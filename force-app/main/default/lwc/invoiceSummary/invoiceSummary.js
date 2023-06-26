import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue, getFieldDisplayValue } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import paymentModal from "c/addPaymentModal";
import datatableHelpers from "c/datatableHelpers";
import modalAlert from "c/modalAlert";
import modalConfirm from "c/modalConfirm";

/* Invoice */
import requestInvoice from '@salesforce/apex/InvoiceButtonHandler.requestInvoice';

import INVOICE_NUMBER from '@salesforce/schema/Noncredit_Invoice__c.Invoice_Number__c';
import REGISTRATION_NUMBER from '@salesforce/schema/Noncredit_Invoice__c.Registration_Id__c';
import NONCREDIT_ID from '@salesforce/schema/Noncredit_Invoice__c.Noncredit_Id__c';
import PAYER_ACCOUNT from '@salesforce/schema/Noncredit_Invoice__c.Payer_Account__c';
import COST_TOTAL from '@salesforce/schema/Noncredit_Invoice__c.Total_Amount__c';
import PAYMENT_TOTAL from '@salesforce/schema/Noncredit_Invoice__c.Total_Paid__c';
import CANCEL_IN_PROGRESS from '@salesforce/schema/Noncredit_Invoice__c.Cancel_in_Progress__c';
import CANCEL_AT from '@salesforce/schema/Noncredit_Invoice__c.Cancel_At__c';
import NOTES from '@salesforce/schema/Noncredit_Invoice__c.Notes__c';
import INVOICE_CREATED_AT from '@salesforce/schema/Noncredit_Invoice__c.CreatedDate';
import INVOICE_CANCELLED from '@salesforce/schema/Noncredit_Invoice__c.Is_Cancelled__c';

import IS_PAID from '@salesforce/schema/Noncredit_Invoice__c.Is_Paid__c';
import IS_CONFIRMED from '@salesforce/schema/Noncredit_Invoice__c.Is_Completely_Confirmed__c';
import IS_FULFILLED from '@salesforce/schema/Noncredit_Invoice__c.Is_Completely_Fulfilled__c';
import HAS_FAILED_PAYMENTS from '@salesforce/schema/Noncredit_Invoice__c.Has_Failed_Payments__c';

import refreshChildren from '@salesforce/apex/CombinedFunctions.refreshChildren';

/* Line Items */
import getTrackingInterviewsForInvoice from '@salesforce/apex/InvoiceButtonHandler.getTrackingInterviewsForInvoice';
import trackLineItem from "@salesforce/apex/LineItemButtonHandler.trackLineItem";

import LINE_ITEM_SECTION_REFERENCE from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Section_Reference__c';
import LINE_ITEM_AMOUNT from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Line_Item_Amount__c';
import LINE_ITEM_CANVAS_LINK from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Course_Offering__r.Canvas_Link__c';
import LINE_ITEM_IS_CONFIRMED from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Is_Confirmed__c';
import LINE_ITEM_CONFIRMED_AT from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Confirmed_At__c';
import LINE_ITEM_IS_FULFILLED from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Is_Fulfilled__c';
import LINE_ITEM_REQUIRES_FULFILLED from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Requires_LMS_Fulfillment__c';


/* Payments */
import sendPayment from '@salesforce/apex/InvoiceButtonHandler.addPayment';
import cancelPayment from '@salesforce/apex/InvoiceButtonHandler.initiatePaymentRefund';

import PAYMENT_NAME from '@salesforce/schema/Noncredit_Invoice_Payment__c.Name';
import PAYMENT_TYPE from '@salesforce/schema/Noncredit_Invoice_Payment__c.Payment_Type__c';
import PAYMENT_AMOUNT from '@salesforce/schema/Noncredit_Invoice_Payment__c.Amount__c';
import PAYMENT_SUCCESS from '@salesforce/schema/Noncredit_Invoice_Payment__c.Successful__c';
import PAYMENT_CREATED_AT from '@salesforce/schema/Noncredit_Invoice_Payment__c.CreatedDate';

/* Email */
import getInvoiceEmails from '@salesforce/apex/InvoiceEmailMessageHandler.getInvoiceEmails';
import EMAIL_SUBJECT from '@salesforce/schema/EmailMessage.Subject';
import EMAIL_HAS_BEEN_OPENED from '@salesforce/schema/EmailMessage.Has_Been_Opened__c';

