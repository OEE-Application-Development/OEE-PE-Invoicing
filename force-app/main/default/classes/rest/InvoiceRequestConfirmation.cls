@RestResource(urlMapping = '/pe/registration/confirmation')
global class InvoiceRequestConfirmation {

    @HttpPost
    global static Map<String, String> sendConfirmation(csuoee__Noncredit_Invoice__c invoice) {
        try {
            if(invoice.Id == null && invoice.csuoee__Invoice_Number__c == null) return new Map<String, String>{'success' => 'false', 'message' => 'Neither Id nor Invoice Number are present.'};
            if(invoice.Id != null) {
                invoice = [select Id, csuoee__Contact__c, csuoee__Send_Confirmation_Email__c, csuoee__Is_Completely_Fulfilled__c, csuoee__Fulfilled_Email_Sent__c from csuoee__Noncredit_Invoice__c where Id = :invoice.Id LIMIT 1];
            } else {
                invoice = [select Id, csuoee__Contact__c, csuoee__Send_Confirmation_Email__c, csuoee__Is_Completely_Fulfilled__c, csuoee__Fulfilled_Email_Sent__c from csuoee__Noncredit_Invoice__c where csuoee__Invoice_Number__c = :invoice.csuoee__Invoice_Number__c LIMIT 1];
            }
        } catch(DmlException de) {
            return new Map<String, String> {'success' => 'false', 'message' => 'Nonexistent Invoice.'};
        }

        if(invoice.csuoee__Fulfilled_Email_Sent__c) return new Map<String, String> {'success' => 'true', 'message' => 'Invoice already marked as sent.'};
        if(invoice.csuoee__Contact__c == null) return new Map<String, String> {'success' => 'false', 'message' => 'Invoice missing contact.'};

        if(invoice.csuoee__Is_Completely_Fulfilled__c == null) return new Map<String, String> {'success' => 'false', 'message' => 'Invoice not fulfilled.'};

        csuoee__Marketing_Cloud_Journey_Event_Settings__c journeySettings = [select csuoee__Invoicing_Journey_API_Key__c, csuoee__Invoicing_Journey_Confirmation_Type__c from csuoee__Marketing_Cloud_Journey_Event_Settings__c LIMIT 1];
        csuoee__Marketing_Cloud_Journey_Event__c event = new csuoee__Marketing_Cloud_Journey_Event__c(
            csuoee__ContactWhoId__c = invoice.csuoee__Contact__c, 
            csuoee__Event_Type__c = journeySettings.csuoee__Invoicing_Journey_Confirmation_Type__c, 
            csuoee__Event__c = 'Confirmation',
            csuoee__Key__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c+'-'+invoice.Id+'-Confirmation',
            csuoee__RelatedToId__c = invoice.Id
        );

        try {
            insert event;
        } catch(DmlException de) {
            // Just let the caller know.
            return new Map<String, String> {'success' => 'false', 'message' => de.getMessage()};
        }

        invoice.csuoee__Fulfilled_Email_Sent__c = true;
        update invoice;
        return new Map<String, String> {'success' => 'true', 'message' => 'Journey Event Created.'};
    }
    
}