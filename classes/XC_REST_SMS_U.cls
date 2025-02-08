/**
 * The Class XC_REST_SMS_U.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it - Simone Trenta strenta@deloitte.it
 * @date Creation     : 13/05/2019
 * @date Modification : dd/mm/yyyy
 * @description       : UTIL for XC_REST_SMS
 */


public without sharing class XC_REST_SMS_U {


    /**
     * ValidateRequest.
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request
     * @return the wrapper result
     * @description method to verify if Header and SMS Section required parameters are correctly filled
     */
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, XC_REST_SMS_W.WrapperRequest wrReq){
        
        XC_UTIL_Integration.WrapperResult validateResult;
        
        // Validate Header
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        // Validate SMS
        if(wrReq.SMS == null) {
            validateResult.errorMessage = 'Missing mandatory field: SMS';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(String.isBlank(wrReq.SMS.SMSID)) {
            validateResult.errorMessage = 'Missing mandatory field: SMS.SMSID';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(String.isBlank(wrReq.SMS.StatusCode)) {
            validateResult.errorMessage = 'Missing mandatory field: SMS.StatusCode';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(String.isBlank(wrReq.SMS.StatusDescription)) {
            validateResult.errorMessage = 'Missing mandatory field: SMS.StatusDescription';
            validateResult.errorFlag = true; 
            return validateResult;
        }

        if(String.isBlank(wrReq.SMS.DateSMS)) {
            validateResult.errorMessage = 'Missing mandatory field: SMS.Date';
            validateResult.errorFlag = true;
            return validateResult;
        }

        return validateResult;
    }

    /**
     * retrieveCustomerInteraction.
     *
     * @param smsId the smsId
     * @return a list XC_Customer_Interaction__c
     * @description get a list of XC_Customer_Interaction__c
     */
    public static List<XC_Customer_Interaction__c> retrieveCustomerInteraction(String smsId){

        Map<id,XC_Customer_Interaction__c> res = 
            new Map<id,XC_Customer_Interaction__c>([
                SELECT 
                    id, 
                    XC_SMSID__c
                FROM XC_Customer_Interaction__c
                WHERE XC_SMSID__c like: '%'+smsId
                ]);

        return res.values();
    }

}