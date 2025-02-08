/**
 * Created by LCONATO00 on 23/07/2020.
 */
public with sharing class MesisCallout {
    public static ResponseMesis mesisCallout( String fiscalCode, String practiceCode ) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        ResponseMesis respMesis = new ResponseMesis();
        HttpRequest req = new HttpRequest();
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        String input = '/'+fiscalCode+'/'+practiceCode;
        req.setEndpoint(
                'callout:CRM'+input
        );
        req.setMethod('GET');
        req.setTimeout(30000);
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Accept', 'application/json');
        req.setHeader(System.Label.Mesis_Header_Key, System.Label.Mesis_Header_Value);
        RequestMesis reqJSON = new RequestMesis(fiscalCode, practiceCode);
        String request = JSON.serialize(reqJSON);
        Http http = new Http();
        HttpResponse res = null;
        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'CRM', 'callout:CRM'+input,'');
            /** Status 200 is SUCCESS, Status 201 is Created. If the status is different from 200 or 201 or if the returned link is empty return the long URL*/
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                respMesis = (ResponseMesis) System.JSON.deserialize(res.getBody(), ResponseMesis.class);
            }
        } catch(Exception e) {
            System.debug('Exception at MesisCallout.mesisCallout ' + e.getMessage());
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'CRM', 'callout:CRM'+input,'');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            system.debug('errorEvent -> '+ errorEvent);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return respMesis;
    }
}