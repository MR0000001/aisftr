// import { updateRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import getCaseTag from '@salesforce/apex/CaseCreationController.getCaseTag';

//FIELDS
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import CASE_TAG_FIELD from '@salesforce/schema/Case.Case_Tag__c';
import ID_FIELD from '@salesforce/schema/Case.Id';
import RT_FIELD from '@salesforce/schema/Case.RecordTypeId';
import CURRENTQUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import SPECIFICATION_FIELD from '@salesforce/schema/Case.Case_Specification__c';
import TOPIC_SERVICE_FIELD from '@salesforce/schema/Case.Case_Topic_Service__c';
import THEME_AREA_FIELD from '@salesforce/schema/Case.Case_Theme_Area__c';
import ESTIMATED_QUEUE_FIELD from '@salesforce/schema/Case.Estimated_Queue__c';
import ADDRESS_FIELD from '@salesforce/schema/Case.Street_Address__c';
import ADDRESS_NUMBER from '@salesforce/schema/Case.Number_Address__c';
import ADDRESS_LETTER from '@salesforce/schema/Case.Letter_Address__c';
import MUNICIPALITY_CATEGORY from '@salesforce/schema/Case.Municipality_Category__c';
import CASE_GEOLOCALIZATION from '@salesforce/schema/Case.Case_Geolocalization__c';
import CASE_ALERT_POLICE_WARNING_FIELD from '@salesforce/schema/Case.Case_Alert_Police_Warning__c';
import CASE_NO_REASSIGN from '@salesforce/schema/Case.Case_No_Reassign__c';
// import IS_NIC_ERROR from '@salesforce/schema/Case.Is_Nic_Error__c';
import PERSONA_FISICA from '@salesforce/schema/Case.Persona_Fisica__c';
import BUSINESS_ACCOUNT from '@salesforce/schema/Case.Case_Business_Account__c';
//LABELS
import previous from '@salesforce/label/c.caseCreation_Previous';
import save from '@salesforce/label/c.caseCreation_Save';
import insufficientAccess from '@salesforce/label/c.caseCreation_InsufficientAccess';
import cancel from '@salesforce/label/c.Cancel';
import none from '@salesforce/label/c.None';

export default class CaseCreation extends NavigationMixin(LightningElement) {
  @api fields;
  @track fieldToQuery = [STATUS_FIELD, CASE_TAG_FIELD];
  @track status;
  @track caseTagValue;
  @api caseid;
  @api personaFisica;
  @api caseBusinessAccount;
  @api typologyselected;
  @api selectedqueue;
  @api interactionselected;
  @api selectedargument;
  @api selectedspecification;
  @api selectedthemarea;
  @api estimatedQueue;
  @api selectedThematicArea;
  @api selectedArgument;
  @api selectedSpecific;
  @api fullAddress;
  @api address;
  @api letterAddress;
  @api numberAddress;
  @api municipality;
  @api contactId;
  @api accountId;
  @api serviceRequestId;
  @api origin;
  @api lat;
  @api lng;
  @api casealertpolicewarning;
  @api noReassign;
  @api municipalitycategory;
  @api subject;
  @api isCreation;
  @api nameinteraction;
  @api maintainTriplets;
  @track spin = false;
  @track disableAll = false;
  @track reminderCase = '';
  @api originalid;
  //@api isNicError;
  @api protocolNumber;
  @api oldInteraction;
  @api isonchangeselected;
  @track label = {
    previous,
    save,
    insufficientAccess,
    cancel,
    none
  };

  @track caseTagOptions = [];

