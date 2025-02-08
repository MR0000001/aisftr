public with sharing class TA_LCC238_NewLead {

    private final static Boolean DEBUGACTIVE = true;

    public class FieldSetWrapper {
        List<FieldSetMember> fsPersonalData = new List<FieldSetMember>();
        List<FieldSetMember> fsContactData = new List<FieldSetMember>();
        List<FieldSetMember> fsDocumentData = new List<FieldSetMember>();
        List<FieldSetMember> fsOpportunity  = new List<FieldSetMember>();
        List<FieldSetMember> fsConsents     = new List<FieldSetMember>();
        List<FieldSetMember> fsSource       = new List<FieldSetMember>();
        List<FieldSetMember> fsCampaign     = new List<FieldSetMember>();
        String listMandatory = '';
        String defaultPhonePrefix ='';
        String defaultPrefLanguage = '';
        String defaultNationality='';
        Lead existingRecord = new Lead();
        String recordTypeName = '';
        String communityBaseUrl;
    }

    @AuraEnabled
    public static String retrieveData(Id recordId, String recordTypeId) {
        Schema.DescribeSObjectResult dsr = Lead.SObjectType.getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if(rti.isDefaultRecordTypeMapping()) {
                defaultRecordType = rti;
            }
        }
        if(recordTypeId == null && defaultRecordType!=null){
            recordTypeId=defaultRecordType.recordTypeId;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordId->' + recordId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordTypeId->' + recordTypeId);
        FieldSetWrapper wrapper = new FieldSetWrapper();
        wrapper.recordTypeName = XC_UTIL_Sobject.retrieveRecordTypNameFromId(recordTypeId);
        populateWrapper(wrapper, recordTypeId);
        wrapper.communityBaseUrl = Site.getBaseUrl();
        
        return JSON.serialize(wrapper);
    }

    @AuraEnabled
    public static Boolean isSystemAdmin(){
        return XC_UTIL_Environment.isSystemAdmin();
    }

    @AuraEnabled
    public static XC_UTIL_ResultWrapper getChannelFromUser(){
        XC_UTIL_ResultWrapper result = new XC_UTIL_ResultWrapper();
        result.success = true;
        String channel =  XC_UTIL_User.getChannelFromUser(UserInfo.getUserId());
        String country =  XC_UTIL_User.getCountryFromUser(UserInfo.getUserId());
        String countryFinal = '';
        if(country.contains(' ')){
            for(String word : country.split(' ')){
                countryFinal = countryFinal + word.toLowerCase().capitalize() + ' ';
            }
            countryFinal = countryFinal.removeEnd(' ');
        }else{
            countryFinal = country.toLowerCase().capitalize();
        }
        result.fieldName = channel;
        result.objectInfo = countryFinal;
        return result;
    }

    @AuraEnabled
    public static XC_LCC002_NewLead_W.InsertResultWrapper createRecord(String mapLeadString) {

        Savepoint savePoint = Database.setSavepoint();

        try{
            if(String.isBlank(mapLeadString)){
                return new XC_LCC002_NewLead_W.InsertResultWrapper('Unknown Error','');
            }

            Map<String,Object> mapLead = (Map<String, Object>) JSON.deserializeUntyped(mapLeadString);
            
            String addressFieldsSerialized;
            Map<String,Object> addressMap;

            if(String.isNotBlank((String) mapLead.get('addressFields'))){
                addressFieldsSerialized = (String) mapLead.get('addressFields');
                addressMap = (Map<String, Object>) JSON.deserializeUntyped(addressFieldsSerialized);
            } else {
                Database.rollback(savePoint);
                return new XC_LCC002_NewLead_W.InsertResultWrapper('Empty addressFields in JSON input.','');
            }
            
            String fieldMapStringLead;
            if(String.isNotBlank((String) mapLead.get('fieldMapStringLead'))){
                fieldMapStringLead = (String) mapLead.get('fieldMapStringLead');

            } else {
                Database.rollback(savePoint);
                return new XC_LCC002_NewLead_W.InsertResultWrapper('Empty fieldMapStringLead in JSON input.','');
            }
            
            //CREAZIONE DEL LEAD
            XC_REST_Lead_W.WrapperLeadResponse createLeadResponse = createLead(mapLead, fieldMapStringLead);
            system.debug('@@>> createLeadResponse >>> ' + createLeadResponse);

            if(createLeadResponse.Result.ErrorCode != '0'){
                system.debug('@@>> Internal Error on CREATE LEAD >>> ' + createLeadResponse.Result.Message);
                Database.rollback(savePoint);
                return new XC_LCC002_NewLead_W.InsertResultWrapper('Internal Error on CREATE LEAD: ' + createLeadResponse.Result.Message, '');
            } else {
                XC_LCC002_NewLead_W.InsertResultWrapper createLeadResponseToReturn = new XC_LCC002_NewLead_W.InsertResultWrapper(createLeadResponse.Lead.LeadID);

                Lead newLeadToUpdate = new Lead(Id = createLeadResponse.Lead.LeadID, Status = 'Take Charge', OwnerId = UserInfo.getUserId());
                XC_UTIL_Sobject.WrapperResult updateLeadStatusTakeCharge = XC_UTIL_Sobject.updateRecord(newLeadToUpdate);
                system.debug('@@>> updateLeadStatusTakeCharge >>> ' + updateLeadStatusTakeCharge);

                //UPDATE LEAD STATUS - Customer Contacted
                newLeadToUpdate.Status = 'Customer Contacted';
                XC_UTIL_Sobject.WrapperResult updateLeadStatusCustomerContacted = XC_UTIL_Sobject.updateRecord(newLeadToUpdate);
                system.debug('@@>> updateLeadStatusCustomerContacted >>> ' + updateLeadStatusCustomerContacted);
                
                if(createLeadResponse.Lead.CommercialVisit){
                    //UPDATE LEAD STATUS - Pending Scheduling
                    newLeadToUpdate.Status = 'Pending Scheduling';
                    XC_UTIL_Sobject.WrapperResult updateLeadStatusPendingScheduling = XC_UTIL_Sobject.updateRecord(newLeadToUpdate);
                    system.debug('@@>> updateLeadStatusPendingScheduling >>> ' + updateLeadStatusPendingScheduling);
                }

                createLeadResponseToReturn.key = String.valueOf(createLeadResponse.Lead.CommercialVisit);
                return createLeadResponseToReturn;
            }

        } catch (Exception e) {
            Database.rollback(savePoint);
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC238_NewLead] createRecord - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC238_NewLead', 'createRecord', errorMessage, 0, errorMessage, null);
        }

        return new XC_LCC002_NewLead_W.InsertResultWrapper('Unknown Error','');
    }

    @AuraEnabled
    public static XC_LCC002_NewLead_W.InsertResultWrapper manageConvertLead(String leadId, String workOrderId, Boolean bookNow){

        Savepoint savePoint = Database.setSavepoint();
        List<Lead> leadToDeleteForRollback = [SELECT Id, XC_Birthdate__c, XC_ProductCategoryOfInterest__c, XC_LeadAddress__c FROM Lead WHERE Id =: leadId];
        List<WorkOrder> workOrderToDeleteForRollback = new List<WorkOrder>();
        
        System.debug('@@>> leadToDeleteFOrRollback >>> ' + leadToDeleteFOrRollback);
        System.debug('@@>> leadId >>> ' + leadId);
        System.debug('@@>> workOrderId >>> ' + workOrderId);
        System.debug('@@>> bookNow >>> ' + bookNow);
        //System.debug('@@>> commercialVisit >>> ' + commercialVisit);

        if(String.isNotBlank(workOrderId)){
            workOrderToDeleteForRollback = [SELECT Id FROM WorkOrder WHERE Id =: workOrderId];
            System.debug('@@>> workOrderToDeleteForRollback >>> ' + workOrderToDeleteForRollback);
        }

        try {

            //CONVERSIONE DEL LEAD
            XC_REST_Lead_W.WrapperLeadResponse convertLeadResponse = convertLead(leadId);
            system.debug('@@>> convertLeadResponse >>> ' + convertLeadResponse);

            if(convertLeadResponse.Result.ErrorCode != '0' && !Test.isRunningTest()){
                system.debug('@@>> Internal Error on CONVERT LEAD >>> ' + convertLeadResponse.Result.Message);
                Database.rollback(savePoint);
                delete leadToDeleteForRollback;

                System.debug('@@>> workOrderToDeleteForRollback >>> ' + workOrderToDeleteForRollback);
                if(!workOrderToDeleteForRollback.isEmpty()){
                    delete workOrderToDeleteForRollback;
                }
                
                return new XC_LCC002_NewLead_W.InsertResultWrapper('Internal Error on CONVERT LEAD: ' + convertLeadResponse.Result.Message, '');
            }

            //Update BirthDate Contact
            update new Contact(Id = convertLeadResponse.Account.ContactID, Birthdate = leadToDeleteForRollback[0].XC_Birthdate__c);
                
            if(Test.isRunningTest()) {
                convertLeadResponse.Account = new XC_REST_Lead_W.WrapperAccount();
            }

            if(String.isNotBlank(workOrderId)){

                updateWorkOrderAndServiceAppointment(workOrderId, leadId, convertLeadResponse, bookNow);

            } else {

                XC_UTIL_Sobject.WrapperResult resultInsertWorkOrder = createDummyWorkOrder(leadToDeleteForRollback, leadId, convertLeadResponse);
                
                if(!resultInsertWorkOrder.success){
                    Database.rollback(savePoint);
                    delete leadToDeleteForRollback;
                    return new XC_LCC002_NewLead_W.InsertResultWrapper('Internal Error on CONVERT LEAD: ' + resultInsertWorkOrder.errorMessage, '');
                }

                XC_UTIL_Sobject.WrapperResult resultInsertServiceAppointment = createDummyServiceAppointment(resultInsertWorkOrder);
                
                if(!resultInsertServiceAppointment.success){
                    Database.rollback(savePoint);
                    delete leadToDeleteForRollback;
                    return new XC_LCC002_NewLead_W.InsertResultWrapper('Internal Error on CONVERT LEAD: ' + resultInsertServiceAppointment.errorMessage, '');
                }

                //XC_LCC002_NewLead_W.InsertResultWrapper createdDummyWorkOrderResult = new XC_LCC002_NewLead_W.InsertResultWrapper(dummyWorkOrderToInsert.Id);
                XC_LCC002_NewLead_W.InsertResultWrapper createdDummyWorkOrderResult = new XC_LCC002_NewLead_W.InsertResultWrapper(resultInsertWorkOrder.recordId);
                createdDummyWorkOrderResult.fieldName = resultInsertServiceAppointment.recordId;
                createdDummyWorkOrderResult.errorMessage = 'createAssignedResource';
                return createdDummyWorkOrderResult;
            }
            //Creato Lead e fatta leadConversion, ritorno al cmp per far uscire il pop up della book appointment
            XC_LCC002_NewLead_W.InsertResultWrapper convertLeadResult = new XC_LCC002_NewLead_W.InsertResultWrapper(leadId);
            return convertLeadResult;

        } catch (Exception e) {
            Database.rollback(savePoint);
            delete leadToDeleteForRollback;

            if(!workOrderToDeleteForRollback.isEmpty()){
                delete workOrderToDeleteForRollback;
            }

            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC238_NewLead] manageConvertLead - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC238_NewLead', 'manageConvertLead', errorMessage, 0, errorMessage, null);
        }

        return new XC_LCC002_NewLead_W.InsertResultWrapper('Unknown Error','');
    }

    @AuraEnabled
    public static XC_LCC002_NewLead_W.InsertResultWrapper createAssignedResource(String serviceAppointmentId){

        System.debug('@@>> serviceAppointmentId >>> ' + serviceAppointmentId);

        try {

            String currentUserId = UserInfo.getUserId();
            ServiceResource serviceResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :currentUserId];

            //CREO L'ASSIGNED RESOURCE
            AssignedResource relatedAssignedResource = new AssignedResource();
            relatedAssignedResource.ServiceResourceId = serviceResource.Id;
            relatedAssignedResource.ServiceAppointmentId = serviceAppointmentId;
            
            XC_UTIL_Sobject.WrapperResult resultInsertAssignedResource = XC_UTIL_Sobject.insertRecord(relatedAssignedResource);
            System.debug('@@>> Assigned Resource inserito >>> ' + resultInsertAssignedResource);

            if(!resultInsertAssignedResource.success){
                return new XC_LCC002_NewLead_W.InsertResultWrapper('Internal Error on createAssignedResource: ' + resultInsertAssignedResource.errorMessage, '');
            }

            XC_LCC002_NewLead_W.InsertResultWrapper createdAssignedResource = new XC_LCC002_NewLead_W.InsertResultWrapper(resultInsertAssignedResource.recordId);
            return createdAssignedResource;
            

        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC238_NewLead] createAssignedResource - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC238_NewLead', 'createAssignedResource', errorMessage, 0, errorMessage, null);
        }

        return new XC_LCC002_NewLead_W.InsertResultWrapper('Unknown Error','');
    }

    private static XC_REST_Lead_W.WrapperLeadResponse createLead(Map<String,Object> mapLead, String fieldMapStringLead){
        
        XC_REST_Lead_W.WrapperLeadRequest leadWrapperRequest = new XC_REST_Lead_W.WrapperLeadRequest();
        XC_REST_Lead_W.WrapperLeadResponse createLeadResponseWrapper = new XC_REST_Lead_W.WrapperLeadResponse();

        Map<String,String> mapHeader = new Map<String,String> {
                            'ClientSystem' => 'XInstaller',
                            'DateTimeMessage' => DateTime.now().format('yyyyMMddHHmmssSSS'),
                            'TransactionID' => 'createLead',
                            'Operation' => 'Create',
                            'Functionality' => 'CreateLead',
                            'ServerSystem' => 'XCustomerB2C'
        };

        Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(fieldMapStringLead);
        List<Object> consentsWrapper = (List<Object>) JSON.deserializeUntyped((String) mapLead.get('consentsWrapper'));

        //POPULATE ADDRESS WRAPPER
        XC_UTIL_Address.AddressWrapper addressWrapper = populateAddressWrapper(fieldMap);
        system.debug('@@>> addressWrapper >>> ' + addressWrapper);
        
        //POPULATE GDPR WRAPPER
        XC_UTIL_Lead.gdprWrapper gdprWrapper = populateGDPRWrapper(consentsWrapper);
        system.debug('@@>> gdprWrapper >>> ' + gdprWrapper);

        //POPULATE LEAD WRAPPER
        XC_UTIL_Lead.LeadRESTWrapper leadWrapper = populateLeadWrapper(fieldMap, addressWrapper, gdprWrapper);
        system.debug('@@>> leadWrapper >>> ' + leadWrapper);

        leadWrapperRequest.Lead = leadWrapper;

        //VALIDATE BEFORE INSERT
        XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_RESTInbound.checkObjectPermission('Lead', 'create');
        if(validateResult.errorFlag){
            createLeadResponseWrapper.Result.Message = validateResult.errorMessage; 
            createLeadResponseWrapper.Result.ErrorCode = validateResult.errorCode!=null?validateResult.errorCode:'400'; 
            return createLeadResponseWrapper;
        }

        //Validate Request
        validateResult = XC_REST_Lead_V.validateRequest(mapHeader, leadWrapperRequest, 'POST'); 
        if(validateResult.errorFlag) {                        
            createLeadResponseWrapper.Result.Message = 'ERROR. ' + validateResult.errorMessage;
            createLeadResponseWrapper.Result.ErrorCode = '400';
            return createLeadResponseWrapper;

        } else {                                                
            XC_REST_Lead_U.manageInsert(leadWrapperRequest.Lead, createLeadResponseWrapper, mapHeader);            
            return createLeadResponseWrapper;
        }
    }

    private static XC_UTIL_Address.AddressWrapper populateAddressWrapper(Map<String,Object> fieldMap){
        XC_UTIL_Address.AddressWrapper addressWrapperToReturn = new XC_UTIL_Address.AddressWrapper();

        addressWrapperToReturn.addressValid = true;
        addressWrapperToReturn.AddressValidated = true;
        addressWrapperToReturn.Category = (String) fieldMap.get('XC_Category__c');
        addressWrapperToReturn.StreetType = (String) fieldMap.get('XC_StreetTypeText__c');
        addressWrapperToReturn.StreetTypeText = (String) fieldMap.get('XC_StreetTypeText__c');
        addressWrapperToReturn.Address = (String) fieldMap.get('XC_Address__c');
        addressWrapperToReturn.ZipCode = (String) fieldMap.get('XC_PostalCode__c');
        addressWrapperToReturn.Province = (String) fieldMap.get('XC_AddressProvince__c');
        addressWrapperToReturn.City = (String) fieldMap.get('XC_City__c');
        addressWrapperToReturn.StreetNumber = (String) fieldMap.get('XC_StreetNumber__c');
        addressWrapperToReturn.Door = (String) fieldMap.get('XC_Door__c');
        addressWrapperToReturn.Floor = (String) fieldMap.get('XC_Floor__c');
        addressWrapperToReturn.Stair = (String) fieldMap.get('XC_Stair__c');
        addressWrapperToReturn.Country = (String) fieldMap.get('XC_AddressCountry__c');
        addressWrapperToReturn.electricCUPS = (String) fieldMap.get('XC_ElectricCUPS__c');
        addressWrapperToReturn.gasCUPS = (String) fieldMap.get('XC_GasCUPS__c');
        addressWrapperToReturn.Note = (String) fieldMap.get('XC_Note__c');
        addressWrapperToReturn.Region = (String) fieldMap.get('XC_Region__c');
        addressWrapperToReturn.clarifType = (String) fieldMap.get('XC_ClarificatorType__c');
        addressWrapperToReturn.clarifValue = (String) fieldMap.get('XC_ClarificatorValue__c');

        return addressWrapperToReturn;
    }

    private static XC_UTIL_Lead.gdprWrapper populateGDPRWrapper(List<Object> consentsWrapper){

        XC_UTIL_Lead.gdprWrapper gdprWrapperToReturn = new XC_UTIL_Lead.gdprWrapper();
        List<XC_UTIL_Lead.LegalEntityWrapper> legalEntityWrapperList = new List<XC_UTIL_Lead.LegalEntityWrapper>();
        
        for(Object consent : consentsWrapper){
            XC_UTIL_Lead.LegalEntityWrapper legalEntityWrapper = new XC_UTIL_Lead.LegalEntityWrapper();
            Map<String, Object> singleConsent = (Map<String, Object>) consent;
            
            if(String.isNotBlank((String) singleConsent.get('legalEntity'))){
                legalEntityWrapper.LegalEntity = (String) singleConsent.get('legalEntity');
            }

            if(String.isNotBlank((String) singleConsent.get('country'))){
                legalEntityWrapper.Country = (String) singleConsent.get('country');
            }

            /*if(String.isNotBlank((String) singleConsent.get('thirdPartyValue'))){
                String GiveDataToLegalEntity = (String) singleConsent.get('thirdPartyValue');
                legalEntityWrapper.GiveDataToLegalEntity = GiveDataToLegalEntity.left(1);
                gdprWrapperToReturn.GiveDataToThirdParties = GiveDataToLegalEntity.left(1);
            }*/

            legalEntityWrapper.GiveDataToLegalEntity = 'Y';
            if(String.isNotBlank((String) singleConsent.get('thirdPartyValue'))){
                String GiveDataToThirdParties = (String) singleConsent.get('thirdPartyValue');
                gdprWrapperToReturn.GiveDataToThirdParties = GiveDataToThirdParties.left(1);
            }

            if(String.isNotBlank((String) singleConsent.get('thPartiesMarketingValue'))){
                String GiveDataForMarketing = (String) singleConsent.get('thPartiesMarketingValue');
                legalEntityWrapper.GiveDataForMarketing = GiveDataForMarketing.left(1);
            }

            if(String.isNotBlank((String) singleConsent.get('profilingValue'))){
                String GiveDataForProfiling = (String) singleConsent.get('profilingValue');
                legalEntityWrapper.GiveDataForProfiling = GiveDataForProfiling.left(1);
            }

            if(String.isNotBlank((String) singleConsent.get('notCustomerValue'))){
                String GiveDataForNotCustomer = (String) singleConsent.get('notCustomerValue');
                legalEntityWrapper.GiveDataForNotCustomer = GiveDataForNotCustomer.left(1);
            }

            if(String.isNotBlank((String) singleConsent.get('thPartiesMarketingValue'))){
                String GiveDataForThirdProductMarketing = (String) singleConsent.get('thPartiesMarketingValue');
                legalEntityWrapper.GiveDataForThirdProductMarketing = GiveDataForThirdProductMarketing.left(1);
            }

            if(String.isNotBlank((String) singleConsent.get('consentVersion'))){
                legalEntityWrapper.VersionConsentCompany = (String) singleConsent.get('consentVersion');
                legalEntityWrapper.VersionConsentMarketing = (String) singleConsent.get('consentVersion');
                legalEntityWrapper.VersionConsentForProfiling = (String) singleConsent.get('consentVersion');
                legalEntityWrapper.VersionConsentNotCustomer = (String) singleConsent.get('consentVersion');
                legalEntityWrapper.VersionConsentThirdProductMarketing = (String) singleConsent.get('consentVersion');
                gdprWrapperToReturn.VersionConsentThirdParty = (String) singleConsent.get('consentVersion');
            }             

            legalEntityWrapperList.add(legalEntityWrapper);

        }

        gdprWrapperToReturn.LegalEntity = legalEntityWrapperList;
        return gdprWrapperToReturn;
    }

    private static XC_UTIL_Lead.LeadRESTWrapper populateLeadWrapper(Map<String,Object> fieldMap, XC_UTIL_Address.AddressWrapper addressWrapper, XC_UTIL_Lead.gdprWrapper gdprWrapper){

        XC_UTIL_Lead.LeadRESTWrapper leadWrapperToReturn = new XC_UTIL_Lead.LeadRESTWrapper();

        leadWrapperToReturn.LeadType = 'Residential';
        leadWrapperToReturn.Stream = 'B2C';

        if(String.isNotBlank((String) fieldMap.get('XC_Salutation__c'))){
            leadWrapperToReturn.Salutation = (String) fieldMap.get('XC_Salutation__c');
        }
        if(String.isNotBlank((String) fieldMap.get('LastName'))){
            leadWrapperToReturn.LastName = (String) fieldMap.get('LastName');   
        }

        if(String.isNotBlank((String) fieldMap.get('FirstName'))){
            leadWrapperToReturn.FirstName = (String) fieldMap.get('FirstName'); 
        }

        if(String.isNotBlank((String) fieldMap.get('Email'))){
            leadWrapperToReturn.PrimaryEmail = (String) fieldMap.get('Email');  
        }

        if(String.isNotBlank((String) fieldMap.get('XC_PhonePrefix__c'))){
            leadWrapperToReturn.PhonePrefix = (String) fieldMap.get('XC_PhonePrefix__c');  
        }

        if(String.isNotBlank((String) fieldMap.get('XC_LeadPhone__c'))){
            leadWrapperToReturn.Phone = (String) fieldMap.get('XC_LeadPhone__c');  
        }

        if(String.isNotBlank((String) fieldMap.get('XC_MobilePrefix__c'))){
            leadWrapperToReturn.MobilePrefix = (String) fieldMap.get('XC_MobilePrefix__c');  
        }

        if(String.isNotBlank((String) fieldMap.get('XC_LeadMobile__c'))){
            leadWrapperToReturn.Mobile = (String) fieldMap.get('XC_LeadMobile__c');  
        }

        if(String.isNotBlank((String) fieldMap.get('XC_Channel__c'))){
            leadWrapperToReturn.ReceivingChannel = (String) fieldMap.get('XC_Channel__c');  
        }

        if(String.isNotBlank((String) fieldMap.get('XC_Birthdate__c'))){
            leadWrapperToReturn.Birthdate = (String) fieldMap.get('XC_Birthdate__c'); 
        }

        if(String.isNotBlank((String) fieldMap.get('XC_Note__c'))){
            leadWrapperToReturn.Notes = (String) fieldMap.get('XC_Note__c');    
        }

        if(String.isNotBlank((String) fieldMap.get('XC_DocumentCountry__c'))){
            leadWrapperToReturn.Country = (String) fieldMap.get('XC_DocumentCountry__c');
            leadWrapperToReturn.IdentityCountry = (String) fieldMap.get('XC_DocumentCountry__c');
        }

        if(String.isNotBlank((String) fieldMap.get('XC_DocumentType__c'))){
            leadWrapperToReturn.IdentityType = (String) fieldMap.get('XC_DocumentType__c');
        }
        
        if(String.isNotBlank((String) fieldMap.get('XC_DocumentNumber__c'))){
            leadWrapperToReturn.IdentityNumber = (String) fieldMap.get('XC_DocumentNumber__c');
        }
        
        if(String.isNotBlank((String) fieldMap.get('XC_PostalCode__c'))){
            leadWrapperToReturn.ZipCode = (String) fieldMap.get('XC_PostalCode__c');
        }

        if(String.isNotBlank((String) fieldMap.get('XC_ProductCategoryOfInterest__c'))){
            leadWrapperToReturn.ProductCategoryOfInterest = (String) fieldMap.get('XC_ProductCategoryOfInterest__c');
        }

        if(String.isNotBlank((String) fieldMap.get('XC_Nationality__c'))){
            leadWrapperToReturn.Nationality = (String) fieldMap.get('XC_Nationality__c');
        }

        if(String.isNotBlank((String) fieldMap.get('XC_Preference_Language__c'))){
            leadWrapperToReturn.PreferenceLanguage = (String) fieldMap.get('XC_Preference_Language__c');
        }

        leadWrapperToReturn.Address = addressWrapper;
        leadWrapperToReturn.GDPR = gdprWrapper;

        return leadWrapperToReturn;
    }
    
    @TestVisible
    private static XC_REST_Lead_W.WrapperLeadResponse convertLead(String recordId){

        Map<String, String> params = new Map<String,String>{                               
            'LeadID' => recordId
        };                               
                    
        Map<String,String> header = new Map<String,String>{                               
            'ClientSystem' => 'XInstaller'                               
        };
                    
        XC_REST_Lead_W.WrapperLeadResponse responseWrapper = XC_REST_Lead_S.getLeadWrapper(params, header);                                
        XC_UTIL_Lead.LeadRESTWrapper leadWrapperForLeadConversion = responseWrapper.Lead;                               
                    
        XC_REST_Lead_T.manageConvertLead(leadWrapperForLeadConversion, responseWrapper);                               
                    
        return responseWrapper;
    }

    @AuraEnabled
    public static Boolean doRollback(String leadId){

        System.debug('@@>> leadId >>> ' + leadId);

        try {
            if(String.isNotBlank(leadId)){
                List<Lead> leadToDeleteForRollback = [SELECT Id FROM Lead WHERE Id =: leadId];
                System.debug('@@>> leadToDeleteForRollback >>> ' + leadToDeleteForRollback);
                if(!leadToDeleteForRollback.isEmpty()){
                    delete leadToDeleteForRollback;
                    return true;
                }
            } else {
                return false;
            }

        } catch (Exception e) {

            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC238_NewLead] doRollback - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC238_NewLead', 'doRollback', errorMessage, 0, errorMessage, null);
        }

        return false;
    }

    public static void populateFields(Lead newLead, Map<String,Object> fieldMap, String addressFields) {
        XC_LCC002_NewLead_U.removeAddress(fieldMap);
        XC_LCC002_NewLead_U.removePrefix(fieldMap);
        XC_LCC002_NewLead_U.removeReleaseDate(fieldMap);
        List<String> fieldList = XC_UTIL_Sobject.getListAllFields('Lead');
        for(String fieldName : fieldList){
            if(fieldName=='XC_Birthdate__c' || fieldName=='XC_NIE_expedition_date__c' || fieldName=='XC_NIE_expiration_date__c' || fieldName=='XC_ContactDocumentExpirationDate__c' || fieldName=='XC_ContacDocumentReleaseDate__c') {
                XC_LCC002_NewLead_U.populateDateFields(fieldName, fieldMap);
            }
            if(fieldName!='Name' && fieldMap.containsKey(fieldName) && fieldMap.get(fieldName) != null) {
                if((String.valueOf(fieldMap.get(fieldName)).contains('displayValue=null'))) {
                    Object v = ((Map<String,Object>)fieldMap.get(fieldName)).get('value');
                    System.debug('@@@ convVal -> ' + v);
                    newLead.put(fieldName, v);
                } else {
                    newLead.put(fieldName, fieldMap.get(fieldName));
                }
            }
        }
    }

    public static XC_LCC002_NewLead_W.InsertResultWrapper checkDuplicatesAndInsertRecord(Lead newLead, XC_LCC002_NewLead_W.LeadInputDataWrapper inputData) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkDuplicatesAndInsertRecord -> inputData = ' + inputData);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordTypeId->' + inputData.recordTypeId);
        String recordTypeName ='';
        if (!String.isBlank(inputData.recordTypeId)) {
            newLead.RecordTypeId = inputData.recordTypeId;
            recordTypeName = Schema.SObjectType.Lead.getRecordTypeInfosById().get(newLead.RecordTypeId).getDeveloperName();
        }
        
        newLead.Status = Label.XC_CL_Lead_Assigned;
        newLead.Salutation = newLead.XC_Salutation__c;

        List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse> lcc163Wrapper = (List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>) JSON.deserialize(inputData.consentsWrapper, List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>.class);
        List<String> leList = new List<String>();
        for (XC_LCC163_CreateConsents.GetLegalEntitiesResponse currWrapper : (lcc163Wrapper != null ? lcc163Wrapper : new List<XC_LCC163_CreateConsents.GetLegalEntitiesResponse>())) {
            XC_LCC163_CreateConsents.GetLegalEntitiesResponse createConsentsWrapper = (currWrapper != null) ? currWrapper : new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();
            leList.add(String.escapeSingleQuotes(createConsentsWrapper.legalEntity));
        }
        if(!recordTypeName.contains('SFM')){ 
            XC_LCC002_NewLead_U.populateListOfLegalEntities(newLead, String.escapeSingleQuotes(JSON.serialize(leList)));
        }
        List<Lead> listLeadInput = new List<Lead>();
        listLeadInput.add(newLead);
        System.debug('@@>> listLeadInput >>> ' + listLeadInput);
        List<XC_LCC002_NewLead_W.InsertResultWrapper> wrapperList = XC_UTIL_LeadDuplication.checkDuplicates(listLeadInput);
        System.debug('@@@checkDuplicatesAndInsertRecord wrapperList ' + wrapperList);
        try {
            if ((!wrapperList.isEmpty() && wrapperList[0].success) || wrapperList.isEmpty()) {
                XC_LCC002_NewLead_W.InsertResultWrapper retVal = insertRecord(newLead, inputData);
                if (retVal.success) {
                    for (XC_LCC163_CreateConsents.GetLegalEntitiesResponse currWrapper : lcc163Wrapper) {
                        XC_LCC163_CreateConsents.GetLegalEntitiesResponse createConsentsWrapper = (currWrapper != null) ? currWrapper : new XC_LCC163_CreateConsents.GetLegalEntitiesResponse();

                        System.debug('@@@ DP->' + inputData.consentsWrapper);
                        newLead.Country__c = createConsentsWrapper.consentsData.personalInfo.theLead.Country__c;
                        createConsentsWrapper.consentsData.personalInfo.theLead = (Lead) XC_UTIL_Sobject.selectAllFields(newLead.Id)[0];
                        createConsentsWrapper.consentsData.personalInfo.theContactIndividual = (Individual) XC_UTIL_Sobject.selectAllFields(createConsentsWrapper.consentsData.personalInfo.theLead.IndividualId)[0];
                        System.debug('@@@ DP->' + createConsentsWrapper);
                        XC_LCC163_CreateConsents.createLegalEntities(JSON.serialize(createConsentsWrapper));
                    }
                    return retVal;
                } else {
                    return retVal;
                }
            } else {
                XC_UTIL_Sobject.updateRecord(wrapperList[0].leadToUpdate);
                return wrapperList[0];
            }
        } catch(Exception e){
            System.debug(e);
            return null;
        }
    }

    private static void removeDocumentType(Lead newLead) {
        if(newLead.XC_DocumentNumber__c== null || newLead.XC_DocumentNumber__c == ''){
            System.debug('@@@ In removeDocumentType');
            newLead.XC_DocumentNumber__c= null;
            newLead.XC_DocumentType__c= null;
        }
    }

    @TestVisible
    private static XC_LCC002_NewLead_W.InsertResultWrapper insertRecord(Lead newLead, XC_LCC002_NewLead_W.LeadInputDataWrapper inputData) {
        System.Savepoint beforeInsertSavepoint = Database.setSavepoint();
        if(XC_UTIL_Lead.isResidential(newLead.RecordTypeId)){
            removeDocumentType(newLead);
        }
        XC_LCC002_NewLead_W.RollBackWrapper rollBackWrapper = XC_UTIL_InsertNewLead.checkForInsertRollBack(newLead, beforeInsertSavepoint);
        system.debug('@@>> rollBackWrapper >>> ' + rollBackWrapper);
        system.debug('@@>> newLead >>> ' + newLead);
        if(rollBackWrapper.isRollBack) {
            return rollBackWrapper.resultWrapper;
        }

        List<Lead> newLeadAllFields = XC_UTIL_Sobject.selectAllFields(newLead.Id);
        system.debug('@@>> newLeadAllFields >>> ' + newLeadAllFields);
        Lead newLeadToUpdate = newLeadAllFields[0];
        system.debug('@@>> newLeadToUpdate >>> ' + newLeadToUpdate);
        if(!String.isBlank(newLeadToUpdate.XC_Address__c) && !String.isBlank(newLeadToUpdate.XC_Country__c) && newLeadToUpdate.XC_Country__c != null){
            XC_UTIL_Sobject.WrapperResult addressResult = XC_LCC002_NewLead_U.insertAddress(newLeadToUpdate);
            if(!addressResult.success){
                return XC_LCC002_NewLead_Related.doRollback(addressResult, beforeInsertSavepoint);
            }
            newLeadToUpdate.XC_LeadAddress__c = addressResult.recordId;
        }
        newLeadToUpdate.XC_LeadId__c = newLeadToUpdate.Id;
        newLeadToUpdate.Status = 'Take Charge';

        XC_UTIL_Sobject.WrapperResult updateResult = XC_UTIL_Sobject.updateRecord(newLeadToUpdate);
        system.debug('@@>> updateResult >>> ' + updateResult);
        if(!updateResult.success){
            return XC_LCC002_NewLead_Related.doRollback(updateResult, beforeInsertSavepoint);
        }

        newLeadToUpdate.Status = 'Customer Contacted';
        newLeadToUpdate.XC_CommercialVisitRequired__c = true;
        XC_UTIL_Sobject.WrapperResult updateLeadStatusCustomerContacted = XC_UTIL_Sobject.updateRecord(newLeadToUpdate);
        //TEMPORANEO PROVO A FARE LA TAKE CHARGE

        return new XC_LCC002_NewLead_W.InsertResultWrapper(newLeadToUpdate.Id);
    }

    private static void populateWrapper(FieldSetWrapper wrapper, String recordTypeId) {
        String recordTypeName = XC_UTIL_Sobject.retrieveRecordTypNameFromId(recordTypeId);
        if(recordTypeName.contains('SFM')){
            String countryIso = 'ARG';
            if(recordTypeName.length()> 6 ){
                countryIso =  recordTypeName.substring(3,6);
            }
            wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_SFM_'+ countryIso +'_AccountInformation').getFields();
            wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_SFM_'+ countryIso +'_New_ContactInformation').getFields();
            wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_SFM_'+ countryIso +'_MandatoryAccount'));
            wrapper.fsOpportunity = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_SFM_'+ countryIso +'_New_Opportunity').getFields();
            wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_SFM_'+ countryIso +'_New_Source').getFields();
            String userId = UserInfo.getUserId();
            List<User> userList = [SELECT id, Country__c FROM User WHERE Id=:userId];
            if(userList[0].Country__c == null){
                return;
            }
            XC_CM_CountryLegalEntityAssociation__mdt userLE =  [select  XC_PhonePrefix__c,XC_Nationality__c,XC_Preferredlanguageofcontact__c from XC_CM_CountryLegalEntityAssociation__mdt where XC_Country__c = :userList[0].Country__c AND XC_Stream__c = 'B2B' limit 1];
            wrapper.defaultPhonePrefix= (userLE!=null && String.isNotBlank(userLE.XC_PhonePrefix__c)) ? userLE.XC_PhonePrefix__c : '';
            wrapper.defaultNationality = (userLE!=null && String.isNotBlank(userLE.XC_Nationality__c)) ? userLE.XC_Nationality__c : '';
            wrapper.defaultPrefLanguage= (userLE!=null && String.isNotBlank(userLE.XC_Preferredlanguageofcontact__c)) ? userLE.XC_Preferredlanguageofcontact__c : '';
            return;
        }
        XC_CM_CountryLegalEntityAssociation__mdt userLE = XC_UTIL_User.getLegalEntityMetadataFromUserByRT(recordTypeName);
        String countryIso = Constants.COUNTRY_ISO_CODES.get(userLE.XC_Country__c);
        String userLEString = userLE.XC_Category__c;

        if (countryIso == 'ESP') {
            if(XC_UTIL_Lead.isCondominium(recordTypeId)){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_PersonalData_Condominium').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_ESP_Lead_New_Mandatory_ContactInforma'));
            } else if(XC_UTIL_Lead.isSoho(recordTypeId)){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_PersonalData_Soho').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_ESP_Lead_New_Mandatory_ContactInforma'));
            } else {
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_PersonalData_Residential').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_ESP_Lead_New_Mandatory'));
            }
            wrapper.fsDocumentData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_DocumentInformation').getFields();
            wrapper.fsOpportunity = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Opportunity').getFields();
            wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_ESP_Lead_New_Source').getFields();
        }
        else{
            if(XC_UTIL_Lead.isCondominium(recordTypeId)){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_PersonalData_Condominium').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_'+countryIso+'_'+userLEString+'_New_Mandatory_ContactInforma'));
            } else if(XC_UTIL_Lead.isSoho(recordTypeId) ){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_PersonalData_Soho').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_'+countryIso+'_'+userLEString+'_New_Mandatory_ContactInforma'));
            } else if(XC_UTIL_Lead.isGlobalB2B(recordTypeId) || XC_UTIL_Lead.isGlobalB2G(recordTypeId)){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_PersonalData').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_'+countryIso+'_'+userLEString+'_New_Mandatory_ContactInforma'));
                List<XC_CM_LegalEntity_Configuration__mdt> complexProduct = [SELECT  XC_Country__c, XC_ComplexProductActive__c, XC_Stream__c FROM  XC_CM_LegalEntity_Configuration__mdt WHERE XC_Country__c = : userLE.XC_Country__c AND XC_Stream__c =: userLEString AND XC_OrgId__c =: UserInfo.getOrganizationId() ];
                if((countryIso != 'CHL' && countryIso != 'COL') || (!complexProduct.isEmpty() && complexProduct[0].XC_ComplexProductActive__c)){
                    wrapper.fsCampaign = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_CampaignInformation').getFields();
                }
            } else if(XC_UTIL_Lead.isGlobalLead(recordTypeId) ){
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_PersonalData').getFields();
                wrapper.fsContactData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_ContactInformation').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_GLO_New_Mandatory_ContactInforma'));
                wrapper.fsCampaign = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_CampaignInformation').getFields();
                
            } 
            else{
                wrapper.fsPersonalData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_PersonalData_Residential').getFields();
                wrapper.listMandatory = JSON.serialize(XC_UTIL_Sobject.getListFieldsFromFieldSet('Lead','XC_'+countryIso+'_'+userLEString+'_Lead_New_Mandatory'));
            }
            if(!XC_UTIL_Lead.isGlobalLead(recordTypeId)){
                wrapper.fsDocumentData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_DocumentInformation').getFields();
                wrapper.fsOpportunity = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_Opportunity').getFields();
                wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_'+countryIso+'_'+userLEString+'_New_Source').getFields();
            }else{
                wrapper.fsDocumentData = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_DocumentInformation').getFields();
                wrapper.fsOpportunity = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_Opportunity').getFields();
                wrapper.fsSource = Schema.SObjectType.Lead.fieldSets.getMap().get('XC_GLO_New_Source').getFields();
            }

            wrapper.defaultPhonePrefix= (userLE!=null && String.isNotBlank(userLE.XC_PhonePrefix__c)) ? userLE.XC_PhonePrefix__c : '';
            wrapper.defaultNationality = (userLE!=null && String.isNotBlank(userLE.XC_Nationality__c)) ? userLE.XC_Nationality__c : '';
            wrapper.defaultPrefLanguage= (userLE!=null && String.isNotBlank(userLE.XC_Preferredlanguageofcontact__c)) ? userLE.XC_Preferredlanguageofcontact__c : '';
        }
    }

    public static XC_UTIL_Sobject.WrapperResult createDummyWorkOrder(List<Lead> leadToDeleteForRollback, String leadId, XC_REST_Lead_W.WrapperLeadResponse convertLeadResponse) {

        Map<String,String> workTypeMap = new Map<String,String> {
                    'Air Conditioning'                   => 'Commercial Visit - Air Conditioning',

                    'Boiler'                             => 'Commercial Visit - Boiler',

                    'Architectural Lighting'             => 'Commercial Visit - Electric Installation',
                    'Electric Infrastructure Project'    => 'Commercial Visit - Electric Installation',
                    'Energy Efficiency (Smart Building)' => 'Commercial Visit - Electric Installation',
                    'Energy Infrastructure'              => 'Commercial Visit - Electric Installation',

                    'Water Heater'                       => 'Commercial Visit - Heaters',

                    'Car and Motorbike'                  => 'Commercial Visit - Juicebox',
                    'eMobility Private'                  => 'Commercial Visit - Juicebox',
                    'JuiceAbility'                       => 'Commercial Visit - Juicebox',
                    'Juice Box'                          => 'Commercial Visit - Juicebox',
                    'Juice Lamp'                         => 'Commercial Visit - Juicebox',
                    'Juice Pole'                         => 'Commercial Visit - Juicebox',
                    'Juice Pump'                         => 'Commercial Visit - Juicebox',
                    'JuicePedestal'                      => 'Commercial Visit - Juicebox',
                    'Smart Community'                    => 'Commercial Visit - Juicebox',
                    'Smart Home'                         => 'Commercial Visit - Juicebox',
                    'Smart City Services'                => 'Commercial Visit - Juicebox',
                    'Smart Community'                    => 'Commercial Visit - Juicebox',
                    'Smart Lighting'                     => 'Commercial Visit - Juicebox',

                    'Photovoltaic'                       => 'Commercial Visit - Photovoltaic',
                    'Photovoltaic PP'                    => 'Commercial Visit - Photovoltaic',

                    'Solar Thermal'                      => 'Commercial Visit - Solar Thermic'       
        };
        
        String workTypeName = workTypeMap.get(leadToDeleteForRollback[0].XC_ProductCategoryOfInterest__c);
        if(String.isBlank(workTypeName)){
            workTypeName = 'Commercial Visit - Electric Installation';
        }
        
        List<WorkType> workTypeList = [SELECT Id FROM WorkType WHERE Name = :workTypeName LIMIT 1];

        User u = [SELECT XC_LegalEntity__c FROM User where id = :UserInfo.getUserId() LIMIT 1]; //ENXCRM-169 bgo

        WorkOrder dummyWorkOrderToInsert = new WorkOrder();

        dummyWorkOrderToInsert.TA_Phase__c = 'Evaluation';
        dummyWorkOrderToInsert.Status = 'In Progress';
        dummyWorkOrderToInsert.XC_LegalEntity__c = u.XC_LegalEntity__c; //ENXCRM-169 bgo
        dummyWorkOrderToInsert.XC_WorkTypeLabel__c = workTypeName; //ENXCRM-169 bgo
        dummyWorkOrderToInsert.XC_Lead__c = leadId;
        dummyWorkOrderToInsert.XC_WorkTypeCategory__c = 'Commercial Visit';
        dummyWorkOrderToInsert.AccountId = convertLeadResponse.Account.AccountID;
        dummyWorkOrderToInsert.ContactId = convertLeadResponse.Account.ContactID;
        dummyWorkOrderToInsert.XC_Opportunity__c = convertLeadResponse.Account.OpportunityID;
        if(!workTypeList.isEmpty()){
            dummyWorkOrderToInsert.WorkTypeId = workTypeList.get(0).Id;
        }
        dummyworkOrderToInsert.XC_Address__c = leadToDeleteForRollback[0].XC_LeadAddress__c;

        List<Opportunity> listOppty = [SELECT Id, XC_LegalEntity__c FROM Opportunity WHERE Id = :dummyWorkOrderToInsert.XC_Opportunity__c];
        Opportunity oppty = listOppty.size() > 0 ? listOppty[0] : new Opportunity();
        dummyWorkOrderToInsert.XC_LegalEntity__c = oppty.XC_LegalEntity__c;

        XC_UTIL_Sobject.WrapperResult resultInsertWorkOrder = XC_UTIL_Sobject.insertRecord(dummyWorkOrderToInsert);
        System.debug('@@>> WorkOrder inserito >>> ' + resultInsertWorkOrder);
        return resultInsertWorkOrder;
    }

    public static XC_UTIL_Sobject.WrapperResult createDummyServiceAppointment(XC_UTIL_Sobject.WrapperResult resultInsertWorkOrder) {

        String currentUserId = UserInfo.getUserId();
        User currentUser = [SELECT Country__c, AccountId FROM User WHERE Id = :currentUserId];
        ServiceResource serviceResource = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :currentUserId];

        ServiceAppointment dummyServiceAppointmentToInsert = new ServiceAppointment();
        dummyServiceAppointmentToInsert.OwnerId = UserInfo.getUserId();
        dummyServiceAppointmentToInsert.ParentRecordId = resultInsertWorkOrder.recordId;
        dummyServiceAppointmentToInsert.Status = 'In Progress';
        dummyServiceAppointmentToInsert.ActualStartTime = DateTime.now();
        dummyServiceAppointmentToInsert.schedStartTime = DateTime.now();
        dummyServiceAppointmentToInsert.schedEndTime = DateTime.now();
        dummyServiceAppointmentToInsert.XC_AssignedPartner__c = currentUser.AccountId;
        dummyServiceAppointmentToInsert.XC_AssignedResource__c = serviceResource.Id;
        
        XC_UTIL_Sobject.WrapperResult resultInsertServiceAppointment = XC_UTIL_Sobject.insertRecord(dummyServiceAppointmentToInsert);
        System.debug('@@>> ServiceAppointment inserito >>> ' + resultInsertServiceAppointment);
        return resultInsertServiceAppointment;
    }

    public static void updateWorkOrderAndServiceAppointment(String workOrderId, String leadId, XC_REST_Lead_W.WrapperLeadResponse convertLeadResponse, Boolean bookNow) {

        WorkOrder workOrderToUpdate = new WorkOrder(Id = workOrderId);
        workOrderToUpdate.XC_Lead__c = leadId;
        workOrderToUpdate.AccountId = convertLeadResponse.Account.AccountID;
        workOrderToUpdate.ContactId = convertLeadResponse.Account.ContactID;
        workOrderToUpdate.XC_Opportunity__c = convertLeadResponse.Account.OpportunityID;
        // workOrderToUpdate.XC_WorkTypeLabel__c = null; //ENXCRM-169 bgo
        
        ServiceAppointment relatedServiceAppointment;
        if(bookNow){
            List<ServiceAppointment> relatedServiceAppointmentList = [SELECT id FROM ServiceAppointment WHERE ParentRecordId =: workOrderId];
            
            if(!relatedServiceAppointmentList.isEmpty()){
                relatedServiceAppointment = relatedServiceAppointmentList[0];
                relatedServiceAppointment.Status = 'In Progress';
                relatedServiceAppointment.ActualStartTime = DateTime.now();
            }
            workOrderToUpdate.TA_Phase__c = 'Evaluation';
            workOrderToUpdate.Status = 'In Progress';
        } else {
            workOrderToUpdate.TA_Phase__c = 'PreService';
        }
        
        XC_UTIL_Sobject.WrapperResult resInsertSA = XC_UTIL_Sobject.updaterecord(relatedServiceAppointment);
        XC_UTIL_Sobject.WrapperResult resInsertWO = XC_UTIL_Sobject.updaterecord(workOrderToUpdate);
    }

    @AuraEnabled
    public static XC_UTIL_ResultWrapper initCanvas(String recordId) {

        XC_UTIL_ResultWrapper result = XC_LCC066_Doxee.fetchUser(recordId);
        return result;
    }
}