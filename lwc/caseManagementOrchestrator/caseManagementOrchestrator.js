import { LightningElement,api,track,wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//APEX METHODS
import getCurrentUserRole from '@salesforce/apex/CaseManagementController.getCurrentUserRole';
import getActionsCaseManagement from '@salesforce/apex/CaseManagementController.getActionsCaseManagement';
import getReasonsCaseManagement from '@salesforce/apex/CaseManagementController.getReasonsCaseManagement';
import getQueueId from '@salesforce/apex/CaseManagementController.getQueueId';
import getModalitiesCaseManagement from '@salesforce/apex/CaseManagementController.getModalitiesCaseManagement';
import getQueuesCaseManagement from '@salesforce/apex/CaseManagementController.getQueuesCaseManagement';
import getDefaultQueueLabel from '@salesforce/apex/CaseManagementController.getDefaultQueueLabel';
//FIELDS
import CURRENTQUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';
import REJECTION_FIELD from '@salesforce/schema/Case.Rejection__c';
import INSTRUCTOR_PRIOR_QUEUE_FIELD from '@salesforce/schema/Case.Istruttore_Prior_Queue__c';
import COMMUNICATION_DEPARTMENT_FIELD from '@salesforce/schema/Case.CommunicationDepartment__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import PRIOR_QUEUE_FIELD from '@salesforce/schema/Case.Prior_Queue__c';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import COUNT_REJECT_FIELD from '@salesforce/schema/Case.Count_Reject__c';
import TAXONOMY_FIELD from '@salesforce/schema/Case.Taxonomy__c';
import ESTIMATED_QUEUE_FIELD from '@salesforce/schema/Case.Estimated_Queue__c';
import SUB_STATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
//LABELS
import trueTaxonomy from '@salesforce/label/c.CaseManagementOrchestrator_TrueTaxonomy';
import attention from '@salesforce/label/c.HomeScreenCaseManagement_Attention';
import genericError from '@salesforce/label/c.GenericError_LwcServerError';

export default class CaseManagementOrchestrator extends LightningElement {
    @track reassign;
    @api recordId;
    @api originalUserRole;
    @track showHomeScreen;
    @track showReassignment;
    @track showRejection;
    @track showChangeLevel;
    @api caseRecord;
    @track fields = [CURRENTQUEUE_FIELD,REJECTION_FIELD,INSTRUCTOR_PRIOR_QUEUE_FIELD,COMMUNICATION_DEPARTMENT_FIELD,ID_FIELD,PRIOR_QUEUE_FIELD,ORIGIN_FIELD,COUNT_REJECT_FIELD, TAXONOMY_FIELD,ESTIMATED_QUEUE_FIELD,SUB_STATUS_FIELD, CASE_NUMBER];
    @api userRole;
    @api actionsHomeScreen;
    @api reasons;
    @api selectedRejectionReason;
    @api modalities;
    @api selectedModalityPass;
    @api selectedQueuePass;
    @api rejectionComment;
    @api selectedHomeScreenAction;
    @api priorQueue;
    @api dipReassignQueue;
    @api reassignQueues;
    @api commentReassign;
    @api selectedQueueReassign;
    @api selectedReasonReassign;
    @api reasonsReassignment;
    @track defaultQueueLabel;
    @track label = {
        trueTaxonomy,
        attention,
        genericError
    }


    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    wiredRecord({ error, data }) {
        if(data) {
            getDefaultQueueLabel({})
            .then(result => {
                console.log("@@@result "+result);
                this.defaultQueueLabel = result;
                console.log("@@@data "+JSON.stringify(data));
                this.caseRecord = data;
                this.reassign = (data.fields.Current_Queue__c.value == this.defaultQueueLabel);
                if(this.reassign){
                    this.showHomeScreen = false;
                    this.showReassignment = true;
                }
                if(data.fields.Prior_Queue__c.value != null && data.fields.Prior_Queue__c.value != ""){
                    getQueueId({queueName: data.fields.Prior_Queue__c.value})
                    .then(result =>{
                       this.priorQueue = result;
                    });
                }

                getQueueId({queueName: this.defaultQueueLabel})
                .then(result =>{
                   this.dipReassignQueue = result;
                });
            })
            .catch(error => {
                console.log('error');
                console.log(error);
                this.showToast(this.showToast(this.label.attention, this.label.genericError, "error"));
            });
        } else if (error) {

        }
    }

    connectedCallback() {
        console.log('recordId -> ', this.recordId);
        getCurrentUserRole({})
        .then(result => {
            this.originalUserRole = result;
            console.log('originalUserRole -> ', this.originalUserRole);
            this.userRole = result;
            this.userRole = (this.userRole == 'Responsabile CC') ? 'Operatore CC' : (this.userRole == 'Specialista Brogliaccio') ? 'URP' : this.userRole;
            this.showHomeScreen = true && !this.showReassignment;
            getActionsCaseManagement({userRole: this.userRole})
            .then(data =>{
                var actionsForHomeScreen = [];
                for(var key in data){
                    actionsForHomeScreen.push({value: key, label: data[key]});
                }
                this.actionsHomeScreen = actionsForHomeScreen;
            });
        });
    }

    handleBackRejection(event){
        this.showRejection = false;
        this.showHomeScreen = true;
        this.selectedRejectionReason = event.detail.selectedReason;
        this.rejectionComment = event.detail.rejectionComment;
        this.setHomeScreenForSuperUser(event);
    }

    setHomeScreenForSuperUser(event) {
        console.log('setHomeScreenForSuperUser');
        console.log(event.detail.actionsHomeScreen);
        if(this.originalUserRole == 'Super User') {
            this.userRole = event.detail.userRole;
            this.actionsHomeScreen = event.detail.actionsHomeScreen;
            console.log('setHomeScreenForSuperUser ' + this.userRole);
            console.log(this.actionsHomeScreen);
        }
    }

    handleBackPassLevel(event){
        this.showChangeLevel = false;
        this.showHomeScreen = true;
        this.selectedQueuePass = event.detail.selectedQueue;
        this.selectedModalityPass = event.detail.selectedModalityPass;
        this.setHomeScreenForSuperUser(event);
    }
    handleBackReassignment(event){
        this.showReassignment = false;
        this.showHomeScreen = true;
        this.commentReassign = event.detail.commentReassign;
        this.selectedQueueReassign = event.detail.selectedQueueReassign;
        this.selectedReasonReassign = event.detail.selectedReasonReassign;
        console.log('handleBackReassignment');
        this.setHomeScreenForSuperUser(event);
    }

    handleCloseTab(event) {
        console.log('in caseManagementOrchestrator invoco closetab');
        const closeclickedevt = new CustomEvent('closetab', {
            detail: { close },
        });

         // Fire the custom event
        this.dispatchEvent(closeclickedevt);         
    }

    handleNextHomeScreen(event){
        this.showHomeScreen = false;
        var selectedAction = event.detail.selectedAction;
        var selectedHomeScreenAction = selectedAction.toLowerCase();
        this.setHomeScreenForSuperUser(event);
        console.log("selectedHomeScreenAction "+selectedHomeScreenAction);
        if(selectedHomeScreenAction.includes("passaggio")){
            if(this.caseRecord.fields.Taxonomy__c.value == true && this.userRole == 'Operatore CC'){
                this.selectedModalityPass="";
                this.selectedQueuePass="";
                this.showToast(this.label.attention, this.label.trueTaxonomy, "error");
                this.showHomeScreen = true;
                return;
            }
            console.log("showHomeScreen "+this.showHomeScreen);
            this.showChangeLevel = true;
            if(this.selectedHomeScreenAction != selectedAction){
                this.getModalitiesCaseManagement(this.userRole, selectedAction);
            }
        }else{
            if(selectedHomeScreenAction.includes("riassegnazione")){
                this.showReassignment = true;
                console.log("@@@ this.userRole "+this.userRole);
                console.log("@@@ this.selectedHomeScreenAction "+this.selectedHomeScreenAction);
                console.log("@@@ selectedAction "+selectedAction);
                if(this.selectedHomeScreenAction != selectedAction){
                    console.log("@@@ first control");
                    this.selectedQueueReassign = "";
                    this.selectedReasonReassign=""; 
                    this.commentReassign="";
                    if(this.userRole == 'Operatore CC'){
                        console.log("@@@ second control");
                        this.getQueuesCaseManagement();
                    }else{
                        if(this.userRole == 'URP' || this.userRole == "Istruttore"){
                            this.getReasonsCaseManagement(this.userRole, "Riassegnazione");
                        }
                    }
                    
                }
            }else{
                console.log("rigetto "+selectedHomeScreenAction.includes("rigetto"));
                if(selectedHomeScreenAction.includes("rigetto")){
                    this.showRejection = true;
                    this.selectedRejectionReason="";
                    this.rejectionComment="";
                    console.log("showRejection "+this.showRejection);
                    if(this.selectedHomeScreenAction != selectedAction){
                        this.getReasonsCaseManagement(this.userRole, "Rigetto");
                    }
                }
            }
        }
        this.selectedHomeScreenAction = selectedAction;
    }

    getQueuesCaseManagement(){
        getQueuesCaseManagement({})
            .then(data =>{
                var queues = [];
                for(var key in data){
                    queues.push({value: key, label: data[key]});
                }
                console.log("@@@ queues "+queues);
                this.reassignQueues = queues;
            });
    }

    getReasonsCaseManagement(userRole, action){
        getReasonsCaseManagement({userRole: userRole, action: action})
            .then(data =>{
                var reasons = [];
                for(var key in data){
                    reasons.push({value: key, label: data[key]});
                }
                if(action == "Rigetto"){
                    this.reasons = reasons;
                    if(reasons.length == 1){
                        this.selectedRejectionReason = reasons.entries().next().value[1].value;
                    }
                }else{
                    if(action == "Riassegnazione"){
                        this.reasonsReassignment = reasons;
                        if(reasons.length == 1){
                            this.selectedReasonReassign = reasons.entries().next().value[1].value;
                        }
                    } 
                }
                
            });
    }

    getModalitiesCaseManagement(userRole, action){
        getModalitiesCaseManagement({userRole: userRole, action: action})
            .then(data =>{
                var modalities = [];
                for(var key in data){
                    modalities.push({value: key, label: data[key]});
                }
                this.modalities = modalities;
                if(this.modalities.length ==1){
                    this.selectedModalityPass = modalities.entries().next().value[1].value;
                }
            });
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

}