  connectedCallback() {
    console.log('fields', JSON.stringify(this.fields));
    console.log('caseid', this.caseid);
    console.log('personaFisica', this.personaFisica);
    console.log('caseBusinessAccount', this.caseBusinessAccount);
    console.log('typologyselected', this.typologyselected);
    console.log('selectedqueue', this.selectedqueue);
    console.log('interactionselected', this.interactionselected);
    console.log('selectedargument', this.selectedargument);
    console.log('selectedspecification', this.selectedspecification);
    console.log('selectedthemarea', this.selectedthemarea);
    console.log('estimatedQueue', this.estimatedQueue);
    console.log('selectedThematicArea', JSON.stringify(this.selectedThematicArea));
    console.log('selectedArgument', JSON.stringify(this.selectedArgument));
    console.log('selectedSpecific', JSON.stringify(this.selectedSpecific));
    console.log('fullAddress', this.fullAddress);
    console.log('address', this.address);
    console.log('letterAddress', this.letterAddress);
    console.log('numberAddress', this.numberAddress);
    console.log('municipality', this.municipality);
    console.log('contactId', this.contactId);
    console.log('accountId', this.accountId);
    console.log('serviceRequestId', this.serviceRequestId);
    console.log('origin', this.origin);
    console.log('lat', this.lat);
    console.log('lng', this.lng);
    console.log('casealertpolicewarning', this.casealertpolicewarning);
    console.log('noReassign', this.noReassign);
    console.log('municipalitycategory', this.municipalitycategory);
    console.log('subject', this.subject);
    console.log('isCreation', this.isCreation);
    console.log('nameinteraction', this.nameinteraction);
    console.log('maintainTriplets', this.maintainTriplets);
    console.log('originalid', this.originalid);
    console.log('isNicError', this.isNicError);
    console.log('protocolNumber', this.protocolNumber);
    console.log('oldInteraction', this.oldInteraction);
    console.log('isonchangeselected', this.isonchangeselected);

    getCaseTag({ recordTypeId: this.typologyselected }).then((value) => {
      console.log(value);
      this.caseTagOptions = value;
    });

    this.fields = JSON.parse(JSON.stringify(this.fields));
    for (let f in this.fields) {
      if (this.fields[f].fieldName == 'Subject') {
        this.fields[f].isSubjectPrePopulated = true;
      } else {
        this.fields[f].isSubjectPrePopulated = false;
      }
      if (this.fields[f].fieldName == 'Case_Tag__c') {
        this.fields[f].isCaseTag = true;
      } else {
        this.fields[f].isCaseTag = false;
      }
    }
    this.subject =
      this.subject != null && this.subject != '' && this.subject != this.selectedspecification
        ? this.subject
        : this.selectedspecification;

    console.log('case creation connnected component account id ', this.accountId);
    console.log('case creation connnected component contact id ', this.contactId);
    console.log('case creation connected callback isonchangeselected ', this.isonchangeselected);
  }

  @wire(getRecord, { recordId: '$caseid', fields: '$fieldToQuery' })
  wiredRecord({ error, data }) {
    console.log('error -> ', error);
    console.log('data -> ', data);
    if (data) {
      this.status = data.fields.Status.value;
      this.caseTagValue = data.fields.Case_Tag__c.value;
    }
  }

  @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
  caseObjectInfo;

  handleSubjectChange(event) {
    console.log('event.detail.value');
    console.log(event.detail.value);
    this.subject = event.detail.value;
  }

  handlePrevious() {
    this.nameinteraction = this.maintainTriplets ? this.nameinteraction : '';
    var params = {
      typologyselected: this.typologyselected,
      interactionselected: this.interactionselected,
      selectedqueue: this.selectedqueue,
      selectedargument: this.selectedargument,
      selectedthemarea: this.selectedthemarea,
      selectedspecification: this.selectedspecification,
      selectedargumentr: this.selectedArgument,
      selectedthemarear: this.selectedThematicArea,
      selectedspecificationr: this.selectedSpecific,
      estimatedQueue: this.estimatedQueue,
      fullAddress: this.fullAddress,
      address: this.address,
      numberAddress: this.numberAddress,
      letterAddress: this.letterAddress,
      municipality: this.municipality,
      contactId: this.contactId,
      accountId: this.accountId,
      serviceRequestId: this.serviceRequestId,
      origin: this.origin,
      caseid: this.caseid,
      lat: this.lat,
      lng: this.lng,
      casealertpolicewarning: this.casealertpolicewarning,
      municipalitycategory: this.municipalitycategory,
      subject: this.subject,
      iscreation: this.isCreation,
      nameinteraction: this.nameinteraction,
      originalid: this.originalid,
      //isNicError : this.isNicError,
      protocolNumber: this.protocolNumber,
      oldInteraction: this.oldInteraction,
      personaFisica: this.personaFisica,
      caseBusinessAccount: this.caseBusinessAccount,
      isonchangeselected: this.isonchangeselected
    };
    console.log('@@@ params ');
    console.log(params);
    const selectedEvent = new CustomEvent('previousfromcreation', { detail: params });
    //dispatching the custom event
    this.dispatchEvent(selectedEvent);
  }

