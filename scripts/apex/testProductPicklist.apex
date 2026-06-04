String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

Schema.DescribeFieldResult f = Case.Product__c.getDescribe();
List<String> activeValues = new List<String>();
for (Schema.PicklistEntry e : f.getPicklistValues()) {
    if (e.isActive()) {
        activeValues.add(e.getValue());
    }
}
System.debug('Active Product__c values: ' + activeValues);

Set<String> expected = new Set<String>{ 'E-Invoicing', 'TotalAgility', 'PowerPDF' };
System.assertEquals(3, activeValues.size(), 'Expected exactly 3 active picklist values');
for (String v : activeValues) {
    System.assert(expected.contains(v), 'Unexpected value: ' + v);
}

Map<String, String> result = CaseResolutionController.createSupportCase(
    'Cursor', 'Test', 'cursor-test@example.com',
    marker + ' product picklist verification',
    'E-Invoicing'
);
Case c = [SELECT Id, CaseNumber, Product__c, Subject FROM Case WHERE Id = :result.get('caseId')];
System.assertEquals('E-Invoicing', c.Product__c, 'Product__c should be E-Invoicing');

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Case Id: ' + c.Id);
System.debug('Case Number: ' + c.CaseNumber);
