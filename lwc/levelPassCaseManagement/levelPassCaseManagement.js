import { LightningElement, track, api } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//FIELDS
import CASE_ACTION_FIELD from '@salesforce/schema/Case.Case_Action__c';
import CASE_ROLE_ACTION_FIELD from '@salesforce/schema/Case.Case_Role_Action__c';
import CASE_ACTION_TRANSFER_FIELD from '@salesforce/schema/Case.Case_Action_Trasfer__c';
import CASE_ACTION_COMMENT_FIELD from '@salesforce/schema/Case.Case_Action_Comment__c';
import CASE_ACTION_REASON_FIELD from '@salesforce/schema/Case.Case_Action_Reason__c';
import OWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import CURRENTQUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';
import PRIOR_QUEUE_FIELD from '@salesforce/schema/Case.Prior_Queue__c';
import CASE_ACTION_FIRST_SEND_EMAIL_FIELD from '@salesforce/schema/Case.Action_Case_First_Send_Email__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import TAXONOMY_FIELD from '@salesforce/schema/Case.Taxonomy__c';
import REJECTION_FIELD from '@salesforce/schema/Case.Rejection__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUB_STATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
//LABELS
import compilationError from '@salesforce/label/c.RejectionCaseManagement_CompilationError';
import attention from '@salesforce/label/c.HomeScreenCaseManagement_Attention';
import save from '@salesforce/label/c.RejectionCaseManagement_Save';
import back from '@salesforce/label/c.RejectionCaseManagement_Back';
import title from '@salesforce/label/c.LevelPassCaseManagement_Title';
import modality from '@salesforce/label/c.LevelPassCaseManagement_Modality';
import mismatchErrorLevelPass from '@salesforce/label/c.LevelPassCaseManagement_SelectedQueueError';
import queues from '@salesforce/label/c.LevelPassCaseManagement_Queues';
import success from '@salesforce/label/c.ReassignCaseManagement_Success';
import recordSaved from '@salesforce/label/c.ReassignCaseManagement_RecordSaved';
//APEX METHODS
import getQueueId from '@salesforce/apex/CaseManagementController.getQueueId';
import postToChatter from '@salesforce/apex/CaseManagementController.postToChatter';
import getQueuesURP from '@salesforce/apex/CaseManagementController.getQueuesURP';

export default class LevelPassCaseManagement extends LightningElement {
    @api modalities;
    @api selectedModalityPass;
    @api selectedQueue;
    @track selectedQueueId;
    @track estimatedQueueId;
    @track queueURP;
    @api userRole;
    @api originalUserRole;
    @api case;
    @api actions;
    @api action;
    @track queues;
    @track showQueue = false;
    @track label = {
        attention,
        compilationError,
        save,
        back,
        title,
        modality,
        queues,
        success,
        recordSaved,
        mismatchErrorLevelPass
    }

    connectedCallback() {
        console.log('level pass case management connectedCallback');
        if(this.userRole == "URP"){
            this.showQueue = true;
            this.getQueueURP();
        }
        
        if(this.selectedQueue != null && this.selectedQueue != ""){
            this.getQueueId(this.selectedQueue, "selectedQueue");
        }
        this.getQueueId(this.case.fields.Estimated_Queue__c.value, "estimatedQueue");
        if(this.modalities != undefined && this.modalities.length ==1){
            this.selectedModalityPass = this.modalities.entries().next().value[1].value;
        }
    }

    getQueueURP() {
        getQueuesURP({currentQueue: this.case.fields.Current_Queue__c.value})
        .then(data =>{
            var queues = [];
            for(var key in data){
                queues.push({value: key, label: data[key]});
            }
            this.queues = queues;
        });
    }

    setQueues(data) {
        var queues = [];
        for(var key in data){
            queues.push({value: key, label: data[key]});
        }
        this.queues = queues;
    }

    getQueueId(queueName, logic){
        getQueueId({queueName: queueName})
            .then(result =>{
                if(logic == "selectedQueue"){
                    this.selectedQueueId = result;
                }
                if(logic == "estimatedQueue"){
                    this.estimatedQueueId = result;
                }
               
            });
    }
    
    handleModalitySelection(event){
        this.selectedModalityPass = event.detail.value;
    }

    handleQueueSelection(event){
        this.selectedQueue = event.detail.value;
        this.getQueueId(this.selectedQueue,"selectedQueue");
    }

