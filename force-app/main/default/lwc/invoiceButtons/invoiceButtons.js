import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import REG_ID_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Registration_Id__c';
import IS_CONFIRMED_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Is_Completely_Confirmed__c';
import IS_PAID_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Is_Paid__c';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Contact__r.Email';
import IS_ESCALATION_SENT_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Escalation_Sent__c';
import confirmInvoice from "@salesforce/apex/InvoiceButtonHandler.confirmInvoice";
import cancelInvoice from "@salesforce/apex/InvoiceButtonHandler.cancelInvoice";
import sendEscalationEmail from '@salesforce/apex/InvoiceButtonHandler.sendEscalationEmail';
import modalConfirm from "c/modalConfirm";
import modalAlert from "c/modalAlert";

import workspaceAPI from "c/workspaceAPI";

const fields = [REG_ID_FIELD, IS_CONFIRMED_FIELD, IS_PAID_FIELD, CONTACT_EMAIL_FIELD, IS_ESCALATION_SENT_FIELD];
const NULL_EMAIL_TOAST = new ShowToastEvent({title: 'Escalation Email', message: 'This contact does not have an email! Please add an email for this person before sending an escalation.', variant: 'error'});
export default class InvoiceButtons extends NavigationMixin(LightningElement) {

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
                        content: 'Confirmation Sent! Please wait a moment while we process your request... if you do not see an update immediately, please refresh your browser.'
                    }).then((result) => {
                        workspaceAPI.refreshCurrentTab();
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
                .then((invoiceMessage) => {
                    modalAlert.open({
                        title: 'Invoice Cancelled',
                        content: invoiceMessage
                    }).then((result) => {
                        workspaceAPI.closeCurrentTab();
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
        if(getFieldValue(this.lineItem.data, CONTACT_EMAIL_FIELD) == null) {
            this.dispatchEvent(NULL_EMAIL_TOAST);
            return;
        }
        modalConfirm.open({
            title: 'Send Escalation',
            content: 'Are you sure you want to send a payment escalation email to: '+getFieldValue(this.lineItem.data, CONTACT_EMAIL_FIELD)+'?'
        }).then((result) => {
            if(result) {
                sendEscalationEmail({invoiceId: this.recordId}).then((emailResult) => {
                    this.dispatchEvent(new ShowToastEvent({title: 'Escalation Send', message: 'Escalation Sent!', variant: 'success'}));
                    workspaceAPI.refreshCurrentTab();
                })
                .catch((error) => {
                    this.dispatchEvent(new ShowToastEvent({title: 'Escalation Send', message: 'Failed to send Escalation: '+error.body.message, variant: 'error'}));
                });
            }
        })
    }

    runViewInOpus() {
        let regId = getFieldValue(this.lineItem.data, REG_ID_FIELD);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://online.colostate.edu/c/portal/layout?p_l_id=28.3&p_p_id=EXT_REGISTRATIONS&p_p_action=1&p_p_state=maximized&p_p_mode=view&_EXT_REGISTRATIONS_struts_action=%2Fcsu%2Fregistrations%2Fedit_registration&inode='+regId
            }
        });
    }

    get cancelLabel() {
        if(getFieldValue(this.lineItem.data, IS_CONFIRMED_FIELD)) {
            return "Drop & Refund";
        } else {
            return "Void Invoice";
        }
    }
    
}