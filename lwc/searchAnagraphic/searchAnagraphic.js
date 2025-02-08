import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
//APEX
import searchAccount from '@salesforce/apex/SearchAccountController.searchAccount';
import getPersonAccountGenderPicklist from '@salesforce/apex/SearchAccountController.getPersonAccountGenderPicklist';
import createAccountDraft from '@salesforce/apex/SearchAccountController.createAccountDraft';
import getRecordTypeForPersonAccount from '@salesforce/apex/SearchAccountController.getRecordTypeForPersonAccount';
import associateAccountIdToCaseById from '@salesforce/apex/SearchAccountController.associateAccountIdToCaseById';
import updateAccountDraftField from '@salesforce/apex/SearchAccountController.updateAccountDraftField';
//LABELS
import fiscalCode from '@salesforce/label/c.searchAccount_FiscalCode';
import selectGender from '@salesforce/label/c.searchAccount_SelectGender';
import dateofbirth from '@salesforce/label/c.searchAccount_BirthDay';
import gender from '@salesforce/label/c.searchAccount_Sex';
import name from '@salesforce/label/c.searchAccount_Name';
import surname from '@salesforce/label/c.searchAccount_Surname';
import searchAccountTitle from '@salesforce/label/c.searchAccount_Title';
import newAccount from '@salesforce/label/c.searchAccount_NewAccount';
import reset from '@salesforce/label/c.searchAccount_Reset';
import address from '@salesforce/label/c.searchAccount_Address';
import home from '@salesforce/label/c.searchAccount_Home';
import search from '@salesforce/label/c.searchAccount_Search';
import attention from '@salesforce/label/c.searchAccount_Attention';
import compilation from '@salesforce/label/c.searchAccount_Compilation';
import createNew from '@salesforce/label/c.searchAccount_CreateNew';
import generalError from '@salesforce/label/c.searchAccount_GeneralError';
import generalSearch from '@salesforce/label/c.searchAccount_GeneralSearch';
import searchByFC from '@salesforce/label/c.searchAccount_SearchByFC';
import invalidSearch from '@salesforce/label/c.searchAccount_invalidSearch';
import wrongCompilation from '@salesforce/label/c.searchAccount_WrongCompilation';
import invalidFiscalCode from '@salesforce/label/c.SchoolConsultation_FiscalCodeInvalid';
import accountCreated from '@salesforce/label/c.searchAccount_NewAccountCreated';
import accountNotCreated from '@salesforce/label/c.searchAccount_KOAccountCreated';
import cfEmpty from '@salesforce/label/c.searchAccount_CfEmpty';
import accountAssociated from '@salesforce/label/c.searchAccount_accountAssociated';
import legalEntitesRegistryButtonsDesc from '@salesforce/label/c.LegalEntities_Registry_ButtonsDesc';
import legalEntityPhase from '@salesforce/label/c.LegalEntities_Phase';


const PAGE_SIZE = 10;  
export default class SearchAccount extends NavigationMixin(LightningElement) {
    activeSections = ['generalSearch'];
    @api isLoading = false;
    @api accounts;
    @api totalPages;
    @api isFromCase = false;
    @track personAccountRecordTypeId;
    @track years;
    @api fiscalCodeIndicated;
    @track isFromLegal = false;
    @track birthday;
    @track firstname;
    @track lastname;
    @track sex = null;
    @track pageSize = 10;
    @track PaginationList;
    @track startPage;
    @track endPage;
    @track disableButtons = true;
    @track disableNewButton = true;
    @track searchCompleted = false;
    @track today = this.getToday();
    @track disableInput = false;
    @track label = {
		fiscalCode,
        search,
        dateofbirth,
        gender,
        name,
        surname,
        searchAccountTitle,
        newAccount,
        reset,
        address,
        home,
        compilation,
        attention,
        createNew,
        generalError,
        generalSearch,
        searchByFC,
        invalidSearch,
        wrongCompilation,
        invalidFiscalCode,
        selectGender,
        accountCreated,
        accountNotCreated,
        accountAssociated,
        legalEntitesRegistryButtonsDesc,
        legalEntityPhase,
        cfEmpty
    };

    @track genderPicklistValues = [{
        label: this.label.selectGender,
        value: null,
    }];


    @track showCardAccountToggle = false;
    @track showCardNewAccount = false;
    @api accountRecordId;
    @api accountRecordIdToShow;
    @api recordTypeIdToUse;
    @api caseid;
    @api canAssociateCase;

