import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LABELS
import search from '@salesforce/label/c.LegalEntities_Search';
import reset from '@salesforce/label/c.LegalEntities_Reset';
import fiscalCode from '@salesforce/label/c.LegalEntities_FiscalCode';
import legalEntitiesTitle from '@salesforce/label/c.LegalEntities_Title';
import attention from '@salesforce/label/c.attention';
import info from '@salesforce/label/c.Generic_Info';
import noLegalEntitiesFound from '@salesforce/label/c.LegalEntities_Sigeud_NoLegalEntitiesFound';
import integrationError from '@salesforce/label/c.LegalEntities_Sigeud_IntegrationError';
import noPersonAccounts from '@salesforce/label/c.LegalEntities_NoPersonAccountsFound';
import noContactsFound from '@salesforce/label/c.LegalEntities_NoContactsFound';
import generalError from '@salesforce/label/c.Generic_SomethingWrong';
import invalidFiscalCode from '@salesforce/label/c.SchoolConsultation_FiscalCodeInvalid';
//APEX
import getLegalEntities from '@salesforce/apex/LegalEntitiesController.getLegalEntities';
import sigeudCallout from '@salesforce/apex/LegalEntitiesController.sigeudCallout';

export default class SearchLegalEntities extends NavigationMixin(LightningElement) {
    @api caseid;
    @api personAccountId;
    @api fiscalCodeIndicated;
    @api isFromCase;
    @api legalEntities = [];
    @api sigeudLegalEntities = [];
    @api blockBeforeInsertion = false;
    @track messageToDisplay;
    @track disableCancelButton = true;
    @track disableSearchButton = true;
    @track disableInput = false;
    @track isLoading = false;
    @track showLegalEntities = false;
    @track showSigeudLegalEntities = false;
    @track showInfoModal = false;
    @track showSearch = false;
    @track hideInfoModalButtons = false;
    @track label = {
        search,
        reset,
        fiscalCode,
        legalEntitiesTitle,
        attention,
        generalError,
        noLegalEntitiesFound,
        integrationError,
        info,
        noPersonAccounts,
        noContactsFound,
        invalidFiscalCode
    }

    legalEntitiesExists = false;
    deleteFailedIds = [];

    connectedCallback() {
        console.group('SearchLegalEntities_connectedCallback');
        console.log('this.caseid ' + this.caseid);
        if(this.caseid != null && this.caseid.startsWith('500')) {
            console.log('from case');
            this.showSearch = true;
            this.hideInfoModalButtons = false;
            if(this.blockBeforeInsertion) {
                this.resetAndBlock();
            }
        } else {
            console.log('from PA');
            this.isFromCase = false;
            this.showSearch = false;
            this.hideInfoModalButtons = true;
            this.getLegalEntities();
        }
        console.groupEnd('SearchLegalEntities_connectedCallback');
    }

    disableAllChildComponents() {
        this.showLegalEntities = false;
        this.showSigeudLegalEntities = false;
        this.showInfoModal = false;
    }

    showLegalEntitiesOnly() {
        this.showLegalEntities = true;
        this.showSigeudLegalEntities = false;
        this.showInfoModal = false;
    }

    showInfoModalOnly() {
        this.showLegalEntities = false;
        this.showSigeudLegalEntities = false;
        this.showInfoModal = true;
        this.showSearch = false;
    }

    showSigeudLegalEntitiessOnly() {
        this.showLegalEntities = false;
        this.showSigeudLegalEntities = true;
        this.showInfoModal = false;
    }

    handleFiscalCode(event) {
        console.group('handleFiscalCode');
        this.clearPreviousTables();
        this.fiscalCodeIndicated = event.target.value.toUpperCase();
        this.checkFiscalCodeFilled();
        console.log(this.fiscalCodeIndicated);
        this.disableAllChildComponents();
        console.groupEnd('handleFiscalCode');
    }

