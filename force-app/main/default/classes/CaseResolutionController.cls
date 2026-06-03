/**
 * Apex controller for the Case Resolution Assistant LWC.
 *
 * Runs WITHOUT SHARING because the LWC is invoked by the unauthenticated
 * Guest User on a public Experience Cloud (LWR) site. The Guest User
 * profile typically cannot insert/read/update Case records under default
 * sharing rules, so we explicitly elevate privileges for these three
 * narrow, well-defined operations.
 *
 * Methods exposed to the LWC:
 *   1. createSupportCase  - inserts a new Case from the form fields
 *   2. getRecommendation  - polled while waiting for the GPTfy AI answer
 *   3. resolveCase        - publishes a Case_Resolved__e Platform Event so that
 *                           CaseResolvedTrigger can close the Case in system
 *                           context (the Guest User License forbids guests from
 *                           updating Cases directly)
 */
public without sharing class CaseResolutionController {

    private static final Integer SUBJECT_MAX_LENGTH = 255;

    /**
     * Inserts a new Case from the guest's form submission.
     * Origin = 'Web' is critical: the record-triggered Flow filters on it.
     *
     * @param firstName  Guest's first name (becomes part of SuppliedName)
     * @param lastName   Guest's last name  (becomes part of SuppliedName)
     * @param email      Guest's email      (stored on SuppliedEmail)
     * @param subject    The user's question (stored on Subject; truncated to 255 chars)
     * @param product    Optional product picklist value (stored on Product__c).
     *                   Pass null/blank if the guest did not pick one; the GPTfy
     *                   prompt will then search KB across all products.
     * @return Map with keys 'caseId' (the new record's Id) and
     *         'caseNumber' (the auto-generated human-readable number).
     */
    @AuraEnabled
    public static Map<String, String> createSupportCase(
        String firstName,
        String lastName,
        String email,
        String subject,
        String product
    ) {
        try {
            String safeSubject = subject == null ? '' : subject;
            if (safeSubject.length() > SUBJECT_MAX_LENGTH) {
                safeSubject = safeSubject.substring(0, SUBJECT_MAX_LENGTH);
            }

            String suppliedName = String.join(
                new List<String>{
                    firstName == null ? '' : firstName,
                    lastName == null ? '' : lastName
                },
                ' '
            ).trim();

            Case c = new Case(
                Origin       = 'Web',
                Status       = 'New',
                Priority     = 'Medium',
                Subject      = safeSubject,
                SuppliedName = suppliedName,
                SuppliedEmail = email,
                Product__c   = String.isBlank(product) ? null : product
            );
            insert c;

            // CaseNumber is auto-generated on insert; we must re-query to read it.
            Case requeried = [
                SELECT Id, CaseNumber
                FROM Case
                WHERE Id = :c.Id
                LIMIT 1
            ];

            return new Map<String, String>{
                'caseId'     => requeried.Id,
                'caseNumber' => requeried.CaseNumber
            };
        } catch (Exception e) {
            throw new AuraHandledException('Unable to create Case: ' + e.getMessage());
        }
    }

    /**
     * Returns the Case.Description if populated by GPTfy, or null while empty.
     * Polled by the LWC every 2.5 seconds for up to 30 seconds.
     *
     * Returns null on any error so that the LWC's polling loop continues
     * cleanly instead of surfacing a transient query failure to the user.
     */
    @AuraEnabled
    public static String getRecommendation(Id caseId) {
        try {
            if (caseId == null) {
                return null;
            }
            Case c = [
                SELECT Description
                FROM Case
                WHERE Id = :caseId
                LIMIT 1
            ];
            if (String.isBlank(c.Description)) {
                return null;
            }
            return c.Description;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Called when the guest clicks "Yes, resolved".
     *
     * The Salesforce Guest User License does NOT permit "Edit Cases", so we
     * cannot `update` the Case directly from this transaction (the restriction
     * is enforced below the sharing layer and `without sharing` does not bypass
     * it). Instead, we publish a Case_Resolved__e Platform Event; the
     * subscriber (CaseResolvedTrigger) runs as the Automated Process user and
     * is permitted to flip Status='Closed' and copy the AI answer into
     * Case.Resolution__c.
     *
     * Delivery is fire-and-forget from the guest's perspective: the event is
     * persisted to the bus after this transaction commits, and the trigger
     * fires within a second or two. The LWC's "Closing your case..." spinner
     * covers that window.
     */
    @AuraEnabled
    public static void resolveCase(Id caseId) {
        if (caseId == null) {
            throw new AuraHandledException('Case Id is required.');
        }
        try {
            Case_Resolved__e evt = new Case_Resolved__e(
                CaseId__c = String.valueOf(caseId)
            );
            Database.SaveResult sr = EventBus.publish(evt);
            if (!sr.isSuccess()) {
                String firstError = sr.getErrors().isEmpty()
                    ? 'Unknown error publishing Case_Resolved__e'
                    : sr.getErrors()[0].getMessage();
                throw new AuraHandledException(
                    'Unable to close case: ' + firstError
                );
            }
        } catch (AuraHandledException ahe) {
            throw ahe;
        } catch (Exception e) {
            throw new AuraHandledException(
                'Unable to close case: ' + e.getMessage()
            );
        }
    }

    /**
     * Returns the active picklist values for Case.Product__c so the LWC can
     * render an up-to-date <select> without hard-coding values. Cacheable so
     * the wire adapter only hits the server once per session.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getProductOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Schema.DescribeFieldResult f = Case.Product__c.getDescribe();
        for (Schema.PicklistEntry e : f.getPicklistValues()) {
            if (e.isActive()) {
                options.add(new Map<String, String>{
                    'label' => e.getLabel(),
                    'value' => e.getValue()
                });
            }
        }
        return options;
    }
}
