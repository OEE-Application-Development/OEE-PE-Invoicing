public without sharing class InvoiceEmailMessageHandler {
    
    @AuraEnabled(cacheable = true)
    public static List<EmailMessage> getInvoiceEmails(Id invoiceId) {
        try {
            List<EmailMessage> messages = [select Id, Subject, csuoee__Has_Been_Opened__c from EmailMessage order by LastModifiedDate desc];
            return messages;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}