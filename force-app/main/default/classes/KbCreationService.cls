/**
 * Async Queueable that invokes the KB Creation GPTfy prompt for a resolved Case.
 *
 * Enqueued by CaseResolveActionController.saveResolution() when the agent checks
 * "Update Knowledge Base" and clicks Save.
 *
 * Runs in TWO chained transactions:
 *   Phase 1 — SOSL candidate search + persist KB_Prompt_Context__c (DML only).
 *   Phase 2 — Invoke GPTfy prompt (callout only), after Phase 1 commits so
 *             GPTfy's data-extraction REST query can see KB_Prompt_Context__r.Candidates__c.
 *
 * After the prompt runs, GPTfy fires the configured Prompt Action which calls
 * KbArticleBuilderAction to parse the response and create or update the article.
 *
 * GPTfy Prompt: KB Creation Prompt (promptRequestId = 7093be507198515b03c651eedd9552ec71a9a)
 */
public without sharing class KbCreationService implements Queueable, Database.AllowsCallouts {

    private static final String PROMPT_REQUEST_ID = '7093be507198515b03c651eedd9552ec71a9a';

    private final Id caseId;
    private final Boolean invokePromptOnly;

    public KbCreationService(Id caseId) {
        this(caseId, false);
    }

    @TestVisible
    private KbCreationService(Id caseId, Boolean invokePromptOnly) {
        this.caseId = caseId;
        this.invokePromptOnly = invokePromptOnly;
    }

    public void execute(QueueableContext ctx) {
        if (!invokePromptOnly) {
            populateCandidatesAndChainPrompt();
            return;
        }
        invokeKbCreationPrompt();
    }

    private void populateCandidatesAndChainPrompt() {
        try {
            Case c = [
                SELECT Id, Subject
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
            ];

            String candidatesText = KbCandidateSearchService.searchAndSerialize(c.Subject);
            Id contextId = KbPromptContextService.saveCandidates(caseId, candidatesText);

            System.debug(LoggingLevel.INFO,
                'KbCreationService: KB_Prompt_Context__c ' + contextId + ' set (' +
                (candidatesText == KbCandidateSearchService.NONE_MARKER ? 'NONE' : 'candidates found') +
                ') for Case ' + caseId + ' — chaining prompt invocation');

            System.enqueueJob(new KbCreationService(caseId, true));
        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'KbCreationService: candidate staging failed for Case ' + caseId +
                ' — ' + e.getTypeName() + ': ' + e.getMessage() +
                ' | Stack: ' + e.getStackTraceString()
            );
        }
    }

    private void invokeKbCreationPrompt() {
        String eventUUID = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 32);
        System.debug(LoggingLevel.INFO,
            'KbCreationService: invoking prompt for Case ' + caseId +
            ' | eventUUID=' + eventUUID);

        try {
            Case c = [
                SELECT Id, KB_Prompt_Context__c, KB_Prompt_Context__r.Candidates__c
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
            ];

            if (c.KB_Prompt_Context__c == null) {
                System.debug(LoggingLevel.ERROR,
                    'KbCreationService: KB_Prompt_Context__c missing on Case ' + caseId +
                    ' — aborting prompt invocation');
                return;
            }

            Invocable.Action action = Invocable.Action.createCustomAction(
                'apex', 'ccai__AIPromptProcessingInvokable');
            action.setInvocationParameter('promptRequestId', PROMPT_REQUEST_ID);
            action.setInvocationParameter('recordId', String.valueOf(caseId));
            action.setInvocationParameter('eventUUID', eventUUID);

            List<Invocable.Action.Result> results = action.invoke();

            for (Invocable.Action.Result r : results) {
                if (r.isSuccess()) {
                    System.debug(LoggingLevel.INFO,
                        'KbCreationService: prompt dispatched successfully for Case ' + caseId);
                } else {
                    System.debug(LoggingLevel.ERROR,
                        'KbCreationService: prompt invocation returned errors for Case ' + caseId +
                        ' — ' + r.getErrors());
                }
            }
            if (results.isEmpty()) {
                System.debug(LoggingLevel.WARN,
                    'KbCreationService: invoke() returned no results for Case ' + caseId);
            }
        } catch (Exception e) {
            System.debug(
                LoggingLevel.ERROR,
                'KbCreationService: prompt invocation failed for Case ' + caseId +
                ' — ' + e.getTypeName() + ': ' + e.getMessage() +
                ' | Stack: ' + e.getStackTraceString()
            );
        }
    }
}
