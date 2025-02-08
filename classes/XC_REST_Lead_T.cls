/**
 * The Class XC_REST_Lead_T.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 08/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse for Create/Update Lead
 **/


public without sharing class XC_REST_Lead_T {

        
    /**
     * Manage update.
     *
     * @param leadWr the lead wrapper
     * @param responseWrapper the response wrapper
     * @description manage update
     */
    public static void manageUpdate(XC_UTIL_Lead.LeadRESTWrapper leadWr, XC_REST_Lead_W.WrapperLeadResponse responseWrapper, Map<String,String> header) {

        // Lead
        manageUpdateLead(leadWr, responseWrapper, header);
        if(responseWrapper.result.ErrorCode != '0') {
            return;
        }

        // Personal Document
        /*if(leadWr.Identity != null && !leadWr.Identity.isEmpty()) {
            responseWrapper.Lead.Identity = new List<XC_UTIL_Account.IdentityIFWrapper>();
            XC_REST_Lead_U.manageupsertDocument(leadWr.Identity, leadWr.LeadID, responseWrapper);
            if(String.isNotBlank(responseWrapper.result.ErrorCode) && responseWrapper.result.ErrorCode != '0') {
                return;
            }
        }*/

        // Address
        XC_REST_Lead_U.manageAddress(leadWr.address, leadWr.LeadID, responseWrapper);
        if(responseWrapper.result.ErrorCode != '0') {
            return;
        }

        responseWrapper.result.ErrorCode = '0';
        responseWrapper.result.Message = 'Operation completed successfully';
    }


    /**
     * Manage update Lead.
     *
     * @param leadWr the lead wrapper
     * @param responseWrapper the response wrapper
     * @description manage update
     */
    public static void manageUpdateLead(XC_UTIL_Lead.LeadRESTWrapper leadWr, XC_REST_Lead_W.WrapperLeadResponse responseWrapper, Map<String,String> header) {

        Lead existingLead = XC_REST_Lead_S.checkExistingLead(leadWr, responseWrapper);
        if(existingLead == null) {
            return;
        }
        
        Lead leadToUpdate = XC_REST_Lead_W.generateLeadFromWrapper(leadWr, 'PUT', existingLead, header);
        XC_UTIL_Sobject.WrapperResult resultUpdate = XC_UTIL_Sobject.updateRecord(leadToUpdate);
        if(!resultUpdate.success){
            if(resultUpdate.errorMessage.contains('Lead already exists.')){
                XC_REST_Lead_U.manageDuplicationErrorMessage(resultUpdate.errorMessage, responseWrapper);
                return;
            }else{
                responseWrapper.result.ErrorCode = '500';
                responseWrapper.result.Message = 'INTERNAL ERROR: ' + resultUpdate.errorMessage;
                responseWrapper.result.logError = 'INTERNAL ERROR: ' + resultUpdate.errorMessage;
                return;
            }
        }

        responseWrapper.Lead = new XC_UTIL_Lead.LeadRESTWrapper();
        responseWrapper.Lead.LeadID = leadWr.LeadID;

        // GDPR
        manageGDPR(leadWr.GDPR, leadToUpdate.Id, responseWrapper);
        if(responseWrapper.result.ErrorCode != '0') {
            return;
        }

        responseWrapper.result.ErrorCode = '0';
    }


    /**
	 * Manage GDPR.
	 *
	 * @param gdprWr the gdprWr to manage
     * @param leadId the lead ID
	 * @param responseWrapper the response wrapper
     * @description manage GDPR
	 */ 
	public static void manageGDPR(XC_UTIL_Lead.gdprWrapper gdprWr, Id leadId, XC_REST_Lead_W.WrapperLeadResponse responseWrapper) {

        Set<String> setFields = new Set<String>{'IndividualId'};
        List<Lead> leadList = (List<Lead>) XC_UTIL_Query.selectFieldsList(setFields, leadId);

        if(gdprWr != null){
            Individual indToUpdate = new Individual();

            if(gdprWr.GiveDataToThirdParties != null){
                indToUpdate.XC_GiveDataToThirdParties__c = XC_UTIL_Integration_U.convertFromStringToPicklist(gdprWr.GiveDataToThirdParties);
            }
            if(gdprWr.RobinsonCustomer != null){
                indToUpdate.XC_RobinsonCustomer__c =  XC_UTIL_Integration.convertFromStringToBoolean(gdprWr.RobinsonCustomer);
            }


            Map<String, Object> mapGdpr = new Map<String,Object>{
                                                                'Id' => leadList[0].IndividualId,
                                                                'XC_ThirdPartyConsentVersion__c' => gdprWr.VersionConsentThirdParty,
                                                                'XC_CollectionDateThirdParties__c' => gdprWr.ConsentThirdPartyDate
                                                                };

            for(String key : mapGdpr.keySet()){
                if(mapGdpr.get(key) != null){
                    indToUpdate.put(key, mapGdpr.get(key));
                }
            }
            XC_UTIL_Sobject.WrapperResult resultUpdateInd = XC_UTIL_Sobject.updateRecord(indToUpdate);
            if(!resultUpdateInd.success) {
                responseWrapper.result.ErrorCode = '500';
                responseWrapper.result.Message = 'INTERNAL ERROR';
                responseWrapper.result.logError = 'INTERNAL ERROR: ' + resultUpdateInd.errorMessage;
                return;
            }

            /*if(gdprWr.GiveDataToThirdParties != null){
                //new Individual(Id = leadList[0].IndividualId, XC_GiveDataToThirdParties__c = XC_UTIL_Integration_U.convertFromStringToPicklist(gdprWr.GiveDataToThirdParties));
            
                XC_UTIL_Sobject.WrapperResult resultUpdateInd = XC_UTIL_Sobject.updateRecord(indToUpdate);
                if(!resultUpdateInd.success) {
                    responseWrapper.result.ErrorCode = '500';
                    responseWrapper.result.Message = 'INTERNAL ERROR';
                    responseWrapper.result.logError = 'INTERNAL ERROR: ' + resultUpdateInd.errorMessage;
                    return;
                }
            }*/
            
            // Legal Entity
            if(gdprWr.LegalEntity != null){
                manageLegalEntity(gdprWr.LegalEntity, leadList[0].IndividualId, responseWrapper);
                if(String.isNotBlank(responseWrapper.result.ErrorCode) && responseWrapper.result.ErrorCode != '0') {
                    return;
                }
            }
        }

        responseWrapper.result.ErrorCode = '0';
    }


    /**
	 * Manage Legal Entity.
	 *
	 * @param legalEntityWr the legalEntity to manage
     * @param individualId the individual ID
	 * @param responseWrapper the response wrapper
     * @description manage legal entity
	 */
	public static void manageLegalEntity(List<XC_UTIL_Lead.LegalEntityWrapper> legalEntityWr, String individualId, XC_REST_Lead_W.WrapperLeadResponse responseWrapper) {

        Map<Id, XC_LegalEntityConsent__c> legalEnMap = new Map<Id, XC_LegalEntityConsent__c>([SELECT Id, XC_LegalEntity__c FROM XC_LegalEntityConsent__c WHERE XC_Individual__c =: individualId]);
        Map<String, XC_LegalEntityConsent__c> entityMap = new Map<String, XC_LegalEntityConsent__c>();
        for(XC_LegalEntityConsent__c legEn : legalEnMap.values()) {
            entityMap.put(legEn.XC_LegalEntity__c, legEn);
        }

        List<XC_LegalEntityConsent__c> legalToUpsertList = new List<XC_LegalEntityConsent__c>();
        for(XC_UTIL_Lead.LegalEntityWrapper legalEn : legalEntityWr) {
            if(entityMap.containsKey(legalEn.LegalEntity)) {
                legalEn.LegalEntityID = entityMap.get(legalEn.LegalEntity).Id;
            }
            XC_LegalEntityConsent__c legToUpsert = XC_REST_Lead_W.generateLegalEntityFromWrapper(legalEn, individualId);
            legToUpsert.XC_FromAPI__c = true; //**per skippare duplicazione leagl entity */
            legalToUpsertList.add(legToUpsert);
        }

        List<XC_UTIL_Sobject.WrapperResult> resultUpsertLegEn = XC_UTIL_Sobject.upsertListRecords(legalToUpsertList);
        for(XC_UTIL_Sobject.WrapperResult res : resultUpsertLegEn) {
            if(!res.success) {
                responseWrapper.result.ErrorCode = '500';
                responseWrapper.result.Message = 'INTERNAL ERROR: ' + res.errorMessage;
                responseWrapper.result.logError = 'INTERNAL ERROR: ' + res.errorMessage;
                return;
            }
        }
    }
    

    /**
	 * ManageConvertLead.
	 *
     * @param lead the lead wrapper
     * @description manage convert Lead
	 */ 
	public static void manageConvertLead(XC_UTIL_Lead.LeadRESTWrapper leadWr, XC_REST_Lead_W.WrapperLeadResponse responseWrapper) {

        /*Lead existingLead = XC_REST_Lead_S.checkExistingLead(leadWr, responseWrapper);
        if(existingLead == null) {
            return;
        }*/

        system.debug('before XC_LCC122_LeadConversion.retrieveLead    '+system.datetime.now());

        XC_LCC122_LeadConversion.CheckResultWrapper validateForCoversionResult = XC_LCC122_LeadConversion.retrieveLead(leadWr.LeadID);
        if(validateForCoversionResult.isErrorValidation) {
            responseWrapper.Result.Message = 'ERROR in CovertLead: ' + validateForCoversionResult.errorMessage;
            responseWrapper.Result.ErrorCode = '500';
            return;
        }

        system.debug('before XC_LCC122_LeadConversion.conversionForRecordType    '+system.datetime.now());

        validateForCoversionResult.oppSecondaryContactConversion = true;
        validateForCoversionResult.createOpportunity = true;
        XC_LCC122_LeadConversion.ConversionResultWrapper conversionResult = XC_LCC122_LeadConversion.conversionForRecordType(JSON.serialize(validateForCoversionResult));
        if(conversionResult.success) {
            responseWrapper.Result.Message = 'Operation completed successfully';
            responseWrapper.Result.ErrorCode = '0';
            responseWrapper.Account = new XC_REST_Lead_W.WrapperAccount();
            responseWrapper.Account.AccountID = conversionResult.account.Id;
            responseWrapper.Account.ContactID = conversionResult.contact.Id;
            responseWrapper.Account.OpportunityID = conversionResult.opportunity.Id;
        } else {
            responseWrapper.Result.Message = 'ERROR in CovertLead: ' + conversionResult.errorMessage;
            responseWrapper.Result.ErrorCode = '500';
            return;
        }

        system.debug('after XC_LCC122_LeadConversion.conversionForRecordType    '+system.datetime.now());

        /*Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(existingLead.Id);  
        lc.setConvertedStatus('Closed - Converted');
        lc.setOwnerId(UserInfo.getUserId());
        if(String.isNotBlank(leadWr.AccountID)) {
            lc.setAccountId(leadWr.AccountID);
        }
        if(String.isNotBlank(leadWr.ContactID)) {
            lc.setContactId(leadWr.ContactID);
        }
        // Missing RecordType
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.debug('Convert result -> ' + lcr.isSuccess());

        if(lcr.isSuccess()) {
            responseWrapper.Result.Message = 'Operation completed successfully';
            responseWrapper.Result.ErrorCode = '0';
            responseWrapper.Account = new XC_REST_Lead_W.WrapperAccount();
            responseWrapper.Account.AccountID = lcr.getAccountId();
            responseWrapper.Account.ContactID = lcr.getContactId();
            responseWrapper.Account.OpportunityID = lcr.getOpportunityId();
        } else {
            responseWrapper.Result.Message = 'INTERNAL ERROR';
            responseWrapper.Result.ErrorCode = '500';
        }*/

        System.debug('AccountID converted -> ' + responseWrapper.Account.AccountID);
        System.debug('ContactID converted -> ' + responseWrapper.Account.ContactID);
        System.debug('OpportunityID converted -> ' + responseWrapper.Account.OpportunityID);
    }
}