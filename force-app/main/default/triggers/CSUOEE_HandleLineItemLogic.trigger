trigger CSUOEE_HandleLineItemLogic on csuoee__Noncredit_Invoice_Line_Item__c (before insert, before update) {
    for(csuoee__Noncredit_Invoice_Line_Item__c li : (List<csuoee__Noncredit_Invoice_Line_Item__c>)Trigger.new) {
        if(li.csuoee__Line_Item_Amount__c > 0)li.csuoee__Line_Item_Amount__c = li.csuoee__Line_Item_Amount__c*-1;

        if(li.csuoee__Is_Confirmed__c) {
            if(li.csuoee__Confirmed_At__c == null) {
                li.csuoee__Confirmed_At__c = Datetime.now();
            }
        }
        if(li.csuoee__Canvas_Enrollment__c != null) {
            if(li.csuoee__Fulfilled_At__c == null) {
                li.csuoee__Fulfilled_At__c = Datetime.now();
            }
        }
    }
}