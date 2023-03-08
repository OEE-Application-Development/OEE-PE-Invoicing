import { LightningElement, api, wire } from 'lwc';
import confirmLineItem from "@salesforce/apex/LineItemButtonHandler.confirmLineItem";
import voidLineItem from "@salesforce/apex/LineItemButtonHandler.voidLineItem";

export default class LineItemButtons extends LightningElement {

    @api recordId;


    @wire(confirmLineItem, {lineItemId: "$recordId"})
    runConfirm({ error, data }) {
        
    }

    @wire(voidLineItem, {lineItemId: "$recordId"})
    runVoid(event) {
        console.log("RecordId: "+this.recordId);
    }

}