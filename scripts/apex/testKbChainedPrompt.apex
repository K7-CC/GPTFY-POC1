/**
 * E2E: chained KbCreationService — candidates must commit before GPTfy prompt runs.
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

System.debug('Case Id: ' + testCase.Id);
System.debug('Case URL: https://gptfy-poc1.lightning.force.com/lightning/r/Case/' + testCase.Id + '/view');
System.debug('Marker: ' + marker);
System.debug('=== CURSOR TEST ENQUEUED — wait ~30s then query AI Response ===');
