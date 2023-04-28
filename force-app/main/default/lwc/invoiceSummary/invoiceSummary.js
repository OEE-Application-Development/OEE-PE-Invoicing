import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import paymentModal from "c/addPaymentModal";
import datatableHelpers from "c/datatableHelpers";
import modalAlert from "c/modalAlert";

/* Invoice */
import requestInvoice from '@salesforce/apex/InvoiceButtonHandler.requestInvoice';
import INVOICE_NUMBER from '@salesforce/schema/Noncredit_Invoice__c.Invoice_Number__c';
import REGISTRATION_NUMBER from '@salesforce/schema/Noncredit_Invoice__c.Registration_Id__c';
import NONCREDIT_ID from '@salesforce/schema/Noncredit_Invoice__c.Noncredit_Id__c';
import PAYER_ACCOUNT from '@salesforce/schema/Noncredit_Invoice__c.Payer_Account__c';
import COST_TOTAL from '@salesforce/schema/Noncredit_Invoice__c.Total_Amount__c';
import PAYMENT_TOTAL from '@salesforce/schema/Noncredit_Invoice__c.Total_Paid__c';

import IS_PAID from '@salesforce/schema/Noncredit_Invoice__c.Is_Paid__c';
import IS_CONFIRMED from '@salesforce/schema/Noncredit_Invoice__c.Is_Completely_Confirmed__c';
import IS_FULFILLED from '@salesforce/schema/Noncredit_Invoice__c.Is_Completely_Fulfilled__c';
import HAS_FAILED_PAYMENTS from '@salesforce/schema/Noncredit_Invoice__c.Has_Failed_Payments__c';

/* Line Items */
import LINE_ITEM_SECTION_REFERENCE from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Section_Reference__c';
import LINE_ITEM_AMOUNT from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Line_Item_Amount__c';
import LINE_ITEM_CANVAS_LINK from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Course_Offering__r.Canvas_Link__c';

/* Payments */
import sendPayment from '@salesforce/apex/InvoiceButtonHandler.addPayment';
import PAYMENT_NAME from '@salesforce/schema/Noncredit_Invoice_Payment__c.Name';
import PAYMENT_TYPE from '@salesforce/schema/Noncredit_Invoice_Payment__c.Payment_Type__c';
import PAYMENT_AMOUNT from '@salesforce/schema/Noncredit_Invoice_Payment__c.Amount__c';
import PAYMENT_SUCCESS from '@salesforce/schema/Noncredit_Invoice_Payment__c.Successful__c';

/* Email */
import getInvoiceEmails from '@salesforce/apex/InvoiceEmailMessageHandler.getInvoiceEmails';
import EMAIL_SUBJECT from '@salesforce/schema/EmailMessage.Subject';
import EMAIL_HAS_BEEN_OPENED from '@salesforce/schema/EmailMessage.Has_Been_Opened__c';

