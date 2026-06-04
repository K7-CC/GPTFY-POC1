// Set CASE_ID from create step before running
Id caseId = '500dN00000OybAMQAZ';

Case c = [SELECT Id, CaseNumber, Description FROM Case WHERE Id = :caseId LIMIT 1];

String rawDescription = c.Description;
String guestMessage;
if (String.isBlank(rawDescription)) {
    guestMessage = CaseResolutionController.TIMEOUT_MESSAGE;
} else {
    guestMessage = CaseResolutionController.getRecommendation(caseId);
}

Boolean isFallback =
    guestMessage == CaseResolutionController.NO_ANSWER_MESSAGE ||
    guestMessage == CaseResolutionController.TIMEOUT_MESSAGE;

System.debug('=== IRRELEVANT QUESTION E2E RESULT ===');
System.debug('Case Id: ' + c.Id);
System.debug('Case Number: ' + c.CaseNumber);
System.debug('Badge shown: ' + (isFallback ? 'WE\'LL FOLLOW UP' : 'KNOWLEDGE ARTICLE FOUND'));
System.debug('Card title: ' + (isFallback ? 'Next Steps' : 'Recommended Solution'));
System.debug('Raw RAG Description: ' + (rawDescription == null ? '(blank)' : rawDescription));
System.debug('Guest end-result message: ' + guestMessage);
System.debug('=== CURSOR TEST COMPLETE ===');
