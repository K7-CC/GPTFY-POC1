/**
 * Unit tests for KbCreationService.
 */
@IsTest
private class KbCreationServiceTest {

    @IsTest
    static void execute_savesCandidatesBeforePromptInvocation() {
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
            SELECT KB_Candidates__c
            FROM Case
            WHERE Id = :c.Id
        ];

        System.assertNotEquals(null, after.KB_Candidates__c,
            'Queueable should populate KB_Candidates__c on Case');

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
    static void invokePromptOnly_requiresCandidatesField() {
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
            SELECT KB_Candidates__c
            FROM Case
            WHERE Id = :c.Id
        ];
        System.assertEquals(null, after.KB_Candidates__c,
            'Prompt-only phase should abort when KB_Candidates__c is blank');
    }

    @IsTest
    static void invokePromptOnly_withCandidates_reachesPromptInvocation() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'cursor-test prompt-only with candidates'
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
            SELECT KB_Candidates__c
            FROM Case
            WHERE Id = :c.Id
        ];
        System.assertEquals(KbCandidateSearchService.NONE_MARKER, after.KB_Candidates__c,
            'Candidates should remain on Case through prompt-only phase');
    }
}
