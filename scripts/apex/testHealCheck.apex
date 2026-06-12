String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');
Case c = new Case(
    Origin        = 'Web',
    Status        = 'New',
    Priority      = 'Medium',
    Subject       = marker + ' Invoices of type Credit are not allowed in Tungsten e-Invoice',
    SuppliedName  = 'cursor tester',
    SuppliedEmail = 'cursor@test.com'
);
insert c;
System.debug('Case Id: ' + c.Id);
System.debug('Marker: ' + marker);
System.debug('Created at: ' + Datetime.now());
