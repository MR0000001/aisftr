/**
 * The Class XC_REST_Lead_S.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 08/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse for Create/Update Lead
 **/

    
public without sharing class XC_REST_Lead_S {
    
    
    /**
     * ValidateRequestPOS.
     *
     * @param validateResult the result of validation
     * @param leadWrapper the lead wrapper
     * @description validate pos section
     */
    public static void validateRequestPOS(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper) {

        Integer i = 1;
        List<XC_UTIL_Address.PoSWrapper> posList = (leadWrapper.Address.PointOfService != null) ? leadWrapper.Address.PointOfService : new List<XC_UTIL_Address.PoSWrapper>();
        for(XC_UTIL_Address.PoSWrapper pos : posList) {
            if(String.isBlank(pos.POSID) && String.isBlank(pos.POSType)) {
                validateResult.errorMessage = 'Missing mandatory field: Lead.Address.PointOfService.POSType in the ' + i + '-th PointOfService';
                validateResult.errorFlag = true;
                return;
            }
            if(String.isBlank(pos.POSID) && String.isBlank(pos.POS)) {
                validateResult.errorMessage = 'Missing mandatory field: Lead.Address.PointOfService.POS in the ' + i + '-th PointOfService';
                validateResult.errorFlag = true;
                return;
            }
            i++;
        }

    }


    /**
     * CheckAddress.
     *
     * @param validateResult the result of validation
     * @param leadWrapper the lead wrapper
     * @description check address
     */
    public static void checkAddress(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper) {
        
        if(String.isBlank(leadWrapper.Address.StreetType)) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.Address.StreetType';
            validateResult.errorFlag = true;
            return;
        }
        if(String.isBlank(leadWrapper.Address.Address)) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.Address.Address';
            validateResult.errorFlag = true;
            return;
        }
        if(String.isBlank(leadWrapper.Address.StreetNumber)) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.Address.StreetNumber';
            validateResult.errorFlag = true;
            return;
        }
        if(String.isBlank(leadWrapper.Address.ZipCode)) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.Address.ZipCode';
            validateResult.errorFlag = true;
            return;
        }
        if(String.isBlank(leadWrapper.Address.City)) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.Address.City';
            validateResult.errorFlag = true;
            return;
        }
        if(String.isBlank(leadWrapper.Address.Country)) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.Address.Country';
            validateResult.errorFlag = true;
            return;
        }

    }


    /**
     * ValidateRequestGDPR.
     *
     * @param validateResult the result of validation
     * @param leadWrapper the lead wrapper
     * @description validate GDPR section
     */
    public static void validateRequestGDPR(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String method) {

        if(method == 'POST') {
            if (leadWrapper.GDPR == null) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.GDPR';
                validateResult.errorFlag = true;
                return;
            }

            if (leadWrapper.GDPR.LegalEntity == null || leadWrapper.GDPR.LegalEntity.size() == 0) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.GDPR.LegalEntity';
                validateResult.errorFlag = true;
                return;
            }
        }

        if(leadWrapper.GDPR != null && leadWrapper.GDPR.LegalEntity != null) {
            validateRequestLegalEntity(validateResult, leadWrapper.GDPR.LegalEntity);
        }
    }


    /**
     * ValidateRequestLegalEntity.
     *
     * @param validateResult the result of validation
     * @param legalWrList the legal wrapper list
     * @description validate GDPR section
     */
    public static void validateRequestLegalEntity(XC_UTIL_Integration.WrapperResult validateResult, List<XC_UTIL_Lead.LegalEntityWrapper> legalWrList) {

        for (XC_UTIL_Lead.LegalEntityWrapper legalWr : legalWrList){
            Integer i = 1;

            if (String.isBlank(legalWr.LegalEntity)) {
                validateResult.errorMessage = 'Missing mandatory field: Lead.GDPR.LegalEntity.LegalEntity in the ' + i + '-th LegalEntity';
                validateResult.errorFlag = true;
                return;
            }

            if (String.isBlank(legalWr.GiveDataToLegalEntity)) {
                validateResult.errorMessage = 'Missing mandatory field: Lead.GDPR.LegalEntity.GiveDataToLegalEntity in the ' + i + '-th LegalEntity';
                validateResult.errorFlag = true;
                return;
            }
            
            if (legalWr.GiveDataToLegalEntity != 'Y') {
                validateResult.errorMessage = 'Lead.GDPR.LegalEntity.GiveDataToLegalEntity must be Y in the ' + i + '-th LegalEntity';
                validateResult.errorFlag = true;
                return;
            }

            i++;
        }
    }


    /**
     * CheckExistingLead.
     *
     * @param leadWrapperRequest the lead wrapper
     * @param responseWrapper the response wrapper
     * @return Lead the existingLead
     * @description check existing lead
     */
    public static Lead checkExistingLead(XC_UTIL_Lead.LeadRESTWrapper leadWrapperRequest, XC_REST_Lead_W.WrapperLeadResponse responseWrapper) {
    
        List<Lead> leadList = new List<Lead>();
        if(String.isBlank(leadWrapperRequest.LeadID)) {            
         
           
            // search by keys
            leadList = searchLeadbyKeys(leadWrapperRequest);
            System.debug('LeadList -> ' + leadList);
            if (leadList.isEmpty()) {
                responseWrapper.Result.Message = Label.XC_CL_LeadNotFound;
                responseWrapper.Result.ErrorCode = '400';
                return null;
                
            } else {
                leadWrapperRequest.LeadID = leadList[0].id; 
            }
            
        } else {
            
            // Check if the Lead exists
            Set<String> setFields = new Set<String>{'Id', 'FirstName', 'LastName', 'Status', 'XC_ProductCategoryOfInterest__c', 'XC_Segment__c'};
            leadList = (List<Lead>) XC_UTIL_Query.selectFieldsList(setFields, leadWrapperRequest.LeadID);
            if(leadList.size() == 0) {
                responseWrapper.Result.Message = Label.XC_CL_LeadNotFound;
                responseWrapper.Result.ErrorCode = '400';
                return null;
            }
        }

        return leadList[0];
    }


    /**
     * SearchLeadbyKeys.
     *
     * @param leadWrapperRequest the lead wrapper
     * @return the lead list
     * @description search lead by keys
     */
    public static List<Lead> searchLeadbyKeys(XC_UTIL_Lead.LeadRESTWrapper leadWrapperRequest) {

        Boolean whereCondition = false;

        String phone = leadWrapperRequest.Phone;
        String phonePrefix = leadWrapperRequest.PhonePrefix;
        String email = leadWrapperRequest.PrimaryEmail;
        String idNum = leadWrapperRequest.IdentityNumber;

        String query = 'SELECT Id, XC_Segment__c, FirstName, LastName, Status, XC_ProductCategoryOfInterest__c FROM Lead WHERE ';
        if (String.isNotBlank(leadWrapperRequest.Phone)) {
            query += 'XC_LeadPhone__c =: phone AND XC_PhonePrefix__c =: phonePrefix';
            whereCondition = true;
        }
        if (String.isNotBlank(leadWrapperRequest.PrimaryEmail)) {
            if(whereCondition) {
                query += ' AND Email =: email';
            } else {
                query += 'Email =: email';
                whereCondition = true;
            } 
        }
        if (String.isNotBlank(leadWrapperRequest.IdentityNumber)) {
            if(whereCondition) {
                query += ' AND XC_DocumentNumber__c =: idNum';
            } else {
                query += 'XC_DocumentNumber__c =: idNum';
                whereCondition = true;
            } 
        }
        
        return (List<Lead>) Database.query(String.escapeSingleQuotes(query));
    }

    /**
     * get lead.
     *
     * @param params the params
     * @return the lead wrapper
     * @description search lead by keys
     * @author Simone Trenta - strenta@deloitte.it
     */
    public static XC_REST_Lead_W.WrapperLeadResponse getLeadWrapper(Map<String,String> params, Map<String,String> header){
        XC_REST_Lead_W.WrapperLeadResponse result = new XC_REST_Lead_W.WrapperLeadResponse();

        List<Lead> leads = getLead(params); 
        if(leads.isEmpty()){
            result.Result.Message = 'ERROR. Lead ' + Label.XC_CL_NotFount; 
            result.Result.ErrorCode = '400';
            return result;
        }

        result.Result.Message = 'Operation completed successfully'; 
        result.Result.ErrorCode = '0';

        result.Lead = new XC_UTIL_Lead.LeadRESTWrapper();
        result.Lead.LeadID = leads[0].Id;
        result.Lead.LeadType = leads[0].RecordType.name;
        result.Lead.FirstName = leads[0].FirstName;
        result.Lead.LastName = leads[0].LastName;
        result.Lead.BusinessName = leads[0].Company;
        result.Lead.PhonePrefix = leads[0].XC_PhonePrefix__c;
        result.Lead.Phone = leads[0].XC_LeadPhone__c; 
        result.Lead.PrimaryEmail = leads[0].Email;
        result.Lead.ECID = leads[0].XC_Ecid__c;

        if(header.get('ClientSystem')=='XInstaller'){
            result.Lead.MobilePrefix = leads[0].XC_MobilePrefix__c;
            result.Lead.Mobile = leads[0].XC_LeadMobile__c;
        }

        /*
        result.Lead.IdentityCountry = leads[0].XC_CDocCountry__c;
        result.Lead.IdentityType = leads[0].XC_CDocType__c;
        result.Lead.IdentityNumber = leads[0].XC_CDocNumber__c;
		*/
        result.Lead.IdentityCountry = leads[0].XC_DocumentCountry__c;
        result.Lead.IdentityType = leads[0].XC_DocumentType__c;
        result.Lead.IdentityNumber = leads[0].XC_DocumentNumber__c;
        if (leads[0].XC_NIE_expedition_date__c != null){
            result.Lead.ReleaseDate = leads[0].XC_NIE_expedition_date__c+'';
        } 
        if (leads[0].XC_NIE_expiration_date__c != null){
            result.Lead.ExpiryDate = leads[0].XC_NIE_expiration_date__c+'';
        }
        result.Lead.Nationality = leads[0].XC_Nationality__c;
        if (leads[0].XC_Birthdate__c != null){
            result.Lead.Birthdate = leads[0].XC_Birthdate__c+'';
        }
        result.Lead.ReceivingChannel = leads[0].XC_Channel__c;
        result.Lead.Source = leads[0].XC_LeadSource__c;
        result.Lead.PreferenceLanguage = leads[0].XC_Preference_Language__c;
        result.Lead.ProductCategoryOfInterest = leads[0].XC_ProductCategoryOfInterest__c;
        result.Lead.CommercialVisitPreferredTime = leads[0].XC_HourToBeRecontacted__c;
        result.Lead.Notes = leads[0].XC_Notes__c;
        result.Lead.ZipCode = leads[0].XC_GenericZipCode__c;

        result.Lead.Address = new XC_UTIL_Address.AddressWrapper('REST');
        result.Lead.Address.AddressID = leads[0].Id;
        result.Lead.Address.Category = leads[0].XC_LeadAddress__r.XC_Category__c;
        result.Lead.Address.StreetType = leads[0].XC_LeadAddress__r.XC_StreetTypeText__c;
        result.Lead.Address.Address = leads[0].XC_LeadAddress__r.XC_Address__c;
        result.Lead.Address.StreetNumber = leads[0].XC_LeadAddress__r.XC_StreetNumber__c;
        result.Lead.Address.ZipCode = leads[0].XC_LeadAddress__r.XC_PostalCode__c;
        result.Lead.Address.City = leads[0].XC_LeadAddress__r.XC_City__c;
        result.Lead.Address.Country  = leads[0].XC_LeadAddress__r.XC_AddressCountry__c;
        result.Lead.Address.Stair = leads[0].XC_LeadAddress__r.XC_Stair__c;
        result.Lead.Address.Floor = leads[0].XC_LeadAddress__r.XC_Floor__c;
        result.Lead.Address.Door = leads[0].XC_LeadAddress__r.XC_Door__c;
        result.Lead.Address.Province = leads[0].XC_LeadAddress__r.XC_AddressProvince__c;
        result.Lead.Address.MunicipalName = leads[0].XC_LeadAddress__r.XC_Municipality__c;
        result.Lead.Address.ShippingAddress = leads[0].XC_LeadAddress__r.XC_DeliveryAddress__c;
        result.Lead.Address.BillingAddress = leads[0].XC_LeadAddress__r.XC_BillingAddress__c;
        result.Lead.Address.InstallationAddress = leads[0].XC_LeadAddress__r.XC_InstallationAddress__c;
        result.Lead.Address.AddressValidated = leads[0].XC_LeadAddress__r.XC_AddressValidated__c;
        result.Lead.Address.Region = leads[0].XC_LeadAddress__r.XC_Region__c;

        List<XC_LegalEntityConsent__c> cons;
        if(!String.isBlank(leads[0].IndividualId)){
            cons = getLegalEntities(leads[0].IndividualId);
            if(!cons.isEmpty()){
                result.Lead.GDPR = new XC_UTIL_Lead.gdprWrapper();
                result.Lead.GDPR.GiveDataToThirdParties = leads[0].Individual.XC_GiveDataToThirdParties__c;
                result.Lead.GDPR.VersionConsentThirdParty = leads[0].Individual.XC_ThirdPartyConsentVersion__c;
                result.Lead.GDPR.ConsentThirdPartyDate = leads[0].Individual.XC_CollectionDateThirdParties__c;
                result.Lead.GDPR.RobinsonCustomer = XC_UTIL_Integration.convertFromBooleanToString(leads[0].Individual.XC_RobinsonCustomer__c);
                result.Lead.GDPR.LegalEntity = new List<XC_UTIL_Lead.LegalEntityWrapper>();
                for(XC_LegalEntityConsent__c c : cons){
                    XC_UTIL_Lead.LegalEntityWrapper leg = new XC_UTIL_Lead.LegalEntityWrapper(); 
                    leg.LegalEntity = c.XC_LegalEntity__c;
                    leg.GiveDataToLegalEntity = c.XC_GiveDataToNew__c =='Yes'? 'Y':'N' ;
                    leg.GiveDataForMarketing = c.XC_MarketingConsent__c =='Yes'? 'Y':'N' ;
                    leg.GiveDataForProfiling = c.XC_ProfilingConsent__c=='Yes'? 'Y':'N' ;
                    leg.Country = c.XC_LeCountry__c;
                    leg.VersionConsentCompany = c.XC_CompanyConsentVersion__c;
                    //leg.ConsentCompanyDate
                    leg.VersionConsentMarketing = c.XC_MarketingConsentVersion__c;
                    leg.ConsentMarketingDate = c.XC_CollectionDateMarketing__c;
                    leg.VersionConsentForProfiling = c.XC_ProfilingConsentVersion__c;
                    leg.ConsentProfilingDate = c.XC_CollectionDateProfiling__c;
                    //leg.PreferredContactMethod
                     leg.GiveDataForNotCustomer = c.XC_NotCustomerConsent__c;
                     leg.GiveDataForThirdProductMarketing = c.XC_ThirdProductsMarketingConsent__c;
                     leg.VersionConsentNotCustomer = c.XC_NotCustomerConsentVersion__c;
                     leg.ConsentNotCustomerDate = c.XC_CollectionDateNotCustomer__c;
                     leg.VersionConsentThirdProductMarketing = c.XC_ThirdProductsMarketingConsentVersion__c;
                     leg.ConsentThirdProductMarketingDate = c.XC_CollectionDateThirdProductsMarketing__c;
                    result.Lead.GDPR.LegalEntity.add(leg);
                }
            }
        }
        
        List<XC_PointOfService__c> pos;
        if(!String.isBlank(leads[0].XC_LeadAddress__c)){
            pos = getPosFields(leads[0].XC_LeadAddress__c);
            if(!pos.isEmpty()){
                result.Lead.Address.PointOfService = new List<XC_UTIL_Address.PoSWrapper>();
                for(XC_PointOfService__c p : pos){
                    XC_UTIL_Address.PoSWrapper point = new XC_UTIL_Address.PoSWrapper();
                    point.POS = p.Name;
                    point.POSType = p.XC_Type__c;
                    result.Lead.Address.PointOfService.add(point);
                }
            }
        }


        return result;
    }
    


    private static List<Lead> getLead(Map<String,String> params){

        String leadFields = 
            'Id, RecordType.name, FirstName, LastName, Company, XC_PhonePrefix__c, XC_GenericZipCode__c, '+
            'XC_LeadPhone__c, Email, XC_CDocCountry__c, XC_CDocType__c, XC_CDocNumber__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c, '+
            'XC_ContacDocumentReleaseDate__c, XC_ContactDocumentExpirationDate__c, XC_Nationality__c, '+
            'XC_Birthdate__c, XC_Channel__c, XC_LeadSource__c, XC_Preference_Language__c, '+
            'XC_ProductCategoryOfInterest__c, XC_HourToBeRecontacted__c, XC_Notes__c, '+
            'XC_LeadAddress__c, XC_LeadAddress__r.XC_Category__c, XC_LeadAddress__r.XC_StreetTypeText__c, '+
            'XC_LeadAddress__r.XC_Address__c, XC_LeadAddress__r.XC_StreetNumber__c, XC_LeadAddress__r.XC_Region__c,'+
            'XC_LeadAddress__r.XC_PostalCode__c, XC_LeadAddress__r.XC_City__c, '+
            'XC_LeadAddress__r.XC_AddressCountry__c, XC_LeadAddress__r.XC_Stair__c, '+ 
            'XC_LeadAddress__r.XC_Floor__c, XC_LeadAddress__r.XC_Door__c, '+
            'XC_LeadAddress__r.XC_AddressProvince__c, XC_LeadAddress__r.XC_Municipality__c,'+
            'XC_LeadAddress__r.XC_DeliveryAddress__c, XC_LeadAddress__r.XC_BillingAddress__c, XC_LeadMobile__c, XC_MobilePrefix__c, '+
            'XC_LeadAddress__r.XC_InstallationAddress__c, IndividualId, XC_LeadAddress__r.XC_AddressValidated__c, XC_DocumentType__c, XC_DocumentCountry__c, XC_DocumentNumber__c, '+
            'Individual.XC_GiveDataToThirdParties__c, Individual.XC_ThirdPartyConsentVersion__c, Individual.XC_CollectionDateThirdParties__c, Individual.XC_RobinsonCustomer__c, XC_Ecid__c ';


        String conditions = '';

        if(!String.isBlank(params.get('LeadID'))){
            String leadIdStr = params.get('LeadID');
            conditions = 'Id =: leadIdStr';

        } else if(!String.isBlank(params.get('PrimaryEmail'))) {
            String emailStr = params.get('PrimaryEmail');
            conditions = 'Email =: emailStr';

        } else if(!String.isBlank(params.get('PhonePrefix'))&&!String.isBlank(params.get('Phone'))) {
            String phoneStr = params.get('PhonePrefix').replace(' ','+')+''+params.get('Phone');
            conditions = 'phone =: phoneStr';

        } else if(!String.isBlank(params.get('IdentityNumber'))) {
            String indentityStr = params.get('IdentityNumber');
            conditions = 'XC_DocumentNumber__c =: indentityStr';
        } 

        String queryString =  'SELECT '+ leadFields + ' '+
                    'FROM Lead WHERE '+ conditions;
        return Database.query( String.escapeSingleQuotes(queryString) );
    }
    


    private static List<XC_LegalEntityConsent__c> getLegalEntities(String indivId){
        String queryString = 
             'SELECT XC_LeCountry__c, XC_MarketingConsentVersion__c, XC_ProfilingConsentVersion__c, XC_IndividualLegalEntity__c, XC_LegalEntity__c, XC_MarketingConsent__c, XC_ProfilingConsent__c, XC_GiveDataToNew__c, XC_CollectionDateMarketing__c, XC_CompanyConsentVersion__c, XC_CollectionDateProfiling__c, XC_NotCustomerConsent__c, XC_ThirdProductsMarketingConsent__c, XC_NotCustomerConsentVersion__c, XC_CollectionDateNotCustomer__c, XC_ThirdProductsMarketingConsentVersion__c, XC_CollectionDateThirdProductsMarketing__c ' +
            'FROM XC_LegalEntityConsent__c ' + 'WHERE XC_Individual__c=:indivId'; 
        return Database.query( String.escapeSingleQuotes(queryString) );
    }
        


    private static List<XC_PointOfService__c> getPosFields(String addressId){
        String queryString = 
            'SELECT Id, Name, XC_Type__c ' +
            'FROM XC_PointOfService__c WHERE XC_Address__c=:addressId'; 
        return Database.query( String.escapeSingleQuotes(queryString) );
    }
    
}