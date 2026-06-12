String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');
String caseSubject =
    'i am facing issue with License Activation Server and Software Download Disruption.. need you support to fix this';

System.debug('=== CURSOR TEST: weak-term filtering ===');
System.debug('Marker: ' + marker);

String serialized = KbCandidateSearchService.searchAndSerialize(caseSubject);

System.assert(
    !serialized.contains('compatibility issue with my ScanSnap iX500'),
    'FAIL: vague "issue" should not drive ScanSnap compatibility article'
);
System.assert(
    !serialized.contains('size handling limitations'),
    'FAIL: vague "issue" should not drive PDF size-limit article'
);

Integer candidateBlocks = serialized.split('CANDIDATE_').size() - 1;
System.debug('Candidate blocks returned: ' + candidateBlocks);
System.assert(candidateBlocks <= 3, 'FAIL: should return fewer noisy SOSL hits than before');

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
