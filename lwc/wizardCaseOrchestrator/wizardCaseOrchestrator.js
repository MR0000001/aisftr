import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//LABELS
import caseCompilation from '@salesforce/label/c.wizardCaseOrchestrator_CaseCompilation';
import attention from '@salesforce/label/c.caseDetails_Attention';
import taxInactive from '@salesforce/label/c.wizardCaseOrchestrator_TaxInactive';
import step0 from '@salesforce/label/c.wizardCaseOrchestrator_Base';
import step1 from '@salesforce/label/c.wizardCaseOrchestrator_Generals';
import step2 from '@salesforce/label/c.wizardCaseOrchestrator_Specifics';


export default class WizardCaseOrchestrator extends LightningElement {
    @api showCaseDetails;
    @track showCaseCreation = false;
    @api showCaseBasicInformation;
    @track currentStep = "0";
    @api personaFisica;
    @api caseBusinessAccount;
    @api contactId;
    @api bottomUp;
    @api caseId;
    @api recordId;
    @api fields;
    @api typologySelected;
    @api nameinteraction;
    @api interactionSelected;
    @api selectedQueue;
    @api selectedSpecification;
    @api selectedThemarea;
    @api selectedArgument;
    @api selectedSpecificationr;
    @api selectedThemarear;
    @api selectedArgumentr;
    @api selectedSpecificationrs;
    @api selectedThemarears;
    @api selectedArgumentrs;
    @api estimatedQueue;
    @api casealertpolicewarning;
    @api noReassign;
    @api dontQuery = false;
    @api fullAddress;
    @api address;
    @api letterAddress;
    @api numberAddress;
    @api municipality;
    @api lat;
    @api lng;
    /*@api callNic;
    @api isNicError;*/
    @api serviceRequestId;
    @api accountId;
    @api origin;
    @api isonchangeselected;
    @api subject;
    @api isCreation;
    @api maintainTriplets;
    @api originalid;
    @api protocolNumber;
    @api oldInteraction;
    @track label = {
    caseCompilation,
    step0,
    step1,
    step2,
    attention,
    taxInactive
    };

    connectedCallback() {
        this.originalid = this.recordId;
        if(this.selectedSpecificationrs != null && this.selectedSpecificationrs!=''){
            this.selectedSpecificationR = JSON.parse(this.selectedSpecificationrs);
        }
        if(this.selectedThemarears != null && this.selectedThemarears!=''){
            this.selectedThemareaR = JSON.parse(this.selectedThemarears);
        }
        if(this.selectedArgumentrs != null && this.selectedArgumentrs!=''){
            this.selectedArgumentR = JSON.parse(this.selectedArgumentrs);
        }
        console.log('wizard connected callback account id ', this.accountId);
        console.log('wizard connected callback contact id ', this.contactId);
        console.log('wizard connected callback bottomUp ', this.bottomUp);
        console.log('wizard connected callback isonchangeselected ', this.isonchangeselected);
        console.log('wizard connected callback lat ', this.lat);
        console.log('wizard connected callback lng ', this.lng);
        console.log('wizard connected callback address ', this.address);
        console.log('wizard connected callback municipality ', this.municipality);
    }


    handleNavigatePage(event){
        this.protocolNumber = event.detail.protocolNumber;
        this.oldInteraction = event.detail.oldInteraction;
        this.maintainTriplets = event.detail.maintainTriplets;
        /*this.isNicError = event.detail.isNicError;*/
        this.isCreation = event.detail.iscreation;
        this.caseId = event.detail.caseid;
        this.fields = event.detail.fields;
        this.fullAddress = event.detail.fullAddress;
        this.address = event.detail.address;
        this.letterAddress = event.detail.letterAddress;
        this.numberAddress = event.detail.numberAddress;
        this.typologySelected = event.detail.typologyselected;
        this.interactionSelected = event.detail.interactionselected;
        this.selectedQueue = event.detail.selectedqueue;
        this.selectedThemarea = event.detail.selectedthemarea;
        this.selectedArgument = event.detail.selectedargument;
        this.selectedSpecification = event.detail.selectedspecification;
        this.selectedThemareaR = event.detail.selectedthemarear;
        this.selectedArgumentR = event.detail.selectedargumentr;
        this.selectedSpecificationR = event.detail.selectedspecificationr;
        this.estimatedQueue = event.detail.estimatedQueue;
        this.casealertpolicewarning = event.detail.casealertpolicewarning;
        this.noReassign = event.detail.noReassign;
        if (  (event.type == "nextfromdetails") ||  (event.type == "previousfromdetails") ) {
            this.bottomUp = event.detail.bottomUp;
        }
        this.nameinteraction = event.detail.nameinteraction;
        if ( event.type != "previousfromdetails") {
            this.isonchangeselected = event.detail.isonchangeselected;
        }
        this.showCaseCreation = (event.type=="nextfromdetails");
        this.showCaseDetails = (event.type=="nextfrombi" || event.type=="previousfromcreation");
        this.showCaseBasicInformation = (event.type=="previousfromdetails");
        this.currentStep = this.showCaseBasicInformation?"0":(this.showCaseDetails?"1":"2");
        this.dontQuery = true;
        this.origin = event.detail.origin;
        this.serviceRequestId = event.detail.serviceRequestId;
        this.accountId = event.detail.accountId;
        this.contactId = event.detail.contactId;
        /*console.log(' this.callNic wizard ' +  event.detail.callNic);
        this.callNic = event.detail.callNic;*/
        this.municipality = event.detail.municipality;
        console.log(' this.municipality wizard ' +  event.detail.municipality);
        if(event.detail.activeTax == "false"){
            this.showToast(this.label.attention,this.label.taxInactive,'warning',"sticky");
        }
        this.lng = event.detail.lng;
        this.lat = event.detail.lat;
        this.subject=event.detail.subject;
        this.originalid=event.detail.originalid;
        this.personaFisica = event.detail.personaFisica;
        this.caseBusinessAccount = event.detail.caseBusinessAccount;
    }

