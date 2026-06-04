String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');
String question =
    'Does Kofax have a Whitepaper that covers Essential Eight for our organization record?';

Map<String, String> result = CaseResolutionController.createSupportCase(
    'Cursor',
    'RAG',
    'cursor-test@example.com',
    marker + ' ' + question,
    'PowerPDF'
);
Id caseId = result.get('caseId');

Integer maxWaits = 24;
String description;
for (Integer i = 0; i < maxWaits; i++) {
    Case c = [SELECT Description FROM Case WHERE Id = :caseId];
    if (String.isNotBlank(c.Description)) {
        description = c.Description;
        System.debug('Description populated after ~' + (i * 5) + 's');
        break;
    }
    // Busy-wait ~5s between checks (anonymous apex has no sleep)
    Long deadline = DateTime.now().getTime() + 5000;
    while (DateTime.now().getTime() < deadline) {
        // spin
    }
}

if (String.isBlank(description)) {
    System.debug('FAIL: Description still blank after ~' + (maxWaits * 5) + 's');
} else {
    String guestView = CaseResolutionController.sanitizeRecommendation(description);
    System.debug('Raw Description (first 200): ' + description.left(200));
    System.debug('Guest view (first 200): ' + (guestView == null ? '(null)' : guestView.left(200)));
    System.assert(
        guestView != CaseResolutionController.NO_ANSWER_MESSAGE,
        'Expected a real KB hit for Essential Eight whitepaper question'
    );
}

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Case Id: ' + caseId);
System.debug('Case Number: ' + result.get('caseNumber'));