    checkFiscalCodeFilled() {
        if(this.fiscalCodeIndicated != null && this.fiscalCodeIndicated != '') {
            this.disableSearchButton = false;
            this.disableCancelButton = false;
        } else {
            this.disableSearchButton = true;
            this.disableCancelButton = true;
            this.disableAllChildComponents();
        }
    }

    handleSearch() {
        console.group('handleSearch');
        this.clearPreviousTables();
        let errorMsg = this.validateFiscalCode();

        if(errorMsg != null && errorMsg != '') {
            this.disableSearchButton = true;
            this.showToast(String(this.label.attention), errorMsg, 'error');
        } else {
            this.getLegalEntities();
        }
        console.groupEnd('handleSearch');
    }

    @api getLegalEntitiesWrapper(fiscalCodeIndicated, personAccountId) {
        console.group('getLegalEntitiesWrapper');
        this.fiscalCodeIndicated = fiscalCodeIndicated;
        this.personAccountId = personAccountId;
        
        console.log('this.fiscalCodeIndicated ' + this.fiscalCodeIndicated);
        console.log('this.personAccountId ' + this.personAccountId);
        this.getLegalEntities();
        console.groupEnd('getLegalEntitiesWrapper');
    }

    getLegalEntities() {
        console.group('getLegalEntities');
        this.disableInteractions();
        this.eventRegistry('disableregistry');
        this.disableAllChildComponents();
        getLegalEntities({fiscalCodePersonAccount : this.fiscalCodeIndicated})
        .then(data => {
            console.log('legalEntities data');
            console.log(data);
            console.log(Object.keys(data).length);
            if(Object.keys(data).length !== 0) {
                console.log('data not empty');
                console.log(data.errorMessage);
                console.log(data.legalEntities);
                if(!data.errorMessage) {
                    console.log('data legalEntities size ' + data.legalEntities.length);
                    this.legalEntitiesExists = true;
                    this.legalEntities = data.legalEntities;
                    console.log('all ok');
                    console.log('this.legalEntities');
                    console.log(this.legalEntities);
                    this.personAccountId = data.personAccountId;
                    this.showLegalEntitiesOnly();
                    this.disableAssociateForInvalidLegalEntities();
                    console.log('showLegalEntities if ' + this.personAccountId);
                    console.log('showLegalEntities if ' + this.showLegalEntities);
                    console.log('showInfoModal if ' + this.showInfoModal);
                    this.enableInteractions();
                } else if(data.errorMessage && data.errorMessage == this.label.noPersonAccounts) {
                    console.log('no person accounts');
                    this.showInfoModalOnly();
                    this.legalEntitiesExists = false;
                    this.messageToDisplay = this.label.noPersonAccounts;
                    console.log('showLegalEntities else ' + this.showLegalEntities);
                    console.log('showInfoModal else ' + this.showInfoModal);
                    this.enableInteractions();
                } else if(data.errorMessage && data.errorMessage == this.label.noContactsFound) {
                    console.log('yes person account no contacts');
                    this.personAccountId = data.personAccountId;
                    this.legalEntitiesExists = false;
                    console.log('this.personAccountId ' + this.personAccountId);
                    this.disableAllChildComponents();
                    this.sigeudCallout();
                }
            } else {
                console.log('legalEntities empty');
                this.legalEntitiesExists = false;
                this.enableInteractions();
                this.showToast(String(this.label.attention), this.label.generalError, 'error');
                this.eventRegistry('enableregistry');
            }
        })
        .catch(error => {
            console.log(error);
            this.legalEntitiesExists = false;
            this.showToast(String(this.label.attention), this.label.generalError, 'error');
            this.disableAllChildComponents();
            this.eventRegistry('enableregistry');
        });
        console.groupEnd('getLegalEntities');
    }

    eventRegistry(evt) {
        console.group('eventRegistry');
        if(this.isFromCase) {
            const selectedEvent = new CustomEvent(evt);
            this.dispatchEvent(selectedEvent);
            console.groupEnd('eventRegistry');
        }
    }