    filterchange(event){
        let action = '';
        if ( event.detail != null) {
            action = event.detail.action;
        }
        const filterChangeEvent = new CustomEvent('filterchange', {
            detail: { action }
        });
        this.dispatchEvent(filterChangeEvent);

    }

    showGeoCoding(event){
        this.typologySelected = event.detail.typologyselected;
        this.nameinteraction = event.detail.nameinteraction;
        this.interactionSelected = event.detail.interactionselected;
        this.selectedQueue = event.detail.selectedqueue;
        this.selectedThemarea = event.detail.selectedthemarea;
        this.selectedArgument = event.detail.selectedargument;
        this.selectedSpecification = event.detail.selectedspecification;
        this.selectedThemareaR = event.detail.selectedthemarear;
        this.selectedArgumentR = event.detail.selectedargumentr;
        this.selectedSpecificationR = event.detail.selectedspecificationr;
        this.estimatedQueue = event.detail.estimatedQueue;
        this.fullAddress = event.detail.fullAddress;
        this.address = event.detail.address;
        this.letterAddress = event.detail.letterAddress;
        this.numberAddress = event.detail.numberAddress;
        this.contactId = event.detail.contactId;
        this.accountId = event.detail.accountId;
        this.serviceRequestId = event.detail.serviceRequestId;
        this.municipality = event.detail.municipality;
        this.origin = event.detail.origin;
        this.casealertpolicewarning = event.detail.casealertpolicewarning;
        this.caseId = event.detail.caseid;
        this.bottomUp = event.detail.bottomUp;
        this.subject = event.detail.subject;
        this.isCreation = event.detail.iscreation;
        /*this.isNicError = event.detail.isNicError;*/
        this.oldInteraction = event.detail.oldInteraction;
        this.protocolNumber = event.detail.protocolNumber;
        this.personaFisica = event.detail.personaFisica;
        this.caseBusinessAccount = event.detail.caseBusinessAccount;
        this.isonchangeselected = event.detail.isonchangeselected;
        this.lng = event.detail.lng;
        this.lat = event.detail.lat;
        var params = {
            typologyselected: event.detail.typologyselected, 
            nameinteraction: event.detail.nameinteraction,
            interactionselected: event.detail.interactionselected,
            selectedqueue: event.detail.selectedqueue,
            selectedargument: event.detail.selectedargument,
            selectedthemarea: event.detail.selectedthemarea,
            selectedspecification: event.detail.selectedspecification,
            selectedargumentr: event.detail.selectedargumentr,
            selectedthemarear: event.detail.selectedthemarear,
            selectedspecificationr: event.detail.selectedspecificationr,
            estimatedQueue: event.detail.estimatedQueue,
            fullAddress: event.detail.fullAddress,
            address: event.detail.address,
            letterAddress: event.detail.letterAddress,
            numberAddress: event.detail.numberAddress,
            /*googleKey: event.detail.googleKey,
            vfOrigin: event.detail.vfOrigin,
            domain: event.detail.domain,*/
            bottomUp: event.detail.bottomUp,
            municipality: event.detail.municipality,
            contactId: event.detail.contactId,
            accountId: event.detail.accountId,
            serviceRequestId: event.detail.serviceRequestId,
            origin: event.detail.origin,
            caseid: event.detail.caseid,
            casealertpolicewarning: event.detail.casealertpolicewarning,
            subject: event.detail.subject,
            iscreation: event.detail.iscreation,
            /*isNicError: event.detail.isNicError,*/
            protocolNumber: event.detail.protocolNumber,
            oldInteraction: event.detail.oldInteraction,
            personaFisica : this.personaFisica,
            caseBusinessAccount : this.caseBusinessAccount,
            isonchangeselected : this.isonchangeselected,
            lat: this.lat,
            lng: this.lng
        };
        const selectedEvent = new CustomEvent('showgeocoding', {detail : {params}});
        this.dispatchEvent(selectedEvent); 

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
}