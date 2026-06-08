/**
 * End-to-end Save-button test:
 *   1. Create a realistic Case (Subject + Resolution like a real agent would fill in)
 *   2. Call saveResolution(createKb=true) — same code path as the Save button
 *   3. Log the queued Job Id so we can poll it
 *
 * Run this first, then run testSaveButtonE2E_check.apex after ~15 seconds to
 * see KB articles created by the async GPTfy flow.
 *
 * Tag: cursor-test-<timestamp>
 */
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

Case c = new Case(
    Origin        = 'Phone',
    Status        = 'New',
    Subject       = 'How do I add a new user to the E-Invoicing portal?',
    Resolution__c = 'Log in to the E-Invoicing admin portal, navigate to User Management, click Add User, fill in the required details (name, email, role), and click Save. The new user will receive an activation email.'
);
insert c;

CaseResolveActionController.SaveResult result =
    CaseResolveActionController.saveResolution(
        c.Id,
        c.Resolution__c,
        true
    );

System.debug('=== Save Button E2E Test ===');
System.debug('Case Id: ' + c.Id);
System.debug('Case URL: https://gptfy-poc1.lightning.force.com/lightning/r/Case/' + c.Id + '/view');
System.debug('caseClosed:    ' + result.caseClosed);
System.debug('articleQueued: ' + result.articleQueued);

List<AsyncApexJob> jobs = [
    SELECT Id, Status
    FROM AsyncApexJob
    WHERE ApexClass.Name = 'KbCreationService'
    AND CreatedDate = TODAY
    ORDER BY CreatedDate DESC
    LIMIT 1
];
System.debug('KbCreationService job: ' + (jobs.isEmpty() ? 'not found' : jobs[0].Id + ' [' + jobs[0].Status + ']'));
System.debug('Marker: ' + marker);
System.debug('=== WAIT ~20 SECONDS then run testSaveButtonE2E_check.apex with Case Id: ' + c.Id + ' ===');