    handleToggleInteractivity(event) {
        if(this.isFromCase) {
            if(event.type == 'disablelegalregistry') {
                this.disableInteractions();
            } else {
                this.enableInteractions();
            }
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

    validateFiscalCode() {
        let isCorrectPattern = this.checkFiscalCode(this.fiscalCodeIndicated);

        let errorMsg = (!isCorrectPattern) ? this.label.invalidFiscalCode : '';

        return errorMsg;
    }

    checkFiscalCode(fiscalCode){
        var patt = new RegExp("^([A-Z]{6}[0-9LMNPQRSTUV]{2}[ABCDEHLMPRST]{1}[0-9LMNPQRSTUV]{2}[A-Z]{1}[0-9LMNPQRSTUV]{3}[A-Z]{1})$|([0-9]{11})$");
        return patt.test(fiscalCode);
      }

    handleClear() {
        console.group('handleClear');
        this.disableCancelButton = true;
        this.disableSearchButton = true;
        this.fiscalCodeIndicated = '';
        this.clearPreviousTables();
        this.disableAllChildComponents();
        this.eventRegistry('enableregistry');
        console.groupEnd('handleClear');
    }

    clearPreviousTables() {
        this.legalEntities = [];
        this.sigeudLegalEntities = [];
    }

    @api resetAndBlock() {
        console.group('resetAndBlock');
        this.disableCancelButton = true;
        this.disableInput = true;
        this.disableSearchButton = true;
        //this.fiscalCodeIndicated = '';
        this.clearPreviousTables();
        this.disableAllChildComponents();
        console.groupEnd('resetAndBlock');
    }

    @api enableInput() {
        this.disableInput = false;
        this.fiscalCodeIndicated = null;
        this.isLoading = false;
    }

    disableInteractions() {
        console.group('search legal entities disableInteractions');
        this.disableCancelButton = true;
        this.disableSearchButton = true;
        this.disableInput = true;
        this.isLoading = true;
        console.groupEnd('search legal entities disableInteractions');
    }

    @api enableInteractions() {
        console.group('search legal entities enableInteractions');
        this.disableCancelButton = false;
        this.disableSearchButton = false;
        this.disableInput = false;
        this.isLoading = false;
        console.groupEnd('search legal entities enableInteractions');
    }

    sigeudCallout() {
        console.group('sigeudCallout');
        console.log('this.fiscalCodeIndicated ' + this.fiscalCodeIndicated);
        console.log('this.personAccountId ' + this.personAccountId);
        this.disableInteractions();

        sigeudCallout({fiscalCodePersonAccount : this.fiscalCodeIndicated, personAccountId : this.personAccountId})
        .then(data => {
            console.log('sigeud data');
            console.log(data);
            console.log(Object.keys(data).length);
            if(Object.keys(data).length !== 0) {
                console.log('data not empty');
                console.log(data.errorMessage);
                console.log(data.sigeudContacts);
                if(!data.errorMessage) {
                    console.log('showSigeudLegalEntitiessOnly');
                    this.sigeudLegalEntities = data.sigeudContacts;
                    this.showSigeudLegalEntitiessOnly();
                    console.log('this.showLegalEntities ' + this.showLegalEntities);
                    console.log('this.showSigeudLegalEntities ' + this.showSigeudLegalEntities);
                } else if(data.errorMessage && data.errorMessage == this.label.noLegalEntitiesFound) {
                    console.log('noLegalEntitiesFound');
                    this.toggleSigeudError(this.label.info, this.label.noLegalEntitiesFound+' '+this.fiscalCodeIndicated, 'warning');
                } else if(data.errorMessage && data.errorMessage == this.label.integrationError) {
                    console.log('integrationError');
                    this.toggleSigeudError(this.label.attention, this.label.integrationError, 'error');
                } else if(data.errorMessage && data.errorMessage == this.label.generalError) {
                    if(this.isFromCase) {
                        this.showToast(this.label.attention, this.label.generalError, 'error');
                    } else {
                        this.showInfoModal = true;
                        this.messageToDisplay = this.label.generalError;
                    }
                }
            }
        }).catch(error => {
            console.log('error');
            console.log(error);
            this.toggleSigeudError(this.label.attention, this.label.generalError, 'error');
        }).finally(() => {
            console.log('finally');
            this.enableInteractions();
            console.groupEnd('sigeudCallout');
        });
    }

    toggleSigeudError(toastTitle, toastMsg, toastType) {
        console.group('toggleSigeudError');
        this.showToast(toastTitle, toastMsg, toastType);

        if(this.legalEntitiesExists) {
            this.getLegalEntities();
        } else if(!this.isFromCase) {
            this.showInfoModal = true;
            this.messageToDisplay = toastMsg;
        }
        console.groupEnd('toggleSigeudError');
    }

    handleClose() {
        console.group('handleClose');
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
        console.groupEnd('handleClose');
    }

    handleCloseModal(event) {
        console.group('handleCloseModal');
        this.showInfoModal = false;
        this.showSearch = true;
        console.log('this.showInfoModal ' + this.showInfoModal);
        console.groupEnd('handleCloseModal');
    }

    handleRedirectToRegistry(event) {
        console.group('handleRedirectToRegistry');
        this.showInfoModal = false;
        this.showSearch = true;
        console.log('this.showInfoModal ' + this.showInfoModal);
        console.log('this.fiscalCodeIndicated ' + this.fiscalCodeIndicated);

        const selectedEvent = new CustomEvent('redirecttoregistry', {
            detail : {
                fiscalCodeIndicated : this.fiscalCodeIndicated
            }
        });
        this.disableInteractions();
        this.dispatchEvent(selectedEvent);
        console.groupEnd('handleRedirectToRegistry');
    }

    disableAssociateForInvalidLegalEntities() {
        console.group('disableAssociateForInvalidLegalEntities');
        if(this.deleteFailedIds.length > 0) {
            console.log('entered if')
            this.legalEntities = this.legalEntities.map(con => {
                if(this.deleteFailedIds.includes(con.id)) {
                    console.log('set disableAssociate true')
                    con.disableAssociate = true;
                } else {
                    console.log('set disableAssociate false')
                    con.disableAssociate = false;
                }
                return con;
            });
        }
        console.groupEnd('disableAssociateForInvalidLegalEntities');
    }

    handleBackFromSigeud(event) {
        console.group('handleBackFromSigeud');
        this.deleteFailedIds = event.detail.deleteFailedIds;
        this.legalEntities = JSON.parse(JSON.stringify(event.detail.legalEntities));
        console.log('this.legalEntities ', JSON.parse(JSON.stringify(this.legalEntities)));
        console.log('this.deleteFailedIds ', JSON.parse(JSON.stringify(this.deleteFailedIds)));
        if(this.legalEntities != null && this.legalEntities.length != 0) {
            this.disableAssociateForInvalidLegalEntities();
            this.showLegalEntitiesOnly();
        } else {
            this.disableAllChildComponents();
        }
        this.toggleShowSearch();
        console.groupEnd('handleBackFromSigeud');
    }

    handleSaveFromSigeud(event) {
        console.group('handleSaveFromSigeud');
        console.log('this.legalEntities');
        console.log(this.legalEntities);
        this.deleteFailedIds = event.detail.deleteFailedIds;
        console.log('this.deleteFailedIds ', JSON.parse(JSON.stringify(this.deleteFailedIds)));
        this.getLegalEntities();
        this.toggleShowSearch();
        console.groupEnd('handleSaveFromSigeud');
    }

    toggleShowSearch() {
        if(this.isFromCase) {
            this.showSearch = true;
        } else {
            this.showSearch = false;
        }
    }
}