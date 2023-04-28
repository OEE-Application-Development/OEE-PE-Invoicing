global with sharing class PEInvoiceRequestEvent {
    @InvocableMethod(Label='Create Invoice Request Event' Description='Sends an invoice request to grid to be added to Opus.')
    global static List<AzureEventIntegration.AzureResponse> createInvoiceRequest(List<PEInvoiceRequest> requests) {
        List<AzureEventIntegration.AzureEvent> events = new List<AzureEventIntegration.AzureEvent>();
        for(PEInvoiceRequest request : requests) {
            events.add(PaymentEvent(request.invoiceNumber, request.amount, request.userId));
        }

        return new List<AzureEventIntegration.AzureResponse>{AzureEventIntegration.sendEvents(events, false)};
    }

    private static AzureEventIntegration.AzureEvent PaymentEvent(String invoiceNumber, Decimal amount, String userId) {
        return new AzureEventIntegration.AzureEvent(
            'payment', 
            'InvoiceRequest', 
            'csuoee/noncredit/payment', 
            new Map<String, Object>{'invoiceNumber' => invoiceNumber, 'userId' => userId, 'amount' => amount}
        );
    }

    global class PEInvoiceRequest extends AzureEventIntegration.AzureRequest {
        @InvocableVariable(Required=true Description='Invoice to Add Sponsor Payment to.')
        global String invoiceNumber;

        @InvocableVariable(Required=true Description='Payment Amount.')
        global Decimal amount;

        @InvocableVariable(Required=true Description='Noncredit ID for the user')
        global String userId;

        global PEInvoiceRequest(String invoiceNumber, Decimal amount, String userId) {
            super(false);
            this.invoiceNumber = invoiceNumber;
            this.amount = amount;
            this.userId = userId;
        }

    }
    
}