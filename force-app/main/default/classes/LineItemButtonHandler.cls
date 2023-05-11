global with sharing class LineItemButtonHandler {

    private static csuoee__Noncredit_Invoice_Line_Item__c getLineItemById(Id lineItemId) {
        return [select Id, csuoee__Section_Reference__c, csuoee__Noncredit_Invoice__r.csuoee__Noncredit_ID__c, csuoee__Noncredit_Invoice__r.csuoee__Invoice_Number__c, csuoee__Noncredit_Invoice__r.csuoee__Contact__c, csuoee__Course_Offering__c, csuoee__Is_Actual__c, csuoee__Is_Credit_Line_Item__c, csuoee__Is_Confirmed__c, csuoee__Requires_LMS_Fulfillment__c, csuoee__Is_Fulfilled__c from csuoee__Noncredit_Invoice_Line_Item__c where Id = :lineItemId LIMIT 1];
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
    
}