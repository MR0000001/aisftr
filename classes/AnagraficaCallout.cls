/**
 * Created by SNEKKANTI00 on 17/12/2020.
 */

public with sharing class AnagraficaCallout {

    public static List<ResponseAnagrafica> anagraficaCallout(Integer searchType, Integer individualCode, String taxCode, String gender, String surname, String name,
            Integer birthDay, Integer birthMonth, Integer birthYear) {

        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;

        String accessToken = WSO2AuthCallout.WSO2AuthCallout();

        RequestAnagrafica requestAnagrafica = new RequestAnagrafica(searchType, individualCode, taxCode, gender, surname, name, birthDay, birthMonth, birthYear);
                
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setMethod('POST');
        req.setTimeout(60000);
        req.setEndpoint('callout:Anagrafica');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setBody(JSON.serialize(requestAnagrafica));

        System.debug('requestAnagrafica: ' + requestAnagrafica);
        System.debug('JSON.serialize(requestAnagrafica): ' + JSON.serialize(requestAnagrafica));

        HttpResponse res = null;
        List<ResponseAnagrafica> dataFromAnagrafica = new List<ResponseAnagrafica>();
        ResponseAnagrafica responseAnagrafica = new ResponseAnagrafica();

        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'Anagrafica', 'callout:Anagrafica', '');

            System.debug('request sent and response received');
            System.debug('res.getBody() ' + res.getBody());
            String respBody = res.getBody();
            if(res.getStatusCode() != 200) {
                responseAnagrafica.anagraficaError = new ResponseAnagrafica.AnagraficaError(res.getBody(), String.valueOf(res.getStatusCode()));
                dataFromAnagrafica.add(responseAnagrafica);
            } else {
                responseAnagrafica = (ResponseAnagrafica) JSON.deserialize(res.getBody(), ResponseAnagrafica.Class);
                dataFromAnagrafica.add(responseAnagrafica);
            }
            System.debug('responseAnagrafica size ' + dataFromAnagrafica.size());
        } catch(Exception e) {
            System.debug('Exception at AnagraficaCallout: ' + e.getMessage());
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'Anagrafica', 'callout:Anagrafica', '');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            system.debug('errorEvent -> '+ errorEvent);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return dataFromAnagrafica;
    }
}