const allFields = [INVOICE_NUMBER, REGISTRATION_NUMBER, IS_PAID, IS_CONFIRMED, IS_FULFILLED, HAS_FAILED_PAYMENTS, NONCREDIT_ID, PAYER_ACCOUNT, COST_TOTAL, PAYMENT_TOTAL];
const noPayments = [{'csuoee__Amount__c' : 'No Payments'}];
export default class InvoiceSummary extends NavigationMixin(LightningElement) {
    invoiceFields = [ INVOICE_NUMBER, REGISTRATION_NUMBER, NONCREDIT_ID, PAYER_ACCOUNT, COST_TOTAL, PAYMENT_TOTAL ];

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: allFields })
    invoice;

    /* Line Items */
    lineItemColumns = [
        {label: 'Section Reference', fieldName: LINE_ITEM_SECTION_REFERENCE.fieldApiName, type: 'text'},
        {label: 'Amount', fieldName: LINE_ITEM_AMOUNT.fieldApiName, type: 'currency'},
        {label: 'Canvas Link', fieldName: LINE_ITEM_CANVAS_LINK.fieldApiName, type: 'url'},
        {label: '', type: 'button', typeAttributes: {label: 'Review Line Item', name: 'reviewLineItem'}, cellAttributes: {alignment: 'center'}}
    ];
    lineItemData = [];
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'csuoee__Noncredit_Invoice_Line_Items__r',
        fields: ['id', LINE_ITEM_SECTION_REFERENCE.objectApiName+'.'+LINE_ITEM_SECTION_REFERENCE.fieldApiName, LINE_ITEM_AMOUNT.objectApiName+'.'+LINE_ITEM_AMOUNT.fieldApiName, LINE_ITEM_CANVAS_LINK.objectApiName+'.'+LINE_ITEM_CANVAS_LINK.fieldApiName]
    })
    relatedLineItems({error, data}) {
        if(data) {
            this.lineItemData = datatableHelpers.parseFieldData(this.lineItemColumns, data);
        }
    }

    handleLineItemAction(event) {
        if(event.detail.action.name == 'reviewLineItem') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Noncredit_Invoice_Line_Item__c',
                    actionName: 'view',
                    recordId: event.detail.row.id
                }
            });
        }
    }

    /* Payments */
    paymentColumns = [
        {label: 'Payment', fieldName: PAYMENT_NAME.fieldApiName, type: 'text'},
        {label: 'Payment Type', fieldName: PAYMENT_TYPE.fieldApiName, type: 'text'},
        {label: 'Successful', fieldName: PAYMENT_SUCCESS.fieldApiName, type: 'boolean'},
        {label: 'Amount', fieldName: PAYMENT_AMOUNT.fieldApiName, type: 'currency', cellAttributes: { alignment: 'left' }}
    ];
    paymentData = [];
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'csuoee__Payments__r',
        fields: ['id', PAYMENT_NAME.objectApiName+'.'+PAYMENT_NAME.fieldApiName, PAYMENT_TYPE.objectApiName+'.'+PAYMENT_TYPE.fieldApiName, PAYMENT_SUCCESS.objectApiName+'.'+PAYMENT_SUCCESS.fieldApiName, PAYMENT_AMOUNT.objectApiName+'.'+PAYMENT_AMOUNT.fieldApiName]
    })
    relatedPayments({error, data}) {
        if(data) {
            this.paymentData = datatableHelpers.parseFieldData(this.paymentColumns, data);
        } else {
            this.paymentData = noPayments;
        }
    }

    /* Emails */
    emailColumns = [
        {label: 'Subject', fieldName: EMAIL_SUBJECT.fieldApiName, type: 'text'},
        {label: 'Has Been Opened', fieldName: EMAIL_HAS_BEEN_OPENED.fieldApiName, type: 'boolean'}
    ];
    emailData = [];
    @wire(getInvoiceEmails, {
        invoiceId: '$recordId'
    })
    relatedEmails({error, data}) {
        if(data) {
            this.emailData = data;
        }
    }
    
    /* Invoice Stage */
    get invoiceStep() {
        let isPaid = getFieldValue(this.invoice.data, IS_PAID);
        if(isPaid) {
            let isConfirmed = getFieldValue(this.invoice.data, IS_CONFIRMED);
            if(isConfirmed) {
                let isFulfilled = getFieldValue(this.invoice.data, IS_FULFILLED);
                if(isFulfilled) {
                    return "4";
                } else {
                    return "3";
                }
            } else {
                return "2";
            }
        } else {
            return "1";
        }
    }

    /* Currently - only error is failed payment && not yet paid */
    get invoiceError() {
        let isPaid = getFieldValue(this.invoice.data, IS_PAID);
        let isConfirmed = getFieldValue(this.invoice.data, IS_CONFIRMED);
        if(!isPaid && !isConfirmed) {
            let hasFailedPayment = getFieldValue(this.invoice.data, HAS_FAILED_PAYMENTS);
            if(hasFailedPayment) {
                return true;
            }
        }

        return false;
    }

    runAddPayment() {
        paymentModal.open({size: 'small', invoiceId: this.invoice.data.id, defaultAmount: (this.invoice.data.fields.csuoee__Total_Amount__c.value - this.invoice.data.fields.csuoee__Total_Paid__c.value)})
            .then((result) => {
                if(result.ok) {
                    if(result.isSponsor) {
                        requestInvoice({accountId: result.account, invoiceId: this.invoice.data.id, amount: result.amount})
                            .then((result) => {
                                modalAlert.open({
                                    title: 'Sponsor Payment Sent',
                                    content: 'Sponsor Payment Sent! This will take a moment to complete because we are generating a new Invoice for the sponsor. Hang tight, the invoice should appear soon!'
                                });
                            })
                            .catch((error) => {
                                this.dispatchEvent(new ShowToastEvent({title: 'Sponsor Payment Add', message: 'Failed to send Sponsor Payment: '+error.body.message, variant: 'error'}));
                            });
                    } else {
                        sendPayment({invoiceId: this.invoice.data.id, paymentType: result.type, amount: result.amount, processorId: result.processorid})
                            .then((result) => {        
                                modalAlert.open({
                                    title: 'Payment Sent',
                                    content: 'Payment Sent! Please close this tab; any updates will come through shortly.'
                                });
                            })
                            .catch((error) => {
                                this.dispatchEvent(new ShowToastEvent({title: 'Payment Add', message: 'Failed to send Payment: '+error.body.message, variant: 'error'}));
                            });
                    }
                }
            });
    }

}