KB_Prompt_Context__c ctx = new KB_Prompt_Context__c(
    Candidates__c = 'cursor diag test'
);
insert ctx;
System.debug('ctx id: ' + ctx.Id);

List<KB_Prompt_Context__c> rows = [
    SELECT Id, Candidates__c
    FROM KB_Prompt_Context__c
    WHERE Id = :ctx.Id
];
System.debug('rows: ' + rows.size());
System.debug('candidates: ' + rows[0].Candidates__c);

Case c = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = 'cursor-test diag kb context'
);
insert c;

Id contextId = KbPromptContextService.saveCandidates(
    c.Id,
    KbCandidateSearchService.NONE_MARKER
);
System.debug('linked context: ' + contextId);

Case linked = [
    SELECT KB_Prompt_Context__c, KB_Prompt_Context__r.Candidates__c
    FROM Case
    WHERE Id = :c.Id
];
System.debug('case lookup: ' + linked.KB_Prompt_Context__c);
System.debug('case candidates: ' + linked.KB_Prompt_Context__r.Candidates__c);
