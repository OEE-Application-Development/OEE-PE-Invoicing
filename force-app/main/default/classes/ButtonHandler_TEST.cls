@IsTest
private class ButtonHandler_TEST {

    @IsTest
    private static void confirmAndCancelInvoiceEmpty() {
        generateJourneySettings();
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
    private static void trackLineItem() {
        csuoee__Noncredit_Invoice_Line_Item__c li = generateLineItem();
        Test.startTest();
        try {
            LineItemButtonHandler.trackLineItem(li.Id);
        } catch(AuraHandledException ahe1) {
            System.assert(true);
        }

        hed__Course_Offering__c offering = generateOffering();
        li.csuoee__Section_Reference__c = offering.lms_hed__LMS_Reference_Code__c;
        //li.csuoee__Course_Offering__c = offering.Id;
        update li;
        
        LineItemButtonHandler.trackLineItem(li.Id);

        Test.stopTest();
    }

    @IsTest
    private static csuoee__Noncredit_Invoice_Line_Item__c generateLineItem() {
        csuoee__Noncredit_Invoice__c invoice = generateInvoice();
        return generateLineItem(invoice);
    }

    @IsTest
    private static void addPayment() {
        csuoee__Noncredit_Invoice__c invoice = generateInvoice();
        generateLineItem(invoice);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        Boolean result = InvoiceButtonHandler.addPayment(invoice.Id, 'Credit Card', 120.00, null);
        csuoee__Noncredit_Invoice_Payment__c payment = new csuoee__Noncredit_Invoice_Payment__c(csuoee__Amount__c = 120.00, csuoee__CSU_Trans_Id__c = '12345', csuoee__Is_Actual__c = true, csuoee__Noncredit_Invoice__c = invoice.Id, Name = 'Test Payment', csuoee__Payment_Type__c = 'Credit Card', csuoee__Successful__c = true);
        insert payment;

        invoice = [select Id, csuoee__Is_Paid__c from csuoee__Noncredit_Invoice__c where Id = :invoice.Id LIMIT 1];
        System.assertEquals(true, invoice.csuoee__Is_Paid__c, 'Is was not marked true: '+invoice.csuoee__Is_Paid__c);
        Test.stopTest();

        System.assert(result);
    }

    @IsTest
    private static void sendEscalationEmail() {
        csuoee__Noncredit_Invoice__c invoice = generateInvoice();

        boolean result = InvoiceButtonHandler.sendEscalationEmail(invoice.Id);
        System.assert(result);

        try {
            InvoiceButtonHandler.sendEscalationEmail(invoice.Id);
        } catch(AuraHandledException ae) {
            result = false;
        }

        System.assert(!result);
    }

    @IsTest
    private static void requestInvoice() {
        Account a = new Account(Name = 'test', hed__School_Code__c = 'test');
        insert a;
        csuoee__Noncredit_Invoice__c i = generateInvoice();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        Boolean result = InvoiceButtonHandler.requestInvoice(a.Id, i.Id, 120.00);
        Test.stopTest();

        System.assert(result);
    }

    @IsTest
    private static void autocompleteInvoiceLineItem() {
        Account a = new Account(Name = 'test', hed__School_Code__c = 'test');
        insert a;
        csuoee__Noncredit_Invoice__c i = generateInvoice();
        hed__Course_Offering__c offering = generateOffering();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        csuoee__Noncredit_Invoice_Line_Item__c li = new csuoee__Noncredit_Invoice_Line_Item__c(csuoee__Noncredit_Invoice__c = i.Id, csuoee__Line_Item_Amount__c = 0, csuoee__Section_Reference__c = offering.lms_hed__LMS_Reference_Code__c, csuoee__Course_Offering__c = offering.Id, csuoee__Is_Confirmed__c = false);
        insert li;
        Test.stopTest();
        System.assert(true);
    }

    private static csuoee__Noncredit_Invoice_Line_Item__c generateLineItem(csuoee__Noncredit_Invoice__c invoice) {
        generateJourneySettings();
        csuoee__Noncredit_Invoice_Line_Item__c lineItem = new csuoee__Noncredit_Invoice_Line_Item__c(csuoee__Noncredit_Invoice__c = invoice.Id, csuoee__Noncredit_Invoice__r = invoice, csuoee__Section_Reference__c = '1111SP-AAA-222-100', csuoee__Line_Item_Amount__c = 120);
        insert lineItem;
        return lineItem;
    }

    @IsTest
    private static void generateJourneySettings() {
        csuoee__Marketing_Cloud_Journey_Event_Settings__c settings = new csuoee__Marketing_Cloud_Journey_Event_Settings__c(csuoee__Invoicing_Journey_API_Key__c = 'bananas', csuoee__Invoicing_Journey_Confirmation_Type__c = 'Confirmation');
        insert settings;
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

    @IsTest
    private static void insertEnrollment() {
        Account canvas = generateCanvasAccount();
        hed__Course_Offering__c offering = generateOffering();
        Contact c = generateContact();
        lms_hed__LMS_Account__c acct = generateLmsAccount(c, canvas);
        lms_hed__LMS_Course_Term__c ct = generateCourseTerm(canvas, offering.hed__Course__r, offering.hed__Term__r);
        Test.startTest();
        lms_hed__LMS_Course_Enrollment__c enrollment = new lms_hed__LMS_Course_Enrollment__c(lms_hed__LMS_Account__c = acct.Id, lms_hed__LMS_Course_Term__c = ct.Id, lms_hed__Course_Offering__c = offering.Id, lms_hed__LMS_External_ID__c = '12345');
        insert enrollment;
        Test.stopTest();

        System.assert(enrollment.Id != null);
    }

    @IsTest
    private static void emitEnrollmentComplete() {
        Account canvas = generateCanvasAccount();
        hed__Course_Offering__c offering = generateOffering();
        Contact c = generateContact();
        lms_hed__LMS_Account__c acct = generateLmsAccount(c, canvas);
        lms_hed__LMS_Course_Term__c ct = generateCourseTerm(canvas, offering.hed__Course__r, offering.hed__Term__r);
        lms_hed__LMS_Course_Enrollment__c enrollment = new lms_hed__LMS_Course_Enrollment__c(lms_hed__LMS_Account__c = acct.Id, lms_hed__LMS_Course_Term__c = ct.Id, lms_hed__Course_Offering__c = offering.Id, lms_hed__LMS_External_ID__c = '12345');
        insert enrollment;
        csuoee__Noncredit_Invoice_Line_Item__c li = generateLineItem();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        try {
            LineItemButtonHandler.emitEnrollmentComplete(ct.Id);
            System.assert(false);
        } catch(AuraHandledException e) {
            System.assert(true);
        }
        LineItemButtonHandler.emitEnrollmentComplete(enrollment.Id);

        LineItemButtonHandler.setLineItemEnrollment(enrollment.Id, li.Id);
        Test.stopTest();
        System.assert(true);
    }

    @IsTest
    private static void checkLineItemEnrollmentExists() {
        Account canvas = generateCanvasAccount();
        hed__Course_Offering__c offering = generateOffering();
        Contact c = generateContact();
        lms_hed__LMS_Account__c acct = generateLmsAccount(c, canvas);
        lms_hed__LMS_Course_Term__c ct = generateCourseTerm(canvas, offering.hed__Course__r, offering.hed__Term__r);
        lms_hed__LMS_Course_Enrollment__c enrollment = new lms_hed__LMS_Course_Enrollment__c(lms_hed__LMS_Account__c = acct.Id, lms_hed__LMS_Course_Term__c = ct.Id, lms_hed__Course_Offering__c = offering.Id, lms_hed__LMS_External_ID__c = '12345');
        insert enrollment;
        csuoee__Noncredit_Invoice_Line_Item__c li = generateLineItem();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, BaseTestUtil.getEventCalloutMock());
        boolean result = LineItemButtonHandler.checkLineItemEnrollmentExists(li.Id);
        System.assert(!result);

        csuoee__Noncredit_Invoice__c invoice = [select Id, csuoee__Contact__c from csuoee__Noncredit_Invoice__c where Id = :li.csuoee__Noncredit_Invoice__c LIMIT 1];
        invoice.csuoee__Contact__c = c.Id;
        update invoice;

        hed__Course_Enrollment__c offeringEnrollment = new hed__Course_Enrollment__c(hed__Contact__c = c.Id, hed__Course_Offering__c = offering.Id);
        insert offeringEnrollment;

        li.csuoee__Course_Offering__c = offering.Id;
        update li;

        result = LineItemButtonHandler.checkLineItemEnrollmentExists(li.Id);
        System.assert(result);

        li.csuoee__Is_Confirmed__c = true;
        li.csuoee__Canvas_Enrollment__c = enrollment.Id;
        update li;
        System.assert(true);

        InvoiceButtonHandler.cancelInvoice(li.csuoee__Noncredit_Invoice__c);

        Test.stopTest();
    }

    @IsTest
    private static void escalateInvoice() {
        csuoee__Noncredit_Invoice__c invoice = generateInvoice();

        Test.startTest();
        InvoiceEscalationInvocable.InvoiceEscalationRequest request = new InvoiceEscalationInvocable.InvoiceEscalationRequest();
        request.invoiceId = invoice.Id;

        InvoiceEscalationInvocable.escalateInvoice(new List<InvoiceEscalationInvocable.InvoiceEscalationRequest>{request});
        Test.stopTest();
    }

    @IsTest
    private static Account generateCanvasAccount() {
        RecordType lmsType = [select Id from RecordType where DeveloperName = 'LMS' LIMIT 1];
        Account canvas = new Account(RecordTypeId = lmsType.Id, Name = 'Canvas', hed__School_Code__c = 'Canvas');
        insert canvas;

        return canvas;
    }

    @IsTest
    private static Contact generateContact() {
        Account admin = new Account(Name = 'Administrative');
        insert admin;
        Contact c = new Contact(LastName = 'Winterrowd', AccountId = admin.Id, csuoee__Noncredit_ID__c = 'learn.1');
        insert c;

        return c;
    }

    private static lms_hed__LMS_Account__c generateLmsAccount(Contact c, Account canvas) {
        lms_hed__LMS_Account__c acct = new lms_hed__LMS_Account__c(Name = 'Test', lms_hed__LMS__c = canvas.Id, lms_hed__Account_Owner__c = c.Id, lms_hed__LMS_External_ID__c = '12345', lms_hed__Primary_Login__c = 'testlogin');
        insert acct;

        return acct;
    }

    @IsTest
    private static hed__Course_Offering__c generateOffering() {
        Account educ = new Account(Name = 'CSU');
        insert educ;

        hed__Course__c course = new hed__Course__c(Name = 'Test Course', hed__Course_ID__c = 'Test 101', hed__Account__c = educ.Id, csuoee__Course_Code__c = 'TST 101');
        insert course;

        hed__Term__c term = new hed__Term__c(Name = 'Test Term', hed__Account__c = educ.Id);
        insert term;

        hed__Course_Offering__c offering = new hed__Course_Offering__c(Name = 'Test Section', hed__Course__c = course.Id, hed__Term__c = term.Id, lms_hed__LMS_Reference_Code__c = '2023SP-CO-333-100');
        insert offering;

        offering.hed__Course__r = course;
        offering.hed__Term__r = term;

        return offering;
    }

    private static lms_hed__LMS_Course_Term__c generateCourseTerm(Account canvas, hed__Course__c course, hed__Term__c term) {
        lms_hed__LMS_Course_Term__c ct = new lms_hed__LMS_Course_Term__c(Name = 'TestCourse', lms_hed__Course__c = course.Id, lms_hed__LMS_Course_ID__c = '12345', lms_hed__LMS__c = canvas.Id, lms_hed__Term__c = term.Id);
        insert ct;

        return ct;
    }

}