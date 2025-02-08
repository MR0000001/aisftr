/**
 * Created by snekkanti002 on 09/09/2021.
 */

@RestResource(UrlMapping='/OpenDataResponseHandler/*')
global without sharing class OpenDataResponseHandler {

    @HttpPost
    global static void doPost() {
        DebugService.printLimits('OpenDataResponseHandler', 'doPost', 'start');
        ResponseOpenDataWebService responseOpenDataWebService = new ResponseOpenDataWebService();
        responseOpenDataWebService.Esiti = new List<ResponseOpenDataWebService.Esiti>();
        RequestOpenDataWebService request = new RequestOpenDataWebService();

        try {
            request = (RequestOpenDataWebService) JSON.deserialize(RestContext.request.requestBody.toString(), RequestOpenDataWebService.class);
            Map<String, RequestOpenDataWebService.Esiti> outcomeIdOutcomeMap = new Map<String, RequestOpenDataWebService.Esiti>();

            System.debug('request -> ' + request);
            for(RequestOpenDataWebService.Esiti esiti : request.Esiti) {
                outcomeIdOutcomeMap.put(esiti.Id, esiti);
                ResponseOpenDataWebService.Esiti outcome = new ResponseOpenDataWebService.Esiti();
                outcome.Esito = '1';
                outcome.Id = esiti.Id;
                responseOpenDataWebService.Esiti.add(outcome);
            }
            List<String> notFoundIds = OpenDataService.createOpenDataLogs(outcomeIdOutcomeMap);
            DebugService.printList('OpenDataResponseHandler', 'doPost', 'notFoundIds', notFoundIds);

            if(!notFoundIds.isEmpty()) {
                System.debug('Entered notFoundIds not empty');
                for(ResponseOpenDataWebService.Esiti e : responseOpenDataWebService.Esiti) {
                    if(notFoundIds.contains(e.Id)) {
                        System.debug('Entered notFoundIds contains ' + e.Id);
                        e.Esito = '0';
                    }
                }
            }

            String response = JSON.serialize(responseOpenDataWebService);

            HttpResponse httpResponse = CalloutHelper.setHttpResponse('OK', 200, response, null, 'OpenDataResponseHandler', 'doPost try');
            RestResponse restResponse = CalloutHelper.setRestResponse(200, response, new Map<String, String>{'Content-Type' => 'application/json'}, 'OpenDataResponseHandler', 'doPost try');

            CalloutLoggerService.initializeUpdateCalloutLog(null, httpResponse, JSON.serialize(request), 0, '', 'OpenDataResponseHandler','','');
        } catch(Exception e) {
            DebugService.printException('OpenDataResponseHandler', 'doPost', e);
            ErrorLogEventHandler.standardExceptionLog(e);

            ResponseOpenDataWebService.Esiti outcome = new ResponseOpenDataWebService.Esiti();
            outcome.Esito = '0';
            responseOpenDataWebService.Esiti.add(outcome);

            String response = JSON.serialize(responseOpenDataWebService);

            HttpResponse httpResponse = CalloutHelper.setHttpResponse(e.getMessage().abbreviate(100), 500, response, null, 'OpenDataResponseHandler', 'doPost catch');
            RestResponse restResponse = CalloutHelper.setRestResponse(500, response, new Map<String, String>{'Content-Type' => 'application/json'}, 'OpenDataResponseHandler', 'doPost catch');

            CalloutLoggerService.initializeUpdateCalloutLog(null, httpResponse, JSON.serialize(request), 0, '', 'OpenDataResponseHandler','','');
        }
        DebugService.printLimits('OpenDataResponseHandler', 'doPost', 'end');
    }
}