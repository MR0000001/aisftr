import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
//FIELDS
import CASE_ACTION_FIELD from '@salesforce/schema/Case.Case_Action__c';
import CASE_ROLE_ACTION_FIELD from '@salesforce/schema/Case.Case_Role_Action__c';
import CASE_ACTION_REASON_FIELD from '@salesforce/schema/Case.Case_Action_Reason__c';
import CASE_ACTION_COMMENT_FIELD from '@salesforce/schema/Case.Case_Action_Comment__c';
import CASE_ACTION_TRANSFER_FIELD from '@salesforce/schema/Case.Case_Action_Trasfer__c';
import COUNT_REJECT_FIELD from '@salesforce/schema/Case.Count_Reject__c';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import CURRENTQUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';
import PRIOR_QUEUE_FIELD from '@salesforce/schema/Case.Prior_Queue__c';
import REJECTION_FIELD from '@salesforce/schema/Case.Rejection__c';
import TAXONOMY_FIELD from '@salesforce/schema/Case.Taxonomy__c';
import COMMUNICATION_DEPARTMENT_FIELD from '@salesforce/schema/Case.CommunicationDepartment__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUB_STATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
//LABELS
import rejection from '@salesforce/label/c.RejectionCaseManagement_Title';
import reason from '@salesforce/label/c.RejectionCaseManagement_Reason';
import compilationError from '@salesforce/label/c.RejectionCaseManagement_CompilationError';
import attention from '@salesforce/label/c.HomeScreenCaseManagement_Attention';
import save from '@salesforce/label/c.RejectionCaseManagement_Save';
import back from '@salesforce/label/c.RejectionCaseManagement_Back';
import comment from '@salesforce/label/c.RejectionCaseManagement_Comment';
import trueCommDep from '@salesforce/label/c.RejectionCaseManagement_CommDepTrue';
import trueRejection from '@salesforce/label/c.RejectionCaseManagement_RejTrue';
import stringTooLong from '@salesforce/label/c.ReassignCaseManagement_StringTooLong';
import success from '@salesforce/label/c.ReassignCaseManagement_Success';
import recordSaved from '@salesforce/label/c.ReassignCaseManagement_RecordSaved';
import genericError from '@salesforce/label/c.GenericError_LwcServerError';
import caseOriginApp from '@salesforce/label/c.CASE_ORIGIN_APP';
import caseOriginCdc from '@salesforce/label/c.CASE_ORIGIN_CDC';
//METHODS
import getDefaultQueueLabel from '@salesforce/apex/CaseManagementController.getDefaultQueueLabel';
export default class RejectionCaseManagement extends LightningElement {
    @api case;
    @api reasons;
    @api selectedReason;
    @api rejectionComment;
    @api actions;
    @api action;
    @api priorQueue;
    @api dipReassignQueue;
    @api userRole;
    @api originalUserRole;
    @track disableSave = false;
    @track maxLength = 254;
    @track defaultQueueLabel;
    @track label = {
        rejection,
        reason,
        attention,
        compilationError,
        save,
        back,
        comment,
        trueCommDep,
        trueRejection,
        stringTooLong,
        success,
        recordSaved,
        genericError,
        caseOriginApp,
        caseOriginCdc
    };

    connectedCallback() {
        getDefaultQueueLabel()
        .then(result => {
            this.defaultQueueLabel = result;
            console.log(this.defaultQueueLabel);
            if(this.case.fields.CommunicationDepartment__c.value ==true){
                this.disableSave = true;
                this.showToast(this.label.attention, this.label.trueCommDep);
            }
    
            if(this.case.fields.Rejection__c.value == true){
                this.disableSave = true;
                this.showToast(this.label.attention, this.label.trueRejection);
            }
        })
        .catch(error => {
            console.log('error');
            console.log(error);
            this.showToast(this.showToast(this.label.attention, this.label.genericError, "error"));
        })
    }

