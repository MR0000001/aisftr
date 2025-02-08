import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
//FIELDS
import CASE_ID from '@salesforce/schema/Case.Id';
import CASE_ACCOUNT_ID from '@salesforce/schema/Case.AccountId';
import CASE_CONTACT_ID from '@salesforce/schema/Case.ContactId';
import CASE_PHYSICAL_PERSON from '@salesforce/schema/Case.Persona_Fisica__c';
import CASE_BUSINESS_ACCOUNT from '@salesforce/schema/Case.Case_Business_Account__c';
//LABEL
import name from '@salesforce/label/c.LegalEntities_List_Name';
import companyName from '@salesforce/label/c.LegalEntities_List_CompanyName';
import role from '@salesforce/label/c.LegalEntities_List_Ruolo';
import cf from '@salesforce/label/c.LegalEntities_List_CF';
import piva from '@salesforce/label/c.LegalEntities_List_PIVA';
import via from '@salesforce/label/c.LegalEntities_List_Address';
import genericPage from '@salesforce/label/c.Generic_Page';
import of from '@salesforce/label/c.Generic_outOf';
import sizePage from '@salesforce/label/c.LegalEntities_List_PageSize';
import searchSigeud from '@salesforce/label/c.LegalEntities_List_SearchSigeud';
import searchSigeudButton from '@salesforce/label/c.LegalEntities_List_SearchSigeudButton';
import associate from '@salesforce/label/c.Generic_Associate';
import accountNotCreated from '@salesforce/label/c.searchAccount_KOAccountCreated';
import accountAssociated from '@salesforce/label/c.searchAccount_accountAssociated';
import attention from '@salesforce/label/c.Generic_Attention';
import legalEntitiesTableName from '@salesforce/label/c.LegalEntities_List_TableName';
import legalEntitiesTableTitle from '@salesforce/label/c.LegalEntities_List_TableTitle';
import searchByCompanyName from '@salesforce/label/c.LegalEntities_Sigeud_SearchByCompanyName';
import associateValidationError from '@salesforce/label/c.LegalEntities_List_AssociateValidationError';
import legalEntitiesTableInfo from '@salesforce/label/c.LegalEntities_List_TableInfo';
import open from '@salesforce/label/c.Generic_Open';

export default class LegalEntitiesList extends NavigationMixin(LightningElement) {
    @api caseid;
    @api records;
    @api fiscalCodeIndicated;
    @api isFromCase;
    @track isLoading = false;
    @track recordsToDisplay = [];
    @track searchRecords = [];
    @track page = 1;
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize; 
    @track totalRecordsCount = 0;
    @track totalPages = 0;
    @track isInSearch = false;
    @track disableSearch = false;
    @track disableReintegrateButton = false;
    @track label = {
        name,
        role,
        companyName,
        genericPage,
        of,
        sizePage,
        searchSigeud,
        searchSigeudButton,
        associate,
        accountNotCreated,
        accountAssociated,
        attention,
        legalEntitiesTableName,
        associateValidationError,
        searchByCompanyName,
        legalEntitiesTableInfo,
        open,
        cf,
        piva,
        via,
        legalEntitiesTableTitle
    }

    @track columns = [
        //{ label: this.label.name, fieldName: 'name', type: 'text', wrapText: true },
        { label: this.label.companyName, fieldName: 'company', type: 'text', wrapText: true },
        { label: this.label.role, fieldName: 'roleDescription', type: 'text', wrapText: true },
        { label: this.label.cf, fieldName: 'cf', type: 'text', wrapText: true },
        { label: this.label.piva, fieldName: 'piva', type: 'text', wrapText: true },
        { label: this.label.via, fieldName: 'via', type: 'text', wrapText: true }
    ];

    connectedCallback() {
        console.group('connectedCallback');
        console.log('is from case ' + this.isFromCase);
        this.disableReintegrateButton = false;
        this.toggleAssociateOrOpenButton();
        this.pageSize = Number(this.label.sizePage);
        console.log('this.pageSize ' + this.pageSize);
        console.log('this.records list');
        console.log(this.records.length);
        console.log(this.records);
        console.log(JSON.parse(JSON.stringify(this.records)));
        this.setPagesCount(this.records);
        this.displayRecordsPerPage(this.page);
        console.groupEnd('connectedCallback');
    }

