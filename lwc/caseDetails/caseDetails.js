import { LightningElement,api,track, wire} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// LABELS
import caseDetails from '@salesforce/label/c.caseDetails_caseDetails';
import next from '@salesforce/label/c.caseDetails_Next';
import compileRequiredFields from '@salesforce/label/c.caseDetails_compileRequiredFields';
import nicTimedOut from '@salesforce/label/c.caseDetails_NicTimedOut';
import nicTimeOutError from '@salesforce/label/c.caseDetails_NicTimeOutError';
import attention from '@salesforce/label/c.caseDetails_Attention';
import themArea from '@salesforce/label/c.caseDetails_ThematicArea';
import argument from '@salesforce/label/c.caseDetails_Argument';
import specific from '@salesforce/label/c.caseDetails_Specific';
import extimatedQueue from '@salesforce/label/c.caseDetails_ExtimatedQueue';
import cancel from '@salesforce/label/c.Cancel';
import geoCoding from '@salesforce/label/c.caseDetails_geoCoding';
import address from '@salesforce/label/c.caseDetails_Address';
import goToGMaps from '@salesforce/label/c.caseDetails_goToGMaps';
import confirmAddress from '@salesforce/label/c.caseDetails_confirmAddress';
import previous from '@salesforce/label/c.caseCreation_Previous';
import topDown from '@salesforce/label/c.caseDetails_topDown';
import bottomUp from '@salesforce/label/c.caseDetails_bottomUp';
// APEX METHODS
import getCaseFields from '@salesforce/apex/CaseDetailsController.getCaseFields';
import findRecords from '@salesforce/apex/CaseDetailsController.findRecords';
import getSynonymous from '@salesforce/apex/CaseDetailsController.getSynonymous';
//import getGoogleMaps from '@salesforce/apex/CaseDetailsController.getGoogleMaps';
//import findMunicipality from '@salesforce/apex/CaseDetailsController.findMunicipality';
import manageMajorRoards from '@salesforce/apex/CaseDetailsController.manageMajorRoards';
//FIELDS
import CASE_OBJECT from '@salesforce/schema/Case';
import RT_FIELD from '@salesforce/schema/Case.RecordTypeId';  
import CURRENTQUEUE_FIELD from '@salesforce/schema/Case.Current_Queue__c';  
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import ACCOUNT_FIELD from '@salesforce/schema/Case.AccountId';
import CONTACT_FIELD from '@salesforce/schema/Case.ContactId';
import SPECIFICATION_FIELD from '@salesforce/schema/Case.Case_Specification__c';
import TOPIC_SERVICE_FIELD from '@salesforce/schema/Case.Case_Topic_Service__c';
import THEME_AREA_FIELD from '@salesforce/schema/Case.Case_Theme_Area__c';
import ESTIMATED_QUEUE_FIELD from '@salesforce/schema/Case.Estimated_Queue__c';
import SERVICE_REQUEST_FIELD from '@salesforce/schema/Case.Service_Request__c';
import ADDRESS_FIELD from '@salesforce/schema/Case.Street_Address__c';
import ADDRESS_NUMBER from '@salesforce/schema/Case.Number_Address__c';
import ADDRESS_LETTER from '@salesforce/schema/Case.Letter_Address__c';
import MUNICIPALITY_CATEGORY from '@salesforce/schema/Case.Municipality_Category__c';
import CASE_GEOLOCALIZATION  from '@salesforce/schema/Case.Case_Geolocalization__c';
import CASE_ALERT_POLICE_WARNING_FIELD from '@salesforce/schema/Case.Case_Alert_Police_Warning__c';
import CASE_NO_REASSIGN from '@salesforce/schema/Case.Case_No_Reassign__c';
import IS_NIC_ERROR from '@salesforce/schema/Case.Is_Nic_Error__c';
import PERSONA_FISICA from '@salesforce/schema/Case.Persona_Fisica__c';
import BUSINESS_ACCOUNT from '@salesforce/schema/Case.Case_Business_Account__c';

export default class CaseDetails extends LightningElement {
    activeSections = ['caseDetails'];
    @api case;
    @api serviceRequest;
    @api selectedqueue;
    @api typologyselected;
    @api nameinteraction;
    @api interactionselected;
    @api caseid;
    @api personaFisica;
    @api caseBusinessAccount;
    @api accountId;
    @api contactId;
    @api origin;
    @api serviceRequestId;
    @track fields;
    @track disableAll = false;
    @track disableQueue;
    @api objectName = 'Taxonomy__c';
    @api searchfield = 'Name,Tax_Theme_Area__c,Tax_Topic_Service__c,Tax_Specification__c,Tax_Queue__c,Tax_Active__c,Tax_Geolocalization__c, Geo_Municipality__c,toLabel(Tax_Type__c), Tax_Alert_Police_Warning__c, MajorRoads__c, Tax_No_Reassign__c';
    @api allRecords;
    @track allRecordsTemp;
    @track allTaxonomy;
    @api thematicArea;
    @api selectedThematicArea;
    @api selectedArgument;
    @api selectedSpecific;
    @track isMajorRoads = false;
    @api argument;
    @api specific;
    @api allArguments;
    @api allSpecifications;
    @api allThemAreas;
    @api disableArgument = false;
    @api disableSpecific = false;
    @track alreadyFired = false;
    @api synonymMap;
    @api estimatedQueue;
    @api casealertpolicewarning;
    @api noReassign;
    @api error;
    @api caseStatus;
    @track showGeoCoding = false;
    @api fullAddress;
    @api address;
    @api letterAddress;
    @api numberAddress;
    @track estimatedQueuePicklist;
    @track alreadyQueriedSyn = false;
    @track disableConfirmAddress = true;
    @track gmapsConfig;
    @api InstructorUser = false;
    @api lat;
    @api lng;
    /*@api isNicError;
    @api callNic = false;*/
    @api isonchangeselected = false;
    @api subject;
    @track showMap= false;
    @track mapMarkers;
    @track zoomLevel = 15;
    @track listView = 'visible';
    @api bottomUp = false;
    @track toggle='';
    @api municipality;
    @track spin = false;
    @api majorRoadsMapped;
    @api isCreation;
    @api maintainTriplets;
    @api originalid;
    @api protocolNumber;
    @api oldInteraction;
    //@track isFirstTime = true;
    @track label = {
        caseDetails,
        next,
        compileRequiredFields,
        attention,
        themArea,
        cancel,
        specific,
        argument,
        extimatedQueue,
        geoCoding,
        address,
        goToGMaps,
        confirmAddress,
        previous,
        nicTimedOut,
        nicTimeOutError
    };

