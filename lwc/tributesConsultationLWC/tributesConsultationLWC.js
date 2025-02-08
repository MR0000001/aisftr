import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
//APEX
import getPositions from '@salesforce/apex/ConsultationController.getPositions';
import getCase from '@salesforce/apex/ConsultationController.getCase';
//import getAccountsList from '@salesforce/apex/ConsultationController.getAccountsList';
import getTributesTypologies from '@salesforce/apex/ConsultationController.getTributesTypologies';
import fetchTributesWrapper from '@salesforce/apex/ConsultationController.fetchTributesWrapper';
import getOrgManagementCustomSetting from '@salesforce/apex/ConsultationController.getAnonymousIds';
//FIELDS
import ID_FIELD from '@salesforce/schema/Case.Id';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUB_STATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
//LABELS
import fiscalCode from '@salesforce/label/c.SchoolConsultation_FiscalCode';
import positions from '@salesforce/label/c.TributesConsultation_Positions';
import year from '@salesforce/label/c.TributesConsultation_Year';
import tributeTypology from '@salesforce/label/c.TributesConsultation_TributeTypology';
import fillFiscalCode from '@salesforce/label/c.Consultation_FillFiscalCode';
import tributesTitle from '@salesforce/label/c.TributesConsultation_Title';
import attention from '@salesforce/label/c.TributesConsultation_Attention';
import compilation from '@salesforce/label/c.TributesConsultation_CompilationError';
import errorConnection from '@salesforce/label/c.TributesConsultation_errorConnection';
import search from '@salesforce/label/c.SchoolConsultation_Search';
import choosePosition from '@salesforce/label/c.Consultation_ChoosePosition';
import chooseYear from '@salesforce/label/c.Consultation_ChooseYear';
import chooseTributeTypology from '@salesforce/label/c.Consultation_ChooseTributeTypology';
import tributesHeader from '@salesforce/label/c.Consultation_TributesHeader';
import invalidFiscalCode from '@salesforce/label/c.SchoolConsultation_FiscalCodeInvalid';
import FCnotFound from '@salesforce/label/c.Tributes_FiscalCodeNotFound';
import calloutError from '@salesforce/label/c.calloutError';