    toggleAssociateOrOpenButton() {
        if(this.isFromCase) {
            this.columns.push({ type: 'button', cellAttributes: { alignment: 'center' }, typeAttributes: { label: this.label.associate, name: this.label.associate, variant: 'brand', disabled: { fieldName: 'disableAssociate' } } });
        } else {
            this.columns.push({ type: 'button', cellAttributes: { alignment: 'center' }, typeAttributes: { label: this.label.open, name: this.label.open, variant: 'brand', disabled: false } });
        }
    }

    enableInteractivity() {
        console.group('enableInteractivity');
        this.isLoading = false;
        this.disableReintegrateButton = false;
        this.disableSearch = false;
        if(this.isFromCase) {
            this.enableAssociate();
            this.eventLegalRegistry('enablelegalregistry');
        }
        console.groupEnd('enableInteractivity');
    }

    disableInteractivity() {
        console.group('disableInteractivity');
        this.isLoading = true;
        this.disableReintegrateButton = true;
        this.disableSearch = true;
        if(this.isFromCase) {
            this.disableAssociate();
            this.eventLegalRegistry('disablelegalregistry');
        } else {
            this.disableOpen();
        }
        console.groupEnd('disableInteractivity');
    }

    enableAssociate() {
        console.group('enableAssociate');
        this.columns = this.columns.map(col => {
            if(col.type === 'button') {
                col.typeAttributes.disabled = false;
            }
            return col;
        });
        //this.template.querySelector('[data-id="contactslist"]').columns = this.columns;
        console.groupEnd('enableAssociate');
    }

    disableAssociate() {
        console.group('disableAssociate');
        this.columns = this.columns.map(col => {
            if(col.type === 'button') {
                col.typeAttributes.disabled = true;
            }
            return col;
        });
        //this.template.querySelector('[data-id="contactslist"]').columns = this.columns;
        console.groupEnd('disableAssociate');
    }

    disableOpen() {
        console.group('disableOpen');
        this.columns = this.columns.map(col => {
            if(col.type === 'button') {
                col.typeAttributes.disabled = true;
            }
            return col;
        });
        console.groupEnd('disableOpen');
    }

    handleSearch(event) {
        console.group('LegalEntitiesList_handleSearch');
        console.log('this.isInSearch ' + this.isInSearch);
        if(event.target.value.length != 0) {
            this.isInSearch = true;
        } else {
            this.isInSearch = false;
        }
        this.page = 1;
        let regex = new RegExp(event.target.value, 'i');
        console.log('regex');
        console.log(regex);
        this.searchRecords = this.records.filter(row => regex.test(row.company));
        console.log('this.searchRecords');
        console.log(JSON.parse(JSON.stringify(this.searchRecords)));
        this.setPagesCount(this.searchRecords);
        this.displayRecordsPerPage(this.page);
        console.log('this.isInSearch ' + this.isInSearch);
        console.groupEnd('LegalEntitiesList_handleSearch');
    }

    handleRowAction(event) {
        console.group('handleRowAction');
        console.log(JSON.parse(JSON.stringify(event.detail)));
        this.disableInteractivity();
        if(event.detail.action.name === this.label.associate) {
            this.handleAssociate(event);
        } else {
            this.handleOpen(event);
        }
        console.groupEnd('handleRowAction');
    }

    handleOpen(event) {
        console.group('handleOpen');
        this.navigateToRecord(event.detail.row.id);
        console.groupEnd('handleOpen');
    }

