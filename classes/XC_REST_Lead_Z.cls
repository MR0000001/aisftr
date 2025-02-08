/**
 * The Class XC_REST_Lead_Z.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 08/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Rest Resourse for Create/Update Lead
 **/


public without sharing class XC_REST_Lead_Z {
    
    
    /**
     * ValidateRequestLeadParameters2.
     *
     * @param validateResult the result of validation
     * @param leadWrapper the lead wrapper
     * @param method the http method
     * @description validate request lead parameters
     */
    public static void validateRequestLeadParameters2(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String method) {

        if (String.isNotBlank(leadWrapper.ReleaseDate) && !XC_UTIL_RESTInbound.checkDate(leadWrapper.ReleaseDate)) {
            validateResult.errorMessage = 'Wrong format of the field Lead.IdentityReleaseDate';
            validateResult.errorFlag = true;
            return;
        }

        if (String.isNotBlank(leadWrapper.ExpiryDate) && !XC_UTIL_RESTInbound.checkDate(leadWrapper.ExpiryDate)) {
            validateResult.errorMessage = 'Wrong format of the field Lead.IdentityExpiryDate';
            validateResult.errorFlag = true;
            return;
        }

        if (String.isNotBlank(leadWrapper.BirthDate) && !XC_UTIL_RESTInbound.checkDate(leadWrapper.BirthDate)) {
            validateResult.errorMessage = 'Wrong format of the field Lead.BirthDate';
            validateResult.errorFlag = true;
            return;
        }
    }


    /**
     * ValidateRequestLeadParameters3.
     *
     * @param validateResult the result of validation
     * @param leadWrapper the lead wrapper
     * @param method the http method
     * @description validate request lead parameters
     */
    public static void validateRequestLeadParameters3(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String method) {

        if (method == 'PUT' && String.isBlank(leadWrapper.LeadID) && String.isBlank(leadWrapper.Phone) && String.isBlank(leadWrapper.PrimaryEmail) && String.isBlank(leadWrapper.IdentityNumber)) {
            validateResult.errorMessage = 'Missing mandatory field: Lead.LeadID, Lead.Phone, Lead.PrimaryEmail or Lead.IdentityNumber';
            validateResult.errorFlag = true;
            return;
        }

        if (String.isBlank(leadWrapper.PhonePrefix) && String.isNotBlank(leadWrapper.Phone)) {
            validateResult.errorMessage = 'Missing mandatory field: Lead.PhonePrefix';
            validateResult.errorFlag = true;
            return;
        }
    }


    /**
     * ValidateRequestIdentity.
     *
     * @param validateResult the result of validation
     * @param leadWrapper the lead wrapper
     * @param method the http method
     * @description validate identity section
     */
    public static void validateRequestIdentity(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String method) {

        if(leadWrapper.Identity != null && !leadWrapper.Identity.isEmpty()) {
            Integer i = 1;
            for(XC_UTIL_Account.IdentityIFWrapper idWr : leadWrapper.Identity) {
                validateRequestSingleIdentity(validateResult, idWr, i);
                if(validateResult.errorFlag) {
                    return;
                }
                i++;
            }

        } /*else if(method == 'POST' && leadWrapper.LeadType == 'Small Business'){
            validateResult.errorMessage = 'Identity section must be filled for LeadType ' + leadWrapper.LeadType;
            validateResult.errorFlag = true;
            return;
        }*/
    }


    /**
     * ValidateRequestSingleIdentity.
     *
     * @param validateResult the result of validation
     * @param idWr the identity wrapper
     * @param i the counter
     * @description validate single identity wrapper
     */
    public static void validateRequestSingleIdentity(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Account.IdentityIFWrapper idWr, Integer i) {
        if(String.isBlank(idWr.IdentityID) && String.isBlank(idWr.IdentityType)) {
            validateResult.errorMessage = 'Missing mandatory field: Lead.Identity.IdentityType in the ' + i + '-th Identity';
            validateResult.errorFlag = true;
            return;
        }
        if(String.isBlank(idWr.IdentityID) && String.isBlank(idWr.IdentityNumber)) {
            validateResult.errorMessage = 'Missing mandatory field: Lead.Identity.IdentityNumber in the ' + i + '-th Identity';
            validateResult.errorFlag = true;
            return;
        }
        if(String.isNotBlank(idWr.ReleaseDate) && !XC_UTIL_RESTInbound.checkDate(idWr.ReleaseDate)) {
            validateResult.errorMessage = 'Wrong format of the field Lead.Identity.ReleaseDate in the ' + i + '-th Identity';
            validateResult.errorFlag = true;
            return;
        }
        if(String.isNotBlank(idWr.ExpiryDate) && !XC_UTIL_RESTInbound.checkDate(idWr.ExpiryDate)) {
            validateResult.errorMessage = 'Wrong format of the field Lead.Identity.ExpiryDate in the ' + i + '-th Identity';
            validateResult.errorFlag = true;
            return;
        }
    }

    
    /**
     * ValidateRequestAddress.
     *
     * @param validateResult the result of validation 
     * @param leadWrapper the lead wrapper
     * @description validate address section
     */
    public static void validateRequestAddress(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper) {
        
        if(String.isBlank(leadWrapper.Address.AddressID)) {
            XC_REST_Lead_S.checkAddress(validateResult, leadWrapper); 
            if(validateResult.errorFlag) { 
                return;
            }
        }
        
        XC_REST_Lead_S.validateRequestPOS(validateResult, leadWrapper);
    }

    /**
     * checkLeadBlacklist.
     * @author            : Giuseppe Di Bonito - gdibonito@deloitte.it
     * @date Creation     : 26/03/2020
     * @param validateResult the result of validation 
     * @param leadWrapper the lead wrapper
     * @description validate zipcode
     */
    public static void checkLeadBlacklist(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String method) {
        
        List<XC_UTIL_ZipCodeBlacklist.InputWrapper> blist = new List<XC_UTIL_ZipCodeBlacklist.InputWrapper>();
        XC_UTIL_ZipCodeBlacklist.InputWrapper b = new XC_UTIL_ZipCodeBlacklist.InputWrapper();      
        Map<XC_UTIL_ZipCodeBlacklist.InputWrapper,Boolean> breturn = new Map<XC_UTIL_ZipCodeBlacklist.InputWrapper,Boolean>();
        String legalEntity = '';
        String stream = '';

        if(method == 'POST' && !String.isblank(leadWrapper.ZipCode) && !String.isblank(leadWrapper.ProductCategoryOfInterest)){
            b.productCategoryOfInterest = leadWrapper.ProductCategoryOfInterest;
            b.zipCode = leadWrapper.ZipCode;
            legalEntity = leadWrapper.GDPR.LegalEntity[0].LegalEntity;
            stream = (String.isNotBlank(leadWrapper.Stream)) ? leadWrapper.Stream : 'B2C';
            blist.add(b);        

        } else if(method == 'PUT'){
            Boolean z = String.isblank(leadWrapper.ZipCode);
            Boolean p = String.isblank(leadWrapper.ProductCategoryOfInterest);
            Boolean l = (leadWrapper.GDPR == null || leadWrapper.GDPR.LegalEntity == null || leadWrapper.GDPR.LegalEntity.isEmpty() || String.isblank(leadWrapper.GDPR.LegalEntity[0].LegalEntity));
            
            if(z && p && l){
                return;
            
            } else if(!z && !p && !l){
                b.productCategoryOfInterest = leadWrapper.ProductCategoryOfInterest;
                b.zipCode = leadWrapper.ZipCode;
                legalEntity = leadWrapper.GDPR.LegalEntity[0].LegalEntity;
                blist.add(b);

                Map<Id, Lead> mapLead =  new Map<Id, Lead>([SELECT id, XC_Segment__c 
                                                            FROM Lead 
                                                            WHERE (Id =: leadWrapper.LeadID)
                                                            OR ((XC_PhonePrefix__c =: leadWrapper.PhonePrefix AND XC_PhonePrefix__c != null) AND XC_LeadPhone__c =: leadWrapper.Phone AND XC_LeadPhone__c != null) 
                                                            OR (Email =: leadWrapper.PrimaryEmail AND Email != null)
                                                            OR (XC_DocumentNumber__c =: leadWrapper.IdentityNumber AND XC_DocumentNumber__c!= null)]);
                stream = mapLead.values()[0].XC_Segment__c;
                                                    
            } else{
                Map<Id, Lead> mapLead =  new Map<Id, Lead>([SELECT id, XC_GenericZipCode__c, XC_ProductCategoryOfInterest__c, XC_MainLegalEntity__c, XC_Segment__c 
                                                            FROM Lead 
                                                            WHERE (Id =: leadWrapper.LeadID)
                                                            OR ((XC_PhonePrefix__c =: leadWrapper.PhonePrefix AND XC_PhonePrefix__c != null) AND XC_LeadPhone__c =: leadWrapper.Phone AND XC_LeadPhone__c != null) 
                                                            OR (Email =: leadWrapper.PrimaryEmail AND Email != null)
                                                            OR (XC_DocumentNumber__c =: leadWrapper.IdentityNumber AND XC_DocumentNumber__c!= null)]);
                stream = mapLead.values()[0].XC_Segment__c;
                if(z){
                    if(!String.isblank(mapLead.values()[0].XC_GenericZipCode__c)){
                        b.zipCode = mapLead.values()[0].XC_GenericZipCode__c;
                    } else {
                        return;
                    }
                } else{
                    b.zipCode = leadWrapper.ZipCode;
                }
                if(p){
                    if(!String.isblank(mapLead.values()[0].XC_ProductCategoryOfInterest__c)){
                        b.productCategoryOfInterest = mapLead.values()[0].XC_ProductCategoryOfInterest__c;
                    } else {
                        return;
                    }
                } else {
                    b.productCategoryOfInterest = leadWrapper.ProductCategoryOfInterest;
                }
                if(l){
                    legalEntity = mapLead.values()[0].XC_MainLegalEntity__c;
                } else {
                    legalEntity = leadWrapper.GDPR.LegalEntity[0].LegalEntity;
                }
                blist.add(b);
            }
        } else{
            return;
        }
        breturn = XC_UTIL_ZipCodeBlacklist.checkZipBlacklist(blist, legalEntity, stream);
        if(breturn.get(b)) {
            validateResult.errorMessage = 'Product category of Interest selected is in blacklist for the zipcode provided';
            validateResult.errorCode = '492';
            validateResult.errorFlag = true;
            return;
        }
    }

    /**
     * checkSector.
     * @author            : Giuseppe Di Bonito - gdibonito@deloitte.it
     * @date Creation     : 21/07/2020
     * @param validateResult the result of validation 
     * @param leadWrapper the lead wrapper
     * @description validate sector
     */
    public static void checkSector(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper) {

        if(String.isBlank(leadWrapper.CompanySectorLev1) || String.isBlank(leadWrapper.CompanySectorLev2) || String.isBlank(leadWrapper.Salutation)){

            validateResult.errorMessage = 'Missing mandatory field: Lead.CompanySectorLev1, Lead.CompanySectorLev2 or Lead.Salutation for Lead.LeadType = \'B2B\' or \'B2G\'';
            validateResult.errorFlag = true;
        }
    }
}