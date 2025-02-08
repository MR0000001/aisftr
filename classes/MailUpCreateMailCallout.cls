/**
 * Created by SNEKKANTI00 on 08/03/2021.
 */

public with sharing class MailUpCreateMailCallout {
    public static Boolean mailUpCreateMailCallout(MailUpMailWrapper mailUpMailWrapper) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        String messageId;
        Boolean isFailed = true;

        RequestMailUpCreateMail reqJson = new RequestMailUpCreateMail(mailUpMailWrapper.templateSubject, mailUpMailWrapper.templateBody, false, false, null, null);

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setTimeout(30000);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(
                'callout:MailUp'+'/List/'+mailUpMailWrapper.listId+'/Email'
        );
        req.setBody(JSON.serialize(reqJson));
        HttpResponse respHttp = null;

        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            respHttp = http.send(req);
            System.debug('mailUpCreateMailCallout.getStatusCode() ' + respHttp.getStatusCode());
            System.debug('mailUpCreateMailCallout.getBody() ' + respHttp.getBody());
            if(respHttp.getStatusCode() == 200) {
                ResponseMailUpCreateMail respMailUp = (ResponseMailUpCreateMail) JSON.deserialize(respHttp.getBody(), ResponseMailUpCreateMail.class);
                messageId = String.valueOf(respMailUp.idMessage);
                if(mailUpMailWrapper.isForRecipient) {
                    isFailed = MailUpSendMailRecipientCallout.mailUpSendMailRecipientCallout(mailUpMailWrapper, messageId);
                } else {
                    isFailed = MailUpSendMailCallout.mailUpSendMailCallout(mailUpMailWrapper, messageId);
                }

                if(!isFailed) EmailMessageService.createEmailMessages(mailUpMailWrapper);
            } else mailUpMailWrapper.error = respHttp.getBody();

            mailUpMailWrapper.calloutLoggers.add(CalloutLoggerService.createCalloutLog(req, respHttp, req.getBody(), totalTime,'', 'MailUp', 'callout:MailUp', ''));

            return isFailed;
        } catch(Exception e) {
            System.debug('Exception at MailUpCreateMailCallout.mailUpCreateMailCallout ' + e.getMessage());

            mailUpMailWrapper.error = e.getMessage();
            Error_Log_Event__e errorEvent = null;
            if (respHttp == null) {
                mailUpMailWrapper.calloutLoggers.add(CalloutLoggerService.createCalloutLog(req, null, req.getBody(), totalTime, '', 'MailUp', 'callout:MailUp', ''));
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            mailUpMailWrapper.errorLogEvents.add(errorEvent);
        }
        return true;
    }
}