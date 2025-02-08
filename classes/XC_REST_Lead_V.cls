/**
 * The Class XC_REST_Lead_V.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 24/04/2019
 * @date Modification : 14/04/209 - Marco Ottaviano mottaviano@deloitte.it
 * @description       : Rest Resourse for Create/Update Lead
 **/


public without sharing class XC_REST_Lead_V {


    /**
     * Validate request.
     *
     * @param mapHeader the map header
     * @param wrReq the wr req
     * @param method the method
     * @return the Wrapper Result
     * @description validate request
     */
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, XC_REST_Lead_W.WrapperLeadRequest wrReq, String method) {		
        XC_UTIL_Integration.WrapperResult validateResult;
		validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
		if(validateResult.errorFlag) {
            return validateResult; 
        }
        
        if(method == 'PUT' && mapHeader.get('Operation') != 'Update' && mapHeader.get('Operation') != 'Convert') {
            validateResult.errorMessage = 'Wrong Operation value \'' + mapHeader.get('Operation') + '\'';
            validateResult.errorFlag = true;
            return validateResult;
        }

        validateResult = validateRequestLead(wrReq.Lead, method, mapHeader);
        return validateResult;
    }


    /**
     * ValidateRequestLead.
     *
     * @param leadWrapper the lead wrapper
     * @param method the method of request
     * @param mapHeader the header map
     * @return the Wrapper Result
     * @description validate request Lead
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestLead(XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String method, Map<String, String> mapHeader) {	

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
        
        // Lead
        if (leadWrapper == null) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead';
            validateResult.errorFlag = true;
            return validateResult;
        }

        validateRequestLeadParameters(validateResult, leadWrapper, method);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        /*  Duplicate control on ProductCategoryOfInterest. Comment of Marco Ottaviano - maottaviano@deloitte.it
        if (method == 'POST' && String.isBlank(leadWrapper.ProductCategoryOfInterest) && mapHeader.get('ClientSystem') == 'CommoditySpainB2C') {
            validateResult.errorMessage = 'Missing mandatory field: Lead.ProductCategoryOfInterest';
            validateResult.errorFlag = true;
            return validateResult;
        }
        */

        //BlacklistCheck GDB 26/03/2020
        XC_REST_Lead_Z.checkLeadBlacklist(validateResult, leadWrapper, method);
        if(validateResult.errorFlag) {
            return validateResult;    
        }

        // Identity
        XC_REST_Lead_Z.validateRequestIdentity(validateResult, leadWrapper, method);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        // Address
        if(leadWrapper.Address != null) {
            XC_REST_Lead_Z.validateRequestAddress(validateResult, leadWrapper);
            if(validateResult.errorFlag) {
                return validateResult;
            }
        }

        // Sector
        if(method == 'POST' && (leadWrapper.LeadType == 'B2B' || leadWrapper.LeadType == 'B2G')) {
            XC_REST_Lead_Z.checkSector(validateResult, leadWrapper);
            if(validateResult.errorFlag) {
                return validateResult;
            }
        }

        return validateResult;
    }


    /**
     * ValidateRequestLeadParameters.
     *
     * @param validateResult the result of validation
     * @param leadWrapper the lead wrapper
     * @param method the http method
     * @description validate request lead parameters
     */
    public static void validateRequestLeadParameters(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String method) {	

        Map<String, String> requiredParameters = new Map<String, String>{'LeadType' => leadWrapper.LeadType,
                                                                            'LastName' => leadWrapper.LastName,
                                                                            'FirstName' => leadWrapper.FirstName,
                                                                            'ReceivingChannel' => leadWrapper.ReceivingChannel/*,
                                                                            'ProductCategoryOfInterest' => leadWrapper.ProductCategoryOfInterest*/  // NM 29.06.2020 ALM 4691
                                                                            };
        for(String key : requiredParameters.keySet()) {
            if (method == 'POST' && String.isBlank(requiredParameters.get(key))) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.' + key;
                validateResult.errorFlag = true;
                return;
            } else if (method == 'PUT' && requiredParameters.get(key) != null && requiredParameters.get(key).isWhiteSpace()) {
                validateResult.errorMessage = 'Lead.' + key + Label.XC_CL_CanNotEmpty;
                validateResult.errorFlag = true;
                return;
            }
        }

        validateOtherLeadParameters(validateResult, leadWrapper, method);
        if(validateResult.errorFlag) {
            return;
        }
        
        // GDPR
        XC_REST_Lead_S.validateRequestGDPR(validateResult, leadWrapper, method);
    }

    
    /**
     * ValidateOtherLeadParameters.
     *
     * @param validateResult the result of validation
     * @param leadWrapper the lead wrapper
     * @param method the http method
     * @description validate request lead parameters
     */
    public static void validateOtherLeadParameters(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String method) {

        validateRequestLeadParameters1(validateResult, leadWrapper, method);
        if(validateResult.errorFlag) {
            return;
        }

        XC_REST_Lead_Z.validateRequestLeadParameters2(validateResult, leadWrapper, method);
        if(validateResult.errorFlag) {
            return;
        }

        XC_REST_Lead_Z.validateRequestLeadParameters3(validateResult, leadWrapper, method);
        if(validateResult.errorFlag) {
            return;
        }

        if (String.isBlank(leadWrapper.IdentityType) && String.isNotBlank(leadWrapper.IdentityNumber)) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.IdentityType';
            validateResult.errorFlag = true;
            return;
        }

        if (method == 'POST' && String.isBlank(leadWrapper.IdentityCountry) && String.isNotBlank(leadWrapper.IdentityType)) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.IdentityCountry';
            validateResult.errorFlag = true;
            return;
        }

        if (method == 'POST' && String.isBlank(leadWrapper.IdentityCountry) && String.isBlank(leadWrapper.IdentityType) && String.isBlank(leadWrapper.IdentityNumber) && leadWrapper.LeadType == 'Small Business'){
            validateResult.errorMessage = 'Identity fields must be filled for LeadType ' + leadWrapper.LeadType;
            validateResult.errorFlag = true;
            return;
        }

    }

    /**
     * ValidateRequestLeadParameters1.
     *
     * @param validateResult the result of validation
     * @param leadWrapper the lead wrapper
     * @param method the http method
     * @description validate request lead parameters
     */
    public static void validateRequestLeadParameters1(XC_UTIL_Integration.WrapperResult validateResult, XC_UTIL_Lead.LeadRESTWrapper leadWrapper, String method) {

        if (method == 'POST') {

            if(leadWrapper.LeadType == Label.XC_CL_Lead_TypeSmallBusiness) {
                if (String.isBlank(leadWrapper.BusinessName)) {
                    validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.BusinessName';
                    validateResult.errorFlag = true;
                    return;
                }

                if (String.isBlank(leadWrapper.PrimaryEmail)) {
                    validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.PrimaryEmail for LeadType ' + Label.XC_CL_Lead_TypeSmallBusiness;
                    validateResult.errorFlag = true;
                    return;
                }

                if (String.isBlank(leadWrapper.IdentityNumber)) {
                    validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.IdentityNumber for LeadType ' + Label.XC_CL_Lead_TypeSmallBusiness;
                    validateResult.errorFlag = true;
                    return;
                }
            
            } else if (String.isBlank(leadWrapper.PrimaryEmail) && String.isBlank(leadWrapper.Phone)) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Lead.PrimaryEmail or Lead.Phone';
                validateResult.errorFlag = true;
                return;
            }
        }
    
    }   
    
    public static XC_UTIL_Integration.WrapperResult validateGetRequest(Map<String, String> mapHeader, Map<String, String> requestParams){

        // Validate Header
        XC_UTIL_Integration.WrapperResult validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult; 
        }
        
        // Validate Query String Parameters
        if (String.isblank(requestParams.get('LeadID')) & 
            String.isblank(requestParams.get('PrimaryEmail')) & 
            (String.isblank(requestParams.get('PhonePrefix')) || String.isblank(requestParams.get('Phone'))) & 
            (String.isblank(requestParams.get('IdentityCountry')) || String.isblank(requestParams.get('IdentityType')) || String.isblank(requestParams.get('IdentityNumber')))) {
              validateResult.errorMessage = 'ERROR. Missing one of this fields: LeadId or PrimaryEmail or (PhonePrefix and Phone) or (IdentityCountry and IdentityType and IdentityNumber)';
              validateResult.errorFlag = true; 
        }      
        return validateResult;
    }
    
}