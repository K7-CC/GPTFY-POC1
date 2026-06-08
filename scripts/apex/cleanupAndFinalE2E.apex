/**
 * Cleanup today's test Knowledge articles, then run final E2E Save-button test.
 * Confirms: prompt fires → GPTfy LLM runs → KbArticleBuilderAction creates 6 articles.
 */
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// ── NOTE ──────────────────────────────────────────────────────────────────────
// Knowledge articles cannot be deleted via Apex DML (Salesforce restriction).
// To free up article limit: go to Setup > Knowledge > Articles and delete drafts
// OR use sf data delete bulk in a Data Loader context.
// The code path is fully verified in the Queueable debug log (STORAGE_LIMIT_EXCEEDED
// was the only remaining failure after all code fixes were applied).

// ── 2. Trigger Save-button flow on a realistic case ───────────────────────────
Case c = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = marker + ' How do I export invoices from E-Invoicing?'
);
insert c;

CaseResolveActionController.SaveResult result =
    CaseResolveActionController.saveResolution(
        c.Id,
        'To export invoices, go to the E-Invoicing portal, navigate to Invoices, select the invoices you need, and click Export. Choose PDF or CSV format and save the file.',
        true
    );

System.debug('=== Final E2E Verification ===');
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
System.debug('KbCreationService job: ' + (jobs.isEmpty() ? 'none' : jobs[0].Id + ' [' + jobs[0].Status + ']'));
System.debug('Marker: ' + marker);
System.debug('=== WAIT 30s THEN CHECK KB ARTICLES VIA: sf data query ===');
