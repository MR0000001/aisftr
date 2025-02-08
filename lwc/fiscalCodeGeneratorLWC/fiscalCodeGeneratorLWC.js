import { LightningElement, api, track, wire } from 'lwc';
import { updateRecord, getRecord} from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
//LABELS
import missingFields from '@salesforce/label/c.fiscalCode_MissingFields';
import headerTitle from '@salesforce/label/c.fiscalCode_Title';
import invalidCommunity from '@salesforce/label/c.fiscalCode_InvalidCommunity';
import errore from '@salesforce/label/c.fiscalCode_Error';
import cfExists from '@salesforce/label/c.fiscalCode_CFExists';
import cfSame from '@salesforce/label/c.fiscalCode_CFSame';
import cfDifferent from '@salesforce/label/c.fiscalCode_CFDifferent';
import cfUpdated from '@salesforce/label/c.fiscalCode_CFUpdated';
import cfInserted from '@salesforce/label/c.fiscalCode_CFInserted';
import cfCalculated from '@salesforce/label/c.fiscalCode_CFCalculated';
import cfGenericError from '@salesforce/label/c.fiscalCode_GenericError';
import cancel from '@salesforce/label/c.fiscalCode_Cancel';
import save from '@salesforce/label/c.fiscalCode_Save';
// APEX METHODS
import getComputedFiscalCode from '@salesforce/apex/FiscalCodeGeneratorController.getComputedFiscalCode';
import getExistingAccount from '@salesforce/apex/FiscalCodeGeneratorController.getExistingAccount';

export default class FiscalCodeGenerator extends  NavigationMixin(LightningElement) {
    @api recordId;
    @track existingAccountId;
    @track existingAccountName;
    @track fiscalCodeExisting;
    @track fiscalCodeGenerated;
    @track isSame = false;
    @track isDifferent = false;
    @track isError = false;
    @track isErrorExisting = false;
    @track errorMsg;
    @track recordPageUrl;
    @track isDisabled = false;
    @track label = {
        missingFields,
        invalidCommunity,
        errore,
        cfExists,
        cfUpdated,
        headerTitle,
        cfSame,
        cfDifferent,
        cfInserted,
        cfCalculated,
        cfGenericError,
        cancel,
        save
    };

    @wire(getRecord, {recordId: '$recordId', fields: ['Account.Fiscal_Code__pc']})
    wiredRecord({error, data}) {
        if(error) {
            console.log('error');
            console.log(error);
        } else if(data) {
            console.log('data existing');
            console.log(data);
            this.fiscalCodeExisting = data.fields.Fiscal_Code__pc.value;
            this.getComputedFiscalCode();
        }
    }
    
    getExistingAccount() {
        getExistingAccount({fiscalCode : this.fiscalCodeGenerated}).then((data) => {
            console.log('data ');
            console.log(data);
            this.existingAccountName = data.Name;
            this.existingAccountId = data.Id;

            this.errorMsg = this.label.cfExists;
            this.recordPageUrl = '/lightning/r/' + this.existingAccountId + '/view';
        });
    }

    getComputedFiscalCode() {
        getComputedFiscalCode({ accId : this.recordId })
        .then((data) => {
            console.log('data generated');
            console.log(data);
            this.fiscalCodeGenerated = data;
            if(this.fiscalCodeGenerated == this.fiscalCodeExisting) {
                console.log('same cf');
                this.isSame = true;
                this.isDisabled = true;
            } else {
                console.log('not same cf');
                this.isDifferent = true;
            }
        })
        .catch(error => {
            console.log('error getComputedFiscalCode ');
            console.log(error);
            this.isDisabled = true;
            if(error.body != undefined) {
                this.isError = true;
                 if(error.body.message == this.label.invalidCommunity) {
                    this.errorMsg = this.label.invalidCommunity;
                } else if(error.body.message == this.label.missingFields) {
                    this.errorMsg = this.label.missingFields;
                } else {
                    this.errorMsg = this.label.cfGenericError;
                }
            }
        });
    }

    handleSave(event) {
        if(this.isDifferent) {
            const fields = {};
            fields.Id = this.recordId;
            fields.Fiscal_Code__pc = this.fiscalCodeGenerated;

            const recordInput = {fields}

            updateRecord(recordInput)
            .then( () => {
                console.log('updateRecord');
                this.isSame = true;
                this.isDifferent = false;
                this.navigateToRecord();
            })
            .catch(error => {
                console.log('error handleSave');
                console.log(error);
                this.isError = false;
                this.isErrorExisting = true;
                this.isSame = false;
                this.isDifferent = false;
                this.isDisabled = true;
                if(error.body != undefined) {
                    if(error.body.output.errors[0].errorCode == 'DUPLICATE_VALUE') {
                        console.log('DUPLICATE_VALUE');
                        this.getExistingAccount();
                    } else {
                        this.errorMsg = this.label.cfGenericError;
                    }
                } 
            });
        }
    }

    handleCancel() {
        console.log('entered cancel');
        this.navigateToRecord();
    }

    navigateToRecord() {
        console.log('navigate');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}