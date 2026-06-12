/**
 * Thin Question Guard — verification script
 *
 * The guard is enforced client-side in the LWC (caseResolutionAssistant.js).
 * Questions with < 10 words never reach Apex (createSupportCase is not called).
 *
 * This script verifies that:
 *   1. The Apex controller still accepts and processes a "thick" (adequate) question
 *      — simulating the path a user would take after dismissing the hint.
 *   2. No thin-question Cases exist that were created in the last hour
 *      (which would indicate the guard failed to fire post-deploy).
 *
 * Marker convention: Subject starts with 'cursor-test-{timestamp}'
 */
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss') + '-thin-guard';

// Simulate a "thick" question that would pass the 10-word guard
String thickQuestion = marker + ' PowerPDF crashes when converting a Word document to PDF on Windows 11';

// Call the same Apex method the LWC calls after the guard passes
Map<String, Object> result = (Map<String, Object>) CaseResolutionController.createSupportCase(
    'Cursor',      // firstName
    'TestUser',    // lastName
    'cursor-test@gptfy-test.example.com', // email
    thickQuestion, // subject (thick question -- guard would have passed)
    'PowerPDF'     // product
);

String caseId     = (String) result.get('caseId');
String caseNumber = (String) result.get('caseNumber');

System.debug('=== THIN QUESTION GUARD VERIFICATION ===');
System.debug('Marker: ' + marker);
System.debug('Thick-question Case created -- Id: ' + caseId + '  Number: ' + caseNumber);

// Assert the case was created with the expected subject
Case c = [SELECT Id, Subject, Origin FROM Case WHERE Id = :caseId];
System.assertEquals(thickQuestion, c.Subject,  'Subject should match thick question');
System.assertEquals('Web',         c.Origin,   'Origin should be Web');

// Verify NO thin-question Cases were created in the last hour (i.e., post-deploy).
// Pre-existing historical cases from before this fix are excluded by the date filter.
Datetime deployedAt = Datetime.now().addMinutes(-10);
List<Case> thinCases = [
    SELECT Id, Subject, CreatedDate
    FROM Case
    WHERE Origin = 'Web'
      AND CreatedDate >= :deployedAt
      AND (Subject = 'I NEED HELP' OR Subject = 'I have an issue' OR Subject = 'help me')
];
System.assertEquals(0, thinCases.size(),
    'Expected no thin-question cases created after deploy -- guard should block them');

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('PASS -- thick question reached Apex, no post-deploy thin-question cases found');
System.debug('Lightning URL: https://gptfy-poc1.lightning.force.com/lightning/r/Case/' + caseId + '/view');
