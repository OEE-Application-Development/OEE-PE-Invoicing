import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import INVOICE_FIELD from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Noncredit_Invoice__c';
import IS_CONFIRMED_FIELD from '@salesforce/schema/Noncredit_Invoice_Line_Item__c.Is_Confirmed__c';

import confirmLineItem from "@salesforce/apex/LineItemButtonHandler.confirmLineItem";
import voidLineItem from "@salesforce/apex/LineItemButtonHandler.voidLineItem";
import trackLineItem from "@salesforce/apex/LineItemButtonHandler.trackLineItem";
import getLineItemData from "@salesforce/apex/LineItemButtonHandler.getLineItemData";
import emitEnrollmentComplete from "@salesforce/apex/LineItemButtonHandler.emitEnrollmentComplete";
import setLineItemEnrollment from "@salesforce/apex/LineItemButtonHandler.setLineItemEnrollment";
import checkLineItemEnrollmentExists from "@salesforce/apex/LineItemButtonHandler.checkLineItemEnrollmentExists";

import modalConfirm from "c/modalConfirm";
import modalAlert from "c/modalAlert";

const CONFIRM_NOT_FOUND_TOAST = new ShowToastEvent({title: 'Confirmation', message: 'Confirmation not found!', variant: 'error'});
const CONFIRM_FOUND_TOAST = new ShowToastEvent({title: 'Confirmation', message: 'Confirmation found. We\'re marking this line item... returning to Invoice view while awaiting completion.', variant: 'success'});
const ENROLLMENT_FOUND_TOAST = new ShowToastEvent({title: 'Canvas Enrollment', message: 'Canvas Enrollment Found! We\'re marking this enrollment... returning to Invoice view while awaiting completion.', variant: 'success'});
const fields = [INVOICE_FIELD, IS_CONFIRMED_FIELD];
export default class LineItemButtons extends NavigationMixin(LightningElement) {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    lineItem;

    @wire(getLineItemData, { recordId: '$recordId' })
    setFields({error, data}) {
        console.log(data);
        if(data) {
            if(data.offeringId)this.offeringId = data.offeringId;
            if(data.lmsAccountId)this.lmsAccountId = data.lmsAccountId;
            if(data.lmsCourseTermId)this.lmsCourseTermId = data.lmsCourseTermId;
        }
        if(error) {

        }
    }

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

    handleConfirmCheck(event) {
        checkLineItemEnrollmentExists({lineItemId: this.recordId})
            .then((result) => {
                if(result) {
                    let invoiceId = getFieldValue(this.lineItem.data, INVOICE_FIELD);
                    this.dispatchEvent(CONFIRM_FOUND_TOAST);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            objectApiName: 'Noncredit_Invoice__c',
                            actionName: 'view',
                            recordId: invoiceId
                        }
                    });
                } else {
                    this.dispatchEvent(CONFIRM_NOT_FOUND_TOAST);
                }
            })
    }

    lmsAccountId;
    lmsCourseTermId;
    offeringId;
    @api enrollmentId;

    handleFoundEnrollmentId(event) {
        this.enrollmentId = event.detail.foundId;
        if(this.enrollmentId) {
            let invoiceId = getFieldValue(this.lineItem.data, INVOICE_FIELD);
            setLineItemEnrollment({lmsEnrollmentId: this.enrollmentId, lineItemId: this.recordId});
            emitEnrollmentComplete({lmsEnrollmentId: this.enrollmentId})
                .then(() => {
                    this.dispatchEvent(ENROLLMENT_FOUND_TOAST);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            objectApiName: 'Noncredit_Invoice__c',
                            actionName: 'view',
                            recordId: invoiceId
                        }
                    });
                })
                .catch((error) => {
                    modalAlert.open({
                        title: 'Enrollment Check Failed',
                        content: 'We found an LMS Enrollment for this line item, but could not send to grid. If this issue persists, please contact IT support.'
                    })
                });
        }
    }

}