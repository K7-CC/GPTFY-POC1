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
 *   1. Parses Action (CREATE/UPDATE), ArticleId, Question, and Answer
 *   2. Creates a new draft article OR updates an existing one
 *   3. Links the article back to the Case via CaseArticle
 *   4. Clears Case.KB_Candidates__c staging field
 *
 * Expected prompt response format:
 *   Action: CREATE or UPDATE
 *   ArticleId: [Knowledge__kav Id if UPDATE, blank if CREATE]
 *   Question: "[original customer question, exactly as submitted]"
 *   Answer: "[enhanced professional answer]"
 */
global without sharing class KbArticleBuilderAction implements ccai.AIPromptActionInterface {

    private static final String ACTION_CREATE = 'CREATE';
    private static final String ACTION_UPDATE = 'UPDATE';

    // ─── Parsed prompt result ──────────────────────────────────────────────────

    @TestVisible
    class PromptResult {
        public String action;
        public String articleId;
        public String question;
        public String answer;

        PromptResult(String action, String articleId, String question, String answer) {
            this.action    = action;
            this.articleId = articleId;
            this.question  = question;
            this.answer    = answer;
        }
    }

    // ─── Interface entry point ─────────────────────────────────────────────────

    global void invokeApex(ccai__AI_Response__c response) {
        String responseText = response?.ccai__AI_Processed_Data_PII_Added__c;
        if (String.isBlank(responseText)) {
            responseText = response?.ccai__Message__c;
        }

        if (String.isBlank(responseText)) {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: blank/null AI response, skipping KB article processing.');
            return;
        }

        if (responseText.startsWith('{') && responseText.contains('"error"')) {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: GPTfy returned an error response, skipping. Response: '
                + responseText.abbreviate(500));
            return;
        }

        PromptResult result = parseResponse(responseText);
        if (result == null || String.isBlank(result.question) || String.isBlank(result.answer)) {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: no valid Q&A could be parsed from response.');
            return;
        }

        Id caseId = null;
        if (String.isNotBlank(response.ccai__Record_Id__c)) {
            try {
                caseId = Id.valueOf(response.ccai__Record_Id__c);
            } catch (Exception e) {
                System.debug(LoggingLevel.WARN,
                    'KbArticleBuilderAction: could not parse Record Id "' +
                    response.ccai__Record_Id__c + '" — article will not be linked to Case.');
            }
        }

        Id knowledgeArticleId = null;
        if (ACTION_UPDATE.equalsIgnoreCase(result.action) && String.isNotBlank(result.articleId)) {
            knowledgeArticleId = updateKnowledgeArticle(result);
            if (knowledgeArticleId == null) {
                System.debug(LoggingLevel.WARN,
                    'KbArticleBuilderAction: UPDATE failed for ArticleId ' + result.articleId +
                    ' — falling back to CREATE.');
                knowledgeArticleId = createKnowledgeArticle(result);
            }
        } else {
            knowledgeArticleId = createKnowledgeArticle(result);
        }

        if (caseId != null && knowledgeArticleId != null) {
            linkArticleToCase(caseId, knowledgeArticleId);
            clearPromptContext(caseId);
        }
    }

    // ─── Response parser ───────────────────────────────────────────────────────

    @TestVisible
    static PromptResult parseResponse(String responseText) {
        String action    = extractFirst(responseText, '(?i)Action:\\s*(CREATE|UPDATE)');
        String articleId = extractFirst(responseText, '(?i)ArticleId:\\s*(\\S+)');
        String question  = extractFirst(responseText, '(?i)Question:\\s*"([^"]+)"');
        String answer    = extractFirst(responseText, '(?i)Answer:\\s*"([^"]+)"');

        if (String.isBlank(action)) {
            action = ACTION_CREATE;
        }
        if (ACTION_CREATE.equalsIgnoreCase(action)) {
            articleId = null;
        }
        if (String.isBlank(question) || String.isBlank(answer)) {
            return null;
        }

        return new PromptResult(
            action.toUpperCase(),
            String.isNotBlank(articleId) ? articleId.trim() : null,
            question.trim(),
            answer.trim()
        );
    }

    private static String extractFirst(String text, String regexPattern) {
        Matcher m = Pattern.compile(regexPattern).matcher(text);
        return m.find() ? m.group(1) : null;
    }

    // ─── Article create / update ─────────────────────────────────────────────────

    private static Id createKnowledgeArticle(PromptResult result) {
        String title = buildTitle(result.question);

        Knowledge__kav article = new Knowledge__kav(
            Title         = title,
            UrlName       = buildUrlSlug(result.question, 0),
            Language      = 'en_US',
            Resolution__c = result.answer
        );

        try {
            insert article;
        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR,
                'KbArticleBuilderAction: failed to insert Knowledge article — ' + e.getMessage());
            return null;
        }

        Knowledge__kav refreshed = [
            SELECT KnowledgeArticleId
            FROM Knowledge__kav
            WHERE Id = :article.Id
            LIMIT 1
        ];
        return refreshed.KnowledgeArticleId;
    }

    private static Id updateKnowledgeArticle(PromptResult result) {
        Id kavId;
        try {
            kavId = Id.valueOf(result.articleId);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: invalid ArticleId "' + result.articleId + '"');
            return null;
        }

        List<Knowledge__kav> existing = [
            SELECT Id, KnowledgeArticleId, PublishStatus, Title
            FROM Knowledge__kav
            WHERE Id = :kavId
            LIMIT 1
        ];
        if (existing.isEmpty()) {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: no Knowledge__kav found for Id ' + kavId);
            return null;
        }

        Knowledge__kav current = existing[0];
        String title = buildTitle(result.question);
        Id draftKavId = current.Id;

        if (current.PublishStatus == 'Online') {
            try {
                String draftKavIdStr = KbManagement.PublishingService.editOnlineArticle(
                    String.valueOf(current.KnowledgeArticleId),
                    false
                );
                draftKavId = Id.valueOf(draftKavIdStr);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR,
                    'KbArticleBuilderAction: editOnlineArticle failed — ' + e.getMessage());
                return null;
            }
        } else if (current.PublishStatus != 'Draft') {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: unsupported PublishStatus "' + current.PublishStatus +
                '" for article ' + kavId);
            return null;
        }

        try {
            update new Knowledge__kav(
                Id            = draftKavId,
                Title         = title,
                Resolution__c = result.answer
            );
        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR,
                'KbArticleBuilderAction: failed to update Knowledge article — ' + e.getMessage());
            return null;
        }

        return current.KnowledgeArticleId;
    }

    private static String buildTitle(String question) {
        String title = String.isBlank(question) ? 'KB Article' : question;
        return title.length() > 255 ? title.substring(0, 255) : title;
    }

    // ─── Case linkage and cleanup ────────────────────────────────────────────────

    private static void linkArticleToCase(Id caseId, Id knowledgeArticleId) {
        try {
            insert new CaseArticle(
                CaseId             = caseId,
                KnowledgeArticleId = knowledgeArticleId
            );
        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR,
                'KbArticleBuilderAction: failed to insert CaseArticle link — ' + e.getMessage());
        }
    }

    private static void clearPromptContext(Id caseId) {
        try {
            KbPromptContextService.clearForCase(caseId);
        } catch (DmlException e) {
            System.debug(LoggingLevel.WARN,
                'KbArticleBuilderAction: failed to clear KB prompt context — ' + e.getMessage());
        }
    }

    // ─── URL slug helper ───────────────────────────────────────────────────────

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
