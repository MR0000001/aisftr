/**
 * Created by snekkanti002 on 23/09/2021.
 */

@RestResource(urlMapping='/BrogliaccioUpdateAttachment/')
global without sharing class BrogliaccioUpdateAttachment {

    @HttpPost
    global static void doPost() {
        DebugService.printLimits('BrogliaccioUpdateAttachment', 'doPost', 'start');

        RequestBrogliaccioWebService req = new RequestBrogliaccioWebService();
        ResponseBrogliaccioUpdateAttachment responseBrogliaccioUpdateAttachment = new ResponseBrogliaccioUpdateAttachment();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setBody(RestContext.request.requestBody.ToString());
        System.debug('httpReq Body ' + httpReq.getBody());

        try {
            ContentVersionService.handleBrogliaccioPostRequest();

            responseBrogliaccioUpdateAttachment.setEsito('1');
            String response = JSON.serialize(responseBrogliaccioUpdateAttachment);

            HttpResponse httpResponse = CalloutHelper.setHttpResponse('OK', 200, response, null, 'BrogliaccioUpdateAttachment', 'doPost try');

            RestResponse restResponse = CalloutHelper.setRestResponse(200, response, new Map<String, String>{'Content-Type' => 'application/json'}, 'BrogliaccioUpdateAttachment', 'doPost try');

            CalloutLoggerService.initializeUpdateCalloutLog(httpReq, httpResponse, httpReq.getBody(), 0, '', 'BrogliaccioUpdateAttachment','','');
        } catch(Exception e) {
            DebugService.printException('BrogliaccioUpdateAttachment', 'doPost', e);
            ErrorLogEventHandler.standardExceptionLog(e);

            responseBrogliaccioUpdateAttachment.setEsito('0');
            String response = JSON.serialize(responseBrogliaccioUpdateAttachment);

            HttpResponse httpResponse = CalloutHelper.setHttpResponse(e.getMessage().abbreviate(100), 500, response, null, 'BrogliaccioUpdateAttachment', 'doPost catch');

            RestResponse restResponse = CalloutHelper.setRestResponse(500, response, new Map<String, String>{'Content-Type' => 'application/json'}, 'BrogliaccioUpdateAttachment', 'doPost catch');

            CalloutLoggerService.initializeUpdateCalloutLog(httpReq, httpResponse, httpReq.getBody(), 0, '', 'BrogliaccioUpdateAttachment','','');
        }
        DebugService.printLimits('BrogliaccioUpdateAttachment', 'doPost', 'end');
    }
}