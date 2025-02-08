/**
 * @author              Simone Trenta - strenta@deloitte.it
 * @date Creation       15/06/2020
 * @date Modification   
 * @description         XC_REST_OrderCharger – Rest Resourse for account and order creation 
 */

public without sharing class XC_REST_OrderCharger_U {

    public static final Set<String> FILTERED_CLIENTSYSTEM = new Set<String>{
        'COMMODITYSPAINB2C', 'COMMODITYITALYB2C'
    };

    public class WrapperRequest {
        public AccountOrderInfo AccountOrder;
    }

    public class WrapperResponse {
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
    }

    public class AccountOrderInfo{
        public String AccountOrderInfo;
        public String Status;
        public String Reason;
        public String OrderType;
        public String OrderSubType;
    }

    /**
    * @description insertQueuedRequest
    * @param wr the wrapper
    * @param header the mapHeader
    * @return the wrapper result
    */
    public static WrapperResponse insertQueuedRequest(WrapperRequest wr, Map<String,String> header){
        WrapperResponse res = new WrapperResponse();
        

        XC_QueuedRequest__c qr = new XC_QueuedRequest__c();
        qr.XC_RequestBody__c = wr.AccountOrder.AccountOrderInfo; 
        qr.XC_ClientSystem__c = header.get('ClientSystem');
        qr.XC_TransactionId__c = header.get('TransactionID');
        qr.XC_IdempotencyToken__c = header.get('IdempotencyToken');

        // check idempotencyToken
        if(!String.isBlank(qr.XC_ClientSystem__c) && FILTERED_CLIENTSYSTEM.contains((qr.XC_ClientSystem__c).toUppercase()) && !String.isBlank(wr.AccountOrder.Status)){
            qr.XC_ValidationStatus__c = wr.AccountOrder.Status;
            qr.XC_Reason__c = wr.AccountOrder.Reason;
            qr.XC_OrderType__c = wr.AccountOrder.OrderType;
            qr.XC_OrderSubType__c = wr.AccountOrder.OrderSubType;
            if(wr.AccountOrder.Status.equalsIgnoreCase('KO')){
                qr.XC_Status__c  = 'In Error';
            }else if(wr.AccountOrder.Status.equalsIgnoreCase('OK')){
                Map<Id,XC_QueuedRequest__c> mapIdQR = searchQueuedRequestByIdempotencyToken(wr, header);
                if(!mapIdQR.isEmpty()){
                    return manageResponseQRFound(mapIdQR);
                }
            }
        }
        

        XC_UTIL_QueuedRequest_W.WrapperRequest wrInfo = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(wr.AccountOrder.AccountOrderInfo,XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        qr.XC_IntegrationId__c = wrInfo.Order.IntegrationID;  

        XC_UTIL_Sobject.WrapperResult wrRes = XC_UTIL_Sobject.insertRecord(qr);
        if(wrRes.success){
            res.Result.Message = 'Operation completed successfully';
            res.Result.errorCode = '0';
        } else {
            res.Result.Message = 'INTERNAL ERROR: '+wrRes.errorMessage; 
            res.Result.ErrorCode = '500';
        }
        

        return res;
    }

        /**
    * @description insertQueuedRequest
    * @param wr the wrapper
    * @param header the mapHeader
    * @return the wrapper result
    */
    public static XC_UTIL_Integration.WrapperResult validateQueuedRequest(WrapperRequest wr, Map<String,String> header){
        XC_UTIL_Integration.WrapperResult res = new XC_UTIL_Integration.WrapperResult();

        if(wr == null){
            res.errorMessage = 'Missing AccountOrder section'; 
            res.errorFlag = true;
            return res;
        }

        if(wr.AccountOrder == null || String.isBlank(wr.AccountOrder.AccountOrderInfo)){
            res.errorMessage = 'Missing AccountOrderInfo field'; 
            res.errorFlag = true;
            return res;
        }

        /*if(FILTERED_CLIENTSYSTEM.contains(header.get('ClientSystem').toUppercase()) && String.isBlank(wr.AccountOrder.Status)){
            res.errorMessage = 'Missing Status field'; 
            res.errorFlag = true;
            return res;
        }*/

        //res = validateQueuedRequestDetail(wr.AccountOrder.AccountOrderInfo,header);

        return res;
    }


    /**
    * @description method to search a ququed request by idempotency token 
    * @param wr the wrapper
    * @param header the mapHeader
    * @return the map with queued request id as key and queued request as value
    */
    private static Map<Id, XC_QueuedRequest__c> searchQueuedRequestByIdempotencyToken(WrapperRequest wr, Map<String,String> header){

        Map<Id,XC_QueuedRequest__c> mapIdQR = new Map<Id,XC_QueuedRequest__c>();
        if(!String.isBlank(header.get('ClientSystem')) && !String.isBlank(header.get('IdempotencyToken'))){ 
            mapIdQR = new  Map<Id,XC_QueuedRequest__c>([SELECT Id, XC_Status__c, (SELECT Id, XC_Status__c, XC_CallbackRequest__c FROM QueuedRequestSteps__r WHERE XC_StepLabel__c =: Label.XC_CL_CommodityCallback) 
                       FROM XC_QueuedRequest__c 
                       WHERE XC_IdempotencyToken__c =: header.get('IdempotencyToken') AND XC_ClientSystem__c =: header.get('ClientSystem') AND XC_ValidationStatus__c =: wr.AccountOrder.Status
                       LIMIT 1
                      ]);
        }
        
        return mapIdQR; 
    }


    /**
    * @description method to manage properly response for queued request found
    * @param mapIdQR the map with queued request id as key and queued request as value
    * @return the wrapper response
    */
    private static WrapperResponse manageResponseQRFound(Map<Id,XC_QueuedRequest__c> mapIdQR){

        WrapperResponse res = new WrapperResponse();
        Set<String> finalStatus = new Set<String>{Label.XC_CL_Completed,'In Error'}; 
        
        if(finalStatus.contains(mapIdQR.values()[0].XC_Status__c) && mapIdQR.values()[0].QueuedRequestSteps__r[0].XC_Status__c == Label.XC_CL_Completed_OK){
            String message = '';
            if(mapIdQR.values()[0].XC_Status__c == Label.XC_CL_Completed){
                message = 'Operation completed successfully';
                res.Result.errorCode = '0';
            } else{
                message = 'In error';
                res.Result.errorCode = '500';
            }

            if(!String.isBlank(mapIdQR.values()[0].QueuedRequestSteps__r[0].XC_CallbackRequest__c)){
              	XC_REST_OrderChargerCallback.OrderCallbackRequest callBackWr =  (XC_REST_OrderChargerCallback.OrderCallbackRequest)JSON.deserialize(mapIdQR.values()[0].QueuedRequestSteps__r[0].XC_CallbackRequest__c, XC_REST_OrderChargerCallback.OrderCallbackRequest.class);
                message = message + '. IntegrationId: ' + callBackWr.integration_id +  ', Result: ' + callBackWr.result + ((!String.isBlank(callbackWr.result_message)) ?  ', ResultMessage: ' + callbackWr.result_message : ''); 
            }
            
            res.Result.Message = (message.length() > 255) ? message.substring(0, 255 - 1) : message;

        }else{
            res.Result.Message = 'Operation completed successfully';
            res.Result.errorCode = '0';
        }

        return res;
    }


    /**
    * @description manage validations at field level over the accountOrderInfo field of the request
    * @author Francesco Imperioli - fimperioli@deloitte.it | 07-08-2020 
    * @param accountOrderInfo 
    * @param res 
    **/
    /*private static XC_UTIL_Integration.WrapperResult validateQueuedRequestDetail(String accountOrderInfo,Map<String,String> headerMap){

        //try to deserialize
        XC_UTIL_QueuedRequest_W.WrapperRequest wrInfo = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(accountOrderInfo,XC_UTIL_QueuedRequest_W.WrapperRequest.class);

        //generate full account request to validate
        XC_REST_Account_W.WrapperRequest accountWrReq = new XC_REST_Account_W.WrapperRequest();
        accountWrReq.Account = wrInfo.Account;
        accountWrReq.Contact = wrInfo.Contact;
        accountWrReq.Identity = wrInfo.Identity;
        accountWrReq.BillingProfile = wrInfo.BillingProfile;
        accountWrReq.Address = wrInfo.Address;



        return XC_REST_Account_V.validateRequestPOST(headerMap, accountWrReq);

    }*/

}