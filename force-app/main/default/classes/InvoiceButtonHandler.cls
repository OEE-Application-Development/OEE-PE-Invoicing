global with sharing class InvoiceButtonHandler {
    private static csuoee__Noncredit_Invoice__c getInvoiceById(Id invoiceId) {
        return [select Id, csuoee__Invoice_Number__c, csuoee__Noncredit_ID__c, csuoee__Registration_Id__c, csuoee__Contact__c, csuoee__Escalate_Automatically__c, csuoee__Escalation_Sent__c, (select Id, csuoee__Is_Confirmed__c, csuoee__Section_Reference__c, csuoee__Line_Item_Amount__c from csuoee__Noncredit_Invoice_Line_Items__r), csuoee__Payer_Account__c from csuoee__Noncredit_Invoice__c where Id = :invoiceId LIMIT 1];
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
    global static String cancelInvoice(Id invoiceId, Decimal refundAmount){
        csuoee__Noncredit_Invoice__c invoice = getInvoiceById(invoiceId);
        List<PEConfirmedEvent.PEConfirmedRequest> dropRequests = new List<PEConfirmedEvent.PEConfirmedRequest>();
        List<PEVoidLineItemEvent.PEVoidLineItemRequest> voidRequests = new List<PEVoidLineItemEvent.PEVoidLineItemRequest>();
        
        for(csuoee__Noncredit_Invoice_Line_Item__c li : invoice.csuoee__Noncredit_Invoice_Line_Items__r) {
            if(li.csuoee__Is_Confirmed__c) {
                dropRequests.add(new PEConfirmedEvent.PEConfirmedRequest(invoice.csuoee__Noncredit_ID__c, li.csuoee__Section_Reference__c));
            } else {
                voidRequests.add(new PEVoidLineItemEvent.PEVoidLineItemRequest(invoice.csuoee__Invoice_Number__c, li.csuoee__Section_Reference__c));
            }
        }
        if(!dropRequests.isEmpty()) {
            PEVoidConfirmedEvent.unenrollStudent(dropRequests);
        }
        if(!voidRequests.isEmpty()) {
            PEVoidLineItemEvent.voidLineItem(voidRequests);
        }
        List<csuoee__Noncredit_Invoice_Payment__c> payments = [select Id, csuoee__CSU_Trans_Id__c, csuoee__Is_Actual__c, csuoee__Payment_Type__c, csuoee__Processor_Trans_Id__c, csuoee__Processor_Trans_Status__c, csuoee__Amount__c from csuoee__Noncredit_Invoice_Payment__c where csuoee__Noncredit_Invoice__c = :invoiceId and csuoee__Successful__c = true];
        List<PEPaymentEvent.PEPaymentRequest> refunds = new List<PEPaymentEvent.PEPaymentRequest>();
        Decimal runningManualTotal = 0;
        if(refundAmount == null) refundAmount = 1.0;
        for(csuoee__Noncredit_Invoice_Payment__c payment : payments) {
            if(!payment.csuoee__Is_Actual__c || payment.csuoee__CSU_Trans_Id__c == null || ''.equals(payment.csuoee__CSU_Trans_Id__c)) continue;
            
            runningManualTotal += payment.csuoee__Amount__c*refundAmount;
            refunds.add(new PEPaymentEvent.PEPaymentRequest(invoice.csuoee__Invoice_Number__c, 'Refund', payment.csuoee__Amount__c*refundAmount, null, payment.csuoee__CSU_Trans_Id__c));
        }
        if(!refunds.isEmpty()) {
            PEPaymentEvent.createPayment(refunds);
        }

        // If there is an automated refund requested... send to support.
        if(!refunds.isEmpty()) {
            try {
                csuoee__Marketing_Cloud_Journey_Event_Settings__c settings = [select csuoee__PE_Manual_Refund_Mailbox__c from csuoee__Marketing_Cloud_Journey_Event_Settings__c LIMIT 1];
                Account payer = [select Name from Account where Id = :invoice.csuoee__Payer_Account__c LIMIT 1];
                csuoee__Email_Simple_Request__c emailRequest = new csuoee__Email_Simple_Request__c(
                    Name = 'Refund Requested for Invoice#'+invoice.csuoee__Invoice_Number__c,
                    csuoee__Email_Body__c = '<div>Refund requested for Invoice#'+invoice.csuoee__Invoice_Number__c+'</div><div>Refunding Amount: '+String.valueOf(runningManualTotal)+' from payer: '+payer.Name+'</div>',
                    csuoee__Email_Recipient_List__c = settings.csuoee__PE_Manual_Refund_Mailbox__c
                );
                insert emailRequest;
            } catch(QueryException qe) {
                // Settings not set... skip email
            }
        }

        Set<Id> relatedInvoiceIds = new Set<Id>();
        List<csuoee__Noncredit_Invoice_Line_Item__c> relatedItems = [select Id, csuoee__Noncredit_Invoice__c from csuoee__Noncredit_Invoice_Line_Item__c where csuoee__Sponsor_Payment_Invoice__c = :invoice.Id and csuoee__Is_Actual__c = false];
        for(csuoee__Noncredit_Invoice_Line_Item__c item : relatedItems) {
            relatedInvoiceIds.add(item.csuoee__Noncredit_Invoice__c);
        }
        for(Id relatedInvoiceId : relatedInvoiceIds) {
            cancelInvoice(relatedInvoiceId, refundAmount);
        }

        invoice.csuoee__Is_Cancelled__c = true;
        update invoice;

        EventBus.publish(new csuoee__Flow_Cancel__e(
            csuoee__Cancel_Type__c = 'Invoice Cancel',
            csuoee__Cancel_Identifier__c = invoice.Id
        ));

        return 'Invoice cancellation in progress. Please allow a moment for completion.';
    }

    @AuraEnabled
    public static Boolean addPayment(Id invoiceId, String paymentType, Decimal amount, String processorId){
        try {
            csuoee__Noncredit_Invoice__c invoice = getInvoiceById(invoiceId);
            List<PEPaymentEvent.PEPaymentRequest> payRequests = new List<PEPaymentEvent.PEPaymentRequest>();
            for(csuoee__Noncredit_Invoice_Line_Item__c li : invoice.csuoee__Noncredit_Invoice_Line_Items__r) {
                if(amount <= 0) break;
                if(amount >= li.csuoee__Line_Item_Amount__c) {
                    payRequests.add(new PEPaymentEvent.PEPaymentRequest(invoice.csuoee__Invoice_Number__c, paymentType, li.csuoee__Line_Item_Amount__c, processorId));
                    amount-=li.csuoee__Line_Item_Amount__c;
                } else {
                    payRequests.add(new PEPaymentEvent.PEPaymentRequest(invoice.csuoee__Invoice_Number__c, paymentType, amount, processorId));
                    amount = 0;
                }
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
        if(invoice.csuoee__Escalation_Sent__c) return false;

        try {
            csuoee__Marketing_Cloud_Journey_Event__c event = new csuoee__Marketing_Cloud_Journey_Event__c(csuoee__ContactWhoId__c = invoice.csuoee__Contact__c, csuoee__Event__c = 'APIEvent-5fb3143e-8df7-32b9-4d07-dec54063bd7d', csuoee__Key__c = 'APIEvent-5fb3143e-8df7-32b9-4d07-dec54063bd7d'+invoice.Id, csuoee__Event_Type__c = 'PaymentEscalation', csuoee__RelatedToId__c = invoiceId);
            insert event;
        } catch(Exception e) {
            // the event couldn't be created. Don't mark the esclation as sent, still needs to cancel in the future.
        }
        
        if(event.Id == null) return false;

        invoice.csuoee__Escalation_Sent__c = true;
        //Set for cancel
        invoice.csuoee__Cancel_At__c = Date.today().addDays(8);
        
        update invoice;

        return true;
    }

    @AuraEnabled(cacheable = true)
    public static Map<String, String> getTrackingInterviewsForInvoice(Id invoiceId) {
        csuoee__Noncredit_Invoice__c invoice = [select Id, csuoee__Invoice_Number__c from csuoee__Noncredit_Invoice__c where Id = :invoiceId LIMIT 1];
        String labelString = 'Line Item for [Invoice: '+invoice.csuoee__Invoice_Number__c+'%';
        Map<String, String> statusMap = new Map<String, String>();
        for(FlowInterview interview : [select Id, InterviewLabel, CurrentElement from FlowInterview where InterviewStatus = 'Paused' and InterviewLabel LIKE :labelString]) {
            String labelEnd = interview.InterviewLabel.split('Section: ')[1];
            labelEnd = labelEnd.substring(0, labelEnd.length()-1);

            statusMap.put(labelEnd, interview.CurrentElement);
        }

        return statusMap;
    }

    @AuraEnabled
    public static String initiatePaymentRefund(Id paymentId, Decimal amount){
        try {
            csuoee__Noncredit_Invoice_Payment__c toRefund = [select Id, csuoee__Noncredit_Invoice__r.csuoee__Invoice_Number__c, csuoee__Amount__c, csuoee__Processor_Trans_Id__c, csuoee__CSU_Trans_Id__c, csuoee__Successful__c from csuoee__Noncredit_Invoice_Payment__c where Id = :paymentId LIMIT 1];
            if(!toRefund.csuoee__Successful__c) throw new IllegalArgumentException('This payment is already not marked successful... has it already been removed?');
            PEPaymentEvent.createPayment(
                new List<PEPaymentEvent.PEPaymentRequest>{new PEPaymentEvent.PEPaymentRequest(
                    toRefund.csuoee__Noncredit_Invoice__r.csuoee__Invoice_Number__c, 
                    'Cancel', 
                    amount, 
                    toRefund.csuoee__Processor_Trans_Id__c,
                    toRefund.csuoee__CSU_Trans_Id__c)}
            );

            return 'Refund Request Sent';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string validateTxInOpus(String csuTx, String processorTx) {
        try {
            MiddlewareActionResponse resp = MiddlewareIntegration.sendPostRequest('/action/tx/validate', new Map<String, String>{'csuTxId' => csuTx, 'processorTxId' => processorTx});
            
            return resp.message;
        } catch (System.CalloutException e) {
            return 'Could not get a response from CSU systems - most likely Authorize.Net is being slow to respond.';
        }
    }

}