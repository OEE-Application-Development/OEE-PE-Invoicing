trigger CSUOEE_StartLineItemProcessFlow on csuoee__Noncredit_Invoice_Line_Item__c (after insert) {
    List<PEConfirmedEvent.PEConfirmedRequest> autoCompletedRequests = new List<PEConfirmedEvent.PEConfirmedRequest>();
    List<hed__Course_Enrollment__c> pendingEnrollments = new List<hed__Course_Enrollment__c>();
    for(csuoee__Noncredit_Invoice_Line_Item__c li : (List<csuoee__Noncredit_Invoice_Line_Item__c>)Trigger.new) {

        if(!li.csuoee__Is_Actual__c)continue;//Don't track sponsor invoices the same way.
        if(li.csuoee__Is_Credit_Line_Item__c)continue;//Different process for credit
        if(String.isBlank(li.csuoee__Course_Offering__c))continue;//Process isn't ready - we don't have the seed data.
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('LineItemInProgress', li);
        
        // Start tracking it!
        if(!li.csuoee__Is_Confirmed__c || String.isBlank(li.csuoee__Canvas_Enrollment__c)) // Only start tracking if item isn't fulfilled.
            Flow.Interview.createInterview('csuoee', 'Noncredit_Line_Item_Process', inputMap).start();

        // Set pending status!
        if(li.csuoee__Noncredit_Invoice__r.csuoee__Contact__c != null) {
            hed__Course_Enrollment__c pendingEnrollment = new hed__Course_Enrollment__c(RecordTypeId = PEHelpers.getNoncreditPendingStudentEnrollmentRecordType().Id, hed__Course_Offering__c = li.csuoee__Course_Offering__c, hed__Contact__c = li.csuoee__Noncredit_Invoice__r.csuoee__Contact__c);
            pendingEnrollments.add(pendingEnrollment);
        }

        if(!li.csuoee__Is_Confirmed__c && li.csuoee__Is_Actual__c && li.csuoee__Line_Item_Amount__c == 0) {
            autoCompletedRequests.add(new PEConfirmedEvent.PEConfirmedRequest(li.csuoee__Noncredit_Invoice__r.csuoee__Noncredit_ID__c, li.csuoee__Section_Reference__c));
        }
    }

    if(!pendingEnrollments.isEmpty()) {
        insert pendingEnrollments;
    }
    if(!autoCompletedRequests.isEmpty()) {
        PEConfirmedEvent.enrollStudent(autoCompletedRequests);
    }
}