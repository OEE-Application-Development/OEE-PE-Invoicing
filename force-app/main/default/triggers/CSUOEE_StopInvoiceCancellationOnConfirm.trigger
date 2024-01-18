trigger CSUOEE_StopInvoiceCancellationOnConfirm on csuoee__Noncredit_Invoice_Line_Item__c (after update) {
    Set<Id> invoiceIdsToSave = new Set<Id>();
    for(csuoee__Noncredit_Invoice_Line_Item__c li : (List<csuoee__Noncredit_Invoice_Line_Item__c>)Trigger.new) {
        invoiceIdsToSave.add(li.csuoee__Noncredit_Invoice__c); // De-Duping
    }
    List<csuoee__Noncredit_Invoice__c> invoicesToSave = new List<csuoee__Noncredit_Invoice__c>();
    for(Id invoiceId : invoiceIdsToSave) {
        invoicesToSave.add(new csuoee__Noncredit_Invoice__c(Id = invoiceId, csuoee__Cancel_At__c = null));
    }

    update invoicesToSave;
}