global with sharing class InvoiceEscalationInvocable {
    @InvocableMethod(Label='Escalate Invoice' Description='Sends an escalation email & marks the invoice as escalated.')
    global static void escalateInvoice(List<InvoiceEscalationRequest> requests) {
        for(InvoiceEscalationRequest request : requests) {
            InvoiceButtonHandler.sendEscalationEmail(request.invoiceId);
        }
    }

    global class InvoiceEscalationRequest {
        @InvocableVariable(Required=true Description='ID of the invoice to escalate.')
        global Id invoiceId;
    }
}