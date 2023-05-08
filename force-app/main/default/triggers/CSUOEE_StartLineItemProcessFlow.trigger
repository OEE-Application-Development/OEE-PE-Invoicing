trigger CSUOEE_StartLineItemProcessFlow on csuoee__Noncredit_Invoice_Line_Item__c (after insert) {
    for(csuoee__Noncredit_Invoice_Line_Item__c li : (List<csuoee__Noncredit_Invoice_Line_Item__c>)Trigger.new) {
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('LineItemInProgress', li);

        if(!li.csuoee__Is_Actual__c)continue;//Don't track sponsor invoices the same way.
        if(li.csuoee__Is_Credit_Line_Item__c)continue;//Different process for credit
        Flow.Interview.Noncredit_Line_Item_Process handleLineItemFlow = new Flow.Interview.Noncredit_Line_Item_Process(inputMap);
        handleLineItemFlow.start();
    }
}