    mapOptions = {draggable: false, scrollwheel: false, disableDefaultUI: true};

    connectedCallback() {
        console.log('isonchangeselected case details connnected component start ' + this.isonchangeselected);
        console.log('bottomUp case details connnected component start ' + this.bottomUp);
        if ( this.isonchangeselected ) {
            this.resetAll();
            this.isonchangeselected = false;
        }

        this.bottomUp = ( this.bottomUp == undefined ? true : this.bottomUp);

        this.toggle = this.bottomUp?bottomUp:topDown;
        this.disableArgument = true;
        this.disableSpecific = true;
        this.disableThematicArea = true;
        this.disableQueue = true;
        this.dontShowRemoveThemArea = this.dontShowRemoveArgument = this.dontShowRemoveSpecific = this.InstructorUser;
            if(this.thematicArea != null && this.thematicArea != ''){
                this.getSynonymous(this.thematicArea,this.argument,this.specific);
            }else{
                this.getSynonymous(null,null,null);
            }
        this.alreadyQueriedSyn = true;
        this.disableConfirmAddress = (this.address == null || this.address =='');
        /*getGoogleMaps({})
        .then(result =>{
            this.gmapsConfig = result;
        });*/

        this.showMap = (this.lat != null && this.lng != null && this.lat != "" && this.lng != "");
        console.log('this.lat ', this.lat);
        console.log('this.lng ', this.lng);
        console.log('this.address ', this.address);
        console.log('this.municipality ', this.municipality);
        if(this.showMap){
            this.mapMarkers = [{
                location: {
                    Latitude: this.lat,
                    Longitude: this.lng
                },
            }];
        }
        this.bottomUp = this.bottomUp;
        console.log('case details connnected component account id ', this.accountId);
        console.log('case details connnected component contact id ', this.contactId);
        console.log('isonchangeselected case details connnected component end ' + this.isonchangeselected);
        console.log('bottomUp case details connnected component end ' + this.bottomUp);
      }


      handleToggle(event){
          this.bottomUp = event.target.checked
          this.toggle = this.bottomUp?bottomUp:topDown;
          this.resetAll();
          if ( !this.bottomUp ) {
            this.dontShowRemoveThemArea = false;
          } else {
              this.dontShowRemoveSpecific = false;
          }
          this.createLists(this.thematicArea,this.argument,this.specific);

      }

      resetAll(){
        this.thematicArea = null;
        this.specific = null;
        this.argument = null;
        this.selectedSpecific = null;
        this.selectedThematicArea = null;
        this.isMajorRoads = false;
        this.selectedArgument = null;
        this.disableThematicArea = (this.bottomUp && (this.thematicArea == null || this.thematicArea =="") && (this.argument == null || this.argument == ""));
        this.disableArgument = true;
        this.disableQueue = true;
        this.disableSpecific = true;
        this.showGeoCoding = false;
        this.estimatedQueue = null;
        //this.callNic = false;
        this.address = null;
        this.letterAddress = null;
        this.numberAddress = null;
        this.fullAddress = null;
        this.municipality = null;
        this.lat = null;
        this.lng = null;
      }

      handleGMap(){
        var params = {
            typologyselected: this.typologyselected,
            interactionselected: this.interactionselected,
            nameinteraction : this.nameinteraction,
            selectedqueue: this.selectedqueue,
            selectedargument: this.argument,
            selectedthemarea: this.thematicArea,
            selectedspecification: this.specific,
            selectedargumentr: this.selectedArgument,
            selectedthemarear: this.selectedThematicArea,
            selectedspecificationr: this.selectedSpecific,
            estimatedQueue: this.estimatedQueue,
            fullAddress: this.fullAddress,
            address: this.address,
            numberAddress: this.numberAddress,
            letterAddress: this.letterAddress,
            /*googleKey: this.gmapsConfig.Google_Key__c,
            vfOrigin: this.gmapsConfig.Visualforce_Origin__c,
            domain: this.gmapsConfig.Domain__c,*/
            bottomUp: this.bottomUp,
            municipality: this.municipality,
            contactId: this.contactId,
            accountId: this.accountId,
            serviceRequestId: this.serviceRequestId,
            origin: this.origin,
            caseid: this.caseid,
            casealertpolicewarning: this.casealertpolicewarning,
            subject: this.subject,
            iscreation: this.isCreation,
            originalid: this.originalid,
            //isNicError: this.isNicError,
            estimatedQueuePicklist: this.estimatedQueuePicklist,
            protocolNumber: this.protocolNumber,
            oldInteraction: this.oldInteraction,
            personaFisica: this.personaFisica,
            caseBusinessAccount: this.caseBusinessAccount,
            isonchangeselected: this.isonchangeselected,
            lat: this.lat,
            lng: this.lng
        };
        const selectedEvent = new CustomEvent('showgeocoding', {detail : params});
        console.log('params ', JSON.parse(JSON.stringify(params)));
        this.dispatchEvent(selectedEvent);
      }


