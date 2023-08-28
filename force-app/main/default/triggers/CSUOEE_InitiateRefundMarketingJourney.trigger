trigger CSUOEE_InitiateRefundMarketingJourney on csuoee__Noncredit_Invoice_Payment__c (after insert, after update) {
    Set<Id> invoicesToRefund = new Set<Id>();
    Map<Id, Boolean> wasRefunded = new Map<Id, Boolean>();
    if(Trigger.isUpdate) {
        for(csuoee__Noncredit_Invoice_Payment__c old : Trigger.old) {
            wasRefunded.put(old.Id, 'Refund'.equals(old.csuoee__Payment_Type__c));
        }
    }

    List<csuoee__Marketing_Cloud_Journey_Event__c> journeyEvents = new List<csuoee__Marketing_Cloud_Journey_Event__c>();
    
    for(csuoee__Noncredit_Invoice_Payment__c payment : Trigger.new)    {
        if(!payment.csuoee__Payment_Type__c.equals('Refund')) continue;

        if(wasRefunded.get(payment.Id) == null || !wasRefunded.get(payment.Id)) {
            invoicesToRefund.add(payment.csuoee__Noncredit_Invoice__c);
        }
    }

    if(!invoicesToRefund.isEmpty()) {
        csuoee__Marketing_Cloud_Journey_Event_Settings__c journeySettings = null;
        for(csuoee__Noncredit_Invoice__c invoice : [select Id, csuoee__Contact__c from csuoee__Noncredit_Invoice__c where Id in :invoicesToRefund and csuoee__Contact__c != null]) {
            if(journeySettings == null)
                journeySettings = [select csuoee__Invoicing_Journey_API_Key__c, csuoee__Invoicing_Journey_InvoiceDropped_Type__c from csuoee__Marketing_Cloud_Journey_Event_Settings__c LIMIT 1];

            journeyEvents.add(
                new csuoee__Marketing_Cloud_Journey_Event__c(
                    csuoee__ContactWhoId__c = invoice.csuoee__Contact__c, 
                    csuoee__Event_Type__c = journeySettings.csuoee__Invoicing_Journey_InvoiceDropped_Type__c, 
                    csuoee__Event__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c,
                    csuoee__Key__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c+'-'+invoice.Id+'-InvoiceDropped',
                    csuoee__RelatedToId__c = invoice.Id
                )
            );
        }
    }

    if(!journeyEvents.isEmpty())
        insert journeyEvents;
}