const PAGE_SIZE = 10;  
export default class TributesConsultationLWC extends NavigationMixin(LightningElement) {
    @api isLoading = false;
    @api tributes;
    @api showadditionalparameters = false;
    //@api accounts;
    /** 
     * @track searchCompleted = false;
     * 
    */
    @api totalPages;
    @api tributesYear;
    @api tributesTypology;
    @api recordId;
    @track years;
    @track selectedYear;
    @track positions;
    @track selectedPosition;
    @track tributesTypologies;
    @track selectedTribute;
    @track fiscalCodeIndicated;
    @track pageSize = 10;
    @api PaginationList;
    @api startPage;
    @api endPage;
    @track anonymousIds;
    @track accountId;
    @track contactId;
    @track label = {
		fiscalCode,
		positions,
		year,
        tributeTypology,
        fillFiscalCode,
        choosePosition,
        chooseYear,
        chooseTributeTypology,
        tributesTitle,
        search,
        attention,
        compilation,
        invalidFiscalCode,
        tributesHeader,
        errorConnection,
        FCnotFound,
        calloutError

    };
    @api page = 1;  
    @api totalrecords;  
    @api _pagesize = PAGE_SIZE;  
    get pagesize() {  
      return this._pagesize;  
    }  
    set pagesize(value) {  
      this._pagesize = value;  
    }
    connectedCallback() {
        getOrgManagementCustomSetting({}).then(data => {
            this.anonymousIds = data;
        });

        this.getYears();
        getCase({recordId: this.recordId})
        .then(result =>{
            this.accountId = result.AccountId;
            this.contactId = result.ContactId;
            if (this.accountId != null && result.Account.IsPersonAccount ) {
                this.fiscalCodeIndicated = ( result.Account.Fiscal_Code__pc != null ) ? result.Account.Fiscal_Code__pc.toUpperCase():null;                
            } else {
                this.fiscalCodeIndicated = ( this.contactId != null && result.Contact.Fiscal_Code_contact__c != null ) ? result.Contact.Fiscal_Code_contact__c.toUpperCase():null;
            }
        });
		getPositions({
			})
			.then(data => {
				var typologyMap = [];
				for(var key in data){
					typologyMap.push({value: key, label: data[key]});
				}
                this.positions = typologyMap;
			})
			.catch(error => {
				this.showToast("Error", error);
            });
        getTributesTypologies({
			})
			.then(data => {
				var typologyMap = [];
				for(var key in data){
					typologyMap.push({value: data[key], label: data[key]});
				}
				this.tributesTypologies = typologyMap;
			})
			.catch(error => {
				this.showToast("Error", error);
            });
        }
    getYears(){
        
        var yearMap = [];
        var currentDate = new Date();
        var currentYear = currentDate.getFullYear();
        for(var i = 0; i<= 100; i++){
            yearMap.push({label: String(currentYear-i), value: String(currentYear-i)});
        }
        this.years = yearMap;
        
    }
    /** 
    closeModal() {    
        // to close modal window set 'searchCompleted' tarck value as false
        this.searchCompleted = false;
    }
    */
   handleNavigate() {
    this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
            componentName: "c__TributesResultsContainer"
        }
        ,
        state: {
            c__tributes: JSON.stringify(this.tributes),
            c__tributesYear: this.tributesYear,
            c__tributeTypology: this.tributeTypology,
            c__startPage: this.startPage,
            c__endPage: this.endPage,
            c__totalrecords: this.totalrecords,
            c__totalPages: this.totalPages,
            c__showadditionalparameters: this.showadditionalparameters,
            c__year: this.selectedYear,
            c__fiscalCode: this.fiscalCodeIndicated,
            c__positions: this.positions.find(position => position.value == this.selectedPosition).label
        }
    });
}
    handleFiscalCodeChange(event){
        
        this.handleSelection('fiscalCode',event.target.value);
    }
    handleTypologySelection(event){
        this.handleSelection('typology',event.target.value);
    }
    handlePositionSelection(event){
        this.handleSelection('position',event.target.value);
    }
    handleYearSelection(event){
        this.handleSelection('year',event.detail.value);
    }
    handleSelection(origin,value){
        this.searchCompleted = false;
        if(origin == 'fiscalCode'){
            this.fiscalCodeIndicated = value.toUpperCase();;
        }else{
            if(origin == 'typology'){
                this.selectedTribute = value;
            }else{
                if(origin == 'position'){
                    this.selectedPosition = value;
                    this.showadditionalparameters = (value == '2');
                }else{
                    if(origin == 'year'){
                        this.selectedYear = value;
                    }
                }
            }
        }
    }
    checkFiscalCode(fiscalCode){
        var patt = new RegExp("^([A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMNPQRSTUV]{3}[A-Z]{1})$|([0-9]{11})$");
        return patt.test(fiscalCode);
    }

    getCase(){
        console.log("@@@ ent ");
        console.log("@@@ recordId "+this.recordId);
        getCase({recordId: this.recordId})
        .then(data => {
            console.log("@@@ data 2 "+JSON.stringify(data));
            
            if(data.Status == "New" && (data.Case_Action__c == null || data.Case_Action__c == "")){
                console.log("@@@ Entrato");
                console.log("@@@ data.Id "+data.Id);
                const fields = {};
                fields[ID_FIELD.fieldApiName] = data.Id;
                fields[STATUS_FIELD.fieldApiName] = "Working";
                fields[SUB_STATUS_FIELD.fieldApiName] = 'In lavorazione al I livello';

                const recordInput = {fields };
                console.log("@@@ recordInput "+JSON.stringify(recordInput));
                updateRecord(recordInput)
                    .then(() => {
                        console.log("@@@ saved record")
                })
                .catch(error => {
                    console.log("@@@ error "+JSON.stringify(error));
                });
            }
        })
        .catch(error => {
            console.log("@@@ error "+JSON.stringify(error));
            this.showToast("Error", error);
        });
    }

    searchTributes(event){
        
        var nullFiscalCode = (this.fiscalCodeIndicated == null || this.fiscalCodeIndicated == "");
        var nullTributes = (this.selectedTribute == null || this.selectedTribute == "");
        var nullPosition = (this.selectedPosition == null || this.selectedPosition == "");
        var nullYear = (this.selectedYear == null || this.selectedYear == "");
        this.getCase();
        if(!this.checkFiscalCode(this.fiscalCodeIndicated) && this.fiscalCodeIndicated != null && this.fiscalCodeIndicated != ""){
            this.showToast(String(this.label.attention), String(this.label.invalidFiscalCode));
            return;
        }
        if(this.accountId == null || this.contactId == null || this.anonymousIds.includes(this.accountId) || this.anonymousIds.includes(this.contactId)) {
            this.showToast(this.label.attention, this.label.calloutError);
        } else if(nullFiscalCode||nullTributes||nullPosition||nullYear){
            this.showToast(String(this.label.attention), String(this.label.compilation));
        } else {
            //this.tributes = fetchTributesWrapper( { fiscalCode:this.fiscalCodeIndicated, position:this.selectedPosition, year:this.selectedYear, tributeTypology: this.selectedTribute});
            this.isLoading = true;
            fetchTributesWrapper( { fiscalCode:this.fiscalCodeIndicated, position:this.selectedPosition, year:this.selectedYear, tributeTypology: this.selectedTribute})
            .then(data => {
                if(data.errore == undefined || data.errore == null){
                    this.tributes = data.posizioniPerAnno[0].posizioniPerTributo[0].posizioneContribuente;
                    this.tributesYear = data.posizioniPerAnno[0].annoRiferimento;
                    this.tributeTypology = data.posizioniPerAnno[0].posizioniPerTributo[0].tipoTributo;
                    this.handleFirst();
                    this.startPage = 0;
                    this.endPage = this._pagesize-1;  
                    this.totalrecords = this.tributes.length;
                    this.totalPages = Math.ceil(this.totalrecords / this._pagesize);  
                    this.pagination(this.tributes);
                    this.handleNavigate();
                    //this.searchCompleted = true;
                }else{
                    if(data.errore.code == '225'){
                        this.showToast(this.label.attention, data.errore.message);
                    }else{
                        if(data.errore.code == '400'){
                            this.showToast(this.label.attention, this.label.FCnotFound);
                        }else{
                            this.showToast(this.label.attention, this.label.errorConnection);
                        }
                        
                    }
                      
                }
                
             this.isLoading = false;
             
            });
        }
        
       
    }
    showToast(theTitle, theMessage) {
		const event = new ShowToastEvent({
			title: theTitle,
			message: theMessage,
			variant: "error"
        });
		this.dispatchEvent(event);
    }
    pagination(tributes) {
        var PaginationList = [];
        for(var i=0; i<this.pagesize; i++){
            if(tributes.length > i){
                PaginationList.push(tributes[i]);
            }
        }
        this.PaginationList = PaginationList;
      }
      handleFirst() {  
        this.page = 1;
        var Paginationlist = [];
        var size = Math.min(this.tributes.length, this.pageSize);
        for(var i= 0; i < size ; i++){
            if(i > -1){
                    Paginationlist.push(this.tributes[i]);
            }
        }
        this.startPage = 0;
        this.endPage = this.pageSize-1;
        this.PaginationList = Paginationlist;
      }
    /** 
    handlePrevious() {  
        if (this.page > 1) {  
          this.page = this.page - 1;  
        }
        var Paginationlist = [];
        var counter = 0;
        var start = this.startPage;
        for(var i= start-this._pagesize; i < start ; i++){
            if(i > -1){
                    Paginationlist.push(this.tributes[i]);
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
            if(this.tributes.length > i){
                    Paginationlist.push(this.tributes[i]);
            }
            counter ++ ;
        }
        this.startPage = this.startPage + counter;
        this.endPage = this.endPage + counter;
        this.PaginationList = Paginationlist;
      }
      pagination(tributes) {
        var PaginationList = [];
        for(var i=0; i<this.pagesize; i++){
            if(tributes.length > i){
                PaginationList.push(tributes[i]);
            }
        }
        this.PaginationList = PaginationList;
      }  
      handleFirst() {  
        this.page = 1;
        var Paginationlist = [];
        var size = Math.min(this.tributes.length, this.pageSize);
        for(var i= 0; i < size ; i++){
            if(i > -1){
                    Paginationlist.push(this.tributes[i]);
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
                    Paginationlist.push(this.tributes[i]);
            }
        }
        this.startPage = (this.totalPages-1) * this._pagesize;
        this.endPage = this.totalPages * this._pagesize-1;
        this.PaginationList = Paginationlist;  
      }   
      handlePageChange(event) {  
        this.page = event.detail;  
      }  
      */
     handleRecordsLoad(event) {  
        this.totalrecords = event.detail;  
      } 
        
}