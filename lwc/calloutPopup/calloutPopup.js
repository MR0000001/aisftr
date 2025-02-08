import { LightningElement, api, track } from 'lwc';
//LABELS
import cancel from '@salesforce/label/c.Cancel';
import send from '@salesforce/label/c.Send';
import continues from '@salesforce/label/c.Continue';

export default class CalloutPopup extends LightningElement {
    @api recordId;
    @api popupTitle;
    @api popupMsgs;
    @api openPopup;
    @track popupMsg;
    @track buttonLabel;
    @track label = {
        cancel,
        send,
        continues
    };

    connectedCallback() {
        console.log('connectedCallback');
        console.log(this.popupMsgs);
        console.log(JSON.parse(JSON.stringify(this.popupMsgs)));

        this.popupMsgs = JSON.parse(JSON.stringify(this.popupMsgs));
        this.popupMsg = this.popupMsgs[0];
        this.popupMsgs.shift();
        this.buttonLabel = (this.popupMsgs.length === 0) ? this.label.send : this.label.continues;
    }

    handleCancel() {
        console.log('entered cancel');
        var params = {
            openPopup: false
        };
        const selectedEvent = new CustomEvent('resetpopup', {detail : params});
        this.dispatchEvent(selectedEvent);
    }

    handleContinue() {
        console.log('handleContinue');
        if(this.popupMsgs.length != 0) {
            this.popupMsg = this.popupMsgs[0];
            this.popupMsgs.shift();
            this.buttonLabel = (this.popupMsgs.length === 0) ? this.label.send : this.label.continues;
        } else {
            var params = {
                openPopup: false
        };
        const selectedEvent = new CustomEvent('callout', {detail : params});
        this.dispatchEvent(selectedEvent);
        }
    }
}