/**
 * Created by snekkanti002 on 17/05/2022.
 */

public without sharing class AutoreturnCallout {
    private static Callout_Common_Settings__mdt commonCalloutSettings = Callout_Common_Settings__mdt.getInstance('Autoreturn');

    public static ResponseAutoreturn autoreturnCallout(String licencePlate) {
        DebugService.printLimits('AutoreturnCallout', 'autoreturnCallout', 'start');
        CalloutHelper.setStartTime();
        HttpRequest req = null;
        HttpResponse res = null;
        ResponseAutoreturn responsesAutoreturn = null;

        req = createHTTPRequest(licencePlate);

        if(req != null) {
            System.debug('Request is not null');
            try {
                res = callout(req);
                if(res != null && res.getStatusCode() == 200) {
                    System.debug('Entered Response OK');
                    responsesAutoreturn = (ResponseAutoreturn) JSON.deserialize(res.getBody(), ResponseAutoreturn.class);
                    System.debug('responsesAutoreturn ' + responsesAutoreturn);
                }
            } catch(Exception e) {
                ErrorLogEventHandler.standardExceptionLog('AutoreturnCallout', 'autoreturnCallout', e);
            }
        }

        DebugService.printLimits('AutoreturnCallout', 'autoreturnCallout', 'end');

        return responsesAutoreturn;
    }

    private static HttpRequest createHTTPRequest(String licencePlate) {
        DebugService.printLimits('AutoreturnCallout', 'createHTTPRequest', 'start');
        HttpRequest req = null;
        try {
            String accessToken = WSO2AuthCallout.WSO2AuthCallout();
            if(String.isNotBlank(accessToken)) {
            req = CalloutHelper.initializeRequest(commonCalloutSettings.Endpoint__c+licencePlate, commonCalloutSettings.Method__c, Integer.valueOf(commonCalloutSettings.Timeout_Value__c), commonCalloutSettings.Header_Content_Type__c, commonCalloutSettings.Auth_Type__c + ' ' + accessToken, commonCalloutSettings.Header_Accept_Type__c, '');
            DebugService.printRequest('AutoreturnCallout', 'createHTTPRequest', req);
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('AutoreturnCallout', 'createHTTPRequest', e);
        }
        DebugService.printLimits('AutoreturnCallout', 'createHTTPRequest', 'end');

        return req;
    }

    private static HttpResponse callout(HttpRequest req) {
        DebugService.printLimits('AutoreturnCallout', 'callout', 'start');
        Long totalTime = null;
        HttpResponse res = null;
        try {
            totalTime = CalloutHelper.getTotalTime();
            res = new Http().send(req);
            DebugService.printResponse('AutoreturnCallout', 'callout', res);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', commonCalloutSettings.Label, commonCalloutSettings.Endpoint__c, '');
        } catch(Exception e) {
            DebugService.printException('AutoreturnCallout', 'callout', e);
            CalloutHelper.handleException(res, req, req.getBody(), totalTime, commonCalloutSettings.Label, commonCalloutSettings.Endpoint__c, e);
        }
        DebugService.printLimits('AutoreturnCallout', 'callout', 'end');

        return res;
    }
}