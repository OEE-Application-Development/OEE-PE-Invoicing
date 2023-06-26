global with sharing class PEPaymentEvent {
    @InvocableMethod(Label='Create Payment Event' Description='Sends payment to grid to be added to Opus.')
    global static List<AzureEventIntegration.AzureResponse> createPayment(List<PEPaymentRequest> requests) {
        List<AzureEventIntegration.AzureEvent> events = new List<AzureEventIntegration.AzureEvent>();
        for(PEPaymentRequest request : requests) {
            events.add(PaymentEvent(request.invoiceNumber, request.transactionType, request.amount, request.processorId, request.transId));
        }

        return new List<AzureEventIntegration.AzureResponse>{AzureEventIntegration.sendEvents(events, false)};
    }

    private static AzureEventIntegration.AzureEvent PaymentEvent(String invoiceNumber, String transactionType, Decimal amount, String processorTransId, String transId) {
        return new AzureEventIntegration.AzureEvent(
            'payment', 
            'PaymentSent', 
            'csuoee/noncredit/payment', 
            new Map<String, Object>{'provider' => (processorTransId==null)?'Opus':'Authorize.net', 'invoiceNumber' => invoiceNumber, 'typeCode' => transactionType, 'amount' => amount, 'processorTransId' => processorTransId, 'transId' => transId}
        );
    }

    global class PEPaymentRequest extends AzureEventIntegration.AzureRequest {
        @InvocableVariable(Required=true Description='Invoice to Add Payment to.')
        global String invoiceNumber;

        @InvocableVariable(Required=true Description='Transaction type added e.g. Credit Card, Check, Cash, Sponsor Payment.')
        global String transactionType;

        @InvocableVariable(Required=true Description='Payment Amount.')
        global Decimal amount;

        @InvocableVariable(Required=false Description='Processor Trans Id')
        global String processorId;

        @InvocableVariable(Required=false Description='CSU Trans Id')
        global String transId;

        global PEPaymentRequest(){super(false);}
        global PEPaymentRequest(String invoiceNumber, String transactionType, Decimal amount, String processorId) {
            super(false);
            this.invoiceNumber = invoiceNumber;
            this.transactionType = transactionType;
            this.amount = amount;
            this.processorId = processorId;
        }
        global PEPaymentRequest(String invoiceNumber, String transactionType, Decimal amount, String processorId, String transId) {
            super(false);
            this.invoiceNumber = invoiceNumber;
            this.transactionType = transactionType;
            this.amount = amount;
            this.processorId = processorId;
            this.transId = transId;
        }

    }
    
}