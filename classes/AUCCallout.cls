/**
 * Created by LCONATO00 on 23/07/2020.
 */

public with sharing class AUCCallout {
    public static ResponseAUC AUCCallout( String fiscalCode, Integer position, String year, String  tributeTypology) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        //List<ResponseAUC> lsttributeListWrapper = new List<ConsultationController.tributesListWrapper>();
        HttpRequest req = new HttpRequest();
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        req.setEndpoint(
                'callout:AUC'
        );
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Accept', 'application/json');
        RequestAUC reqJSON = new RequestAUC();
        reqJSON.codiceFiscale = fiscalCode;
        reqJSON.statoPosizioni = position;
        reqJSON.tipoTributo = tributeTypology;
        reqJSON.annoRiferimento = year;
        String request = JSON.serialize(reqJSON);
        system.debug('@@@ request '+request);
        //String request = '{"codiceFiscale": "'+fiscalCode+'", "statoPosizioni": '+position+', "tipoTributo": "'+tributeTypology+'", "annoRiferimento": "'+year+'"}';
        req.setBody(request);
        Http http = new Http();
        ResponseAUC respAUC = new ResponseAUC();
        HttpResponse res = null;
        try{
        finishTime = Datetime.now().getTime();
        totalTime = (finishTime - startTime) / 1000;
        res = http.send(req);
        CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'AUC', 'callout:AUC','');
        
        respAUC = (ResponseAUC) System.JSON.deserialize(res.getBody(), ResponseAUC.class);
        system.debug('@@@ results '+ respAUC);
        /** Status 200 is SUCCESS, Status 201 is Created. If the status is different from 200 or 201 or if the returned link is empty return the long URL*/
        
        }catch(Exception e){
            System.debug('Exception at AUCCallout: ' + e.getMessage());
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'AUC', 'callout:AUC','');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            system.debug('errorEvent -> '+ errorEvent);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return respAUC;
    }

}