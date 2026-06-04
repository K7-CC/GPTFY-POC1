/**
 * Verification script — PATH 2 (GPTfy Agent / Vector Store)
 *
 * Run AFTER deploying force-app-agent-path and AFTER:
 *   1. Case_Resolution_RTF flow is INACTIVE
 *   2. CaseAIAgentTrigger is ACTIVE
 *   3. GPTfy Agent invocable name is filled in CaseAgentResolutionService
 *   4. RAG sync is configured on the Case Resolve Agent in GPTfy
 *
 * Usage:
 *   sf apex run --file scripts/apex/agent-path/testAgentPath.apex --target-org gptfy-poc1
 *
 * Then poll Case.Description with:
 *   sf data query --query "SELECT Id, CaseNumber, Subject, Description FROM Case WHERE Subject LIKE 'cursor-test%' ORDER BY CreatedDate DESC LIMIT 5" --target-org gptfy-poc1
 */

String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// 1. Insert a test Case (Origin='Web' triggers CaseAIAgentTrigger)
Case c = new Case(
    Origin        = 'Web',
    Status        = 'New',
    Priority      = 'Medium',
    Subject       = marker + ' how do I install PowerPDF on Windows?',
    SuppliedName  = 'Cursor Test User',
    SuppliedEmail = 'cursor-test@example.com'
);
insert c;

Case created = [SELECT Id, CaseNumber FROM Case WHERE Id = :c.Id LIMIT 1];

System.debug('=== PATH 2 AGENT TEST STARTED ===');
System.debug('Marker      : ' + marker);
System.debug('Case Id     : ' + created.Id);
System.debug('Case Number : ' + created.CaseNumber);
System.debug('Lightning URL: https://gptfy-poc1.lightning.force.com/lightning/r/Case/' + created.Id + '/view');
System.debug('');
System.debug('Next step: Wait 15-60 seconds, then poll Case.Description with:');
System.debug('sf data query --query "SELECT Id, CaseNumber, Subject, Description FROM Case WHERE Id = \'' + created.Id + '\'" --target-org gptfy-poc1');
System.debug('');
System.debug('Expected: Description should contain a vector-store answer (not empty, not a low-quality fallback).');
System.debug('=== CURSOR TEST INITIATED — check Description after agent runs ===');
