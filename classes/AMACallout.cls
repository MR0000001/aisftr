/**
* Created by LCONATO00 on 11/11/2020.
*/

public with sharing class AMACallout {
    public static List<Case> AMACallout(List<Case> cases) {
        return AMACallout(cases, false);
    }

    public static List<Case> AMACallout(List<Case> cases, Boolean isFromComponent) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        HttpRequest req = new HttpRequest();
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        Boolean isInfoLog = false;

        req.setMethod('POST');
        req.setTimeout(30000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Accept', 'application/json');
        Map<String,String> caseNumberIdMap = new Map<String,String>();
        Map<String,Case> caseIdMap = new Map<String,Case>();
        List<RequestAMA> reqsJSON = new List<RequestAMA>();
        for(Case caseToSend: cases) {
            caseNumberIdMap.put(caseToSend.CaseNumber,caseToSend.Id);
            caseIdMap.put(caseToSend.Id,caseToSend);
            RequestAMA reqJSON = new RequestAMA(caseToSend);
            reqsJSON.add(reqJSON);
        }
        String request;
        String method;
        if(reqsJSON.size()==1) {
            request = JSON.serialize(reqsJSON[0], true);
            method = 'avviso/';
        }else {
            request = JSON.serialize(reqsJSON, true);
            method = 'avvisi/';
        }
        req.setEndpoint(
                'callout:AMA/'+method
        );
        system.debug('@@@ request '+request);
        req.setBody(request);
        Http http = new Http();
        HttpResponse res = null;
        try{
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'AMA','callout:AMA/'+method,'');
            system.debug('req -> ' + req);
            system.debug('res -> ' + res);
            system.debug('req.getBody() -> ' + req.getBody());
            /** Status 200 is SUCCESS, Status 201 is Created. If the status is different from 200 or 201 or if the returned link is empty return the long URL*/
            if(res.getStatusCode()==200) {
                if(method.equalsIgnoreCase('avviso/')) {
                    ResponseAMA.avvisoResponse respAMA = new ResponseAMA.avvisoResponse();
                    respAMA = (ResponseAMA.avvisoResponse) System.JSON.deserialize(res.getBody(), ResponseAMA.avvisoResponse.class);
                    if(respAMA.esitoCaricamento.esito.equalsIgnoreCase('OK')) {
                        cases[0].ExternalSystemId_AMALV__c = respAMA.esitoCaricamento.codiceSegnalazione;
                    } else {
                        cases[0].Sent_to_External__c =  System.Label.NotSync;
                        if(respAMA.esitoCaricamento.descrizioneErrore.equalsIgnoreCase(System.Label.AmaRequest_StreetNoFound)) {
                            cases[0].Strada_KO__c = true;
                            if(isFromComponent) {
                                isInfoLog = true;
                                //throwAuraException(System.Label.AmaRequest_StreetNoFound);
                            }
                        } else if(respAMA.esitoCaricamento.codiceErrore.equalsIgnoreCase(System.Label.Ama_ErrorCode)) {
                            cases[0].Sent_to_External__c = System.Label.Sync;
                            cases[0].ExternalSystemId_AMALV__c = respAMA.esitoCaricamento.descrizioneErrore.substringAfterLast('L\'AVVISO');
                        }
                    }
                } else {
                    List<ResponseAMA.avvisiResponse> respAMA = new List<ResponseAMA.avvisiResponse>();
                    respAMA = (List<ResponseAMA.avvisiResponse>) System.JSON.deserialize(res.getBody(), List<ResponseAMA.avvisiResponse>.class);
                    List<Case> failedCases = new List<Case>();
                    for(ResponseAMA.avvisiResponse resp : respAMA) {
                        if(resp.esitoCaricamento.esito == 'OK') {
                            Case caseSuccess = caseIdMap.get(caseNumberIdMap.get(resp.esitoCaricamento.idSegnalazioneEsterna));
                            caseSuccess.ExternalSystemId_AMALV__c = resp.esitoCaricamento.codiceSegnalazione;
                        } else {
                            Case caseFailed = caseIdMap.get(caseNumberIdMap.get(resp.esitoCaricamento.idSegnalazioneEsterna));
                            caseFailed.Sent_to_External__c = System.Label.NotSync;
                            if(resp.esitoCaricamento.descrizioneErrore.equalsIgnoreCase(System.Label.AmaRequest_StreetNoFound)) {
                                caseFailed.Strada_KO__c = true;
                            } else if(resp.esitoCaricamento.codiceErrore.equalsIgnoreCase(System.Label.Ama_ErrorCode)) {
                                caseFailed.Sent_to_External__c = System.Label.Sync;
                                caseFailed.ExternalSystemId_AMALV__c = resp.esitoCaricamento.descrizioneErrore.substringAfterLast('L\'AVVISO');
                            }
                        }
                    }
                }
                return cases;
            }
        } catch(Exception e) {
            System.debug('Exception at AMACallout: ' + e.getMessage());
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'AMA', 'callout:AMA'+method, '');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                if(isInfoLog) {
                    errorEvent = ErrorLogEventHandler.createInfoEvent(e);
                } else {
                    errorEvent = ErrorLogEventHandler.createEvent(e);
                }
            }
            system.debug('errorEvent -> '+errorEvent);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
            system.debug('results -> '+ results);
        }
        return new List<Case>();
    }
}