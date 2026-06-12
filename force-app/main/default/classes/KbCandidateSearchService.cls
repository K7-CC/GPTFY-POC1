/**
 * Finds existing Knowledge articles that may match a Case subject via SOSL,
 * then serializes them for the KB Creation Prompt ({!Case.KB_Candidates__c}).
 */
public without sharing class KbCandidateSearchService {

    public static final String NONE_MARKER = 'NONE';
    private static final Integer MAX_CANDIDATES = 5;
    private static final Integer MAX_TITLE_CHARS = 500;
    private static final Integer MAX_ANSWER_CHARS = 8000;

    private static final Set<String> STOP_WORDS = new Set<String>{
        // Articles, pronouns, prepositions, conjunctions
        'how', 'do', 'does', 'did', 'i', 'my', 'me', 'the', 'a', 'an', 'is', 'are',
        'was', 'were', 'can', 'could', 'would', 'should', 'what', 'when', 'where',
        'why', 'who', 'to', 'in', 'on', 'at', 'for', 'of', 'and', 'or', 'not',
        'with', 'this', 'that', 'it', 'be', 'from', 'get', 'has', 'have', 'had',
        'will', 'we', 'you', 'your', 'our', 'their', 'there', 'about', 'into',
        // Vague support / problem wording (poor SOSL signals)
        'issue', 'issues', 'facing', 'support', 'help', 'problem', 'problems',
        'error', 'errors', 'fix', 'fixed', 'need', 'needs', 'please', 'unable',
        'trouble', 'wrong', 'broken', 'failing', 'failed', 'resolve', 'resolving',
        'assist', 'assistance', 'request', 'question', 'query', 'concern',
        'regarding', 'related', 'contact', 'call', 'email', 'urgent', 'thanks',
        'tell', 'explain', 'know', 'want', 'give', 'show', 'check', 'try', 'tried',
        'still', 'just', 'also', 'even', 'really', 'actually', 'maybe', 'any',
        'some', 'anyone', 'someone', 'anything', 'something', 'nothing'
    };

    /**
     * Runs SOSL (with SOQL title fallback) and returns a prompt-ready string.
     * Returns {@link #NONE_MARKER} when no candidates are found.
     */
    public static String searchAndSerialize(String caseSubject) {
        if (String.isBlank(caseSubject)) {
            return NONE_MARKER;
        }

        List<Knowledge__kav> candidates = findCandidates(caseSubject);
        if (candidates.isEmpty()) {
            return NONE_MARKER;
        }

        return serializeCandidates(candidates);
    }

    @TestVisible
    static List<Knowledge__kav> findCandidates(String caseSubject) {
        String searchTerms = buildSearchTerms(caseSubject);
        List<Knowledge__kav> fromSosl = String.isBlank(searchTerms)
            ? new List<Knowledge__kav>()
            : searchViaSosl(searchTerms);

        if (!fromSosl.isEmpty()) {
            return fromSosl;
        }

        return searchViaSoqlFallback(caseSubject);
    }

    @TestVisible
    static String buildSearchTerms(String subject) {
        String normalized = subject.toLowerCase()
            .replaceAll('[^a-z0-9\\s]', ' ')
            .replaceAll('\\s+', ' ')
            .trim();

        if (String.isBlank(normalized)) {
            return null;
        }

        List<String> terms = new List<String>();
        for (String word : normalized.split('\\s+')) {
            if (word.length() < 3 || STOP_WORDS.contains(word)) {
                continue;
            }
            if (!terms.contains(word)) {
                terms.add(escapeSoslTerm(word));
            }
            if (terms.size() >= 5) {
                break;
            }
        }

        return terms.isEmpty() ? null : String.join(terms, ' OR ');
    }

    private static List<Knowledge__kav> searchViaSosl(String searchTerms) {
        try {
            List<List<SObject>> results = [
                FIND :searchTerms
                IN ALL FIELDS
                RETURNING Knowledge__kav(
                    Id, Title, Resolution__c, PublishStatus, KnowledgeArticleId
                    LIMIT 10
                )
            ];

            if (results.isEmpty() || results[0].isEmpty()) {
                return new List<Knowledge__kav>();
            }

            List<Knowledge__kav> filtered = new List<Knowledge__kav>();
            for (Knowledge__kav kav : (List<Knowledge__kav>) results[0]) {
                if (kav.PublishStatus == 'Draft' || kav.PublishStatus == 'Online') {
                    filtered.add(kav);
                }
                if (filtered.size() >= MAX_CANDIDATES) {
                    break;
                }
            }
            return filtered;
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN,
                'KbCandidateSearchService: SOSL failed — ' + e.getMessage());
            return new List<Knowledge__kav>();
        }
    }

    private static List<Knowledge__kav> searchViaSoqlFallback(String caseSubject) {
        String keyword = extractPrimaryKeyword(caseSubject);
        if (String.isBlank(keyword)) {
            return new List<Knowledge__kav>();
        }

        String likePattern = '%' + keyword + '%';
        return [
            SELECT Id, Title, Resolution__c, PublishStatus, KnowledgeArticleId
            FROM Knowledge__kav
            WHERE PublishStatus IN ('Draft', 'Online')
              AND Title LIKE :likePattern
            ORDER BY LastModifiedDate DESC
            LIMIT :MAX_CANDIDATES
        ];
    }

    @TestVisible
    static String extractPrimaryKeyword(String subject) {
        String normalized = subject.toLowerCase()
            .replaceAll('[^a-z0-9\\s]', ' ')
            .replaceAll('\\s+', ' ')
            .trim();

        for (String word : normalized.split('\\s+')) {
            if (word.length() >= 4 && !STOP_WORDS.contains(word)) {
                return word;
            }
        }
        return null;
    }

    @TestVisible
    static String serializeCandidates(List<Knowledge__kav> candidates) {
        List<String> blocks = new List<String>();
        Integer idx = 1;

        for (Knowledge__kav kav : candidates) {
            blocks.add(
                'CANDIDATE_' + idx + '\n' +
                'Id: ' + kav.Id + '\n' +
                'Title: ' + truncate(kav.Title, MAX_TITLE_CHARS) + '\n' +
                'Answer: ' + truncate(stripHtml(kav.Resolution__c), MAX_ANSWER_CHARS)
            );
            idx++;
        }

        return String.join(blocks, '\n\n');
    }

    private static String stripHtml(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        return value.replaceAll('<[^>]+>', ' ')
            .replaceAll('&nbsp;', ' ')
            .replaceAll('\\s+', ' ')
            .trim();
    }

    private static String truncate(String value, Integer maxLen) {
        if (String.isBlank(value)) {
            return '';
        }
        return value.length() <= maxLen ? value : value.substring(0, maxLen) + '...';
    }

    private static String escapeSoslTerm(String term) {
        return term.replaceAll('([?&|!{}\\[\\]()^~*:\\\\"\'+-])', '\\\\$1');
    }
}
