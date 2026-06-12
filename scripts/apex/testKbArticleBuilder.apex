String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// 1. Simulate a Case
Case c = new Case(
    Subject     = marker + ' KB builder parser test',
    Status      = 'New',
    Origin      = 'Web'
);
insert c;
System.debug('Case Id: ' + c.Id);

// 2. Build a mock AI response in the NEW prompt format
String mockResponse =
    'Question: "' + marker + ' — how do I reset my password?"\n' +
    'Answer: "To reset your password, navigate to the login page and click Forgot Password. Enter your registered email address and follow the instructions sent to your inbox."';

// 3. Simulate what GPTfy passes to invokeApex
ccai__AI_Response__c resp = new ccai__AI_Response__c(
    ccai__AI_Processed_Data_PII_Added__c = mockResponse,
    ccai__Record_Id__c                   = c.Id
);

// 4. Invoke the action
KbArticleBuilderAction action = new KbArticleBuilderAction();
action.invokeApex(resp);

// 5. Verify KB article was created
List<Knowledge__kav> articles = [
    SELECT Id, Title, Resolution__c, KnowledgeArticleId
    FROM Knowledge__kav
    WHERE Title LIKE :('%' + marker + '%')
];

System.debug('Articles created: ' + articles.size());
for (Knowledge__kav kav : articles) {
    System.debug('  Title: ' + kav.Title);
    System.debug('  Resolution: ' + kav.Resolution__c);
    System.debug('  KnowledgeArticleId: ' + kav.KnowledgeArticleId);
}

// 6. Verify CaseArticle link
List<CaseArticle> links = [
    SELECT Id, CaseId, KnowledgeArticleId
    FROM CaseArticle
    WHERE CaseId = :c.Id
];
System.debug('CaseArticle links: ' + links.size());

System.assert(articles.size() == 1, 'Expected 1 KB article, got: ' + articles.size());
System.assert(links.size() == 1,    'Expected 1 CaseArticle link, got: ' + links.size());

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Case URL: /lightning/r/Case/' + c.Id + '/view');
System.debug('Article URL: /lightning/r/Knowledge__kav/' + articles[0].Id + '/view');