  handleCancel() {
    let action;
    if (this.interactionselected == 'Sollecito') {
      action = 'noCloseTab';
    }
    const selectedEvent = new CustomEvent('filterchange', {
      detail: { action }
    });
    //dispatching the custom event
    this.dispatchEvent(selectedEvent);
  }
  handleSuccess(event) {
    console.log('handleSuccess ', JSON.stringify(event.detail));
    this.navigationToRecord(this.caseid);

    // const fields = {};

    // fields[ID_FIELD.fieldApiName] = this.caseid;
    // fields[RT_FIELD.fieldApiName] = this.typologyselected;
    // fields[CURRENTQUEUE_FIELD.fieldApiName] = this.selectedqueue;
    // fields[TYPE_FIELD.fieldApiName] = this.interactionselected;
    // fields[THEME_AREA_FIELD.fieldApiName] = this.selectedthemarea;
    // fields[TOPIC_SERVICE_FIELD.fieldApiName] = this.selectedargument;
    // fields[SPECIFICATION_FIELD.fieldApiName] = this.selectedspecification;
    // fields[ESTIMATED_QUEUE_FIELD.fieldApiName] = this.estimatedQueue;
    // fields[ADDRESS_FIELD.fieldApiName] = this.address;
    // fields[ADDRESS_NUMBER.fieldApiName] = this.numberAddress;
    // fields[ADDRESS_LETTER.fieldApiName] = this.letterAddress;
    // fields[MUNICIPALITY_CATEGORY.fieldApiName] = this.municipality == null ? '' : this.municipality.toString();
    // fields[CASE_ALERT_POLICE_WARNING_FIELD.fieldApiName] = this.casealertpolicewarning;
    // fields[CASE_NO_REASSIGN.fieldApiName] = this.noReassign;
    // //fields[IS_NIC_ERROR.fieldApiName] = this.isNicError;
    // fields[PERSONA_FISICA.fieldApiName] = this.personaFisica;
    // fields[BUSINESS_ACCOUNT.fieldApiName] = this.caseBusinessAccount;
    // if (this.municipality != null && this.municipality != '') {
    //   fields[CASE_GEOLOCALIZATION.fieldApiName] = true;
    //   fields.Geolocation__Latitude__s = this.lat;
    //   fields.Geolocation__Longitude__s = this.lng;
    // } else {
    //   fields[CASE_GEOLOCALIZATION.fieldApiName] = false;
    //   fields.Geolocation__Latitude__s = '';
    //   fields.Geolocation__Longitude__s = '';
    // }
    // console.log('@@@ success');
    // const recordInput = { fields };
    // if (this.status == 'In Creazione') {
    //   fields[STATUS_FIELD.fieldApiName] = 'New';
    // }
    // updateRecord(recordInput)
    //   .then((data) => {
    //     console.log('data from update -> ', data);
    //     if (data.fields.ReminderCase__c != undefined) {
    //       this.reminderCase = data.fields.ReminderCase__c.value;
    //     }
    //     this.navigationToRecord(this.caseid);
    //   })
    //   .catch((error) => {
    //     console.log('@@@ error - handleSuccess -> ', error);
    //     if (error.body.output.fieldErrors.Subject != null) {
    //       this.showToast('Error', error.body.output.fieldErrors.Subject[0].message, 'error', 'sticky');
    //     } else if (error.body.output.fieldErrors.Consulted_Case__c != null) {
    //       this.showToast('Error', error.body.output.fieldErrors.Consulted_Case__c[0].message, 'error', 'sticky');
    //     } else if (error.body.output.errors != null) {
    //       this.showToast('Error', error.body.output.errors[0].message, 'error', 'sticky');
    //     } else {
    //       this.showToast('Error', error.body.message, 'error', 'sticky');
    //     }
    //     this.disableAll = false;
    //     this.spin = false;
    //   });
  }

  handleError(event) {
    console.log(JSON.stringify(event.detail));
    this.disableAll = false;
    this.spin = false;
    // if (error.body.output.fieldErrors.Subject != null) {
    //   this.showToast('Error', error.body.output.fieldErrors.Subject[0].message, 'error', 'sticky');
    // } else if (error.body.output.fieldErrors.Consulted_Case__c != null) {
    //   this.showToast('Error', error.body.output.fieldErrors.Consulted_Case__c[0].message, 'error', 'sticky');
    // } else if (error.body.output.errors != null) {
    //   this.showToast('Error', error.body.output.errors[0].message, 'error', 'sticky');
    // } else {
    //   this.showToast('Error', error.body.message, 'error', 'sticky');
    // }
    if (event.detail.output.errors[0] != null && event.detail.output.errors[0].field == null) {
      console.log(JSON.stringify(event.detail.output.errors[0]));
      var errorMessage = event.detail.output.errors[0].message;
      console.log(errorMessage);
      console.log(errorMessage.includes('insufficient access rights on object id'));
      if (errorMessage.includes('insufficient access rights on object id')) {
        errorMessage = this.label.insufficientAccess;
      }
      console.log(errorMessage);
      this.showToast('Error', errorMessage, 'error');
    } else {
      this.showToast('Error', event.detail.output, 'error');
    }
  }

