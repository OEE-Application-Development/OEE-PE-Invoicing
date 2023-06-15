trigger CSUOEE_StopInvoiceCancellation on csuoee__Noncredit_Invoice_Payment__c (after insert, after update) {
    List<Id> invoiceIds = new List<Id>();for(csuoee__Noncredit_Invoice_Payment__c payment : (List<csuoee__Noncredit_Invoice_Payment__c>)Trigger.new) {invoiceIds.add(payment.csuoee__Noncredit_Invoice__c);}
    
    List<csuoee__Noncredit_Invoice__c> toUpdate = [select Id, csuoee__Cancel_At__c, csuoee__Is_Cancelled__c from csuoee__Noncredit_Invoice__c where csuoee__Is_Cancelled__c = true or csuoee__Cancel_in_Progress__c = true];
    if(!toUpdate.isEmpty()) {
        for(csuoee__Noncredit_Invoice__c invoice : toUpdate) {
            invoice.csuoee__Is_Cancelled__c = false;
            invoice.csuoee__Cancel_At__c = null;
        }

        update toUpdate;
    }
}