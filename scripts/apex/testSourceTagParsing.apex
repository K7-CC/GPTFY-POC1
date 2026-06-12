String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// 1. Create a Case whose Description simulates what the agent will write
//    once the system prompt is updated to append [SOURCE: filename] tags.
Case c = new Case(
    Origin      = 'Web',
    Status      = 'New',
    Subject     = marker + ' scanner upgrade issue',
    Description = 'After upgrading to Power PDF 2025.3, ScanSnap iX500 scanner ' +
                  'compatibility issues can be resolved by reinstalling the drivers ' +
                  'and reconfiguring the scanner in Power PDF settings.\n' +
                  '[SOURCE: PowerPDF-2025-3-Release-Notes.pdf]\n' +
                  '[SOURCE: ScanSnap-iX500-Compatibility-Guide.pdf]'
);
insert c;

// 2. Verify getSourceArticles extracts the correct file names.
List<String> sources = CaseResolutionController.getSourceArticles(c.Id);
System.debug('=== CURSOR TEST: Source Tag Parsing ===');
System.debug('Marker: ' + marker);
System.debug('Case Id: ' + c.Id);
System.debug('Sources extracted: ' + sources.size());
for (String src : sources) {
    System.debug('  ★ Golden match → ' + src);
}

// 3. Verify getRecommendation strips the tags from the displayed answer.
String displayed = CaseResolutionController.getRecommendation(c.Id);
System.debug('Displayed answer (should have NO [SOURCE:] tags): ' + displayed);
System.assert(!displayed.contains('[SOURCE:'), 'FAIL: [SOURCE:] tag leaked into displayed answer');
System.assert(displayed.contains('ScanSnap iX500'), 'FAIL: answer text was lost during stripping');

// 4. Assert source count.
System.assertEquals(2, sources.size(), 'FAIL: expected 2 source names');
System.assertEquals('PowerPDF-2025-3-Release-Notes.pdf', sources[0]);
System.assertEquals('ScanSnap-iX500-Compatibility-Guide.pdf', sources[1]);

System.debug('PASS: Source tag parsing and answer stripping work correctly.');
System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Lightning URL: https://gptfy-poc1.lightning.force.com/lightning/r/Case/' + c.Id + '/view');
