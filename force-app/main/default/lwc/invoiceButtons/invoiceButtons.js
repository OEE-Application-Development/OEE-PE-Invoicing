import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import IS_CONFIRMED_FIELD from '@salesforce/schema/Noncredit_Invoice__c.Is_Completely_Confirmed__c';
import confirmInvoice from "@salesforce/apex/InvoiceButtonHandler.confirmInvoice";
import cancelInvoice from "@salesforce/apex/InvoiceButtonHandler.cancelInvoice";
import modalConfirm from "c/modalConfirm";
import modalAlert from "c/modalAlert";

const fields = [IS_CONFIRMED_FIELD];

export default class InvoiceButtons extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    lineItem;

    get isConfirmed() {
        return getFieldValue(this.lineItem.data, IS_CONFIRMED_FIELD);
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
}