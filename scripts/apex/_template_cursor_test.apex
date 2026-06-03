/**
 * Template for org verification scripts.
 * Copy to test{FeatureName}.apex, fill in the scenario, then run:
 *   sf apex run --file scripts/apex/test{FeatureName}.apex --target-org gptfy-poc1
 *
 * All test records MUST include "cursor" in Subject/Title/Name for identification.
 */
String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

// --- 1. Create dummy data ---
// Case example:
// Case c = new Case(
//     Origin  = 'Phone',
//     Status  = 'New',
//     Subject = marker + ' describe scenario here'
// );
// insert c;
// System.debug('=== CURSOR TEST CASE ID: ' + c.Id + ' ===');

// --- 2. Invoke the feature under test ---
// MyController.doSomething(c.Id, 'test input');

// --- 3. Assert and log results ---
// System.debug('=== ASSERTIONS ===');
// System.debug('expected: ... actual: ...');

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Search org for marker: ' + marker);
