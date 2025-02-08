/**
 * The Class XC_REST_Account_VV.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 07/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_Account
 * 
 */

public without sharing class XC_REST_Account_VV {


    /**
     * ValidateRequestGET.
     *
     * @param mapHeader the map header
     * @param requestParams the request map
     * @return the wrapper result
     * @description method to verify if Header and other Section required parameters are correctly filled
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestGET(Map<String, String> mapHeader, Map<String, String> requestParams){

        XC_UTIL_Integration.WrapperResult validateResult;
        
        // Validate Header
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        // Validate Query String Parameters
        Map<String, String> requiredParameters = new Map<String, String>{'AccountID' => requestParams.get('AccountID'),
                                                                        'PrimaryEmail' => requestParams.get('PrimaryEmail'),
                                                                        'IdentityNumber' => requestParams.get('IdentityNumber')
                                                                        };

        Boolean checkParams = false;
        for(String key : requiredParameters.keySet()) {
            if(String.isNotBlank(requiredParameters.get(key))) {
                checkParams = true;
            }   
        }
        validateResult = validateParamsGET(mapHeader, requestParams, checkParams);
        
        
        return validateResult;
    }


    /**
     * ValidateParamsGET.
     *
     * @param mapHeader the map header
     * @param requestParams the request params
     * @param checkParams the boolean
     * @return the wrapper result
     * @description method to verify if query string parameters are correctly filled
     */
    public static XC_UTIL_Integration.WrapperResult validateParamsGET(Map<String, String> mapHeader, Map<String, String> requestParams, Boolean checkParams){

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        List<String> clientSystem = new List<String>{'XInstaller', 'E-Commerce', 'Partner'};
            
        if(mapHeader.get('ClientSystem') == 'CommoditySpainB2C' && String.isBlank(requestParams.get('IdentityNumber'))) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField+' IdentityNumber';
            validateResult.errorFlag = true;
            return validateResult;
        }
        
        if(mapHeader.get('ClientSystem') == 'XRecharge' && String.isBlank(requestParams.get('CompanyCode')) && !checkParams) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField+' AccountID, PrimaryEmail, IdentityNumber or CompanyCode';
            validateResult.errorFlag = true;
            return validateResult;
        } 

        if(clientSystem.contains(mapHeader.get('ClientSystem')) && !checkParams) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField+' AccountID, PrimaryEmail or IdentityNumber';
            validateResult.errorFlag = true;
            return validateResult;
        }

        return validateResult;
    }


    /**
     * ValidateRequestAccount.
     *
     * @param acc the account
     * @param method the method
     * @return the wrapper result
     * @description method to verify if Account required parameters are correctly filled
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestAccount(XC_UTIL_Account.AccountIFWrapper acc, String method, String clientSystem) {
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        if(acc == null){
            validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(method == 'POST') {
            
            // for commodity
            if(clientSystem == Label.XC_CL_CommoditySpainB2C){
               acc.AccountType = (String.isBlank(acc.FirstName)) ? 'Small Business' : (String.isBlank(acc.AccountType)) ? 'Residential' : acc.AccountType;
            }

            if(String.isBlank(acc.AccountType)) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.AccountType';
                validateResult.errorFlag = true;
                return validateResult;
            } 

            if(String.isBlank(acc.LastName) && (acc.AccountType != 'B2B' && acc.AccountType != 'B2G')) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.LastName';
                validateResult.errorFlag = true;
                return validateResult;
            }
            
            if(String.isNotBlank(acc.LastName)){
                acc.LastName = XC_UTIL_String.removeDiacritics(acc.LastName);
                acc.LastName = acc.LastName.replaceAll('[^A-Za-z0-9 \\-?:().,\'+\\s+]', '');
                acc.LastName = acc.LastName.normalizeSpace();
                if(acc.LastName.length() == 1){
                    acc.LastName = acc.LastName + acc.LastName;
                }
            }

            validateRequestAccountPOSTforType(acc, validateResult, clientSystem);

        } else if (method == 'PUT') {
            if(String.isBlank(acc.AccountID) &&  String.isBlank(acc.PrimaryEmail) ){
                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.AccountID or Account.PrimaryEmail';
                validateResult.errorFlag = true;
                return validateResult;
            }

            if(String.isNotBlank(acc.LastName)){
                acc.LastName = XC_UTIL_String.removeDiacritics(acc.LastName);
                acc.LastName = acc.LastName.replaceAll('[^A-Za-z0-9 \\-?:().,\'+\\s+]', '');
                acc.LastName = acc.LastName.normalizeSpace();
                if(acc.LastName.length() == 1){
                    acc.LastName = acc.LastName + acc.LastName;
                }
            }

            if(String.isNotBlank(acc.FirstName)){
                acc.FirstName = XC_UTIL_String.removeDiacritics(acc.FirstName);
                acc.FirstName = acc.FirstName.replaceAll('[^A-Za-z0-9 \\-?:().,\'+\\s+]', '');
                acc.FirstName = acc.FirstName.normalizeSpace();
                if(acc.FirstName.length() == 1){
                    acc.FirstName = acc.FirstName + acc.FirstName;
                }
            }
        }
        
        return validateResult;
    }


    /**
     * ValidateRequestAccountPOSTforType.
     *
     * @param acc the account
     * @param validateResult the result
     * @description method to verify if Account required parameters are correctly filled for POST method and Account type
     */
    public static void validateRequestAccountPOSTforType(XC_UTIL_Account.AccountIFWrapper acc, XC_UTIL_Integration.WrapperResult validateResult, String clientSystem) {

        if(acc.AccountType == 'Residential') {

            if(String.isBlank(acc.FirstName)) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.FirstName';
                validateResult.errorFlag = true;
                return;
            }
            
            
		    acc.FirstName = XC_UTIL_String.removeDiacritics(acc.FirstName);
            acc.FirstName = acc.FirstName.replaceAll('[^A-Za-z0-9 \\-?:().,\'+\\s+]', '');
            acc.FirstName = acc.FirstName.normalizeSpace();
            if(acc.FirstName.length() == 1){
                acc.FirstName = acc.FirstName + acc.FirstName;
            }

            if(String.isBlank(acc.PrimaryEmail) && String.isBlank(acc.MainPhone)) {
                if(clientSystem == Label.XC_CL_CommoditySpainB2C){
                    acc.MainPhonePrefix = '+34';
                    acc.MainPhone = '000000000';
                } else{
                    validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.PrimaryEmail or Account.MainPhone';
                    validateResult.errorFlag = true;
                    return;
                }
                
            }

            if(!String.isBlank(acc.MainPhone) && String.isBlank(acc.MainPhonePrefix)) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.MainPhonePrefix';
                validateResult.errorFlag = true;
                return;
            }
        }

        if(acc.AccountType == 'Partner' && String.isBlank(acc.PartnerID)) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.PartnerID';
            validateResult.errorFlag = true;
            return;
        }

        //B2B2G Validations
        if(acc.AccountType == 'B2B' || acc.AccountType == 'B2G') {

            if(String.isBlank(acc.Name)) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.Name';
                validateResult.errorFlag = true;
                return;
            }

            acc.Stream = acc.AccountType;
            acc.LastName = acc.Name;

            if(String.isBlank(acc.PrimaryEmail) && (String.isBlank(acc.MainPhone) || String.isBlank(acc.MainPhonePrefix))) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.PrimaryEmail or Account.MainPhone and Account.MainPhonePrefix';
                validateResult.errorFlag = true;
                return;
            }

            Map<String, Object> fields = new Map<String, Object>{ 
                'Country' => acc.Country, 
                'Channel' => acc.Channel, 
                'SegmentOfCountry' => acc.SegmentOfCountry, 
                'Sector' => acc.Sector,
                'Subsector' => acc.Subsector, 
                'Theatre' => acc.Theatre
            };

            //BEGIN ACERRA CR-NR2063 B2B 08.11.2021 
            Map<String, Object> fieldsB2BMandatory = new Map<String, Object>{ 
                'SegmentOfCountry' => acc.SegmentOfCountry, 
                'AccountTaxType' => acc.AccountTaxType,
                'VatGroupType' => acc.VatGroupType, 
                'Theatre' => acc.Theatre,
                'Zone' => acc.Zone
            };

            if('CommodityItalyB2C'.equalsIgnoreCase(clientSystem)  && 'B2B'.equalsIgnoreCase(acc.AccountType)){
                fields.clear();
                fields.putAll(fieldsB2BMandatory);
            }
            //END ACERRA CR-NR2063 B2B 08.11.2021

            for(String field : fields.KeySet()) {
                if( fields.get(field) == null || (fields.get(field)+'') == '') {
                    validateResult.errorMessage = Label.XC_CL_MandatoryField+' Account.'+field;
                    validateResult.errorFlag = true;
                    return;
                } 
            }
        }
    }


    /**
     * ValidateRequestIdentity.
     *
     * @param identityList the identity list
     * @return the x C UTI L integration. wrapper result
     * @description Method to verify if Identity required parameters are correctly filled for POST callout
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestIdentity(List<XC_UTIL_Account.IdentityIFWrapper> identityList, String clientSystem) {
            
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        Integer i = 1;
        for(XC_UTIL_Account.IdentityIFWrapper identityWr : identityList) {

            Map<String, String> requiredParameters = new Map<String, String>{'Country' => identityWr.Country,
                                                                                'IdentityType' => identityWr.IdentityType,
                                                                                'IdentityNumber' => identityWr.IdentityNumber
                                                                            };
            for(String key : requiredParameters.keySet()) {
                if(String.isBlank(identityWr.IdentityID) && String.isBlank(requiredParameters.get(key))) {
                    validateResult.errorMessage = Label.XC_CL_MandatoryField+' Identity.' + key + ' in ' + i + '-th Identity';
                    validateResult.errorFlag = true;
                    return validateResult;
                }else if(requiredParameters.get(key) != null && requiredParameters.get(key).isWhitespace()){
                    validateResult.errorMessage = 'Identity.' + key + ' in ' + i + '-th Identity '+Label.XC_CL_CanNotEmpty;
                    validateResult.errorFlag = true;
                    return validateResult;
                }
            }

            if(clientSystem == Label.XC_CL_CommoditySpainB2C && identityWr.IdentityType == 'NIE' && String.isBlank(identityWr.IdentityID)) {
                identityWr.ReleaseDate = (String.isBlank(identityWr.ReleaseDate)) ? String.valueOf(Date.Today()) : identityWr.ReleaseDate;
                identityWr.ExpiryDate = (String.isBlank(identityWr.ExpiryDate)) ? String.valueOf(Date.Today().addYears(40)) : identityWr.ExpiryDate;
            }

            Map<String, String> dateParameters = new Map<String, String>{'ReleaseDate' => (identityWr.ReleaseDate != null) ? identityWr.ReleaseDate.split('T')[0] : null,
                                                                            'ExpiryDate' => (identityWr.ExpiryDate != null) ? identityWr.ExpiryDate.split('T')[0] : null
                                                                        };
            for(String key : dateParameters.keySet()) {
                if(String.isNotBlank(dateParameters.get(key)) && !XC_UTIL_RESTInbound.checkDate(dateParameters.get(key) + ' 00:00:00')) {
                    validateResult.errorMessage = 'Format of Identity.' + key + ' not correct in ' + i + '-th Identity';
                    validateResult.errorFlag = true;
                    return validateResult;
                }
            }
            i++;
        }

        return validateResult;
    }
}