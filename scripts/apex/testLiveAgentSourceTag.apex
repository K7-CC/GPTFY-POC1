String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// Create a real Web Case — this triggers the AI agent (PATH 2) via CaseAIAgentTrigger.
// The agent will search the vector store and (with the updated system prompt) append
// [SOURCE: filename] at the end of its answer.
Case c = new Case(
    Origin        = 'Web',
    Status        = 'New',
    Priority      = 'Medium',
    Subject       = marker + ' Power PDF scanner not detected after upgrade',
    SuppliedName  = 'cursor tester',
    SuppliedEmail = 'cursor@test.com'
);
insert c;

System.debug('=== CURSOR TEST: Live Agent Source Tag ===');
System.debug('Marker: ' + marker);
System.debug('Case Id: ' + c.Id);
System.debug('Case created — AI agent queued. Wait ~30-60s then query Description.');
System.debug('Query: SELECT Description FROM Case WHERE Id = \'' + c.Id + '\'');
System.debug('Lightning URL: https://gptfy-poc1.lightning.force.com/lightning/r/Case/' + c.Id + '/view');
System.debug('=== CURSOR TEST COMPLETE ===');
