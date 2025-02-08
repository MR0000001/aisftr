import { LightningElement,api,track, wire } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//CASE-FIELDS
import CASE_ID_FIELD from '@salesforce/schema/Case.Id';
import CASE_SENT_TO_EXTERNAL_FIELD from '@salesforce/schema/Case.Sent_to_External__c';
import CASE_STATUS_FIELD from '@salesforce/schema/Case.Status';
import CASE_SUB_STATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
import CASE_BROGLIACCIO_ERROR_FIELD from '@salesforce/schema/Case.Brogliaccio_DescriptioError__c';
import CASE_BROGLIACCIO_ID_FIELD from '@salesforce/schema/Case.ExternalSystemId_Brogliaccio__c';
import CASE_ALL_CONTENT_VERSIONS_SUCCESS_FIELD from '@salesforce/schema/Case.All_Content_Versions_Integrated__c';
import CASE_CLOSED_REASON_FIELD from '@salesforce/schema/Case.Closed_Reason__c';
import CASE_COMMENT_USER_FIELD from '@salesforce/schema/Case.Comment_User__c';
import CASE_SKIP_VALIDATION_FIELD from '@salesforce/schema/Case.SkipValidation__c';
import CASE_OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import CASE_CURRENT_QUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';
import CASE_ESTIMATED_QUEUE_FIELD from '@salesforce/schema/Case.Estimated_Queue__c';
import CASE_PRIOR_QUEUE_FIELD from '@salesforce/schema/Case.Prior_Queue__c';
import CASE_N_ATTACHMENTS from '@salesforce/schema/Case.Brogliaccio_N_Attachment__c';
//APEX METHODS
import sendRequest from '@salesforce/apex/BrogliaccioRequestController.sendRequest';
import getBrogliaccioCustomSettingsAndQueue from '@salesforce/apex/CaseService.getBrogliaccioCustomSettingsAndQueue';
//LABELS
import partialsuccess from '@salesforce/label/c.BrogliaccioRequest_PartialSuccess';
import sendrequest from '@salesforce/label/c.BrogliaccioRequest_SendRequest';
import success from '@salesforce/label/c.BrogliaccioRequest_Success';
import error from '@salesforce/label/c.BrogliaccioRequest_Error';
import send from '@salesforce/label/c.BrogliaccioRequest_Send';
import calloutError from '@salesforce/label/c.calloutError';
import notSyncStatus from '@salesforce/label/c.NotSync';
import brogliaccioPoliceLocale from '@salesforce/label/c.Brogliaccio_PoliceLocaleCommentUser';

export default class BrogliaccioRequest extends LightningElement {
    @api recordId;
    //@track caseIds = [];
    @track fields = [CASE_ID_FIELD, CASE_SENT_TO_EXTERNAL_FIELD, CASE_STATUS_FIELD, CASE_SUB_STATUS_FIELD, CASE_BROGLIACCIO_ERROR_FIELD, CASE_BROGLIACCIO_ID_FIELD, CASE_ALL_CONTENT_VERSIONS_SUCCESS_FIELD, CASE_CLOSED_REASON_FIELD, CASE_COMMENT_USER_FIELD, CASE_SKIP_VALIDATION_FIELD, CASE_OWNER_FIELD, CASE_CURRENT_QUEUE_FIELD, CASE_ESTIMATED_QUEUE_FIELD, CASE_PRIOR_QUEUE_FIELD]
    @track case;
    @track contentVersion;
    @track loading = false;
    @track brogliaccioQueue;
    @track brogliaccioCustomSetting;
    @track label = {
        send,
        success,
        error,
        sendrequest,
        calloutError,
        partialsuccess,
        notSyncStatus,
        brogliaccioPoliceLocale
    };
    @track sentToExternal;
    @track alreadyClicked = false;

    @wire(getRecord, { recordId: '$recordId', fields: '$fields'})
    caseRecord({ error, data }) {
        if (error) {
            console.log("@@@ error recordId "+this.recordId);
            console.log(error);
        } else if (data) {
            console.log("@@@ recordId "+this.recordId);
            this.case = data;
            var sentToExternal = getFieldValue(this.case, CASE_SENT_TO_EXTERNAL_FIELD);
            this.sentToExternal = (sentToExternal == "Sync");
            //this.caseIds.push(this.case.fields.Id.value);
        }
    }

    connectedCallback() {
        getBrogliaccioCustomSettingsAndQueue({})
        .then(data => {
            this.brogliaccioQueue = Object.keys(data)[0];
            this.brogliaccioCustomSetting = data[this.brogliaccioQueue];

            console.log('this.brogliaccioCustomSettingsAndQueue');
            console.log(this.brogliaccioQueue);
            console.log(this.brogliaccioCustomSetting.Closed_Reason__c);
        });
    }