    async getEstimatedQueueId(queueName) {
        this.estimatedQueueId = await getQueueId({queueName : queueName});
        console.log(this.estimatedQueueId);
    }

    handleSave(event){
        this.save();
    }

    postToChatter(caseId, caseNumber, groupId, groupName) {
        postToChatter({caseId, caseNumber, groupId, groupName})
        .catch((error) => {
            console.log('error post to chatter ', error);
        })
    }

    async regetQueueURP(currentQueue) {
        let data = await getQueuesURP({currentQueue: currentQueue});
        this.setQueues(data);
    }

    async save() {
        if(this.selectedModalityPass != null && this.selectedModalityPass != ""){
            let toUpdate = true;
            if(this.userRole == "URP" && (this.selectedQueue == null || this.selectedQueue == "")) {
                console.log('return null');
                this.showToast(this.label.attention,this.label.compilationError,"error")
                return;
            }
            const fields = {};
            console.log("case "+JSON.stringify(this.case));
            fields[ID_FIELD.fieldApiName] = this.case.id;
            fields[CASE_ACTION_FIELD.fieldApiName] = this.action;
            fields[CASE_ACTION_TRANSFER_FIELD.fieldApiName] = this.selectedModalityPass;
            fields[PRIOR_QUEUE_FIELD.fieldApiName] = this.case.fields.Current_Queue__c.value;
            fields[CASE_ACTION_FIRST_SEND_EMAIL_FIELD.fieldApiName] = true;
            fields[CASE_ACTION_COMMENT_FIELD.fieldApiName] = "";
            fields[CASE_ACTION_REASON_FIELD.fieldApiName] = "";
            fields[STATUS_FIELD.fieldApiName] = 'Working'; 
            if(this.userRole == "URP") {
                console.log('in URP', this.selectedQueueId, '  ', this.selectedQueue);
                await this.regetQueueURP(this.case.fields.Current_Queue__c.value);
                this.postToChatter(this.case.fields.Id.value, this.case.fields.CaseNumber.value, this.selectedQueueId, this.selectedQueue);
                if(Boolean(this.queues.find(q => q.value == this.selectedQueue))) {
                    fields[OWNERID_FIELD.fieldApiName] = this.selectedQueueId;
                    fields[CURRENTQUEUE_FIELD.fieldApiName] = this.selectedQueue;
                    fields[SUB_STATUS_FIELD.fieldApiName] = 'Istruttoria';
                    fields[REJECTION_FIELD.fieldApiName] = false;
                } else {
                    this.selectedQueue = '';
                    toUpdate = false;
                    this.showToast(this.label.attention,this.label.mismatchErrorLevelPass,"error")
                }
            } else {
                if(this.userRole == "Operatore CC") {
                    console.log('in Operatore CC');
                    await this.getEstimatedQueueId(this.case.fields.Estimated_Queue__c.value);
                    fields[OWNERID_FIELD.fieldApiName] = this.estimatedQueueId;
                    fields[CURRENTQUEUE_FIELD.fieldApiName] = this.case.fields.Estimated_Queue__c.value;
                    fields[TAXONOMY_FIELD.fieldApiName] = true;    
                    fields[REJECTION_FIELD.fieldApiName] = false;  
                    fields[SUB_STATUS_FIELD.fieldApiName] = 'In Lavorazione al II livello';
                } 
            }
            fields[CASE_ROLE_ACTION_FIELD.fieldApiName] = this.originalUserRole == 'Super User'?this.userRole:null;
            
            if(toUpdate) {
                const recordInput = {fields};
                updateRecord(recordInput)
                    .then(() => {
                        this.showToast(this.label.success,this.label.recordSaved,"success")
                        setTimeout(function() {
                            location.reload();
                        }, 1000);  
                })
                .catch(error => {
                    if(error.body.output.errors != undefined && error.body.output.errors.length > 0 ) {
                        this.showToast(this.label.attention, error.body.output.errors[0].message, "error");
                    } else {
                        this.showToast(this.label.attention, error.body.message, "error");
                    }
                });
            }
        } else {
            this.showToast(this.label.attention, this.label.compilationError, "error")
        }
    }

    handleBack(event) {
        var params = {selectedQueue: this.selectedQueue,
            selectedModalityPass: this.selectedModalityPass,
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
}