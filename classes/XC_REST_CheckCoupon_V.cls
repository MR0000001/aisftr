/**
 * The Class XC_REST_CheckCoupon_V.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 26/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util class for Rest Resource for Check Coupon/Voucher
 **/


public without sharing class XC_REST_CheckCoupon_V {


    /**
     * ValidateRequest.
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request oh PUT method
     * @param parameters the params map of GET method
     * @return the wrapper result
     * @description method to validate the request
     */
    public static XC_UTIL_Integration.WrapperResult validateRequest(Map<String, String> mapHeader, XC_REST_CheckCoupon_W.WrapperCheckCouponRequest wrReq, Map<String, String> parameters) {

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();
        
        validateResult = XC_UTIL_Integration.validateHeader(mapHeader);
        if(validateResult.errorFlag) {
            return validateResult;
        }

        String method = mapHeader.get('method');
        if(method == 'GET') {           // GET Check Coupon
            validateResult = XC_UTIL_RESTInbound.checkObjectPermission('XC_Voucher__c', 'read');
            if(validateResult.errorFlag) {
                return validateResult;
            }
            validateResult = validateRequestGET(mapHeader, parameters);

        } else if(method == 'POST') {   // POST Check Coupon
            validateResult = XC_UTIL_RESTInbound.checkObjectPermission('XC_Voucher__c', 'read');
            if(validateResult.errorFlag) {
                return validateResult;
            }
            validateResult = validateRequestPOST(mapHeader, wrReq);

        } else if(method == 'PUT') {    // PUT Burn Coupon
            validateResult = XC_UTIL_RESTInbound.checkObjectPermission('XC_Voucher__c', 'update');
            if(validateResult.errorFlag) {
                return validateResult;
            }
            validateResult = validateRequestPUT(mapHeader, wrReq);
        }
        
        return validateResult;
    }


    /**
        * ValidateRequestGET.
        *
        * @param mapHeader the map header
        * @param parameters the params map of GET method
        * @return the wrapper result
        * @description method to validate the GET parameters
        */
    public static XC_UTIL_Integration.WrapperResult validateRequestGET(Map<String, String> mapHeader, Map<String, String> parameters) {

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        if(mapHeader.get('Functionality') != 'CheckCoupon') {
            validateResult.errorMessage = 'ERROR. ' + Label.XC_CL_Error_FunctionalityValue;
            validateResult.errorFlag = true;
            return validateResult;
        }
                
        if (String.isBlank(parameters.get('couponCode'))) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + 'CouponCode';
            validateResult.errorFlag = true;
            return validateResult;
        }

        return validateResult;
    }


    /**
     * validateRequestPOST.
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request oh POST method
     * @return the wrapper result
     * @description method to validate the POST parameters
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestPOST(Map<String, String> mapHeader, XC_REST_CheckCoupon_W.WrapperCheckCouponRequest wrReq) {

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        /*if(mapHeader.get('Functionality') != 'CheckCoupon' && mapHeader.get('Functionality') != 'ReadBulk') {
            validateResult.errorMessage = 'ERROR. ' + Label.XC_CL_Error_FunctionalityValue;
            validateResult.errorFlag = true;
            return validateResult;
        }*/

        if(wrReq.requestElement == null || wrReq.requestElement.isEmpty()) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' requestElement';
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(mapHeader.get('Functionality') == 'CheckCoupon') {
            validateRequestPOSTCheckCoupon(mapHeader, wrReq, validateResult);
        } else if (mapHeader.get('Functionality') == 'ReadBulk') {
            validateRequestPOSTReadBulk(mapHeader, wrReq, validateResult);
        } else {
            validateResult.errorMessage = 'ERROR. ' + Label.XC_CL_Error_FunctionalityValue;
            validateResult.errorFlag = true;
            return validateResult;
        }

        return validateResult;
    }

    /**
     * validateRequestPOSTCheckCoupon.
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request oh POST method
     * @param validateResult the wrapper of the validate
     * @description method to validate the POST parameters for CheckCoupon functionality
     */
    public static void validateRequestPOSTCheckCoupon(Map<String, String> mapHeader, XC_REST_CheckCoupon_W.WrapperCheckCouponRequest wrReq, XC_UTIL_Integration.WrapperResult validateResult) {

        if(mapHeader.get('Operation') != 'Create') {
            validateResult.errorMessage = 'ERROR. ' + Label.XC_CL_Error_OperationValue;
            validateResult.errorFlag = true;
            return;
        }

        Integer i = 1;
        for(XC_REST_CheckCoupon_W.WrapperRequestElement wrElement : wrReq.requestElement) {

            if(String.isBlank(wrElement.CouponCode)){
                validateResult.errorMessage = Label.XC_CL_MandatoryField + ' CouponCode in the ' + i + '-th requestElement';
                validateResult.errorFlag = true;
                return;
            }

            i++;
        }

    }


    /**
     * validateRequestPOSTReadBulk.
     *
     * @param mapHeader the map header
     * @param wrReq the wrapper request oh POST method
     * @param validateResult the wrapper of the validate
     * @description method to validate the POST parameters for ReadBulk functionality
     */
    public static void validateRequestPOSTReadBulk(Map<String, String> mapHeader, XC_REST_CheckCoupon_W.WrapperCheckCouponRequest wrReq, XC_UTIL_Integration.WrapperResult validateResult) {

        if(mapHeader.get('Operation') != 'ReadBulk') {
            validateResult.errorMessage = 'ERROR. ' + Label.XC_CL_Error_OperationValue;
            validateResult.errorFlag = true;
            return;
        }

        if(wrReq.requestElement.size() > 1) {
            validateResult.errorMessage = Label.XC_CL_Error_MaxSizeCheckCoupon;
            validateResult.errorFlag = true;
            return;
        }

        if(String.isBlank(wrReq.requestElement[0].LegalEntity)){
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' LegalEntity';
            validateResult.errorFlag = true;
            return;
        }

        if(String.isBlank(wrReq.requestElement[0].RecordTypeName)){
            validateResult.errorMessage = Label.XC_CL_MandatoryField + ' RecordTypeName';
            validateResult.errorFlag = true;
            return;
        }

    }


    /**
     * ValidateRequestPUT.
     *
     * @param mapHeader the map header
     * @param requestElementReq the wrapper request oh PUT method
     * @return the wrapper result
     * @description method to validate the PUT parameters
     */
    public static XC_UTIL_Integration.WrapperResult validateRequestPUT(Map<String, String> mapHeader, XC_REST_CheckCoupon_W.WrapperCheckCouponRequest wrReq) {

        XC_UTIL_Integration.WrapperResult validateResult = new XC_UTIL_Integration.WrapperResult();

        if(mapHeader.get('Functionality') != 'BurnCoupon') {
            validateResult.errorMessage = 'ERROR. ' + Label.XC_CL_Error_FunctionalityValue;
            validateResult.errorFlag = true;
            return validateResult;
        }

        if(wrReq.requestElement == null || wrReq.requestElement.isEmpty()) {
            validateResult.errorMessage = Label.XC_CL_MandatoryField + 'requestElement';
            validateResult.errorFlag = true;
            return validateResult;
        }

        Integer i = 1;
        for(XC_REST_CheckCoupon_W.WrapperRequestElement wrElement : wrReq.requestElement) {

            if(String.isBlank(wrElement.CouponCode)){
                validateResult.errorMessage = Label.XC_CL_MandatoryField + ' CouponCode in the ' + i + '-th requestElement';
                validateResult.errorFlag = true;
                return validateResult;
            }

            if(String.isBlank(wrElement.AccountID) && String.isBlank(wrElement.PrimaryEmail) && String.isBlank(wrElement.IdentityNumber)) {
                validateResult.errorMessage = Label.XC_CL_MandatoryField + ' AccountID or PrimaryEmail or IdentityNumber in the ' + i + '-th requestElement';
                validateResult.errorFlag = true;
                return validateResult;
            }

            i++;
        }

        return validateResult;
    }

}