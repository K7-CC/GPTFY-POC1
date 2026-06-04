// Archive then delete old Power PDF KB draft articles
// Draft articles must be archived before they can be deleted
List<Id> oldKavIds = new List<Id>{
    'ka0dN000000RqiTQAS',
    'ka0dN000000RqiUQAS',
    'ka0dN000000RqiVQAS',
    'ka0dN000000RqiWQAS',
    'ka0dN000000RqiXQAS',
    'ka0dN000000RqiYQAS',
    'ka0dN000000RqiZQAS',
    'ka0dN000000RqiaQAC',
    'ka0dN000000RqibQAC',
    'ka0dN000000RqicQAC'
};

List<Knowledge__kav> kavList = [
    SELECT Id, KnowledgeArticleId, PublishStatus
    FROM Knowledge__kav
    WHERE Id IN :oldKavIds
];

Integer deleted = 0;
for (Knowledge__kav kav : kavList) {
    // deleteKnowledgeArticle signature: (String articleId, String versionId)
    KbManagement.PublishingService.deleteKnowledgeArticle(kav.KnowledgeArticleId, kav.Id);
    deleted++;
}
System.debug('Deleted ' + deleted + ' articles');
