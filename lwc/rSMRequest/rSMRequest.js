import { LightningElement,api,track, wire } from 'lwc';
import { getRecord,updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//FIELDS
//import CASE_OBJECT from '@salesforce/schema/Case';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Case.AccountId';
import CONTACT_ID_FIELD from '@salesforce/schema/Case.ContactId';
import EXTERNAL_ID_FIELD from '@salesforce/schema/Case.ExternalSystemId__c';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import ID_FIELD from '@salesforce/schema/Case.Id';
import SENT_TO_EXTERNAL_FIELD from '@salesforce/schema/Case.Sent_to_External__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUB_STATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
import CLOSE_REASON_FIELD from '@salesforce/schema/Case.Closed_Reason__c';
import CURRENT_QUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';
import ESTIMATED_QUEUE_FIELD from '@salesforce/schema/Case.Estimated_Queue__c';
import PRIOR_QUEUE_FIELD from '@salesforce/schema/Case.Prior_Queue__c';
//LABELS
import sendrequest from '@salesforce/label/c.RSMRequest_SendRequest';
import success from '@salesforce/label/c.RSMRequest_Success';
import error from '@salesforce/label/c.RSMRequest_Error';
import send from '@salesforce/label/c.RSMRequest_Send';
import noComuneConcessione from '@salesforce/label/c.RSMNoComuneConcessione';
import calloutError from '@salesforce/label/c.calloutError';
//APEX METHODS
import sendRequest from '@salesforce/apex/RSMRequestController.sendRequest';
import getRsmQueue from '@salesforce/apex/RSMRequestController.getRsmQueue';
import getOrgManagementCustomSetting from '@salesforce/apex/RSMRequestController.getAnonymousIds';

export default class RSMRequest extends LightningElement {
    @api recordId;
    @track noComune = false;
    @track fields = [ACCOUNT_ID_FIELD,ESTIMATED_QUEUE_FIELD, CONTACT_ID_FIELD, EXTERNAL_ID_FIELD,ID_FIELD,SENT_TO_EXTERNAL_FIELD,PRIOR_QUEUE_FIELD,CURRENT_QUEUE_FIELD];
    @track case;
    @track loading = false;
    @track rsmQueue;
    @track anonymousIds;
    @track label = {
        send,
        success,
        error,
        sendrequest,
        noComuneConcessione,
        calloutError
    };
    @track sentToExternal;
    @track alreadyClicked = false;

    @wire(getRecord, { recordId: '$recordId', fields: '$fields'})
    wiredRecord({ error, data }) {
        if (error) {
            console.log("@@@ error recordId "+this.recordId);
        } else if (data) {
            console.log("@@@ recordId "+this.recordId);
                this.case = data;
                var sentToExternal = getFieldValue(this.case, SENT_TO_EXTERNAL_FIELD);
                this.sentToExternal = (sentToExternal == "Sync");
        }
    }

    connectedCallback() {
        getOrgManagementCustomSetting({}).then(data => {
            this.anonymousIds = data;
        });

        getRsmQueue({})
        .then(data =>{
            this.rsmQueue = data;
        });
    }

    handleSend(){
        console.log("@@@ recordId "+this.recordId);
        if(this.case.fields.AccountId.value == null || this.case.fields.ContactId.value == null || this.anonymousIds.includes(this.case.fields.AccountId.value) || this.anonymousIds.includes(this.case.fields.ContactId.value)) {
            this.showToast(this.label.calloutError, 'error');
        } else {
            if(!this.alreadyClicked) {
                this.loading = true;
                console.log("@@@ not clicked ");
                this.alreadyClicked = true;
                sendRequest({caseToSendString: this.recordId})
                .catch(error => {
                    console.log('error');
                    console.log(error);
                    if(error.body.message != undefined && error.body.message == this.label.noComuneConcessione) {
                        this.noComune = true;
                    }
                })
                .then(result => {
                    console.log('result');
                    console.log(result);
                    if(result == true){
                        const fields = {};
                        this.sentToExternal = true;
                        fields[ID_FIELD.fieldApiName] = this.case.id;
                        fields[OWNER_FIELD.fieldApiName] = this.rsmQueue;
                        fields[STATUS_FIELD.fieldApiName] = "Closed";
                        fields[SUB_STATUS_FIELD.fieldApiName] = "Chiuso";
                        fields[CLOSE_REASON_FIELD.fieldApiName] = "In carico a ente esterno";
                        fields[SENT_TO_EXTERNAL_FIELD.fieldApiName] = "Sync";
                        fields[PRIOR_QUEUE_FIELD.fieldApiName] = this.case.fields.Current_Queue__c .value;
                        fields[CURRENT_QUEUE_FIELD.fieldApiName] = this.case.fields.Estimated_Queue__c.value;
                        console.log("@@@ success");
                        const recordInput = {fields};
                        updateRecord(recordInput)
                            .then(() => {
                                this.showToast(this.label.success,'success');
                                this.loading = false;
                        });

                    }else{
                        const fields = {};
                        this.sentToExternal = false;
                        fields[ID_FIELD.fieldApiName] = this.case.id;
                        fields[SENT_TO_EXTERNAL_FIELD.fieldApiName] = "Not Sync";
                        const recordInput = {fields};
                        updateRecord(recordInput)
                            .then(() => {
                                if(this.noComune) {
                                    this.showToast(this.label.noComuneConcessione,'error');
                                } else {
                                    this.showToast(this.label.error,'error');
                                }

                                this.loading = false;
                        });

                        this.alreadyClicked = false;
                    }
                });
            }
        }
    }

      showToast(message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                message: message,
                variant: variant
            })
        );
    }

}