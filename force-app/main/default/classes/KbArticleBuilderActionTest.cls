/**
 * Unit tests for KbArticleBuilderAction.
 *
 * Tests the parser and article creation logic via the ccai.AIPromptActionInterface
 * entry point (invokeApex). No callouts needed — the class only receives a
 * ccai__AI_Response__c record and performs DML.
 */
@IsTest
private class KbArticleBuilderActionTest {

    // ─── Sample response matching the KB Creation Prompt format ────────────────

    private static final String SAMPLE_RESPONSE =
        'Portal Question: "How do I reset my E-Invoicing password?"\n' +
        'OG Answer: "To reset your E-Invoicing password, navigate to the login page and click Forgot Password."\n' +
        '\n' +
        'Other possible Questions & Answers\n' +
        '\n' +
        'Question 1: "What steps do I follow to recover my E-Invoicing account access?"\n' +
        'Answer 1: "To recover access, navigate to the login page and select Forgot Password."\n' +
        '\n' +
        'Question 2: "How can I regain access if I forgot my E-Invoicing password?"\n' +
        'Answer 2: "Navigate to the login page and use the Forgot Password option."\n' +
        '\n' +
        'Question 3: "Is there a self-service option to reset my password in E-Invoicing?"\n' +
        'Answer 3: "Yes. Go to the login page and click Forgot Password."\n' +
        '\n' +
        'Question 4: "My E-Invoicing password is not working, what should I do?"\n' +
        'Answer 4: "Use the Forgot Password link on the login page to reset your password."\n' +
        '\n' +
        'Question 5: "How do I change my E-Invoicing login credentials?"\n' +
        'Answer 5: "Click Forgot Password on the login page to initiate a password reset."';

    // ─── Parser tests ──────────────────────────────────────────────────────────

    @IsTest
    static void parseResponse_extractsSixPairs() {
        List<KbArticleBuilderAction.QAPair> pairs =
            KbArticleBuilderAction.parseResponse(SAMPLE_RESPONSE);

        System.assertEquals(6, pairs.size(),
            'Parser must extract exactly 6 Q&A pairs (1 original + 5 variations)');
    }

    @IsTest
    static void parseResponse_originalPairIsFirst() {
        List<KbArticleBuilderAction.QAPair> pairs =
            KbArticleBuilderAction.parseResponse(SAMPLE_RESPONSE);

        System.assertEquals(
            'How do I reset my E-Invoicing password?',
            pairs[0].question,
            'First pair must be the Portal Question');
        System.assert(
            pairs[0].answer.contains('Forgot Password'),
            'First pair answer must be the OG Answer');
    }

    @IsTest
    static void parseResponse_variationsAreParsed() {
        List<KbArticleBuilderAction.QAPair> pairs =
            KbArticleBuilderAction.parseResponse(SAMPLE_RESPONSE);

        System.assertEquals(
            'What steps do I follow to recover my E-Invoicing account access?',
            pairs[1].question,
            'Pair 1 question must match Question 1');
        System.assertEquals(
            'Click Forgot Password on the login page to initiate a password reset.',
            pairs[5].answer,
            'Pair 5 answer must match Answer 5');
    }

    @IsTest
    static void parseResponse_returnsEmptyForBlankInput() {
        List<KbArticleBuilderAction.QAPair> pairs =
            KbArticleBuilderAction.parseResponse('');
        System.assertEquals(0, pairs.size(),
            'Blank input must return an empty list');
    }

    @IsTest
    static void parseResponse_returnsEmptyForUnrecognisedFormat() {
        List<KbArticleBuilderAction.QAPair> pairs =
            KbArticleBuilderAction.parseResponse('This is just some free text with no structure.');
        System.assertEquals(0, pairs.size(),
            'Unstructured text must return an empty list');
    }

    // ─── invokeApex tests ──────────────────────────────────────────────────────

