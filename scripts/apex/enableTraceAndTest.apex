/**
 * Enable debug logging for KbCreationService Queueable, then trigger E2E test.
 * Run this script, wait 30 seconds, then check the latest debug log.
 */
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// ── 1. Create a DebugLevel if needed, then create a TraceFlag ─────────────────
// Check if our debug level already exists
List<DebugLevel> dbgLevels = [
    SELECT Id FROM DebugLevel WHERE DeveloperName = 'KbTracer' LIMIT 1
];
DebugLevel dbgLevel;
if (dbgLevels.isEmpty()) {
    dbgLevel = new DebugLevel(
        DeveloperName = 'KbTracer',
        MasterLabel   = 'KbTracer',
        ApexCode      = 'FINEST',
        ApexProfiling = 'INFO',
        Callout       = 'INFO',
        Database      = 'INFO',
        System        = 'DEBUG',
        Workflow      = 'INFO',
        Validation    = 'INFO',
        Visualforce   = 'NONE'
    );
    insert dbgLevel;
    System.debug('DebugLevel created: ' + dbgLevel.Id);
} else {
    dbgLevel = dbgLevels[0];
    System.debug('DebugLevel reused: ' + dbgLevel.Id);
}

// Trace the running user for the next 5 minutes
Datetime expiryTime = Datetime.now().addMinutes(5);
TraceFlag tf = new TraceFlag(
    DebugLevelId  = dbgLevel.Id,
    LogType       = 'USER_DEBUG',
    TracedEntityId = '005dN00000BqqfJQAR',
    StartDate     = Datetime.now(),
    ExpirationDate = expiryTime
);
insert tf;
System.debug('TraceFlag created: ' + tf.Id + ' expires: ' + expiryTime);

// ── 2. Trigger the Save-button flow ───────────────────────────────────────────
Case c = new Case(
    Origin        = 'Phone',
    Status        = 'New',
    Subject       = marker + ' How do I add a new user to the portal?'
);
insert c;

CaseResolveActionController.SaveResult result =
    CaseResolveActionController.saveResolution(
        c.Id,
        'To add a new user, go to Admin > Users, click New User, enter their details and click Save.',
        true
    );

List<AsyncApexJob> jobs = [
    SELECT Id, Status
    FROM AsyncApexJob
    WHERE ApexClass.Name = 'KbCreationService'
    AND CreatedDate = TODAY
    ORDER BY CreatedDate DESC
    LIMIT 1
];

System.debug('=== E2E WITH TRACE ===');
System.debug('Case Id: ' + c.Id);
System.debug('caseClosed: ' + result.caseClosed + ' | articleQueued: ' + result.articleQueued);
System.debug('KbCreationService job: ' + (jobs.isEmpty() ? 'none' : jobs[0].Id + ' [' + jobs[0].Status + ']'));
System.debug('Marker: ' + marker);
System.debug('=== WAIT 30s THEN CHECK: sf apex get log --log-id <latest> --target-org gptfy-poc1 ===');
