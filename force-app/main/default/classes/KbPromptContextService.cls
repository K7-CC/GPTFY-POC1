/**
 * Creates and clears {@link KB_Prompt_Context__c} staging records on Case.
 */
public without sharing class KbPromptContextService {

    /**
     * Persists candidate search results and links them to the Case for GPTfy merge fields.
     */
    public static Id saveCandidates(Id caseId, String candidatesText) {
        KB_Prompt_Context__c contextRecord = new KB_Prompt_Context__c(
            Case__c         = caseId,
            Candidates__c   = candidatesText
        );
        insert contextRecord;

        update new Case(
            Id                   = caseId,
            KB_Prompt_Context__c = contextRecord.Id
        );

        return contextRecord.Id;
    }

    /**
     * Removes the staging lookup from Case and deletes the context record.
     */
    public static void clearForCase(Id caseId) {
        List<Case> cases = [
            SELECT KB_Prompt_Context__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
        if (cases.isEmpty() || cases[0].KB_Prompt_Context__c == null) {
            return;
        }

        Id contextId = cases[0].KB_Prompt_Context__c;
        update new Case(Id = caseId, KB_Prompt_Context__c = null);
        delete new KB_Prompt_Context__c(Id = contextId);
    }
}