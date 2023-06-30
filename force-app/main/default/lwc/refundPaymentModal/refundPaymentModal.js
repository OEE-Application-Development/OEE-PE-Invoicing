import { api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';

export default class RefundPaymentModal extends LightningModal {

    @api defaultAmount;

    handleRefund() {
        if(this.refs.refundamount.value <= 0){this.dispatchEvent(new ShowToastEvent({title: 'Payment Refund', message: 'Payment Amount must be greater than 0', variant: 'error'})); return;}
        this.close({ok: true, amount: this.refs.refundamount.value});
    }

    handleCancel() {
        this.close({ok: false});
    }

}