    @api page = 1;
    @api totalrecords;  
    @api _pagesize = PAGE_SIZE;  
    get pagesize() {  
      return this._pagesize;  
    }  
    set pagesize(value) {  
      this._pagesize = value;  
    }

    @api fiscaldata;

    @api showNewAccount() {
        console.group('showNewAccount');
        console.log('this.isFromLegal ' + this.isFromLegal);
        this.showCardAccountToggle = false;
        let listValForAccount = [this.fiscalCodeIndicated,this.firstname,this.lastname,this.sex,this.birthday];
        this.createAccountDraft(listValForAccount);
        console.groupEnd('showNewAccount');
    }

    getRecordTypeForPersonAccount(){
        getRecordTypeForPersonAccount()
        .then(data =>{
            console.log('recordTypeIdToUse -> ', data);
            this.recordTypeIdToUse = data;
        })
        .catch(error => {
            console.log("@@@ error "+JSON.stringify(error));
        });
    }

    associateAccountIdToCaseById(caseId, accountIdToAssociate){
        associateAccountIdToCaseById({caseId : caseId, accountIdToAssociate : accountIdToAssociate })
        .then(data =>{
            console.log('data ->> ', data);
            if (data) {
                this.showToast('Success', this.label.accountAssociated, 'success');
                this.closeQuickAction();
            } else {
                this.showToast('Error', this.label.accountNotCreated, 'error');
            }
            this.closeSpinner();
        })
        .catch(error => {
            console.log("@@@ error "+JSON.stringify(error));
        });
    }

    createAccountDraft(listValForAccount) {
        console.group('createAccountDraft')
        console.log('this.isFromLegal ' + this.isFromLegal);
        createAccountDraft({listValForAccount: listValForAccount})
        .then(data =>{
            console.log('data -> ', data);
            this.accountRecordId = data;
            this.showCardAccountToggle= false;
            this.showCardNewAccount = !this.showCardNewAccount;
        })
        .catch(error => {
            console.log("@@@ error "+JSON.stringify(error));
        });
        console.groupEnd('createAccountDraft')
    }

    updateAccountDraftField(AccountId) {
        console.group('updateAccountDraftField')
        updateAccountDraftField({AccountId: AccountId})
        .then(data =>{
            console.log('this.isFromLegal ' + this.isFromLegal);
            if(this.canAssociateCase) {
                this.associateAccountIdToCaseById(this.caseid, AccountId);
            } else if(this.isFromLegal) {
                const selectedEvent = new CustomEvent('redirecttolegalsearch', {
                    detail : {
                        fiscalCodeIndicated : this.fiscalCodeIndicated,
                        personAccountId : AccountId
                    }
                });
                this.dispatchEvent(selectedEvent);
                //this.closeQuickAction();
                this.showCardNewAccount = false;
                this.resetAndDisableButtons();
                //this.closeSpinner();
            }
        })
        .catch(error => {
            console.log("@@@ error "+JSON.stringify(error));
        });
        console.groupEnd('updateAccountDraftField')
    }

    handleCancelCreateAccount(){
        this.showCardNewAccount = false;
    }

    @wire(getPersonAccountGenderPicklist)
    genderPopulator({error, data}) {
        if(data) {
            for(let key in data) {
                console.log(key);
                const option = {
                    label: key,
                    value: data[key]
                };
                this.genderPicklistValues = [...this.genderPicklistValues, option];
            }
        } else if(error) {
            console.log('error');
            console.log(error);
        }
    }
    
    connectedCallback() {
        console.group('connectedCallback');
        this.resetAllToggle();
        this.canAssociateCase = ( this.caseid != undefined ? true: false );
        console.log('this.canAssociateCase ' + this.canAssociateCase);
        this.getRecordTypeForPersonAccount();
        console.groupEnd('connectedCallback')
    }

    resetAllToggle() {
        this.showSpinner();
        this.showCardNewAccount = false;
        this.searchCompleted = false;
        this.showCardAccountToggle = false;
        this.resetFilters();
        this.closeSpinner();
    }

    checkFiscalCode(fiscalCode){
      var patt = new RegExp("^([A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMNPQRSTUV]{3}[A-Z]{1})$|([0-9]{11})$");
      return patt.test(fiscalCode);
    }  

    getToday(){
        var d = new Date();
        var day = d.getDate();
        var year = d.getFullYear();
        var month = d.getMonth()+1;

        return year+'-'+month+'-'+day;
    }

    resetFilters(){
        //this.template.querySelector('form').reset();
        this.resetInputsAndButtons();
        this.eventLegalRegistry('enablelegalregistry');
        this.isFromLegal = false;
    }

