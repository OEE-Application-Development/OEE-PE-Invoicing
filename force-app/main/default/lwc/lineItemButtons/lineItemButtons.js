import { LightningElement, api } from 'lwc';
import confirmLineItem from "@salesforce/apex/LineItemButtonHandler.confirmLineItem";
import voidLineItem from "@salesforce/apex/LineItemButtonHandler.voidLineItem";
import modalConfirm from "c/modalConfirm";
import CloseActionScreenEvent from 'lightning/actions';

export default class LineItemButtons extends LightningElement {

    @api recordId;

    runConfirm() {
        modalConfirm.open({
            title: 'Set Confirmed',
            content: 'Are you sure you want to confirm this line item?'
        }).then((result) => {
            if(result) {
                confirmLineItem({lineItemId: this.recordId})
                .then((result) => {
                    this.dispatchEvent(new CloseActionScreenEvent());
                })
                .catch((error) => {
                    
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
                    this.dispatchEvent(new CloseActionScreenEvent());
                })
                .catch((error) => {
                    
                });
            }
        })
    }

}