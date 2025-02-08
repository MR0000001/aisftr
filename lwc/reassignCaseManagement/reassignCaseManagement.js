import { LightningElement,track,api, wire } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//FIELDS
import ID_FIELD from '@salesforce/schema/Case.Id';
import CASE_ACTION_FIELD from '@salesforce/schema/Case.Case_Action__c';
import CASE_ROLE_ACTION_FIELD from '@salesforce/schema/Case.Case_Role_Action__c';
import CASE_ACTION_REASON_FIELD from '@salesforce/schema/Case.Case_Action_Reason__c';
import CASE_ACTION_COMMENT_FIELD from '@salesforce/schema/Case.Case_Action_Comment__c';
import CASE_ACTION_TRANSFER_FIELD from '@salesforce/schema/Case.Case_Action_Trasfer__c';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import CURRENTQUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';
import PRIOR_QUEUE_FIELD from '@salesforce/schema/Case.Prior_Queue__c';
import COMMUNICATION_DEPARTMENT_FIELD from '@salesforce/schema/Case.CommunicationDepartment__c';
import CASE_ACTION_FIRST_SEND_EMAIL_FIELD from '@salesforce/schema/Case.Action_Case_First_Send_Email__c';
import TAXONOMY_FIELD from '@salesforce/schema/Case.Taxonomy__c';
import REJECTION_FIELD from '@salesforce/schema/Case.Rejection__c';
import COUNT_REJECT_FIELD from '@salesforce/schema/Case.Count_Reject__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUB_STATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
import CHECK_ASSIGNMENT_FIELD from '@salesforce/schema/Case.Check_Assignment_Case__c';
//LABELS
import compilationError from '@salesforce/label/c.RejectionCaseManagement_CompilationError';
import attention from '@salesforce/label/c.HomeScreenCaseManagement_Attention';
import save from '@salesforce/label/c.RejectionCaseManagement_Save';
import back from '@salesforce/label/c.RejectionCaseManagement_Back';
import reason from '@salesforce/label/c.RejectionCaseManagement_Reason';
import comment from '@salesforce/label/c.RejectionCaseManagement_Comment';
import title from '@salesforce/label/c.ReassignCaseManagement_Title';
import warning from '@salesforce/label/c.ReassignCaseManagement_WarningDipReassign';
import queues from '@salesforce/label/c.ReassignCaseManagement_Queues';
import trueTaxonomy from '@salesforce/label/c.ReassignCaseManagement_TrueTaxonomy';
import trueCommDep from '@salesforce/label/c.ReassignCaseManagement_CommDepTrue';
import stringTooLong from '@salesforce/label/c.ReassignCaseManagement_StringTooLong';
import success from '@salesforce/label/c.ReassignCaseManagement_Success';
import recordSaved from '@salesforce/label/c.ReassignCaseManagement_RecordSaved';
import genericError from '@salesforce/label/c.GenericError_LwcServerError';
//APEX METHODS
import getQueueId from '@salesforce/apex/CaseManagementController.getQueueId';
import queuesAreActive from '@salesforce/apex/CaseManagementController.queuesAreActive';
import getDefaultQueueLabel from '@salesforce/apex/CaseManagementController.getDefaultQueueLabel';

export default class ReassignCaseManagement extends LightningElement {
    @api userRole;
    @api case;
    @api actions;
    @api reassignQueues;
    @api commentReassign;
    @api selectedQueueReassign;
    @api selectedReasonReassign;
    @api reasonsReassignment;
    @api action;
    @api recordid;
    @api originalUserRole;
    @track estimatedQueueId;
    @track showURP;
    @track showCC;
    @track showDipReass;
    @track disableSave;
    @track dipReassignId;
    @track queueInactive;
    @track priorQueueId;
    @track showSection1;
    @track maxLength = 254;
    @track defaultQueueLabel;
    @track label ={
        compilationError,
        attention,
        save,
        back,
        reason,
        comment,
        title,
        warning,
        queues,
        trueTaxonomy,
        trueCommDep,
        stringTooLong,
        success,
        recordSaved,
        genericError
    }