    resetInputsAndButtons() {
        this.fiscalCodeIndicated = null;
        this.firstname = null;
        this.birthday = null;
        this.lastname = null;
        this.sex = null;
        this.searchCompleted = false;
        this.disableButtons = true;
        this.disableNewButton = true;
    }

    resetFiscalCodeField() {
        this.fiscalCodeIndicated = null;
    }

    resetDataFields() {
        this.firstname = null;
        this.birthday = null;
        this.lastname = null;
        this.sex = null;
    }

    handleFiscalCodeChange(event){
        this.handleSelection('fiscalCode',event.target.value);
    }
    handleNameChange(event){
        this.handleSelection('name',event.target.value);
    }
    handleSurnameChange(event){
        this.handleSelection('surname',event.target.value);
    }
    handleDateChange(event){
        this.handleSelection('birthday',event.target.value);
    }
    handleSexChange(event){
        this.handleSelection('sex',event.target.value);
    }
    startLoading(event){
        this.Loading = true;
    }
    stopLoading(event){
        this.Loading = false;
    }
    showCardAccount(event) {
        this.accountRecordIdToShow = event.detail.idToShow;
        this.showCardAccountToggle = event.detail.show;
    }
    closeCardAccount(event){
        this.showCardAccountToggle = false;
    }
    closecardnewaccount(event){
        console.log('closecardnewaccount');
        console.log('this.fiscalCodeIndicated ' +  this.fiscalCodeIndicated);
        this.showCardNewAccount=false;
    }
    closecreateaccountform(event) {
        console.group('closecreateaccountform');
        let newAccountId = event.detail.idToSave;
        if(!event.detail.isFiscalCodeNull) {
            this.fiscalCodeIndicated = event.detail.fiscalCodeIndicated;
        }
        console.log('canAssociateCase ' + this.canAssociateCase);
        console.log('isFromLegal ' + this.isFromLegal);
        if(this.canAssociateCase) {
            this.updateAccountDraftField(newAccountId);
        } else if(this.isFromLegal) {
            if(!event.detail.isFiscalCodeNull) {
                this.fiscalCodeIndicated = this.fiscalCodeIndicated.toUpperCase();
                this.updateAccountDraftField(newAccountId);
            } else {
                this.showToast(this.label.attention, this.label.cfEmpty, 'error');
            }
        } else {
            this.showToast('Success', this.label.accountCreated, 'success');
            this.navigationToRecord(this.caseid);
            // oppure reset e resto this.resetAllToggle();
        }
        console.groupEnd('closecreateaccountform');
    }

    navigationToRecord(caseid){

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseid,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
        const filterChangeEvent = new CustomEvent('filterchange');
        this.dispatchEvent(filterChangeEvent);
    }

