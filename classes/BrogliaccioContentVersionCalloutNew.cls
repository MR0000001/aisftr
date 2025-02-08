/**
 * Created by snekkanti002 on 20/09/2021.
 */

public without sharing class BrogliaccioContentVersionCalloutNew {
    public static void brogliaccioContentVersionCallout(BrogliaccioCaseListWrapperNew brogliaccioCaseListWrapper) {
        DebugService.printLimits('BrogliaccioContentVersionCalloutNew', 'brogliaccioContentVersionCallout', 'start');
        CalloutHelper.setStartTime();
        Long totalTime;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        List<ContentVersion> contentVersions = new List<ContentVersion>();

        try {
            String accessToken = WSO2AuthCallout.WSO2AuthCallout();

            RequestContentVersionBrogliaccioNew reqsJSON = new RequestContentVersionBrogliaccioNew(brogliaccioCaseListWrapper);
            ResponseContentVersionBrogliaccioNew respContent = new ResponseContentVersionBrogliaccioNew();

            req = CalloutHelper.initializeRequest('callout:BROGLIACCIO_CV_NEW', 'POST', 60000, 'application/json', 'Bearer '+accessToken, 'application/json', JSON.serialize(reqsJSON));

            DebugService.printRequest('BrogliaccioContentVersionCalloutNew', 'brogliaccioContentVersionCallout', req);

            totalTime = CalloutHelper.getTotalTime();
            res = http.send(req);

            DebugService.printResponse('BrogliaccioContentVersionCalloutNew', 'brogliaccioContentVersionCallout', res);

            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'BROGLIACCIO_CV_NEW','callout:BROGLIACCIO_CV_NEW','');

            if(res.getStatusCode() == 200) {
                System.debug('Res is 200');
                respContent = (ResponseContentVersionBrogliaccioNew) System.JSON.deserialize(res.getBody(), ResponseContentVersionBrogliaccioNew.class);
                if(respContent.Esito.equalsIgnoreCase('1')) {
                    System.debug('Esito is 1');
                    for(List<ContentVersion> cvs : brogliaccioCaseListWrapper.caseIdCvsMap.values()) {
                        for(ContentVersion cv : cvs) {
                            System.debug('Updating Cv\'s field');
                            cv.Take_for_Brogliaccio__c = true;
                            contentVersions.add(cv);
                        }
                    }
                    ContentVersionService.updateContentVersions(contentVersions, false);
                    System.debug('Finished updating Cv\'s');
                }
            }
        } catch(Exception e) {
            DebugService.printException('BrogliaccioContentVersionCalloutNew', 'brogliaccioContentVersionCallout', e);
            CalloutHelper.handleException(res, req, req.getBody(), totalTime, 'BROGLIACCIO_CV_NEW', 'callout:BROGLIACCIO_CV_NEW', e);
        }
        DebugService.printLimits('BrogliaccioContentVersionCalloutNew', 'brogliaccioContentVersionCallout', 'end');
    }
}