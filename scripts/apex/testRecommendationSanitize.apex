String marker = 'cursor-test-' + Datetime.now().format('yyyyMMdd-HHmmss');

Case lowQuality = new Case(
    Origin = 'Web',
    Status = 'New',
    Priority = 'Medium',
    Subject = marker + ' RAG no-answer sanitize',
    Description = 'What was that?'
);
insert lowQuality;

String guestView = CaseResolutionController.getRecommendation(lowQuality.Id);
System.assert(
    guestView == CaseResolutionController.NO_ANSWER_MESSAGE,
    'getRecommendation should replace low-quality RAG text'
);

Case sayAgain = new Case(
    Origin = 'Web',
    Status = 'New',
    Priority = 'Medium',
    Subject = marker + ' RAG say-that-again sanitize',
    Description = 'Sorry, can you say that again?'
);
insert sayAgain;

String sayAgainView = CaseResolutionController.getRecommendation(sayAgain.Id);
System.assert(
    sayAgainView == CaseResolutionController.NO_ANSWER_MESSAGE,
    'Sorry, can you say that again? must map to NO_ANSWER_MESSAGE'
);

Case good = new Case(
    Origin = 'Web',
    Status = 'New',
    Priority = 'Medium',
    Subject = marker + ' valid KB answer',
    Description = 'Restart the application and clear the temp folder.'
);
insert good;

String goodView = CaseResolutionController.getRecommendation(good.Id);
System.assert(
    goodView == 'Restart the application and clear the temp folder.',
    'Valid answers must pass through unchanged'
);

System.debug('=== CURSOR TEST COMPLETE ===');
System.debug('Marker: ' + marker);
System.debug('Low-quality Case Id: ' + lowQuality.Id);
System.debug('Good answer Case Id: ' + good.Id);
System.debug('Sanitized message preview: ' + guestView.left(80));
