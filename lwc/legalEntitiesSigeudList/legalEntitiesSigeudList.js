import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LABEL
import companyName from '@salesforce/label/c.LegalEntities_Sigeud_CompanyName';
import piva from '@salesforce/label/c.LegalEntities_Sigeud_PIVA';
import cf from '@salesforce/label/c.LegalEntities_Sigeud_CF';
import role from '@salesforce/label/c.LegalEntities_Sigeud_Role';
import via from '@salesforce/label/c.LegalEntities_Sigeud_Address';
import genericPage from '@salesforce/label/c.Generic_Page';
import of from '@salesforce/label/c.Generic_outOf';
import sizePage from '@salesforce/label/c.LegalEntities_Sigeud_PageSize';
import back from '@salesforce/label/c.Generic_Back';
import save from '@salesforce/label/c.Generic_Save';
import attention from '@salesforce/label/c.Generic_Attention';
import insertFailed from '@salesforce/label/c.LegalEntities_Sigeud_InsertFailed';
import insertPartialSuccess from '@salesforce/label/c.LegalEntities_Sigeud_InsertPartialSuccess';
import insertSuccess from '@salesforce/label/c.LegalEntities_Sigeud_InsertSuccess';
import genericFailError from '@salesforce/label/c.Generic_SomethingWrong';
import searchByCompanyName from '@salesforce/label/c.LegalEntities_Sigeud_SearchByCompanyName';
import sigeudTableName from '@salesforce/label/c.LegalEntities_Sigeud_TableName';
import sigeudTableTitle from '@salesforce/label/c.LegalEntities_Sigeud_TableTitle';
import sigeudTableInfo from '@salesforce/label/c.LegalEntities_Sigeud_TableInfo';
//APEX
import saveSigeudRecords from '@salesforce/apex/LegalEntitiesController.saveSigeudRecords';
import deactivateContactsNotInSigeud from '@salesforce/apex/LegalEntitiesController.deactivateContactsNotInSigeud';

export default class LegalEntitiesSigeudList extends NavigationMixin(LightningElement) {
    @api records;
    @api legalEntities;
    @api isFromCase;
    @api deleteFailedIds = [];
    @track disableBack;
    @track disableSave = false;
    @track disableSearch = false;
    @track recordsToDisplay = [];
    @track searchRecords = [];
    @track page = 1;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize;
    @track totalRecordsCount = 0;
    @track totalPages = 0;
    @track selectedRows = [];
    @track selectedRecords = [];
    @track hideSaveButton = false;
    @track isInSearch = false;
    @track isLoading = false;
    @track isSaving = false;
    @track currentRowsSelectedCount = 0;
    @track label = {
        companyName,
        piva,
        cf,
        role,
        genericPage,
        of,
        sizePage,
        back,
        save,
        attention,
        insertFailed,
        insertSuccess,
        insertPartialSuccess,
        genericFailError,
        searchByCompanyName,
        sigeudTableName,
        via,
        sigeudTableTitle,
        sigeudTableInfo
    }

    @track columns = [
        { label: this.label.companyName, fieldName: 'firstName', type: 'text', wrapText: true },
        { label: this.label.role, fieldName: 'roleDescription', type: 'text', wrapText: true },
        { label: this.label.piva, fieldName: 'piva', type: 'text', wrapText: true },
        { label: this.label.cf, fieldName: 'cf', type: 'text', wrapText: true },
        { label: this.label.via, fieldName: 'via', type: 'text', wrapText: true }
    ];

    connectedCallback() {
        console.group('connectedCallback LegalEntitiesSigeudList');
        this.pageSize = Number(this.label.sizePage);
        console.log('isFromCase ' + this.isFromCase);
        console.log('pageSize ' + this.pageSize);
        console.log('records ', this.records);
        console.log('deleteFailedIds ', JSON.parse(JSON.stringify(this.deleteFailedIds)));
        console.log(JSON.parse(JSON.stringify(this.records)));
        this.disableSave = true;
        this.removeLegalsNotInSigeud();
        this.setPagesCount(this.records);
        this.displayRecordsPerPage(this.page);
        console.groupEnd('connectedCallback');
    }

