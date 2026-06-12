String caseSubject = 'i am facing issue with License Activation Server and Software Download Disruption.. need you support to fix this';
String targetTitle = 'License Activation Server and Software Download Disruption';

System.debug('=== ACTUAL CASE SUBJECT SEARCH ===');
System.debug('Subject: ' + caseSubject);

String serialized = KbCandidateSearchService.searchAndSerialize(caseSubject);
System.debug('Contains target article: ' + serialized.contains(targetTitle));
System.debug('Candidates preview:\n' + serialized.left(1200));

System.debug('=== SOSL with facing/issue/license/activation/server ===');
List<List<SObject>> sosl = [
    FIND 'facing OR issue OR license OR activation OR server'
    IN ALL FIELDS
    RETURNING Knowledge__kav(Id, Title, PublishStatus LIMIT 10)
];
System.debug('SOSL count: ' + sosl[0].size());
for (SObject s : sosl[0]) {
    Knowledge__kav k = (Knowledge__kav) s;
    System.debug('  ' + k.PublishStatus + ' | ' + k.Title.left(100));
}

System.debug('=== Is target in SOSL at all? ===');
List<List<SObject>> sosl2 = [
    FIND 'License Activation Server Software Download Disruption'
    IN ALL FIELDS
    RETURNING Knowledge__kav(Id, Title, PublishStatus LIMIT 10)
];
System.debug('Exact phrase SOSL count: ' + sosl2[0].size());
for (SObject s : sosl2[0]) {
    Knowledge__kav k = (Knowledge__kav) s;
    System.debug('  ' + k.PublishStatus + ' | ' + k.Title);
}
