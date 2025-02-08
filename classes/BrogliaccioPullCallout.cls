/**
 * Created by SNEKKANTI00 on 30/06/2021.
 */

public with sharing class BrogliaccioPullCallout {
    public static ResponseBrogliaccioPull brogliaccioPullCallout(Map<String, Case> extBrogliaccioIdCasesMap) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = null;

        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        System.debug('accessToken ' + accessToken);

        RequestBrogliaccioPull reqsJson = new RequestBrogliaccioPull(extBrogliaccioIdCasesMap);

        ResponseBrogliaccioPull responseBrogliaccioPull = new ResponseBrogliaccioPull();

        req.setEndpoint('callout:BROGLIACCIO_PULL');
        req.setBody(System.JSON.serialize(reqsJson));
        System.debug(req.getBody());
        req.setMethod('POST');
        req.setTimeout(30000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Accept', 'application/json');

        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'BROGLIACCIO_PULL','callout:BROGLIACCIO_PULL','');
            System.debug(res.getStatus());
            System.debug(res.getStatusCode());
            System.debug(res.getBody());

            if(res.getStatusCode() == 200) {
                responseBrogliaccioPull = (ResponseBrogliaccioPull) System.JSON.deserialize(res.getBody(), ResponseBrogliaccioPull.class);
            }
        } catch(Exception e) {
            System.debug('Exception at BrogliaccioPullCallout ' + e.getMessage());

            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'BROGLIACCIO_PULL','callout:BROGLIACCIO_PULL','');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            System.debug('errorEvent -> '+ errorEvent);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return responseBrogliaccioPull;
    }
}