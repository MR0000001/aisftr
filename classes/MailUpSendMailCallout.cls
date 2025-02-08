/**
 * Created by SNEKKANTI00 on 08/03/2021.
 */

public with sharing class MailUpSendMailCallout {
    public static Boolean mailUpSendMailCallout(MailUpMailWrapper mailUpMailWrapper, String messageId) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setTimeout(30000);
        req.setHeader('Content-Length', '0');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(
                'callout:MailUp'+'/Group/'+mailUpMailWrapper.groupId+'/Email/'+messageId+'/Send'
        );

        HttpResponse respHttp = null;
        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            respHttp = http.send(req);
            mailUpMailWrapper.calloutLoggers.add(CalloutLoggerService.createCalloutLog(req, respHttp, req.getBody(), totalTime, '', 'MailUp', 'callout:MailUp',''));

            System.debug('mailUpSendMailCallout: ' + respHttp.getBody());
            if(respHttp.getStatusCode() == 200) {
                ResponseMailUpSendMail respMailUp = (ResponseMailUpSendMail) JSON.deserialize(respHttp.getBody(), ResponseMailUpSendMail.class);

                return false;
            } else {
                mailUpMailWrapper.error = respHttp.getBody();
            }

        } catch(Exception e) {
            System.debug('Exception at MailUpSendMailCallout.mailUpSendMailCallout ' + e.getMessage());

            mailUpMailWrapper.error = e.getMessage();
            Error_Log_Event__e errorEvent = null;
            if (respHttp == null) {
                mailUpMailWrapper.calloutLoggers.add(CalloutLoggerService.createCalloutLog(req, null, req.getBody(), totalTime, '', 'MailUp', 'callout:MailUp',''));
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            mailUpMailWrapper.errorLogEvents.add(errorEvent);
        }
        return true;
    }
}