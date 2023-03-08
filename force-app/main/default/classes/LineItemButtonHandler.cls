global with sharing class LineItemButtonHandler {

    private static csuoee__Noncredit_Invoice_Line_Item__c getLineItemById(Id lineItemId) {
        return [select Id, csuoee__Section_Reference__c, csuoee__Noncredit_Invoice__r.csuoee__Noncredit_ID__c from csuoee__Noncredit_Invoice_Line_Item__c where Id = :lineItemId LIMIT 1];
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
    
}