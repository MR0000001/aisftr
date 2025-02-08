import { LightningElement,api,wire,track } from 'lwc';
import ISRETRY from '@salesforce/schema/XC_BillingProfileLineItem__c.XC_ZuoraIntegrationIsToRetry__c';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';
import { getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import callZuoraFromRetrieveButton from '@salesforce/apex/XC_REST_Account_B.callZuoraFromRetrieveButton';
import CallZuoraSuccess from '@salesforce/label/c.XC_CL_CallZuoraSuccess';
import Retry from '@salesforce/label/c.XC_CL_RetryCallZuora';
import CallSuccess from '@salesforce/label/c.XC_CL_CallSuccess'

const fields = [ISRETRY];
export default class Xc_LWC004_RetryCallZuora extends LightningElement {
    @api recordId;
    isRetryFlag;
    label = {
        Retry
    };
    loading =false;

    @wire(getRecord, { recordId: '$recordId', fields })
    bpli;

    @api
    get isRetry() {
        console.log(getFieldValue(this.bpli.data, ISRETRY));
        return getFieldValue(this.bpli.data, ISRETRY);
    }

    set isRetry(value){
        this.isRetryFlag = value;
    }

    retryCallZuora(){
        console.log(getFieldValue(this.bpli.data, ISRETRY));
        this.loading = true;
        if(getFieldValue(this.bpli.data, ISRETRY)!=false){
            console.log('inside if');
            callZuoraFromRetrieveButton({ bpliIds : this.recordId })
            .then(result => {
                this.loading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                              title: CallSuccess,
                              message: CallZuoraSuccess,
                              variant: 'success',
                              mode: 'pester'
                          })
                 );
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                this.loading = false;
                this.handleErrors(error);
            })
        }
    }

    

    handleErrors(error){
        let allErrors = this.reduceErrors(error);
        console.log(allErrors);
        this.dispatchEvent(
            new ShowToastEvent({
                      title: 'Error !',
                      message: allErrors.join(","),
                      variant: 'error',
                      mode: 'pester'
                  })
         );
    }

    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }
        return (
            errors.filter((error) => !!error)
                .map((error) => {
                    if (Array.isArray(error.body)) {
                        return error.body.map((e) => e.message);
                    }
                    else if (error.body.output && error.body.output.errors && error.body.output.errors.length) {
                        let allErrors = [];
                        error.body.output.errors.forEach(element => {
                            allErrors.push(element.message);
                        });
                        return allErrors.join(",");
                    }else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    return error.statusText;
                })
                .reduce((prev, curr) => prev.concat(curr), [])
                .filter((message) => !!message)
        ); 
    }

}