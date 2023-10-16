global with sharing class GetTransactionsOnInvoice {
    @InvocableMethod(Label='GetTransactionsOnInvoice' Description = 'Ask Middleware to find all transactions for invoice.' Category = 'Middleware Operation')
    global static List<List<csuoee__Noncredit_Invoice_Payment__c>> getTransactionsOnInvoice(List<String> invoiceIds) {
        Map<String, Id> invoiceIdMap = getInvoiceIdMap(invoiceIds);

        List<List<csuoee__Noncredit_Invoice_Payment__c>> results = new List<List<csuoee__Noncredit_Invoice_Payment__c>>();
        for(String invoiceId : invoiceIds) {
            List<csuoee__Noncredit_Invoice_Payment__c> payments = new List<csuoee__Noncredit_Invoice_Payment__c>();
            MiddlewareActionTxResponse txResponse = InvoiceButtonHandler.getTransactionList(invoiceId);
            Id invID = invoiceIdMap.get(invoiceId);
            if(txResponse.httpStatus >=200 && txResponse.httpStatus < 300) {
                if(txResponse.success) {
                    for(MiddlewareTransactionResponse tx : txResponse.data) {
                        payments.add(new csuoee__Noncredit_Invoice_Payment__c(
                            csuoee__Amount__c = tx.amount,
                            csuoee__CSU_Trans_Id__c = tx.csuTransId,
                            csuoee__Payment_Type__c = tx.paymentType,
                            csuoee__Is_Actual__c = tx.isActual,
                            csuoee__Noncredit_Invoice__c = invID,
                            //csuoee__Posted_At__c = (tx.postedAt==null || ''.equals(tx.postedAt))?null:Datetime.parse(tx.postedAt),
                            csuoee__Posted_At__c = tx.postedAt,
                            csuoee__Processor_Trans_Id__c = tx.processorTransId,
                            csuoee__Processor_Trans_Status__c = tx.processorTransStatus,
                            csuoee__Successful__c = tx.isSuccessful,
                            csuoee__Failure_Reason__c = tx.failureReason
                        ));
                    }
                }
            }
        }
        
        upsertAll(results);
        return results;
    }

    private static Map<String, Id> getInvoiceIdMap(List<String> invoiceNumbers) {
        Map<String, Id> idMap = new Map<String, Id>();
        for(csuoee__Noncredit_Invoice__c inv : [select Id, csuoee__Invoice_Number__c from csuoee__Noncredit_Invoice__c where csuoee__Invoice_Number__c in :invoiceNumbers]) {
            idMap.put(inv.csuoee__Invoice_Number__c, inv.Id);
        }
        return idMap;
    }

    private static void upsertAll(List<List<csuoee__Noncredit_Invoice_Payment__c>> allPayments) {
        List<csuoee__Noncredit_Invoice_Payment__c> all = new List<csuoee__Noncredit_Invoice_Payment__c>();
        for(List<csuoee__Noncredit_Invoice_Payment__c> payList : allPayments) {
            all.addAll(payList);
        }
        Database.upsert(all, csuoee__Noncredit_Invoice_Payment__c.CSU_Trans_Id__c, false);
    }
}