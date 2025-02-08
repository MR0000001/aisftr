/**
 * Created by SNEKKANTI00 on 12/07/2021.
 */

public without sharing class GEDContentVersionCallout {
    public static Boolean gedContentVersionCallout(Map<Case, List<ContentVersion>> caseCvsMap) {
        DebugService.printLimits('GEDContentVersionCallout', 'gedContentVersionCallout', 'start');
        System.debug('caseCvsMap ' + caseCvsMap);
        CalloutHelper.setStartTime();
        Long totalTime;
        Http http = new Http();
        HttpResponse res = null;

        RequestGEDContentVersionAcknowledgement requestGEDContentVersionAcknowledgement = new RequestGEDContentVersionAcknowledgement(caseCvsMap);
        ResponseGEDContentVersionAcknowledgement responseGEDContentVersionAcknowledgement = new ResponseGEDContentVersionAcknowledgement();

        String reqJson = JSON.serialize(requestGEDContentVersionAcknowledgement);
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        HttpRequest req = CalloutHelper.initializeRequest('callout:GED_Attachments', 'POST', 30000, 'application/json', 'Bearer '+accessToken, 'application/json', reqJson);
        system.debug('req -> '+ req);
        DebugService.printRequest('GEDContentVersionCallout', 'gedContentVersionCallout', req);
        System.debug('reqJson: ' + reqJson);
        System.debug('requestGEDContentVersionAcknowledgement: ' + requestGEDContentVersionAcknowledgement);

        try {
            totalTime = CalloutHelper.getTotalTime();
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'GED_Attachments','callout:GED_Attachments','');

            System.debug('res status: ' + res.getStatus());
            System.debug('res status code: ' + res.getStatusCode());
            System.debug('res body: ' + res.getBody());
            DebugService.printResponse('GEDContentVersionCallout', 'gedContentVersionCallout', res);

            if(res.getStatusCode() == 200) {
                System.debug('GEDContentVersionCallout res is success');
                responseGEDContentVersionAcknowledgement = (ResponseGEDContentVersionAcknowledgement) System.JSON.deserialize(res.getBody(), ResponseGEDContentVersionAcknowledgement.class);
                System.debug('responseGEDContentVersionAcknowledgement: ' + responseGEDContentVersionAcknowledgement);

                if(responseGEDContentVersionAcknowledgement.Esito.equalsIgnoreCase(System.Label.GED_ContentVersionAck)) {
                    System.debug('GEDContentVersionCallout esito is success');
                    return true;
                }
            }
        } catch(Exception e) {
            System.debug('Exception at GEDContentVersionCallout.gedContentVersionCallout ' + e.getMessage());
            CalloutHelper.handleException(res, req, req.getBody(), totalTime, 'GED_Attachments', 'callout:GED_Attachments', e);
        }
        DebugService.printLimits('GEDContentVersionCallout', 'gedContentVersionCallout', 'end');
        return false;
    }
}