@RestResource(urlMapping = '/pe/registration/notification')
global class InvoiceRequestNotification {

    @HttpPost
    global static Map<String, String> sendNotification(csuoee__Noncredit_Invoice__c invoice) {
        csuoee__Marketing_Cloud_Journey_Event_Settings__c journeySettings;
        try {
            journeySettings = [select csuoee__PE_Notification_Event__c, csuoee__Invoicing_Journey_API_Key__c from csuoee__Marketing_Cloud_Journey_Event_Settings__c LIMIT 1];
        } catch(QueryException qe) {
            journeySettings = new csuoee__Marketing_Cloud_Journey_Event_Settings__c(csuoee__PE_Notification_Event__c = 'Notification', csuoee__Invoicing_Journey_API_Key__c = '');
        }

        List<csuoee__Marketing_Cloud_Journey_Event__c> journeyEvents = new List<csuoee__Marketing_Cloud_Journey_Event__c>();
        if(invoice.csuoee__Contact__c == null || journeySettings.csuoee__PE_Notification_Event__c == null) return new Map<String, String> {'success' => 'false'};
        
        csuoee__Marketing_Cloud_Journey_Event__c event = new csuoee__Marketing_Cloud_Journey_Event__c(
                csuoee__ContactWhoId__c = invoice.csuoee__Contact__c, 
                csuoee__Event_Type__c = journeySettings.csuoee__PE_Notification_Event__c, 
                csuoee__Event__c = journeySettings.csuoee__PE_Notification_Event__c,
                csuoee__Key__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c+'-'+invoice.Id+'-Notification',
                csuoee__RelatedToId__c = invoice.Id);

        try {
            insert event;
        } catch(DmlException de) {
            // Just let the caller know.
            return new Map<String, String> {'success' => 'false'};
        }
        return new Map<String, String> {'success' => 'true'};
    }
    
}