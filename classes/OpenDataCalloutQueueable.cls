/**
 * Created by snekkanti002 on 05/08/2021.
 */

public without sharing class OpenDataCalloutQueueable implements Queueable, Database.AllowsCallouts {
    private static Map<String, OpenData_Setting__mdt> settings = OpenData_Setting__mdt.getAll();
    private static Map<String, String> settingIdQueryMap = OpenDataService.getSettingIdQueryMap();
    private static Callout_Common_Settings__mdt commonCalloutSettings = Callout_Common_Settings__mdt.getInstance('Opendata');

    public void execute(QueueableContext qc) {
        CalloutHelper.setStartTime();
        HttpRequest req = null;
        HttpResponse res = null;
        RequestOpenData request = new RequestOpenData(settings, settingIdQueryMap);
        ResponseOpenData responseOpenData = new ResponseOpenData();

        req = createHTTPRequest(JSON.serialize(request));

        if(req != null) {
            System.debug('Request is not null');
            try {
                res = callout(req);
                if(res != null && res.getStatusCode() == 200) {
                    System.debug('Entered responseOpenData OK');
                    responseOpenData = (ResponseOpenData) JSON.deserialize(res.getBody(), ResponseOpenData.class);
                    System.debug('responseOpenData ' + responseOpenData);
                }
            } catch(Exception e) {
                ErrorLogEventHandler.standardExceptionLog('OpenDataCalloutQueueable', 'execute', e);
            }
        }

        DebugService.printLimits('OpenDataCalloutQueueable', 'execute', 'end');
    }

    private static HttpRequest createHTTPRequest(String reqJson) {
        DebugService.printLimits('OpenDataCalloutQueueable', 'createHTTPRequest', 'start');
        HttpRequest req = null;

        try {
            String accessToken = WSO2AuthCallout.WSO2AuthCallout();
            if(String.isNotBlank(accessToken)) {
                req = CalloutHelper.initializeRequest(commonCalloutSettings.Endpoint__c, commonCalloutSettings.Method__c, Integer.valueOf(commonCalloutSettings.Timeout_Value__c), commonCalloutSettings.Header_Content_Type__c, commonCalloutSettings.Auth_Type__c + ' ' + accessToken, commonCalloutSettings.Header_Accept_Type__c, reqJson);
                DebugService.printRequest('OpenDataCalloutQueueable', 'createHTTPRequest', req);
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('OpenDataCalloutQueueable', 'createHTTPRequest', e);
        }
        DebugService.printLimits('OpenDataCalloutQueueable', 'createHTTPRequest', 'end');

        return req;
    }

    private static HttpResponse callout(HttpRequest req) {
        DebugService.printLimits('OpenDataCalloutQueueable', 'callout', 'start');
        Long totalTime = null;
        HttpResponse res = null;
        try {
            totalTime = CalloutHelper.getTotalTime();
            res = new Http().send(req);
            DebugService.printResponse('OpenDataCalloutQueueable', 'callout', res);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', commonCalloutSettings.Label, commonCalloutSettings.Endpoint__c, '');
        } catch(Exception e) {
            DebugService.printException('OpenDataCalloutQueueable', 'callout', e);
            CalloutHelper.handleException(res, req, req.getBody(), totalTime, commonCalloutSettings.Label, commonCalloutSettings.Endpoint__c, e);
        }
        DebugService.printLimits('OpenDataCalloutQueueable', 'callout', 'end');

        return res;
    }
}