    connectedCallback() {
        getDefaultQueueLabel()
        .then(result => {
            this.defaultQueueLabel = result;
            console.log(this.defaultQueueLabel);

            if(this.recordid != undefined && this.case == undefined) {
                this.case.id = this.recordid;
            }
            if(this.case.fields.Estimated_Queue__c.value != null && this.case.fields.Estimated_Queue__c.value!=""){
                this.getQueueId(this.case.fields.Estimated_Queue__c.value,"estimated");
            }
            this.getQueueId(this.defaultQueueLabel,"reassigned");
            if(this.case.fields.Prior_Queue__c.value != null && this.case.fields.Prior_Queue__c.value!=""){
                this.getQueueId(this.case.fields.Prior_Queue__c.value,"prior");
            }

            var userRole = this.userRole;
            this.showInstruct = userRole == "Istruttore"
            this.showURP = userRole == "URP";
            this.showSection1 = this.showInstruct || this.showURP;
            this.showCC = (userRole == "Operatore CC");

            this.showDipReass = (this.case.fields.Current_Queue__c.value == this.defaultQueueLabel);
            if(this.reassignQueues != undefined && this.reassignQueues.length == 1){
                this.selectedQueueReassign = this.reassignQueues.entries().next().value[1].value;
            }
            if(!this.showDipReass && this.showURP){
                if(this.case.fields.Taxonomy__c.value ==true){
                    this.disableSave = true;
                    this.showToast(this.label.attention, this.label.trueTaxonomy, "dismissible");
                }
                if(this.case.fields.CommunicationDepartment__c.value ==true){
                    this.disableSave = true;
                    this.showToast(this.label.attention, this.label.trueCommDep, "dismissible");
                }
            }
        })
        .catch(error => {
            console.log('error');
            console.log(error);
            this.showToast(this.showToast(this.label.attention, this.label.genericError, "error"));
        });
    }

    getQueueId(queueName,method){
        getQueueId({queueName: queueName})
            .then(result =>{
                if(method == "estimated"){
                    this.estimatedQueueId = result;
                    this.queuesAreActive(this.estimatedQueueId, this.case.fields.Estimated_Queue__c.value) == false;
                }
                if(method == "reassigned"){
                    this.dipReassignId = result;
                }
                if(method == "prior"){
                    this.priorQueueId = result;
                }
            });
    }

    async getEstimatedQueueId(queueName) {
        this.estimatedQueueId = await getQueueId({queueName: queueName});
    }

    handleComment(event){
        this.commentReassign = event.detail.value;
    }
    handleSelectQueue(event){
        this.selectedQueueReassign = event.detail.value;
    }
    handleSelecteReason(event){
        this.selectedReasonReassign = event.detail.value;
    }

    allFieldsFilled(){
        var userRole = this.userRole;
        var isValid;
        if(userRole == "URP" || userRole == "Istruttore"){
            isValid =  (this.selectedReasonReassign != null && this.selectedReasonReassign != "" && this.commentReassign != null && this.commentReassign != "");
        }else{
            if(userRole == "Operatore CC"){
                isValid =  (this.selectedQueueReassign != null && this.selectedQueueReassign != "");
            }
        }
        return isValid;
    }

    queuesAreActive(queueId, queueName){
        queuesAreActive({queueId: queueId, queueName:queueName})
            .then(result =>{
                console.log("@@@ result queuesAreActive "+result);
                this.queueInactive = !result;
               
            });
    }

    handleSave(event){
        this.save();
    }

