import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import IS_CONFIRMED_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Is_Completely_Confirmed__c';
import IS_PAID_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Is_Paid__c';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Contact__r.Email';
import IS_ESCALATION_SENT_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Escalation_Sent__c';
import confirmInvoice from "@salesforce/apex/InvoiceButtonHandler.confirmInvoice";
import cancelInvoice from "@salesforce/apex/InvoiceButtonHandler.cancelInvoice";
import sendEscalationEmail from '@salesforce/apex/InvoiceButtonHandler.sendEscalationEmail';
import modalConfirm from "c/modalConfirm";
import modalAlert from "c/modalAlert";

const fields = [IS_CONFIRMED_FIELD, IS_PAID_FIELD, CONTACT_EMAIL_FIELD, IS_ESCALATION_SENT_FIELD];

export default class InvoiceButtons extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    lineItem;

    get isConfirmed() {
        return getFieldValue(this.lineItem.data, IS_CONFIRMED_FIELD);
    }

    get isEscalationNotAvailable() {
        return (getFieldValue(this.lineItem.data, IS_PAID_FIELD) || getFieldValue(this.lineItem.data, IS_ESCALATION_SENT_FIELD));
    }

    runConfirm() {
        modalConfirm.open({
            title: 'Set Confirmed',
            content: 'Are you sure you want to confirm all the line items on this invoice? Note that this invoice will NOT be considered paid by this action.'
        }).then((result) => {
            if(result) {
                confirmInvoice({invoiceId: this.recordId})
                .then((result) => {
                    modalAlert.open({
                        title: 'Confirmation Sent',
                        content: 'Confirmation Sent! Please close this tab; any updates will come through shortly.'
                    });
                })
                .catch((error) => {
                    modalAlert.open({
                        title: 'Confirmation Error',
                        content: 'Send failure! If this issue persists, please contact IT.'
                    });
                });
            }
        });
    }

    runCancel() {
        modalConfirm.open({
            title: 'Void Confirmed',
            content: 'Are you sure you want to cancel this invoice? This action will reverse any confirmations that have already occurred.'
        }).then((result) => {
            if(result) {
                cancelInvoice({invoiceId: this.recordId})
                .then((result) => {
                    modalAlert.open({
                        title: 'Invoice Cancelled',
                        content: 'Cancel Sent! Please close this tab; any updates will come through shortly.'
                    });
                })
                .catch((error) => {
                    modalAlert.open({
                        title: 'Cancel Error',
                        content: 'Send failure! If this issue persists, please contact IT.'
                    });
                });
            }
        })
    }

    runSendEscalation() {
        modalConfirm.open({
            title: 'Send Escalation',
            content: 'Are you sure you want to send a payment escalation email to: '+getFieldValue(this.lineItem.data, CONTACT_EMAIL_FIELD)+'?'
        }).then((result) => {
            if(result) {
                sendEscalationEmail({invoiceId: this.recordId}).then((emailResult) => {
                    this.dispatchEvent(new ShowToastEvent({title: 'Escalation Send', message: 'Escalation Sent!', variant: 'success'}));
                    this.recordId = this.recordId;
                })
                .catch((error) => {
                    this.dispatchEvent(new ShowToastEvent({title: 'Escalation Send', message: 'Failed to send Escalation: '+error.body.message, variant: 'error'}));
                });
            }
        })
    }
}