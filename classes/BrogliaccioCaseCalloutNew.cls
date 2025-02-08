/**
 * Created by snekkanti002 on 21/09/2021.
 */

public without sharing class BrogliaccioCaseCalloutNew {
    public static List<Case> brogliaccioCaseCallout(BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapper) {
        DebugService.printLimits('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', 'start');
        CalloutHelper.setStartTime();
        Long totalTime;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        List<Case> casesToSend = new List<Case>();
        Map<String, Case> caseMap = new Map<String, Case>();
        List<String> caseIds = new List<String>();
        Map<String, List<ContentVersion>> caseIdCvsMap = new Map<String, List<ContentVersion>>();
        Map<String, String> caseIdExternalStatusOldMap = new Map<String, String>();
        Map<String, Integer> caseIdCvCount = new Map<String, Integer>();
        List<Case> cases = brogliaccioCaseListWrapper.cases;

        system.debug('brogliaccioCaseListWrapper.cases -> ' + brogliaccioCaseListWrapper.cases);
        system.debug('cases -> ' + cases);

        RequestCaseBrogliaccioNew reqsJSON;
        ResponseCaseBrogliaccio respCase = new ResponseCaseBrogliaccio();

        String accessToken = WSO2AuthCallout.WSO2AuthCallout();

        for(Case c: cases) {
            caseIds.add(c.Id);
            caseMap.put(c.Id, c);
            caseIdExternalStatusOldMap.put(c.Id, c.Sent_to_External__c);
            if(String.isBlank(c.Sent_to_External__c) || !c.Sent_to_External__c.equalsIgnoreCase(System.Label.Sync)) {
                System.debug('Entered different from Sync');
                casesToSend.add(c);
            }
        }

        system.debug('casesToSend -> ' + casesToSend);

        brogliaccioCaseListWrapper.caseIdExternalStatusOldMap = caseIdExternalStatusOldMap;

        DebugService.printList('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', 'caseIds', caseIds, true);
        DebugService.printMap('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', 'caseIdExternalStatusOldMap', new List<String>(caseIdExternalStatusOldMap.keySet()), caseIdExternalStatusOldMap.values(), true);
        DebugService.printMap('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', 'caseMap', new List<String>(caseMap.keySet()), caseMap.values(), true);

        caseIdCvsMap = ContentVersionService.getCaseIdCvsNotIntegratedMapBrogliaccio(caseIds);
        DebugService.printMap('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', 'caseIdCvsMap', new List<String>(caseIdCvsMap.keySet()), caseIdCvsMap.values(), true);

        caseIdCvCount = CaseService.getCaseIdCvCountNotIntegratedBroglaiccio(caseIdCvsMap);
        DebugService.printMap('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', 'caseIdCvCount', new List<String>(caseIdCvCount.keySet()), caseIdCvCount.values(), true);

        try {
            if(!casesToSend.isEmpty()) {
		        system.debug('casesToSend pre -> ' + casesToSend);
		        system.debug('caseIdCvCount -> ' + caseIdCvCount);

                for(Case c : casesToSend) {
                    c.Brogliaccio_N_Attachment__c = (caseIdCvCount.containsKey(c.Id)) ? caseIdCvCount.get(c.Id) : 0;
                    System.debug('c.Brogliaccio_N_Attachment__c ' + c.Brogliaccio_N_Attachment__c);
                }

		        system.debug('casesToSend post -> ' + casesToSend);

                reqsJSON = new RequestCaseBrogliaccioNew(casesToSend);
                system.debug('reqsJSON -> ' + reqsJSON);
                system.debug('JSON.serialize(reqsJSON) -> ' + JSON.serialize(reqsJSON));
                req = CalloutHelper.initializeRequest('callout:BROGLIACCIO_CASE', 'POST', 60000, 'application/json', 'Bearer '+accessToken, 'application/json', JSON.serialize(reqsJSON));

                DebugService.printRequest('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', req);

                totalTime = CalloutHelper.getTotalTime();
                res = http.send(req);

                DebugService.printResponse('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', res);

                if(res.getStatusCode() == 200) {
                    respCase = (ResponseCaseBrogliaccio) System.JSON.deserialize(res.getBody(), ResponseCaseBrogliaccio.class);

                    for(ResponseCaseBrogliaccio.InserisciSegnalazioneResult resp : respCase.InserisciSegnalazioneResponse.InserisciSegnalazioneResult) {
                        if(resp.Esito) {
                            System.debug('Entered OK ' + caseMap.get(resp.PortalID).Id);
                            Case theCase = caseMap.get(resp.PortalID);
                            theCase.Brogliaccio_DescriptioError__c = null;
                            theCase.ExternalSystemId_Brogliaccio__c = String.valueOf(resp.IDSegnalazione);
                        } else {
                            System.debug('Entered KO');
                            for(case c : casesToSend) {
                                c.Brogliaccio_DescriptioError__c = resp.DescrEsito;
                                caseIdCvsMap.remove(c.Id);
                                caseIdCvCount.remove(c.Id);
                                //c.ExternalSystemId_Brogliaccio__c = '0';
                            }
                        }
                    }
                }
            }

            brogliaccioCaseListWrapper.caseMap = caseMap;
            brogliaccioCaseListWrapper.caseIdCvsMap = caseIdCvsMap;
            brogliaccioCaseListWrapper.caseIdCvCount = caseIdCvCount;

            System.debug('brogliaccioCaseListWrapper ' + brogliaccioCaseListWrapper);

            CaseService.setCaseFieldsForBrogliaccioNew(brogliaccioCaseListWrapper);

            Set<Integer> caseIdCvCountSet = new Set<Integer>(caseIdCvCount.values());

            if(!caseIdCvCountSet.isEmpty() && ((caseIdCvCountSet.size() == 1 && !caseIdCvCountSet.contains(0)) || caseIdCvCountSet.size() > 1)) {
                System.debug('Entered Calling BrogliaccioContentVersionCalloutNew');
                BrogliaccioContentVersionCalloutNew.brogliaccioContentVersionCallout(brogliaccioCaseListWrapper);
                System.debug('Finished Calling BrogliaccioContentVersionCalloutNew');
            }
            if(!casesToSend.isEmpty()) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'BROGLIACCIO_CASE','callout:BROGLIACCIO_CASE','');
            }

            return cases;
        } catch(Exception e) {
            DebugService.printException('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', e);
            CalloutHelper.handleException(res, req, req.getBody(), totalTime, 'BROGLIACCIO_CASE', 'callout:BROGLIACCIO_CASE', e);
        }
        DebugService.printLimits('BrogliaccioCaseCalloutNew', 'brogliaccioCaseCallout', 'end');
        return new List<Case>();
    }
}