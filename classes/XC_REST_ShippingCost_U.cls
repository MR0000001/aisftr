/**
 * The Class XC_REST_ShippingCost_U.
 *
 * @author            : Gklaras Dionysios dgklaras@deloitte.gr
 * @date Creation     : 14/04/2021
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for XC_REST_ShippingCost
 */

public without sharing class XC_REST_ShippingCost_U {

        /**
     * ValidateRequest.
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request
     * @return the wrapper result
     * @description method to verify if Header and ShippingCost required parameters are correctly filled
     */

    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, Map<String,String> wrReq){
        
        XC_UTIL_Integration.WrapperResult validateResult;
        
        // Validate Header
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        // Validate ShippingCost

        if(String.isEmpty(wrReq.get('StreetType'))) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' StreetType';
            validateResult.errorFlag = true;
            return validateResult;
        }
        
        if(String.isEmpty(wrReq.get('Address'))) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Address';
            validateResult.errorFlag = true;
            return validateResult;
        }
        
        if(String.isEmpty(wrReq.get('StreetNumber'))) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' StreetNumber';
            validateResult.errorFlag = true;
            return validateResult;
        }
        
        if(String.isEmpty(wrReq.get('City'))) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' City';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(String.isEmpty(wrReq.get('Country'))) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' Country';
            validateResult.errorFlag = true;
            return validateResult;
        }
        
        
        return validateResult;
    }


        /*  Untyped
        Set<String> requiredFields =  new Set<String>{'StreetType', 'Address', 'StreetNumber', 'City', 'Country'};

        for(String requiredField:requiredFields) {
            if(!wrReq.contains(requiredField) || String.isBlank(wrReq.get(requiredField))) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField + ' ' + requiredField;
                validateResult.errorFlag = true;
                return validateResult;
            } 
        }       
        
        return validateResult;
        */
}