      getSynonymous(themArea, argument,specific){
        getSynonymous({})
        .then(data => {
            this.synonymMap = data;
            if(themArea == null){
                this.findAllTaxonomy(null,null,null);
            }else{
                this.findAllTaxonomy(themArea,argument,specific);
            }
        })
        .catch(error => {
            this.error = error;
            console.log('@@@ error | getSynonymous ', this.error);
            this.synonymMap = undefined;
        });
      }

      findAllTaxonomy(themArea, argument, specific){
        findRecords({
            objectName : this.objectName,
            searchField : this.searchfield,
            additionalTaxType: this.nameinteraction
        })
        .then(result => {
            var results = [];
            Object.assign(results, result);
            if(themArea != null){
                const listHasTax = results.some(tax => tax.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && tax.Tax_Theme_Area__c == themArea && tax.Tax_Topic_Service__c == argument && tax.Tax_Specification__c == specific && tax.Tax_Queue__c == this.estimatedQueue);
                if(!listHasTax){
                    results.push({"Id":"add","Name":"add","Tax_Theme_Area__c":themArea,"Tax_Topic_Service__c":argument,"Tax_Specification__c":specific,"Tax_Queue__c":this.estimatedQueue,"Tax_Active__c":"false","Tax_Geolocalization__c":"false", "Tax_Type__c":this.interactionselected,"MajorRoads__c": listHasTax.MajorRoads__c});
                }
            }
            this.allRecordsTemp = results;
            this.allTaxonomy = results;
            this.createLists(themArea,argument,specific);

            this.error = undefined;

        })
        .catch(error => {
            this.error = error;
            console.log('@@@ error | findAllTaxonomy ', this.error);
            this.allRecords = undefined;
        });
      }

    createLists(themArea, argument,specific){
        var recsNames = [];
        var allRecs = [];
        var alreadyAssigned = false;
        for(let i=0; i < this.allRecordsTemp.length; i++){
            const rec = this.allRecordsTemp[i];
            var record;
            if(this.bottomUp){
                record = {Id: rec["Tax_Specification__c"], Name: rec["Tax_Specification__c"], Synonymous: rec["Tax_Specification__c"]};
            }else{
                record = {Id: rec["Tax_Theme_Area__c"], Name: rec["Tax_Theme_Area__c"], Synonymous: rec["Tax_Theme_Area__c"]};
            }

            if(!recsNames.includes(record.Name)){
                allRecs.push(record);
                var tempSyn = [];
                if(this.bottomUp){
                    tempSyn = this.synonymMap.filter(item => item.Name.toLowerCase() == rec["Tax_Specification__c"].toLowerCase());
                }else{
                    tempSyn = this.synonymMap.filter(item => item.Name.toLowerCase() == rec["Tax_Theme_Area__c"].toLowerCase());
                }
                if(tempSyn.length>0){
                    Array.prototype.push.apply(allRecs, tempSyn)
                }
                recsNames.push(record.Name);
            }

            if(!this.bottomUp && (themArea != null && record.Name==themArea && !alreadyAssigned)){
                alreadyAssigned = true;
                this.selectedThematicArea = record;
                this.disableArgument = false;
                this.findArguments(themArea,argument,specific);
            }
            if(this.bottomUp && (specific != null && record.Name==specific && !alreadyAssigned)){
                alreadyAssigned = true;
                this.selectedSpecific = record;
                this.disableArgument = false;
                this.findArguments(themArea,argument,specific);
            }
        }
        allRecs.sort((a, b) => (a.Name > b.Name) ? 1 : -1);
        this.allRecords = allRecs;
        if(!this.bottomUp) {
            var resultUniqueThemeArea = new Set(this.allRecords.map(item => item.Id));
            console.log('resultUniqueThemeArea -> ' ,resultUniqueThemeArea);
            if ( resultUniqueThemeArea.size == 1 ) {
                this.selectedThematicArea = {Id: this.allRecords[0].Id ,Name: this.allRecords[0].Name};
                this.disableArgument = false;
                this.findArguments(this.allRecords[0].Id,null,null);
                this.dontShowRemoveThemArea = true;
            }
        } else {
            var resultUniqueThemeArea = new Set(this.allRecords.map(item => item.Id));
            console.log('resultUniqueThemeArea -> ' ,resultUniqueThemeArea);
            if ( resultUniqueThemeArea.size == 1 ) {
                this.selectedSpecific = {Id: this.allRecords[0].Id ,Name: this.allRecords[0].Name};
                this.disableArgument = false;
                this.findArguments(null,null,this.allRecords[0].Id);
                this.dontShowRemoveSpecific = true;
            }
        }
    }

