Id caseId = '500dN00000PIMGeQAP';

Case c = [
    SELECT Id, Subject, Resolution__c, KB_Candidates__c, Status
    FROM Case
    WHERE Id = :caseId
    LIMIT 1
];
System.debug('Case: ' + c.Subject);
System.debug('Candidates length: ' + (c.KB_Candidates__c == null ? 0 : c.KB_Candidates__c.length()));

List<ccai__AI_Response__c> responses = [
    SELECT Id, Name, ccai__record_id__c, ccai__status__c, ccai__message__c,
           ccai__data_decrypt_pii_key__c, ccai__ai_processed_data_no_pii__c,
           CreatedDate
    FROM ccai__AI_Response__c
    WHERE ccai__record_id__c = :caseId
    ORDER BY CreatedDate DESC
    LIMIT 3
];
for (ccai__AI_Response__c r : responses) {
    System.debug('--- Response ' + r.Name + ' @ ' + r.CreatedDate);
    System.debug('status=' + r.ccai__status__c + ' msg=' + r.ccai__message__c);
    System.debug('data=' + r.ccai__data_decrypt_pii_key__c);
    System.debug('processed=' + r.ccai__ai_processed_data_no_pii__c);
}
