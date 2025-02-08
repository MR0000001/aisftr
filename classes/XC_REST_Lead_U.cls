/**
 * The Class XC_REST_Lead_U.
 *
 * @author            : Federico Amici federico.amici@nttdata.com
 * @date Creation     : dd/mm/yyyy
 * @date Modification : 16/04/2019 by Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @description       : Rest Resourse for Create/Update Lead
 **/


public without sharing class XC_REST_Lead_U {  
    
    
    /**
	 * Manage insert.
	 *
	 * @param lead the lead to insert
	 * @param responseWrapper the response wrapper
     * @description manage insert of Lead
	 */
	public static void manageInsert(XC_UTIL_Lead.LeadRESTWrapper lead, XC_REST_Lead_W.WrapperLeadResponse responseWrapper, Map<String, String> mapHeader) {

        // Lead
        Lead leadToInsert = XC_REST_Lead_W.generateLeadFromWrapper(lead, 'POST', null, mapHeader);
        /*if(lead.Identity != null && !lead.Identity.isEmpty() && String.isBlank(leadToInsert.XC_DocumentNumber__c)) {
            Date nieExpeditionDate = String.isNotBlank(lead.Identity[0].ReleaseDate) ? Date.valueOf(lead.Identity[0].ReleaseDate) : null;
            Date nieExpirationDate = String.isNotBlank(lead.Identity[0].ExpiryDate) ? Date.valueOf(lead.Identity[0].ExpiryDate) : null;
            leadToInsert.XC_DocumentCountry__c = lead.Identity[0].Country;
            leadToInsert.XC_DocumentType__c = lead.Identity[0].IdentityType;
            leadToInsert.XC_DocumentNumber__c = lead.Identity[0].IdentityNumber;
            leadToInsert.XC_NIE_expedition_date__c = nieExpeditionDate;
            leadToInsert.XC_NIE_expiration_date__c = nieExpirationDate;
        }*/
        manageInsertLead(leadToInsert, lead, responseWrapper);
        if(responseWrapper.Result.ErrorCode != '0') {
            return;
        }

        // Personal Document
        /*if(lead.Identity != null && !Lead.Identity.isEmpty()) {
            responseWrapper.Lead.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
            manageupsertDocument(lead.Identity, leadToInsert.Id, responseWrapper);
            if(String.isNotBlank(responseWrapper.result.ErrorCode) && responseWrapper.result.ErrorCode != '0') {
                return;
            }
        }*/
        
        // Address
        manageAddress(lead.address, leadToInsert.Id, responseWrapper);
        if(responseWrapper.result.ErrorCode != '0') {
            return;
        }

        manageCTI(lead, leadToInsert.Id);

        responseWrapper.Result.ErrorCode = '0';
        responseWrapper.Result.Message = 'Operation completed successfully';
    }


    /**
	 * Manage insert Lead.
	 *
	 * @param leadToInsert the lead to insert
     * @param leadWrapper the lead wrapper
	 * @param responseWrapper the response wrapper
     * @description manage insert of Lead
	 */
	public static void manageInsertLead(Lead leadToInsert, XC_UTIL_Lead.LeadRESTWrapper leadWrapper, XC_REST_Lead_W.WrapperLeadResponse responseWrapper) {
            
        XC_LCC002_NewLead_W.LeadInputDataWrapper inputData = new XC_LCC002_NewLead_W.LeadInputDataWrapper();
        inputData.recordTypeId = leadToInsert.RecordTypeId;
        inputData.assignLead = true;
        inputData.thirdPartiesCheckNew = (String.isNotBlank(XC_UTIL_Integration_U.convertFromStringToPicklist(leadWrapper.GDPR.GiveDataToThirdParties))) ? XC_UTIL_Integration_U.convertFromStringToPicklist(leadWrapper.GDPR.GiveDataToThirdParties) : 'No';
        //inputData.robinsonCustomer = false;

        // Check for Legal Entity Consent:
        List<Map<String, Object>> mapLegalEntityConsent = XC_REST_Lead_W.generateLegalEntityForInsertLead(leadWrapper.GDPR.LegalEntity);
        List<XC_LegalEntityConsent__c> listLegalEntityConsent = new List<XC_LegalEntityConsent__c>();
        for(Map<String, Object> singleObj : mapLegalEntityConsent) {
            XC_LegalEntityConsent__c lec = new XC_LegalEntityConsent__c(XC_LegalEntity__c = String.valueOf(singleObj.get('singleObj')));
            listLegalEntityConsent.add(lec);
        }
        Boolean canInsertLCE = XC_TR_LegalEntityConsent_U_CheckFields.checkAge(listLegalEntityConsent, leadToInsert);
        if(!canInsertLCE) {
            responseWrapper.Result.ErrorCode = '501';
            responseWrapper.Result.Message = 'INTERNAL ERROR: ' + Label.XC_CL_ErrorAdultAge;
            System.debug(LoggingLevel.FINEST, '### ERRORMESSAGE ### ' + responseWrapper.Result.Message);
            XC_TR_LegalEntityConsent_U_CheckFields.checkAlreadyDone = true;
            return;
        }
        inputData.consentsLE = JSON.serialize(listLegalEntityConsent);
        inputData.consentsWrapper = JSON.serialize(XC_REST_Lead_W.generateConsentsWrapper(leadWrapper.GDPR.LegalEntity, inputData.thirdPartiesCheckNew));
        
        if(leadWrapper.gdpr != null){
            if(leadWrapper.gdpr.RobinsonCustomer != null){
                inputData.robinsonCustomer = XC_UTIL_Integration.convertFromStringToBoolean(leadWrapper.gdpr.RobinsonCustomer);
            } 
            inputData.thirdPartiesVersion = leadWrapper.gdpr.VersionConsentThirdParty;
        }

        XC_LCC002_NewLead_W.InsertResultWrapper resultInsertLead = XC_LCC002_NewLead.checkDuplicatesAndInsertRecord(leadToInsert, inputData);
        if(!resultInsertLead.success){
            if(resultInsertLead.errorMessage.contains('Lead already exists')){
                manageDuplicationErrorMessage(resultInsertLead.errorMessage, responseWrapper);
                return;
            }else{
                responseWrapper.Result.ErrorCode = '500';
                responseWrapper.Result.Message = 'INTERNAL ERROR: ' + resultInsertLead.errorMessage;
                System.debug(LoggingLevel.FINEST, '### ERRORMESSAGE ### ' + responseWrapper.Result.Message);
                return;
            }
            
        } else {
            responseWrapper.Lead = new XC_UTIL_Lead.LeadRESTWrapper();
            responseWrapper.Lead.LeadID = resultInsertLead.recordId;
            Lead l = [SELECT Id, Status, IndividualId, XC_MainLegalEntity__c FROM Lead WHERE  Id =: resultInsertLead.recordId LIMIT 1];
            responseWrapper.Lead.Status = l.Status;

            //aggiungere leg
            List<XC_UTIL_Lead.LegalEntityWrapper> leList = new List<XC_UTIL_Lead.LegalEntityWrapper>();
            for(XC_UTIL_Lead.LegalEntityWrapper le : leadWrapper.GDPR.LegalEntity){
                if(le.LegalEntity != l.XC_MainLegalEntity__c){
                    leList.add(le);
                }
            }

            XC_REST_Lead_T.manageLegalEntity(leList,l.individualId,responseWrapper);

            if(String.isNotBlank(leadToInsert.XC_ProductCategoryOfInterest__c)) {
                responseWrapper.Lead.CommercialVisit = XC_LCC002_NewLead_U.hasCommercialVisit(leadToInsert.XC_ProductCategoryOfInterest__c);
            }
        }

        responseWrapper.Result.ErrorCode = '0';
    }


    /**
	 * Manage upsert document.
	 *
	 * @param identityList the identity list to upsert
     * @param leadId the lead ID
	 * @param responseWrapper the response wrapper
     * @description manage upsert of Personal Document
	 */
	/*public static void manageUpsertDocument(List<XC_UTIL_Account.IdentityIFWrapper> identityList, String leadId, XC_REST_Lead_W.WrapperLeadResponse responseWrapper) {

        List<XC_PersonalDocument__c> documentToUpsertList = new List<XC_PersonalDocument__c>();
        for(XC_UTIL_Account.IdentityIFWrapper idWr : identityList) {
            XC_PersonalDocument__c documentToUpsert = XC_REST_Lead_W.generateDocumentFromWrapper(idWr, leadId);
            documentToUpsertList.add(documentToUpsert);
        }

        List<XC_UTIL_Sobject.WrapperResult> resultUpsertDoc = XC_UTIL_Sobject.upsertListRecords(documentToUpsertList);
        for(XC_UTIL_Sobject.WrapperResult res : resultUpsertDoc) {
            if(!res.success) {
                responseWrapper.result.ErrorCode = '500';
                responseWrapper.result.Message = 'INTERNAL ERROR: ' + res.errorMessage;
                responseWrapper.result.logError = 'INTERNAL ERROR: ' + res.errorMessage;
                return;
            } else {
                XC_UTIL_Account.IdentityIFWrapper idWr = new XC_UTIL_Account.IdentityIFWrapper();
                idWr.IdentityID = res.recordId;
                for(XC_PersonalDocument__c pd : documentToUpsertList) {
                    if(pd.Id == idWr.IdentityID) {
                        idWr.Country = pd.XC_Country__c;
                        idWr.IdentityType = pd.XC_DocumentType__c;
                        idWr.IdentityNumber = pd.XC_DocumentNumber__c;
                    }
                }
                responseWrapper.Lead.Identity.add(idWr);
            }
        }
    }*/


    /**
	 * Manage address.
	 *
	 * @param address the address to manage
     * @param leadId the lead ID
	 * @param responseWrapper the response wrapper
     * @description manage address
	 */
	public static void manageAddress(XC_UTIL_Address.AddressWrapper address, String leadId, XC_REST_Lead_W.WrapperLeadResponse responseWrapper) {
        
        if(address == null) {
            return;
        }

        Map<Id, XC_Address__c> addMap = new Map<Id, XC_Address__c>([SELECT Id, XC_StreetType__c, XC_StreetTypeText__c, XC_Address__c, XC_StreetNumber__c, XC_PostalCode__c, XC_AddressCountry__c, XC_City__c FROM XC_Address__c WHERE XC_Lead__c =: leadId]);
        
        responseWrapper.Lead.Address = new XC_UTIL_Address.AddressWrapper();
        responseWrapper.Lead.Address.AddressID = addMap.values()[0].Id;
        responseWrapper.Lead.Address.StreetType = addMap.values()[0].XC_StreetType__c;
        responseWrapper.Lead.Address.Address = addMap.values()[0].XC_Address__c;
        responseWrapper.Lead.Address.StreetNumber = addMap.values()[0].XC_StreetNumber__c;
        responseWrapper.Lead.Address.ZipCode = addMap.values()[0].XC_PostalCode__c;
        responseWrapper.Lead.Address.City = addMap.values()[0].XC_City__c;
        responseWrapper.Lead.Address.Country = addMap.values()[0].XC_AddressCountry__c;
        responseWrapper.Lead.Address.InstallationAddress = null; 
        responseWrapper.Lead.Address.DeliveryAddress = null;
        responseWrapper.Lead.Address.BillingAddress = null;
        responseWrapper.Lead.Address.isPartner = null;
        responseWrapper.Lead.Address.PickupPoint = null;
        responseWrapper.Lead.Address.Warehouse = null;
        responseWrapper.Lead.Address.PointOfSales = null;
        //responseWrapper.Lead.Address.MunicipalCode = address.MunicipalCode;
        //responseWrapper.Lead.Address.StreetCode = address.StreetCode;

        if(address.PointOfService != null && !address.PointOfService.isEmpty()) {
            responseWrapper.Lead.Address.PointOfService = new List<XC_UTIL_Address.PoSWrapper>();
            manageUpsertPointOfService(address.PointOfService, addMap.values()[0].Id, responseWrapper);
        }
    }
        

    /**
	 * Manage upsert point of service.
	 *
	 * @param pointOfService the pointOfService to update
     * @param addressId the address ID
	 * @param responseWrapper the response wrapper
     * @description manage upsert of pos
	 */
	public static void manageUpsertPointOfService(List<XC_UTIL_Address.PoSWrapper> pointOfService, String addressId, XC_REST_Lead_W.WrapperLeadResponse responseWrapper) {

        List<XC_PointOfService__c> posToUpsertList = new List<XC_PointOfService__c>();
        for(XC_UTIL_Address.PoSWrapper pos : pointOfService) {
            XC_PointOfService__c posToUpsert = XC_REST_Lead_W.generatePosFromWrapper(pos, addressId);
            posToUpsertList.add(posToUpsert);
        }

        List<XC_UTIL_Sobject.WrapperResult> resultUpsertPos = XC_UTIL_Sobject.upsertListRecords(posToUpsertList);
        for(XC_UTIL_Sobject.WrapperResult res : resultUpsertPos) {
            if(!res.success) {
                responseWrapper.result.ErrorCode = '500';
                responseWrapper.result.Message = 'INTERNAL ERROR';
                responseWrapper.result.logError = 'INTERNAL ERROR: ' + res.errorMessage;
                system.debug('debuggggggg'+res.errorMessage);
                return;
            } else {
                XC_UTIL_Address.PoSWrapper posWr = new XC_UTIL_Address.PoSWrapper();
                posWr.POSID = res.recordId;
                for(XC_PointOfService__c pos : posToUpsertList) {
                    if(pos.Id == posWr.POSID) {
                        posWr.POS = pos.Name;
                    }
                }
                responseWrapper.Lead.Address.PointOfService.add(posWr);
            }
        }
    }


    /**
	 * @param errorMessage the errorMessage
     * @param responseWrapper the responseWrapper to populate
     * @description manage error message of lead duplication 
	 */
    public static void manageDuplicationErrorMessage(String errorMessage, XC_REST_Lead_W.WrapperLeadResponse responseWrapper){
        String key = errorMessage.split('key:')[1];
        responseWrapper.result.ErrorCode = '501';
        responseWrapper.result.Message =  Label.XC_CL_LeadAssigned2;
        responseWrapper.Lead = new XC_UTIL_Lead.LeadRESTWrapper();
        responseWrapper.Lead.LeadID = key;
        system.debug('prova: '+responseWrapper);
        
        Map<id, Lead> dupList = new Map<id, Lead>([SELECT Id, Status, XC_CommercialVisitRequired__c FROM Lead WHERE id =: key]);
        if(!dupList.values().isEmpty()){
            responseWrapper.Lead.CommercialVisit = dupList.values()[0].XC_CommercialVisitRequired__c;
            responseWrapper.Lead.Status = dupList.values()[0].Status;  
        }
    }

    private static void manageCTI(XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String leadId) {
        if(!String.isBlank(leadWrapper.RegistrationLink)){
            XC_CTICallRecording__c cti = new XC_CTICallRecording__c();
            cti.XC_RecordingUrl__c = leadWrapper.RegistrationLink;
            cti.XC_Lead__c = leadId;
            XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.insertRecord(cti);
        }
    }

}