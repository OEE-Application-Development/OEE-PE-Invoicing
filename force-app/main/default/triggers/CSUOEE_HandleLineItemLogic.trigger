trigger CSUOEE_HandleLineItemLogic on csuoee__Noncredit_Invoice_Line_Item__c (before insert, before update) {
    for(csuoee__Noncredit_Invoice_Line_Item__c li : (List<csuoee__Noncredit_Invoice_Line_Item__c>)Trigger.new) {
        if(li.csuoee__Line_Item_Amount__c > 0)li.csuoee__Line_Item_Amount__c = li.csuoee__Line_Item_Amount__c*-1;
    }
}