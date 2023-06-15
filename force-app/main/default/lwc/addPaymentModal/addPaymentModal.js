import { api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';

export default class AddPaymentModal extends LightningModal {

    @api defaultAmount;

    updatePaymentType(e) {
        if(e.detail.value == "Credit Card") {
            this.sponsorPayment = "sponsor-closed";
        } else if(e.detail.value == "Sponsor") {
            this.sponsorPayment = "sponsor-open";
        } else if(e.detail.value == "Check") {
            this.sponsorPayment = "sponsor-closed";
        }
    }

    handleAdd() {
        if(this.refs.payamount.value <= 0){this.dispatchEvent(new ShowToastEvent({title: 'Payment Add', message: 'Payment Amount must be greater than 0', variant: 'error'})); return;}
        let isSponsor = (this.refs.paytype.value === "Sponsor");
        if(isSponsor && !this.refs.paysponsor.value) {this.dispatchEvent(new ShowToastEvent({title: 'Payment Add', message: 'Sponsor Payment type requires an account!', variant: 'error'})); return;}
        this.close({ok: true, isSponsor: isSponsor, type: this.refs.paytype.value, amount: this.refs.payamount.value, processorid: this.refs.payprocessorid.value, account: this.refs.paysponsor.value});
    }

    handleCancel() {
        this.close({ok: false});
    }

    sponsorPayment = "sponsor-closed";
    get sponsorPaymentClass() {
        return this.sponsorPayment;
    }

    get oppositeSponsorPaymentClass() {
        if(this.sponsorPayment == "sponsor-closed") {
            return "sponsor-open";
        } else {
            return "sponsor-closed";
        }
    }
}