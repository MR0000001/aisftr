import { LightningElement, track, api } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//ACCOUNT LIST WRAPPER FIELDS
import page from '@salesforce/label/c.KMSearch_Page';
import of from '@salesforce/label/c.KMSearch_outOf';
import fiscalCode from '@salesforce/label/c.accountsList_FiscalCode';
import birthday from '@salesforce/label/c.accountsList_Birthday';
import name from '@salesforce/label/c.accountsList_Name';
import surname from '@salesforce/label/c.accountsList_Surname';
import address from '@salesforce/label/c.accountsList_Address';
import home from '@salesforce/label/c.accountsList_Home';
import add from '@salesforce/label/c.accountsList_CreateNew';
import open from '@salesforce/label/c.Generic_Open';
import attention from '@salesforce/label/c.searchAccount_Attention';
import insertFailed from '@salesforce/label/c.searchAccount_InsertFailed';
import associa from '@salesforce/label/c.searchAccount_Associa';
import research from '@salesforce/label/c.LegalEntities_Research';
//SALESFORCE OBJECTS
import ACCOUNT_OBJECT from '@salesforce/schema/Account';

export default class AccountsList extends NavigationMixin(LightningElement) {
    @api isLoading = false;
    @api accounts;
    @track error;  
    @api currentpage;  
    @api pagesize;  
    @api totalpages;
    @api showadditionalparameters = false;
    @track searchKey;
    @api accountId;
    @api canAssociateCase;
    @api isFromLegal;
    @api disableButtons = false;
    
    @track label = {
        page,
        of,
        name,
        fiscalCode,
        birthday,
        surname,
        address,
        home,
        add,
        open,
        attention,
        insertFailed,
        associa,
        research
    };  
    totalpages;  
    localCurrentPage = null;  
    isSearchChangeExecuted = false;  
   
    renderedCallback() {  
        this.isSearchChangeExecuted = true;  
        this.localCurrentPage = this.currentpage; 
        //console.log('@@@ this.accounts '+this.accounts);
        //console.log('@@@ acc');
        const event = new CustomEvent('recordsload', {
            detail: this.totalrecords
        });
    }

    newAccount(event) {
        this.disableAllButtons();

        let acc = this.accounts.find(acc => acc.fiscalCode == event.target.dataset.fiscalcode);

        const fields = {};
        fields.FirstName = acc.firstName;
        fields.LastName = acc.lastName;
        fields.Fiscal_Code__pc = acc.fiscalCode;
        fields.Registration_Number__c = acc.registrationNumber;
        fields.Identity_Card__pc = acc.identityCard;
        fields.Gender__pc = acc.gender;
        fields.PersonBirthdate = acc.birthdayDate;
        fields.Birthday_Place__pc = acc.birthdayPlace;
        fields.Birthday_Zone__pc = acc.birthdayZone;
        fields.Birthday_Nation__pc = acc.birthdayNation;
        fields.Citizenship__pc = acc.citizenship;
        fields.Flag_Stato__pc = acc.flagStatus;
        fields.Civil_Status__pc = acc.civilStatus;
        fields.Family_Code__pc = acc.familyCode;
        fields.Death_Date__pc = acc.deathDate;
        fields.PersonOtherStreet = acc.homeData;
        fields.PersonOtherPostalCode = acc.homePostalCode;
        fields.PersonOtherCity = acc.homeCity;
        fields.PersonOtherState = acc.homeState;
        fields.PersonOtherCountry = acc.homeCountry;
        fields.Street_Code_Residence__pc = acc.stateCodeResidence;
        fields.Residence_Lot__pc = acc.residenceLot;
        fields.Town_Hall_Residence__pc = acc.townHallResidence;
        fields.Staircase_Residence__pc = acc.staircaseResidence;
        fields.Internal_Number__pc = acc.internalNumber;
        fields.Residence_Floor__pc = acc.residenceFloor;
        fields.Immigration_City__pc = acc.immigrationCity;
        fields.Immigration_State__pc = acc.immigrationState;
        fields.Immigration_Date__pc = acc.immigrationDate;
        fields.Immigration_Province__pc = acc.immigrationProvince;
        fields.Spouse_Registration_Number__pc = acc.spouseRegistrationNumber;
        fields.Family_Relation__pc = acc.familyRelation;
        fields.Starting_Date_Relationship__pc = acc.startingDateRelationShip;
        fields.Starting_Date_Domicile__pc = acc.startingDateDomicile;
        fields.Educational_Qualification__pc = acc.educationalQualification;

        const recordInput = {};
        recordInput.apiName = ACCOUNT_OBJECT.objectApiName;
        recordInput.fields = fields;
        //console.log('recordInput -> ', recordInput);
        createRecord(recordInput)
                .then(data => {
                    //console.log('data -> ', data);
                    //console.log('this.canAssociateCase -> ', this.canAssociateCase);
                    this.accountId = data.id;
                    //console.log('this.accountId: ' + this.accountId);
                    if ( this.canAssociateCase ) {
                        //console.log('data.id -> ', data.id);
                        this.sendAccountToAssociateFromAdd();
                    } else if(this.isFromLegal) {
                        this.handleSearchSigeud();
                    } else {
                        this.navigateToRecord(this.accountId);
                    }
                }).catch(error => {
                    //console.log(error);
                    if(error.body != undefined) {
                        this.showToast(String(this.label.attention), String(this.label.insertFailed));
                        //console.log('error body message: ' + error.body.message);
                        //console.log('error body statusCode: ' + error.body.statusCode);
                        //console.log('error body errorCode: ' + error.body.errorCode);
                    }
                });

        //console.log('Finished inserting new record');
    }

