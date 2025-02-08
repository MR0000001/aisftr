/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 20/09/2019
* @description 
*/   
public with sharing class XC_REST_UrgentWONotification {

    
    /**
     * @description The Class WrapperResult.
     */
    public class WrapperResult { 
        
        /** The Success. */
        public Boolean success = true;
        
        /** The result. */
        public Integer result;

        /** The result. */
        public String message;

    }

        
    /**
     * @description The Class WrapperResult.
     */
    public class WrapperRequest { 
        public String TechnicianId;
        public String WorkOrderNumber;
        public Boolean IsUrgent;
        public String Title;
        public String Message;
    }

    /**
     * @description The callout method.
     * @param wrReq the req
     * @return the wrapper result
     */
    public static WrapperResult callout(WrapperRequest wrReq){ 

        WrapperResult res = new WrapperResult();

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:XC_XINSTALLER_NOTIFICATION');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('ServerSystem', 'XInstaller');
        req.setBody(JSON.serialize(wrReq, true));
   
        XC_UTIL_IntegrationLog intLog = new XC_UTIL_IntegrationLog();
        XC_UTIL_IntegrationLog.LogWrapper logWrapper = new XC_UTIL_IntegrationLog.LogWrapper();
        logWrapper.logIntegrationName = 'PushNotification';
        logWrapper.logEndpoint = req.getEndpoint();
        logWrapper.logMessage = req.getBody();
        logWrapper.httpMethod = req.getMethod();
        intLog.insertIntegReqOutboundLog(logWrapper);

        HttpResponse response = http.send(req);
        
        if(response!=null){
            res.success = true;
            res.result = response.getStatusCode();
            res.message = JSON.serialize(response.getBody());
            intLog.insertIntegRespOutboundLog(response.getStatusCode()==200, response.getBody(), '', '');
            return res;

        } else {
            res.success = false;
            res.message = 'Could not get any response from server';
            intLog.insertIntegRespOutboundLog(false, response.getBody(), '', '');
            return res;
        }
    }


}