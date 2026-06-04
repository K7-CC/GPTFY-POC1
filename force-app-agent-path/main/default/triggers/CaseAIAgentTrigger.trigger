/**
 * PATH 2 — GPTfy Agent / Vector Store path.
 *
 * Fires after a new Case with Origin='Web' is inserted (the same gate used by
 * the Case_Resolution_RTF flow in PATH 1). Immediately hands off to
 * CaseAgentResolutionService (Queueable) so the GPTfy Agent invocable can run
 * in an async context that allows callouts.
 *
 * SWITCH MECHANISM
 * ─────────────────
 * • To use PATH 1 (GCP/Flow)   : Activate  Case_Resolution_RTF flow
 *                                 Deactivate this trigger (Setup → Apex Triggers)
 * • To use PATH 2 (Agent/RAG)  : Deactivate Case_Resolution_RTF flow
 *                                 Activate  this trigger (Setup → Apex Triggers)
 *
 * Never run both active at the same time — two AI calls would race to write
 * Case.Description.
 */
trigger CaseAIAgentTrigger on Case (after insert) {
    for (Case c : Trigger.new) {
        if (c.Origin == 'Web' && String.isNotBlank(c.Subject)) {
            System.enqueueJob(
                new CaseAgentResolutionService(c.Id, c.Subject)
            );
        }
    }
}
