import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class AddPaymentModal extends LightningModal {

    @api defaultAmount;

    handleAdd() {
        this.close({ok: true, type: this.refs.paytype.value, amount: this.refs.payamount.value});
    }

    handleCancel() {
        this.close({ok: false});
    }
}