    resetOnChangeTaxonomy() {
        this.estimatedQueue = null;
        this.showGeoCoding = false;
        this.fullAddress = null;
        this.address = null;
        this.municipality = null;
        this.showMap = false;
        this.disableQueue = true;
        this.lat = null;
        this.lng = null;
        this.estimatedQueuePicklist = null;
    }

    handleSelectThemArea(event){
        var thematicArea = event.detail.recordId;
        console.log('this.bottomUp -> ', this.bottomUp);

        if(thematicArea == undefined) {
            this.thematicArea = null;
            this.selectedThematicArea = null;
            this.resetOnChangeTaxonomy();
            if(!this.bottomUp) {
                this.template.querySelector("c-custom-lookup[data-lwcid='argument']").Remove();
                this.specific = null;
                this.argument = null;
                this.selectedargument = null;
                this.selectedSpecific = null;
                this.disableArgument = true;
                this.disableSpecific = true;
            } else {
                this.disableThematicArea = false;
            }
        } else {
            this.selectedThematicArea = {Id: thematicArea,Name: thematicArea};
            this.thematicArea = thematicArea;
            if(!this.bottomUp) {
                this.disableArgument = false;
            } else {
                this.disableThematicArea = false;
                this.disableQueue = false;
            }

            if(!this.bottomUp) {
                this.findArguments(thematicArea,null,null);
            } else {
                this.findQueues();
            }
        }
    }

    handleAddress(event){
        this.fullAddress = event.detail.value;
        this.disableConfirmAddress = (this.fullAddress == null || this.fullAddress =='');
    }

      findArguments(thematicArea,argument,specific){
        var allRecs = [];
        var recsNames = [];
        this.thematicArea = thematicArea;
        this.specific = specific;
        var records = [];
        if(!this.bottomUp){
            records = this.allRecordsTemp.filter(rec => rec.Tax_Theme_Area__c == thematicArea);
        }else{
            records = this.allRecordsTemp.filter(rec => rec.Tax_Specification__c == specific);
        }
        var result = records.reduce( (rec,o) => (rec[o.Tax_Topic_Service__c] = (rec[o.Tax_Topic_Service__c]  || 0)+1, rec), {} );
        var uniqueTaxonomy = Object.keys(result).length;
        this.dontShowRemoveArgument = (uniqueTaxonomy==1)  || this.InstructorUser;
        var alreadyAssigned = false;
            for(let i=0; i < records.length; i++){
                const rec = records[i];
                var record = {Id: rec["Tax_Topic_Service__c"],Name: rec["Tax_Topic_Service__c"], Synonymous: rec["Tax_Topic_Service__c"]};
                if(!recsNames.includes(record.Name)){
                    allRecs.push(record);
                    var tempSyn = this.synonymMap.filter(item => item.Name.toLowerCase() == rec["Tax_Topic_Service__c"].toLowerCase());
                    if(tempSyn.length>0){
                        Array.prototype.push.apply(allRecs, tempSyn)
                    }
                    recsNames.push(record.Name);
                }
                if(((argument != null && argument == record.Name)|| uniqueTaxonomy == 1) && !alreadyAssigned){
                    alreadyAssigned = true;
                    this.selectedArgument = record;
                    this.disableSpecific = false;
                    var argToPass = (argument !=null)?argument:record.Name;
                    if(this.bottomUp){
                        this.findThemArea(argToPass,thematicArea);
                    }else{
                        this.findSpecific(argToPass,specific);
                    }
                }
            }
            allRecs.sort((a, b) => (a.Name > b.Name) ? 1 : -1);
            this.error = undefined;
            this.allArguments = allRecs;
      }

      handleSelectArgument(event){
        var argument = event.detail.recordId;

        if(argument == undefined) {
            this.argument = null;
            this.selectedArgument = null;
            if(!this.bottomUp){
                this.template.querySelector("c-custom-lookup[data-lwcid='specific']").Remove();
                this.selectedSpecific = null;
                this.specific = null;
                this.disableSpecific = true;
            }else{
                this.template.querySelector("c-custom-lookup[data-lwcid='themarea']").Remove();
                this.selectedThematicArea = null;
                this.thematicArea = null;
                this.disableThematicArea = true;
            }
            this.resetOnChangeTaxonomy();
          } else {
            if(!this.bottomUp){
                this.findSpecific(argument,null);
            }else{
                this.findThemArea(argument,null);
            }

            this.selectedArgument = {Id: argument,Name: argument};
            this.disableSpecific = false;

        }
    }

    findThemArea(argument,thematicArea){
        var allRecs = [];
          var recsNames = [];
          this.argument = argument;
          var alreadyAssigned = false;
          var records = this.allRecordsTemp.filter(rec => rec.Tax_Specification__c == this.specific && rec.Tax_Topic_Service__c == this.argument);
          var result = records.reduce( (rec,o) => (rec[o.Tax_Theme_Area__c] = (rec[o.Tax_Theme_Area__c]  || 0)+1, rec), {} );
          var uniqueTaxonomy = Object.keys(result).length;
          this.dontShowRemoveThemArea = (uniqueTaxonomy == 1) || this.InstructorUser;
          for(let i=0; i < records.length; i++){
              const rec = records[i];
              var record = {Id: rec["Tax_Theme_Area__c"],Name: rec["Tax_Theme_Area__c"], Synonymous: rec["Tax_Theme_Area__c"]};
              if(!recsNames.includes(record.Name)){
                  allRecs.push(record);
                  var tempSyn = this.synonymMap.filter(item => item.Name.toLowerCase() == rec["Tax_Theme_Area__c"].toLowerCase());
                  if(tempSyn.length>0){
                      Array.prototype.push.apply(allRecs, tempSyn)
                  }
                  recsNames.push(record.Name);
              }
              if(((thematicArea != null && thematicArea == record.Name) || uniqueTaxonomy == 1) && !alreadyAssigned){
                alreadyAssigned = true;
                this.thematicArea = record.Name;
                this.disableQueue = this.InstructorUser;
                this.selectedThematicArea = record;
                this.findQueues();
                //this.showGeoCodingSection();
              }

          }
          allRecs.sort((a, b) => (a.Name > b.Name) ? 1 : -1);
          this.error = undefined;
          this.allThemAreas = allRecs;
    }

