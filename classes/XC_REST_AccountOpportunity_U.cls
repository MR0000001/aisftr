/**
 * @author              Giuseppe Di Bonito - gdibonito@deloitte.it
 * @date Creation       03/11/2020
 * @date Modification   
 * @description         XC_REST_AccountOpportunity_U – Rest Resource for account and opportunity creation 
 */

public without sharing class XC_REST_AccountOpportunity_U {

    public class WrapperRequest {
        public AccountOpportunityInfo AccountOpportunity;
    }

    public class WrapperResponse {
        public XC_UTIL_Integration.Result Result = new  XC_UTIL_Integration.Result();
    }

    public class AccountOpportunityInfo{
        public String AccountOpportunityInfo;
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
        qr.XC_RequestBody__c = wr.AccountOpportunity.AccountOpportunityInfo; 
        qr.XC_ClientSystem__c = header.get('ClientSystem');
        qr.XC_TransactionId__c = header.get('TransactionID');

        XC_UTIL_QueuedRequest_W.WrapperRequest wrInfo = (XC_UTIL_QueuedRequest_W.WrapperRequest) JSON.deserialize(wr.AccountOpportunity.AccountOpportunityInfo,XC_UTIL_QueuedRequest_W.WrapperRequest.class);
        qr.XC_IntegrationId__c = wrInfo.Opportunity.LeadID;  

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
            res.errorMessage = 'Missing AccountOpportunity section'; 
            res.errorFlag = true;
            return res;
        }

        if(wr.AccountOpportunity == null || String.isBlank(wr.AccountOpportunity.AccountOpportunityInfo)){
            res.errorMessage = 'Missing AccountOpportunityInfo field'; 
            res.errorFlag = true;
            return res;
        }

        //res = validateQueuedRequestDetail(wr.AccountOpportunity.AccountOpportunityInfo,header);

        return res;
    }
}