    navigateToRecord(contactId) {
        console.group('navigateToRecord');    
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                objectApiName: 'Contact',
                actionName: 'view'
            }
        });
        console.groupEnd('navigateToRecord');
    }

    handleAssociate(event) {
        console.group('LegalEntitiesList_handleAssociate');
        console.log(JSON.parse(JSON.stringify(event.detail)));
        console.log(JSON.parse(JSON.stringify(event.detail.action)));
        console.log(JSON.parse(JSON.stringify(event.detail.row)));
        console.log(event.detail.row.id);
        console.log('this.caseid ' + this.caseid);

        /*
        console.log('table columns');
        console.log(this.columns);
        console.log(this.columns[this.columns.length - 1]);
        console.log(this.columns[this.columns.length - 1].typeAttributes);
        console.log(this.columns[this.columns.length - 1].typeAttributes.disabled);
        */
        
        const fields = {};
        fields[CASE_ID.fieldApiName] = this.caseid;
        fields[CASE_ACCOUNT_ID.fieldApiName] = event.detail.row.accountId;
        fields[CASE_CONTACT_ID.fieldApiName] = event.detail.row.id;
        fields[CASE_PHYSICAL_PERSON.fieldApiName] = event.detail.row.personaFisicaId;
        fields[CASE_BUSINESS_ACCOUNT.fieldApiName] = true;

        const recordInput = {fields};
        updateRecord(recordInput)
            .then((data) => {
                console.log('data from update ', data);
                this.showToast('Success', this.label.accountAssociated, 'success');
                this.closeQuickAction();
            }).catch(error => {
                console.log('error');
                console.log(error);
                console.log(error.body.output.errors[0].message);
                try {
                    if(error.body.output.errors != null) {
                        error.body.output.errors.find(err => {
                            if(err.errorCode === 'FIELD_CUSTOM_VALIDATION_EXCEPTION') {
                                this.showToast(this.label.attention, err.message, 'error');
                                
                                return;
                            }
                        });
                    } else {
                        this.showToast(this.label.attention, this.label.accountNotCreated, 'error');
                    }
                } catch(exception) {
                    this.showToast(this.label.attention, this.label.accountNotCreated, 'error');
                }
            }).finally(() => {
                this.enableInteractivity();
            });
        console.groupEnd('LegalEntitiesList_handleAssociate');
    }

    closeQuickAction() {
        console.group('closeQuickAction');
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
        console.groupEnd('closeQuickAction');
    }

    showToast(theTitle, theMessage, theVariant) {
        const event = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant
        });
        this.dispatchEvent(event);
    }
    
    setPagesCount(records) {
        console.group('LegalEntitiesList_setPagesCount');
        this.totalRecordsCount = records.length;
        this.totalPages = Math.ceil(this.totalRecordsCount / this.pageSize);

        console.log('this.totalRecordsCount ' + this.totalRecordsCount);
        console.log('this.totalPages ' + this.totalPages);
        console.log('this.pageSize ' + this.pageSize);
        console.groupEnd('LegalEntitiesList_setPagesCount');
    }

    handlePrevious() {
        console.group('handlePrevious');
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordsPerPage(this.page);
        }
        console.groupEnd('handlePrevious');
    }

    handleNext() {
        console.group('handleNext');
        console.log('this.totalPages ' + this.totalPages);
        console.log('this.page ' + this.page);
        if((this.page < this.totalPages) && this.page !== this.totalPages){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordsPerPage(this.page);
        }             
        console.groupEnd('handleNext');
    }

    handleFirst() {
        console.group('handleFirst');
        this.page = 1;
        this.displayRecordsPerPage(this.page);
        console.groupEnd('handleFirst');
    }

    handleLast() {
        console.group('handleLast');
        this.page = this.totalPages;
        this.displayRecordsPerPage(this.page);
        console.groupEnd('handleLast');
    }

    displayRecordsPerPage(page) {
        console.group('displayRecordsPerPage');
        console.log('page: ' + page);
        console.log('this.totalRecordsCount: ' + this.totalRecordsCount);
        page = (page === 0 && this.totalRecordsCount != 0) ? 1 : page;
        this.startingRecord = ((page - 1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        console.log('this.endingRecord before setting: ' + this.endingRecord);

        this.endingRecord = (this.endingRecord > this.totalRecordsCount) ? this.totalRecordsCount : this.endingRecord; 
        console.log('this.startingRecord before setting: ' + this.startingRecord);
        console.log('this.endingRecord after setting: ' + this.endingRecord);

        if(this.isInSearch) {
            this.recordsToDisplay = this.searchRecords.slice(this.startingRecord, this.endingRecord);
        } else {
            this.recordsToDisplay = this.records.slice(this.startingRecord, this.endingRecord);
        }

        this.page = page;
        this.startingRecord = this.startingRecord + 1;
        console.log('this.startingRecord after setting: ' + this.startingRecord);
        console.groupEnd('displayRecordsPerPage');
    }

    handleSigeudCallout() {
        this.disableInteractivity();
        const selectedEvent = new CustomEvent('callsigeud');
        this.dispatchEvent(selectedEvent);
        this.isLoading = false;
    }

    eventLegalRegistry(evt) {
        console.group('eventLegalRegistry');
        const selectedEvent = new CustomEvent(evt);
        this.dispatchEvent(selectedEvent);
        console.groupEnd('eventLegalRegistry');
    }
}