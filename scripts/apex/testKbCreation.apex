/**
 * End-to-end verification: KB article creation via KbArticleBuilderAction.
 *
 * Simulates a GPTfy AI Response using ccai__AI_Processed_Data_PII_Added__c
 * (the field GPTfy actually populates) and verifies 6 draft Knowledge articles
 * are created and linked to the Case.
 *
 * Records tagged 'cursor-test-...' for easy cleanup.
 */
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// ── 1. Create a test Case ──────────────────────────────────────────────────────
Case testCase = new Case(
    Origin        = 'Phone',
    Status        = 'New',
    Subject       = marker + ' How do I reset my E-Invoicing password?',
    Resolution__c = 'Navigate to the login page and click Forgot Password to reset.'
);
insert testCase;
System.debug('=== CASE CREATED: ' + testCase.Id + ' ===');

// ── 2. Build a simulated GPTfy AI Response ────────────────────────────────────
//    GPTfy writes the LLM text to ccai__AI_Processed_Data_PII_Added__c
String simulatedResponseText =
    'Portal Question: "How do I reset my E-Invoicing password?"\n' +
    'OG Answer: "To reset your E-Invoicing password, navigate to the login page and click Forgot Password."\n\n' +
    'Other possible Questions & Answers\n\n' +
    'Question 1: "What steps do I follow to recover my E-Invoicing account access?"\n' +
    'Answer 1: "Navigate to the login page and select Forgot Password to recover access."\n\n' +
    'Question 2: "How can I regain access if I forgot my E-Invoicing password?"\n' +
    'Answer 2: "Use the Forgot Password option on the login page."\n\n' +
    'Question 3: "Is there a self-service option to reset my password in E-Invoicing?"\n' +
    'Answer 3: "Yes. Go to the login page and click Forgot Password."\n\n' +
    'Question 4: "My E-Invoicing password is not working, what should I do?"\n' +
    'Answer 4: "Use the Forgot Password link on the login page to reset your password."\n\n' +
    'Question 5: "How do I change my E-Invoicing login credentials?"\n' +
    'Answer 5: "Click Forgot Password on the login page to initiate a password reset."';

ccai__AI_Response__c fakeResponse = new ccai__AI_Response__c(
    ccai__AI_Processed_Data_PII_Added__c = simulatedResponseText,
    ccai__Record_Id__c                   = String.valueOf(testCase.Id)
);

// ── 3. Call KbArticleBuilderAction directly ───────────────────────────────────
KbArticleBuilderAction kbAction = new KbArticleBuilderAction();
kbAction.invokeApex(fakeResponse);

System.debug('=== KbArticleBuilderAction.invokeApex() completed ===');

// ── 4. Verify 6 Knowledge articles were created and linked ─────────────────────
List<CaseArticle> links = [
    SELECT KnowledgeArticleId
    FROM CaseArticle
    WHERE CaseId = :testCase.Id
];
System.debug('CaseArticle links created: ' + links.size() + ' (expected: 6)');

if (!links.isEmpty()) {
    Set<Id> parentIds = new Set<Id>();
    for (CaseArticle ca : links) {
        parentIds.add(ca.KnowledgeArticleId);
    }

    List<Knowledge__kav> articles = [
        SELECT Id, Title, Resolution__c, PublishStatus, UrlName
        FROM Knowledge__kav
        WHERE KnowledgeArticleId IN :parentIds
    ];
    System.debug('Knowledge__kav articles created: ' + articles.size());
    for (Knowledge__kav kav : articles) {
        System.debug('  → [' + kav.PublishStatus + '] ' + kav.Title);
    }
}

// ── 5. Verify CaseResolveActionController enqueues the job ────────────────────
Case resolveCase = new Case(
    Origin  = 'Phone',
    Status  = 'New',
    Subject = marker + ' (resolve action test)'
);
insert resolveCase;

CaseResolveActionController.SaveResult result =
    CaseResolveActionController.saveResolution(resolveCase.Id, 'Test resolution.', true);

System.debug('=== saveResolution result ===');
System.debug('caseClosed:    ' + result.caseClosed);
System.debug('articleQueued: ' + result.articleQueued);
System.debug('articleWarning: ' + result.articleWarning);

Case afterResolve = [SELECT Status, Resolution__c FROM Case WHERE Id = :resolveCase.Id];
System.debug('Case Status: ' + afterResolve.Status + ' (expected: Closed)');

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Test Case Id: ' + testCase.Id);
System.debug('Resolve Case Id: ' + resolveCase.Id);
