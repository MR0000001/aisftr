/**
 * Created by SNEKKANTI00 on 09/03/2021.
 */

public with sharing class MailUpSendSMSCallout {
    public static Boolean mailUpSendSMSCallout(SMSWrapper smsWrapper, Integer messageId) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;

        RequestMailUpSendSMS reqJson = new RequestMailUpSendSMS(smsWrapper.phoneNumber, smsWrapper.prefixPhoneNumber, messageId);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setTimeout(30000);
        req.setHeader('Content-Length', smsWrapper.contentLength);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(
                'callout:MailUp'+'/Sms/Send'
        );
        req.setBody(JSON.serialize(reqJson).replace('Number_x', 'Number'));

        HttpResponse respHttp = null;
        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            respHttp = http.send(req);
            smsWrapper.calloutLoggers.add(CalloutLoggerService.createCalloutLog(req, respHttp, req.getBody(), totalTime, '', 'MailUp', 'callout:MailUp',''));

            if(respHttp.getStatusCode() == 200) {
                ResponseMailUpSendSMS respMailUp = (ResponseMailUpSendSMS) JSON.deserialize(respHttp.getBody(), ResponseMailUpSendSMS.class);

                return false;
            } else smsWrapper.error = respHttp.getBody();
        } catch(Exception e) {
            System.debug('Exception at MailUpSendMailCallout.mailUpSendMailCallout ' + e.getMessage());

            smsWrapper.error = e.getMessage();
            Error_Log_Event__e errorEvent = null;
            if (respHttp == null) {
                smsWrapper.calloutLoggers.add(CalloutLoggerService.createCalloutLog(req, null, req.getBody(), totalTime, '', 'MailUp', 'callout:MailUp',''));
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            smsWrapper.errorLogEvents.add(errorEvent);
        }
        return true;
    }
}