    sendAccountToAssociateFromAdd() {
        const selectedEvent = new CustomEvent('associateaccounttocase', {
            detail: {
                idToAssociate: this.accountId
            }
        });
        //console.log('selectedEvent -> ', selectedEvent);
        this.dispatchEvent(selectedEvent);
        //console.log('dispatched');
    }

    openAccount(event) {
        if ( this.canAssociateCase ) {
            const selectedEvent = new CustomEvent('showcardaccount', {
                detail: {
                    show: true,
                    idToShow: event.target.dataset.id
                }
            });
            this.dispatchEvent(selectedEvent);
        } else {
            this.dispatchEvent(new CustomEvent('startloading'));
            var accountId = event.target.dataset.id;
            this.navigateToRecord(accountId);
            //console.log('@@@ event');
            this.dispatchEvent(new CustomEvent('navigation'));
            this.dispatchEvent(new CustomEvent('stoploading'));
            //console.log('@@@ setLoading');
        }
    }

    navigateToRecord(accountId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }

    associateAccountToCase(event) {
        this.disableAllButtons();
        //console.log('event.target.dataset.id -> ' , event.target.dataset.id);
        const selectedEvent = new CustomEvent('associateaccounttocase', {
            detail: {
                idToAssociate: event.target.dataset.id
            } 
        });
        this.dispatchEvent(selectedEvent);        
    }
    
    showToast(theTitle, theMessage) {
		const event = new ShowToastEvent({
			title: theTitle,
			message: theMessage,
			variant: "error"
        });
		this.dispatchEvent(event);
    }

    showSpinner(){
        const selectedEvent = new CustomEvent('handlespinner', {
            detail: {
                show: true
            }
        });
        this.dispatchEvent(selectedEvent);        
    }

    closeSpinner(){
        const selectedEvent = new CustomEvent('handlespinner', {
            detail: {
                show: false
            }
        });
        this.dispatchEvent(selectedEvent);        
    }

    disableAllButtons() {
        this.disableButtons = true;
    }

    enableAllButtons() {
        this.disableButtons = false;
    }

    handleSearchSigeud(event) {
        this.disableAllButtons();
        const selectedEvent = new CustomEvent('searchsigeud', {
            detail: {
                personAccountId : this.accountId
            } 
        });
        this.dispatchEvent(selectedEvent);
        this.enableAllButtons();
    }
}