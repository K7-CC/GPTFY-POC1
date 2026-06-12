/**
 * Unit tests for KbPromptContextService.
 */
@IsTest
private class KbPromptContextServiceTest {

    @IsTest
    static void saveCandidates_createsContextAndLinksCase() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'cursor-test context save'
        );
        insert c;

        Test.startTest();
        Id contextId = KbPromptContextService.saveCandidates(
            c.Id,
            KbCandidateSearchService.NONE_MARKER
        );
        Test.stopTest();

        KB_Prompt_Context__c contextRecord = [
            SELECT Candidates__c
            FROM KB_Prompt_Context__c
            WHERE Id = :contextId
        ];
        System.assertEquals(KbCandidateSearchService.NONE_MARKER, contextRecord.Candidates__c);

        Case linkedCase = [
            SELECT KB_Prompt_Context__c
            FROM Case
            WHERE Id = :c.Id
        ];
        System.assertEquals(contextId, linkedCase.KB_Prompt_Context__c);
    }

    @IsTest
    static void clearForCase_removesLookupAndDeletesContext() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'cursor-test context clear'
        );
        insert c;

        Id contextId = KbPromptContextService.saveCandidates(c.Id, 'CANDIDATE_1\nId: test');

        Test.startTest();
        KbPromptContextService.clearForCase(c.Id);
        Test.stopTest();

        Case clearedCase = [
            SELECT KB_Prompt_Context__c
            FROM Case
            WHERE Id = :c.Id
        ];
        System.assertEquals(null, clearedCase.KB_Prompt_Context__c);

        Integer remaining = [
            SELECT COUNT()
            FROM KB_Prompt_Context__c
            WHERE Id = :contextId
        ];
        System.assertEquals(0, remaining, 'Context record should be deleted');
    }
}
