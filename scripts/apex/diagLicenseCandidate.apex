// Diagnose why "License Activation Server..." article was not shortlisted
String targetTitle = 'License Activation Server and Software Download Disruption';
String testSubject = 'License Activation Server and Software Download Disruption';

System.debug('=== TARGET ARTICLE ===');
List<Knowledge__kav> target = [
    SELECT Id, Title, PublishStatus, LastModifiedDate, UrlName
    FROM Knowledge__kav
    WHERE Title = :targetTitle
    ORDER BY LastModifiedDate DESC
    LIMIT 3
];
System.debug('Articles with exact title: ' + target.size());
for (Knowledge__kav k : target) {
    System.debug('  Id=' + k.Id + ' | Status=' + k.PublishStatus + ' | Modified=' + k.LastModifiedDate);
}

System.debug('=== SOSL DIRECT ===');
try {
    List<List<SObject>> sosl = [
        FIND 'license OR activation OR server OR software OR download'
        IN ALL FIELDS
        RETURNING Knowledge__kav(Id, Title, PublishStatus LIMIT 10)
    ];
    System.debug('SOSL hit count: ' + sosl[0].size());
    for (SObject s : sosl[0]) {
        Knowledge__kav k = (Knowledge__kav) s;
        Boolean isTarget = k.Title == targetTitle;
        System.debug('  ' + (isTarget ? '>>> TARGET <<<' : '') + k.PublishStatus + ' | ' + k.Title);
    }
} catch (Exception e) {
    System.debug('SOSL error: ' + e.getMessage());
}

System.debug('=== SOQL FALLBACK (Title LIKE %license%) ===');
for (Knowledge__kav k : [
    SELECT Id, Title, PublishStatus
    FROM Knowledge__kav
    WHERE PublishStatus IN ('Draft', 'Online')
      AND Title LIKE '%license%'
    ORDER BY LastModifiedDate DESC
    LIMIT 5
]) {
    Boolean isTarget = k.Title == targetTitle;
    System.debug('  ' + (isTarget ? '>>> TARGET <<<' : '') + k.PublishStatus + ' | ' + k.Title);
}

System.debug('=== SERVICE searchAndSerialize ===');
String serialized = KbCandidateSearchService.searchAndSerialize(testSubject);
System.debug('Contains target title: ' + serialized.contains(targetTitle));
System.debug('Result length: ' + serialized.length());
System.debug('First 800 chars:\n' + serialized.left(800));

System.debug('=== RECENT CASES WITH LICENSE IN SUBJECT ===');
for (Case c : [
    SELECT Id, Subject, CreatedDate, KB_Candidates__c
    FROM Case
    WHERE Subject LIKE '%License Activation%'
    ORDER BY CreatedDate DESC
    LIMIT 3
]) {
    System.debug('Case: ' + c.Id + ' | Created: ' + c.CreatedDate + ' | Subject: ' + c.Subject);
    String cand = c.KB_Candidates__c;
    System.debug('  Candidates contain target: ' + (cand != null && cand.contains(targetTitle)));
    System.debug('  Candidates first 400: ' + (cand == null ? 'null' : cand.left(400)));
}

System.debug('=== DONE ===');