    findSpecific(argument,specific){
        var allRecs = [];
          var recsNames = [];
          this.argument = argument;
          var alreadyAssigned = false;
          var records = this.allRecordsTemp.filter(rec => rec.Tax_Theme_Area__c == this.thematicArea && rec.Tax_Topic_Service__c == this.argument);
          var uniqueTaxonomy = 0;
          if(!this.bottomUp){
            var result = records.reduce( (rec,o) => (rec[o.Tax_Specification__c] = (rec[o.Tax_Specification__c]  || 0)+1, rec), {} );
            uniqueTaxonomy = Object.keys(result).length;
          }
          this.dontShowRemoveSpecific = (uniqueTaxonomy==1) || this.InstructorUser;
          for(let i=0; i < records.length; i++){
              const rec = records[i];
              var record = {Id: rec["Tax_Specification__c"],Name: rec["Tax_Specification__c"], Synonymous: rec["Tax_Specification__c"]};
              if(!recsNames.includes(record.Name)){
                  allRecs.push(record);
                  var tempSyn = this.synonymMap.filter(item => item.Name.toLowerCase() == rec["Tax_Specification__c"].toLowerCase());
                  if(tempSyn.length>0){
                      Array.prototype.push.apply(allRecs, tempSyn)
                  }
                  recsNames.push(record.Name);
              }
              if(((specific != null && specific == record.Name)||(!this.bottomUp && uniqueTaxonomy == 1)) && !alreadyAssigned){
                alreadyAssigned = true;
                this.specific = record.Name;
                this.disableQueue = this.InstructorUser;
                this.selectedSpecific = record;
                this.findQueues();
                //this.showGeoCodingSection();
              }

          }
          allRecs.sort((a, b) => (a.Name > b.Name) ? 1 : -1);
          this.error = undefined;
          this.allSpecifications = allRecs;
    }

    findQueues(){
        this.showGeoCodingSection();
        let tmpisMajorRoads = this.allRecordsTemp.filter(rec => rec.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && rec.Tax_Theme_Area__c.toUpperCase() == this.thematicArea.toUpperCase() && rec.Tax_Topic_Service__c.toUpperCase() == this.argument.toUpperCase() && rec.Tax_Specification__c.toUpperCase() == this.specific.toUpperCase() && rec.MajorRoads__c == true);
        if ( tmpisMajorRoads.length == 1 ) {
            this.isMajorRoads = true;
        } else {
            this.isMajorRoads = false;
        }
        console.log('this.isMajorRoads -> ', this.isMajorRoads);
        var estimatedQueue = [];
        if(!this.showGeoCoding) {
            console.log('calling non geo');
            this.municipality = null;
            this.fullAddress = null;
            this.address = null;
            this.letterAddress = null;
            this.numberAddress = null;
            //this.callNic = false;
            estimatedQueue = this.allRecordsTemp.filter(rec => rec.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && rec.Tax_Theme_Area__c == this.thematicArea && rec.Tax_Topic_Service__c == this.argument && rec.Tax_Specification__c == this.specific && rec.Tax_Queue__c != null);
            this.sortQueues(estimatedQueue);
        } else {
            console.log('calling showGeoCoding');
            console.log(this.estimatedQueuePicklist);
            if(this.municipality != null && this.municipality != '') {
                console.log('calling based on municipality ');
                this.setEstimatedQueueAndSortForGeolocalization();
            }
            if(this.municipality == null || this.municipality == '') {
                console.log('blocking');
                this.estimatedQueue = null;
                this.showMap = false;
                this.disableQueue = true;
            }

            /*if(this.callNic) {
                console.log('calling findMunicipality');
                this.findMunicipality(estimatedQueue);
            }
            if(!this.callNic && this.isNicError) {
                let estimatedQueue = this.nicErrorFilterEstimatedQueue();
                this.sortQueues(estimatedQueue);
            }*/
        }
    }

    /*nicErrorFilterEstimatedQueue() {
        let estimatedQueue = this.allRecordsTemp.filter(rec =>
            rec.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() &&
            rec.Tax_Theme_Area__c == this.thematicArea &&
            rec.Tax_Topic_Service__c == this.argument &&
            rec.Tax_Specification__c == this.specific &&
            rec.Tax_Geolocalization__c == true &&
            rec.Tax_Active__c == true );

        return estimatedQueue;
    }*/

    setEstimatedQueueAndSortForGeolocalization() {
        this.spin = true;
        this.manageMajorRoards(this.address);
    }

