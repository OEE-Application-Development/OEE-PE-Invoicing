import { api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';

export default class ReviewInvoiceModal extends LightningModal {

    @api invoiceId;

    get invoiceInput() {
        return [{name:'InvoiceId', type:'String', value: this.invoiceId}];
    }

    handleStatusChange(e) {
        if(e.detail.status == 'FINISHED') {
            this.close();
        }
    }

}