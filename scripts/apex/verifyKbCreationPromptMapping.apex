Id promptId = 'a0KdN000007W3DFUA0';

ccai__AI_Prompt__c prompt = [
    SELECT Id, Name, ccai__Status__c, ccai__Prompt_Request_Id__c,
           ccai__AI_Data_Extraction_Mapping__c
    FROM ccai__AI_Prompt__c
    WHERE Id = :promptId
    LIMIT 1
];

System.debug('PROMPT: ' + prompt.Name + ' | Status=' + prompt.ccai__Status__c);
System.debug('RequestId: ' + prompt.ccai__Prompt_Request_Id__c);
System.debug('MappingId: ' + prompt.ccai__AI_Data_Extraction_Mapping__c);

for (String objName : new List<String>{
    'ccai__AI_Data_Extraction_Mapping__c',
    'ccai__AI_Data_Extraction_Field__c',
    'ccai__AI_Prompt_Action__c'
}) {
    System.debug('--- FIELDS ON ' + objName + ' ---');
    Schema.SObjectType t = Schema.getGlobalDescribe().get(objName);
    if (t == null) {
        System.debug('NOT FOUND');
        continue;
    }
    for (String f : t.getDescribe().fields.getMap().keySet()) {
        if (f.startsWith('ccai__')) {
            System.debug(f);
        }
    }
}

if (prompt.ccai__AI_Data_Extraction_Mapping__c != null) {
    List<ccai__AI_Data_Extraction_Field__c> fields = [
        SELECT Id, Name, ccai__Field__c, ccai__Send_To_AI__c
        FROM ccai__AI_Data_Extraction_Field__c
        WHERE ccai__AI_Data_Extraction_Mapping__c = :prompt.ccai__AI_Data_Extraction_Mapping__c
        ORDER BY ccai__Field__c
    ];
    System.debug('=== MAPPED FIELDS (' + fields.size() + ') ===');
    for (ccai__AI_Data_Extraction_Field__c f : fields) {
        System.debug('Field=' + f.ccai__Field__c + ' | SendToAI=' + f.ccai__Send_To_AI__c);
    }
}

List<ccai__AI_Prompt_Action__c> actions = [
    SELECT Id, Name, ccai__Action__c, ccai__Apex_Class__c, ccai__Field_API_Name__c
    FROM ccai__AI_Prompt_Action__c
    WHERE ccai__AI_Prompt__c = :promptId
];
System.debug('=== PROMPT ACTIONS (' + actions.size() + ') ===');
for (ccai__AI_Prompt_Action__c a : actions) {
    System.debug('Action=' + a.ccai__Action__c + ' | Apex=' + a.ccai__Apex_Class__c + ' | Field=' + a.ccai__Field_API_Name__c);
}