    sortQueues(estimatedQueue) {
        console.log('estimatedQueue in sortQueues -> ', estimatedQueue);
        var estimatedQueuePicklist = [];

        estimatedQueue.sort((a, b) => (a.Tax_Queue__c > b.Tax_Queue__c) ? 1 : -1);
        let oldValue = '';
        for(let i=0; i < estimatedQueue.length; i++) {
            if(oldValue == '' || estimatedQueue[i].Tax_Queue__c != oldValue) {
                estimatedQueuePicklist.push({value: estimatedQueue[i].Tax_Queue__c, label: estimatedQueue[i].Tax_Queue__c});
            }
            oldValue = estimatedQueue[i].Tax_Queue__c;
        }
        this.estimatedQueuePicklist = estimatedQueuePicklist;
        if(this.estimatedQueuePicklist.length == 1){
            this.estimatedQueue = estimatedQueuePicklist.entries().next().value[1].value;
            //this.showGeoCodingSection();
        }
    }

    manageMajorRoards(addressToFind) {
        manageMajorRoards({addressToFind: addressToFind})
        .then(data => {
            let resultList = data;
            let estimatedQueue;
            let selecteItemQueue;
            if ( resultList[0] == 'isMajorRoads' && this.isMajorRoads == true)  {
                if ( resultList[1] == 'isPartialRoad') {
                    estimatedQueue = this.allRecordsTemp.filter(rec => rec.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && rec.Tax_Theme_Area__c == this.thematicArea && rec.Tax_Topic_Service__c == this.argument && rec.Tax_Specification__c == this.specific && rec.Tax_Geolocalization__c == true && rec.Tax_Queue__c != null && (rec.Geo_Municipality__c == this.municipality || rec.Geo_Municipality__c == 'ALL' || rec.Geo_Municipality__c == null));
                    selecteItemQueue = true;
                } else {
                    estimatedQueue = this.allRecordsTemp.filter(rec => rec.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && rec.Tax_Theme_Area__c.toUpperCase() == this.thematicArea.toUpperCase() && rec.Tax_Topic_Service__c.toUpperCase() == this.argument.toUpperCase() && rec.Tax_Specification__c.toUpperCase() == this.specific.toUpperCase() && rec.Tax_Geolocalization__c == true && rec.Tax_Queue__c != null && rec.MajorRoads__c == true);
                }
            } else {
                estimatedQueue = this.allRecordsTemp.filter(rec => rec.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && rec.Tax_Theme_Area__c == this.thematicArea && rec.Tax_Topic_Service__c == this.argument && rec.Tax_Specification__c == this.specific && rec.Tax_Geolocalization__c == true && rec.Tax_Queue__c != null && (rec.Geo_Municipality__c == this.municipality || rec.Geo_Municipality__c == 'ALL' || rec.Geo_Municipality__c == null) && rec.MajorRoads__c == false);
            }
            /*
            if(this.isNicError) {
                estimatedQueue = this.allRecordsTemp.filter(rec =>
                    rec.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() &&
                    rec.Tax_Theme_Area__c == this.thematicArea &&
                    rec.Tax_Topic_Service__c == this.argument &&
                    rec.Tax_Specification__c == this.specific &&
                    rec.Tax_Geolocalization__c == true &&
                    rec.Tax_Active__c == true );
            }
            */
            console.log('estimatedQueue | manageMajorRoards -> ', estimatedQueue);
            console.log('selecteItemQueue | manageMajorRoards -> ', selecteItemQueue);
            this.sortQueues(estimatedQueue);
            if ( selecteItemQueue ) this.selectItemInQueue();
        })
        .catch(error => {
            this.error = error;
            console.log('@@@ error | manageMajorRoards ', this.error);
        })
        .finally(() => {
            this.spin = false;
        });
    }

    selectItemInQueue() {
        let valueToSelect = this.allRecordsTemp.filter(rec => rec.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && rec.Tax_Theme_Area__c == this.thematicArea && rec.Tax_Topic_Service__c == this.argument && rec.Tax_Specification__c == this.specific && rec.Tax_Geolocalization__c == true && rec.Tax_Queue__c != null && (rec.Geo_Municipality__c == this.municipality || rec.Geo_Municipality__c == 'ALL' || rec.Geo_Municipality__c == null) && rec.MajorRoads__c == true);
        this.estimatedQueue = valueToSelect[0].Tax_Queue__c;
    }

    /*findMunicipality(estimatedQueue) {
        this.spin = true;
        this.disableAll = true;
        findMunicipality({lat: this.lat, lng: this.lng})
        .then(data => {
            this.estimatedQueue = '';
            if(data.municipio.numberMunicipio != null && data.municipio.numberMunicipio != undefined) {
                this.municipalityFromNic = data.municipio.numberMunicipio;
                console.log('findMunicipality, municipalityFromNic -> ' + this.municipalityFromNic);
                this.isNicError = false;
                console.log('isNicError false -> ', this.isNicError);

                this.setEstimatedQueueAndSortForGeolocalization();
            } else {
                console.log('this.showGeoCoding -> ', this.showGeoCoding);
                console.log('this.address -> ', this.address);
                console.log('this.lat -> ', this.lat);
                console.log('this.lng -> ', this.lng);
                if(data.nicError.message != null && data.nicError.message != undefined && this.showGeoCoding && this.address != null && this.address != '') {
                    estimatedQueue = this.nicErrorFilterEstimatedQueue();
                    console.log('estimatedQueue -> ', estimatedQueue);
                    this.sortQueues(estimatedQueue);
                    this.disableQueue = false;
                    console.log('estimatedQueue -> ', estimatedQueue);
                    this.isNicError = true;
                    console.log('isNicError true -> ', this.isNicError);
            /!*
                } else if(data.nicError == this.label.nicTimeOutError) {
                    this.showToast(this.label.attention, this.label.nicTimedOut,'error',"dismissable");
                    console.log('continue blocking');
                    this.disableQueue = true;
            *!/
                } else {
                    console.log('continue blocking');
                    this.disableQueue = true;
                }
            }
            this.spin = false;
            this.disableAll = false;
        })
        .catch(error => {
            this.error = error;
            console.log('@@@ error | findMunicipality ', this.error);
            this.spin = false;
            this.disableAll = false;
        });
    }*/

