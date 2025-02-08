public with sharing class RSMCallout {
    public static List<Case> RSMCallout(List<Case> cases) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        HttpRequest req = new HttpRequest();
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        req.setMethod('POST');
        req.setTimeout(30000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Accept', 'application/json');
        Map<String,String> caseNumberIdMap = new Map<String,String>();
        Map<String,Case> caseIdMap = new Map<String,Case>();
        List<RequestRSM> reqsJSON = new List<RequestRSM>();
        Map<String, String> cityNameCityCodeMap = RSMHelper.caseComuneMapper(cases);
        System.debug('cityNameCityCodeMap ' + cityNameCityCodeMap);
        List<Case> casesToUpdate = new List<Case>();

        for(Case caseToSend: cases) {
            String comuneName = caseToSend.Concession_Municipality__c?.toUpperCase();
            System.debug('comuneName ' + comuneName);
            System.debug('caseToSend.ID_Comune__c ' + caseToSend.ID_Comune__c);
            System.debug('cityNameCityCodeMap.containsKey(comuneName) ' + cityNameCityCodeMap.containsKey(comuneName));

            if(comuneName != null && !comuneName.equalsIgnoreCase('') && cityNameCityCodeMap.containsKey(comuneName) &&
                    (caseToSend.ID_Comune__c != Integer.valueOf(cityNameCityCodeMap.get(comuneName)))) {
                System.debug('Will have to update the cases');
                caseToSend.ID_Comune__c = Integer.valueOf(cityNameCityCodeMap.get(comuneName));
                casesToUpdate.add(caseToSend);
            }

            caseNumberIdMap.put(caseToSend.CaseNumber,caseToSend.Id);
            caseIdMap.put(caseToSend.Id,caseToSend);
            RequestRSM reqJSON = new RequestRSM();
            RequestRSM.InviaSegnalazione inviaSegnalazione = new RequestRSM.InviaSegnalazione();
            RequestRSM.Segnalazione segnalazione = new RequestRSM.Segnalazione();
            String dataAccesso = (caseToSend.Start_Day_Access__c!=null)?String.valueOf(caseToSend.Start_Day_Access__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')):null;
            String oraInizioAccesso = (caseToSend.Start_Day_Access__c!=null)?String.valueOf(caseToSend.Start_Day_Access__c.format('HH:mm')):null;
            String dataFineAccesso = (caseToSend.Finish_Day_Access__c!=null)?String.valueOf(caseToSend.Finish_Day_Access__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')):null;
            String oraFineAccesso = (caseToSend.Finish_Day_Access__c!=null)?String.valueOf(caseToSend.Finish_Day_Access__c.format('HH:mm')):null;
            segnalazione.identificativo = caseToSend.CaseNumber;
            segnalazione.targa = caseToSend.License_plate__c;
            segnalazione.numeroConcessione = caseToSend.Concession_Number__c;
            segnalazione.comuneRilascio = caseToSend.Concession_Municipality__c;
            segnalazione.idComune = String.valueOf(Integer.valueOf(caseToSend.ID_Comune__c));
            segnalazione.dataAccesso = dataAccesso;
            segnalazione.oraInizioAccesso = oraInizioAccesso;
            segnalazione.dataFineAccesso = dataFineAccesso;
            segnalazione.oraFineAccesso = oraFineAccesso;
            inviaSegnalazione.segnalazione = segnalazione;
            reqJSON.inviaSegnalazione = inviaSegnalazione;
            reqsJSON.add(reqJSON);
            System.debug('segnalazione.idComune ' + segnalazione.idComune);
        }
        String request;
        String method;
        if(reqsJSON.size()==1) {
            request = JSON.serialize(reqsJSON[0]);
            method = '/invioSegnalazione/';
        }else {
            request = JSON.serialize(reqsJSON);
            method = '/invioMassivoSegnalazione/';
        }
        req.setEndpoint(
                'callout:RSM'+method
        );
        //String request = '{"codiceFiscale": "'+fiscalCode+'", "statoPosizioni": '+position+', "tipoTributo": "'+tributeTypology+'", "annoRiferimento": "'+year+'"}';
        req.setBody(request);
        system.debug('@@@ req '+req.getBody());
        system.debug('@@@ req '+req.getEndpoint());
        Http http = new Http();
        HttpResponse res = null;
        try{
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            system.debug('@@@ res '+res);
            system.debug('@@@ res '+res.getBody());
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'RSM', 'callout:RSM'+method, '');
            system.debug('@@@ casesToUpdate.size '+casesToUpdate.size());
            if(!casesToUpdate.isEmpty()) {
                try {
                    Database.update(casesToUpdate, false);
                } catch(Exception e) {
                    System.debug('Exception at RSMCallout update cases:' + e.getMessage());
                    ErrorLogEventHandler.standardExceptionLog(e);
                }
            }

            if(res.getStatusCode()==200) {
                if(method.equalsIgnoreCase('/invioSegnalazione/')) {
                    ResponseRSM.invioSegnalazioneResponse respRSM = new ResponseRSM.invioSegnalazioneResponse();
                    respRSM = (ResponseRSM.invioSegnalazioneResponse) System.JSON.deserialize(res.getBody(), ResponseRSM.invioSegnalazioneResponse.class);
                    if(respRSM.esito.valore == 'true' && respRSM.esito.descrizione.contains('Segnalazione inoltrata correttamente')) {
                        cases[0].Sent_to_External__c = 'Sync';
                        return cases;
                    }
                } else {
                    ResponseRSM.invioMassivoSegnalazioneResponse respRSM = new ResponseRSM.invioMassivoSegnalazioneResponse();
                    respRSM = (ResponseRSM.invioMassivoSegnalazioneResponse) System.JSON.deserialize(res.getBody(), ResponseRSM.invioMassivoSegnalazioneResponse.class);
                    List<Case> casesSent = new List<Case>();
                    for(ResponseRSM.EsitoMass esito : respRSM.esito) {
                        if(esito.valore?.equalsIgnoreCase('true') && esito.descrizione.contains('Segnalazione inoltrata correttamente')) {
                            Case c = caseIdMap.get(caseNumberIdMap.get(esito.identificativo));
                            c.Sent_to_External__c = 'Sync';
                        } else {
                            Case c = caseIdMap.get(caseNumberIdMap.get(esito.identificativo));
                            c.Sent_to_External__c = 'Not Sync';
                        }
                    }
                    return cases;
                }
            }
        } catch(Exception e) {
            System.debug('Exception at RSMCallout: ' + e.getMessage());
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'RSM', 'callout:RSM'+method, '');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            system.debug('errorEvent -> '+ errorEvent);
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
            system.debug('results -> '+ results);
        }
        return new List<Case>();
    }
}