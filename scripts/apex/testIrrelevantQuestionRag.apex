String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');
String question =
    'What is the best pizza topping on Mars and who won the FIFA World Cup in 2099?';

Map<String, String> result = CaseResolutionController.createSupportCase(
    'Cursor',
    'RAG',
    'cursor-test@example.com',
    marker + ' ' + question,
    'PowerPDF'
);
Id caseId = result.get('caseId');

Integer maxWaits = 24;
String rawDescription;
for (Integer i = 0; i < maxWaits; i++) {
    Case c = [SELECT Description FROM Case WHERE Id = :caseId];
    if (String.isNotBlank(c.Description)) {
        rawDescription = c.Description;
        System.debug('Description populated after ~' + (i * 5) + 's');
        break;
    }
    Long deadline = DateTime.now().getTime() + 5000;
    while (DateTime.now().getTime() < deadline) {
        // busy-wait ~5s (anonymous apex has no sleep)
    }
}

String guestMessage;
if (String.isBlank(rawDescription)) {
    guestMessage = CaseResolutionController.TIMEOUT_MESSAGE;
    System.debug('TIMEOUT: Description still blank after ~' + (maxWaits * 5) + 's');
} else {
    guestMessage = CaseResolutionController.getRecommendation(caseId);
}

Boolean isFallback =
    guestMessage == CaseResolutionController.NO_ANSWER_MESSAGE ||
    guestMessage == CaseResolutionController.TIMEOUT_MESSAGE;
String badge = isFallback ? 'WE\'LL FOLLOW UP' : 'KNOWLEDGE ARTICLE FOUND';
String title = isFallback ? 'Next Steps' : 'Recommended Solution';

System.debug('=== IRRELEVANT QUESTION E2E RESULT ===');
System.debug('Marker: ' + marker);
System.debug('Case Id: ' + caseId);
System.debug('Case Number: ' + result.get('caseNumber'));
System.debug('Badge shown: ' + badge);
System.debug('Card title: ' + title);
System.debug('Raw RAG Description: ' + (rawDescription == null ? '(blank)' : rawDescription));
System.debug('Guest end-result message: ' + guestMessage);
System.debug('Is fallback (sanitized): ' + isFallback);
System.debug('=== CURSOR TEST COMPLETE ===');
