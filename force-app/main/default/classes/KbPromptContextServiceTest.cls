/**
 * Unit tests for KbPromptContextService.
 */
@IsTest
private class KbPromptContextServiceTest {

    @IsTest
    static void saveCandidates_writesToCaseField() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'cursor-test context save'
        );
        insert c;

        Test.startTest();
        KbPromptContextService.saveCandidates(
            c.Id,
            KbCandidateSearchService.NONE_MARKER
        );
        Test.stopTest();

        Case updatedCase = [
            SELECT KB_Candidates__c
            FROM Case
            WHERE Id = :c.Id
        ];
        System.assertEquals(KbCandidateSearchService.NONE_MARKER, updatedCase.KB_Candidates__c);
    }

    @IsTest
    static void clearForCase_clearsCandidatesField() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'cursor-test context clear'
        );
        insert c;

        KbPromptContextService.saveCandidates(c.Id, 'CANDIDATE_1\nId: test');

        Test.startTest();
        KbPromptContextService.clearForCase(c.Id);
        Test.stopTest();

        Case clearedCase = [
            SELECT KB_Candidates__c
            FROM Case
            WHERE Id = :c.Id
        ];
        System.assertEquals(null, clearedCase.KB_Candidates__c);
    }
}
