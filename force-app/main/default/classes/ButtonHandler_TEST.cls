@IsTest
private class ButtonHandler_TEST {

    @IsTest
    private static void confirmAndCancelInvoiceEmpty() {
        csuoee__Noncredit_Invoice__c invoice = generateInvoice();
        Boolean result = false;
        //Empty Confirm
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        result = InvoiceButtonHandler.confirmInvoice(invoice.Id);
        
        System.assert(result);
        
        //Empty cancel
        result = InvoiceButtonHandler.cancelInvoice(invoice.Id);
        Test.stopTest();
        System.assert(result);
    }

    @IsTest
    private static void confirmAndCancelInvoice() {
        csuoee__Noncredit_Invoice__c invoice = generateInvoice();
        csuoee__Noncredit_Invoice_Line_Item__c li = generateLineItem(invoice);
        Boolean result = false;
        
        //Empty Confirm
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        
        //Sneak the email test in there.
        List<EmailMessage> msgs = InvoiceEmailMessageHandler.getInvoiceEmails(invoice.Id);
        System.assert(msgs.isEmpty());

        //Confirm 1
        result = InvoiceButtonHandler.confirmInvoice(invoice.Id);
        
        System.assert(result);
        
        //Cancel 1
        result = InvoiceButtonHandler.cancelInvoice(invoice.Id);
        Test.stopTest();

        System.assert(result);
    }

    @IsTest
    private static void confirmLineItem() {
        csuoee__Noncredit_Invoice_Line_Item__c li = generateLineItem();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        Boolean result = LineItemButtonHandler.confirmLineItem(li.Id);
        Test.stopTest();

        System.assert(result);
    }

    @IsTest
    private static void voidLineItem() {
        csuoee__Noncredit_Invoice_Line_Item__c li = generateLineItem();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        Boolean result = LineItemButtonHandler.voidLineItem(li.Id);
        Test.stopTest();

        System.assert(result);
    }

    @IsTest
    private static csuoee__Noncredit_Invoice_Line_Item__c generateLineItem() {
        csuoee__Noncredit_Invoice__c invoice = generateInvoice();
        return generateLineItem(invoice);
    }

    private static csuoee__Noncredit_Invoice_Line_Item__c generateLineItem(csuoee__Noncredit_Invoice__c invoice) {
        csuoee__Noncredit_Invoice_Line_Item__c lineItem = new csuoee__Noncredit_Invoice_Line_Item__c(csuoee__Noncredit_Invoice__c = invoice.Id, csuoee__Noncredit_Invoice__r = invoice, csuoee__Section_Reference__c = '1111SP-AAA-222-100', csuoee__Line_Item_Amount__c = 120);
        insert lineItem;
        return lineItem;
    }

    @IsTest
    private static csuoee__Noncredit_Invoice__c generateInvoice() {
        Account testAccount = new Account(Name = 'Test Administrative');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'Test', csuoee__Noncredit_ID__c = 'user.1234', AccountId = testAccount.Id);
        insert testContact;
        csuoee__Noncredit_Invoice__c invoice = new csuoee__Noncredit_Invoice__c(csuoee__Invoice_Number__c = '1111', csuoee__Registration_Id__c = '1111', csuoee__Contact__c = testContact.Id, csuoee__Payer_Account__c = testContact.AccountId);
        insert invoice;

        return invoice;
    }

}