    removeLegalsNotInSigeud() {
        console.group('removeLegalsNotInSigeud');
        console.log('legalEntities before ', JSON.parse(JSON.stringify(this.legalEntities)));
        if(this.legalEntities != null && this.legalEntities.length > 0) {
            console.log('legal entities not empty');
            let sigeudContactKeys = this.records.map(rec => rec.contactKey);
            console.log('sigeudContactKeys ', sigeudContactKeys);

            let toDeleteContacts = this.getContactsToDelete(sigeudContactKeys);
            console.log('toDeleteContacts ', toDeleteContacts);

            if(toDeleteContacts.length > 0) {
                console.log('deactivateContactsNotInSigeud not empty');
                this.deactivateContactsNotInSigeud(sigeudContactKeys, toDeleteContacts)
            } else {
                console.log('deactivateContactsNotInSigeud empty');
                this.disableBack = false;
            }
        } else if((this.legalEntities == null || this.legalEntities.length == 0)) {
            console.log('legal entities empty');
            this.disableBack = true;
        }
        console.groupEnd('removeLegalsNotInSigeud');
    }

    getContactsToDelete(sigeudContactKeys) {
        console.log('getContactsToDelete');
        return this.legalEntities.map(con => {
            if(!sigeudContactKeys.includes(con.contactKey)) {
                return con.id;
            }
        }).filter(l => l != null);
    }

    deactivateContactsNotInSigeud(sigeudContactKeys, toDeleteContacts) {
        console.group('deactivateContactsNotInSigeud');
        deactivateContactsNotInSigeud({contactIds : toDeleteContacts})
        .then(data => {
            console.log('data ', data);
            this.setLegalEntities(sigeudContactKeys, data);

            if(this.legalEntities.length == 0) {
                console.log('legalEntities empty');
                this.disableBack = true;
            } else if(this.legalEntities.length > 0) {
                console.log('legalEntities not empty');
                this.disableBack = false;
                if(data.length > 0) {
                    this.deleteFailedIds = Array.from(new Set([...this.deleteFailedIds, ...data].filter(a => !Array.isArray(a))));
                }
            }
            console.log('deleteFailedIds after ', JSON.parse(JSON.stringify(this.deleteFailedIds)));
        }).catch(error => {
            console.log('error');
            console.log(error);
        })
        console.groupEnd('deactivateContactsNotInSigeud');
    }

    setLegalEntities(sigeudContactKeys, data) {
        console.group('setLegalEntities');
        this.legalEntities = this.legalEntities.map(con => {
            if(sigeudContactKeys.includes(con.contactKey) || (data.length > 0 && data.includes(con.id))) {
                return con;
            }
        }).filter(l => l != null);
        console.log('legalEntities after ', JSON.parse(JSON.stringify(this.legalEntities)));
        console.groupEnd('setLegalEntities');
    }

    eventLegalRegistry(evt) {
        console.group('eventLegalRegistry');
        const selectedEvent = new CustomEvent(evt);
        this.dispatchEvent(selectedEvent);
        console.groupEnd('eventLegalRegistry');
    }

    disableInteractivity() {
        console.group('disableInteractivity');
        this.isLoading = true;
        this.disableBack = true;
        this.disableSave = true;
        this.disableSearch = true;
        this.isSaving = true;
        if(this.isFromCase) {
            this.eventLegalRegistry('disablelegalregistry');
        }
        console.groupEnd('disableInteractivity');
    }

    enableInteractivity() {
        console.group('enableInteractivity');
        this.isLoading = false;
        this.disableBack = false;
        this.disableSave = false;
        this.disableSearch = false;
        this.isSaving = false;
        if(this.isFromCase) {
            this.eventLegalRegistry('enablelegalregistry');
        }
        console.groupEnd('enableInteractivity');
    }

    handleSearch(event) {
        console.group('handleSearch');
        console.log('isInSearch ' + this.isInSearch);
        if(event.target.value.length != 0) {
            this.isInSearch = true;
        } else {
            this.isInSearch = false;
        }
        this.page = 1;
        let regex = new RegExp(event.target.value, 'i');
        console.log('regex');
        console.log(regex);
        this.searchRecords = this.records.filter(row => regex.test(row.firstName));
        console.log('searchRecords');
        console.log(JSON.parse(JSON.stringify(this.searchRecords)));
        this.setPagesCount(this.searchRecords);
        this.displayRecordsPerPage(this.page);
        this.setDataTableSelectedRecordsOnPageChange();
        console.log('isInSearch ' + this.isInSearch);
        console.groupEnd('handleSearch');
    }