    handleSelectSpecific(event){
        var specific = event.detail.recordId;
        this.specific = specific;
        if(specific != undefined) {
            this.selectedSpecific = {Id: specific,Name: specific};
            if(this.bottomUp){
                this.findArguments(null,null,specific);
                this.disableArgument = false;
            } else {
                this.disableQueue = false;
            }
        } else {
            this.disableSpecific = false;
            this.specific = null;
            this.selectedSpecific = null;
            this.resetOnChangeTaxonomy();

            if(this.bottomUp){
                this.template.querySelector("c-custom-lookup[data-lwcid='argument']").Remove();
                this.argument = null;
                this.thematicArea = null;
                this.disableArgument = true;
                this.disableThematicArea = true;
            }
        }
        if(!this.bottomUp && specific != undefined) {
        this.findQueues();
        }
    }

      handleEstimatedQueueSelection(event){
        this.estimatedQueue = event.detail.value;
        //this.showGeoCodingSection();
      }
      showGeoCodingSection(){
        this.showGeoCoding = this.allTaxonomy.some(tax => tax.Tax_Theme_Area__c == this.thematicArea && tax.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && tax.Tax_Topic_Service__c == this.argument && tax.Tax_Specification__c == this.specific && tax.Tax_Geolocalization__c == true);
        if(this.showGeoCoding) {
            this.activeSections.push('geoCoding');
        } else {
            this.lng = null;
            this.lat = null;
        }
    }

