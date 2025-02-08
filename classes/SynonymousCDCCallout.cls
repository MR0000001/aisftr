/**
 * Created by SNEKKANTI00 on 22/02/2021.
 */

public with sharing class SynonymousCDCCallout {

    public static void synonymousCDCCallout(List<Synonymous__c> synonymous, Boolean isInsert) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        HttpRequest req = new HttpRequest();
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        req.setEndpoint(
                'callout:SYNONYMOUS'
        );
        req.setMethod('POST');
        req.setTimeout(30000);
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        List<RequestSynonymous> reqsJSON = new List<RequestSynonymous>();
        for(Synonymous__c syn: synonymous) {
            RequestSynonymous reqJSON = new RequestSynonymous(syn);
            reqsJSON.add(reqJSON);
        }
        System.debug('accessToken ' + accessToken);
        String request = JSON.serialize(reqsJSON);
        req.setBody(request);
        Http http = new Http();
        ResponseSynonymous respSyn = new ResponseSynonymous();
        System.debug('req ' + req.getBody());
        System.debug('request ' + request);
        Boolean rollBackAll = false;

        HttpResponse res = null;
        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, Util.abbreviateTo10k(req.getBody()), totalTime, '', 'SYNONYMOUS', 'callout:SYNONYMOUS','');
            System.debug('res ' + res);
            System.debug('res.getBody ' + res.getBody());

            if (res.getStatusCode() == 200) {
                if(String.isNotBlank(res.getBody()) && res.getBody().containsIgnoreCase('"esito":"KO"')) rollBackAll = true;

                respSyn = (ResponseSynonymous) System.JSON.deserialize(res.getBody(), ResponseSynonymous.class);
                SynonymousService.calloutAndPostProcess(synonymous, null, rollBackAll, isInsert);
            } else {
                SynonymousService.calloutAndPostProcess(synonymous, System.Label.TaxonomySynonimyCDC_Error, true, isInsert);
            }
        } catch(Exception e) {
            System.debug('Exception at SynonymousCDCCallout.execute ' + e.getMessage());
            SynonymousService.calloutAndPostProcess(synonymous, System.Label.TaxonomySynonimyCDC_Error, true, isInsert);
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'SYNONYMOUS', 'callout:SYNONYMOUS', '');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            system.debug('errorEvent -> '+ errorEvent);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
            system.debug('results -> '+ results);
        }
    }
}