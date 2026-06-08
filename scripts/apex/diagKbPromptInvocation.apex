/**
 * Diagnostic script: traces the full KB prompt invocation path
 * Step 1 — Confirms saveResolution enqueues KbCreationService
 * Step 2 — Directly tests the Invocable.Action call (no callout, so we catch the callout restriction)
 * Step 3 — Queries recent AsyncApexJob failures for KbCreationService
 *
 * Tag: cursor-test-<timestamp>
 */
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// ── 1. Create a test Case ─────────────────────────────────────────────────────
Case testCase = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = marker + ' diag KB prompt invocation'
);
insert testCase;
System.debug('=== Case Created: ' + testCase.Id);
System.debug('Case URL: https://gptfy-poc1.lightning.force.com/lightning/r/Case/' + testCase.Id + '/view');

// ── 2. Call saveResolution — should enqueue KbCreationService ─────────────────
CaseResolveActionController.SaveResult res =
    CaseResolveActionController.saveResolution(
        testCase.Id, 'Cursor diagnostic resolution.', true);

System.debug('caseClosed:    ' + res.caseClosed);
System.debug('articleQueued: ' + res.articleQueued);
System.debug('articleWarning: ' + res.articleWarning);

// ── 3. Confirm the Queueable job is queued ────────────────────────────────────
List<AsyncApexJob> jobs = [
    SELECT Id, Status, ApexClass.Name, NumberOfErrors, ExtendedStatus
    FROM AsyncApexJob
    WHERE ApexClass.Name = 'KbCreationService'
    AND CreatedDate = TODAY
    ORDER BY CreatedDate DESC
    LIMIT 5
];
System.debug('=== KbCreationService jobs today: ' + jobs.size());
for (AsyncApexJob j : jobs) {
    System.debug('  Job ' + j.Id + ' | Status: ' + j.Status
        + ' | Errors: ' + j.NumberOfErrors
        + ' | ExtendedStatus: ' + j.ExtendedStatus);
}

// ── 4. Direct Invocable.Action smoke test (no HTTP — expect callout error here) ─
System.debug('=== Testing Invocable.Action directly ===');
try {
    Invocable.Action action = Invocable.Action.createCustomAction(
        'apex', 'ccai__AIPromptProcessingInvokable');
    action.setInvocationParameter('promptRequestId', '7093be507198515b03c651eedd9552ec71a9a');
    action.setInvocationParameter('recordId', (String) testCase.Id);
    action.setInvocationParameter(
        'eventUUID',
        EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0, 32)
    );
    List<Invocable.Action.Result> results = action.invoke();
    System.debug('invoke() returned ' + results.size() + ' result(s)');
    for (Invocable.Action.Result r : results) {
        System.debug('  success=' + r.isSuccess());
        if (!r.isSuccess()) {
            System.debug('  errors=' + r.getErrors());
        }
    }
} catch (Exception ex) {
    System.debug('Invocable.Action exception: [' + ex.getTypeName() + '] ' + ex.getMessage());
}

// ── 5. Check for any recent failed Queueable jobs ─────────────────────────────
List<AsyncApexJob> failedJobs = [
    SELECT Id, Status, ApexClass.Name, ExtendedStatus, CreatedDate
    FROM AsyncApexJob
    WHERE ApexClass.Name = 'KbCreationService'
    AND Status IN ('Failed', 'Aborted')
    AND CreatedDate = LAST_N_DAYS:7
    ORDER BY CreatedDate DESC
    LIMIT 10
];
System.debug('=== KbCreationService failed jobs (last 7 days): ' + failedJobs.size());
for (AsyncApexJob j : failedJobs) {
    System.debug('  ' + j.CreatedDate + ' | ' + j.Status + ' | ' + j.ExtendedStatus);
}

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Test Case Id: ' + testCase.Id);