    convertToLocalDateFormat(date) {
        let month = String(Number(date.getMonth()) + 1);
        month = month.length == 1 ? '0'+month : month

        return date.getDate() + '/' + month + '/' + date.getFullYear();
    }

    handleSend() {
        if(!this.alreadyClicked) {
            this.alreadyClicked = true;
            this.loading = true;
            sendRequest({caseToSendString: this.recordId})
            .catch(error => {
                console.log('error Brogliaccio');
                console.log(error);
                this.alreadyClicked = false;
            })
            .then(result => {
                console.log('this.case');
                console.log(this.case);
                if(result != undefined && result.length > 0) {
                    const fields = {};
                    fields[CASE_ID_FIELD.fieldApiName] = this.case.id;
                    fields[CASE_BROGLIACCIO_ERROR_FIELD.fieldApiName] = result[0].Brogliaccio_DescriptioError__c;
                    fields[CASE_BROGLIACCIO_ID_FIELD.fieldApiName] = result[0].ExternalSystemId_Brogliaccio__c;
                    //fields[TO_BE_SENT_BROGLIACCIO.fieldApiName] = true;
                    this.sentToExternal = (result[0].sentToExternal == this.brogliaccioCustomSetting.Sent_to_External__c);
                    if(result[0].ExternalSystemId_Brogliaccio__c != null && result[0].ExternalSystemId_Brogliaccio__c != '0') {
                        let toAddToCommentUser;
                        fields[CASE_OWNER_FIELD.fieldApiName] = this.brogliaccioQueue;
                        fields[CASE_PRIOR_QUEUE_FIELD.fieldApiName] = this.case.fields.Current_Queue__c.value;
                        fields[CASE_CURRENT_QUEUE_FIELD.fieldApiName] = this.brogliaccioCustomSetting.Group_Name__c;
                        fields[CASE_SKIP_VALIDATION_FIELD.fieldApiName] = result[0].SkipValidation__c;
                        fields[CASE_STATUS_FIELD.fieldApiName] = this.brogliaccioCustomSetting.Status__c;
                        fields[CASE_SUB_STATUS_FIELD.fieldApiName] = this.brogliaccioCustomSetting.Sub_Status__c;
                        fields[CASE_SENT_TO_EXTERNAL_FIELD.fieldApiName] = this.brogliaccioCustomSetting.Sent_to_External__c;
                        fields[CASE_CLOSED_REASON_FIELD.fieldApiName] = this.brogliaccioCustomSetting.Closed_Reason__c;

                        if(Boolean(this.case.fields.Comment_User__c.value)) {
                            toAddToCommentUser = this.case.fields.Comment_User__c.value + '\n';
                        } else {
                            toAddToCommentUser = '';
                        }

                        fields[CASE_COMMENT_USER_FIELD.fieldApiName] = toAddToCommentUser + this.convertToLocalDateFormat(new Date()) + ': ' + this.label.brogliaccioPoliceLocale;
                        fields[CASE_ALL_CONTENT_VERSIONS_SUCCESS_FIELD.fieldApiName] = result[0].All_Content_Versions_Integrated__c;
                        fields[CASE_N_ATTACHMENTS.fieldApiName] = result[0].Brogliaccio_N_Attachment__c;
                        console.log("@@@ success");
                        
                        const recordInput = {fields};
                        updateRecord(recordInput)
                            .then(() => {
                                this.loading = false;
                                let msg = (result[0].All_Content_Versions_Integrated__c) ? this.label.success : this.label.partialsuccess;
                                let type = (result[0].All_Content_Versions_Integrated__c) ? 'success' : 'warning';
                                this.showToast(msg, type);
                            }).catch(error => {
                                this.alreadyClicked = false;
                                this.loading = false;
                                console.log('Error at update success');
                                console.log(error);
                            });
                    } else {
                        console.log("@@@ no success");
                        fields[CASE_SENT_TO_EXTERNAL_FIELD.fieldApiName] = this.label.notSyncStatus;
                        const recordInput = {fields};
                        updateRecord(recordInput)
                            .then(() => {
                                this.loading = false;
                                this.alreadyClicked = false;
                                this.showToast(this.label.error,'error');
                            }).catch(error => {
                                this.loading = false;
                                this.alreadyClicked = false;
                                console.log('Error at update failed');
                                console.log(error);
                            });
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

    showToast(message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                message: message,
                variant: variant
            })
        );
    }
}