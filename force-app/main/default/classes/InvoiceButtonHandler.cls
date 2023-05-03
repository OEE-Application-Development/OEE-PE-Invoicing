global with sharing class InvoiceButtonHandler {
    private static csuoee__Noncredit_Invoice__c getInvoiceById(Id invoiceId) {
        return [select Id, csuoee__Invoice_Number__c, csuoee__Noncredit_ID__c, csuoee__Registration_Id__c, csuoee__Contact__c, csuoee__Escalation_Sent__c, (select Id, csuoee__Is_Confirmed__c, csuoee__Section_Reference__c from csuoee__Noncredit_Invoice_Line_Items__r) from csuoee__Noncredit_Invoice__c where Id = :invoiceId LIMIT 1];
    }
    
    @AuraEnabled
    global static Boolean confirmInvoice(Id invoiceId){
        try {
            csuoee__Noncredit_Invoice__c invoice = getInvoiceById(invoiceId);
            List<PEConfirmedEvent.PEConfirmedRequest> confirmRequests = new List<PEConfirmedEvent.PEConfirmedRequest>();
            for(csuoee__Noncredit_Invoice_Line_Item__c li : invoice.csuoee__Noncredit_Invoice_Line_Items__r) {
                if(li.csuoee__Is_Confirmed__c) continue;

                confirmRequests.add(new PEConfirmedEvent.PEConfirmedRequest(invoice.csuoee__Noncredit_ID__c, li.csuoee__Section_Reference__c));
            }
            if(confirmRequests.isEmpty()) return true;

            PEConfirmedEvent.enrollStudent(confirmRequests);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }

    @AuraEnabled
    global static Boolean cancelInvoice(Id invoiceId){
        try {
            csuoee__Noncredit_Invoice__c invoice = getInvoiceById(invoiceId);
            List<PEConfirmedEvent.PEConfirmedRequest> voidRequests = new List<PEConfirmedEvent.PEConfirmedRequest>();
            for(csuoee__Noncredit_Invoice_Line_Item__c li : invoice.csuoee__Noncredit_Invoice_Line_Items__r) {
                if(!li.csuoee__Is_Confirmed__c) continue;

                voidRequests.add(new PEConfirmedEvent.PEConfirmedRequest(invoice.csuoee__Noncredit_ID__c, li.csuoee__Section_Reference__c));
            }
            if(!voidRequests.isEmpty()) {
                PEVoidConfirmedEvent.unenrollStudent(voidRequests);
            }
            
            PERegistrationCancelEvent.cancelRegistration(new List<PERegistrationCancelEvent.PERegistrationCancelRequest>{new PERegistrationCancelEvent.PERegistrationCancelRequest(invoice.csuoee__Registration_Id__c, 'Cancelled by Salesforce Admin')});
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }

    @AuraEnabled
    public static Boolean addPayment(Id invoiceId, String paymentType, Decimal amount, String processorId){
        try {
            csuoee__Noncredit_Invoice__c invoice = getInvoiceById(invoiceId);
            List<PEPaymentEvent.PEPaymentRequest> payRequests = new List<PEPaymentEvent.PEPaymentRequest>();
            for(csuoee__Noncredit_Invoice_Line_Item__c li : invoice.csuoee__Noncredit_Invoice_Line_Items__r) {
                payRequests.add(new PEPaymentEvent.PEPaymentRequest(invoice.csuoee__Invoice_Number__c, paymentType, amount, processorId));
            }
            if(payRequests.isEmpty()) return true;

            PEPaymentEvent.createPayment(payRequests);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }

    @AuraEnabled
    public static Boolean requestInvoice(Id accountId, Id invoiceId, Decimal amount){
        csuoee__Noncredit_Invoice__c invoice = getInvoiceById(invoiceId);
        Account account = [select Id, hed__School_Code__c from Account where Id = :accountId LIMIT 1];

        if(String.isBlank(account.hed__School_Code__c)) throw new AuraHandledException('User ID is not set on this Account! This user is not in Opus.');

        PEInvoiceRequestEvent.createInvoiceRequest(new List<PEInvoiceRequestEvent.PEInvoiceRequest>{new PEInvoiceRequestEvent.PEInvoiceRequest(invoice.csuoee__Invoice_Number__c, amount, account.hed__School_Code__c)});
        return true;
    }

    @AuraEnabled
    public static boolean sendEscalationEmail(Id invoiceId) {
        csuoee__Noncredit_Invoice__c invoice = InvoiceButtonHandler.getInvoiceById(invoiceId);
        if(invoice.csuoee__Escalation_Sent__c) throw new AuraHandledException('An escalation email has already been sent for this invoice!');

        csuoee__Marketing_Cloud_Journey_Event__c event = new csuoee__Marketing_Cloud_Journey_Event__c(csuoee__ContactWhoId__c = invoice.csuoee__Contact__c, csuoee__Event__c = 'APIEvent-5fb3143e-8df7-32b9-4d07-dec54063bd7d', csuoee__Key__c = 'APIEvent-5fb3143e-8df7-32b9-4d07-dec54063bd7d'+invoice.Id, csuoee__Event_Type__c = 'PaymentEscalation', csuoee__RelatedToId__c = invoiceId);
        insert event;
        
        if(String.isBlank(event.Id)) throw new AuraHandledException('Could not send email! Possibly a duplicate...');

        invoice.csuoee__Escalation_Sent__c = true;
        update invoice;

        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('MarkedInvoice', invoice);
        inputMap.put('DelayConfiguration', csuoee.FlowDelayConfiguration.DayDelay(7));

        Flow.Interview.Mark_Invoice_to_Void markInvoiceFlow = new Flow.Interview.Mark_Invoice_to_Void(inputMap);
        markInvoiceFlow.start();

        return true;
    }

}