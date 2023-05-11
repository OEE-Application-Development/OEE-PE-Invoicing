import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import IS_CONFIRMED_FIELD from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Is_Confirmed__c';
import confirmLineItem from "@salesforce/apex/LineItemButtonHandler.confirmLineItem";
import voidLineItem from "@salesforce/apex/LineItemButtonHandler.voidLineItem";
import trackLineItem from "@salesforce/apex/LineItemButtonHandler.trackLineItem";
import modalConfirm from "c/modalConfirm";
import modalAlert from "c/modalAlert";

const fields = [IS_CONFIRMED_FIELD];

export default class LineItemButtons extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    lineItem;

    get isConfirmed() {
        return getFieldValue(this.lineItem.data, IS_CONFIRMED_FIELD);
    }

    get isNotConfirmed() {
        return !getFieldValue(this.lineItem.data, IS_CONFIRMED_FIELD);
    }

    runConfirm() {
        modalConfirm.open({
            title: 'Set Confirmed',
            content: 'Are you sure you want to confirm this line item?'
        }).then((result) => {
            if(result) {
                confirmLineItem({lineItemId: this.recordId})
                .then((result) => {
                    modalAlert.open({
                        title: 'Confirmation Sent',
                        content: 'Confirmation Sent! Please close this tab; the update will come through shortly.'
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

    runVoid() {
        modalConfirm.open({
            title: 'Void Confirmed',
            content: 'Are you sure you want to void this line item? If the student is enrolled in Canvas, that enrollment will be deactivated.'
        }).then((result) => {
            if(result) {
                voidLineItem({lineItemId: this.recordId})
                .then((result) => {
                    modalAlert.open({
                        title: 'Void Sent',
                        content: 'Void Sent! Please close this tab; the update will come through shortly.'
                    });
                })
                .catch((error) => {
                    modalAlert.open({
                        title: 'Void Error',
                        content: 'Send failure! If this issue persists, please contact IT.'
                    });
                });
            }
        })
    }

    runTrackLineItem() {
        modalConfirm.open({
            title: 'Restart Tracking',
            content: 'If the Offering isn\'t set on this line item, restart tracking to attempt setting it and starting the tracking process.'
        }).then((result) => {
            if(result) {
                trackLineItem({lineItemId: this.recordId})
                .then((trackResult) => {
                    modalAlert.open({
                        title: 'Tracking Started',
                        content: 'Previous tracking for this line item was cancelled. If a course connection was found, then this should now be confirmed... otherwise tracking restarted!'
                    })
                })
                .catch((error) => {
                    modalAlert.open({
                        title: 'Tracking Failed',
                        content: error.body.message
                    })
                });
            }
        })
    }

}