    closeQuickAction() {
        console.log('closeQA');
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    handleSearchSigeud(event) {
        const selectedEvent = new CustomEvent('redirecttolegalsearch', {
            detail : {
                fiscalCodeIndicated : this.fiscalCodeIndicated,
                personAccountId : event.detail.personAccountId
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    associateaccounttocase(event) {
        this.showSpinner();
        console.log('this.caseid -> ' , this.caseid);
        console.log('event.detail.idToAssociate -> ', event.detail.idToAssociate);
        this.associateAccountIdToCaseById(this.caseid, event.detail.idToAssociate);
    }

    handleSelection(origin,value){
        this.searchCompleted = false;
        this.disableButtons = false;
        this.disableNewButton = true;
        if(origin == 'fiscalCode'){
            this.resetDataFields();
            this.fiscalCodeIndicated = value.toUpperCase();
            
        }else{
            this.resetFiscalCodeField();
            if(origin == 'name'){
                this.firstname = value;
            }else{
                if(origin == 'surname'){
                    this.lastname = value;
                } else if(origin == 'birthday') {
                    this.birthday = value;
                    console.log("@@@ value "+value);
                } else if(origin == 'sex') {
                    this.sex = value;
                    console.log("@@@ value "+value);
                }
            }
        }
        
        this.disableButtons = !this.validateAllFieldsFilled();
    }

    validateAllFieldsFilled(){
        var nullFiscalCode = (this.fiscalCodeIndicated == null || this.fiscalCodeIndicated == "");
        var nullFirstName = (this.firstname == null || this.firstname == "");
        var nullBirthday = (this.birthday == null || this.birthday == "");
        var nullLastName = (this.lastname == null || this.lastname == "");
        var nullSex = (this.sex == null || this.sex == "");
        return (!nullFiscalCode) || (!nullFirstName && !nullBirthday && !nullLastName && !nullSex);
    }
    validateGeneralSearch(){
        var nullFiscalCode = (this.fiscalCodeIndicated == null || this.fiscalCodeIndicated == "");
        var nullFirstName = (this.firstname == null || this.firstname == "");
        var nullBirthday = (this.birthday == null || this.birthday == "");
        var nullLastName = (this.lastname == null || this.lastname == "");
        var nullSex = (this.sex == null || this.sex == "");
        return (nullFiscalCode && (nullFirstName || nullBirthday || nullLastName || nullSex) && (!nullFirstName || !nullBirthday || !nullLastName || !nullSex));
    }
    invalidSearch(){
        var nullFiscalCode = (this.fiscalCodeIndicated == null || this.fiscalCodeIndicated == "");
        var nullFirstName = (this.firstname == null || this.firstname == "");
        var nullBirthday = (this.birthday == null || this.birthday == "");
        var nullLastName = (this.lastname == null || this.lastname == "");
        var nullSex = (this.sex == null || this.sex == "");
        return (!nullFiscalCode && (!nullFirstName || !nullBirthday || !nullLastName || !nullSex));
    }

    validatesInputFields(){
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }

    eventLegalRegistry(evt) {
        console.group('eventLegalRegistry');
        const selectedEvent = new CustomEvent(evt);
        this.dispatchEvent(selectedEvent);
        console.groupEnd('eventLegalRegistry');
    }

    searchAccounts(event) {
        console.log('this.isFromLegal ' + this.isFromLegal);
        console.log('this.isFromCase ' + this.isFromCase);
        if(!this.isFromLegal && this.isFromCase) {
            console.log('disabling searchAccounts');
            this.eventLegalRegistry('disablelegalregistry');
        }
        this.disableButtons = true;
        this.disableNewButton = true;
        this.disableInput = true;
        var allFieldsFilled = this.validateAllFieldsFilled();
        var allValid = this.validatesInputFields();
        var generaleSearchGeneral = this.validateGeneralSearch();
        var invalidSearch = this.invalidSearch();
        if(!this.checkFiscalCode(this.fiscalCodeIndicated) && this.fiscalCodeIndicated != null && this.fiscalCodeIndicated != ""){
            this.showToast(String(this.label.attention), String(this.label.invalidFiscalCode), 'error');

            this.disableButtons = false;
            this.disableNewButton = false;
            this.disableInput = false;
            return;
        }
        if(allFieldsFilled && allValid && !invalidSearch) {
            this.showSpinner();
            searchAccount( { name:this.firstname, surname:this.lastname, birthday:this.birthday, fiscalCode: this.fiscalCodeIndicated, sex : this.sex})
            .then(data => {
                this.accounts = data;
                this.handleFirst();
                this.startPage = 0;
                this.endPage = this._pagesize-1;  
                this.totalrecords = this.accounts.length;
                this.totalPages = Math.ceil(this.totalrecords / this._pagesize);  
                this.pagination(this.accounts);
                this.searchCompleted = true;
                this.closeSpinner();
                if(this.totalrecords == 0) {
                    this.disableNewButton = false;
                    this.showToast(String(this.label.attention), String(this.label.createNew), 'error');
                    this.searchCompleted = false;
                }
                this.disableButtons = false;
                this.disableInput = false;
            });
        }else{
            if(!allValid){
                this.showToast(String(this.label.attention), this.label.generalError, 'error');
            }else{
                if(invalidSearch){
                    this.showToast(String(this.label.attention), String(this.label.invalidSearch), 'error');
                }else{
                    if(validateGeneralSearch){
                            this.showToast(String(this.label.attention), String(this.label.wrongCompilation), 'error');
                        
                    }
                }
            }
            this.disableButtons = false;
            this.disableNewButton = false;
            this.disableInput = false;
        }
    }

    showToast(theTitle, theMessage, theVariant) {
        const event = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant
        });
        this.dispatchEvent(event);
    }

    handlePrevious() {  
        if (this.page > 1) {  
          this.page = this.page - 1;  
        }
        var Paginationlist = [];
        var counter = 0;
        var start = this.startPage;
        for(var i= start-this._pagesize; i < start ; i++){
            if(i > -1){
                    Paginationlist.push(this.accounts[i]);
                counter ++;
            }else{
                start++;
            }
        }
        this.startPage = start - counter;
        this.endPage = this.endPage - counter;
        this.PaginationList = Paginationlist;
      }

    handleNext() {  
        if (this.page < this.totalPages){
            this.page = this.page + 1;  
        }
        var Paginationlist = [];
        var counter = 0;
        for(var i = this.endPage + 1; i < this.endPage + this._pagesize + 1; i++){
            if(this.accounts.length > i){
                    Paginationlist.push(this.accounts[i]);
            }
            counter ++ ;
        }
        this.startPage = this.startPage + counter;
        this.endPage = this.endPage + counter;
        this.PaginationList = Paginationlist;
    }

    pagination(accounts) {
        var PaginationList = [];
        for(var i=0; i<this.pagesize; i++){
            if(accounts.length > i){
                PaginationList.push(accounts[i]);
            }
        }
        this.PaginationList = PaginationList;
    }  

    handleFirst() {  
        this.page = 1;
        var Paginationlist = [];
        var size = Math.min(this.accounts.length, this.pageSize);
        for(var i= 0; i < size ; i++){
            if(i > -1){
                    Paginationlist.push(this.accounts[i]);
            }
        }
        this.startPage = 0;
        this.endPage = this.pageSize-1;
        this.PaginationList = Paginationlist;
    }  
    
    handleLast() {  
        this.page = this.totalPages;
        var Paginationlist = [];
        for(var i= (this.totalPages-1) * this._pagesize; i < this.totalrecords ; i++){
            if(i > -1){
                    Paginationlist.push(this.accounts[i]);
            }
        }
        this.startPage = (this.totalPages-1) * this._pagesize;
        this.endPage = this.totalPages * this._pagesize-1;
        this.PaginationList = Paginationlist;  
    }

    newAccount(event) {
        console.log('newAccount this.isFromLegal ' + this.isFromLegal);
        console.log('newAccount this.canAssociateCase ' +  this.canAssociateCase);
        if ( this.canAssociateCase || this.isFromLegal ) {
            this.showNewAccount();
        } else {
            console.log("@@@ "+((this.fiscalCodeIndicated != null && this.fiscalCodeIndicated != '')? this.fiscalCodeIndicated: null));
            console.log("@@@ "+((this.birthday != null && this.birthday != '')? this.birthday: null));
            console.log("@@@ "+((this.firstname != null && this.firstname != '')? this.firstname: null));
            console.log("@@@ "+((this.lastname != null && this.lastname != '')? this.lastname: null));
            console.log('@@@ this.recordTypeIdToUse '+this.recordTypeIdToUse);
            const defaultValues = encodeDefaultFieldValues({
                FirstName: this.firstname,
                LastName: this.lastname,
                PersonBirthdate: this.birthday,
                Fiscal_Code__pc: this.fiscalCodeIndicated,
                Gender__pc: this.sex
                //recordTypeId: this.recordTypeIdToUse
            });
            console.log("@@@ defaultValues "+defaultValues);
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Account',
                    actionName: 'new'
                },
                state: {
                    recordTypeId: this.recordTypeIdToUse,
                    defaultFieldValues: defaultValues
                }
            });
            this.resetFilters();
        }
    }   

