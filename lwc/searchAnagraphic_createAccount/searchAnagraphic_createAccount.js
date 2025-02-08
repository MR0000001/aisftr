import { LightningElement, api } from 'lwc';
//APEX
import deleteAccountDraft from '@salesforce/apex/SearchAccountController.deleteAccountDraft';

export default class SearchAnagraphic_createAccount extends LightningElement {

    @api isLoading;
    @api accountRecordId;
    @api recordTypeIdToUse;

    deleteAccountDraft(accountRecordId){
        deleteAccountDraft({IdToRemove: accountRecordId})
        .then(data =>{
            console.log('data -> ', data);                       
        })
        .catch(error => {
            console.log("@@@ error "+JSON.stringify(error));
        })
        .finally(() => {
            this.cancelAndRestore();
        });
    }

    handleSubmitCreateAccount(event) {
    }
    
    handleSuccessCreateAccount(event) {
        event.preventDefault();
        this.isLoading = true;
        let accountId = event.detail.id;
        let fiscalCode = event.detail.fields.Fiscal_Code__pc.value;
        console.log('id saved -> ', accountId);
        console.log('fiscalCode ', fiscalCode);
        let detailToSend = {
            idToSave: accountId
        }
        if(fiscalCode != null) {
            detailToSend.fiscalCodeIndicated = fiscalCode
        } else {
            detailToSend.isFiscalCodeNull = true;
        }
        const selectedEvent = new CustomEvent('closecreateaccountform', {detail: detailToSend});
        this.dispatchEvent(selectedEvent);
        const editForm = this.template.querySelector('lightning-record-form');
        editForm.recordId = accountId;
        editForm.mode = 'edit';
        this.isLoading = false;
    }  

    handleCancelCreateAccount(event){
        console.log('handleCancelCreateAccount event -> ', event);
        this.deleteAccountDraft(this.accountRecordId);
    }

    cancelAndRestore() {
        console.log('cancelAndRestore');
        const selectedEvent = new CustomEvent('closecardnewaccount');
        this.dispatchEvent(selectedEvent);
        this.isLoading = false;
    }    
}