    handleCancel(){
        let action;
        if ( this.interactionselected == 'Sollecito'  ) {
            action = 'noCloseTab';
        }     
        const selectedEvent = new CustomEvent('filterchange', {
            detail: { action }            
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);

    }

    navigationToRecord(idCase){
        getCaseFields({rtId: this.typologyselected})
            .then(data =>{
                var params = {
                    caseid: idCase,
                    fields: data,
                    typologyselected: this.typologyselected,
                    nameinteraction: this.nameinteraction,
                    interactionselected: this.interactionselected,
                    selectedqueue: this.selectedqueue,
                    selectedargument: this.argument,
                    selectedthemarea: this.thematicArea,
                    selectedspecification: this.specific,
                    selectedargumentr: this.selectedArgument,
                    selectedthemarear: this.selectedThematicArea,
                    selectedspecificationr: this.selectedSpecific,
                    estimatedQueue: this.estimatedQueue,
                    activeTax: this.allTaxonomy.find(tax => tax.Tax_Theme_Area__c == this.thematicArea && tax.Tax_Topic_Service__c == this.argument && tax.Tax_Specification__c == this.specific && tax.Tax_Queue__c == this.estimatedQueue).Tax_Active__c,
                    fullAddress: this.fullAddress,
                    address: this.address,
                    numberAddress: this.numberAddress,
                    letterAddress: this.letterAddress,
                    bottomUp: this.bottomUp,
                    municipality: this.municipality,
                    contactId: this.contactId,
                    accountId: this.accountId,
                    serviceRequestId: this.serviceRequestId,
                    origin: this.origin,
                    lat: this.lat,
                    lng: this.lng,
                    casealertpolicewarning: this.casealertpolicewarning,
                    subject: this.subject,
                    iscreation: this.isCreation,
                    maintainTriplets: this.maintainTriplets,
                    noReassign: this.noReassign,
                    originalid: this.originalid,
                    //isNicError : this.isNicError,
                    protocolNumber: this.protocolNumber,
                    oldInteraction: this.oldInteraction,
                    personaFisica : this.personaFisica,
                    caseBusinessAccount : this.caseBusinessAccount,
                    isonchangeselected: this.isonchangeselected
                };
                const selectedEvent = new CustomEvent('nextfromdetails', {
                    detail : params
                });
                //dispatching the custom event
                this.dispatchEvent(selectedEvent);
                this.disableAll = false;
                this.spin = false;
            });
    }

    resetSubject() {
        if(this.subject != this.specific && this.allTaxonomy.find(tax => tax.Tax_Specification__c == this.subject)) this.subject = '';
    }

    handleNext(event) {
        this.maintainTriplets = (this.dontShowRemoveThemArea && this.dontShowRemoveArgument && this.dontShowRemoveSpecific);
        this.disableAll = true;
        this.spin = true;
        this.resetSubject();

        var areValidFields = this.validateRequiredFields(event);

        //var tax = this.allTaxonomy.find(tax => tax.Tax_Theme_Area__c == this.thematicArea && tax.Tax_Topic_Service__c == this.argument && tax.Tax_Specification__c == this.specific && tax.Tax_Queue__c == this.estimatedQueue && tax.Tax_Active__c && tax.Geo_Municipality__c == this.municipalitycategory);
        var tax = this.allTaxonomy.find(tax => tax.Tax_Theme_Area__c == this.thematicArea && tax.Tax_Topic_Service__c == this.argument && tax.Tax_Specification__c == this.specific && tax.Tax_Queue__c == this.estimatedQueue && tax.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && (tax.Geo_Municipality__c == this.municipality || tax.Geo_Municipality__c == 'ALL' || tax.Geo_Municipality__c == null));

        var taxNoReassign = this.allTaxonomy.find(tax => tax.Tax_Theme_Area__c == this.thematicArea && tax.Tax_Topic_Service__c == this.argument && tax.Tax_Specification__c == this.specific && tax.Tax_Queue__c == this.estimatedQueue && tax.Tax_Type__c.toUpperCase() == this.interactionselected.toUpperCase() && (tax.Geo_Municipality__c == this.municipality || tax.Geo_Municipality__c == 'ALL' || tax.Geo_Municipality__c == null));

        console.log('tax ' + JSON.stringify(tax));
        if(tax == undefined) {
            this.casealertpolicewarning = false;
        } else {
            this.casealertpolicewarning = tax.Tax_Alert_Police_Warning__c;
        }

        console.log('taxNoReassign ' + JSON.stringify(taxNoReassign));
        if(taxNoReassign) {
            this.noReassign = taxNoReassign.Tax_No_Reassign__c;
        } else {
            this.noReassign = false;
        }

        if(areValidFields) {
            const fields = {};
            fields[RT_FIELD.fieldApiName] = this.typologyselected;
            fields[CURRENTQUEUE_FIELD.fieldApiName] = this.selectedqueue;
            fields[TYPE_FIELD.fieldApiName] = this.interactionselected;
            fields[CONTACT_FIELD.fieldApiName] = this.contactId;
            fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
            fields[ORIGIN_FIELD.fieldApiName] = this.origin;
            fields[SERVICE_REQUEST_FIELD.fieldApiName] = this.serviceRequestId;
            fields[SPECIFICATION_FIELD.fieldApiName] = this.specific;
            fields[TOPIC_SERVICE_FIELD.fieldApiName] = this.argument;
            fields[THEME_AREA_FIELD.fieldApiName] = this.thematicArea;
            fields[ESTIMATED_QUEUE_FIELD.fieldApiName] = this.estimatedQueue;
            fields[ADDRESS_FIELD.fieldApiName] = this.address;
            fields[ADDRESS_NUMBER.fieldApiName] = this.numberAddress;
            fields[ADDRESS_LETTER.fieldApiName] = this.letterAddress;
            fields[MUNICIPALITY_CATEGORY.fieldApiName] = (this.municipality == null) ? '' : this.municipality.toString();
            fields[CASE_GEOLOCALIZATION.fieldApiName] = this.showGeoCoding;
            fields.Geolocation__Latitude__s = this.lat;
            fields.Geolocation__Longitude__s = this.lng;
            fields[CASE_ALERT_POLICE_WARNING_FIELD.fieldApiName] = this.casealertpolicewarning;
            fields[CASE_NO_REASSIGN.fieldApiName] = this.noReassign;
            //fields[IS_NIC_ERROR.fieldApiName] = this.isNicError;
            fields[PERSONA_FISICA.fieldApiName] = this.personaFisica;
            fields[BUSINESS_ACCOUNT.fieldApiName] = this.caseBusinessAccount;

            if(this.caseid == null || this.caseid == '') {
                const recordInput = { apiName: CASE_OBJECT.objectApiName, fields };
                createRecord(recordInput)
                    .then(data => {
                        this.caseid = data.id;
                        this.navigationToRecord(this.caseid);
                        
                    });

                } else {
                    this.navigationToRecord(this.caseid);
                }
        } else {
            this.showToast(this.label.attention,this.label.compileRequiredFields,'error',"dismissable");
            this.disableAll = false;
            this.spin = false;
        }
    }
    validateRequiredFields(event) {
        var specific = (this.specific != null && this.specific != '');
        var argument = (this.argument != null && this.argument != '');
        var thematicArea = (this.thematicArea != null && this.thematicArea != '');
        var estimatedQueue = (this.estimatedQueue != null && this.estimatedQueue != '');
        return specific && argument && thematicArea && estimatedQueue;
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
    handlePrevious() {
        var params = {
            typologyselected: this.typologyselected,
            nameinteraction: this.nameinteraction,
            interactionselected: this.interactionselected,
            selectedqueue: this.selectedqueue,
            selectedargument: this.argument,
            selectedthemarea: this.thematicArea,
            selectedspecification: this.specific,
            selectedargumentr: this.selectedArgument,
            selectedthemarear: this.selectedThematicArea,
            selectedspecificationr: this.selectedSpecific,
            estimatedQueue: this.estimatedQueue,
            fullAddress: this.fullAddress,
            address: this.address,
            numberAddress: this.numberAddress,
            letterAddress: this.letterAddress,
            bottomUp: this.bottomUp,
            municipality: this.municipality,
            caseid: this.caseid,
            lat: this.lat,
            lng: this.lng,
            casealertpolicewarning: this.casealertpolicewarning,
            subject: this.subject,
            iscreation: this.isCreation,
            originalid: this.originalid,
            //isNicError : this.isNicError,
            protocolNumber: this.protocolNumber,
            oldInteraction: this.oldInteraction,
            personaFisica : this.personaFisica,
            caseBusinessAccount : this.caseBusinessAccount,
            accountId: this.accountId,
            contactId: this.contactId,
            origin: this.origin,
            serviceRequestId: this.serviceRequestId
        };
        const selectedEvent = new CustomEvent('previousfromdetails', {detail : params});
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);
        
    }
    
}