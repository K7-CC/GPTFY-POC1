String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// 1. Simulate the AI answer text that would come back for a Power PDF scanner question.
//    This mirrors what the AI agent would write, which paraphrases the KB article content.
String simulatedAiAnswer =
    'After upgrading to Power PDF 2025.3, ScanSnap iX500 scanner compatibility issues ' +
    'can occur because Power PDF 2025.3 changed its scanner communication protocol. ' +
    'To resolve this, reinstall the ScanSnap iX500 drivers and configure the scanner ' +
    'in Power PDF settings under File > Scanner. ' +
    'If the issue persists, check the Power PDF release notes for known scanner compatibility fixes.';

// 2. Call getRelatedArticles with the simulated AI answer.
List<Map<String, Object>> articles = CaseResolutionController.getRelatedArticles(simulatedAiAnswer);

// 3. Assert and report results.
System.debug('=== CURSOR TEST: Golden Match Feature ===');
System.debug('Marker: ' + marker);
System.debug('Simulated AI Answer (first 100 chars): ' + simulatedAiAnswer.left(100));
System.debug('Articles returned: ' + articles.size());

for (Map<String, Object> art : articles) {
    System.debug('  ★ Golden match → Id: ' + art.get('id') + ' | Title: ' + art.get('title'));
}

if (articles.isEmpty()) {
    System.debug('WARN: No articles found — check that published KB articles exist and match the query.');
} else {
    System.debug('PASS: Golden match articles returned successfully.');
}

System.debug('=== CURSOR TEST COMPLETE ===');
