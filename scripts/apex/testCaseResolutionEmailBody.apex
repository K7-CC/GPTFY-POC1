// Verify resolution email body formatting (plain text + entity decode)
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

String resolutionWithQuotes =
    'To create a JSON prompt, select "JSON" as the type and set status to "Draft".';

Case testCase = new Case(
    Origin        = 'Web',
    Status        = 'New',
    Priority      = 'Medium',
    Subject       = marker + ' Email body formatting test with quotes',
    SuppliedEmail = 'cursor-test-body@example.com',
    SuppliedName  = 'Cursor Body Test',
    Description   = resolutionWithQuotes
);
insert testCase;

// Mirror guest close: copy Description to Resolution__c (Html field encodes quotes)
update new Case(
    Id            = testCase.Id,
    Status        = 'Closed',
    Resolution__c = resolutionWithQuotes
);

Case after = [
    SELECT Id, Status, Description, Resolution__c, SuppliedEmail, Subject
    FROM Case
    WHERE Id = :testCase.Id
];

System.debug('=== CURSOR EMAIL BODY TEST ===');
System.debug('Marker: ' + marker);
System.debug('Case Id: ' + after.Id);
System.debug('Description (clean): ' + after.Description);
System.debug('Resolution__c (stored): ' + after.Resolution__c);
System.debug('Resolution contains &quot;: ' + after.Resolution__c.contains('&quot;'));
System.debug('Status: ' + after.Status);
System.debug('=== CURSOR TEST COMPLETE ===');
