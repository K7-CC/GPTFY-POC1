// Assigns the GPTfy_Case_Fields_Access permission set to every active user
// who does not already have it. Idempotent — safe to re-run.
PermissionSet ps = [
    SELECT Id, Name
    FROM PermissionSet
    WHERE Name = 'GPTfy_Case_Fields_Access'
    LIMIT 1
];

Set<Id> alreadyAssigned = new Set<Id>();
for (PermissionSetAssignment existing : [
    SELECT AssigneeId
    FROM PermissionSetAssignment
    WHERE PermissionSetId = :ps.Id
]) {
    alreadyAssigned.add(existing.AssigneeId);
}

List<PermissionSetAssignment> toInsert = new List<PermissionSetAssignment>();
Integer skippedInactive = 0;
Integer skippedExisting = 0;
for (User u : [
    SELECT Id, Username, IsActive, Profile.Name, UserType
    FROM User
    WHERE IsActive = true
]) {
    if (alreadyAssigned.contains(u.Id)) {
        skippedExisting++;
        continue;
    }
    toInsert.add(new PermissionSetAssignment(
        AssigneeId      = u.Id,
        PermissionSetId = ps.Id
    ));
}

Database.SaveResult[] results = Database.insert(toInsert, false);

Integer successCount = 0;
Integer failureCount = 0;
List<String> failureMessages = new List<String>();
for (Integer i = 0; i < results.size(); i++) {
    if (results[i].isSuccess()) {
        successCount++;
    } else {
        failureCount++;
        String userId = String.valueOf(toInsert[i].AssigneeId);
        String errs   = '';
        for (Database.Error e : results[i].getErrors()) {
            errs += e.getStatusCode() + ': ' + e.getMessage() + '; ';
        }
        failureMessages.add(userId + ' -> ' + errs);
    }
}

System.debug(LoggingLevel.INFO, '=== PermissionSet Assignment Summary ===');
System.debug(LoggingLevel.INFO, 'PermissionSet: ' + ps.Name + ' (' + ps.Id + ')');
System.debug(LoggingLevel.INFO, 'Already assigned (skipped): ' + skippedExisting);
System.debug(LoggingLevel.INFO, 'Newly assigned: ' + successCount);
System.debug(LoggingLevel.INFO, 'Failed: ' + failureCount);
if (failureCount > 0) {
    for (String msg : failureMessages) {
        System.debug(LoggingLevel.WARN, 'FAIL: ' + msg);
    }
}
