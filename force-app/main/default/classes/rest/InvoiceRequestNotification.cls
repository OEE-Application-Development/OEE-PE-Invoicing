@RestResource(urlMapping = '/pe/registration/notification')
global class InvoiceRequestNotification {

    @HttpPost
    global static Map<String, String> sendNotification(csuoee__Noncredit_Invoice__c invoice) {
        try {
            if(invoice.Id == null && invoice.csuoee__Invoice_Number__c == null) return new Map<String, String>{'success' => 'false', 'message' => 'Neither Id nor Invoice Number are present.'};
            if(invoice.Id != null) {
                invoice = [select Id, csuoee__Contact__c, csuoee__Send_Confirmation_Email__c, csuoee__Fulfilled_Email_Sent__c, csuoee__Registration_Method__c from csuoee__Noncredit_Invoice__c where Id = :invoice.Id LIMIT 1];
            } else {
                invoice = [select Id, csuoee__Contact__c, csuoee__Send_Confirmation_Email__c, csuoee__Fulfilled_Email_Sent__c, csuoee__Registration_Method__c from csuoee__Noncredit_Invoice__c where csuoee__Invoice_Number__c = :invoice.csuoee__Invoice_Number__c LIMIT 1];
            }
        } catch(DmlException de) {
            return new Map<String, String> {'success' => 'false', 'message' => 'Nonexistent Invoice.'};
        }
        csuoee__Marketing_Cloud_Journey_Event_Settings__c journeySettings;
        try {
            journeySettings = [select csuoee__PE_Notification_Event__c, csuoee__Invoicing_Journey_API_Key__c from csuoee__Marketing_Cloud_Journey_Event_Settings__c LIMIT 1];
        } catch(QueryException qe) {
            journeySettings = new csuoee__Marketing_Cloud_Journey_Event_Settings__c(csuoee__PE_Notification_Event__c = 'Notification', csuoee__Invoicing_Journey_API_Key__c = '');
        }

        List<csuoee__Marketing_Cloud_Journey_Event__c> journeyEvents = new List<csuoee__Marketing_Cloud_Journey_Event__c>();
        if(invoice.csuoee__Contact__c == null || journeySettings.csuoee__PE_Notification_Event__c == null) return new Map<String, String> {'success' => 'false'};
        
        String eventType = journeySettings.csuoee__PE_Notification_Event__c;
        if(invoice.csuoee__Registration_Method__c == 'Online - Sponsor') eventType = 'Sponsor ' + eventType;
        csuoee__Marketing_Cloud_Journey_Event__c event = new csuoee__Marketing_Cloud_Journey_Event__c(
                csuoee__ContactWhoId__c = invoice.csuoee__Contact__c, 
                csuoee__Event_Type__c = eventType, 
                csuoee__Event__c = journeySettings.csuoee__PE_Notification_Event__c,
                csuoee__Key__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c+'-'+invoice.Id+'-Notification',
                csuoee__RelatedToId__c = invoice.Id);

        try {
            insert event;
        } catch(DmlException de) {
            // Just let the caller know.
            return new Map<String, String> {'success' => 'false', 'message' => de.getMessage()};
        }
        return new Map<String, String> {'success' => 'true', 'message' => 'Journey Event Created.'};
    }
    
}