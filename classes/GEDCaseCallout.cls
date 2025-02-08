/**
 * Created by SNEKKANTI00 on 12/07/2021.
 */

public without sharing class GEDCaseCallout {
    public static List<Case> gedCaseCallout(List<Case> cases) {
        DebugService.printLimits('GEDCaseCallout', 'gedCaseCallout', 'start');
        CalloutHelper.setStartTime();
        Long totalTime;
        Http http = new Http();
        HttpResponse res = null;

        Map<String, Case> caseIdCaseMap = CaseService.getCaseIdCaseMap(cases);
        RequestGEDCase requestGEDCase = new RequestGEDCase(caseIdCaseMap.values());
        ResponseGEDCase responseGEDCase = new ResponseGEDCase();

        String reqJson = JSON.serialize(requestGEDCase);
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        HttpRequest req = CalloutHelper.initializeRequest('callout:GED_Case', 'POST', 30000, 'application/json', 'Bearer '+accessToken, 'application/json', reqJson);

        DebugService.printRequest('GEDCaseCallout', 'gedCaseCallout', req);
        System.debug('reqJson: ' + reqJson);
        System.debug('requestGEDCase: ' + requestGEDCase);

        try {
            totalTime = CalloutHelper.getTotalTime();
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'GED_Case','callout:GED_Case','');

            System.debug('res status: ' + res.getStatus());
            System.debug('res status code: ' + res.getStatusCode());
            System.debug('res body: ' + res.getBody());
            DebugService.printResponse('GEDCaseCallout', 'gedCaseCallout', res);

            if(res.getStatusCode() == 200) {
                System.debug('GEDCaseCallout res is success');
                responseGEDCase = (ResponseGEDCase) System.JSON.deserialize(res.getBody(), ResponseGEDCase.class);
                System.debug('responseGEDCase: ' + responseGEDCase);

                if(responseGEDCase.apiWsResponse.errorCode.equalsIgnoreCase(System.Label.GED_CaseResponseSuccess)) {
                    System.debug('GEDCaseCallout esito is success');
                    CaseService.setCaseFieldsGEDCase(responseGEDCase.listaNumeroProtollo, caseIdCaseMap);
                }
                return caseIdCaseMap.values();
            }
        } catch(Exception e) {
            System.debug('Exception at GEDCaseCallout.gedCaseCallout ' + e.getMessage());
            CalloutHelper.handleException(res, req, req.getBody(), totalTime, 'GED_Case', 'callout:GED_Case', e);
        }
        DebugService.printLimits('GEDCaseCallout', 'gedCaseCallout', 'end');
        return new List<Case>();
    }
}