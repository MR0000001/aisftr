/**
 * The Class XC_REST_CheckCoupon_W.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 26/04/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Util class for Rest Resource for Check Coupon/Voucher
 **/
    

public without sharing class XC_REST_CheckCoupon_W {


    /**
     * @description The Class WrapperCheckCouponRequest.
     */
    public class WrapperCheckCouponRequest {
            
        /** The request element. */
        public List<WrapperRequestElement> requestElement;
    }


    /**
     * The Class WrapperRequestElement.
     * 
     * @description wrapper request element of REST call
     */
    public class WrapperRequestElement {
            
        /** The coupon code. */
        public String couponCode;
        
        /** The Account ID. */
        public String AccountID;
        
        /** The Primary email. */
        public String PrimaryEmail;
        
        /** The Identity number. */
        public String IdentityNumber;

        /** The Legal Entity. */
        public String LegalEntity;

        /** The Record Type Name. */
        public String RecordTypeName;
        
        /** The Status. */
        public String Status;

        /** The Limit Row. */
        public Decimal LimitRow;

        /** The External Status. */
        public String ExternalStatus;
    }


    /**
     * The Class WrapperResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperResponse {

        /** The logError. */
        public String logError = '';

        /** The errorCode. */
        public String errorCode = '200';

        /** The counterError. */
        public Integer counterError = 0;

        /** The responseElement. */
        public List<WrapperCheckCouponResponse> responseElement = new List<WrapperCheckCouponResponse>();
    }


    /**
     * The Class WrapperCheckCouponResponse.
     *
     * @description wrapper response of REST call
     */
    public class WrapperCheckCouponResponse {
            
        /** The outcome. */
        public String outcome;
        
        /** The outcome code. */
        public String outcomeCode;
        
        /** The outcome description. */
        public String outcomeDescription;
        
        /** The coupon code. */
        public String couponCode;
        
        /** The is active. */
        public Boolean isActive;
        
        /** The counter. */
        public String counter;
        
        /** The value. */
        public String value;
        
        /** The coupon type. */
        public String couponType;
        
        /** The selling channel. */
        public String sellingChannel;
        
        /** The start date. */
        public String startDate;
        
        /** The end date. */
        public String endDate;

        /** The name. */
        public String name;

        /** The catalog Item. */
        public String catalogItem;
        
        /** The catalog Category. */
        public String catalogCategory;
        
        /** The payment Model. */
        public String paymentModel;

        /** The Account ID. */
        public String AccountID;

        /** The log Error. */
        public String logError;

        /** The log Error. */
        public XC_Voucher__c voucherToUpdate;

        /** The log Error. */
        public XC_VoucherUtilization__c utilizationToInsert;

        /** The Duration. */
        public Integer Duration; 

        /** The Final Price. */
        public Integer FinalPrice; 

        /** The Threshold. */
        public Decimal Threshold; 

        /** The Unit Of Measure. */
        public String UnitOfMeasure; 

        /** The Coupon Family. */
        public String CouponFamily;

        /** The Identity Number. */
        public String IdentityNumber;
        
        /** The Pod Pdr. */
        public String PodPdr;

        /** The Category Name. */
        public String CategoryName;

        /** The External Product Name. */
        public String ExternalProductName;
        
        /** The Order Number. */
        public String OrderNumber;
        
        /** The External Status. */
        public String ExternalStatus;
        
        /** The External Message. */
        public String ExternalMessage;

        /** The Address section. */
        public XC_UTIL_Address.AddressWrapper Address;
    }


    /**
     * CreateHttpResponseGET.
     *
     * @param mapHeader the header map
     * @param wrResp the wrapper response
     * @param intLog the integration log
     * @description method to create Http response for GET method
     */
    public static void createHttpResponseGET(Map<String, String> mapHeader, XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResp, XC_UTIL_IntegrationLog intLog) {
        
        String logError = wrResp.logError;

        if(wrResp.outcome == 'KO') {
            wrresp.couponCode = null;
            wrResp.isActive = null;
            wrResp.counter = null;
            wrResp.value = null;
            wrResp.couponType = null;
            wrResp.sellingChannel = null;
            wrResp.startDate = null;
            wrResp.endDate = null;
            wrResp.AccountID = null;
        }

        wrResp.logError = null;
        String msgResponse = JSON.serialize(wrResp, true);
        msgResponse = msgResponse.replace('DeliveryAddress', 'ShippingAddress');

        XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
        restContextResponseWrapper.res = RestContext.response;
        restContextResponseWrapper.msgResponse = msgResponse;
        restContextResponseWrapper.mapHeader = mapHeader;
        if(wrResp.outcomeCode == 'EMOB000' || wrResp.outcomeCode == 'EMOB005') {
            intLog.insertIntegRespInboundLog('200', true, msgResponse, logError);
            restContextResponseWrapper.errorCode = '200';
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        } else if(wrResp.outcomeCode == 'EMOB001' || wrResp.outcomeCode == 'EMOB002' || wrResp.outcomeCode == 'EMOB003' || wrResp.outcomeCode == 'EMOB004') {
            intLog.insertIntegRespInboundLog('400', false, msgResponse, logError);
            restContextResponseWrapper.errorCode = '400';
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        } else {
            intLog.insertIntegRespInboundLog(wrResp.outcomeCode, false, msgResponse, logError);
            restContextResponseWrapper.errorCode = wrResp.outcomeCode;
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        }
    }


    /**
     * CreateHttpResponsePostPut.
     *
     * @param mapHeader the header map
     * @param wrResp the wrapper response
     * @param intLog the integration log
     * @description method to create Http response for POST/PUT method
     */
    public static void createHttpResponsePostPut(Map<String, String> mapHeader, XC_REST_CheckCoupon_W.WrapperResponse wrResp, XC_UTIL_IntegrationLog intLog) {
        
        /*String logError = '';
        String errorCode = '200';
        Integer counterError = 0;
        for(XC_REST_CheckCoupon_W.WrapperCheckCouponResponse wrResponseElem : wrResp.responseElement) {
            if(wrResponseElem.outcome == 'KO') {
                logError = wrResponseElem.logError;
                errorCode = (wrResponseElem.outcomeCode == 'EMOB001' || wrResponseElem.outcomeCode == 'EMOB002' || wrResponseElem.outcomeCode == 'EMOB003' || wrResponseElem.outcomeCode == 'EMOB004') ? '400' : wrResponseElem.outcomeCode;
                counterError++;

                wrResponseElem.isActive = null;
                wrResponseElem.counter = null;
                wrResponseElem.value = null;
                wrResponseElem.couponType = null;
                wrResponseElem.sellingChannel = null;
                wrResponseElem.startDate = null;
                wrResponseElem.catalogItem = null;
                wrResponseElem.catalogCategory = null;
                wrResponseElem.name = null;
            }
            wrResponseElem.logError = null;
        }*/

        String logError = wrResp.logError;
        String errorCode = (String.isNotBlank(wrResp.errorCode)) ? wrResp.errorCode : '200';
        Integer counterError = (wrResp.counterError != null) ? wrResp.counterError : 0;

        wrResp.logError = null;
        wrResp.errorCode = null;
        wrResp.counterError = null;
        
        String msgResponse = JSON.serialize(wrResp, true);
        msgResponse = msgResponse.replace('DeliveryAddress', 'ShippingAddress');

        XC_UTIL_Integration.RestContextResponseWrapper restContextResponseWrapper = new XC_UTIL_Integration.RestContextResponseWrapper();
        restContextResponseWrapper.res = RestContext.response;
        restContextResponseWrapper.msgResponse = msgResponse;
        restContextResponseWrapper.mapHeader = mapHeader;
        if(counterError == wrResp.responseElement.size()) {
            intLog.insertIntegRespInboundLog(errorCode, false, msgResponse, logError);
            restContextResponseWrapper.errorCode = errorCode;
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        } else {
            intLog.insertIntegRespInboundLog('200', true, msgResponse, logError);
            restContextResponseWrapper.errorCode = '200';
            XC_UTIL_Integration.setRestContextResponse(restContextResponseWrapper);
        }
    }

}