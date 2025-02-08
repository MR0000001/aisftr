/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 12-21-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   12-11-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public  without sharing class XC_AMP_LCC002_OrderMainViewBuilder {

    /** @description ViewSection Wrapper */
    public class ViewDefinition{
        public Boolean success = true;
        public String resultMessage;
        public Set<String> sectionsOrder;
        public Set<String> sectionsExtraOrder;
        public Map<String,ViewSection> sections;
        public Map<String,ViewSection> extraSections;
        public Set<String> sectionsEditabledBeforeOrder;
        
        //public String accountRecordTypeName;
        public String partnerAMP;
        public String userCountry;
        public String defaultPhonePrefix;
        public String defaultPrefLanguage;
        public String defaultNationality;

        public Boolean viewFileUpload = false;
        public Boolean fileUploadRequired = false;
        public String categoryForFile;
        public String categoriesForExtraSection;
        
        //Account existingRecord = new Account();

        public String defaultCategoryOfInterest;
        public Boolean isFullFlow;
        public String defaultCatalogCategories;
        public String segment;
    }

    /** @description ViewSection Wrapper */
    public class ViewSection{
        public String sectionName;
        public String componetName;
        public String objectType;
        public String recordTypeId;
        public String recordId;
        public List<XC_UTIL_FieldSet.FieldWrapper> fields;
    }

    /** @description InformationUser Wrapper */
    public class InformationUser{
        public String consetInformation;
        public String legalEntityUser = '';
    }

    public class SectionFieldsWrapper{
        @AuraEnabled
        public String recordTypeId {get;set;}
        @AuraEnabled
        public String sObjectName {get;set;}
        @AuraEnabled
        public String sectionName {get;set;}
        @AuraEnabled
        public Boolean isSectionValid {get;set;}
        @AuraEnabled
        public Map<String,Object> fields {get;set;}
    }


    public class InsertResultWrapper{
        @AuraEnabled
        public String accountId {get;set;}
        @AuraEnabled
        public String opportunityId {get;set;}
        @AuraEnabled
        public String errorMessage {get;set;}
        @AuraEnabled
        public Boolean success {get;set;}
    }

    public static Boolean fullFlow;


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-11-2020 
    * @param accountRecordTypeId 
    * @param parentOpportunityId 
    * @return String 
    **/
    @AuraEnabled
    public static String initNewCreationConfig(String accountRecordTypeId, String parentOpportunityId){
        ViewDefinition viewDefResult = new ViewDefinition();
        XC_AMP_UTIL_ViewConfiguration.ViewDefinitionInputData inputData = new XC_AMP_UTIL_ViewConfiguration.ViewDefinitionInputData();
        Map<String,String> opportunityRecordInfos = new Map<String,String>();
        if(String.isNotBlank(parentOpportunityId)){
            opportunityRecordInfos = getInitInfoFromOpportunity(parentOpportunityId);
        }

        //retrieving starting rt
        if(String.isNotBlank(accountRecordTypeId)){
            inputData.recordTypeName = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(accountRecordTypeId).getDeveloperName();
        }else if(opportunityRecordInfos.containsKey('RT_Account')){
            accountRecordTypeId = opportunityRecordInfos.get('RT_Account');
            inputData.recordTypeName = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(opportunityRecordInfos.get('RT_Account')).getDeveloperName();
        }
        
        //retrieving user info
        Id accountRecordTypeIdObj = accountRecordTypeId;
        populateInfoFromUser(viewDefResult, accountRecordTypeIdObj);
        opportunityRecordInfos.put('partnerAMP',viewDefResult.partnerAMP);

        //getting configurations
        List<XC_CM_OrderPortalSales_ViewDefinition__mdt> dataView = XC_AMP_UTIL_ViewConfiguration.retrieveNetworkViewDefinition(inputData);
        if(dataView.isEmpty()){
            viewDefResult.success = false;
            return JSON.serialize(viewDefResult);
        }
       
        inputData.viewDefMtd = dataView[0];
        List<XC_CM_OrderPortalSales_ComponentDef__mdt> compView = XC_AMP_UTIL_ViewConfiguration.retrieveComponentDefinition(inputData);
        if(compView.isEmpty()){
            viewDefResult.success = false;
            return JSON.serialize(viewDefResult);
        }
        checkForComponentViewFilter(compView, opportunityRecordInfos);

        viewDefResult.segment = dataView[0].XC_Stream__c;
        
        //mapping configurations for fileupload
        viewDefResult.fileUploadRequired = String.isNotEmpty(dataView[0].XC_InsertDocument__c) && dataView[0].XC_InsertDocument__c.equalsIgnoreCase('Required');
        viewDefResult.viewFileUpload = String.isNotEmpty(dataView[0].XC_InsertDocument__c) && (dataView[0].XC_InsertDocument__c.equalsIgnoreCase('Required') || dataView[0].XC_InsertDocument__c.equalsIgnoreCase('Possible'));
        viewDefResult.categoryForFile = String.isNotEmpty(dataView[0].XC_CategoriesMandatoryDocumentation__c) ? dataView[0].XC_CategoriesMandatoryDocumentation__c : '';
        viewDefResult.defaultCatalogCategories = dataView[0].XC_AMP_AvailableCatalogCategories__c;
        
        //remapping configurations in component wrapper
        viewDefResult.sectionsOrder = new Set<String>(dataView[0].XC_AvailableSections__c.split(','));
        viewDefResult.sections = new Map<String,ViewSection>();
        ViewSection section;
        for(XC_CM_OrderPortalSales_ComponentDef__mdt cmpData : compView){
            section = new ViewSection();
            section.sectionName = cmpData.XC_SectionName__c;
            section.objectType = cmpData.XC_ReferenceSObject__c;

            if(String.isNotBlank(parentOpportunityId) && !opportunityRecordInfos.isEmpty() && opportunityRecordInfos.containsKey(section.objectType)){
                section.recordId = opportunityRecordInfos.get(section.objectType);
            }

            if(String.isNotBlank(cmpData.XC_RTDevName__c)){
                section.recordTypeId = Schema.getGlobalDescribe().get(cmpData.XC_ReferenceSObject__c).getDescribe().getRecordTypeInfosByDeveloperName().get(cmpData.XC_RTDevName__c).getRecordTypeId();
            }

            if(String.isNotBlank(cmpData.XC_FieldSetName__c) && String.isNotBlank(cmpData.XC_ReferenceSObject__c)){
                section.fields = XC_UTIL_FieldSet.getFieldSetFields (cmpData.XC_FieldSetName__c, cmpData.XC_ReferenceSObject__c);
                for(XC_UTIL_FieldSet.FieldWrapper fw : section.fields){
                    if(fw.fieldName == 'XC_AMP_Partner__c'){
                        fw.isReadonly = true;
                    }
                }
            }

            section.componetName = cmpData.XC_ComponentName__c;
            viewDefResult.sections.put(cmpData.XC_SectionName__c,section);
        }
        
        //Extra Section Management
        String extraSectVal = dataView[0].XC_ExtraSections__c;
        if(String.isNotBlank(extraSectVal)){
            Map<String, Object> extraSectDef = (Map<String, Object>)JSON.deserializeUntyped(extraSectVal);
            if(extraSectDef.get(viewDefResult.partnerAMP) != null){
                List<Object> extraSectNamesObj = (List<Object>) extraSectDef.get(viewDefResult.partnerAMP);
                //viewDefResult.extraSections
                if(extraSectNamesObj != null && !extraSectNamesObj.isEmpty()){
                    List<String> extraSectNames = new List<String>();
                    for(Object name : extraSectNamesObj){
                        extraSectNames.add(String.valueOf(name));
                    }
                    viewDefResult.categoriesForExtraSection = dataView[0].XC_CategoriesExtraSections__c;
                    viewDefResult.sectionsExtraOrder = new Set<String>(extraSectNames);

                    List<XC_CM_OrderPortalSales_ComponentDef__mdt> extraCompView = XC_AMP_UTIL_ViewConfiguration.getComponentDefinitionForSectionNames(inputData, extraSectNames);
                    viewDefResult.extraSections = new Map<String,ViewSection>();
                    ViewSection sectionExt;
                    for(XC_CM_OrderPortalSales_ComponentDef__mdt cmpData : extraCompView){
                        sectionExt = new ViewSection();
                        sectionExt.sectionName = cmpData.XC_SectionName__c;
                        sectionExt.objectType = cmpData.XC_ReferenceSObject__c;
                        if(String.isNotBlank(cmpData.XC_RTDevName__c)){
                            sectionExt.recordTypeId = Schema.getGlobalDescribe().get(cmpData.XC_ReferenceSObject__c).getDescribe().getRecordTypeInfosByDeveloperName().get(cmpData.XC_RTDevName__c).getRecordTypeId();
                        }
                        if(String.isNotBlank(cmpData.XC_FieldSetName__c) && String.isNotBlank(cmpData.XC_ReferenceSObject__c)){
                            sectionExt.fields = XC_UTIL_FieldSet.getFieldSetFields (cmpData.XC_FieldSetName__c, cmpData.XC_ReferenceSObject__c);
                            for(XC_UTIL_FieldSet.FieldWrapper fw : sectionExt.fields){
                                if(fw.fieldName == 'XC_AMP_OrderCSPSMarket__c'){
                                    fw.isReadonly = true;
                                }
                            }
                        }
                        sectionExt.componetName = cmpData.XC_ComponentName__c;
                        viewDefResult.extraSections.put(sectionExt.sectionName,sectionExt);
                    }
                }
            }
        }
        String editableSections = dataView[0].XC_EditableSectionsBeforeOrderCreation__c;
        if(String.isNotBlank(editableSections)){
            viewDefResult.sectionsEditabledBeforeOrder = new Set<String>(editableSections.split(','));
        }

        // ET - 22/03/2021
        String defaultCategory = dataView[0].XC_DefaultCategoryOfInterest__c;
        if(String.isNotBlank(defaultCategory)){
            viewDefResult.defaultCategoryOfInterest = defaultCategory;
        }
        viewDefResult.isFullFlow = dataView[0].XC_IsFullFlow__c;
        // ET - 24/03/2021

        return JSON.serialize(viewDefResult);
    }


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-11-2020 
    * @param viewDefResult 
    * @param accountRecordTypeId 
    **/
    private static void populateInfoFromUser(ViewDefinition viewDefResult, Id accountRecordTypeId){
        Map<String,Object> userInfo = XC_UTIL_User.getInfoFromPortalUser(UserInfo.getUserId());
        String legalEntity = String.valueOf(userInfo.get('XC_LegalEntity__c')); //XC_UTIL_User.getLegalEntityFromUser();
        String country = String.valueOf(userInfo.get('Country__c')); //XC_UTIL_User.getCountryFromUser(UserInfo.getUserId());
        //XC_CM_CountryLegalEntityAssociation__mdt cmLegalEntityConfig = XC_AMP_UTIL_ViewConfiguration.getLegalEntityInfo(legalEntity).get(legalEntity);
        XC_CM_CountryLegalEntityAssociation__mdt userLE = XC_UTIL_User.getLegalEntityMetadataFromUserByRT(XC_UTIL_Sobject.retrieveRecordTypNameFromId(accountRecordTypeId));
        
        viewDefResult.userCountry = /*country;//countryFinal.capitalize();*/  (userLE!=null && String.isNotBlank(userLE.XC_Country__c)) ? userLE.XC_Country__c : '';
        viewDefResult.defaultPhonePrefix= (userLE!=null && String.isNotBlank(userLE.XC_PhonePrefix__c)) ? userLE.XC_PhonePrefix__c : '';
        viewDefResult.defaultNationality = (userLE!=null && String.isNotBlank(userLE.XC_Nationality__c)) ? userLE.XC_Nationality__c : '';
        Schema.DescribeFieldResult describeContactLang = Contact.XC_Preferredlanguageofcontact__c.getDescribe();
        List<Schema.PicklistEntry> pickValsLangContact = describeContactLang.getPicklistValues();
        for(Schema.PicklistEntry pv: pickValsLangContact) {
            if(pv.isDefaultValue()) {
                viewDefResult.defaultPrefLanguage = pv.getValue();
                break;
            }
        }
        viewDefResult.defaultPrefLanguage = (userLE!=null && String.isNotBlank(userLE.XC_Preferredlanguageofcontact__c)) ? userLE.XC_Preferredlanguageofcontact__c : viewDefResult.defaultPrefLanguage;
        viewDefResult.partnerAMP = String.valueOf(userInfo.get('XC_AMP_Partner__c'));
    }



    /**
    * @description submit exposed sections in order to create related records
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-11-2020 
    * @param validSections 
    * @param paramsInput 
    * @return XC_LCC003_NewAccount_W.InsertResultWrapper 
    **/
    @AuraEnabled
    //public static InsertResultWrapper submitFirstStepSections(String partnerAMP, Boolean isFullFlow){
    public static InsertResultWrapper submitFirstStepSections(List<SectionFieldsWrapper> validSections, Map<String,Object> paramsInput){
        String partnerAMP = String.valueOf(paramsInput.get('partnerAMP'));
        Boolean isFullFlow = Boolean.valueOf(paramsInput.get('isFullFlow'));
        String segment = String.valueOf(paramsInput.get('segment'));

        InsertResultWrapper result = new InsertResultWrapper();
        Map<String,Object> sectionExtraInfos = new Map<String,Object>();
        
        System.Debug('VALID SECTIONS RECEIVED ' + JSON.Serialize(validSections));
        Savepoint sp = Database.setSavePoint();


        //Remapping sections by objectname
        Map<String,Map<String,Object>> sectionObjectFieldsMap = new Map<String,Map<String,Object>>();

        for(SectionFieldsWrapper section : validSections){
            if(sectionObjectFieldsMap.containsKey(section.sObjectName)){
                for(String fieldName : section.fields.keySet()){
                    if(section.fields.get(fieldName)!= null){
                        sectionObjectFieldsMap.get(section.sObjectName).put(fieldName,section.fields.get(fieldName));
                    }
                }
            }else{
                Map<String,Object> tmpMap = section.fields;
                tmpMap.put('recordTypeId',section.recordTypeId);
                sectionObjectFieldsMap.put(section.sObjectName,tmpMap);
            }
        }


        //Create Account
        //TODO: Add check on duplicates in order to re-use duplicate account

        Map<String,Object> normalizedInput = normalizeCreateAccountInput(sectionObjectFieldsMap,segment);
        XC_LCC003_NewAccount_W.InsertResultWrapper accountResultWr;
        if (!Test.isRunningTest()){
        	accountResultWr = XC_LCC003_NewAccount.createRecord(JSON.serialize(normalizedInput));
            result.success = accountResultWr.success;
            result.accountId = accountResultWr.recordId;
            result.errorMessage = accountResultWr.errorMessage;
        } else {
            Id accId = XC_AMP_LCC002_OrderMainView_TEST.createTestAccount();
            accountResultWr = new XC_LCC003_NewAccount_W.InsertResultWrapper(accId);
        }

        //System.Debug('ACCOUNT INSERTION RESULT::: ' + JSON.serialize(accountResultWr));

        Map<String,Object> duplicateResult = new Map<String,Object>();
        if(String.isNotBlank(accountResultWr.existingAccId)){
            //MANAGE DUPLICATION CASE
            Map<String,Object> paramsMap = new Map<String,Object>();
            paramsMap.put('sections',sectionObjectFieldsMap);
            paramsMap.put('normalizedInputAccount',normalizedInput);
            paramsMap.put('existingAccountId',accountResultWr.existingAccId);
            duplicateResult = manageDuplicationCases(paramsMap);

            if(Boolean.valueOf(duplicateResult.get('success'))){
                accountResultWr.success = true;
                accountResultWr.recordId = accountResultWr.existingAccId;
                result.success = true;
                result.accountId = accountResultWr.existingAccId;
            }else{
                result.success = false;
                result.accountId = accountResultWr.existingAccId;
                result.errorMessage = String.valueOf(duplicateResult.get('errorMsg'));
            }
        }

        //Create Vehicle
        if(accountResultWr.success && String.isNotBlank(accountResultWr.recordId) && sectionObjectFieldsMap.containsKey('XC_AMP_Vehicle__c')){
            XC_UTIL_Sobject.WrapperResult vehicleResultWr = createAccountVehicleFromSection(accountResultWr.recordId,sectionObjectFieldsMap.get('XC_AMP_Vehicle__c'),partnerAMP);
            sectionExtraInfos.put('vehicleId',vehicleResultWr.recordId);
            sectionExtraInfos.put('internalChannel',(sectionObjectFieldsMap.get('XC_AMP_Vehicle__c')).get('XC_AMP_InternalChannel__c'));
            if(!vehicleResultWr.success){
                Database.rollback(sp);
                result.success = false;
                result.accountId = null;
                result.errorMessage = vehicleResultWr.errorMessage;
                return result;
            }
        }

        //Create Opportunity
        if(accountResultWr.success && String.isNotBlank(accountResultWr.recordId)){
            fullFlow = isFullFlow;
            if(sectionObjectFieldsMap.get('Opportunity') != null) { //ET
                for(String fieldName : sectionObjectFieldsMap.get('Opportunity').keySet()) {
                    sectionExtraInfos.put(fieldName, sectionObjectFieldsMap.get('Opportunity').get(fieldName));
                }
            }
            System.debug('SectionExtraInfos before opportunity creation: ' + sectionExtraInfos);
            // in case of duplicate on address, the original address is used, otherwise the last created one
            String addressId = duplicateResult.containsKey('foundAddress') ? String.valueOf(duplicateResult.get('foundAddress')) : null;
            String legalEntityUser = (normalizedInput.containsKey('legalEntityUser') && String.isNotBlank((String) normalizedInput.get('legalEntityUser'))) ? (String) normalizedInput.get('legalEntityUser') : '';
            XC_UTIL_Sobject.WrapperResult opportunityResultWr = createOpportunity(accountResultWr.recordId, addressId, sectionExtraInfos, legalEntityUser);
            if(!opportunityResultWr.success){
                Database.rollback(sp);
                result.success = false;
                result.accountId = null;
                result.errorMessage = opportunityResultWr.errorMessage;
                return result;
            }else{
                result.opportunityId = opportunityResultWr.recordId;
            }
        }

        return result;
    }

    /**
    * @description autmotive portal specific logic to create child opportunity
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-18-2020 
    * @param paramsMap 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> createChildOpportunity(Map<String,Object> paramsMap){

        Map<String,Object> result = new Map<String,Object>();
        String accountId = String.valueOf(paramsMap.get('accountId'));
        String parentOpportunityId = String.valueOf(paramsMap.get('parentOpportunityId'));
        Opportunity parentOpportunity = (Opportunity) XC_UTIL_Sobject.selectAllFields(parentOpportunityId)[0];

        Map<String,Object> extraInfos = new Map<String,Object>();
        extraInfos.put('vehicleId',parentOpportunity.XC_AMP_Vehicle__c);
        extraInfos.put('internalChannel',parentOpportunity.XC_AMP_InternalChannel__c);
        extraInfos.put('parentOpportunityId',parentOpportunity.Id);
        XC_UTIL_Sobject.WrapperResult opportunityWr = createOpportunity(accountId, parentOpportunity.XC_Address__c, extraInfos, parentOpportunity.XC_LegalEntity__c);


        result.put('success',opportunityWr.success);
        result.put('errorMsg',opportunityWr.errorMessage);
        if(opportunityWr.success){
            result.put('opportunityId',opportunityWr.recordId);
            parentOpportunity.XC_AMP_ChildOpportunity__c = opportunityWr.recordId;
            XC_UTIL_Sobject.updateRecord(parentOpportunity);
        }
        return result;
    }


    /**
    * @description 
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-11-2020 
    * @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com | 22/03/2021
    * @param sectionObjectFieldsMap 
    * @param segment 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> normalizeCreateAccountInput(Map<String,Map<String,Object>> sectionObjectFieldsMap, String segment){

        InformationUser iuWrapper = getDefaultConsentForUserLE();
        Map<String,Object> normalizedInput = new Map<String,Object>();
        normalizedInput.put('confirmationByTheCustomer', true);
        normalizedInput.put('isCommunity', true);
        normalizedInput.put('assignRecord', false);
        normalizedInput.put('thirdPartiesCheck', false);
        normalizedInput.put('thirdPartiesVersion', false);
        normalizedInput.put('consentsLE', iuWrapper.consetInformation);
        normalizedInput.put('brandString', '');
        normalizedInput.put('releaseDate', String.valueOf(Date.today()));
        normalizedInput.put('legalEntityUser', iuWrapper.legalEntityUser);
        
        //'withoutValidate': component.get('v.withoutValidate') > check Address not validated


        System.Debug('SECTION OBJECT FIELDS MAP ' + JSON.Serialize(sectionObjectFieldsMap));
        
        for(String objectName : sectionObjectFieldsMap.keySet()){
            if('Account' == objectName){

                Map<String,Object> accountFields = sectionObjectFieldsMap.get(objectName);
                
                Account emptyReferenceAccount = new Account();
                emptyReferenceAccount.put('RecordTypeId',accountFields.get('recordTypeId'));

                normalizedInput.put('fieldMapStringAccount', JSON.serialize(accountFields));
                normalizedInput.put('recordTypeId', String.valueOf(accountFields.get('recordTypeId')));

                //setting up contact fields
				System.debug('FirstName: '+ String.valueOf(accountFields.get('XC_FirstName__c')) );
                if(!normalizedInput.containsKey('contactFields')){
                    Map<String,Object> contactFieldsMap = new Map<String,Object>();
                    contactFieldsMap.put('FirstName',String.valueOf(accountFields.get('XC_FirstName__c')));
                    contactFieldsMap.put('LastName',String.valueOf(accountFields.get('XC_LastName__c')));
                    contactFieldsMap.put('DocumentCountry',String.valueOf(accountFields.get('XC_DocumentCountry__c')));
                    contactFieldsMap.put('DocumentType',String.valueOf(accountFields.get('IdentityType__c')));
                    contactFieldsMap.put('DocumentID',String.valueOf(accountFields.get('IdentityNumber__c')));
                    contactFieldsMap.put('ExpirationDate',null); //TODO: check null values
                    contactFieldsMap.put('ReleaseDate',null);
                    contactFieldsMap.put('Email',String.valueOf(accountFields.get('PrimaryEmail__c')));
                    contactFieldsMap.put('ContactMobile',String.valueOf(accountFields.get('XC_AccountPhone__c')));
                    contactFieldsMap.put('ContactPhone',String.valueOf(accountFields.get('XC_AccountPhone__c')));
                    contactFieldsMap.put('PhonePrefix',String.valueOf(accountFields.get('XC_AccountPhonePrefix__c')));
                    contactFieldsMap.put('MobilePrefix',String.valueOf(accountFields.get('XC_AccountPhonePrefix__c')));

                    Map<String,XC_CM_CountryLegalEntityAssociation__mdt> mtd = XC_AMP_UTIL_ViewConfiguration.getCountryLegalEntityInfo(iuWrapper.legalEntityUser, segment);
                    String prefLang = (mtd.get(iuWrapper.legalEntityUser+segment)).XC_Preferredlanguageofcontact__c;
                    contactFieldsMap.put('PreferredLanguage',prefLang);
                    
                    normalizedInput.put('contactFields',JSON.serialize(contactFieldsMap));
                }

                //setting up consents , only give data to is setted to the legalentity TODO: remove this if consents component is going to be used
                if(Boolean.valueOf(accountFields.get('XC_ConfirmationByCustomer__c'))){

                    //check this TODO: pass eventually recordID if existing record
                    String JSONconsentsList =XC_LCC163_CreateConsents.getLegalEntities(null,objectName,JSON.serialize(emptyReferenceAccount));

                    System.Debug('CONSENTS CREATED ' + JSONconsentsList);
                    normalizedInput.put('consentsWrapper',JSONconsentsList);

                }

            }else if('Contact' == objectName){
                
                Map<String,Object> contactFields = sectionObjectFieldsMap.get(objectName);
                Map<String,Object> contactObjectFieldsMap = new Map<String,Object>();

                contactObjectFieldsMap.put('FirstName',String.valueOf(contactFields.get('FirstName')));
                contactObjectFieldsMap.put('LastName',String.valueOf(contactFields.get('LastName')));
                contactObjectFieldsMap.put('DocumentCountry',String.valueOf(contactFields.get('XC_ContactDocumentCountry__c')));
                contactObjectFieldsMap.put('DocumentType',String.valueOf(contactFields.get('XC_ContactDocumentType__c')));
                contactObjectFieldsMap.put('DocumentID',String.valueOf(contactFields.get('XC_ContactDocumentNumber__c')));
                contactObjectFieldsMap.put('ExpirationDate',null); //TODO: check null values
                contactObjectFieldsMap.put('ReleaseDate',null);
                contactObjectFieldsMap.put('Email',String.valueOf(contactFields.get('Email')));
                contactObjectFieldsMap.put('Sex',String.valueOf(contactFields.get('XC_Sex__c')));
                contactObjectFieldsMap.put('MobilePrefix',String.valueOf(contactFields.get('XC_MobilePrefix__c')));
                contactObjectFieldsMap.put('Mobile',String.valueOf(contactFields.get('XC_ContactMobile__c')));
                contactObjectFieldsMap.put('Citizenship',String.valueOf(contactFields.get('XC_Citizenship__c')));
                contactObjectFieldsMap.put('BirthPlace',String.valueOf(contactFields.get('XC_Birth_Place__c')));
                contactObjectFieldsMap.put('BirthProvince',String.valueOf(contactFields.get('XC_Birth_Province__c')));
                contactObjectFieldsMap.put('BirthCountry',String.valueOf(contactFields.get('XC_Birth_Country__c')));
                contactObjectFieldsMap.put('Birthdate',String.valueOf(contactFields.get('Birthdate')));
                normalizedInput.put('contactFields',JSON.serialize(contactObjectFieldsMap));

            }else if('XC_Address__c' == objectName){
                normalizedInput.put('addressFields', JSON.serialize(sectionObjectFieldsMap.get(objectName)));
            
            } 
        }

        System.Debug('NORMALIZED INPUT FOR ACCOUNT CREATION ' + JSON.serialize(normalizedInput));

        return normalizedInput;
    }

    /**
    * @description create vehicle record starting from account
    * @author Monica Cutillo - mcutillo@deloitte.it | 18-01-2021
    * @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com | 22/03/2021 
    * @return InformationUser
    **/
    private static InformationUser getDefaultConsentForUserLE() {
        String userId = UserInfo.getUserId();
        List<User> userList = [SELECT Id, XC_LegalEntity__c, Country__c FROM User WHERE Id =: userId];
        List<Map<String, Object>> consentsLEList = new List<Map<String, Object>>();
        Map<String, Object> item = new Map<String, Object>();
        item.put('XC_LeCountry__c', userList[0].Country__c);
        item.put('XC_LegalEntity__c', userList[0].XC_LegalEntity__c);
        item.put('XC_GiveDataTonew__c', 'Yes');
        item.put('XC_UpdateAboutProducts__c', 'No');
        item.put('XC_LeCountXC_ConsentToDataProcessing__cry__c', 'No');
        item.put('XC_GiveDataTo__c', 'Yes');
        consentsLEList.add(item);

        InformationUser iuWrapper = new InformationUser();
        iuWrapper.consetInformation = JSON.serialize(consentsLEList);
        iuWrapper.legalEntityUser = userList[0].XC_LegalEntity__c;
        return iuWrapper;
    }

    /**
    * @description create vehicle record starting from account
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-11-2020 
    * @param accountId 
    * @param vehicleFieldMap 
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    @TestVisible
    private static XC_UTIL_Sobject.WrapperResult createAccountVehicleFromSection(String accountId,Map<String,Object> vehicleFieldMap, String partnerAMP){
        
        XC_AMP_Vehicle__c vehicleToCreate = new XC_AMP_Vehicle__c();
        vehicleToCreate.XC_AMP_Account__c = accountId;
        vehicleToCreate.XC_AMP_Partner__c = partnerAMP;
        vehicleFieldMap.remove('recordTypeId');

        for(String fieldKey : vehicleFieldMap.keySet()){
            if(fieldKey == 'XC_AMP_ExpectedDeliveryDate__c'){
                String dateStr = String.valueOf(vehicleFieldMap.get('XC_AMP_ExpectedDeliveryDate__c'));
        		vehicleToCreate.put(fieldKey,Date.valueOf(dateStr));
                continue;
            }
            vehicleToCreate.put(fieldKey,vehicleFieldMap.get(fieldKey));
        }
        return XC_UTIL_Sobject.insertRecord(vehicleToCreate);
    }


    /**
    * @description Method to create Opportunity
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-11-2020 
    * @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com | 22-03-2021
    * @param accountId - String
    * @param addressId - String
    * @param sectionExtraInfos - Map<String, Object>
    * @param legalEntityUser - String
    * @return XC_UTIL_Sobject.WrapperResult 
    **/
    @TestVisible
    private static XC_UTIL_Sobject.WrapperResult createOpportunity(String accountId, String addressId, Map<String, Object> sectionExtraInfos, String legalEntityUser){

        //get partner infos
        Map<String,Object> partnerInfos = XC_AMP_UTIL_ViewConfiguration.getPartnerUserInfo();

        //get related records
        Account relatedAccount = [SELECT Id, (SELECT Id FROM Addresses__r ORDER BY CreatedDate DESC LIMIT 1),(SELECT ID,XC_MainLegalEntity__c,XC_CountryLegalEntity__c FROM Contacts ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id= :accountId];
        List<XC_CM_Opportunity_Default_Values__mdt> opportunityDefaultValues = [SELECT XC_Default_Days_For_Close_Date_On_Insert__c FROM XC_CM_Opportunity_Default_Values__mdt WHERE XC_Country__c = :relatedAccount.contacts[0].XC_CountryLegalEntity__c];
        //create opportunity API wrapper
        XC_REST_Opportunity_U.WrapperRequest oppWrReq = new XC_REST_Opportunity_U.WrapperRequest();
        oppWrReq.Opportunity = new XC_UTIL_Opportunity.OpportunityIFWrapper();
        oppWrReq.Opportunity.AccountID = relatedAccount.Id;
        oppWrReq.Opportunity.ContactID = relatedAccount.Contacts[0].Id;
        oppWrReq.Opportunity.AddressID = String.isBlank(addressId) ? relatedAccount.Addresses__r[0].Id : addressId;
        oppWrReq.Opportunity.CloseDate = Date.Today().addDays(Integer.valueOf(opportunityDefaultValues[0].XC_Default_Days_For_Close_Date_On_Insert__c));
        oppWrReq.Opportunity.Status = Label.XC_CL_Opportunity_Draft;
        oppWrReq.Opportunity.OpportunityName = 'NoName';
        oppWrReq.Opportunity.LegalEntity = String.isNotBlank(legalEntityUser) ? legalEntityUser : relatedAccount.Contacts[0].XC_MainLegalEntity__c;
        
        if(sectionExtraInfos.containsKey('XC_ProductCategoryOfInterest__c') && fullFlow) { 
            oppWrReq.Opportunity.ProductCategoryOfInterest = String.valueOf(sectionExtraInfos.get('XC_ProductCategoryOfInterest__c'));
        } else {
            oppWrReq.Opportunity.ProductCategoryOfInterest = String.isNotBlank(String.valueOf(partnerInfos.get('categoryOfInterest'))) ? String.valueOf(partnerInfos.get('categoryOfInterest')) : null;
        }

        Opportunity oppToInsert = XC_REST_Opportunity_U.createOpportunityFromWrapper(oppWrReq);
        oppToInsert.XC_IsSimplifiedSales__c = true;
        oppToInsert.XC_AMP_Vehicle__c = sectionExtraInfos.containsKey('vehicleId') ? String.valueOf(sectionExtraInfos.get('vehicleId')) : null;
        oppToInsert.XC_AMP_InternalChannel__c = sectionExtraInfos.containsKey('internalChannel') ? String.valueOf(sectionExtraInfos.get('internalChannel')) : null;
        oppToInsert.XC_ReceivingChannel__c = String.valueOf(partnerInfos.get('receivingChannel'));
        oppToInsert.XC_RelatedOpportunity__c = sectionExtraInfos.containsKey('parentOpportunityId') ? String.valueOf(sectionExtraInfos.get('parentOpportunityId')) : null; //for child opportunities only
        oppToInsert.XC_AMP_Partner__c = String.valueOf(partnerInfos.get('ampPartner'));

        return XC_UTIL_Sobject.insertRecord(oppToInsert);
    }



    /**
    * @description manage existing records and append evetually relatedItems
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-17-2020 
    * @param params 
    * @return Map<String, Object> 
    **/
    @TestVisible
    private static Map<String,Object> manageDuplicationCases(Map<String,Object> params){

        Map<String,Object> result = new Map<String,Object>();
        result.put('success',true);

        Map<String,Map<String,Object>> sectionObjectFieldsMap = (Map<String,Map<String,Object>>) params.get('sections');

        Account existingAccountRecord = [SELECT Id,RecordTypeId FROM Account WHERE Id = :String.valueOf(params.get('existingAccountId')) LIMIT 1];

        //CHECK ON ADDRESS
        Map<String,Object> addressFields = sectionObjectFieldsMap.get('XC_Address__c');

        String dupKey1 = existingAccountRecord.Id + ' ' +
        String.valueOf(addressFields.get('country')) + ' ' + 
        String.valueOf(addressFields.get('city')) + ' ' + 
        String.valueOf(addressFields.get('province')) + ' ' + 
        String.valueOf(addressFields.get('streetNumber'));

        String dupKey2 = String.valueOf(addressFields.get('address')) + ' ' + 
        String.valueOf(addressFields.get('streetTypeText')) + ' ' + 
        String.valueOf(addressFields.get('municipality')) + ' ' + 
        String.valueOf(addressFields.get('postalCode'));

         Map<Id,XC_Address__c> addressMap = new Map<Id,XC_Address__c>([SELECT id 
         FROM XC_Address__c 
         WHERE XC_KeyForDuplication__c  = :dupKey1 
         AND XC_KeyForDuplicationOne__c = :dupKey2 
         AND XC_Account__c = :existingAccountRecord.Id LIMIT 1]);

         if(addressMap.isEmpty()){
            XC_LCC003_NewAccount_W.AccountInputDataWrapper aiwd = new XC_LCC003_NewAccount_W.AccountInputDataWrapper();
            aiwd.addressFields = JSON.serialize(addressFields);
            XC_UTIL_Sobject.WrapperResult addressAppendWr = XC_LCC003_NewAccount_U.insertAddress(existingAccountRecord, aiwd, existingAccountRecord.recordTypeId);
            result.put('success',addressAppendWr.success);
            if(!addressAppendWr.success){
                result.put('errorMsg',addressAppendWr.errorMessage);
            }
         }else{
            result.put('foundAddress',addressMap.values()[0].Id);
         }

        //CHECK ON CONSENTS
        //TODO:

        return result;
    }


    /**
    * @description retrieve object infos from opportunity
    * @author Francesco Imperioli - fimperioli@deloitte.it | 12-17-2020 
    * @param opportunityId 
    * @return Map<String, String> 
    **/
    public static Map<String,String> getInitInfoFromOpportunity(String opportunityId){
        Map<String,String> objectRecordIdMap = new Map<String,String>();
        Opportunity currentOpportunity = [SELECT XC_Contact__c,AccountId,XC_Address__c,XC_AMP_Vehicle__c,Account.RecordTypeId FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        objectRecordIdMap.put('Contact',currentOpportunity.XC_Contact__c);
        objectRecordIdMap.put('Account',currentOpportunity.AccountId);
        objectRecordIdMap.put('RT_Account',currentOpportunity.Account.RecordTypeId);
        objectRecordIdMap.put('XC_Address__c',currentOpportunity.XC_Address__c);
        objectRecordIdMap.put('XC_AMP_Vehicle__c',currentOpportunity.XC_AMP_Vehicle__c);
        objectRecordIdMap.put('Opportunity',opportunityId);
        return objectRecordIdMap;
    }

    /**
    * @description checkForComponentViewFilter
    * @author Monica Cutillo - mcutillo@deloitte.it
    * @param compView 
    * @param inputInfo 
    * @return List<XC_CM_OrderPortalSales_ComponentDef__mdt> filtered
    **/
    private static void checkForComponentViewFilter(List<XC_CM_OrderPortalSales_ComponentDef__mdt> compView, Map<String,String> inputInfo){
        /** Apply Partner filter on FieldSet */
        String partnerFilter = inputInfo.get('partnerAMP');
        for(XC_CM_OrderPortalSales_ComponentDef__mdt mdt : compView){
            List<String> fieldSetNames = mdt.XC_FieldSetName__c.split(',');
            String defaultFS = fieldSetNames[0];
            String partnerFS;
            Boolean samePartner = false;
            for(String fsName : fieldSetNames){
                if(String.isBlank(partnerFilter)){
                    break;
                }
                samePartner = fsName.contains(partnerFilter);
                if(samePartner){
                    partnerFS = fsName;
                    break;
                }
            }
            mdt.XC_FieldSetName__c = (samePartner) ? partnerFS : defaultFS;
        }
    }

}