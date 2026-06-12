Case c = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = 'cursor-test diag kb context'
);
insert c;

KbPromptContextService.saveCandidates(
    c.Id,
    KbCandidateSearchService.NONE_MARKER
);

Case linked = [
    SELECT KB_Candidates__c
    FROM Case
    WHERE Id = :c.Id
];
System.debug('case candidates: ' + linked.KB_Candidates__c);
