import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class AddPaymentModal extends LightningModal {

    @api defaultAmount;

    updatePaymentType(e) {
        console.log(e);
    }

    handleAdd() {
        this.close({ok: true, type: this.refs.paytype.value, amount: this.refs.payamount.value, processorid: this.refs.payprocessorid.value});
    }

    handleCancel() {
        this.close({ok: false});
    }
}