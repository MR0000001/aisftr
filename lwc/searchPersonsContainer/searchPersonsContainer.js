import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
//LABELS
import legalEntitiesTitle from '@salesforce/label/c.LegalEntities_Title';
import accountTitle from '@salesforce/label/c.searchAccount_Title';

export default class SearchPersonsContainer extends NavigationMixin(LightningElement) {
    @api caseId;
    @api fiscalCodeIndicated;
    @api personAccountId;
    @track isFromCase = true;
    @track blockLegalBeforeInsertion = false;
    @track label = {
        legalEntitiesTitle,
        accountTitle
    }

    handleNavigatePage(event) {
        console.group('handleNavigatePage');
        if(event.type == 'redirecttoregistry') {
            console.log('handleNavigatePage cf: ' + event.detail.fiscalCodeIndicated);
        
            this.fiscalCodeIndicated = event.detail.fiscalCodeIndicated;
            //this.showToast(this.label.info, this.label.redirectToRegistry+' ' +this.fiscalCodeIndicated, 'info');
            this.template.querySelector("c-search-anagraphic").autoSearch(this.fiscalCodeIndicated);
            this.template.querySelector('lightning-tabset').activeTabValue = this.label.accountTitle;
        } else if(event.type == 'redirecttolegalsearch') {
            console.log('redirecttolegalsearch');
            console.log('this.fiscalCodeIndicated before ' + this.fiscalCodeIndicated);
            this.fiscalCodeIndicated = event.detail.fiscalCodeIndicated;
            this.personAccountId = event.detail.personAccountId;
            console.log('this.fiscalCodeIndicated after ' + this.fiscalCodeIndicated);
            this.template.querySelector("c-search-legal-entities").enableInteractions();
            this.template.querySelector('lightning-tabset').activeTabValue = this.label.legalEntitiesTitle;
            this.template.querySelector("c-search-legal-entities").getLegalEntitiesWrapper(this.fiscalCodeIndicated, this.personAccountId);
        } else if(event.type == 'disableregistry') {
            console.log('disableregistry');
            this.template.querySelector("c-search-anagraphic").resetAndDisableButtons();
        } else if(event.type == 'enableregistry') {
            console.log('enableregistry');
            this.template.querySelector("c-search-anagraphic").enableInput();
        } else if(event.type == 'disablelegalregistry') {
            console.log('disablelegalregistry');
            if(this.template.querySelector("c-search-legal-entities")) {
                this.template.querySelector("c-search-legal-entities").resetAndBlock();
            } else {
                this.blockLegalBeforeInsertion = true;
            }
        } else if(event.type == 'enablelegalregistry') {
            console.log('enablelegalregistry');
            this.blockLegalBeforeInsertion = false;
            if(this.template.querySelector("c-search-legal-entities")) {
                console.log('c-search-legal-entities');
                this.template.querySelector("c-search-legal-entities").enableInput();
            }
        }
        console.groupEnd('handleNavigatePage');
    }

    showToast(theTitle, theMessage, theVariant) {
        const event = new ShowToastEvent({
            title: theTitle,
            message: theMessage,
            variant: theVariant
        });
        this.dispatchEvent(event);
    }

    closeQuickAction() {
        console.group('SearchPersonsContainer_closeQuickAction');
        this.dispatchEvent(new FlowNavigationNextEvent());
        console.groupEnd('SearchPersonsContainer_closeQuickAction');        
    }
}