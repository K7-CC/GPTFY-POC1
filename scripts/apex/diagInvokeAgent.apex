// Direct diagnostic: call invokeAgent and log every field on the response.
// This tells us exactly what the API returns — null, empty, error, or real body.
try {
    ccai.AIAgenticWebService.RequestWrapper request = new ccai.AIAgenticWebService.RequestWrapper();
    request.agentName   = 'Case_Resolve_Agent';
    request.userMessage = 'Invoices of type Credit are not allowed error in Tungsten e-Invoice';

    System.debug('Calling invokeAgent...');
    ccai.AIAgenticWebService.ResponseWrapper response = ccai.AIAgenticUtility.invokeAgent(request);

    if (response == null) {
        System.debug('RESULT: response object is NULL');
    } else {
        System.debug('RESULT: response is non-null');
        System.debug('  response.status      = ' + response.status);
        System.debug('  response.responseBody (first 500) = ' +
            (response.responseBody == null ? 'NULL' : response.responseBody.left(500)));
        System.debug('  response.responseBody length = ' +
            (response.responseBody == null ? 'NULL' : String.valueOf(response.responseBody.length())));
    }
} catch (Exception e) {
    System.debug('EXCEPTION during invokeAgent: ' + e.getTypeName() + ' — ' + e.getMessage());
    System.debug('Stack: ' + e.getStackTraceString());
}
System.debug('=== DIAG COMPLETE ===');
