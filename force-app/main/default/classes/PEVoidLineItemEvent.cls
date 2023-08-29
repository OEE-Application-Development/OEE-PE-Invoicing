global with sharing class PEVoidLineItemEvent {
    @InvocableMethod(Label='Void Unconfirmed Line Item' Description='Cancel a line item on an Invoice/Registration.')
    global static List<AzureEventIntegration.AzureResponse> voidLineItem(List<PEVoidLineItemRequest> requests) {
        List<AzureEventIntegration.AzureEvent> events = new List<AzureEventIntegration.AzureEvent>();
        for(PEVoidLineItemRequest request : requests) {
            events.add(VoidLineItemEvent(request.invoiceNumber, request.lineItemId));
        }

        return new List<AzureEventIntegration.AzureResponse>{AzureEventIntegration.sendEvents(events, false)};
    }

    private static AzureEventIntegration.AzureEvent VoidLineItemEvent(String invoiceNumber, String lineItemId) {
        return new AzureEventIntegration.AzureEvent(
            'registration', 
            'Void', 
            'csuoee/noncredit/registration', 
            new Map<String, Object>{'invoiceNumber' => invoiceNumber, 'id' => lineItemId}
        );
    }

    global class PEVoidLineItemRequest extends AzureEventIntegration.AzureRequest {
        @InvocableVariable(Required=true Description='Invoice to Void line item on.')
        global String invoiceNumber;

        @InvocableVariable(Required=true Description='Line Item to Cancel')
        global String lineItemId;

        global PEVoidLineItemRequest(String invoiceNumber, String lineItemId) {
            super(false);
            this.invoiceNumber = invoiceNumber;
            this.lineItemId = lineItemId;
        }

    }
}