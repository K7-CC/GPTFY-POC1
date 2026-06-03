String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');
String resolution = 'Compact UI verification resolution.';

Case c = new Case(
    Origin = 'Web',
    Status = 'New',
    Subject = marker + ' resolve modal UI smoke'
);
insert c;

CaseResolveActionController.SaveResult result =
    CaseResolveActionController.saveResolution(c.Id, resolution);

Case after = [
    SELECT Id, Status, Resolution__c, Subject
    FROM Case
    WHERE Id = :c.Id
];

System.assertEquals('Closed', after.Status, 'Case should close');
System.assertEquals(resolution, after.Resolution__c, 'Resolution copied');
System.assert(result.caseClosed, 'SaveResult.caseClosed');

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('PASS: saveResolution after UI deploy');
System.debug('Marker: ' + marker);
System.debug('Case Id: ' + after.Id);
