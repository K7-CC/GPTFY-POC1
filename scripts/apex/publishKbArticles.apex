// Publishes the first 5 draft Knowledge articles so the Golden match feature
// has published articles to surface via SOSL.
List<Knowledge__kav> drafts = [
    SELECT Id, KnowledgeArticleId, Title
    FROM Knowledge__kav
    WHERE PublishStatus = 'Draft' AND Language = 'en_US'
    LIMIT 5
];

Integer published = 0;
for (Knowledge__kav kav : drafts) {
    try {
        KbManagement.PublishingService.publishArticle(kav.KnowledgeArticleId, true);
        System.debug('Published: ' + kav.Title);
        published++;
    } catch (Exception e) {
        System.debug('Could not publish [' + kav.Title + ']: ' + e.getMessage());
    }
}
System.debug('=== PUBLISH COMPLETE: ' + published + ' articles published ===');
