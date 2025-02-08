import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import {updateRecord} from 'lightning/uiRecordApi';
// APEX
import fetchCaseWrapper from '@salesforce/apex/ConsultationController.fetchCaseWrapper';
import getCase from '@salesforce/apex/ConsultationController.getCase';
import getOrgManagementCustomSetting from '@salesforce/apex/ConsultationController.getAnonymousIds';
//FIELDS
import ID_FIELD from '@salesforce/schema/Case.Id';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import SUB_STATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
// LABEL
import fiscalCode from '@salesforce/label/c.SchoolConsultation_FiscalCode';
import fillFiscalCode from '@salesforce/label/c.Consultation_FillFiscalCode';
import caseNmuber from '@salesforce/label/c.SchoolConsultation_CaseNumber';
import practicesTitle from '@salesforce/label/c.SchoolConsultation_Title';
import attention from '@salesforce/label/c.TributesConsultation_Attention';
import compilation from '@salesforce/label/c.TributesConsultation_CompilationError';
import search from '@salesforce/label/c.SchoolConsultation_Search';
import invalidFiscalCode from '@salesforce/label/c.SchoolConsultation_FiscalCodeInvalid';
import schoolHeader from '@salesforce/label/c.SchoolConsultation_SchoolHeader';
import notfound from '@salesforce/label/c.SchoolConsultation_Notfound';
import calloutError from '@salesforce/label/c.calloutError';

