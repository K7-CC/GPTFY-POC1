List<List<SObject>> sosl = [
    FIND 'license OR activation OR server OR software OR download'
    IN ALL FIELDS
    RETURNING Knowledge__kav(Id, Title, PublishStatus LIMIT 10)
];
System.debug('Count: ' + sosl[0].size());
for (SObject s : sosl[0]) {
    Knowledge__kav k = (Knowledge__kav) s;
    System.debug(k.PublishStatus + ' | ' + k.Title.left(120));
}
