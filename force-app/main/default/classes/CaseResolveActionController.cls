/**
 * Apex controller for the caseResolveAction LWC quick action.
 *
 * Runs WITH SHARING because this is an authenticated agent-facing path
 * on the internal Case record page. Standard CRUD/sharing rules should
 * govern who is allowed to update Case.Resolution__c and close the case.
 *
 * Distinct from CaseResolutionController (which is the guest-portal,
 * without-sharing path). The two flows do NOT share Apex.
 *
 * Behaviour on Save:
 *   1. Updates Case.Resolution__c with the agent-typed text and flips
 *      Status to 'Closed' in one DML.
 *   2. Best-effort upsert of a Draft Knowledge__kav article whose Title
 *      mirrors Case.Subject and whose Resolution__c mirrors the typed
 *      text, linked back to the Case via CaseArticle. Failures in the
 *      KB step are isolated - the case still closes.
 */
public with sharing class CaseResolveActionController {

    /**
     * Result envelope returned to the LWC so it can render a precise
     * toast (case closed; draft article created vs updated; KB warning).
     */
    public class SaveResult {
        @AuraEnabled public Boolean caseClosed;
        @AuraEnabled public Id articleId;
        @AuraEnabled public Boolean articleCreated;
        @AuraEnabled public String articleWarning;
    }

    /**
     * Test seam: when true, upsertDraftArticleForCase throws on entry so
     * tests can exercise the "case closed but KB failed" branch without
     * trying to construct an artificial Knowledge validation failure.
     * Not @AuraEnabled - cannot be flipped from the UI.
     */
    @TestVisible
    private static Boolean forceArticleFailureForTest = false;

    /**
     * Saves the agent-authored resolution text, closes the Case, and
     * optionally upserts a linked Draft Knowledge article in a single round trip.
     *
     * The Case.Resolution__c field is declared as Html, but we deliberately
     * write the raw plain text the agent typed - no <p>/<br> wrapping and
     * no HTML entity escaping. Trade-off: line breaks may collapse when
     * rendered, but the stored representation matches exactly what the
     * agent typed.
     *
     * @param caseId          The Id of the Case to resolve. Required.
     * @param resolutionText  Plain-text resolution to copy verbatim into
     *                        Case.Resolution__c. Required, may not be blank.
     * @param createKb        When true, upserts a linked Draft Knowledge article.
     *                        When false, only closes the case and saves the resolution.
     *
     * @throws AuraHandledException if inputs are missing or the Case DML
     *         fails. Knowledge failures are non-fatal and surfaced via
     *         SaveResult.articleWarning.
     */
    @AuraEnabled
    public static SaveResult saveResolution(Id caseId, String resolutionText, Boolean createKb) {
        if (caseId == null) {
            throw new AuraHandledException('Case Id is required.');
        }
        if (String.isBlank(resolutionText)) {
            throw new AuraHandledException('Resolution text is required.');
        }

        Case toUpdate = new Case(
            Id            = caseId,
            Resolution__c = resolutionText,
            Status        = 'Closed'
        );

        try {
            update toUpdate;
        } catch (DmlException e) {
            String detail = e.getNumDml() > 0
                ? e.getDmlMessage(0)
                : e.getMessage();
            throw new AuraHandledException('Unable to save resolution: ' + detail);
        } catch (Exception e) {
            throw new AuraHandledException('Unable to save resolution: ' + e.getMessage());
        }

        SaveResult result = new SaveResult();
        result.caseClosed = true;

        if (createKb == true) {
            try {
                upsertDraftArticleForCase(caseId, resolutionText, result);
            } catch (Exception e) {
                result.articleWarning =
                    'Case closed, but draft Knowledge article could not be saved: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR,
                    'CaseResolveActionController: KB draft failed for Case ' + caseId + ' - ' + e);
            }
        }

        return result;
    }

    /**
     * Upserts the Draft Knowledge article that mirrors this case.
     *
     * Dedupe semantics: if any CaseArticle already links this Case to a
     * Knowledge__kav whose PublishStatus = 'Draft', we update that draft
     * in place (Title + Resolution__c) instead of inserting a duplicate.
     * Only the most-recently-modified matching draft is touched.
     *
     * On insert path we have to re-query the freshly inserted kav to
     * read its KnowledgeArticleId (the parent article record, distinct
     * from the version Id). CaseArticle.KnowledgeArticleId references
     * the parent, not the version.
     *
     * Mutates result in place: sets articleId and articleCreated.
     */
    private static void upsertDraftArticleForCase(
        Id caseId,
        String resolutionText,
        SaveResult result
    ) {
        if (Test.isRunningTest() && forceArticleFailureForTest) {
            throw new IllegalArgumentException('Simulated KB failure for test.');
        }

        List<Case> cases = [
            SELECT Id, CaseNumber, Subject
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
        if (cases.isEmpty()) {
            throw new IllegalArgumentException('Case ' + caseId + ' not found.');
        }
        Case theCase = cases[0];

        String articleTitle = String.isNotBlank(theCase.Subject)
            ? theCase.Subject
            : 'Case ' + theCase.CaseNumber;

        Id existingDraftId = findExistingDraftArticleId(caseId);

        if (existingDraftId != null) {
            Knowledge__kav existing = new Knowledge__kav(
                Id            = existingDraftId,
                Title         = articleTitle,
                Resolution__c = resolutionText
            );
            update existing;
            result.articleId = existingDraftId;
            result.articleCreated = false;
            return;
        }

        Knowledge__kav kav = new Knowledge__kav(
            Title         = articleTitle,
            UrlName       = buildUniqueUrlName(articleTitle, theCase.CaseNumber),
            Language      = 'en_US',
            Resolution__c = resolutionText
        );
        insert kav;

        Knowledge__kav refreshed = [
            SELECT Id, KnowledgeArticleId
            FROM Knowledge__kav
            WHERE Id = :kav.Id
            LIMIT 1
        ];

        insert new CaseArticle(
            CaseId             = caseId,
            KnowledgeArticleId = refreshed.KnowledgeArticleId
        );

        result.articleId = refreshed.Id;
        result.articleCreated = true;
    }

    /**
     * Finds the most-recently-modified Draft Knowledge__kav already
     * linked to this Case via CaseArticle. Returns null if none.
     */
    private static Id findExistingDraftArticleId(Id caseId) {
        Set<Id> parentArticleIds = new Set<Id>();
        for (CaseArticle ca : [
            SELECT KnowledgeArticleId
            FROM CaseArticle
            WHERE CaseId = :caseId
        ]) {
            if (ca.KnowledgeArticleId != null) {
                parentArticleIds.add(ca.KnowledgeArticleId);
            }
        }

        if (parentArticleIds.isEmpty()) {
            return null;
        }

        List<Knowledge__kav> drafts = [
            SELECT Id
            FROM Knowledge__kav
            WHERE KnowledgeArticleId IN :parentArticleIds
              AND PublishStatus = 'Draft'
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];

        return drafts.isEmpty() ? null : drafts[0].Id;
    }

    /**
     * Builds a URL-safe, unique-on-best-effort slug for Knowledge__kav.UrlName.
     *
     * Algorithm:
     *   lowercase Title -> non-alphanumerics collapse to '-' -> trim
     *   leading/trailing '-' -> append '-case-{CaseNumber}'.
     *
     * UrlName must be unique across all Knowledge__kav records (not just
     * per case). If a collision is detected we suffix a short random hex
     * fragment. Re-saves on the same case never reach this path because
     * dedupe updates the existing draft.
     */
    @TestVisible
    private static String buildUniqueUrlName(String title, String caseNumber) {
        String safeTitle = String.isBlank(title) ? 'case' : title.toLowerCase();
        String slug = safeTitle.replaceAll('[^a-z0-9]+', '-');
        slug = slug.replaceAll('^-+', '').replaceAll('-+$', '');
        if (String.isBlank(slug)) {
            slug = 'case';
        }

        String suffix = String.isNotBlank(caseNumber) ? '-case-' + caseNumber : '';
        String candidate = slug + suffix;
        if (candidate.length() > 240) {
            candidate = candidate.substring(0, 240);
        }

        Integer collisions = [
            SELECT COUNT()
            FROM Knowledge__kav
            WHERE UrlName = :candidate
        ];
        if (collisions == 0) {
            return candidate;
        }

        String rand = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 6);
        return candidate + '-' + rand;
    }
}
