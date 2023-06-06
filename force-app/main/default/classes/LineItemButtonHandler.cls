global with sharing class LineItemButtonHandler {

    private static csuoee__Noncredit_Invoice_Line_Item__c getLineItemById(Id lineItemId) {
        return [select Id, csuoee__Section_Reference__c, csuoee__Noncredit_Invoice__r.csuoee__Noncredit_ID__c, csuoee__Noncredit_Invoice__r.csuoee__Invoice_Number__c, csuoee__Noncredit_Invoice__r.csuoee__Contact__c, csuoee__Course_Offering__c, csuoee__Is_Actual__c, csuoee__Is_Credit_Line_Item__c, csuoee__Is_Confirmed__c, csuoee__Requires_LMS_Fulfillment__c, csuoee__Is_Fulfilled__c, csuoee__Course_Offering__r.hed__Course__c, csuoee__Course_Offering__r.hed__Term__c, csuoee__Course_Offering__r.lms_hed__LMS_Course_Term__c from csuoee__Noncredit_Invoice_Line_Item__c where Id = :lineItemId LIMIT 1];
    }

    @AuraEnabled
    global static Boolean confirmLineItem(Id lineItemId){
        try {
            csuoee__Noncredit_Invoice_Line_Item__c li = getLineItemById(lineItemId);
            PEConfirmedEvent.enrollStudent(new List<PEConfirmedEvent.PEConfirmedRequest>{new PEConfirmedEvent.PEConfirmedRequest(li.csuoee__Noncredit_Invoice__r.csuoee__Noncredit_ID__c, li.csuoee__Section_Reference__c)});
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }

    @AuraEnabled
    global static Boolean voidLineItem(Id lineItemId){
        try {
            csuoee__Noncredit_Invoice_Line_Item__c li = getLineItemById(lineItemId);
            PEVoidConfirmedEvent.unenrollStudent(new List<PEConfirmedEvent.PEConfirmedRequest>{new PEConfirmedEvent.PEConfirmedRequest(li.csuoee__Noncredit_Invoice__r.csuoee__Noncredit_ID__c, li.csuoee__Section_Reference__c)});
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }

    @AuraEnabled
    global static void trackLineItem(Id lineItemId){
        csuoee__Noncredit_Invoice_Line_Item__c li = getLineItemById(lineItemId);

        boolean hasBeenUpdated = false;
        if(String.isEmpty(li.csuoee__Course_Offering__c)) {
            // Try to set offering
            try {
                hed__Course_Offering__c offering = [select Id from hed__Course_Offering__c where lms_hed__LMS_Reference_Code__c = :li.csuoee__Section_Reference__c LIMIT 1];
                li.csuoee__Course_Offering__c = offering.Id;
                hasBeenUpdated = true;
            } catch(Exception e) {
                throw new AuraHandledException('Could not find Offering with reference: '+li.csuoee__Section_Reference__c);
            }
        }
        if(!li.csuoee__Is_Confirmed__c) {
            try {
                hed__Course_Enrollment__c enrollment = [select Id from hed__Course_Enrollment__c where hed__Course_Offering__c = :li.csuoee__Course_Offering__c and hed__Contact__c = :li.csuoee__Noncredit_Invoice__r.csuoee__Contact__c LIMIT 1];
                if(enrollment != null) {
                    li.csuoee__Is_Confirmed__c = true;
                    hasBeenUpdated = true;
                }
            } catch(Exception e) {
                //nada
            }
        }
        if(!li.csuoee__Is_Fulfilled__c && li.csuoee__Requires_LMS_Fulfillment__c) {
            try {
                hed__Course_Offering__c offering = [select Id, hed__Course__c, hed__Term__c from hed__Course_Offering__c where Id = :li.csuoee__Course_Offering__c LIMIT 1];
                lms_hed__LMS_Course_Enrollment__c enrollment = [select Id from lms_hed__LMS_Course_Enrollment__c where lms_hed__LMS_Account__r.csuoee__Noncredit_ID__c = :li.csuoee__Noncredit_Invoice__r.csuoee__Noncredit_ID__c and lms_hed__LMS_Course_Term__r.lms_hed__Course__c = :offering.hed__Course__c and lms_hed__LMS_Course_Term__r.lms_hed__Term__c = :offering.hed__Term__c and lms_hed__LMS_Course_Term__r.lms_hed__LMS__r.hed__School_Code__c = 'Canvas' LIMIT 1];
                if(enrollment != null) {
                    li.csuoee__Canvas_Enrollment__c = enrollment.Id;
                    hasBeenUpdated = true;
                }
            } catch(Exception e) {
                //nada
            }
        }

        if(hasBeenUpdated) {
            update li;
        }

        if(!li.csuoee__Is_Actual__c)throw new AuraHandledException('Line Item is a sponsored item... doesn\'t need tracking.');
        if(li.csuoee__Is_Credit_Line_Item__c)throw new AuraHandledException('Line Item is credit... uses a different process.');

        String label = 'Line Item for [Invoice: '+li.csuoee__Noncredit_Invoice__r.csuoee__Invoice_Number__c+', Section: '+li.csuoee__Section_Reference__c+']';
        try {
            List<FlowInterview> currentlyRunning = [select Id from FlowInterview where InterviewStatus = 'Paused' and InterviewLabel = :label];
            delete currentlyRunning;
        } catch(Exception e) {

        }
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('LineItemInProgress', li);
        Flow.Interview.createInterview('csuoee', 'Noncredit_Line_Item_Process', inputMap).start();
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, Object> getLineItemData(Id recordId){
        if(recordId == null) return new Map<String, Object>();

        csuoee__Noncredit_Invoice_Line_Item__c li = getLineItemById(recordId);
        if(li.csuoee__Course_Offering__c == null) throw new AuraHandledException('Line Item does not have Course Offering set!');
        if(li.csuoee__Noncredit_Invoice__r.csuoee__Contact__c == null) throw new AuraHandledException('Invoice does not have Contact set!');
        
        lms_hed__LMS_Account__c lmsAccount;
        try {
            lmsAccount = [select Id from lms_hed__LMS_Account__c where lms_hed__Account_Owner__c = :li.csuoee__Noncredit_Invoice__r.csuoee__Contact__c LIMIT 1];
        } catch(Exception e) {
            return new Map<String, Object>{'offeringId' => li.csuoee__Course_Offering__c};// No point continuing.
        }

        lms_hed__LMS_Course_Term__c lmsCourseTerm;
            try {
                lmsCourseTerm = [select Id from lms_hed__LMS_Course_Term__c where (Id = :li.csuoee__Course_Offering__r.lms_hed__LMS_Course_Term__c) or (lms_hed__Course__c = :li.csuoee__Course_Offering__r.hed__Course__c and lms_hed__Term__c = :li.csuoee__Course_Offering__r.hed__Term__c) LIMIT 1];
            } catch(Exception e) {
                return new Map<String, Object>{'offeringId' => li.csuoee__Course_Offering__c, 'lmsAccountId' => lmsAccount.Id};// No point continuing.
            }

        return new Map<String, Object>{'offeringId' => li.csuoee__Course_Offering__c, 'lmsAccountId' => lmsAccount.Id, 'lmsCourseTermId' => lmsCourseTerm.Id};
    }

    @AuraEnabled
    public static void emitEnrollmentComplete(Id lmsEnrollmentId){
        lms_hed__LMS_Course_Enrollment__c enrollment;
        try {
            enrollment = [select Id, lms_hed__LMS_Account__r.lms_hed__Primary_Login__c, lms_hed__Course_Offering__r.lms_hed__LMS_Reference_Code__c, lms_hed__LMS_External_ID__c, lms_hed__Enrollment_Link__c from lms_hed__LMS_Course_Enrollment__c where Id = :lmsEnrollmentId LIMIT 1];
        } catch(Exception e) {
            throw new AuraHandledException('Could not find LMS Enrollment for the provided Id.');
        }
        // Send Enrollment to Grid
        PELmsEnrollmentCompleteEvent.lmsEnrollmentComplete(new List<PELmsEnrollmentCompleteEvent.PELmsEnrollmentCompleteRequest>{new PELmsEnrollmentCompleteEvent.PELmsEnrollmentCompleteRequest(enrollment.lms_hed__LMS_External_ID__c, enrollment.lms_hed__LMS_Account__r.lms_hed__Primary_Login__c, enrollment.lms_hed__Course_Offering__r.lms_hed__LMS_Reference_Code__c, enrollment.lms_hed__Enrollment_Link__c)});
    }

    @AuraEnabled
    public static void setLineItemEnrollment(Id lmsEnrollmentId, Id lineItemId){
        update new csuoee__Noncredit_Invoice_Line_Item__c(Id = lineItemId, csuoee__Canvas_Enrollment__c = lmsEnrollmentId);
    }

    @AuraEnabled
    public static boolean checkLineItemEnrollmentExists(Id lineItemId){
        csuoee__Noncredit_Invoice_Line_Item__c li = [select Id, csuoee__Noncredit_Invoice__r.csuoee__Contact__c, csuoee__Course_Offering__c, csuoee__Is_Confirmed__c, csuoee__Requires_LMS_Fulfillment__c from csuoee__Noncredit_Invoice_Line_Item__c where Id = :lineItemId LIMIT 1];
        hed__Course_Enrollment__c enrollment = [select Id, hed__Status__c from hed__Course_Enrollment__c where hed__Contact__c = :li.csuoee__Noncredit_Invoice__r.csuoee__Contact__c and hed__Course_Offering__c = :li.csuoee__Course_Offering__c LIMIT 1];
        if(enrollment == null) return false;

        boolean isConfirmed = !('Former'.equals(enrollment.hed__Status__c));
        li.csuoee__Is_Confirmed__c = isConfirmed;

        // Emit Enrollment in case Process Flow is still running.
        if(isConfirmed) {
            // Since it was confirmed... let's check if the line item is also enrolled!
            if(li.csuoee__Requires_LMS_Fulfillment__c) {
                hed__Course_Offering__c offering = [select Id, hed__Term__c, hed__Course__c from hed__Course_Offering__c where Id = :li.csuoee__Course_Offering__c LIMIT 1];
                try {
                    lms_hed__LMS_Course_Enrollment__c lmsEnrollment = [select Id from lms_hed__LMS_Course_Enrollment__c where lms_hed__LMS_Course_Term__r.lms_hed__Term__c = :offering.hed__Term__c and lms_hed__LMS_Course_Term__r.lms_hed__Course__c = :offering.hed__Course__c and lms_hed__LMS_Account__r.lms_hed__Account_Owner__c = :li.csuoee__Noncredit_Invoice__r.csuoee__Contact__c LIMIT 1];
                    li.csuoee__Canvas_Enrollment__c = lmsEnrollment.Id;
                } catch(Exception e) {

                }
            }
            csuoee__Flow_Cancel__e confirmSkip = new csuoee__Flow_Cancel__e(csuoee__Cancel_Type__c = 'Skip Await Confirmation', csuoee__Cancel_Identifier__c = lineItemId);
            EventBus.publish(confirmSkip);
        }
        update li;

        return isConfirmed;
    }
    
}