    handleReasonSelection(event){
        this.selectedReason = event.detail.value;
    }
    handleCommentModification(event){
        this.rejectionComment = event.detail.value;
    }
    handleSave(event){
        if(this.rejectionComment.length> 131072){
            this.showToast(this.label.attention,this.label.stringTooLong,"error")
            return; 
        }  
        if(this.rejectionComment != null && this.rejectionComment != "" && this.selectedReason != null && this.selectedReason != "" ){
            const fields = {};
            console.log("case "+JSON.stringify(this.case));
            fields[ID_FIELD.fieldApiName] = this.case.id;
            fields[CASE_ACTION_FIELD.fieldApiName] = this.action;
            fields[CASE_ACTION_REASON_FIELD.fieldApiName] = this.selectedReason;
            fields[CASE_ACTION_COMMENT_FIELD.fieldApiName] = this.rejectionComment;
            fields[PRIOR_QUEUE_FIELD.fieldApiName] = this.case.fields.Current_Queue__c.value;
            fields[REJECTION_FIELD.fieldApiName] = true;
            fields[REJECTION_FIELD.fieldApiName] = true;
            fields[STATUS_FIELD.fieldApiName] = 'Working';
            fields[CASE_ACTION_TRANSFER_FIELD.fieldApiName] = '';
            if(this.selectedReason != "Necessità di Informazioni Aggiuntive"){
                fields[SUB_STATUS_FIELD.fieldApiName] = 'Rigettato';
            }else{
                fields[SUB_STATUS_FIELD.fieldApiName] = 'In attesa di informazioni aggiuntive';
            }
            
            var countReject = this.case.fields.Count_Reject__c.value;
            if(countReject == null){
                countReject = 0;
            }
            
            if(this.selectedReason != "Necessità di Informazioni Aggiuntive"){
                countReject = countReject+1;
                fields[COUNT_REJECT_FIELD.fieldApiName] = countReject;
            }
            if(this.priorQueue != null && this.priorQueue != ""){
                fields[CURRENTQUEUE_FIELD.fieldApiName] = this.case.fields.Prior_Queue__c.value;
            }
            if(this.case.Origin == this.label.caseOriginApp || this.case.Origin == this.label.caseOriginCdc){
                fields[CURRENTQUEUE_FIELD.fieldApiName] = this.defaultQueueLabel;
            }
            console.log("@@@ countReject "+countReject);
            if(countReject <4){
                if(this.priorQueue != null && this.priorQueue != ""){
                    fields[OWNERID_FIELD.fieldApiName] = this.priorQueue;
                }
                fields[COMMUNICATION_DEPARTMENT_FIELD.fieldApiName] = false;
            }else{
                if(countReject == 4 || this.priorQueue == null || this.priorQueue == ""){
                    fields[OWNERID_FIELD.fieldApiName] = this.dipReassignQueue;
                    fields[CURRENTQUEUE_FIELD.fieldApiName] = this.defaultQueueLabel;
                    console.log("@@@ fields[CURRENTQUEUE_FIELD.fieldApiName] "+fields[CURRENTQUEUE_FIELD.fieldApiName]);
                    if(countReject == 4){
                        fields[COMMUNICATION_DEPARTMENT_FIELD.fieldApiName] = true;
                        fields[TAXONOMY_FIELD.fieldApiName] = false;
                    }
                }
            }
            
            fields[COUNT_REJECT_FIELD.fieldApiName] = countReject;
            fields[CASE_ROLE_ACTION_FIELD.fieldApiName] = this.originalUserRole == 'Super User'?this.userRole:null;

            const recordInput = {fields};
            console.log("@@@ recordInput " , recordInput);
            updateRecord(recordInput)
                .then(() => {
                    console.log("@@@ success ");
                    this.showToast(this.label.success,this.label.recordSaved,"success");
                    setTimeout(function() {
                        location.reload();
                    }, 1000);
            })
            .catch(error => {
                console.log("@@@ error "+JSON.stringify(error));
                if(this.userRole == "Istruttore") {
                    this.showToast(this.label.success, this.label.recordSaved, "success", "sticky");
                    const closeclickedevt = new CustomEvent('closetab', {
                        detail: { close },
                    });            
                    this.dispatchEvent(closeclickedevt); 
                } else {
                    if ( error.body.output.errors != undefined && error.body.output.errors.length > 0 ) {
                        this.showToast(this.label.attention,error.body.output.errors[0].message,"error", "dismissible");
                    } else {
                        this.showToast(this.label.attention,error.body.message,"error", "dismissible");
                    }
                }
            });
        }else{
            this.showToast(this.label.attention,this.label.compilationError,"error")
        }
    }

    handleBack(event){
        var params = {selectedReason: this.selectedReason,
            rejectionComment: this.rejectionComment,
            actionsHomeScreen: this.actions,
            userRole: this.userRole,
            originalUserRole: this.originalUserRole
        };
        const selectedEvent = new CustomEvent('back', {
            detail : params
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);           
        
    }

    showToast(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    
    showToast(title, message, variant, mode){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode           
            })
        );
    }

}