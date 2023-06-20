trigger CSUOEE_HandleInvoiceCancel on csuoee__Noncredit_Invoice__c (before update) {
    Map<Id, csuoee__Noncredit_Invoice__c> oldMap = Trigger.oldMap;
    Map<Id, csuoee__Noncredit_Invoice__c> newMap = Trigger.newMap;

    List<csuoee__Flow_Cancel__e> invoiceCancels = new List<csuoee__Flow_Cancel__e>();
    for(Id invoiceId : newMap.keySet()) {
        Boolean isCancelled = newMap.get(invoiceId).csuoee__Is_Cancelled__c;

        if(isCancelled) {
            Boolean wasCancelled = oldMap.get(invoiceId).csuoee__Is_Cancelled__c;
            if(!wasCancelled) {
                //This is a new cancel. Emit an event for it.
                invoiceCancels.add(new csuoee__Flow_Cancel__e(
                    csuoee__Cancel_Type__c = 'Invoice Cancel',
                    csuoee__Cancel_Identifier__c = invoiceId
                ));
            }
        }
    }

    if(!invoiceCancels.isEmpty())
        EventBus.publish(invoiceCancels);
}