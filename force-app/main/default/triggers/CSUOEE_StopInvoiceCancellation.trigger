trigger CSUOEE_StopInvoiceCancellation on csuoee__Noncredit_Invoice_Payment__c (after insert, after update) {
    List<csuoee__Noncredit_Invoice__c> invoicesToClear = new List<csuoee__Noncredit_Invoice__c>();
    for(csuoee__Noncredit_Invoice_Payment__c payment : (List<csuoee__Noncredit_Invoice_Payment__c>)Trigger.new) {
        if(payment.csuoee__Noncredit_Invoice__r.csuoee__Cancel_in_Progress__c || payment.csuoee__Noncredit_Invoice__r.csuoee__Is_Cancelled__c) {
            invoicesToClear.add(new csuoee__Noncredit_Invoice__c(Id = payment.csuoee__Noncredit_Invoice__c, csuoee__Cancel_At__c = null, csuoee__Is_Cancelled__c = false));
        }
    }

    if(!invoicesToClear.isEmpty())
        update invoicesToClear;
}