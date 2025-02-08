import { LightningElement,api,track, wire } from 'lwc';
import { getRecord,updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//FIELDS
//import CASE_OBJECT from '@salesforce/schema/Case';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Case.AccountId';
import CONTACT_ID_FIELD from '@salesforce/schema/Case.ContactId';
import ACCOUNT_FIRSTNAME_FIELD from '@salesforce/schema/Case.Account.FirstName';
import ACCOUNT_LASTNAME_FIELD from '@salesforce/schema/Case.Account.LastName';
import CONTACT_MOBILE_FIELD from '@salesforce/schema/Case.ContactMobile';
import CONTACT_PHONE_FIELD from '@salesforce/schema/Case.ContactPhone';
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Case.ContactEmail';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import STREET_FIELD from '@salesforce/schema/Case.Street_Address__c';
import NUMBER_ADDRESS_FIELD from '@salesforce/schema/Case.Number_Address__c';
import LETTER_ADDRESS_FIELD from '@salesforce/schema/Case.Letter_Address__c';
import NUMBER_FIELD from '@salesforce/schema/Case.CaseNumber';
import CREATED_DATE_FIELD from '@salesforce/schema/Case.CreatedDate';
import EXTERNAL_ID_FIELD from '@salesforce/schema/Case.ExternalSystemId__c';
import SPECIFICATION_FIELD from '@salesforce/schema/Case.Case_Specification__c';
import TOPIC_SERVICE_FIELD from '@salesforce/schema/Case.Case_Topic_Service__c';
import THEME_AREA_FIELD from '@salesforce/schema/Case.Case_Theme_Area__c';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import ID_FIELD from '@salesforce/schema/Case.Id';
import SENT_TO_EXTERNAL_FIELD from '@salesforce/schema/Case.Sent_to_External__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_SUB_STATUS from '@salesforce/schema/Case.Sub_Status__c';
import INTEGRATION_WSO2 from '@salesforce/schema/Case.Integration_Update_From_WSO2__c';
import STREET_KO from '@salesforce/schema/Case.Strada_KO__c';
import EXTERNAL_AMA_ID_FIELD from '@salesforce/schema/Case.ExternalSystemId_AMALV__c';
import CURRENT_QUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';
import ESTIMATED_QUEUE_FIELD from '@salesforce/schema/Case.Estimated_Queue__c';
import PRIOR_QUEUE_FIELD from '@salesforce/schema/Case.Prior_Queue__c';
import CHECK_ANONYMOUS_FIELD from '@salesforce/schema/Case.checkAnonymous__c';
//LABELS
import attention from '@salesforce/label/c.attention';
import sendrequest from '@salesforce/label/c.AmaRequest_SendRequest';
import missingcivic from '@salesforce/label/c.AmaRequest_MissingCivic';
import anonymous from '@salesforce/label/c.AmaRequest_Anonymous';
import success from '@salesforce/label/c.AmaRequest_Success';
import error from '@salesforce/label/c.AmaRequest_Error';
import send from '@salesforce/label/c.AmaRequest_Send';
import streetnotfound from '@salesforce/label/c.AmaRequest_StreetNoFound';
import calloutError from '@salesforce/label/c.calloutError';
//APEX METHODS
import sendRequest from '@salesforce/apex/AmaRequestController.sendRequest';
import getAmaQueue from '@salesforce/apex/AmaRequestController.getAmaQueue';
import getOrgManagementCustomSetting from '@salesforce/apex/AmaRequestController.getAnonymousIds';


export default class AMARequest extends LightningElement {
    @api recordId;
    @track fields = [CONTACT_ID_FIELD, ACCOUNT_ID_FIELD, ACCOUNT_FIRSTNAME_FIELD, ACCOUNT_LASTNAME_FIELD, CONTACT_MOBILE_FIELD,CONTACT_PHONE_FIELD,THEME_AREA_FIELD,TOPIC_SERVICE_FIELD, ESTIMATED_QUEUE_FIELD, SPECIFICATION_FIELD,CONTACT_EMAIL_FIELD,DESCRIPTION_FIELD,STREET_FIELD,NUMBER_ADDRESS_FIELD,LETTER_ADDRESS_FIELD,NUMBER_FIELD,CREATED_DATE_FIELD,EXTERNAL_ID_FIELD,CASE_STATUS,CASE_SUB_STATUS,INTEGRATION_WSO2,EXTERNAL_AMA_ID_FIELD,ID_FIELD,SENT_TO_EXTERNAL_FIELD,STREET_KO,PRIOR_QUEUE_FIELD,CURRENT_QUEUE_FIELD, CHECK_ANONYMOUS_FIELD];
    @track case;
    @track loading = false;
    @track amaQueue;
    @track anonymousIds;
    @track popupMsgs = [];
    @track label = {
        send,
        success,
        error,
        sendrequest,
        streetnotfound,
        calloutError,
        missingcivic,
        attention,
        anonymous
    };
    @track sentToExternal;
    @track alreadyClicked = false;
    @api openPopup = false;

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

        getAmaQueue({})
        .then(data =>{
            this.amaQueue = data;
        });
    }

    resetPopup(event) {
        console.log('resetPopup');
        this.openPopup = event.detail.openPopup;
        this.popupMsgs = [];
    }

    handleSend() {
        console.group('Handle Send');
        console.log("@@@ recordId "+this.recordId);
        console.log("@@@ this.case");
        console.log(this.case);
        console.log('this.case.fields.Number_Address__c.value ' + this.case.fields.Number_Address__c.value);
        console.groupEnd('Handle Send');

        this.checkForPopup();
        console.log('done');
    }

    checkForPopup() {
        let finalCheck = false;
        if(this.case.fields.checkAnonymous__c.value) {
            finalCheck = true;
            this.popupMsgs.push(this.label.anonymous);
        }
        if(this.case.fields.Number_Address__c.value == null || this.case.fields.Number_Address__c.value == '') {
            finalCheck = true;
            this.popupMsgs.push(this.label.missingcivic);
        }
        if(Boolean(finalCheck)) {
            this.openPopup = finalCheck;
        } else {
            this.callout();
        }
    }

    handleCallout(event) {
        this.openPopup = event.detail.openPopup;
        this.callout();
    }

    callout() {
        if(!this.alreadyClicked) {
            this.loading = true;
            console.log("@@@ not clicked ");
            this.alreadyClicked = true;
            sendRequest({caseToSendString: this.recordId})
            .catch(error => {
                console.log('error ama');
                console.log(error);
                this.alreadyClicked = false;
            })
            .then(result => {
                if(result != undefined && result.length > 0) {
                    const fields = {};
                    fields[ID_FIELD.fieldApiName] = this.case.id;
                    if(Boolean(result[0].ExternalSystemId_AMALV__c)) {
                        this.sentToExternal = true;
                        fields[OWNER_FIELD.fieldApiName] = this.amaQueue;
                        fields[SENT_TO_EXTERNAL_FIELD.fieldApiName] = "Sync";
                        fields[STREET_KO.fieldApiName] = false;
                        fields[CASE_STATUS.fieldApiName] = 'Working';
                        fields[CASE_SUB_STATUS.fieldApiName] = 'In carico a Ente Esterno';
                        //fields[INTEGRATION_WSO2.fieldApiName] = 'AMA Linea Verde';
                        fields[EXTERNAL_AMA_ID_FIELD.fieldApiName] = result[0].ExternalSystemId_AMALV__c;
                        fields[PRIOR_QUEUE_FIELD.fieldApiName] = this.case.fields.Current_Queue__c.value;
                        fields[CURRENT_QUEUE_FIELD.fieldApiName] = this.case.fields.Estimated_Queue__c.value;
                        console.log("@@@ success ");
                        const recordInput = {fields};
                        updateRecord(recordInput)
                            .then(() => {
                                this.showToast(this.label.success,'success');
                                this.loading = false;
                        });
                    } else {
                        console.log("@@@ no success ");
                        let error;
                        this.sentToExternal = false;
                        fields[SENT_TO_EXTERNAL_FIELD.fieldApiName] = "Not Sync";
                        if(result[0].Strada_KO__c) {
                            fields[STREET_KO.fieldApiName] = result[0].Strada_KO__c;
                            error = this.label.streetnotfound
                        } else {
                            error = this.label.error;
                        }
                        const recordInput = {fields};
                        updateRecord(recordInput)
                        .then(() => {
                            this.showToast(error,'error');
                            this.loading = false;
                        });
                        this.alreadyClicked = false;
                    }
                } else {
                    console.log("@@@ exception");
                    this.sentToExternal = false;
                    this.loading = false;
                    this.alreadyClicked = false;
                    this.showToast(this.label.error,'error');
                }
            });
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