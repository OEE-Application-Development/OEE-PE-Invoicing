trigger CSUOEE_HandleInvoiceConfirmationSend on csuoee__Noncredit_Invoice_Line_Item__c (after insert, after update ) {
    Set<Id> invoiceIds = new Set<Id>();
    for(csuoee__Noncredit_Invoice_Line_Item__c li : (List<csuoee__Noncredit_Invoice_Line_Item__c>) Trigger.new) {
        if(li.csuoee__Canvas_Enrollment__c != null)invoiceIds.add(li.csuoee__Noncredit_Invoice__c); // Only lookup invoices to complete if this li is fulfilled.
    }
    
    List<csuoee__Marketing_Cloud_Journey_Event__c> journeyEvents = new List<csuoee__Marketing_Cloud_Journey_Event__c>();
    List<csuoee__Noncredit_Invoice__c> invoicesToComplete = [select Id, csuoee__Contact__c, csuoee__Fulfilled_Email_Sent__c, csuoee__Send_Confirmation_Email__c from csuoee__Noncredit_Invoice__c where Id in :invoiceIds and csuoee__Fulfilled_Email_Sent__c = false];
    
    List<csuoee__Noncredit_Invoice_Line_Item__c> lineItemsToCheck = [select Id, csuoee__Noncredit_Invoice__c, csuoee__Canvas_Enrollment__c from csuoee__Noncredit_Invoice_Line_Item__c where csuoee__Noncredit_Invoice__c in :invoiceIds];
    Map<Id, List<csuoee__Noncredit_Invoice_Line_Item__c>> liToInvoiceMap = new Map<Id, List<csuoee__Noncredit_Invoice_Line_Item__c>>();
    for(csuoee__Noncredit_Invoice_Line_Item__c li : lineItemsToCheck) {
        List<csuoee__Noncredit_Invoice_Line_Item__c> lis = liToInvoiceMap.get(li.csuoee__Noncredit_Invoice__c);
        if(lis == null) {
            lis = new List<csuoee__Noncredit_Invoice_Line_Item__c>();
            liToInvoiceMap.put(li.csuoee__Noncredit_Invoice__c, lis);
        }
        lis.add(li);
    }

    if(!invoicesToComplete.isEmpty()) {
        csuoee__Marketing_Cloud_Journey_Event_Settings__c journeySettings = [select csuoee__Invoicing_Journey_API_Key__c, csuoee__Invoicing_Journey_Confirmation_Type__c from csuoee__Marketing_Cloud_Journey_Event_Settings__c LIMIT 1];

        for(csuoee__Noncredit_Invoice__c invoice : invoicesToComplete) {
            if(invoice.csuoee__Contact__c == null) continue;

            // Check that ALL line items are fulfilled on this invoice.
            Boolean isComplete = true;
            for(csuoee__Noncredit_Invoice_Line_Item__c li : liToInvoiceMap.get(invoice.Id)) {
                isComplete = isComplete&&(li.csuoee__Canvas_Enrollment__c != null);
            }
            if(!isComplete || !invoice.csuoee__Send_Confirmation_Email__c) continue;

            journeyEvents.add(
                new csuoee__Marketing_Cloud_Journey_Event__c(
                    csuoee__ContactWhoId__c = invoice.csuoee__Contact__c, 
                    csuoee__Event_Type__c = journeySettings.csuoee__Invoicing_Journey_Confirmation_Type__c, 
                    csuoee__Event__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c,
                    csuoee__Key__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c+'-'+invoice.Id+'-Confirmation',
                    csuoee__RelatedToId__c = invoice.Id)
            );
            invoice.csuoee__Fulfilled_Email_Sent__c = true;
        }
    }

    Database.insert(journeyEvents, false);
    update invoicesToComplete;
}