import workspaceAPI from "c/workspaceAPI";

const allFields = [INVOICE_NUMBER, REGISTRATION_NUMBER, IS_PAID, IS_CONFIRMED, IS_FULFILLED, HAS_FAILED_PAYMENTS, NONCREDIT_ID, PAYER_ACCOUNT, COST_TOTAL, PAYMENT_TOTAL, CANCEL_IN_PROGRESS, CANCEL_AT, NOTES, INVOICE_CREATED_AT, INVOICE_CANCELLED];
const noPayments = [
    {
        "id": "fakeid",
        "Name": "No Payments",
        "csuoee__Payment_Type__c": "",
        "csuoee__Successful__c": false,
        "CreatedDate": "",
        "csuoee__Amount__c": null
    }
];
const TRACKING_RESTART_TOAST = new ShowToastEvent({title: 'Line Item Tracking', message: 'Previous tracking for this line item was cancelled. If a course connection was found, then this should now be confirmed... otherwise tracking restarted!', variant: 'success'});
const REFUND_SENT_TOAST = new ShowToastEvent({title: 'Payment Refund/Void', message: 'Refund Request Sent!', variant: 'success'});


const LINE_ITEM_FIELDS = ['id', 
    LINE_ITEM_SECTION_REFERENCE.objectApiName+'.'+LINE_ITEM_SECTION_REFERENCE.fieldApiName, 
    LINE_ITEM_AMOUNT.objectApiName+'.'+LINE_ITEM_AMOUNT.fieldApiName, 
    LINE_ITEM_CANVAS_LINK.objectApiName+'.'+LINE_ITEM_CANVAS_LINK.fieldApiName,
    LINE_ITEM_IS_CONFIRMED.objectApiName+'.'+LINE_ITEM_IS_CONFIRMED.fieldApiName,
    LINE_ITEM_IS_FULFILLED.objectApiName+'.'+LINE_ITEM_IS_FULFILLED.fieldApiName,
    LINE_ITEM_REQUIRES_FULFILLED.objectApiName+'.'+LINE_ITEM_REQUIRES_FULFILLED.fieldApiName,
    LINE_ITEM_CONFIRMED_AT.objectApiName+'.'+LINE_ITEM_CONFIRMED_AT.fieldApiName];
const PAYMENT_FIELDS = ['id', 
    PAYMENT_NAME.objectApiName+'.'+PAYMENT_NAME.fieldApiName, 
    PAYMENT_TYPE.objectApiName+'.'+PAYMENT_TYPE.fieldApiName, 
    PAYMENT_SUCCESS.objectApiName+'.'+PAYMENT_SUCCESS.fieldApiName, 
    PAYMENT_AMOUNT.objectApiName+'.'+PAYMENT_AMOUNT.fieldApiName,
    PAYMENT_CREATED_AT.objectApiName+'.'+PAYMENT_CREATED_AT.fieldApiName];