const PAGE_SIZE = 10;
export default class SchoolConsultationLWC extends NavigationMixin(
    LightningElement
) {
    @api isLoading = false;
    @api practices;
    @api showadditionalparameters = false;
    @api recordId;
    @api totalPages;
    @track fiscalCodeIndicated;
    @track practiceCodeIndicated;
    @track pageSize = 10;
    @track searchCompleted = false;
    @track PaginationList;
    @track startPage;
    @track endPage;
    @track searchCompleted = false;
    @track accountId;
    @track contactId;
    @track anonymousIds;
    @track label = {
        fiscalCode,
        practicesTitle,
        caseNmuber,
        search,
        compilation,
        attention,
        fillFiscalCode,
        invalidFiscalCode,
        schoolHeader,
        notfound,
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

        getCase({recordId: this.recordId}).then(result => {
            this.accountId = result.AccountId;
            this.contactId = result.ContactId;
            if (this.accountId != null && result.Account.IsPersonAccount) {
                this.fiscalCodeIndicated = (result.Account.Fiscal_Code__pc != null)
                    ? result
                        .Account
                        .Fiscal_Code__pc
                        .toUpperCase()
                    : null;
            } else {
                this.fiscalCodeIndicated = (
                    this.contactId != null && result.Contact.Fiscal_Code_contact__c != null
                )
                    ? result
                        .Contact
                        .Fiscal_Code_contact__c
                        .toUpperCase()
                    : null;
            }
        });
    }

    handleFiscalCodeChange(event) {
        this.handleSelection('fiscalCode', event.target.value);
    }
    handlePracticeCodeChange(event) {
        this.handleSelection('practiceCode', event.target.value);
    }

    closeModal() {
        // to close modal window set 'searchCompleted' tarck value as false
        this.searchCompleted = false;
    }

    handleSelection(origin, value) {
        this.searchCompleted = false;
        if (origin == 'fiscalCode') {
            this.fiscalCodeIndicated = value.toUpperCase();
        } else {
            if (origin == 'practiceCode') {
                this.practiceCodeIndicated = value;
            }
        }
    }

    checkFiscalCode(fiscalCode) {
        var patt = new RegExp(
            "^([A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMN" +
            "PQRSTUV]{3}[A-Z]{1})$|([0-9]{11})$"
        );
        return patt.test(fiscalCode);
    }

    searchpractices(event) {

        console.log("@@@ ent ");
        console.log("@@@ recordId " + this.recordId);
        getCase({recordId: this.recordId})
            .then(data => {
                console.log("@@@ data 2 " + JSON.stringify(data));

                if (data.Status == "New" && (data.Case_Action__c == null || data.Case_Action__c == "")) {
                    console.log("@@@ Entrato");
                    console.log("@@@ data.Id " + data.Id);
                    const fields = {};
                    console.log('fields -> ', fields);
                    fields[ID_FIELD.fieldApiName] = data.Id;
                    console.log('fields -> ', fields);
                    fields[STATUS_FIELD.fieldApiName] = "Working";
                    console.log('fields -> ', fields);
                    fields[SUB_STATUS_FIELD.fieldApiName] = 'In lavorazione al I livello';
                    console.log('fields -> ', fields);

                    const recordInput = {
                        fields
                    };
                    console.log("@@@ recordInput " + JSON.stringify(recordInput));
                    updateRecord(recordInput)
                        .then(() => {
                            console.log("@@@ saved record");
                            this.searchpracticesManage();
                        })
                        .catch(error => {
                            console.log("@@@ error " + JSON.stringify(error));
                        });
                } else {
                    this.searchpracticesManage();
                }
            })
            .catch(error => {
                console.log("@@@ error " + JSON.stringify(error));
                this.showToast("Error", error);
            });
    }

    searchpracticesManage() {
        console.log('searchpracticesManage');
        var nullFiscalCode = (
            this.fiscalCodeIndicated == null || this.fiscalCodeIndicated == ""
        );
        var nullPracticeCode = (
            this.practiceCodeIndicated == null || this.practiceCodeIndicated == ""
        );
        if (!this.checkFiscalCode(this.fiscalCodeIndicated) && this.fiscalCodeIndicated != null && this.fiscalCodeIndicated != "") {
            this.showToast(
                String(this.label.attention),
                String(this.label.invalidFiscalCode)
            );
            return;
        }
        if (this.accountId == null || this.contactId == null || this.anonymousIds.includes(this.accountId) || this.anonymousIds.includes(this.contactId)) {
            this.showToast(this.label.attention, this.label.calloutError);
        } else if (nullFiscalCode || nullPracticeCode) {
            this.showToast(String(this.label.attention), String(this.label.compilation));
        } else {
            // this.practices = fetchpracticesWrapper( {
            // fiscalCode:this.fiscalCodeIndicated, position:this.selectedPosition,
            // year:this.selectedYear, tributeTypology: this.selectedTribute});
            this.isLoading = true;
            fetchCaseWrapper(
                {fiscalCode: this.fiscalCodeIndicated, caseNumber: this.practiceCodeIndicated, caseId: this.caseId}
            )
                .then(data => {
                    this.practices = data;
                    this.handleFirst();
                    this.startPage = 0;
                    this.endPage = this._pagesize - 1;
                    this.totalrecords = this.practices.length;
                    this.totalPages = Math.ceil(this.totalrecords / this._pagesize);
                    this.pagination(this.practices);
                    this.handleNavigate();
                    this.isLoading = false;
                })
                .catch((error) => {
                    console.log('error');
                    console.log(error);
                    if (error.body != undefined) {
                        if (error.body.message == this.label.notfound) {
                            this.showToast(String(this.label.attention), this.label.notfound);
                        } else {
                            this.showToast(String(this.label.attention), error.body.message);
                        }
                    }
                    this.isLoading = false;
                });
        }
    }

    handleNavigate() {
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: "c__PracticesResultsContainer"
            },
            state: {
                c__practices: JSON.stringify(this.practices),
                c__startPage: this.startPage,
                c__endPage: this.endPage,
                c__totalrecords: this.totalrecords,
                c__totalPages: this.totalPages,
                c__practiceCodeIndicated: this.practiceCodeIndicated,
                c__fiscalCode: this.fiscalCodeIndicated
            }
        });
    }
    showToast(theTitle, theMessage) {
        const event = new ShowToastEvent(
            {title: theTitle, message: theMessage, variant: "error"}
        );
        this.dispatchEvent(event);
    }
    pagination(practices) {
        var PaginationList = [];
        for (var i = 0; i < this.pagesize; i++) {
            if (practices.length > i) {
                PaginationList.push(practices[i]);
            }
        }
        this.PaginationList = PaginationList;
    }
    handleFirst() {
        this.page = 1;
        var Paginationlist = [];
        var size = Math.min(this.practices.length, this.pageSize);
        for (var i = 0; i < size; i++) {
            if (i > -1) {
                Paginationlist.push(this.practices[i]);
            }
        }
        this.startPage = 0;
        this.endPage = this.pageSize - 1;
        this.PaginationList = Paginationlist;
    }

}