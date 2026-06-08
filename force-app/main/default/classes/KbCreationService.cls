/**
 * Async Queueable that invokes the KB Creation GPTfy prompt for a resolved Case.
 *
 * Enqueued by CaseResolveActionController.saveResolution() when the agent checks
 * "Update Knowledge Base" and clicks Save. Runs in a separate transaction so the
 * HTTP callout to GPTfy is allowed after the Case DML has already committed.
 *
 * After the prompt runs, GPTfy fires the configured Prompt Action which calls
 * KbArticleBuilderAction to parse the response and create the 6 draft articles.
 * This class only triggers the prompt — it does not handle the response itself.
 *
 * GPTfy Prompt: KB Creation Prompt (promptRequestId = 7093be507198515b03c651eedd9552ec71a9a)
 */
public without sharing class KbCreationService implements Queueable, Database.AllowsCallouts {

    private static final String PROMPT_REQUEST_ID = '7093be507198515b03c651eedd9552ec71a9a';

    private final Id caseId;

    public KbCreationService(Id caseId) {
        this.caseId = caseId;
    }

    public void execute(QueueableContext ctx) {
        String eventUUID = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 32);
        System.debug(LoggingLevel.INFO,
            'KbCreationService: invoking prompt for Case ' + caseId +
            ' | eventUUID=' + eventUUID);
        try {
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
