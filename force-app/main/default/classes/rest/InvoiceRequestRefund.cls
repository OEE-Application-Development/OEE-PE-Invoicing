@RestResource(urlMapping = '/pe/registration/refund')
global class InvoiceRequestRefund {

    @HttpPost
    global static Map<String, String> sendRefund(csuoee__Noncredit_Invoice__c invoice, csuoee__Noncredit_Invoice_Payment__c refund) {
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

        if(invoice.csuoee__Contact__c == null) return new Map<String, String> {'success' => 'false', 'message' => 'Invoice missing contact.'};

        try {
            refund = [SELECT Id, csuoee__Amount__c, csuoee__CSU_Trans_Id__c, csuoee__Processor_Trans_Id__c, csuoee__Successful__c, csuoee__Processor_Trans_Status__c, csuoee__Payment_Type__c FROM csuoee__Noncredit_Invoice_Payment__c WHERE csuoee__CSU_Trans_Id__c = :refund.csuoee__CSU_Trans_Id__c OR csuoee__Processor_Trans_Id__c = :refund.csuoee__Processor_Trans_Id__c LIMIT 1];
        } catch(DmlException de) {
            return new Map<String, String> {'success' => 'false', 'message' => 'Nonexistent Tx.'};
        }

        csuoee__Marketing_Cloud_Journey_Event_Settings__c journeySettings = [select csuoee__Invoicing_Journey_API_Key__c, csuoee__Invoicing_Journey_Confirmation_Type__c from csuoee__Marketing_Cloud_Journey_Event_Settings__c LIMIT 1];
        csuoee__Marketing_Cloud_Journey_Event__c event = new csuoee__Marketing_Cloud_Journey_Event__c(
            csuoee__ContactWhoId__c = invoice.csuoee__Contact__c, 
            csuoee__Event_Type__c = 'Refund', 
            csuoee__Event__c = 'Payment',
            csuoee__Key__c = journeySettings.csuoee__Invoicing_Journey_API_Key__c+'-'+invoice.Id+'-Refund',
            csuoee__RelatedToId__c = invoice.Id,
            csuoee__Data1__c = refund.csuoee__Processor_Trans_Id__c,
            csuoee__Data2__c = String.valueOf(refund.csuoee__Amount__c)
        );
        
        return new Map<String, String> {'success' => 'true', 'message' => 'Journey Event Created.'};
    }
    
}