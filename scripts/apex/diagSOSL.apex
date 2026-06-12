// Diagnose: can SOSL find published Knowledge__kav at all?
List<List<SObject>> r = [FIND 'Power PDF' IN ALL FIELDS RETURNING Knowledge__kav(Id, Title, PublishStatus LIMIT 5)];
System.debug('SOSL results for "Power PDF": ' + r[0].size());
for (SObject s : r[0]) {
    Knowledge__kav k = (Knowledge__kav) s;
    System.debug('  ' + k.PublishStatus + ' | ' + k.Title);
}

// Also try without WHERE clause
List<List<SObject>> r2 = [FIND 'scanner' IN ALL FIELDS RETURNING Knowledge__kav(Id, Title LIMIT 5)];
System.debug('SOSL results for "scanner": ' + r2[0].size());
for (SObject s : r2[0]) {
    Knowledge__kav k = (Knowledge__kav) s;
    System.debug('  Title: ' + k.Title);
}
