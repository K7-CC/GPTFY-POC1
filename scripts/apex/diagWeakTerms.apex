String caseSubject =
    'i am facing issue with License Activation Server and Software Download Disruption.. need you support to fix this';

String serialized = KbCandidateSearchService.searchAndSerialize(caseSubject);

System.debug('Has compatibility issue ScanSnap: ' +
    serialized.contains('compatibility issue with my ScanSnap iX500'));
System.debug('Has size handling 4 GB: ' +
    serialized.contains('size handling limitations'));
System.debug('Has License Activation Server: ' +
    serialized.contains('License Activation Server and Software Download Disruption'));
System.debug('Candidate count blocks: ' + serialized.split('CANDIDATE_').size());
