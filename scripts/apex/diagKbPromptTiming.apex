Schema.SObjectType t = Schema.getGlobalDescribe().get('ccai__AI_Response__c');
for (String f : t.getDescribe().fields.getMap().keySet()) {
    if (f.startsWith('ccai__')) System.debug(f);
}

ccai__AI_Prompt__c prompt = [
    SELECT Id, Name, ccai__Prompt_Request_Id__c, ccai__AI_Data_Extraction_Mapping__c
    FROM ccai__AI_Prompt__c
    WHERE ccai__Prompt_Request_Id__c = '7093be507198515b03c651eedd9552ec71a9a'
    LIMIT 1
];
System.debug('Prompt: ' + prompt.Name);

for (ccai__AI_Data_Extraction_Field__c f : [
    SELECT ccai__Field__c, ccai__Send_To_AI__c
    FROM ccai__AI_Data_Extraction_Field__c
    WHERE ccai__AI_Data_Extraction_Mapping__c = :prompt.ccai__AI_Data_Extraction_Mapping__c
    ORDER BY ccai__Field__c
]) {
    System.debug('MAPPED: ' + f.ccai__Field__c);
}
