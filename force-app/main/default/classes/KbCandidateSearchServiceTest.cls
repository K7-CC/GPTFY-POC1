/**
 * Unit tests for KbCandidateSearchService.
 */
@IsTest
private class KbCandidateSearchServiceTest {

    @IsTest
    static void buildSearchTerms_filtersStopWordsAndJoinsWithOr() {
        String terms = KbCandidateSearchService.buildSearchTerms(
            'How do I reset my PowerPDF license key?');

        System.assertNotEquals(null, terms, 'Should produce search terms');
        System.assert(terms.contains('powerpdf'), 'Should include significant keyword');
        System.assert(terms.contains('license'), 'Should include significant keyword');
        System.assert(!terms.contains(' OR how '), 'Should exclude stop word "how"');
    }

    @IsTest
    static void buildSearchTerms_excludesVagueSupportWords() {
        String terms = KbCandidateSearchService.buildSearchTerms(
            'i am facing issue with License Activation Server and Software Download Disruption.. need you support to fix this');

        System.assertNotEquals(null, terms, 'Should produce search terms');
        System.assert(terms.contains('license'), 'Should include topic keyword');
        System.assert(terms.contains('activation'), 'Should include topic keyword');
        System.assert(!terms.contains('issue'), 'Should exclude vague word "issue"');
        System.assert(!terms.contains('facing'), 'Should exclude vague word "facing"');
        System.assert(!terms.contains('support'), 'Should exclude vague word "support"');
    }

    @IsTest
    static void extractPrimaryKeyword_skipsVagueSupportWords() {
        System.assertEquals(
            'license',
            KbCandidateSearchService.extractPrimaryKeyword(
                'i am facing issue with License Activation Server disruption')
        );
    }

    @IsTest
    static void buildSearchTerms_returnsNullForBlankSubject() {
        System.assertEquals(null, KbCandidateSearchService.buildSearchTerms(''));
        System.assertEquals(null, KbCandidateSearchService.buildSearchTerms('   '));
    }

    @IsTest
    static void extractPrimaryKeyword_picksFirstMeaningfulWord() {
        System.assertEquals(
            'powerpdf',
            KbCandidateSearchService.extractPrimaryKeyword('How do I fix PowerPDF activation?')
        );
    }

    @IsTest
    static void serializeCandidates_formatsBlocksWithIdTitleAnswer() {
        Knowledge__kav kav = new Knowledge__kav(
            Title         = 'PowerPDF license reset',
            UrlName       = 'powerpdf-license-reset-test',
            Language      = 'en_US',
            Resolution__c = 'Navigate to Help > License Manager.'
        );
        insert kav;

        kav = [
            SELECT Id, Title, Resolution__c, PublishStatus, KnowledgeArticleId
            FROM Knowledge__kav
            WHERE Id = :kav.Id
        ];

        String serialized = KbCandidateSearchService.serializeCandidates(
            new List<Knowledge__kav>{ kav });

        System.assert(serialized.contains('CANDIDATE_1'), 'Should include candidate header');
        System.assert(serialized.contains('Id: ' + kav.Id), 'Should include article Id');
        System.assert(serialized.contains('Title: PowerPDF license reset'), 'Should include title');
        System.assert(serialized.contains('License Manager'), 'Should include answer text');
    }

    @IsTest
    static void searchAndSerialize_returnsNoneWhenNoCandidates() {
        String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');
        String result = KbCandidateSearchService.searchAndSerialize(
            marker + ' xyzzyplughnonexistenttopic999');

        System.assertEquals(
            KbCandidateSearchService.NONE_MARKER,
            result,
            'Unlikely subject should return NONE'
        );
    }

    @IsTest
    static void searchAndSerialize_findsExistingArticleViaSoqlFallback() {
        String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');
        String uniqueTitle = marker + ' PowerPDF scanner calibration guide';

        insert new Knowledge__kav(
            Title         = uniqueTitle,
            UrlName       = 'cursor-scanner-cal-' + Datetime.now().getTime(),
            Language      = 'en_US',
            Resolution__c = 'Recalibrate the scanner using Settings > Devices.'
        );

        String result = KbCandidateSearchService.searchAndSerialize(
            marker + ' PowerPDF scanner calibration issue');

        System.assertNotEquals(
            KbCandidateSearchService.NONE_MARKER,
            result,
            'Should find the seeded article via SOSL or SOQL fallback');
        System.assert(result.contains('scanner calibration'), 'Serialized text should include title');
    }
}
