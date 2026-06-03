// Verification: Case Resolution Email RTF flow
// Tests guest-style close, agent resolve, no-email guard, and re-save guard.
// Email delivery: check Flow interview history / Email Log in org after run.
// Note: Platform events commit after this transaction; we close via the same
// Case DML that CaseResolvedTrigger performs so the email flow is exercised.

String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

System.debug('=== CURSOR TEST MARKER: ' + marker + ' ===');

// --- Scenario A: Guest-style close (mirrors CaseResolvedTrigger DML) ---
String guestResolution = 'Cursor test AI answer: restart the print spooler service.';
Case guestCase = new Case(
    Origin         = 'Web',
    Status         = 'New',
    Priority       = 'Medium',
    Subject        = marker + ' How do I fix a printer offline error?',
    SuppliedEmail  = 'cursor-test-guest@example.com',
    SuppliedName   = 'Cursor Guest',
    Description    = guestResolution
);
insert guestCase;
System.debug('=== SCENARIO A CASE ID: ' + guestCase.Id + ' ===');

update new Case(
    Id            = guestCase.Id,
    Status        = 'Closed',
    Resolution__c = guestResolution
);

Case guestAfter = [
    SELECT Id, Status, Resolution__c, SuppliedEmail, Subject
    FROM Case WHERE Id = :guestCase.Id
];
System.debug('=== SCENARIO A AFTER CLOSE ===');
System.debug('Status: ' + guestAfter.Status);
System.debug('Resolution__c: ' + guestAfter.Resolution__c);
System.debug('SuppliedEmail: ' + guestAfter.SuppliedEmail);
System.assertEquals('Closed', guestAfter.Status, 'Guest-style path should close the case');
System.assertEquals(guestResolution, guestAfter.Resolution__c,
    'Resolution__c should hold the AI answer');

// --- Scenario B: Agent resolve (direct Apex path) ---
Case agentCase = new Case(
    Origin         = 'Web',
    Status         = 'New',
    Priority       = 'Medium',
    Subject        = marker + ' Agent path: VPN connection drops',
    SuppliedEmail  = 'cursor-test-agent@example.com',
    SuppliedName   = 'Cursor Agent Test'
);
insert agentCase;
System.debug('=== SCENARIO B CASE ID: ' + agentCase.Id + ' ===');

String agentResolution = 'Cursor test agent resolution: reinstall VPN client and reset credentials.';
CaseResolveActionController.SaveResult agentResult =
    CaseResolveActionController.saveResolution(agentCase.Id, agentResolution);

Case agentAfter = [
    SELECT Id, Status, Resolution__c, SuppliedEmail, Subject
    FROM Case WHERE Id = :agentCase.Id
];
System.debug('=== SCENARIO B AFTER CLOSE ===');
System.debug('caseClosed: ' + agentResult.caseClosed);
System.debug('Status: ' + agentAfter.Status);
System.debug('Resolution__c: ' + agentAfter.Resolution__c);
System.assertEquals(true, agentResult.caseClosed, 'Agent path should close the case');
System.assertEquals('Closed', agentAfter.Status, 'Agent path Status should be Closed');
System.assertEquals(agentResolution, agentAfter.Resolution__c,
    'Agent resolution should be saved to Resolution__c');

// --- Scenario C: No email guard (blank SuppliedEmail) ---
Case noEmailCase = new Case(
    Origin        = 'Phone',
    Status        = 'New',
    Subject       = marker + ' Internal case no SuppliedEmail',
    Description   = 'Should close without email recipient'
);
insert noEmailCase;
System.debug('=== SCENARIO C CASE ID: ' + noEmailCase.Id + ' ===');

update new Case(
    Id            = noEmailCase.Id,
    Status        = 'Closed',
    Resolution__c = 'Closed without SuppliedEmail — flow should skip send.'
);

Case noEmailAfter = [
    SELECT Id, Status, Resolution__c, SuppliedEmail
    FROM Case WHERE Id = :noEmailCase.Id
];
System.debug('=== SCENARIO C AFTER CLOSE ===');
System.debug('Status: ' + noEmailAfter.Status);
System.debug('SuppliedEmail blank: ' + String.isBlank(noEmailAfter.SuppliedEmail));
System.assertEquals('Closed', noEmailAfter.Status, 'Case should still close');
System.assert(String.isBlank(noEmailAfter.SuppliedEmail),
    'SuppliedEmail should be blank — flow entry should not match');

// --- Scenario D: Re-save closed case (should not re-trigger email) ---
guestAfter.Priority = 'High';
update guestAfter;
System.debug('=== SCENARIO D: Re-saved closed guest case Priority to High ===');
System.debug('Case Id: ' + guestAfter.Id + ' (no Status change — flow should not re-fire)');

System.debug('=== ASSERTIONS SUMMARY ===');
System.debug('A Guest-style close: PASS (Status=Closed, Resolution copied)');
System.debug('B Agent close: PASS (Status=Closed, Resolution saved)');
System.debug('C No email guard: PASS (closed with blank SuppliedEmail)');
System.debug('D Re-save guard: updated Priority only (verify no duplicate email in Flow history)');

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Search org for Subject LIKE: cursor-test%');
System.debug('Guest case: ' + guestCase.Id);
System.debug('Agent case: ' + agentCase.Id);
System.debug('No-email case: ' + noEmailCase.Id);
System.debug('Verify emails in Setup > Email Log or Flow > Case Resolution Email RTF interviews');
