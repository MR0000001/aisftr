/**
 * Created by snekkanti002 on 25/05/2022.
 */

public without sharing class IAMCallout {
    private static Callout_Common_Settings__mdt commonCalloutSettings = Callout_Common_Settings__mdt.getInstance('IAM');

    public static ResponseIAM iamCallout(List<Account> accounts) {
        DebugService.printLimits('IAMCallout', 'iamCallout', 'start');
        CalloutHelper.setStartTime();
        HttpRequest req = null;
        HttpResponse res = null;
        RequestIAM requestIAM = new RequestIAM(accounts);
        String reqJson = JSON.serialize(requestIAM);
        System.debug('requestIAM ' + requestIAM);
        System.debug('reqJson ' + reqJson);
        ResponseIAM responseIAM = null;

        req = createHTTPRequest(reqJson);

        if(req != null) {
            System.debug('Request is not null');
            res = callout(req);
            if(res != null && res.getStatusCode() == 200) {
                System.debug('Entered Response OK');
                responseIAM = (ResponseIAM) JSON.deserialize(res.getBody(), ResponseIAM.class);
                System.debug('responseIAM ' + responseIAM);
            }
        }

        DebugService.printLimits('IAMCallout', 'iamCallout', 'end');

        return responseIAM;
    }

    private static HttpRequest createHTTPRequest(String reqJson) {
        DebugService.printLimits('IAMCallout', 'createHTTPRequest', 'start');
        HttpRequest req = null;

        try {
            String accessToken = WSO2AuthCallout.WSO2AuthCallout();
            if(String.isNotBlank(accessToken)) {
                req = CalloutHelper.initializeRequest(commonCalloutSettings.Endpoint__c, commonCalloutSettings.Method__c, Integer.valueOf(commonCalloutSettings.Timeout_Value__c), commonCalloutSettings.Header_Content_Type__c, commonCalloutSettings.Auth_Type__c + ' ' + accessToken, commonCalloutSettings.Header_Accept_Type__c, reqJson);
                DebugService.printRequest('IAMCallout', 'createHTTPRequest', req);
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('IAMCallout', 'createHTTPRequest', e);
        }
        DebugService.printLimits('IAMCallout', 'createHTTPRequest', 'end');

        return req;
    }

    private static HttpResponse callout(HttpRequest req) {
        DebugService.printLimits('IAMCallout', 'callout', 'start');
        Long totalTime = null;
        HttpResponse res = null;

        try {
            totalTime = CalloutHelper.getTotalTime();
            System.debug('totalTime ' + totalTime);
            res = new Http().send(req);
            DebugService.printResponse('IAMCallout', 'callout', res);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', commonCalloutSettings.Label, commonCalloutSettings.Endpoint__c, '');
        } catch(Exception e) {
            DebugService.printException('IAMCallout', 'callout', e);
            CalloutHelper.handleException(res, req, req.getBody(), totalTime, commonCalloutSettings.Label, commonCalloutSettings.Endpoint__c, e);
        }
        DebugService.printLimits('IAMCallout', 'callout', 'end');

        return res;
    }
}