    beforeUnloadHandler(event) {
        console.log('before unload handler has been called. -> ', event);
    }


    handlespinner(event) {
        if ( event.detail.show ) {
            this.showSpinner();
        } else {
            this.closeSpinner();
        }
    }

    showSpinner(){
        this.isLoading = true;
        this.disableButtons = true;
    }

    closeSpinner() {
        this.isLoading = false;
        this.disableButtons = false;
    }

    @api autoSearch(fiscalCode) {
        console.group('autoSearch');
        console.log('fiscal code ' + fiscalCode);
        this.fiscalCodeIndicated = fiscalCode;
        this.canAssociateCase = false;
        console.log('fiscalCodeIndicated ' + this.fiscalCodeIndicated);
        this.isFromLegal = true;

        if(this.fiscalCodeIndicated != null) {
            this.searchAccounts();
        }
        console.groupEnd('autoSearch')
    }

    @api resetAndDisableButtons() {
        console.group('resetAndDisableButtons');        
        this.isFromLegal = true;
        this.disableInput = true;
        this.resetInputsAndButtons();
        console.groupEnd('resetAndDisableButtons');
    }

    @api enableInput() {
        console.group('enableInput');
        this.disableInput = false;
        this.isFromLegal = false;
        if(this.isFromCase) {
            this.canAssociateCase = true;
        }
        console.groupEnd('enableInput');
    }
}