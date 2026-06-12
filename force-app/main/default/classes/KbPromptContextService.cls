/**
 * Writes and clears {@link Case.KB_Candidates__c} staging data for the KB Creation Prompt.
 */
public without sharing class KbPromptContextService {

    /**
     * Persists candidate search results on the Case for GPTfy merge fields.
     */
    public static void saveCandidates(Id caseId, String candidatesText) {
        update new Case(
            Id               = caseId,
            KB_Candidates__c = candidatesText
        );
    }

    /**
     * Clears staged candidate text from the Case after KB processing completes.
     */
    public static void clearForCase(Id caseId) {
        List<Case> cases = [
            SELECT KB_Candidates__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];
        if (cases.isEmpty() || cases[0].KB_Candidates__c == null) {
            return;
        }

        update new Case(
            Id               = caseId,
            KB_Candidates__c = null
        );
    }
}
