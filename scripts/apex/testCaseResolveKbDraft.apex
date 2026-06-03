// End-to-end test: agent Resolve -> draft Knowledge article
// Records tagged with "cursor" for easy identification.

String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// --- Test 1: Create case and resolve (should create draft article) ---
Case testCase = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = marker + ' Printer jam on tray 2'
);
insert testCase;
System.debug('=== CURSOR TEST CASE ID: ' + testCase.Id + ' ===');

String resolution1 = 'Cursor test resolution: open tray 2, remove paper debris, reseat cartridge.';

CaseResolveActionController.SaveResult result1 =
    CaseResolveActionController.saveResolution(testCase.Id, resolution1);

System.debug('=== RESULT 1 ===');
System.debug('caseClosed: ' + result1.caseClosed);
System.debug('articleCreated: ' + result1.articleCreated);
System.debug('articleId: ' + result1.articleId);
System.debug('articleWarning: ' + result1.articleWarning);

Case afterClose = [
    SELECT Id, CaseNumber, Status, Subject, Resolution__c
    FROM Case WHERE Id = :testCase.Id
];
System.debug('=== CASE AFTER CLOSE ===');
System.debug('Status: ' + afterClose.Status);
System.debug('Resolution__c: ' + afterClose.Resolution__c);

if (result1.articleId != null) {
    Knowledge__kav kav1 = [
        SELECT Id, Title, Resolution__c, PublishStatus, UrlName, KnowledgeArticleId
        FROM Knowledge__kav WHERE Id = :result1.articleId
    ];
    System.debug('=== KNOWLEDGE ARTICLE (CREATE) ===');
    System.debug('Title: ' + kav1.Title);
    System.debug('Resolution__c: ' + kav1.Resolution__c);
    System.debug('PublishStatus: ' + kav1.PublishStatus);
    System.debug('UrlName: ' + kav1.UrlName);

    Integer linkCount1 = [
        SELECT COUNT() FROM CaseArticle
        WHERE CaseId = :testCase.Id AND KnowledgeArticleId = :kav1.KnowledgeArticleId
    ];
    System.debug('CaseArticle link count: ' + linkCount1);
}

// --- Test 2: Re-open and resolve again (should update same draft, not duplicate) ---
afterClose.Status = 'Working';
update afterClose;

String resolution2 = 'Cursor test UPDATED resolution: replace tray 2 roller assembly.';

CaseResolveActionController.SaveResult result2 =
    CaseResolveActionController.saveResolution(testCase.Id, resolution2);

System.debug('=== RESULT 2 (DEDUPE) ===');
System.debug('caseClosed: ' + result2.caseClosed);
System.debug('articleCreated: ' + result2.articleCreated);
System.debug('articleId: ' + result2.articleId);
System.debug('same article as result1: ' + (result1.articleId == result2.articleId));

if (result2.articleId != null) {
    Knowledge__kav kav2 = [
        SELECT Id, Title, Resolution__c, PublishStatus
        FROM Knowledge__kav WHERE Id = :result2.articleId
    ];
    System.debug('=== KNOWLEDGE ARTICLE (UPDATE) ===');
    System.debug('Title: ' + kav2.Title);
    System.debug('Resolution__c: ' + kav2.Resolution__c);
    System.debug('PublishStatus: ' + kav2.PublishStatus);

    Integer totalLinks = [SELECT COUNT() FROM CaseArticle WHERE CaseId = :testCase.Id];
    System.debug('Total CaseArticle links for case: ' + totalLinks);
}

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Look for Case Subject containing: ' + marker);
System.debug('Case Id: ' + testCase.Id);
