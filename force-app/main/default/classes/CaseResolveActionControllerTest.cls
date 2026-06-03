/**
 * Unit tests for CaseResolveActionController.
 *
 * Exercises the saveResolution(Id, String) entry point under the four
 * original branches (happy path, null Id guard, blank text guard, DML
 * failure path) plus three new branches that cover the Knowledge
 * article side-effect: create, update-in-place, and the case-closes-
 * even-when-KB-fails isolation guarantee.
 */
@IsTest
private class CaseResolveActionControllerTest {

    @IsTest
    static void saveResolution_closesCaseAndCopiesText() {
        Case c = new Case(
            Origin  = 'Web',
            Status  = 'New',
            Subject = 'Test case to resolve'
        );
        insert c;

        String solution = 'Restart the service and clear the cache.';

        Test.startTest();
        CaseResolveActionController.saveResolution(c.Id, solution);
        Test.stopTest();

        Case after = [SELECT Status, Resolution__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Closed', after.Status,
            'saveResolution must flip Status to Closed');
        System.assertEquals(solution, after.Resolution__c,
            'saveResolution must copy the supplied text into Resolution__c verbatim');
    }

    @IsTest
    static void saveResolution_overwritesExistingResolution() {
        Case c = new Case(
            Origin        = 'Web',
            Status        = 'Working',
            Subject       = 'Has prior resolution',
            Resolution__c = 'Old text'
        );
        insert c;

        Test.startTest();
        CaseResolveActionController.saveResolution(c.Id, 'New text');
        Test.stopTest();

        Case after = [SELECT Status, Resolution__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Closed', after.Status);
        System.assertEquals('New text', after.Resolution__c,
            'Agent-supplied resolution must overwrite any prior value');
    }

    @IsTest
    static void saveResolution_throwsForNullCaseId() {
        Boolean threw = false;
        try {
            Test.startTest();
            CaseResolveActionController.saveResolution(null, 'Some text');
            Test.stopTest();
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'saveResolution(null, ...) must throw AuraHandledException');
    }

    @IsTest
    static void saveResolution_throwsForBlankResolution() {
        Case c = new Case(Origin = 'Web', Status = 'New', Subject = 'Test');
        insert c;

        Boolean threwForNull = false;
        try {
            CaseResolveActionController.saveResolution(c.Id, null);
        } catch (AuraHandledException e) {
            threwForNull = true;
        }
        System.assert(threwForNull, 'Null resolution must throw');

        Boolean threwForEmpty = false;
        try {
            CaseResolveActionController.saveResolution(c.Id, '   ');
        } catch (AuraHandledException e) {
            threwForEmpty = true;
        }
        System.assert(threwForEmpty, 'Whitespace-only resolution must throw');
    }

    @IsTest
    static void saveResolution_wrapsDmlFailure() {
        Case c = new Case(Origin = 'Web', Status = 'New', Subject = 'To be deleted');
        insert c;
        Id deletedId = c.Id;
        delete c;
        Database.emptyRecycleBin(new List<Id>{ deletedId });

        Boolean threw = false;
        try {
            Test.startTest();
            CaseResolveActionController.saveResolution(deletedId, 'solution');
            Test.stopTest();
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw,
            'Updating a hard-deleted Case must surface as AuraHandledException');
    }

    @IsTest
    static void saveResolution_createsDraftArticleAndLink() {
        Case c = new Case(
            Origin  = 'Web',
            Status  = 'New',
            Subject = 'Printer keeps jamming on tray 2'
        );
        insert c;

        String solution = 'Open tray 2, remove residue, reseat cartridge.';

        Test.startTest();
        CaseResolveActionController.SaveResult result =
            CaseResolveActionController.saveResolution(c.Id, solution);
        Test.stopTest();

        System.assertEquals(true, result.caseClosed, 'caseClosed flag must be set');
        System.assertEquals(true, result.articleCreated, 'A new article should have been created');
        System.assertNotEquals(null, result.articleId, 'articleId must be returned on create');
        System.assertEquals(null, result.articleWarning,
            'Happy path should not surface an article warning');

        Knowledge__kav kav = [
            SELECT Id, Title, Resolution__c, PublishStatus, KnowledgeArticleId
            FROM Knowledge__kav
            WHERE Id = :result.articleId
        ];
        System.assertEquals('Printer keeps jamming on tray 2', kav.Title,
            'Article Title must mirror Case.Subject');
        System.assertEquals(solution, kav.Resolution__c,
            'Article Resolution__c must mirror typed text');
        System.assertEquals('Draft', kav.PublishStatus,
            'New article must be in Draft status');

        Integer linkCount = [
            SELECT COUNT()
            FROM CaseArticle
            WHERE CaseId = :c.Id
              AND KnowledgeArticleId = :kav.KnowledgeArticleId
        ];
        System.assertEquals(1, linkCount,
            'A CaseArticle row must link the case to the new draft article');
    }

    @IsTest
    static void saveResolution_updatesExistingDraftArticle() {
        Case c = new Case(
            Origin  = 'Web',
            Status  = 'New',
            Subject = 'VPN drops every 30 minutes'
        );
        insert c;

        Test.startTest();
        CaseResolveActionController.SaveResult first =
            CaseResolveActionController.saveResolution(c.Id, 'Initial draft answer.');

        c.Status = 'Working';
        update c;

        CaseResolveActionController.SaveResult second =
            CaseResolveActionController.saveResolution(c.Id, 'Refined final answer.');
        Test.stopTest();

        System.assertEquals(true, first.articleCreated, 'First call should create');
        System.assertEquals(false, second.articleCreated, 'Second call should update, not create');
        System.assertEquals(first.articleId, second.articleId,
            'Second call must reuse the same Knowledge__kav, not insert a duplicate');

        Knowledge__kav kav = [
            SELECT Id, Title, Resolution__c, PublishStatus, KnowledgeArticleId
            FROM Knowledge__kav
            WHERE Id = :second.articleId
        ];
        System.assertEquals('VPN drops every 30 minutes', kav.Title);
        System.assertEquals('Refined final answer.', kav.Resolution__c,
            'Resolution__c must reflect the latest typed text');

        Integer linkCount = [
            SELECT COUNT()
            FROM CaseArticle
            WHERE CaseId = :c.Id
              AND KnowledgeArticleId = :kav.KnowledgeArticleId
        ];
        System.assertEquals(1, linkCount,
            'Dedupe must not create a second CaseArticle link');
    }

    @IsTest
    static void saveResolution_caseClosesEvenWhenArticleFails() {
        Case c = new Case(
            Origin  = 'Web',
            Status  = 'New',
            Subject = 'Force KB failure path'
        );
        insert c;

        CaseResolveActionController.forceArticleFailureForTest = true;

        Test.startTest();
        CaseResolveActionController.SaveResult result =
            CaseResolveActionController.saveResolution(c.Id, 'Should still close the case.');
        Test.stopTest();

        CaseResolveActionController.forceArticleFailureForTest = false;

        Case after = [SELECT Status, Resolution__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Closed', after.Status,
            'Case must still be closed when KB step fails');
        System.assertEquals('Should still close the case.', after.Resolution__c,
            'Case.Resolution__c must still be saved when KB step fails');

        System.assertEquals(true, result.caseClosed, 'caseClosed must remain true');
        System.assertEquals(null, result.articleId,
            'No articleId should be returned when KB step fails');
        System.assertNotEquals(null, result.articleWarning,
            'articleWarning must surface the KB failure to the LWC');
        System.assert(
            result.articleWarning.contains('Case closed'),
            'Warning must reassure that the case did close: ' + result.articleWarning
        );
    }
}
