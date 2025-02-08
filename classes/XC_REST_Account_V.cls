/**
 * The Class XC_REST_Account_V.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 07/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util for XC_REST_Account
 * 
 */


public without sharing class XC_REST_Account_V {


    /**
     * ValidateRequestPOST
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request
     * @return the wrapper result
     * @description method to verify if Header and other Section required parameters are correctly filled for POST Method
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestPOST(Map<String, String> mapHeader, XC_REST_Account_W.WrapperRequest wrReq){
        
        XC_UTIL_Integration.WrapperResult validateResult;
        
        // Validate Header
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        // Validate Account
        validateResult = XC_REST_Account_VV.validateRequestAccount(wrReq.Account, 'POST', mapHeader.get('ClientSystem'));
        if(validateResult.errorFlag) {
            return validateResult;
        }

        // Validate Identity
        if(((wrReq.Account.AccountType != 'B2B' && wrReq.Account.AccountType != 'B2G') && (wrReq.Account.AccountType == 'Small Business' || wrReq.Account.AccountType == 'Condominium' || wrReq.Account.RegisteredOnRechargeApp == null)) && (wrReq.Identity == null || wrReq.Identity.isEmpty() || wrReq.Identity.size() > 1)) {
            validateResult.errorMessage = Label.XC_CL_Document_IdentitySection;//'The Identity section must be filled with one document';
            validateResult.errorFlag = true;
            return validateResult;
        } else if (wrReq.Identity != null && !wrReq.Identity.isEmpty()) {
            validateResult = XC_REST_Account_VV.validateRequestIdentity(wrReq.Identity, mapHeader.get('ClientSystem'));
            if(validateResult.errorFlag) {
                return validateResult;
            }
        }
        
        // Validate Contact - Address - Billing Profile
        validateResult = validateRequestPOSTplus(mapHeader, wrReq);

        return validateResult;
    }


    /**
     * ValidateRequestPOSTplus
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request
     * @return the wrapper result
     * @description method to verify if Header and other Section required parameters are correctly filled for POST Method
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestPOSTplus(Map<String, String> mapHeader, XC_REST_Account_W.WrapperRequest wrReq) {

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        // Validate Contact
        if(wrReq.Contact == null || wrReq.Contact.isEmpty()) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField+' Contact';
            validateResult.errorFlag = true;
            return validateResult;
        }
        Map<String, Object> inputsMap = new Map<String, Object>{'conList' => wrReq.Contact,
                                                                'billigProfList' => wrReq.BillingProfile,
                                                                'type' => wrReq.Account.AccountType,
                                                                'clientSystem' => (mapHeader.get('ClientSystem'))
                                                                };
        validateResult = XC_REST_Account_VVV.validateRequestContactsPOST(inputsMap);
        if(validateResult.errorFlag) {
            return validateResult;
        }
            
        // Validate Address
        if(wrReq.Address != null && !wrReq.Address.isEmpty()) {
            validateResult = XC_REST_Account_VVVV.validateRequestAddressesPOST(wrReq.Address, wrReq.Account.AccountType, mapHeader.get('ClientSystem'));
            if(validateResult.errorFlag) {
                return validateResult;
            }
        }

        // Validate BillingProfile
        if(wrReq.BillingProfile != null && !wrReq.BillingProfile.isEmpty()) {
            validateResult = XC_REST_Account_ZZ.validateRequestBillingProfilesPOST(wrReq.BillingProfile, wrReq.Address, mapHeader.get('ClientSystem'));
        }

        return validateResult;
    }



    /**
     * ValidateRequestPUT.
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request
     * @return the wrapper result
     * @description method to verify if Header and other Section required parameters are correctly filled for PUT Method
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestPUT(Map<String, String> mapHeader, XC_REST_Account_W.WrapperRequest wrReq){       
        
        XC_UTIL_Integration.WrapperResult validateResult;
        
        // Validate Header
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        // Validate Account
        validateResult = XC_REST_Account_VV.validateRequestAccount(wrReq.Account, 'PUT', mapHeader.get('ClientSystem'));
        if(validateResult.errorFlag) {
            return validateResult;
        }

        // Validate Identity
        /*if(wrReq.Account.AccountType != 'Residential' && (wrReq.Identity != null && !wrReq.Identity.isEmpty())) {
            validateResult.errorMessage = 'The Identity section must not be filled';
            validateResult.errorFlag = true;
            return validateResult;
        } else if (wrReq.Identity != null && !wrReq.Identity.isEmpty()) {
            validateResult = XC_REST_Account_VV.validateRequestIdentity(wrReq.Identity);
            if(validateResult.errorFlag) {
                return validateResult;
            }
        }*/
            
        // Validate Contact - Address - Billing Profile
        validateResult = validateRequestPUTplus(mapHeader, wrReq);

        return validateResult;
    }

    
    /**
     * ValidateRequestPUTplus
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request
     * @return the wrapper result
     * @description method to verify if Header and other Section required parameters are correctly filled for PUT Method
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestPUTplus(Map<String, String> mapHeader, XC_REST_Account_W.WrapperRequest wrReq) {
        
        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        // Validate Contact
        if(wrReq.Contact != null && !wrReq.Contact.isEmpty()) {
            validateResult = XC_REST_Account_VVV.validateRequestContactsPUT(wrReq.Contact, wrReq.Account.AccountType, mapHeader.get('ClientSystem'));
            if(validateResult.errorFlag) {
                return validateResult;
            }
        }

        // Validate Address
        if(wrReq.Address != null && !wrReq.Address.isEmpty()) {
            validateResult = XC_REST_Account_VVVV.validateRequestAddressesPUT(wrReq.Address, wrReq.Account.AccountType, mapHeader.get('ClientSystem'));
            if(validateResult.errorFlag) {
                return validateResult;
            }
        }

        // Validate BillingProfile
        if(wrReq.BillingProfile != null && !wrReq.BillingProfile.isEmpty()) {
            Map<String, Object> inputsMap = new Map<String, Object>{'billingProfileList' => wrReq.BillingProfile,
                                                                    'addressList' => wrReq.Address,
                                                                    'conList' => wrReq.Contact
                                                                    };
            validateResult = XC_REST_Account_ZZ.validateRequestBillingProfilesPUT(inputsMap, mapHeader.get('ClientSystem'));
            return validateResult;
        }

        validateResult.errorFlag = false;
        return validateResult;
    }
}