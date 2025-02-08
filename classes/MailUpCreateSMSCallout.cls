/**
 * Created by SNEKKANTI00 on 09/03/2021.
 */

public with sharing class MailUpCreateSMSCallout {
    public static Boolean mailUpCreateSMSCallout(SMSWrapper smsWrapper) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        Boolean isFailed = true;

        String body = smsWrapper.smsBody;
        String subject = smsWrapper.smsSubject;
        smsWrapper.contentLength = String.valueOf(body.length());
        RequestMailUpCreateSMS reqJson = new RequestMailUpCreateSMS(subject, Integer.valueOf(smsWrapper.idList), body, '', false, '');

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setTimeout(30000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(
                'callout:MailUp'+'/Sms/List/'+smsWrapper.idList+'/Message'
        );
        req.setBody(JSON.serialize(reqJson));
        HttpResponse respHttp = null;
        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            respHttp = http.send(req);

            System.debug('mailUpCreateSMSCallout.getStatusCode() ' + respHttp.getStatusCode());
            System.debug('mailUpCreateSMSCallout.getBody() ' + respHttp.getBody());

            if(respHttp.getStatusCode() == 200) {
                ResponseMailUpCreateSMS respMailUp = (ResponseMailUpCreateSMS) JSON.deserialize(respHttp.getBody(), ResponseMailUpCreateSMS.class);
                Integer messageId = respMailUp.idMessage;
                isFailed = MailUpSendSMSCallout.mailUpSendSMSCallout(smsWrapper, messageId);

                if(!isFailed) SMSService.createSMSs(smsWrapper);
            } else smsWrapper.error = respHttp.getBody();
            smsWrapper.calloutLoggers.add(CalloutLoggerService.createCalloutLog(req, respHttp, req.getBody(), totalTime, '', 'MailUp', 'callout:MailUp',''));

            return isFailed;
        } catch(Exception e) {
            System.debug('Exception at MailUpCreateSMSCallout.mailUpCreateSMSCallout ' + e.getMessage());

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