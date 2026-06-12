/**
 * E2E: Case.KB_Candidates__c staging + chained KbCreationService prompt.
 */
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

Case testCase = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = marker + ' License Activation Server and Software Download Disruption'
);
insert testCase;

CaseResolveActionController.saveResolution(
    testCase.Id,
    'Open a Critical Case via the Customer Portal for licensing issues affecting activation servers.',
    true
);

Case staged = [
    SELECT KB_Candidates__c
    FROM Case
    WHERE Id = :testCase.Id
];
System.debug('KB_Candidates__c after enqueue (may still be null until queueable runs): ' + staged.KB_Candidates__c);
System.debug('Case Id: ' + testCase.Id);
System.debug('Case URL: https://gptfy-poc1.lightning.force.com/lightning/r/Case/' + testCase.Id + '/view');
System.debug('Marker: ' + marker);
System.debug('=== CURSOR TEST ENQUEUED — wait ~30s then query Case.KB_Candidates__c and AI Response ===');
