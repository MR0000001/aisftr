/**
 * Created by SNEKKANTI00 on 19/02/2021.
 */

public with sharing class TaxonomyCDCCallout {

    public static void taxonomyCDCCallout(List<Taxonomy__c> taxes, Boolean isInsert) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        HttpRequest req = new HttpRequest();
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        req.setEndpoint(
                'callout:TAXONOMY'
        );
        req.setMethod('POST');
        req.setTimeout(30000);
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        List<RequestTaxonomy> reqsJSON = new List<RequestTaxonomy>();
        for(Taxonomy__c tax: taxes) {
            RequestTaxonomy reqJSON = new RequestTaxonomy(tax);
            reqsJSON.add(reqJSON);
        }
        System.debug('accessToken ' + accessToken);
        String request = JSON.serialize(reqsJSON);
        req.setBody(request);
        Http http = new Http();
        ResponseTaxonomy respTax = new ResponseTaxonomy();
        System.debug('req ' + req.getBody());
        System.debug('request ' + request);
        Boolean rollBackAll = false;
        HttpResponse res = null;
        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, Util.abbreviateTo10k(req.getBody()), totalTime, '', 'TAXONOMY', 'callout:TAXONOMY','');
            System.debug('res ' + res);
            System.debug('res.getBody ' + res.getBody());
            if(res.getStatusCode() == 200) {
                if(String.isNotBlank(res.getBody()) && res.getBody().containsIgnoreCase('"esito":"KO"')) rollBackAll = true;

                respTax = (ResponseTaxonomy) System.JSON.deserialize(res.getBody(), ResponseTaxonomy.class);
                TaxonomyService.calloutAndPostProcess(taxes, null, rollBackAll, isInsert);
            } else {
                TaxonomyService.calloutAndPostProcess(taxes, System.Label.TaxonomySynonimyCDC_Error, true, isInsert);
            }
        } catch(Exception e) {
            System.debug('Exception at TaxonomyCDCCallout.execute ' + e.getMessage());
            TaxonomyService.calloutAndPostProcess(taxes, System.Label.TaxonomySynonimyCDC_Error, true, isInsert);
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '',  'TAXONOMY', 'callout:TAXONOMY','');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            system.debug('errorEvent -> '+ errorEvent);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
    }
}