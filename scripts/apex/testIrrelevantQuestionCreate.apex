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

System.debug('CASE_ID=' + result.get('caseId'));
System.debug('CASE_NUMBER=' + result.get('caseNumber'));
System.debug('MARKER=' + marker);
System.debug('QUESTION=' + question);
