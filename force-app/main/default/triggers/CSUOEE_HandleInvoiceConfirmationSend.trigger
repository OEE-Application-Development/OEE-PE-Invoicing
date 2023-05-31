trigger CSUOEE_HandleInvoiceConfirmationSend on csuoee__Noncredit_Invoice_Line_Item__c (after insert, after update ) {
    Set<Id> invoiceIds = new Set<Id>();
    for(csuoee__Noncredit_Invoice_Line_Item__c li : (List<csuoee__Noncredit_Invoice_Line_Item__c>) Trigger.new) {
        invoiceIds.add(li.csuoee__Noncredit_Invoice__c);
    }
    
    List<csuoee__Marketing_Cloud_Journey_Event__c> journeyEvents = new List<csuoee__Marketing_Cloud_Journey_Event__c>();
    List<csuoee__Noncredit_Invoice__c> invoicesToComplete = [select Id, csuoee__Contact__c, csuoee__Fulfilled_Email_Sent__c from csuoee__Noncredit_Invoice__c where Id in :invoiceIds and csuoee__Fulfilled_Email_Sent__c = false];
    
    if(!invoicesToComplete.isEmpty()) {
        csuoee__Marketing_Cloud_Journey_Event_Settings__c journeySettings = [select csuoee__Invoicing_Journey_API_Key__c, csuoee__Invoicing_Journey_Confirmation_Type__c from csuoee__Marketing_Cloud_Journey_Event_Settings__c LIMIT 1];

        for(csuoee__Noncredit_Invoice__c invoice : invoicesToComplete) {
            if(invoice.csuoee__Contact__c == null) continue;

            journeyEvents.add(
                new csuoee__Marketing_Cloud_Journey_Event__c(
                    csuoee__ContactWhoId__c = invoice.csuoee__Contact__c, 
                    csuoee__Event_Type__c = journeySettings.csuoee__Invoicing_Journey_Confirmation_Type__c, 
                    csuoee__Event__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c,
                    csuoee__Key__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c+'-'+invoice.Id,
                    csuoee__RelatedToId__c = invoice.Id)
            );
            invoice.csuoee__Fulfilled_Email_Sent__c = true;
        }
    }

    insert journeyEvents;
    update invoicesToComplete;
}