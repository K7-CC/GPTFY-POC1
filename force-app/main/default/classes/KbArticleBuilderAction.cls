/**
 * GPTfy Prompt Action — invoked automatically by GPTfy after the KB Creation
 * Prompt generates its response.
 *
 * Implements ccai.AIPromptActionInterface so GPTfy can register and call
 * this class as a Prompt Action on the KB Creation Prompt
 * (promptRequestId = 7093be507198515b03c651eedd9552ec71a9a).
 *
 * GPTfy calls invokeApex() with the ccai__AI_Response__c record after the
 * LLM returns its output. This method reads the response text and the
 * originating Case Id, then:
 *   1. Parses 6 Q&A pairs (1 original + 5 variations) from the response
 *   2. Inserts 6 draft Knowledge__kav articles (Title = question, Resolution__c = answer)
 *   3. Links all 6 articles back to the Case via CaseArticle
 *
 * Expected prompt response format:
 *   Portal Question: "[question]"
 *   OG Answer: "[answer]"
 *
 *   Other possible Questions & Answers
 *
 *   Question 1: "[question]"
 *   Answer 1: "[answer]"
 *   ...
 *   Question 5: "[question]"
 *   Answer 5: "[answer]"
 */
global without sharing class KbArticleBuilderAction implements ccai.AIPromptActionInterface {

    // ─── Inner Q&A pair ────────────────────────────────────────────────────────

    @TestVisible
    private class QAPair {
        public String question;
        public String answer;

        QAPair(String q, String a) {
            this.question = q;
            this.answer   = a;
        }
    }

    // ─── Interface entry point ─────────────────────────────────────────────────

    /**
     * Called by GPTfy after the KB Creation Prompt runs.
     *
     * GPTfy writes the LLM response text to ccai__AI_Processed_Data_PII_Added__c
     * (ccai__Message__c stays null in the current GPTfy build).
     * We read ccai__AI_Processed_Data_PII_Added__c first and fall back to
     * ccai__Message__c for forward compatibility.
     *
     * ccai__Record_Id__c = the Id of the Case that triggered the prompt.
     */
    global void invokeApex(ccai__AI_Response__c response) {
        String responseText = response?.ccai__AI_Processed_Data_PII_Added__c;
        if (String.isBlank(responseText)) {
            responseText = response?.ccai__Message__c;
        }

        if (String.isBlank(responseText)) {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: blank/null AI response, skipping KB article creation.');
            return;
        }

        // GPTfy wraps errors in {"error":{"message":"..."}} — skip those
        if (responseText.startsWith('{') && responseText.contains('"error"')) {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: GPTfy returned an error response, skipping. Response: '
                + responseText.abbreviate(500));
            return;
        }

        List<QAPair> pairs = parseResponse(responseText);

        if (pairs.isEmpty()) {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: no Q&A pairs could be parsed from response.');
            return;
        }

        Id caseId = null;
        if (String.isNotBlank(response.ccai__Record_Id__c)) {
            try {
                caseId = Id.valueOf(response.ccai__Record_Id__c);
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN,
                    'KbArticleBuilderAction: could not parse Record Id "' +
                    response.ccai__Record_Id__c + '" — articles will be created without a Case link.');
            }
        }

        createKnowledgeArticles(pairs, caseId);
    }

    // ─── Response parser ───────────────────────────────────────────────────────

    /**
     * Extracts up to 6 Q&A pairs from the structured prompt response.
     * Pair 0  → Portal Question + OG Answer (original)
     * Pairs 1-5 → Question N + Answer N (variations)
     */
    @TestVisible
    static List<QAPair> parseResponse(String responseText) {
        List<QAPair> pairs = new List<QAPair>();

        // Pair 0: original question and enhanced answer
        String portalQ = extractFirst(responseText, 'Portal Question:\\s*"([^"]+)"');
        String ogA     = extractFirst(responseText, 'OG Answer:\\s*"([^"]+)"');
        if (String.isNotBlank(portalQ) && String.isNotBlank(ogA)) {
            pairs.add(new QAPair(portalQ.trim(), ogA.trim()));
        }

        // Pairs 1-5: numbered variations
        Pattern qPat = Pattern.compile('Question (\\d+):\\s*"([^"]+)"');
        Pattern aPat = Pattern.compile('Answer (\\d+):\\s*"([^"]+)"');

        Map<Integer, String> questions = new Map<Integer, String>();
        Map<Integer, String> answers   = new Map<Integer, String>();

        Matcher qm = qPat.matcher(responseText);
        while (qm.find()) {
            questions.put(Integer.valueOf(qm.group(1)), qm.group(2).trim());
        }

        Matcher am = aPat.matcher(responseText);
        while (am.find()) {
            answers.put(Integer.valueOf(am.group(1)), am.group(2).trim());
        }

        for (Integer i = 1; i <= 5; i++) {
            if (questions.containsKey(i) && answers.containsKey(i)) {
                pairs.add(new QAPair(questions.get(i), answers.get(i)));
            }
        }

        return pairs;
    }

    private static String extractFirst(String text, String regexPattern) {
        Matcher m = Pattern.compile(regexPattern).matcher(text);
        return m.find() ? m.group(1) : null;
    }

    // ─── Article creation ──────────────────────────────────────────────────────

    /**
     * Bulk-inserts 6 draft Knowledge__kav articles and links them to the Case.
     * Title is capped at 255 chars. A random suffix on UrlName guarantees
     * uniqueness across the batch and against existing articles.
     */
    private static void createKnowledgeArticles(List<QAPair> pairs, Id caseId) {
        List<Knowledge__kav> articlesToInsert = new List<Knowledge__kav>();

        for (Integer i = 0; i < pairs.size(); i++) {
            QAPair pair  = pairs[i];
            String title = String.isBlank(pair.question) ? 'KB Article ' + i : pair.question;
            if (title.length() > 255) {
                title = title.substring(0, 255);
            }

            articlesToInsert.add(new Knowledge__kav(
                Title         = title,
                UrlName       = buildUrlSlug(pair.question, i),
                Language      = 'en_US',
                Resolution__c = pair.answer
            ));
        }

        try {
            insert articlesToInsert;
        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR,
                'KbArticleBuilderAction: failed to insert Knowledge articles — ' +
                e.getMessage());
            return;
        }

        if (caseId == null) {
            return;
        }

        // Re-query to get KnowledgeArticleId (parent record, required by CaseArticle)
        List<Id> kavIds = new List<Id>();
        for (Knowledge__kav kav : articlesToInsert) {
            kavIds.add(kav.Id);
        }

        List<Knowledge__kav> refreshed = [
            SELECT Id, KnowledgeArticleId
            FROM Knowledge__kav
            WHERE Id IN :kavIds
        ];

        List<CaseArticle> links = new List<CaseArticle>();
        for (Knowledge__kav kav : refreshed) {
            if (kav.KnowledgeArticleId != null) {
                links.add(new CaseArticle(
                    CaseId             = caseId,
                    KnowledgeArticleId = kav.KnowledgeArticleId
                ));
            }
        }

        if (!links.isEmpty()) {
            try {
                insert links;
            } catch (DmlException e) {
                System.debug(LoggingLevel.ERROR,
                    'KbArticleBuilderAction: failed to insert CaseArticle links — ' +
                    e.getMessage());
            }
        }
    }

    // ─── URL slug helper ───────────────────────────────────────────────────────

    /**
     * Builds a URL-safe, unique slug for Knowledge__kav.UrlName.
     * A random 8-char hex suffix prevents collisions within the batch
     * and against existing articles in the org.
     */
    @TestVisible
    static String buildUrlSlug(String question, Integer index) {
        String base = String.isBlank(question) ? 'kb-article' : question.toLowerCase();
        String slug = base.replaceAll('[^a-z0-9]+', '-')
                         .replaceAll('^-+', '')
                         .replaceAll('-+$', '');
        if (String.isBlank(slug)) {
            slug = 'kb-article';
        }
        if (slug.length() > 180) {
            slug = slug.substring(0, 180);
        }

        String rand = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 8);
        return slug + '-' + index + '-' + rand;
    }
}
