import { LightningElement,api,track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
//APEX METHODS
import getCitizenWallets from '@salesforce/apex/CitizenWalletsController.getCitizenWallets'; 
//LABELS
import citizenWalletsTitle from '@salesforce/label/c.CitizenWallets_Title';
import genericError from '@salesforce/label/c.CitizenWallets_SomethingWrong';
//FIELDS
import CASE_CONTACT_FIELD from '@salesforce/schema/Case.Contact.CardInfoCitizenWallets__c';


export default class CitizenWalletsOrchestrator extends LightningElement {
    @api recordId;
    @api cardInformation;
    @api wallets;
    @api transactionInformations;
    @track partnersList;
    @track minDate;
    @track maxDate;
    @track loading;
    @track cardCode;
    @track showAll = false;
    @track cardNotExist;
    @track errorToDisplay;
    @track walletsPerPage;
    @track transactionsPerPage;
    @track label = {
        citizenWalletsTitle,
        genericError
    }
    @track fields = [CASE_CONTACT_FIELD];

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        if (error) {
            console.log("@@@ error recordId "+this.recordId);
            console.log(error);
            this.errorToDisplay = this.label.genericError;
        } else if (data) {
            console.log("@@@ recordId "+this.recordId); 
            console.log(data); 
            console.log('cardCode ' + data.fields.Contact.value.fields.CardInfoCitizenWallets__c.value); 
            this.cardCode = data.fields.Contact.value.fields.CardInfoCitizenWallets__c.value;
            this.loading = true;
            this.getCitizenWallets(this.cardCode);
        }
    }

    getCitizenWallets(cardCode) {
        getCitizenWallets({cardCode})
        .then(data => {
            console.log('data');
            console.log(data);
            if(!data.errorMessage && data.cardInformationWrapper != null && !data.cardInformationWrapper.errorMessage) {
                this.showAll = true;
                this.cardInformation = data.cardInformationWrapper;
                this.wallets = data.walletWrappers;
                this.transactionInformations = data.transactionInformationWrappers;
                this.partnersList = data.partners;
                this.minDate = data.minDate;
                this.maxDate = data.maxDate;
                this.walletsPerPage = data.walletsPerPage;
                this.transactionsPerPage = data.transactionsPerPage;
            } else {
                console.log('no display');
                let errorMsg = data.errorMessage || data.cardInformationWrapper.errorMessage;
                throw new Error(errorMsg);
            }
        })
        .catch(error => {
            console.log('error');
            this.showAll = false;
            this.errorToDisplay = this.label.genericError;
            console.log(this.errorToDisplay);
        }).finally(() => this.loading = false);
    }
}