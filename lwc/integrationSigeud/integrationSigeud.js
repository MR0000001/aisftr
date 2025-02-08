import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
//LABELS
import legalEntitiesTitle from '@salesforce/label/c.LegalEntities_Title';
//FIELDS
import PA_FISCAL_CODE from '@salesforce/schema/Contact.Fiscal_Code__c';

export default class IntegrationSigeud extends NavigationMixin(LightningElement) {
    @api recordId;
    @track fiscalCodeIndicated;
    @track isFromCase = false;
    @track showComponent = false;
    @track label = {
        legalEntitiesTitle
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Fiscal_Code__pc']})
    wiredRecord({error, data}) {
        console.group('wiredRecord');
        console.log('error ' , error);
        console.log('data ', data);
        console.log('this.recordId ', this.recordId);
        if(error) {
            console.log('error');
            console.log(error);
        } else if(data) {
            console.log(data);
           this.fiscalCodeIndicated = data.fields.Fiscal_Code__pc.value;
           console.log('this.fiscalCodeIndicated ' + this.fiscalCodeIndicated);
           this.showComponent = true;
        }
        console.groupEnd('wiredRecord');
    }

    closeQuickAction() {
        console.group('IntegrationSigeud_closeQuickAction');
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
               recordId: this.recordId,
               objectApiName: "Account",
               actionName: "view"
            }
         });
        console.log('finished');
        console.groupEnd('IntegrationSigeud_closeQuickAction');        
    }
}