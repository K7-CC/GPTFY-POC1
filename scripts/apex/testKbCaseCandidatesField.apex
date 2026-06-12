String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

Case c = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = marker + ' KB candidates on Case field'
);
insert c;

KbPromptContextService.saveCandidates(c.Id, 'CANDIDATE_1\nId: ka0TEST\nTitle: Test Article');

Case afterSave = [
    SELECT KB_Candidates__c
    FROM Case
    WHERE Id = :c.Id
];
System.assert(afterSave.KB_Candidates__c != null, 'FAIL: KB_Candidates__c should be set');
System.assert(afterSave.KB_Candidates__c.contains('CANDIDATE_1'), 'FAIL: candidates text missing');

KbPromptContextService.clearForCase(c.Id);

Case afterClear = [
    SELECT KB_Candidates__c
    FROM Case
    WHERE Id = :c.Id
];
System.assertEquals(null, afterClear.KB_Candidates__c, 'FAIL: KB_Candidates__c should be cleared');

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Case Id: ' + c.Id);
System.debug('Case URL: https://gptfy-poc1.lightning.force.com/lightning/r/Case/' + c.Id + '/view');