  navigationToRecord(caseid) {
    // console.log('this.interactionselected -> ', this.interactionselected);
    // console.log('this.reminderCase -> ', this.reminderCase);
    let action = '';
    if (this.interactionselected == 'Sollecito' && this.reminderCase != '') {
      caseid = this.reminderCase;
      console.log('navigationToRecord - this.reminderCase -> ', this.reminderCase);
      console.log('navigationToRecord - this.originalid -> ', this.originalid);
      if (this.originalid != '' && this.originalid.startsWith('500')) {
        action = 'noCloseTab';
      }
    }

    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: caseid,
        objectApiName: 'Case',
        actionName: 'view'
      }
    });

    console.log('action -> ', action);
    const filterChangeEvent = new CustomEvent('filterchange', {
      detail: { action }
    });
    this.dispatchEvent(filterChangeEvent);

    this.disableAll = false;
    this.spin = false;
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }

  handleSubmit(event) {
    this.disableAll = true;
    this.spin = true;
    console.log('handleSubmit');
    event.preventDefault();
    const fields = event.detail.fields;
    console.log('handleSubmit fields', JSON.stringify(fields));
    let caseTagValue = this.template.querySelector('[data-id="Case_Tag__c"]')?.value;
    console.log('case tag value', caseTagValue);
    console.log('label none', this.label.none);

    fields.Case_Tag__c = caseTagValue ? (caseTagValue === this.label.none ? '' : caseTagValue) : '';

    fields[ID_FIELD.fieldApiName] = this.caseid;
    fields[RT_FIELD.fieldApiName] = this.typologyselected;
    fields[CURRENTQUEUE_FIELD.fieldApiName] = this.selectedqueue;
    fields[TYPE_FIELD.fieldApiName] = this.interactionselected;
    fields[THEME_AREA_FIELD.fieldApiName] = this.selectedthemarea;
    fields[TOPIC_SERVICE_FIELD.fieldApiName] = this.selectedargument;
    fields[SPECIFICATION_FIELD.fieldApiName] = this.selectedspecification;
    fields[ESTIMATED_QUEUE_FIELD.fieldApiName] = this.estimatedQueue;
    fields[ADDRESS_FIELD.fieldApiName] = this.address;
    fields[ADDRESS_NUMBER.fieldApiName] = this.numberAddress;
    fields[ADDRESS_LETTER.fieldApiName] = this.letterAddress;
    fields[MUNICIPALITY_CATEGORY.fieldApiName] = this.municipality == null ? '' : this.municipality.toString();
    fields[CASE_ALERT_POLICE_WARNING_FIELD.fieldApiName] = this.casealertpolicewarning;
    fields[CASE_NO_REASSIGN.fieldApiName] = this.noReassign;
    fields[PERSONA_FISICA.fieldApiName] = this.personaFisica;
    fields[BUSINESS_ACCOUNT.fieldApiName] = this.caseBusinessAccount;
    if (this.municipality != null && this.municipality != '') {
      fields[CASE_GEOLOCALIZATION.fieldApiName] = true;
      fields.Geolocation__Latitude__s = this.lat;
      fields.Geolocation__Longitude__s = this.lng;
    } else {
      fields[CASE_GEOLOCALIZATION.fieldApiName] = false;
      fields.Geolocation__Latitude__s = '';
      fields.Geolocation__Longitude__s = '';
    }
    if (this.status == 'In Creazione') {
      fields[STATUS_FIELD.fieldApiName] = 'New';
    }
    this.reminderCase = fields.ReminderCase__c != undefined ? fields.ReminderCase__c : '';
    this.template.querySelector('lightning-record-edit-form').submit(fields);
  }

  get isCaseTagEmpty() {
    return this.caseTagOptions.length === 0;
  }

  get caseTagLabel() {
    return this.caseObjectInfo?.data?.fields?.Case_Tag__c?.label;
  }
}