export default class InvoiceSummary extends NavigationMixin(LightningElement) {
    invoiceFields = [ INVOICE_NUMBER, REGISTRATION_NUMBER, NONCREDIT_ID, PAYER_ACCOUNT, COST_TOTAL, PAYMENT_TOTAL ];
    notesOnly = [ NOTES ];

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: allFields })
    invoice;

    get pendingCancelMessageClass() {
        if(getFieldValue(this.invoice.data, CANCEL_IN_PROGRESS) || getFieldValue(this.invoice.data, INVOICE_CANCELLED)) {
            return "slds-button_neutral slds-card__body slds-theme_error slds-notify--toast slds-show slds-var-m-bottom_small";
        } else {
            return "slds-hide";
        }
    }

    get cancelMessage() {
        if(getFieldValue(this.invoice.data, INVOICE_CANCELLED)) {
            return "This invoice is cancelled & no longer appears in Opus. If you need to recreate it, contact IT support.";
        } else {
            return "Unless a payment occurs or this invoice is confirmed, this invoice is set to expire on "+getFieldDisplayValue(this.invoice.data, CANCEL_AT)+" at midnight.";
        }
    }

    /* Line Items */
    lineItemRefreshHandlerID;
    dataLineItemColumns = [
        {label: 'Section Reference', fieldName: LINE_ITEM_SECTION_REFERENCE.fieldApiName, type: 'text'},
        {label: 'Amount', fieldName: LINE_ITEM_AMOUNT.fieldApiName, type: 'currency'},
        {label: 'Canvas Link', fieldName: LINE_ITEM_CANVAS_LINK.fieldApiName, type: 'url'},
        {label: '', fieldName: LINE_ITEM_IS_CONFIRMED.fieldApiName, type: 'boolean', cellAttributes: {class: 'slds-hidden'}},
        {label: '', fieldName: LINE_ITEM_IS_FULFILLED.fieldApiName, type: 'boolean'},
        {label: 'Tracking Status', fieldName: 'LineItemTracked', type: 'text'},
        {label: 'Confirmed At', fieldName: LINE_ITEM_CONFIRMED_AT.fieldApiName, type: 'date'},
        {label: '', fieldName: LINE_ITEM_REQUIRES_FULFILLED.fieldApiName, type: 'boolean'}
    ];
    lineItemColumns = [
        {label: 'Section Reference', fieldName: LINE_ITEM_SECTION_REFERENCE.fieldApiName, type: 'text'},
        {label: 'Amount', fieldName: LINE_ITEM_AMOUNT.fieldApiName, type: 'currency'},
        {label: 'Canvas Link', fieldName: LINE_ITEM_CANVAS_LINK.fieldApiName, type: 'url'},
        {label: 'Tracking Status', fieldName: 'LineItemTracked', type: 'text', ignoreRefresh: true},
        {label: 'Confirmed At', fieldName: LINE_ITEM_CONFIRMED_AT.fieldApiName, type: 'date'},
        {label: '', type: 'button', typeAttributes: {label: 'Review Line Item', name: 'reviewLineItem'}, cellAttributes: {alignment: 'center'}},
        {label: '', type: 'button', typeAttributes: {label: 'Restart Tracking', name: 'trackLineItem'}, cellAttributes: {alignment: 'center'}}
    ];
    lineItemData = [];
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'csuoee__Noncredit_Invoice_Line_Items__r',
        fields: LINE_ITEM_FIELDS
    })
    relatedLineItems({error, data}) {
        if(data) {
            getTrackingInterviewsForInvoice({invoiceId: this.recordId})
                .then((result) => {
                    let formattedData = datatableHelpers.parseFieldData(this.dataLineItemColumns, data);
                    this.lineItemData = this.spliceTrackingStatus(formattedData, result);
                });
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
            return;
        }
        if(event.detail.action.name == 'trackLineItem') {
            trackLineItem({lineItemId: event.detail.row.id})
                .then((trackResult) => {
                    this.dispatchEvent(TRACKING_RESTART_TOAST);
                    this.refreshLineItemData();
                    workspaceAPI.refreshCurrentTab();
                })
                .catch((error) => {
                    console.log(error);
                    modalAlert.open({
                        title: 'Tracking Failed',
                        content: error.body.message
                    })
                });
        }
    }

    /* Payments */
    paymentColumns = [
        {label: 'Payment', fieldName: PAYMENT_NAME.fieldApiName, type: 'text'},
        {label: 'Payment Type', fieldName: PAYMENT_TYPE.fieldApiName, type: 'text'},
        {label: 'Successful', fieldName: PAYMENT_SUCCESS.fieldApiName, type: 'boolean'},
        {label: 'Paid At', fieldName: PAYMENT_CREATED_AT.fieldApiName, type: 'date'},
        {label: 'Amount', fieldName: PAYMENT_AMOUNT.fieldApiName, type: 'currency', cellAttributes: { alignment: 'left' }},
        {label: '', type: 'button', typeAttributes: {label: 'Refund/Void Payment', name: 'cancelPayment'}, cellAttributes: {alignment: 'center'}}
    ];
    paymentData = [];
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'csuoee__Payments__r',
        fields: PAYMENT_FIELDS
    })
    relatedPayments({error, data}) {
        if(data) {
            if(data.count == 0)
                this.paymentData = noPayments;
            else
                this.paymentData = datatableHelpers.parseFieldData(this.paymentColumns, data);
        } else {
            this.paymentData = noPayments;
        }
    }

    handlePayItemAction(event) {
        if(event.detail.action.name == 'cancelPayment') {
            modalConfirm.open({
                title: 'Refund/Void Payment',
                content: 'Are you sure you want refund/void this payment?'
            }).then((check1) => {
                if(check1) {
                    modalConfirm.open({
                        title: 'WARNING',
                        content: 'This will IMMEDIATELY refund/void this payment. If it came from Authorize.Net, then we will send a request to return the student\'s money & deactivate enrollments in Canvas.'
                    }).then((check2) => {
                        if(check2) {
                            //Do it.
                            cancelPayment({paymentId: event.detail.row.id})
                                .then((refundMessage) => {
                                    let customResponse = REFUND_SENT_TOAST;
                                    customResponse.message = refundMessage;
                                    this.dispatchEvent(customResponse);
                                })
                                .catch((error) => {
                                    this.dispatchEvent(new ShowToastEvent({title: 'Payment Refund', message: error.body.message, variant: 'error'}));
                                });
                        }
                    });
                }
            });
            return;
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
        paymentModal.open({size: 'small', invoiceId: this.invoice.data.id, defaultAmount: Math.abs(this.invoice.data.fields.csuoee__Total_Amount__c.value - this.invoice.data.fields.csuoee__Total_Paid__c.value)})
            .then((result) => {
                if(result.ok) {
                    if(result.isSponsor) {
                        requestInvoice({accountId: result.account, invoiceId: this.invoice.data.id, amount: result.amount})
                            .then((result) => {
                                modalAlert.open({
                                    title: 'Sponsor Payment Sent',
                                    content: 'Sponsor Payment Sent! This will take a moment to complete because we are generating a new Invoice for the sponsor. Hang tight, the invoice should appear soon!'
                                })
                                .then((ok) => {
                                    this.refreshPaymentData();
                                    workspaceAPI.refreshCurrentTab();
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
                                    content: 'Payment Sent! Refreshing page... if you don\'t see the change, give it a minute. If it does not appear within a minute, please contact IT support.'
                                })
                                .then((ok) => {
                                    this.refreshPaymentData();
                                    workspaceAPI.refreshCurrentTab();
                                });
                            })
                            .catch((error) => {
                                this.dispatchEvent(new ShowToastEvent({title: 'Payment Add', message: 'Failed to send Payment: '+error.body.message, variant: 'error'}));
                            });
                    }
                }
            });
    }

    spliceTrackingStatus(formattedData, trackingResult) {
        console.log(formattedData);
        for(var i=0;i<formattedData.length;i++) {
            if(!formattedData[i].id)
                formattedData[i].id = formattedData[i].Id;
            try{
                if(getFieldValue(this.invoice.data, INVOICE_CANCELLED)) {
                    formattedData[i].LineItemTracked = 'Invoice Cancelled';
                    continue;
                }
                let status = trackingResult[formattedData[i].csuoee__Section_Reference__c];
                if(status == null){
                    if(formattedData[i].csuoee__Is_Confirmed__c) {
                        if(formattedData[i].csuoee__Is_Fulfilled__c || !formattedData[i].csuoee__Requires_LMS_Fulfillment__c) {
                            formattedData[i].LineItemTracked = 'Complete';
                        } else {
                            formattedData[i].LineItemTracked = 'Error - Fulfillment';
                        }
                    } else {
                        formattedData[i].LineItemTracked = 'Error - Confirmation';
                    }
                } else {
                    if(status == 'Await_Confirmation') {
                        formattedData[i].LineItemTracked = 'Awaiting Confirmation';
                    } else if(status == 'Await_Fulfillment') {
                        formattedData[i].LineItemTracked = 'Awaiting LMS Enrollment';
                    } else {
                        formattedData[i].LineItemTracked = 'Status Unknown';
                    }
                }
            }catch(e) {
                //Not sure what's happening
            }
        }
        return formattedData;
    }

    refreshLineItemData() {
        refreshChildren({parentId: this.recordId, childObjectName: 'csuoee__Noncredit_Invoice_Line_Item__c', parentFieldName: 'csuoee__Noncredit_Invoice__c', fieldsToRefresh: LINE_ITEM_FIELDS})
            .then((data) => {
                getTrackingInterviewsForInvoice({invoiceId: this.recordId})
                    .then((result) => {
                        this.lineItemData = this.spliceTrackingStatus(data, result);
                    });
            });
    }

    refreshPaymentData() {
        refreshChildren({parentId: this.recordId, childObjectName: 'csuoee__Noncredit_Invoice_Payment__c', parentFieldName: 'csuoee__Noncredit_Invoice__c', fieldsToRefresh: PAYMENT_FIELDS})
            .then((result) => {
                if(result.length == 0) {
                    this.paymentData = noPayments;
                } else {
                    this.paymentData = result;
                }
            });
    }

}