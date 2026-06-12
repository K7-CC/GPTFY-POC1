/**
 * Unit tests for KbCreationService.
 */
@IsTest
private class KbCreationServiceTest {

    @IsTest
    static void execute_savesPromptContextBeforePromptInvocation() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'cursor-test PowerPDF license activation issue'
        );
        insert c;

        Test.startTest();
        System.enqueueJob(new KbCreationService(c.Id));
        Test.stopTest();

        Case after = [
            SELECT KB_Prompt_Context__c, KB_Prompt_Context__r.Candidates__c
            FROM Case
            WHERE Id = :c.Id
        ];

        System.assertNotEquals(null, after.KB_Prompt_Context__c,
            'Queueable should create and link a KB prompt context record');
        System.assertNotEquals(null, after.KB_Prompt_Context__r.Candidates__c,
            'Candidates text should be populated on the context record');

        List<AsyncApexJob> jobs = [
            SELECT Status
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'KbCreationService'
            AND CreatedDate = TODAY
            ORDER BY CreatedDate DESC
            LIMIT 2
        ];
        System.assert(jobs.size() >= 1, 'At least one KbCreationService job should run');
    }

    @IsTest
    static void invokePromptOnly_requiresLinkedContext() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'cursor-test prompt-only guard'
        );
        insert c;

        Test.startTest();
        System.enqueueJob(new KbCreationService(c.Id, true));
        Test.stopTest();

        Case after = [
            SELECT KB_Prompt_Context__c
            FROM Case
            WHERE Id = :c.Id
        ];
        System.assertEquals(null, after.KB_Prompt_Context__c,
            'Prompt-only phase should abort when no context is linked');
    }

    @IsTest
    static void invokePromptOnly_withLinkedContext_reachesPromptInvocation() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'cursor-test prompt-only with context'
        );
        insert c;

        KbPromptContextService.saveCandidates(
            c.Id,
            KbCandidateSearchService.NONE_MARKER
        );

        Test.startTest();
        System.enqueueJob(new KbCreationService(c.Id, true));
        Test.stopTest();

        Case after = [
            SELECT KB_Prompt_Context__c, KB_Prompt_Context__r.Candidates__c
            FROM Case
            WHERE Id = :c.Id
        ];
        System.assertNotEquals(null, after.KB_Prompt_Context__c,
            'Context should remain linked through prompt-only phase');
        System.assertEquals(KbCandidateSearchService.NONE_MARKER,
            after.KB_Prompt_Context__r.Candidates__c);
    }
}