    /**
     * Primary path: GPTfy stores the LLM text in ccai__AI_Processed_Data_PII_Added__c
     * (ccai__Message__c is left null by the current GPTfy build).
     */
    @IsTest
    static void invokeApex_insertsSixArticles_viaProcessedDataField() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'KB article builder test — primary field path'
        );
        insert c;

        ccai__AI_Response__c response = new ccai__AI_Response__c(
            ccai__AI_Processed_Data_PII_Added__c = SAMPLE_RESPONSE,
            ccai__Record_Id__c                   = String.valueOf(c.Id)
        );

        KbArticleBuilderAction action = new KbArticleBuilderAction();

        Test.startTest();
        action.invokeApex(response);
        Test.stopTest();

        List<CaseArticle> links = [
            SELECT KnowledgeArticleId
            FROM CaseArticle
            WHERE CaseId = :c.Id
        ];
        System.assertEquals(6, links.size(),
            'Six CaseArticle links must be created via ccai__AI_Processed_Data_PII_Added__c');
    }

    /**
     * Fallback path: if ccai__AI_Processed_Data_PII_Added__c is blank,
     * the code reads ccai__Message__c for forward compatibility.
     */
    @IsTest
    static void invokeApex_insertsSixArticles_viaMessageFieldFallback() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'KB article builder test — message field fallback'
        );
        insert c;

        ccai__AI_Response__c response = new ccai__AI_Response__c(
            ccai__Message__c   = SAMPLE_RESPONSE,
            ccai__Record_Id__c = String.valueOf(c.Id)
        );

        KbArticleBuilderAction action = new KbArticleBuilderAction();

        Test.startTest();
        action.invokeApex(response);
        Test.stopTest();

        List<CaseArticle> links = [
            SELECT KnowledgeArticleId
            FROM CaseArticle
            WHERE CaseId = :c.Id
        ];
        System.assertEquals(6, links.size(),
            'Six CaseArticle links must be created via ccai__Message__c fallback');
    }

    /**
     * GPTfy wraps error responses in {"error":{"message":"..."}} JSON.
     * The handler must detect this and skip article creation without throwing.
     */
    @IsTest
    static void invokeApex_skipsOnGPTfyErrorJson() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'KB builder test — GPTfy error JSON'
        );
        insert c;

        String errorJson =
            '{"error" : {"message" : "An error occured, please contact your System Admin."}}';

        ccai__AI_Response__c response = new ccai__AI_Response__c(
            ccai__AI_Processed_Data_PII_Added__c = errorJson,
            ccai__Message__c                     = 'An error occured, please contact your System Admin.',
            ccai__Record_Id__c                   = String.valueOf(c.Id)
        );

        KbArticleBuilderAction action = new KbArticleBuilderAction();

        Test.startTest();
        action.invokeApex(response);
        Test.stopTest();

        Integer articleCount = [
            SELECT COUNT() FROM CaseArticle WHERE CaseId = :c.Id
        ];
        System.assertEquals(0, articleCount,
            'No articles should be created when GPTfy returns an error JSON envelope');
    }

    @IsTest
    static void invokeApex_skipsOnBlankResponse() {
        Case c = new Case(
            Origin  = 'Phone',
            Status  = 'New',
            Subject = 'Blank response test'
        );
        insert c;

        ccai__AI_Response__c response = new ccai__AI_Response__c(
            ccai__Message__c   = '',
            ccai__Record_Id__c = String.valueOf(c.Id)
        );

        KbArticleBuilderAction action = new KbArticleBuilderAction();

        Test.startTest();
        action.invokeApex(response);
        Test.stopTest();

        Integer articleCount = [
            SELECT COUNT() FROM CaseArticle WHERE CaseId = :c.Id
        ];
        System.assertEquals(0, articleCount,
            'No articles should be created when the response is blank');
    }

    @IsTest
    static void invokeApex_handlesNullResponse() {
        KbArticleBuilderAction action = new KbArticleBuilderAction();

        Test.startTest();
        action.invokeApex(null);
        Test.stopTest();

        // Should complete without exception
        System.assert(true, 'invokeApex(null) must not throw');
    }

    @IsTest
    static void buildUrlSlug_isUrlSafe() {
        String slug = KbArticleBuilderAction.buildUrlSlug(
            'How do I reset my E-Invoicing password?', 0);
        System.assert(
            slug.startsWith('how-do-i-reset-my-e-invoicing-password-0-'),
            'Slug must be lowercase, hyphenated, and include the index: ' + slug);
        System.assert(
            !slug.contains(' ') && !slug.contains('?'),
            'Slug must not contain spaces or special characters: ' + slug);
    }
}