    closeQuickAction() {
        console.group('LegalEntitiesSigeudList_closeQuickAction');
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
        console.groupEnd('LegalEntitiesSigeudList_closeQuickAction');
    }

    handleSave(event) {
        console.group('handleSave');
        console.log('selectedRecords');
        console.log(JSON.parse(JSON.stringify(this.selectedRecords)));
        this.disableInteractivity();
        saveSigeudRecords({sigeudContacts : this.selectedRecords})
        .then(data => {
            console.log(JSON.parse(JSON.stringify(data)));
            if(data == 0) {
                this.showToast(this.label.attention, this.label.insertFailed, 'error');
            } else if(data != 0) {
                if(data < this.selectedRecords.length) {
                    this.showToast(this.label.attention, this.label.insertPartialSuccess, 'info');
                } else if(data == this.selectedRecords.length) {
                    this.showToast('Success', this.label.insertSuccess, 'success');
                }
                this.redirectToLegalEntitiesList();
            }
        }).catch(error => {
            console.log('error');
            console.log(error);
            this.showToast(this.label.attention, this.label.genericFailError, 'error');
        }).finally(() => {
            this.enableInteractivity();
        });
        console.groupEnd('handleSave');
    }

    redirectToLegalEntitiesList() {
        const selectedEvent = new CustomEvent('savefromsigeudlist', {
            detail: {
                deleteFailedIds: this.deleteFailedIds
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleBack(event) {
        const selectedEvent = new CustomEvent('backfromsigeudlist', {
            detail: {
                deleteFailedIds: this.deleteFailedIds,
                legalEntities: this.legalEntities
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleSelectedRows(event) {
        console.group('handleSelectedRows');
        if(!this.isSaving) {
            const rowsSelected = event.detail.selectedRows;
            console.log('rowsSelected');
            console.log(JSON.parse(JSON.stringify(rowsSelected)));
    
            console.log('before adding ' + this.currentRowsSelectedCount);
            this.addSelectedRecords(rowsSelected);
            console.log('after adding e before removing ' + this.currentRowsSelectedCount);
    
            this.removeSelectedRecords(rowsSelected);
            console.log('after removeSelectedRecords this.currentRowsSelectedCount ' + this.currentRowsSelectedCount);
    
            this.setCurrentRowsSelectedCount();
            console.log('after setCurrentRowsSelectedCount this.currentRowsSelectedCount ' + this.currentRowsSelectedCount);
            
            this.toggleSaveButton();
        } else {
            console.log('trying to select during save but cannot select');
            this.setDataTableSelectedRecordsOnPageChange();
        }
        console.groupEnd('handleSelectedRows');
    }

    addSelectedRecords(rowsSelected) {
        console.group('addSelectedRecords');
        console.log('selectedRows before adding');
        console.log(JSON.parse(JSON.stringify(this.selectedRows)));
        for(let i = 0; i < rowsSelected.length; i++) {
            console.log('entered adding for');
            if(!this.selectedRows.includes(rowsSelected[i].contactKey)) {
                console.log('entered adding for if');
                console.log(JSON.parse(JSON.stringify(rowsSelected[i])));
                this.selectedRows.push(rowsSelected[i].contactKey);
                this.selectedRecords.push(rowsSelected[i]);
                console.log('finished adding for if');
            }
        }
        console.log('selectedRows after adding');
        console.log(JSON.parse(JSON.stringify(this.selectedRows)));
        console.groupEnd('addSelectedRecords');
    }

    removeSelectedRecords(rowsSelected) {
        console.group('removeSelectedRecords');
        if(this.currentRowsSelectedCount == this.selectedRows.length) {
            console.log('to remove');
            let elemsToRemove = []
            elemsToRemove = this.recordsToDisplay.filter(e => !rowsSelected.includes(e));
            console.log('elemsToRemove');
            console.log(JSON.parse(JSON.stringify(elemsToRemove)));

            this.selectedRecords = this.selectedRecords.filter(e => !elemsToRemove.includes(e));
            console.log('after removing in this.selectedRecords');
            console.log(JSON.parse(JSON.stringify(this.selectedRecords)));

            this.selectedRows = this.selectedRecords.map(e => e.contactKey);
            console.log('after removing in this.selectedRows');
            console.log(JSON.parse(JSON.stringify(this.selectedRows)));

            this.currentRowsSelectedCount = this.selectedRows.length;
            console.log('after removing this.currentRowsSelectedCount ' + this.currentRowsSelectedCount);
        } 
        console.groupEnd('removeSelectedRecords');
    }

    setCurrentRowsSelectedCount() {
        if(this.currentRowsSelectedCount < this.selectedRows.length) {
            this.currentRowsSelectedCount = this.selectedRows.length;
        }
    }

    toggleSaveButton() {
        console.group('toggleSaveButton');
        if(this.selectedRows.length == 0) {
            this.disableSave = true;
        } else {
            this.disableSave = false;
        }
        console.log('disableSave ' + this.disableSave);
        console.groupEnd('toggleSaveButton');
    }

    setDataTableSelectedRecordsOnPageChange() {
        this.template.querySelector(
            '[data-id="sigeudlist"]'
          ).selectedRows = this.selectedRows;
    }

    setPagesCount(records) {
        console.group('setPagesCount');
        this.totalRecordsCount = records.length;
        this.totalPages = Math.ceil(this.totalRecordsCount / this.pageSize);

        console.log('totalRecordsCount ' + this.totalRecordsCount);
        console.log('totalPages ' + this.totalPages);
        console.log('pageSize ' + this.pageSize);
        console.groupEnd('setPagesCount');
    }

    handlePrevious() {
        console.group('handlePrevious');
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordsPerPage(this.page);
        }
        console.log('selectedRows handlePrevious');
        console.log(this.selectedRows);
        console.groupEnd('handlePrevious');
        this.setDataTableSelectedRecordsOnPageChange();
    }

    handleNext() {
        console.group('handleNext');
        console.log('totalPages ' + this.totalPages);
        console.log('page ' + this.page);
        if(this.page < this.totalPages) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordsPerPage(this.page);
        }
        console.log('selectedRows handleNext');
        console.log(this.selectedRows);
        this.setDataTableSelectedRecordsOnPageChange();
        console.groupEnd('handleNext');
    }

    handleFirst() {
        console.group('handleFirst');
        this.page = 1;
        this.displayRecordsPerPage(this.page);
        console.log('selectedRows handleFirst');
        console.log(this.selectedRows);
        this.setDataTableSelectedRecordsOnPageChange();
        console.groupEnd('handleFirst');
    }

    handleLast() {
        console.group('handleLast');
        this.page = this.totalPages;
        this.displayRecordsPerPage(this.page);
        console.log('selectedRows handleLast');
        console.log(this.selectedRows);
        this.setDataTableSelectedRecordsOnPageChange();
        console.groupEnd('handleLast');
    }

    displayRecordsPerPage(page) {
        console.group('displayRecordsPerPage');
        console.log('page: ' + page);
        console.log('totalRecordsCount: ' + this.totalRecordsCount);
        page = (page === 0 && this.totalRecordsCount != 0) ? 1 : page;
        this.startingRecord = ((page - 1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        console.log('endingRecord before setting: ' + this.endingRecord);

        this.endingRecord = (this.endingRecord > this.totalRecordsCount) ? this.totalRecordsCount : this.endingRecord; 
        console.log('startingRecord before setting: ' + this.startingRecord);
        console.log('endingRecord after setting: ' + this.endingRecord);

        if(this.isInSearch) {
            this.recordsToDisplay = this.searchRecords.slice(this.startingRecord, this.endingRecord);
        } else {
            this.recordsToDisplay = this.records.slice(this.startingRecord, this.endingRecord);
        }

        this.page = page;
        this.startingRecord = this.startingRecord + 1;
        console.log('startingRecord after setting: ' + this.startingRecord);
        console.groupEnd('displayRecordsPerPage');
    }

    showToast(theTitle, theMessage, theVariant) {
        const event = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant
        });
        this.dispatchEvent(event);
    }
}