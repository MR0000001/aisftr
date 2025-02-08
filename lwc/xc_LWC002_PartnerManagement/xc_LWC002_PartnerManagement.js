import { LightningElement,api,wire, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';



import getPickListValues from '@salesforce/apex/XC_LWCC002_PartnerManagement.getPickListValues';
import createContactAndPersonalDocument from '@salesforce/apex/XC_LWCC002_PartnerManagement.createContactAndPersonalDocument';
import loadExistingContact from '@salesforce/apex/XC_LWCC002_PartnerManagement.loadExistingContact';
import enableAsPartner from '@salesforce/apex/XC_LWCC002_PartnerManagement.enableAsPartner';
import retrieveAndDeleteContact from '@salesforce/apex/XC_LWCC002_PartnerManagement.retrieveAndDeleteContact';
import retrieveContactInfo from '@salesforce/apex/XC_LWCC002_PartnerManagement.retrieveContactInfo';
import editContact from '@salesforce/apex/XC_LWCC002_PartnerManagement.editContact';
import checkIfUserNeedToBeCreated from '@salesforce/apex/XC_LWCC002_PartnerManagement.checkIfUserNeedToBeCreated';
import getPickListValuesRole from '@salesforce/apex/XC_LWCC002_PartnerManagement.getPickListValuesRole';
import createUser from '@salesforce/apex/XC_LWCC002_PartnerManagement.createUser';
import createServiceTerritory from '@salesforce/apex/XC_LWCC002_PartnerManagement.createServiceTerritory';
import findServiceResourceToInsert from '@salesforce/apex/XC_LWCC002_PartnerManagement.findServiceResourceToInsert';
import createServiceResourceToInsert from '@salesforce/apex/XC_LWCC002_PartnerManagement.createServiceResource';
import createServiceTerritoryMemberToInsert from '@salesforce/apex/XC_LWCC002_PartnerManagement.createServiceTerritoryMemberToInsert';
import loadGroupOfPartner from '@salesforce/apex/XC_LWCC002_PartnerManagement.loadGroupOfPartner';
import insertUserToGroupMember from '@salesforce/apex/XC_LWCC002_PartnerManagement.insertUserToGroupMember';
import checkAndCreateServiceResourceShare from '@salesforce/apex/XC_LWCC002_PartnerManagement.checkAndCreateServiceResourceShare';
import loadValueAndServiceResourceForSkillManagement from '@salesforce/apex/XC_LWCC002_PartnerManagement.loadValueAndServiceResourceForSkillManagement';
import createServiceResourceSkill from '@salesforce/apex/XC_LWCC002_PartnerManagement.createServiceResourceSkill';
import deleteUserFromFieldServiceDefault from '@salesforce/apex/XC_LWCC002_PartnerManagement.deleteUserFromFieldServiceDefault';
import openNextStep from '@salesforce/apex/XC_LWCC002_PartnerManagement.openNextStep';
import logoEnelX from '@salesforce/resourceUrl/XC_SR_EnelXLogo_PartnerManagement';
import logoSuccess from '@salesforce/resourceUrl/XC_SR_Success_PartnerManagement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import headerPartnerManagement from '@salesforce/label/c.XC_CL_PartnerManagement_Header';
import searchLookup from '@salesforce/label/c.XC_CL_Search';
import placeholderSearch from '@salesforce/label/c.XC_CL_PartnerManagement_PlaceHolderSearch';
import createContactHeader from '@salesforce/label/c.XC_CL_PartnerManagement_CreateContactHeader';
import partnerInformationHeader from '@salesforce/label/c.XC_CL_PartnerManagement_PartnerInformationHeader';
import partnerName from '@salesforce/label/c.XC_CL_PartnerManagement_PartnerName';
import partnerDocNumb from '@salesforce/label/c.XC_CL_PartnerManagement_PartnerDocumentNumb';
import partnerDocNumbVAT1 from '@salesforce/label/c.XC_CL_PartnerManagement_PartnerDocumentNumbVat1';
import partnerDocNumbVAT2 from '@salesforce/label/c.XC_CL_PartnerManagement_PartnerDocumentNumbVat2';
import partnerCommercialCode from '@salesforce/label/c.XC_CL_PartnerManagement_PartnerCommercialCode';
import partnerIsPartner from '@salesforce/label/c.XC_CL_PartnerManagement_PartnerIsPartner';
import partnerType from '@salesforce/label/c.XC_CL_PartnerManagement_PartnerType';
import enableAspartnerButtonLabel from '@salesforce/label/c.XC_CL_PartnerManagement_EnableAsPartnerLabel';
import nextStepButtonLabel from '@salesforce/label/c.XC_CL_PartnerManagement_NextStepButton';
import createNewContactHeader from '@salesforce/label/c.XC_CL_PartnerManagement_CreateNewContactHeader';
import firstNameCont from '@salesforce/label/c.XC_CL_PartnerManagement_FirstNameContact';
import lastNameCont from '@salesforce/label/c.XC_CL_PartnerManagement_LastNameContact';
import emailCont from '@salesforce/label/c.XC_CL_PartnerManagement_EmailContact';
import typeOfCont from '@salesforce/label/c.XC_CL_PartnerManagement_TypeOfContact';
import primaryPhonePrefixCont from '@salesforce/label/c.XC_CL_PartnerManagement_PrimaryPhonePrefixCont';
import primaryPhoneCont from '@salesforce/label/c.XC_CL_PartnerManagement_PrimaryPhoneCont';
import primaryCont from '@salesforce/label/c.XC_CL_PartnerManagement_PrimaryCont';
import documentCountryCont from '@salesforce/label/c.XC_CL_PartnerManagement_DocumentCountryCont';
import documentTypeCont from '@salesforce/label/c.XC_CL_PartnerManagement_DocumentTypeCont';
import documentNumberCont from '@salesforce/label/c.XC_CL_PartnerManagement_DocumentNumberCont';
import mainDocCont from '@salesforce/label/c.XC_CL_PartnerManagement_MainDocCont';
import giveDataToCont from '@salesforce/label/c.XC_CL_PartnerManagement_GiveDataToCont';
import giveDataToThirdCont from '@salesforce/label/c.XC_CL_PartnerManagement_GiveDataToThirdCont';
import mainLegalEntityCont from '@salesforce/label/c.XC_CL_PartnerManagement_MainLegalEntityCont';
import cancelButtonLabel from '@salesforce/label/c.XC_CL_PartnerManagement_CancelButton';
import editContHeader from '@salesforce/label/c.XC_CL_PartnerManagement_EditContactHeader';
import createUserHeader from '@salesforce/label/c.XC_CL_PartnerManagement_CreateUserHeader';
import receivingChannelUser from '@salesforce/label/c.XC_CL_PartnerManagement_ReceivingChannelUser';
import roleUser from '@salesforce/label/c.XC_CL_PartnerManagement_RoleUser';
import subChannelUser from '@salesforce/label/c.XC_CL_PartnerManagement_SubChannelUser';
import serviceTerritoryLabel from '@salesforce/label/c.XC_CL_PartnerManagement_ServiceTerritoryLabel';
import serviceResourceLabel from '@salesforce/label/c.XC_CL_PartnerManagement_ServiceResourceLabel';
import serviceTerritoryMemberLabel from '@salesforce/label/c.XC_CL_PartnerManagement_ServiceTerritoryMemberLabel';
import groupsMemberLabel from '@salesforce/label/c.XC_CL_PartnerManagement_GroupsMemberLabel';
import serviceResourceShareLabel from '@salesforce/label/c.XC_CL_PartnerManagement_ServiceResourceShareLabel';
import skillLabel from '@salesforce/label/c.XC_CL_PartnerManagement_SkillLabel';
import massiveOpenMessage from '@salesforce/label/c.XC_CL_PartnerManagement_OpenMassiveMessage';
import sharingBatchMessage from '@salesforce/label/c.XC_CL_PartnerManagement_OpenSharingBatchMessage';
import clickHereMessage from '@salesforce/label/c.XC_CL_PartnerManagement_ClickHereMessage';
import groupMemberHeader from '@salesforce/label/c.XC_CL_PartnerManagement_GroupMemberHeader';
import selectGroupLabel from '@salesforce/label/c.XC_CL_PartnerManagement_SelectGroupLabel';
import availableLabel from '@salesforce/label/c.XC_CL_PartnerManagemen_AvailableLabel';
import selectedLabel from '@salesforce/label/c.XC_CL_PartnerManagemen_SelectedLabel';
import selectSkillLabel from '@salesforce/label/c.XC_CL_PartnerManagemen_SelectSkillLabel';
import skillHeader from '@salesforce/label/c.XC_CL_PartnerManagemen_SkillHeader';
import contactCreated from '@salesforce/label/c.XC_CL_PartnerManagemen_SuccessContactCreation';
import contactUpdated from '@salesforce/label/c.XC_CL_PartnerManagemen_SuccessContactUpdated';
import accountUpdated from '@salesforce/label/c.XC_CL_PartnerManagemen_SuccessAccountUpdated';
import contactDeleted from '@salesforce/label/c.XC_CL_PartnerManagemen_SuccessContactDeleted';
import userCreation from '@salesforce/label/c.XC_CL_PartnerManagemen_SuccessUserCreation';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COUNTRY_FIELD from '@salesforce/schema/Contact.XC_ContactDocumentCountry__c';
import DOCUMENTTYPE_FIELD from '@salesforce/schema/Contact.XC_ContactDocumentType__c';



      const actions = [
        { label: 'Create User', name: 'create_user' },
        { label: 'Delete Contact', name: 'delete_contact' },
        { label: 'Edit Contact', name: 'edit_contact' }
      ];
      const columns = [
        { label: 'First Name', fieldName: 'FirstName' },
        { label: 'Last Name', fieldName: 'LastName' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Document Number', fieldName: 'DocumentNumber'},
        { label: 'Type Of Contact', fieldName: 'TypeOfContact'},
        { label: 'User Created', fieldName: 'UserCreated', 
            cellAttributes:{ 
                  iconName: { 
                      fieldName: 'UserCreatedIcon' 
                  },
              iconPosition: 'left', 
              iconAlternativeText: 'UserCreated' 
            }
        },
        { label: 'Username', fieldName: 'UserUsername'},
        { label: 'Receiving Channel User', fieldName: 'UserReceivingChannel'},
        { label: 'SubChannel User', fieldName: 'UserSubChannel'},
        {
            type: 'action',
            typeAttributes: { rowActions: actions },
        },
      ];

export default class Xc_LWC002_PartnerManagement extends NavigationMixin(LightningElement) {

    label = {
    headerPartnerManagement, searchLookup,placeholderSearch,createContactHeader,partnerInformationHeader,partnerName,partnerDocNumb,partnerCommercialCode,partnerIsPartner,partnerType,enableAspartnerButtonLabel,nextStepButtonLabel,createNewContactHeader,firstNameCont,lastNameCont,emailCont,typeOfCont,primaryPhonePrefixCont,primaryPhoneCont,primaryCont,documentCountryCont,documentTypeCont,documentNumberCont,mainDocCont,giveDataToCont,giveDataToThirdCont,mainLegalEntityCont,cancelButtonLabel,editContHeader,createUserHeader,receivingChannelUser,roleUser,subChannelUser,serviceTerritoryLabel,serviceResourceLabel,serviceTerritoryMemberLabel,groupsMemberLabel,serviceResourceShareLabel,skillLabel,massiveOpenMessage,sharingBatchMessage,clickHereMessage,groupMemberHeader,selectGroupLabel,availableLabel,selectedLabel,selectSkillLabel,skillHeader,contactCreated,contactUpdated,accountUpdated,contactDeleted, userCreation, partnerDocNumbVAT1, partnerDocNumbVAT2
    };

    enelXLogoExport = logoEnelX;
    successLogoExport = logoSuccess;
    @api recordFound = false;
    @api notLoaded = false;
    @api spinnerControlModal = false;
    @api spinnerControlDatatable = false;
    @api isModalOpenContact = false;
    @api isModalOpenContactEdit = false;
    //Account Field
    @api accountName = '';
    @api documentNumber;
    @api documentNumberVat1;
    @api documentNumberVat2;
    @api commercialCode;
    @api isPartner;
    //Contact Field
    @track contactObject = {};
    @track accountObject = [];

    @api giveDataToContact;
    @api giveDataToThirdPartiesContact;
    @api mainLegalEntityContact;
    dependentDisabled=true;

    dependentPicklist = [];
    @api typeOfContactOpt;
    @api primaryPhonePrefixOpt;
    @api legalEntityOpt;

    @track documentCountryOpt;
    @track documentTypeOpt;

    @api firstNameContactValue = '';
    @api lastNameContactValue = '';
    @api emailContactValue = '';
    @api typeOfContactValue = '';
    @api phonePrefixContactValue = '';
    @api phoneContactValue = '';
    @api documentCountryContactValue = '';
    @api documentNumberContactValue = '';
    @api documentTypeContactValue = '';
    @api primaryContactValue = false;
    @api giveDataToContactValue = false;
    @api giveDataToThirdPartiesContactValue = false;
    @api mainLegalEntityContactValue = '';
    @api contactToEdit ;

    @api primaryContactDisabled = false;
    @api giveDataToContactDisabled = false;
    @api giveDataToThirdPartiesContactDisabled = false;
    @api mainLegalEntityContactDisabled = false;


    @api isModalOpenCreateUser = false;
    @api receivingChannelUserOpt;
    @api userObject = {};
    @api contactSelected ;
    @api roleUserOpt;
    @api showUsernameBox = false;

    @api isRenderedFLSCard = false;

    @track hasErrorOnInsert = false;
    @track selectedStep = 1;
    @api disabledNextStep = false;
    @api showErrorMessageOnPathBool = false;
    @api errorMessage = '';

    objectName = 'Account';

    @api options = [];
    @api listViewData = [];
    columns = columns;
    record = {};

    @api listOfServiceResourceName = [];
    @api activeSections = [];
    @api isModalOpenServiceResource = false;
    @api serviceResourceNameRole = [];
    @api listOfServiceResource ;

    @api isModalGroupMemberOpen = false;
    @track optionsGroup =[];
    @track selectedGroup = [];
    @track requiredGroup = [];

    @api showModalSkill = false;
    @api serviceResourceListSkill = [];
    @api skillNameList = [];
    @track selectedSkill = [];

    @api showSuccess = false;

    @api enableAsPartnerButtonDisabled = false;

    @api delayInMilliseconds = 3000;


    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

    @wire(getPicklistValues, { recordTypeId: '$contactInfo.data.defaultRecordTypeId', fieldApiName: DOCUMENTTYPE_FIELD })
    slaFieldInfo({ data, error }) {
        if (data) this.slaFieldData = data;
    }

    @wire(getPicklistValues, { recordTypeId: '$accountInfo.data.defaultRecordTypeId', fieldApiName: COUNTRY_FIELD })
    upsellFieldInfo({ data, error }) {
        if (data) this.documentCountryOpt = data.values;
    }

   

    handleRowAction(event) {
      const actionName = event.detail.action.name;
      const row = event.detail.row;
      switch (actionName) {
          case 'create_user':
              this.openModalcreateUser(row);
              break;
          case 'delete_contact':
              this.deleteContact(row);
              break;
          case 'edit_contact':
            this.openModalContactEdit(row);
            break;
          default:
      }
  }

      // handler custom lookup component event 
      lookupRecord(event){
        this.showUsernameBox = false;
        this.notLoaded = true;
        let account = [];
        let userCreated = '';
        let accountObject = [];
        let userSubChannel = '';
        let userReceivingChannel = '';
        let usernameUser = '';
        account =  JSON.stringify(event.detail.selectedRecord);
        if(account != undefined){
          this.accountObject = JSON.parse(account);
          this.accountName = (this.accountObject["Name"] != null || this.accountObject["Name"] != undefined) ? this.accountObject["Name"] : null;
          this.documentNumber = (this.accountObject['IdentityNumber__c'] != null || this.accountObject['IdentityNumber__c'] != undefined) ? this.accountObject['IdentityNumber__c'] : null;
          this.documentNumberVat1 = (this.accountObject['XC_VAT_Number1__c'] != null || this.accountObject['XC_VAT_Number1__c'] != undefined) ? this.accountObject['XC_VAT_Number1__c'] : null;
          this.documentNumberVat2 = (this.accountObject['XC_VAT_Number2__c'] != null || this.accountObject['XC_VAT_Number2__c'] != undefined) ? this.accountObject['XC_VAT_Number2__c'] : null;
          this.commercialCode = (this.accountObject['XC_CommercialCode__c'] != null || this.accountObject['XC_CommercialCode__c'] != undefined) ? this.accountObject['XC_CommercialCode__c'] : null;
          this.isPartner = (this.accountObject["IsPartner"] != null || this.accountObject["IsPartner"] != undefined) ? this.accountObject["IsPartner"] : false;
          this.partnerType = (this.accountObject["XC_PartnerType__c "] != null || this.accountObject["XC_PartnerType__c"] != undefined) ? this.accountObject["XC_PartnerType__c"] : null;
        } 
        this.enableAsPartnerButtonDisabled =  this.isPartner;
        if (account === undefined){
          this.recordFound = false;
          this.listViewData = [];
          this.options = [];
        }else{
          loadExistingContact({
            accountFound: this.accountObject
          })
          .then(result => {
            this.listViewData = [];
            for(let key in result){
              if (result.hasOwnProperty(key)) {
                if(result[key].Users != undefined || result[key].Users != null){
                  userCreated = 'action:approval';
                  userSubChannel = result[key].Users[0].XC_SubChannel__c;
                  userReceivingChannel = result[key].Users[0].XC_Receiving_Channel__c;
                  usernameUser = result[key].Users[0].Username;
                }else{
                  userCreated = 'action:close';
                  userSubChannel = '';
                  userReceivingChannel = '';
                  usernameUser = '';
                }
                this.options.push({keyId : result[key].Id,
                  FirstName : result[key].FirstName,
                  LastName : result[key].LastName,
                  Email : result[key].Email,
                  DocumentNumber : result[key].XC_ContactDocumentNumber__c,
                  TypeOfContact : result[key].XC_TypeOfContact__c,
                  UserCreatedIcon : userCreated,
                  UserUsername : usernameUser,
                  UserReceivingChannel : userReceivingChannel,
                  UserSubChannel : userSubChannel,
                });
              }
            }
            this.listViewData = JSON.parse(JSON.stringify(this.options));
            this.recordFound = true;
          })
          .catch(error => {
            this.displayError(error);
          });
        }
        this.notLoaded = false;
    }

    changeColorMouseOverFilter(){
      const element = this.template.querySelector('[data-id="createContact"]').className ='classOperationOver';
    }

    changeColorMouseOutFilter(){
      const element = this.template.querySelector('[data-id="createContact"]').className ='classOperation';
    }

    openModalContact (){
      this.notLoaded = true;
      getPickListValues({
				objApiName: 'Contact',
				fieldName: 'XC_TypeOfContact__c'
			})
			.then(data => {
				this.typeOfContactOpt = data;
			})
			.catch(error => {
				this.displayError(error);
			});
      getPickListValues({
				objApiName: 'Contact',
				fieldName: 'XC_PhonePrefix__c'
			})
			.then(data => {
				this.primaryPhonePrefixOpt = data;
			})
			.catch(error => {
				this.displayError(error);
			});
      getPickListValues({
				objApiName: 'Contact',
				fieldName: 'XC_ContactDocumentCountry__c'
			})
			.then(data => {
				this.documentCountryOpt = data;
			})
			.catch(error => {
				this.displayError(error);
			});
      getPickListValues({
				objApiName: 'Contact',
				fieldName: 'XC_MainLegalEntity__c'
			})
			.then(data => {
				this.legalEntityOpt = data;
			})
			.catch(error => {
				this.displayError(error);
			});
      
      this.isModalOpenContact = true;
      this.notLoaded = false;
    }

    openModalContactEdit (row){
      this.spinnerControlDatatable = true;
        let cont = JSON.parse(JSON.stringify(row));
        getPickListValues({
          objApiName: 'Contact',
          fieldName: 'XC_TypeOfContact__c'
        })
        .then(data => {
          this.typeOfContactOpt = data;
        })
        .catch(error => {
          this.displayError(error);
        });
        getPickListValues({
          objApiName: 'Contact',
          fieldName: 'XC_PhonePrefix__c'
        })
        .then(data => {
          this.primaryPhonePrefixOpt = data;
        })
        .catch(error => {
          this.displayError(error);
        });
        getPickListValues({
          objApiName: 'Contact',
          fieldName: 'XC_ContactDocumentCountry__c'
        })
        .then(data => {
          this.documentCountryOpt = data;
        })
        .catch(error => {
          this.displayError(error);
        });
        getPickListValues({
          objApiName: 'Contact',
          fieldName: 'XC_MainLegalEntity__c'
        })
        .then(data => {
          this.legalEntityOpt = data;
        })
        .catch(error => {
          this.displayError(error);
        });
        retrieveContactInfo({
          contactToSearchId: cont.keyId
        })
        .then(result => {
          this.firstNameContactValue = result.FirstName;
          this.lastNameContactValue = result.LastName;
          this.emailContactValue = result.Email;
          this.typeOfContactValue = result.XC_TypeOfContact__c;
          this.phonePrefixContactValue = result.XC_PhonePrefix__c;
          this.phoneContactValue = result.XC_ContactPhone__c;
          this.documentCountryContactValue = result.XC_ContactDocumentCountry__c;
          this.prepopulateCountryAndDocumentTypeEditContact(this.documentCountryContactValue);
          this.documentNumberContactValue = result.XC_ContactDocumentNumber__c;
          this.documentTypeContactValue = result.XC_ContactDocumentType__c;
          this.primaryContactValue = result.XC_PrimaryContact__c;
          this.giveDataToContactValue = result.XC_GiveDataToNew__c;
          this.giveDataToThirdPartiesContactValue = result.XC_GiveDataToThirdParties__c; // Yes o no da trasformare in true/false
          this.mainLegalEntityContactValue = result.XC_MainLegalEntity__c;
          this.primaryContactDisabled = true;
          this.giveDataToContactDisabled = true;
          this.giveDataToThirdPartiesContactDisabled = true;
          this.mainLegalEntityContactDisabled = true;
          this.contactToEdit = result;
               
          this.isModalOpenContactEdit = true;
          this.spinnerControlDatatable = false;
            //popolamento del default value
            //disabilitazione dei toggle
        })
        .catch(error => {
          this.displayError(error);
        });

    }

    closeModalContact(){
      this.notLoaded = true;
      this.spinnerControlModal = false;
      this.isModalOpenContact = false;
      this.contactObject = {};
      this.notLoaded = false;
    }

    
    closeModalCreateUser(){
      this.notLoaded = true;
      this.spinnerControlModal = false;
      this.isModalOpenCreateUser = false;
      this.showUsernameBox = false;
      this.notLoaded = false;
    }

    closeModalContactEdit(){
      this.notLoaded = true;
      this.spinnerControlModal = false;
      this.isModalOpenContactEdit = false;
      this.notLoaded = false;
    }

    handleChange (event){
      this.contactObject[event.target.name] = event.target.value;
    }
    handleChangeUser (event){
      this.userObject[event.target.name] = event.target.value;
    }
    handleChangeServiceResourceRole (event){
      this.serviceResourceNameRole[event.target.name] = event.target.value;
    }
    handleChangeToggle (event){
      this.contactObject[event.target.name] = event.target.checked;
    }

    handleChangeCountry (event){
      this.contactObject[event.target.name] = event.target.value;
      let key = this.slaFieldData.controllerValues[event.target.value];
      if (key == undefined){
        this.documentTypeOpt = [];
        this.dependentDisabled = true;
      }
      this.documentTypeOpt = this.slaFieldData.values.filter(opt => opt.validFor.includes(key));
      if(this.documentTypeOpt){
        this.dependentDisabled = false;
      }
    }

    handleChangeGroup(event){
      this.selectedGroup = event.detail.value;
    }

    handleChangeSkill(event){
      var arr = event.detail.value;
      this.selectedSkill[event.target.name] = arr.toString();
    }

    prepopulateCountryAndDocumentTypeEditContact (value){
      this.contactObject[value] = value;
      let key = this.slaFieldData.controllerValues[value];
      if (key == undefined){
        this.documentTypeOpt = [];
        this.dependentDisabled = true;
      }
      this.documentTypeOpt = this.slaFieldData.values.filter(opt => opt.validFor.includes(key));
      if(this.documentTypeOpt){
        this.dependentDisabled = false;
      }
    }

    submitDetailsContact(){
      let blockUpdate = false;
      this.spinnerControlModal = true;
      this.template.querySelectorAll('lightning-input').forEach(element => {
        if(!element.reportValidity()){
          blockUpdate = true;
        }
      });
      this.template.querySelectorAll('lightning-combobox').forEach(element => {
        if(!element.reportValidity()){
          blockUpdate = true;
        }
      });
      if(!blockUpdate){
        let contactToInsert = JSON.stringify(this.contactObject);
        createContactAndPersonalDocument({
          contactToInsert: contactToInsert,
          accountFound: this.accountObject
        })
        .then(wrap => {
          if(!wrap.success){
            this.spinnerControlModal = false;
            this.showErrorToast(wrap.errorMessage);
          }else{          
          loadExistingContact({
            accountFound: this.accountObject
          })
          .then(result => {
            this.listViewData = [];
            this.options = [];
            let userCreated = '';
            let userSubChannel = '';
            let userReceivingChannel = '';
            let usernameUser = '';
            for(let key in result){
              if (result.hasOwnProperty(key)) {
                if(result[key].Users != undefined || result[key].Users != null){
                  userCreated = 'action:approval';
                  userSubChannel = result[key].Users[0].XC_SubChannel__c;
                  userReceivingChannel = result[key].Users[0].XC_Receiving_Channel__c;
                  usernameUser = result[key].Users[0].Username;
                }else{
                  userCreated = 'action:close';
                  userSubChannel = '';
                  userReceivingChannel = '';
                  usernameUser = '';
                }
                this.options.push({keyId : result[key].Id,
                  FirstName : result[key].FirstName,
                  LastName : result[key].LastName,
                  Email : result[key].Email,
                  DocumentNumber : result[key].XC_ContactDocumentNumber__c,
                  TypeOfContact : result[key].XC_TypeOfContact__c,
                  UserCreatedIcon : userCreated,
                  UserUsername : usernameUser,
                  UserReceivingChannel : userReceivingChannel,
                  UserSubChannel : userSubChannel,
                });
              }
            }
            this.listViewData = JSON.parse(JSON.stringify(this.options));
            this.spinnerControlModal = false;
            this.isModalOpenContact = false;
            this.documentTypeOpt = [];
            this.dependentDisabled = true;
            this.contactObject = {};
            this.closeQuickAction();
            this.showToast(this.label.contactCreated);
          });
          }
        })
      }else {
        this.spinnerControlModal = false;
      }
    
    }

    submitDetailsEditContact(){
      let blockUpdate = false;
      let userCreated ;
      this.spinnerControlModal = true;
      this.template.querySelectorAll('lightning-input').forEach(element => {
        if(!element.reportValidity()){
          blockUpdate = true;
        }
      });
      this.template.querySelectorAll('lightning-combobox').forEach(element => {
        if(!element.reportValidity()){
          blockUpdate = true;
        }
      });
      if(!blockUpdate){
        let contactToEdit = JSON.stringify(this.contactObject);
        editContact({
          contactToUpdateId: this.contactToEdit.Id,
          contactToUpdate: contactToEdit
        })
        .then(result => {
          if(!result.success){
            this.spinnerControlModal = false;
            this.showErrorToast(result.errorMessage);
          }else{
            loadExistingContact({
              accountFound: this.accountObject
            })
            .then(result => {
              let userSubChannel = '';
              let userReceivingChannel = '';
              let usernameUser = '';
              this.listViewData = [];
              this.options = [];
              for(let key in result){
                if (result.hasOwnProperty(key)) {
                  if(result[key].Users != undefined || result[key].Users != null){
                    userCreated = 'action:approval';
                    userSubChannel = result[key].Users[0].XC_SubChannel__c;
                    userReceivingChannel = result[key].Users[0].XC_Receiving_Channel__c;
                    usernameUser = result[key].Users[0].Username;
                  }else{
                    userCreated = 'action:close';
                    userSubChannel = '';
                    userReceivingChannel = '';
                    usernameUser = '';
                  }
                  this.options.push({keyId : result[key].Id,
                    FirstName : result[key].FirstName,
                    LastName : result[key].LastName,
                    Email : result[key].Email,
                    DocumentNumber : result[key].XC_ContactDocumentNumber__c,
                    TypeOfContact : result[key].XC_TypeOfContact__c, 
                    UserCreatedIcon : userCreated,
                    UserUsername : usernameUser,
                    UserReceivingChannel : userReceivingChannel,
                    UserSubChannel : userSubChannel,
                  });
                }
              }
              this.listViewData = JSON.parse(JSON.stringify(this.options));
              this.spinnerControlModal = false;
              this.isModalOpenContactEdit = false;
              this.closeQuickAction();
              this.showToast(this.label.contactUpdated);
            })
            .catch(error => {
              this.displayError(error);
            });
          }
        })
        .catch(error => {
          this.displayError(error);
        });
      } else {
        this.spinnerControlModal = false;
      }
    
    }

    showErrorToast(errorMessage) {
      const evt = new ShowToastEvent({
          title: 'Error',
          message: errorMessage,
          variant: 'error',
          mode: 'dismissable'
      });
      this.dispatchEvent(evt);
  }

  showToast(message) {
    const evt = new ShowToastEvent({
        title: 'Success',
        message: message,
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  }

  closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  enableAsPartner(){
    this.notLoaded = true;
    enableAsPartner({
        accountFound: this.accountObject
			})
			.then(result => {
          if(!result.success){
            this.notLoaded = false;
            this.showErrorToast(result.errorMessage);
          }else{
            this.isPartner = result.accountUpdated.IsPartner;           
            this.partnerType = result.accountUpdated.XC_PartnerType__c;
            this.enableAsPartnerButtonDisabled = true;
            this.notLoaded = false;
            this.showToast(this.label.accountUpdated);
          }
			})
			.catch(error => {
				this.displayError(error);
			});
    }

    deleteContact (row){
      this.spinnerControlDatatable = true;
      let cont = JSON.parse(JSON.stringify(row));
      let listViewDataFilter;
      retrieveAndDeleteContact({
        contactToSearchId: cont.keyId
			})
			.then(result => {
        if(!result.success){
          this.spinnerControlModal = false;
          this.spinnerControlDatatable = false;
          this.showErrorToast(result.errorMessage);
        }else{
          listViewDataFilter = this.listViewData.filter(row => row.keyId !== cont.keyId);
          this.listViewData = listViewDataFilter;
          this.spinnerControlDatatable = false;
          this.showToast(this.label.contactDeleted);
        }
			})
			.catch(error => {
				this.displayError(error);
			});
      /*this.firstNameContact
      this.lastNameContact
      this.emailContact
      this.typeOfContact
      this.primaryPhonePrefixContact
      this.primaryPhoneContact
      this.documentCountryContact
      this.documentNumberContact
      this.documentTypeContact
        this.isModalOpenContact = true;*/
    }

    openModalcreateUser(row){
      this.spinnerControlDatatable = true;  
      let cont = JSON.parse(JSON.stringify(row)); 
      this.contactSelected = cont; 
      checkIfUserNeedToBeCreated ({
        contactId : this.contactSelected.keyId
      }).then(data =>{
        if(data.success){
          getPickListValues({
            objApiName: 'User',
            fieldName: 'XC_Receiving_Channel__c'
          })
          .then(data => {
            this.receivingChannelUserOpt = data;
          })
          .catch(error => {
            this.displayError(error);
          });
          getPickListValuesRole({
          })
          .then(data => {
            this.roleUserOpt = data;
            this.isModalOpenCreateUser = true;
            this.spinnerControlDatatable = false;
          })
          .catch(error => {
            this.displayError(error);
          });
        }else{
          this.showErrorToast(data.errorMessage);
          this.spinnerControlDatatable = false;  
        }
      });
    }

    submitDetailsUser(){
      let blockUpdate = false;
      this.spinnerControlModal = true;
      this.template.querySelectorAll('lightning-combobox').forEach(element => {
        if(!element.reportValidity()){
          blockUpdate = true;
        }
      });
      let contactKeyId = this.contactSelected.keyId;
      if(!blockUpdate){
        let userToInsert = JSON.stringify(this.userObject);
        createUser({
          userToInsert: userToInsert,
          contactIdForUser: this.contactSelected.keyId
        })
        .then(result => {
          if(!result.success){
            this.spinnerControlModal = false;
            this.showErrorToast(result.errorMessage);
            if(result.showUsernameBox){
              this.showUsernameBox = true; 
            }
          }else{
            loadExistingContact({
              accountFound: this.accountObject
            })
            .then(result => {
              let userCreated = '';
              let userSubChannel = '';
              let userReceivingChannel = '';
              let usernameUser = '';
              this.listViewData = [];
              this.options = [];
              for(let key in result){
                if (result.hasOwnProperty(key)) {
                  if(result[key].Users != undefined || result[key].Users != null){
                    userCreated = 'action:approval';
                    userSubChannel = result[key].Users[0].XC_SubChannel__c;
                    userReceivingChannel = result[key].Users[0].XC_Receiving_Channel__c;
                    usernameUser = result[key].Users[0].Username;
                  }else{
                    userCreated = 'action:close';
                    userSubChannel = '';
                    userReceivingChannel = '';
                    usernameUser = '';
                  }
                  this.options.push({keyId : result[key].Id,
                    FirstName : result[key].FirstName,
                    LastName : result[key].LastName,
                    Email : result[key].Email,
                    DocumentNumber : result[key].XC_ContactDocumentNumber__c,
                    TypeOfContact : result[key].XC_TypeOfContact__c,
                    UserCreatedIcon : userCreated,
                    UserUsername : usernameUser,
                    UserReceivingChannel : userReceivingChannel,
                    UserSubChannel : userSubChannel,
                  });
                }
              }
              this.listViewData = JSON.parse(JSON.stringify(this.options));
            this.listViewData = JSON.parse(JSON.stringify(this.options));
            this.spinnerControlModal = false;
            this.isModalOpenCreateUser = false;
            this.showUsernameBox = false;
            this.closeQuickAction();
            this.showToast(this.this.label.userCreation);
          })
        }
        })
        .catch(error => {
          this.displayError(error);
        });
      }else {
        this.spinnerControlModal = false;
      }
    
    }

    executeNextStep(){
      openNextStep({
        accountFound: this.accountObject
      })
      .then(result => {
        if(!result.success){
          this.showErrorToast(result.errorMessage);
        }else{
          this.template.querySelector('[data-id="contactSection"]').className ='noPointClick';
          this.isRenderedFLSCard = true;
          this.disabledNextStep = true;
            createServiceTerritory({
              accountFound: this.accountObject
            })
            .then(result => {
              this.bottomFunction();
              if(!result.success){
                this.showErrorMessageOnPath(result.errorMessage);
              }else{
                this.handleNext();
              }
            })   
        }
    })
    }

    handleNext() {
      var getselectedStep = this.selectedStep;
      getselectedStep = getselectedStep + 1;
      this.selectedStep = getselectedStep;
      this.pathHandler(getselectedStep.toString());
      
  }

 
    

  pathHandler(index){
      /*let targetId = event.currentTarget.id;
      let len = targetId.length;
      let mainTarId = targetId.charAt(4);
      let targatPrefix = targetId.substring(5, len);
      var selectedPathTest = this.template.querySelector("[data-id=" +"testPath1"+ "]");*/
      var selectedPath = this.template.querySelector("[data-id=pat-" +index+ "]");
      if(selectedPath){
          this.template.querySelector("[data-id=pat-" +index+ "]").className='slds-is-active slds-path__item';
      }
          for(let i = 0; i < index; i++){
              let selectedPath = this.template.querySelector("[data-id=pat-"+i+"]");
              if(selectedPath){
                  this.template.querySelector("[data-id=pat-"+i+"]").className='slds-is-complete slds-path__item';
              }
          }
          for(let i = index; i < 7; i++){
              if(i != index){
                  let selectedPath = this.template.querySelector("[data-id=pat-"+i+"]");
                  if(selectedPath){
                      this.template.querySelector("[data-id=pat-" +i+"]").className='slds-is-incomplete slds-path__item';
                  }
              }
          }
          if(index < 7){
            this.handleNextStep (index);
          }else{
            this.showSuccessState();
          }
        
  }

  showSuccessState(){
    this.showSuccess = true;
  }

  handleNextStep(index){
    switch (index) {
      case '2':
        this.createServiceResource();
        break;
      case '3':
        this.createServiceTerritoryMember();
        break;
      case '4':
        this.addToGroupMember();
        break;
      case '5':
        this.createServiceResourceShare();
        break;
      case '6':
        this.createSkill();
        break;
      default:
  }
  }

  showErrorMessageOnPath(errorMessage){
    this.showErrorMessageOnPathBool = true;
    this.errorMessage = errorMessage;
  }

  createServiceResource(){
    findServiceResourceToInsert({
      accountFound: this.accountObject
    })
    .then(result => {
      getPickListValuesRole({
      })
      .then(data => {
        let isEmptyObj = true;
        for(var key in result){
          isEmptyObj = false;
        }
        if(isEmptyObj){
          this.handleNext();
        }else{
          this.roleUserOpt = data;
          this.listOfServiceResourceName = result;
          this.activeSections = result;
          this.isModalOpenServiceResource = true;
        }
      })
    })
  }

  serviceResourceDetailSubmit (){
    let blockUpdate = false;
    this.spinnerControlModal = true;
    this.template.querySelectorAll('lightning-combobox').forEach(element => {
      if(!element.reportValidity()){
        blockUpdate = true;
      }
    });
    if(!blockUpdate){
      //let serviceResourceNameWithRole = JSON.parse(this.serviceResourceNameRole);
      let mapServiceResourceNameWithRole = [];
      for(var key in this.serviceResourceNameRole){
        let value = this.serviceResourceNameRole[key];
        mapServiceResourceNameWithRole.push({key,value})
      }
      this.isModalOpenServiceResource = false;
      createServiceResourceToInsert({
        accountFound: this.accountObject,
        listOfServiceResourceName : this.listOfServiceResourceName,
        mapServiceResourceRole : JSON.stringify(mapServiceResourceNameWithRole)
      })
      .then(result => {
        if(!result.success){
          this.showErrorMessageOnPath(result.errorMessage);
        }else {
          this.listOfServiceResource = result.listOfServiceResource;
          this.handleNext();
        }
      this.spinnerControlModal = false;
      });
      
    } else {
      this.spinnerControlModal = false;
    }
     
  }

  createServiceTerritoryMember(){
    createServiceTerritoryMemberToInsert({
      accountFound: this.accountObject
    })
    .then(result => {
      if(!result.success){
        this.showErrorMessageOnPath(result.errorMessage);
      }else {
        this.handleNext();
      }
    });
  }
  addToGroupMember(){
    loadGroupOfPartner ({
      accountFound: this.accountObject
    }).then(result => {
      let isEmptyObj = true;
      for(var key in result.toAddGroups){
        isEmptyObj = false;
        this.optionsGroup.push({ label : result.toAddGroups[key], value : result.toAddGroups[key]});
      }
      this.selectedGroup = [...result.addedGroups];
      this.requiredGroup = [...result.addedGroups];
      if(!isEmptyObj){
        //this.optionsGroup = result;
        this.isModalGroupMemberOpen = true;
      }else {
        this.handleNext();
      } 
    });
 
  }

  addToGroupMemberInsert(){
    this.isModalGroupMemberOpen = false;
    insertUserToGroupMember({
      accountFound: this.accountObject,
      selectedGroup:  this.selectedGroup
    })
    .then(result => {
      if(!result.success){
        this.showErrorMessageOnPath(result.errorMessage);
      }else {
        this.handleNext();
      }
    });
  }

  createServiceResourceShare(){
    checkAndCreateServiceResourceShare({
      accountFound: this.accountObject
    })
    .then(result => {
      if(!result.success){
        this.showErrorMessageOnPath(result.errorMessage);
      }else {
        this.handleNext();
      }
    });
  }

  createSkill(){
    loadValueAndServiceResourceForSkillManagement({
      accountFound: this.accountObject
    })
    .then(result => {
      if(!result.success){
        this.showErrorMessageOnPath(result.errorMessage);
      }else {
        deleteUserFromFieldServiceDefault({
          accountFound: this.accountObject
        })
        .then(result =>{
          if(!result.success){
            this.showErrorMessageOnPath(result.errorMessage);
          }
        });
        if(result.skipStep){
          this.handleNext();
        }else{
          for(var key in result.allSkill){
            this.skillNameList.push({ label : result.allSkill[key], value : result.allSkill[key]})
          }
          for(var key in result.mapServiceResourceToSkills){
            let sr  = JSON.parse(key);
            this.serviceResourceListSkill.push({ serviceResource : sr, selectedSkills : result.mapServiceResourceToSkills[key], requiredSkills : result.mapServiceResourceToSkills[key]});
          }
          this.showModalSkill = true;
          this.activeSections = result.listOfServiceResource;
        }
      }
    });
  }

  serviceResourceDetailSkillSubmit (){
      let mapServiceResourceNameWithSkill = [];
      for(var key in this.selectedSkill){
        let value = this.selectedSkill[key];
        mapServiceResourceNameWithSkill.push({key,value})
      }
      this.showModalSkill = false;
      createServiceResourceSkill({
        accountFound: this.accountObject,
        mapServiceResourceSkill : JSON.stringify(mapServiceResourceNameWithSkill)
      })
      .then(result => {
        if(!result.success){
          this.showErrorMessageOnPath(result.errorMessage);
        }else {
          this.handleNext();
        }
      });
  }

  navigateToTabPageFLSSharing() {
    // Navigate to a specific CustomTab.
    this[NavigationMixin.Navigate]({
        type: 'standard__navItemPage',
        attributes: {
            // CustomTabs from managed packages are identified by their
            // namespace prefix followed by two underscores followed by the
            // developer name. E.g. 'namespace__TabName'
            apiName: 'FSL__Master_Settings'
        }
    });
}

navigateToTabPageMassiveWorktype() {
  // Navigate to a specific CustomTab.
  this[NavigationMixin.Navigate]({
      type: 'standard__navItemPage',
      attributes: {
          // CustomTabs from managed packages are identified by their
          // namespace prefix followed by two underscores followed by the
          // developer name. E.g. 'namespace__TabName'
          apiName: 'XC_MassiveAssignmentWorkType'
      }
  });
}

  bottomFunction(){
    window.scrollTo(0,400);
  }
  skipStep(){
    this.showModalSkill = false;
    this.isModalGroupMemberOpen = false;
    this.handleNext();
  }
}