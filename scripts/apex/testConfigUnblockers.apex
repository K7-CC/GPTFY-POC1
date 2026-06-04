String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// --- GPTfy prompt (promptRequestId 9cf7e95aacf31f5730a118c90c6fda4676843) ---
ccai__AI_Prompt__c prompt = [
    SELECT Id, Name, ccai__Status__c, ccai__Prompt_Request_Id__c,
           ccai__AI_Data_Extraction_Mapping__c
    FROM ccai__AI_Prompt__c
    WHERE ccai__Prompt_Request_Id__c = '9cf7e95aacf31f5730a118c90c6fda4676843'
    LIMIT 1
];
System.assertEquals('Active', prompt.ccai__Status__c, 'GPTfy prompt must be Active');
System.debug('PASS: Prompt Active -> ' + prompt.Name);

List<ccai__AI_Prompt_Action__c> descActions = [
    SELECT Id FROM ccai__AI_Prompt_Action__c
    WHERE ccai__AI_Prompt__c = :prompt.Id
      AND ccai__Action__c = 'Update Field'
      AND ccai__Field_API_Name__c = 'Description'
];
System.assert(!descActions.isEmpty(), 'Prompt must write to Case.Description');
System.debug('PASS: Prompt action updates Case.Description');

List<ccai__AI_Data_Extraction_Field__c> productFields = [
    SELECT Id FROM ccai__AI_Data_Extraction_Field__c
    WHERE ccai__AI_Data_Extraction_Mapping__c = :prompt.ccai__AI_Data_Extraction_Mapping__c
      AND ccai__Field__c = 'Product__c'
      AND ccai__Send_To_AI__c = true
];
System.assert(!productFields.isEmpty(), 'Product__c must be sent to AI');
System.debug('PASS: Product__c sent to AI for KB filtering');

// --- Guest permission set ---
User guestUser = [
    SELECT Id, Name FROM User WHERE Name = 'gptfysupport Site Guest User' LIMIT 1
];
Integer psCount = [
    SELECT COUNT() FROM PermissionSetAssignment
    WHERE AssigneeId = :guestUser.Id
      AND PermissionSet.Name = 'gptfysupport_Guest_Access'
];
System.assert(psCount > 0, 'Guest user must have gptfysupport_Guest_Access');
System.debug('PASS: Guest user has gptfysupport_Guest_Access');

// --- Create tagged case to exercise async flow (verify Description separately) ---
Map<String, String> result = CaseResolutionController.createSupportCase(
    'Cursor', 'Config', 'cursor-test@example.com',
    marker + ' config unblockers verification',
    'E-Invoicing'
);
System.debug('PASS: Portal case created for async flow test');
System.debug('Case Id: ' + result.get('caseId'));
System.debug('Case Number: ' + result.get('caseNumber'));
System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Next: query Case.Description after ~30s for case ' + result.get('caseId'));