    async save() {
        if(!this.allFieldsFilled() && !this.showDipReass){
            this.showToast(this.label.attention,this.label.compilationError,"error", "dismissible")
            return;
        }
        
        if(this.commentReassign != null && this.commentReassign.length > 131072){
            this.showToast(this.label.attention,this.label.stringTooLong,"error", "dismissible")
            return; 
        }     
        var userRole = this.userRole;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.case.id;
        fields[CASE_ACTION_FIELD.fieldApiName] = this.action;
        fields[PRIOR_QUEUE_FIELD.fieldApiName] = this.case.fields.Current_Queue__c.value;
        fields[STATUS_FIELD.fieldApiName] = 'Working';
        fields[CASE_ACTION_TRANSFER_FIELD.fieldApiName] = '';
        
        if(userRole == "URP" && !this.showDipReass) {
            await this.getEstimatedQueueId(this.case.fields.Estimated_Queue__c.value);
            fields[CASE_ACTION_REASON_FIELD.fieldApiName] = this.selectedReasonReassign;
            fields[CASE_ACTION_COMMENT_FIELD.fieldApiName] = this.commentReassign;
            fields[OWNERID_FIELD.fieldApiName] = this.estimatedQueueId;
            console.log("@@@ fields[OWNERID_FIELD.fieldApiName] "+fields[OWNERID_FIELD.fieldApiName]);
            fields[CURRENTQUEUE_FIELD.fieldApiName] = this.case.fields.Estimated_Queue__c.value;
            fields[TAXONOMY_FIELD.fieldApiName] = true;    
            fields[REJECTION_FIELD.fieldApiName] = false;
            fields[CASE_ACTION_FIRST_SEND_EMAIL_FIELD.fieldApiName] = true;
            fields[SUB_STATUS_FIELD.fieldApiName] = 'Da Assegnare';
        }else{
            if(userRole == "Operatore CC" && !this.showDipReass){
                fields[CASE_ACTION_REASON_FIELD.fieldApiName] = "Call Back";
                fields[OWNERID_FIELD.fieldApiName] = this.selectedQueueReassign;
                fields[CURRENTQUEUE_FIELD.fieldApiName] = this.reassignQueues.find(element => element.value == this.selectedQueueReassign).label;
                fields[REJECTION_FIELD.fieldApiName] = false; 
                fields[SUB_STATUS_FIELD.fieldApiName] = 'In Lavorazione al I livello';
            }else{
                if(userRole == "Istruttore" && !this.showDipReass){
                    fields[CASE_ACTION_REASON_FIELD.fieldApiName] = this.selectedReasonReassign;
                    fields[CASE_ACTION_COMMENT_FIELD.fieldApiName] = this.commentReassign;
                    fields[OWNERID_FIELD.fieldApiName] = this.priorQueueId;
                    fields[CURRENTQUEUE_FIELD.fieldApiName] = this.case.fields.Prior_Queue__c.value;
                    fields[REJECTION_FIELD.fieldApiName] = true; 
                    fields[SUB_STATUS_FIELD.fieldApiName] = "Risolto dall'Istruttoria";
                }  
            }
        }
        if(this.case.fields.Current_Queue__c.value == this.defaultQueueLabel){
            fields[CASE_ACTION_FIELD.fieldApiName] = "Riassegnazione";
            fields[CASE_ACTION_REASON_FIELD.fieldApiName] = "Riassegnazione";
            fields[CASE_ACTION_COMMENT_FIELD.fieldApiName] = this.commentReassign;
            fields[OWNERID_FIELD.fieldApiName] = this.estimatedQueueId;
            fields[CURRENTQUEUE_FIELD.fieldApiName] = this.case.fields.Estimated_Queue__c.value;
            fields[COUNT_REJECT_FIELD.fieldApiName] = 0;
            fields[COMMUNICATION_DEPARTMENT_FIELD.fieldApiName] = true;
            if(this.case.fields.Sub_Status__c.value != "Risolto dall'Istruttoria"){
                fields[SUB_STATUS_FIELD.fieldApiName] = 'In Lavorazione al I livello';
            }
            
        }
        console.log("@@@ this.queueInactive "+this.queueInactive);
        if(this.queueInactive){
            fields[OWNERID_FIELD.fieldApiName] = this.dipReassignId;
            fields[CURRENTQUEUE_FIELD.fieldApiName] = this.defaultQueueLabel;
            fields[CHECK_ASSIGNMENT_FIELD.fieldApiName] = true;
        }
        fields[CASE_ROLE_ACTION_FIELD.fieldApiName] = this.originalUserRole == 'Super User'?this.userRole:null;

        const recordInput = {fields};
        console.log("@@@ recordInput "+recordInput);
            updateRecord(recordInput)
                .then(() => {
                    this.showToast(this.label.success,this.label.recordSaved,"success", "dismissible");
                    setTimeout(function() {
                        location.reload();
                    }, 1000);
            })
            .catch(error => {
                console.log("@@@ error "+JSON.stringify(error));
                if(userRole == "Istruttore") {
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

    }

    handleBack(event){  
        var params = {commentReassign: this.commentReassign,
            selectedQueueReassign: this.selectedQueueReassign,
            selectedReasonReassign: this.selectedReasonReassign,
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

    showToast(title, message, variant,mode){
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