trigger CSUOEE_StartLineItemProcessFlow on csuoee__Noncredit_Invoice_Line_Item__c (after insert) {
    for(csuoee__Noncredit_Invoice_Line_Item__c li : (List<csuoee__Noncredit_Invoice_Line_Item__c>)Trigger.new) {

        if(!li.csuoee__Is_Actual__c)continue;//Don't track sponsor invoices the same way.
        if(li.csuoee__Is_Credit_Line_Item__c)continue;//Different process for credit
        if(String.isBlank(li.csuoee__Course_Offering__c))continue;//Process isn't ready - we don't have the seed data.
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('LineItemInProgress', li);
        Flow.Interview.createInterview('csuoee', 'Noncredit_Line_Item_Process', inputMap).start();
    }
}