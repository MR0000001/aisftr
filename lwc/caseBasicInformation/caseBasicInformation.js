import { LightningElement,api,track, wire } from 'lwc';
import { getRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LABELS
import basicInformation from '@salesforce/label/c.caseDetails_BasicInformation';
import interactionTypology from '@salesforce/label/c.caseDetails_interactionTypology';
import interactionDetail from '@salesforce/label/c.caseDetails_interactionDetail';
import compileRequiredFields from '@salesforce/label/c.caseDetails_compileRequiredFields';
import attention from '@salesforce/label/c.caseDetails_Attention';
import next from '@salesforce/label/c.caseDetails_Next';
import currentQueue from '@salesforce/label/c.caseDetails_currentQueue';
import cancel from '@salesforce/label/c.Cancel';
import ownerQueue from '@salesforce/label/c.caseDetails_OwnerQueue';
import noIntection from '@salesforce/label/c.caseDetails_NoInteraction';
import gedChangedInteraction from '@salesforce/label/c.caseDetails_gedChangedType';
//FIELDS
import CASE_OBJECT from '@salesforce/schema/Case';
import RT_FIELD from '@salesforce/schema/Case.RecordTypeId';
import CURRENTQUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';
import ID_FIELD from '@salesforce/schema/Case.Id';
import THEME_AREA_FIELD from '@salesforce/schema/Case.Case_Theme_Area__c';
import ESTIMATED_QUEUE_FIELD from '@salesforce/schema/Case.Estimated_Queue__c';
import SERVICE_REQUEST_FIELD from '@salesforce/schema/Case.Service_Request__c';
import TOPIC_SERVICE_FIELD from '@salesforce/schema/Case.Case_Topic_Service__c';
import SPECIFICATION_FIELD from '@salesforce/schema/Case.Case_Specification__c';
import ACCOUNT_SR_FIELD from '@salesforce/schema/Service_Request__c.Account__c';
import CONTACT_SR_FIELD from '@salesforce/schema/Service_Request__c.Contact__c';
import ORIGIN_SR_FIELD from '@salesforce/schema/Service_Request__c.SR_Origin__c';
import ADDRESS_FIELD from '@salesforce/schema/Case.Street_Address__c';
import ADDRESS_NUMBER from '@salesforce/schema/Case.Number_Address__c';
import ADDRESS_LETTER from '@salesforce/schema/Case.Letter_Address__c';
import MUNICIPALITY_CATEGORY from '@salesforce/schema/Case.Municipality_Category__c';
import CASE_ALERT_POLICE_WARNING_FIELD from '@salesforce/schema/Case.Case_Alert_Police_Warning__c';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import SUBJECT from '@salesforce/schema/Case.Subject';
import IS_NIC_ERROR from '@salesforce/schema/Case.Is_Nic_Error__c';
import PROTOCOL_NUMBER from '@salesforce/schema/Case.Protocol_Number__c';
import PERSONA_FISICA from '@salesforce/schema/Case.Persona_Fisica__c';
import BUSINESS_ACCOUNT from '@salesforce/schema/Case.Case_Business_Account__c';
// APEX METHODS
import getCaseRecordTypes from '@salesforce/apex/CaseDetailsController.getCaseRecordTypes'; 
import getUserQueues from '@salesforce/apex/CaseDetailsController.getUserQueues';
import getInteractions from '@salesforce/apex/CaseDetailsController.getInteractions';
import isUserAdminOrSuperUser from '@salesforce/apex/CaseDetailsController.isUserAdminOrSuperUser';
import getUserProfile from '@salesforce/apex/CaseDetailsController.getUserProfile';
import isUserForSortQueue from '@salesforce/apex/CaseDetailsController.isUserForSortQueue';
import LabelQueueForFirstPosition from '@salesforce/apex/CaseDetailsController.LabelQueueForFirstPosition';
export default class CaseBasicInformation extends LightningElement {
    @api recordid = '0051234567890123456';
    @api recordId;
    @api case;
    @api serviceRequest;
    @api personaFisica;
    @api caseBusinessAccount;
    @track queues;
    @track recordTypes;
    @track interactionDetails;
    @track onlyOneQueue = false;
    @track isCaseStatusWorking = false;
    @api selectedqueue;
    @api typologyselected;
    @api nameinteraction;
    @api interactionselected;
    @api caseid;
    @api accountId;
    @api contactId;
    @api thematicArea;
    @api selectedThematicArea;
    @api selectedArgument;
    @api selectedSpecific;
    @api argument;
    @api specific;
    @track interactionList;
    @api InstructorUser = false;
    @api origin;
    @track RTList;
    @api serviceRequestId;
    @api dontQuery = false;
    @track fields;
    @api estimatedQueue;
    @api fullAddress;
    @api address;
    @api letterAddress;
    @api numberAddress;
    @api municipality;
    @api lat;
    @api lng;
    @api casealertpolicewarning;
    @api isonchangeselected = false;
    @api subject;
    @track caseStatus;
    @track workingqueue;
    @api isCreation;
    @api isUserForSortQueue = false;
    @api LabelQueueForFirstPosition;
    @api originalid;
    //@api isNicError;
    @api protocolNumber;
    @api oldInteraction;

    activeSections = ['basicInformation'];
    @track label = {
        basicInformation,
        interactionTypology,
        interactionDetail,
        next,
        compileRequiredFields,
        attention,
        cancel,
        currentQueue,
        ownerQueue,
        noIntection,
        gedChangedInteraction
    };

    @wire(getRecord, { recordId: '$recordid', fields: '$fields'})
    wiredRecord({ error, data }) {
        if (error) {
        } else if (data) {
            if(this.recordid.startsWith("500")) {
                this.isCreation = false;
                this.case = data;
                if(!this.dontQuery){
                    this.selectedqueue = this.case.fields.Current_Queue__c.value;
                    this.typologyselected = this.case.fields.RecordTypeId.value;
                    this.thematicArea = this.case.fields.Case_Theme_Area__c.value;
                    this.argument = this.case.fields.Case_Topic_Service__c.value;
                    this.specific = this.case.fields.Case_Specification__c.value;
                    this.estimatedQueue = this.case.fields.Estimated_Queue__c.value;
                    this.interactionselected = this.case.fields.Type.value;
                    this.oldInteraction = this.case.fields.Type.value;
                    this.nameinteraction = this.case.fields.Type.value;
                    this.address = this.case.fields.Street_Address__c.value;
                    this.letterAddress = (this.case.fields.Letter_Address__c.value != null) ? this.case.fields.Letter_Address__c.value : '';
                    this.numberAddress = (this.case.fields.Number_Address__c.value != null) ? ', ' + this.case.fields.Number_Address__c.value : '';
                    this.fullAddress = this.address + this.numberAddress + this.letterAddress;
                    this.municipality = this.case.fields.Municipality_Category__c.value;
                    this.casealertpolicewarning = this.case.fields.Case_Alert_Police_Warning__c.value;
                    this.caseStatus = this.case.fields.Status.value;
                    this.subject = this.case.fields.Subject.value;
                    //this.isNicError = this.case.fields.Is_Nic_Error__c.value;
                    this.protocolNumber = this.case.fields.Protocol_Number__c.value;
                    this.personaFisica = this.case.fields.Persona_Fisica__c.value;
                    this.caseBusinessAccount = this.case.fields.Case_Business_Account__c.value;
                    if(this.case.fields.Geolocation__Longitude__s.value != null && this.case.fields.Geolocation__Latitude__s.value != null &&
                        this.case.fields.Geolocation__Longitude__s.value != '' && this.case.fields.Geolocation__Latitude__s.value != '') {
                        this.lng = this.case.fields.Geolocation__Longitude__s.value;
                        this.lat = this.case.fields.Geolocation__Latitude__s.value;
                    }
                    if(this.caseStatus === 'Working') {
                        this.workingqueue = this.case.fields.Current_Queue__c.value;
                        this.onlyOneQueue = true;
                        this.isCaseStatusWorking = true;
                    }
                }
                if(this.case.fields.OwnerId.value.startsWith("00G")){
                    isUserAdminOrSuperUser({})
                    .then(result =>{
                        if(!result){
                            getQueueName({queueId: this.case.fields.OwnerId.value})
                            .then(data =>{
                                if(!data.toLowerCase().includes("external")){
                                    this.showToast(this.label.attention,this.label.ownerQueue,'error',"sticky");
                                    this.disableNext = true;
                                }
                            });
                        }
                    });
                    
                }
                this.caseid = this.case.fields.Id.value;
                this.getInteractions(this.typologyselected, this.interactionselected);
                getUserProfile({})
                    .then(result =>{
                        //console.log("profilo "+result);
                        if(result == 'Istruttore'){
                            this.InstructorUser = true;
                            this.onlyOneQueue = true;
                            this.disableArgument = true;
                            this.disableSpecific = true;
                            this.disableQueue = true;
                            this.disableConfirmAddress = true;

                        }
                    });
                
            }else{
                this.isCreation = true;
                this.serviceRequest = data;
                //this.accountId = this.serviceRequest.fields.Account__c.value;
                //this.contactId = this.serviceRequest.fields.Contact__c.value;
                this.origin = this.serviceRequest.fields.SR_Origin__c.value;
                this.serviceRequestId = this.recordid;
            }
            
        }
    }

    connectedCallback() {
        if(this.recordid.startsWith("500")){
            this.fields = [PROTOCOL_NUMBER, RT_FIELD, SUBJECT, CURRENTQUEUE_FIELD, TYPE_FIELD,ID_FIELD,THEME_AREA_FIELD,TOPIC_SERVICE_FIELD,SPECIFICATION_FIELD,ESTIMATED_QUEUE_FIELD,OWNER_FIELD,ADDRESS_FIELD, ADDRESS_NUMBER, ADDRESS_LETTER, MUNICIPALITY_CATEGORY, CASE_ALERT_POLICE_WARNING_FIELD, CASE_STATUS, IS_NIC_ERROR, BUSINESS_ACCOUNT, PERSONA_FISICA, 'Case.Geolocation__Latitude__s', 'Case.Geolocation__Longitude__s'];
        }else{
            this.fields = [ORIGIN_SR_FIELD, CONTACT_SR_FIELD, ACCOUNT_SR_FIELD];
            this.disableArgument = true;
            this.disableSpecific = true;
            this.disableQueue = true;
        }
        getCaseRecordTypes({})
        .then(data =>{
            var recordTypesMap = [];
            var RTList =[];
            for(var key in data){
                recordTypesMap.push({value: key, label: data[key]});
                RTList.push(key);
            }
            this.RTList = RTList;
            this.recordTypes = recordTypesMap;
        });
        
        LabelQueueForFirstPosition({})
        .then(data => {
            this.LabelQueueForFirstPosition = data;
        });

        isUserForSortQueue({})
        .then(data => {
            this.isUserForSortQueue = data;
        });

        getUserQueues({})
        .then(data =>{
            var queuesMap = [];
            for(var key in data){
                queuesMap.push({value: data[key].Name, label: data[key].Name});
            }
            this.queues = queuesMap;
            if(this.queues.length == 1){
                this.selectedqueue = queuesMap.entries().next().value[1].value;
                this.onlyOneQueue = true;
            }

            if(this.isCaseStatusWorking) {
                queuesMap = [];
                queuesMap.push({value: this.workingqueue, label: this.workingqueue});
                this.queues = queuesMap;
                this.selectedqueue = queuesMap.entries().next().value[1].value;
            }
            //console.log('this.queues->', this.queues);
            //console.log('this.isUserForSortQueue->', this.isUserForSortQueue);
            //console.log('this.LabelQueueForFirstPosition->', this.LabelQueueForFirstPosition);
            if(this.isUserForSortQueue && this.LabelQueueForFirstPosition != '') {
                this.sortQueueForProfile();
            }
        });
        if(this.interactionselected != null && this.interactionselected != ''){
            this.getInteractions(this.typologyselected,null);
        }   
        this.isonchangeselected= false;
        console.log('case basic connnected component account id ', this.accountId);
        console.log('case basic connnected component contact id ', this.contactId);
    }

    sortQueueForProfile() {
        let newQueue = [];
        if ( this.queues.find(tax => tax.value == this.LabelQueueForFirstPosition) != undefined ) {
            newQueue.push({value: this.LabelQueueForFirstPosition, label: this.LabelQueueForFirstPosition});
            for (let index = 0; index < this.queues.length; index++) {
                if ( this.queues[index].value != this.LabelQueueForFirstPosition ) {
                    newQueue.push({value: this.queues[index].value , label: this.queues[index].label});
                }
            }
            this.queues = newQueue;
        }
    }

    getInteractions(typologyselected, caseInteraction){
        getInteractions({rtId: typologyselected})
        .then(data =>{
            var interactionsMap = [];
            var interactionList = [];
            for(var key in data){
                interactionsMap.push({value: key, label: data[key]});
                interactionList.push(key);
            }
            this.interactionDetails = interactionsMap;
            this.interactionList = interactionList;
            if (interactionList.length == 1 ) {
                this.interactionselected = interactionList[0];
                this.nameinteraction = interactionList[0];
            }
            
            if(caseInteraction!= null){
                this.interactionselected = caseInteraction;
                this.nameinteraction = caseInteraction;
            }      
            if  ( interactionList.length == 0 && this.RTList.includes(this.typologyselected) ) {
                this.showToast(this.label.attention,this.label.noIntection,'error',"sticky");
            }           
        });
      }
    validateRequiredFields(event){
      var selectedTypology = (this.typologyselected != null && this.typologyselected != '' && this.RTList.includes(this.typologyselected));
      var selectedqueue = (this.selectedqueue != null && this.selectedqueue != '');
      var interactionselected = (this.interactionselected != null && this.interactionselected != '' && this.interactionList.includes(this.interactionselected));
      return selectedTypology && selectedqueue && interactionselected;
    }
    handleQueueSelection(event){
        this.selectedqueue = event.detail.value;
      }
      handleInteractionSelection(event){
        let selectedObjectlabel  = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.nameinteraction = selectedObjectlabel;
        //console.log('this.nameinteraction -> ', this.nameinteraction);
        this.interactionselected = event.detail.value;
        this.isonchangeselected = true;
      }
    
      handleCancel(){
        let action;
        if ( this.interactionselected == 'Sollecito'  ) {
            action = 'noCloseTab';
        }          
        const selectedEvent = new CustomEvent('filterchange', {
            detail: { action }
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    } 
    handleTypologySelection(event){
        this.typologyselected = event.detail.value;
        this.getInteractions(this.typologyselected,null);
        this.isonchangeselected = true;

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

    validateTypeChanged() {
        if(this.protocolNumber && (this.oldInteraction != this.interactionselected)) {
            this.showToast(this.label.attention, this.label.gedChangedInteraction,'warning', 'dismissable');
        }
    }

    handleNext(event){
        var areValidFields = this.validateRequiredFields(event);

        this.validateTypeChanged();

        //console.log("this.estimatedQueue "+this.estimatedQueue);
        if(areValidFields) {
        var params = {
            typologyselected: this.typologyselected, 
            nameinteraction: this.nameinteraction,
            interactionselected: this.interactionselected, 
            selectedqueue: this.selectedqueue,
            selectedargument: this.argument,
            selectedthemarea: this.thematicArea,
            selectedspecification: this.specific,
            selectedargumentr: this.selectedArgument,
            selectedthemarear: this.selectedThematicArea,
            selectedspecificationr: this.selectedSpecific,
            estimatedQueue: this.estimatedQueue,
            accountId: this.accountId,
            serviceRequestId: this.serviceRequestId,
            origin: this.origin,
            contactId: this.contactId,
            fullAddress: this.fullAddress,
            address: this.address,
            numberAddress: this.numberAddress,
            letterAddress: this.letterAddress,
            municipality: this.municipality,
            caseid: this.caseid,
            lat: this.lat,
            lng: this.lng,
            casealertpolicewarning: this.casealertpolicewarning,
            isonchangeselected: this.isonchangeselected,
            subject: this.subject,
            iscreation: this.isCreation,
            originalid: this.originalid,
            //isNicError : this.isNicError,
            protocolNumber: this.protocolNumber,
            oldInteraction : this.oldInteraction,
            personaFisica : this.personaFisica,
            caseBusinessAccount : this.caseBusinessAccount
        };
        //console.log('params -> ', params);
        const selectedEvent = new CustomEvent('nextfrombi', {detail : params});
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
    }else{
        this.showToast(this.label.attention,this.label.compileRequiredFields,'error',"dismissable");
      }
    } 
}