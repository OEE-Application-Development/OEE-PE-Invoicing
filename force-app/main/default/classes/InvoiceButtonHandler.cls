global with sharing class InvoiceButtonHandler {
    private static csuoee__Noncredit_Invoice__c getInvoiceById(Id invoiceId) {
        return [select Id, csuoee__Noncredit_ID__c, (select Id, csuoee__Is_Confirmed__c, csuoee__Section_Reference__c from csuoee__Noncredit_Invoice_Line_Items__r) from csuoee__Noncredit_Invoice__c where Id = :invoiceId LIMIT 1];
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
            invoice.csuoee__Is_Cancelled__c = true;
            update invoice;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return true;
    }

}