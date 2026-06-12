// End-to-end verification: Approach 3 KB upsert (SOSL pre-search + CREATE/UPDATE prompt action)
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

System.debug('=== APPROACH 3 KB UPSERT TEST ===');
System.debug('Marker: ' + marker);

// --- Seed an existing draft article that should match the next case subject ---
Knowledge__kav seedArticle = new Knowledge__kav(
    Title         = marker + ' PowerPDF license activation fails after reinstall',
    UrlName       = 'cursor-powerpdf-license-' + Datetime.now().getTime(),
    Language      = 'en_US',
    Resolution__c = 'Ensure the license key matches your product edition. Re-enter the key under Help > License Manager.'
);
insert seedArticle;

seedArticle = [
    SELECT Id, Title, Resolution__c, PublishStatus, KnowledgeArticleId
    FROM Knowledge__kav
    WHERE Id = :seedArticle.Id
];

System.debug('=== SEED ARTICLE ===');
System.debug('Id: ' + seedArticle.Id);
System.debug('Title: ' + seedArticle.Title);
System.debug('PublishStatus: ' + seedArticle.PublishStatus);

// --- Test 1: Candidate search serializes the seed article ---
String candidates = KbCandidateSearchService.searchAndSerialize(
    marker + ' PowerPDF license activation problem after reinstall'
);

System.debug('=== CANDIDATE SEARCH ===');
System.debug('Result length: ' + (candidates == null ? 0 : candidates.length()));
System.debug('Contains seed Id: ' + (candidates != null && candidates.contains(String.valueOf(seedArticle.Id))));
System.assertNotEquals(
    KbCandidateSearchService.NONE_MARKER,
    candidates,
    'FAIL: SOSL/SOQL should find the seeded article'
);
System.assert(
    candidates.contains(String.valueOf(seedArticle.Id)),
    'FAIL: Serialized candidates must include seed article Id'
);

// --- Test 2: UPDATE path via KbArticleBuilderAction ---
Case updateCase = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = marker + ' PowerPDF license activation problem after reinstall'
);
insert updateCase;

KbPromptContextService.saveCandidates(updateCase.Id, candidates);

String mergedAnswer =
    'Ensure the license key matches your product edition. Re-enter the key under Help > License Manager. ' +
    'If activation still fails, uninstall any previous version before reinstalling.';

String updateResponse =
    'Action: UPDATE\n' +
    'ArticleId: ' + seedArticle.Id + '\n' +
    'Question: "' + updateCase.Subject + '"\n' +
    'Answer: "' + mergedAnswer + '"';

ccai__AI_Response__c aiResponse = new ccai__AI_Response__c(
    ccai__AI_Processed_Data_PII_Added__c = updateResponse,
    ccai__Record_Id__c                   = String.valueOf(updateCase.Id)
);

new KbArticleBuilderAction().invokeApex(aiResponse);

Knowledge__kav afterUpdate = [
    SELECT Id, Resolution__c, PublishStatus
    FROM Knowledge__kav
    WHERE Id = :seedArticle.Id
];

System.debug('=== UPDATE PATH RESULT ===');
System.debug('Resolution__c: ' + afterUpdate.Resolution__c);
System.assert(
    afterUpdate.Resolution__c.contains('uninstall any previous version'),
    'FAIL: UPDATE path should merge new answer into existing draft'
);

Integer seedArticleCount = [
    SELECT COUNT()
    FROM Knowledge__kav
    WHERE Title LIKE :(marker + '%')
];
System.debug('Articles with marker in title: ' + seedArticleCount);

// --- Test 3: CREATE path for unrelated topic ---
Case createCase = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = marker + ' TotalAgility workflow timeout on large documents'
);
insert createCase;

String createResponse =
    'Action: CREATE\n' +
    'ArticleId:\n' +
    'Question: "' + createCase.Subject + '"\n' +
    'Answer: "Increase the workflow timeout setting in TotalAgility Administration Console under Process Settings."';

ccai__AI_Response__c createAiResponse = new ccai__AI_Response__c(
    ccai__AI_Processed_Data_PII_Added__c = createResponse,
    ccai__Record_Id__c                   = String.valueOf(createCase.Id)
);

new KbArticleBuilderAction().invokeApex(createAiResponse);

List<CaseArticle> createLinks = [
    SELECT KnowledgeArticleId
    FROM CaseArticle
    WHERE CaseId = :createCase.Id
];

System.debug('=== CREATE PATH RESULT ===');
System.debug('CaseArticle links: ' + createLinks.size());
System.assertEquals(1, createLinks.size(), 'FAIL: CREATE path should link one new article');

Case clearedCase = [SELECT KB_Candidates__c FROM Case WHERE Id = :updateCase.Id];
System.assertEquals(null, clearedCase.KB_Candidates__c,
    'FAIL: KB_Candidates__c should be cleared after prompt action');

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Seed article URL: /lightning/r/Knowledge__kav/' + seedArticle.Id + '/view');
System.debug('Update case URL: /lightning/r/Case/' + updateCase.Id + '/view');
System.debug('Create case URL: /lightning/r/Case/' + createCase.Id + '/view');
