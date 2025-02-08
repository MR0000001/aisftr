/**
 * Created by SNEKKANTI00 on 14/07/2021.
 */

@RestResource(UrlMapping='/GEDUpdateAttachment/')
global without sharing class GEDUpdateAttachment {

    @HttpPost
    global static void doPost() {
        DebugService.printLimits('GEDUpdateAttachment', 'doPost', 'start');
        String cvId = '';
        String numeroAllegato = '';
        RequestGEDAttachment requestGEDAttach = new RequestGEDAttachment();
        ResponseGEDAttachment responseGEDAttach = new ResponseGEDAttachment();
        String finalResponseGEDAttach;

        try {
            requestGEDAttach = (RequestGEDAttachment) System.JSON.deserialize(RestContext.request.requestBody.toString(), RequestGEDAttachment.class);
            System.debug('requestGEDAttach -> '+requestGEDAttach);
            cvId = (String) requestGEDAttach.id;
            numeroAllegato = requestGEDAttach.numeroAllegato;
            String errorCode = requestGEDAttach.errorCode;
            String errorMessage = requestGEDAttach.errorMessage;

            if(String.isNotEmpty(cvId)) {
                responseGEDAttach.Id = cvId;
                System.debug('cvId is not empty ' + cvId);
                if(String.isNotEmpty(numeroAllegato)) {
                    System.debug('numeroAllegato is not empty ' + numeroAllegato);
                    ContentVersion contentVersion = new ContentVersion(
                            Id = cvId,
                            NumberGED__c = numeroAllegato,
                            IntegrationResult_GED__c = 1,
                            TimeStampGED__c = System.now(),
                            BlockChangesGED__c = false,
                            GedErrorDescription__c = null
                    );
                    UPDATE contentVersion;

                    //response
                    responseGEDAttach.Esito = '1';
                    responseGEDAttach.numeroAllegato = numeroAllegato;

                    List<Case> cases = CaseService.processGEDUpdateAttachment(new List<String>{
                            cvId
                    });

                    DebugService.printList('GEDUpdateAttachment', 'doPost', 'cases', cases);

                    UPDATE cases;

                    ContentVersionToGedService.deleteContentVersionToGedsByCvIds(new List<String>{cvId}, false);
                } else {
                    System.debug('numeroAllegato is empty');
                    String error = (String.isNotEmpty(errorCode) ? errorCode : '') + (String.isNotEmpty(errorMessage) ? ': '  + errorMessage : '');
                    error = String.isNotEmpty(error) ? error : 'Error in response';
                    ContentVersion contentVersion = new ContentVersion(
                            Id = cvId,
                            GedErrorDescription__c = error,
                            BlockChangesGED__c = false
                    );
                    UPDATE contentVersion;
                    responseGEDAttach.Esito = '0';
                    ContentVersionToGedService.checkContentVersionsToGedRetryabilityAndDoDml(new List<String>{cvId}, false);
                }
            } else {
                System.debug('cvId is empty');
            }

            System.debug('responseGEDAttach -> '+responseGEDAttach.toString());
            finalResponseGEDAttach = JSON.serialize(responseGEDAttach);
            System.debug('finalResponseGEDAttach -> '+finalResponseGEDAttach);

            HttpResponse httpResponse = CalloutHelper.setHttpResponse('OK', 200, finalResponseGEDAttach, null,  'GEDUpdateAttachment',' doPost try');

            RestResponse restResponse = CalloutHelper.setRestResponse(200, finalResponseGEDAttach, new Map<String, String>{'Content-Type' => 'application/json'},  'GEDUpdateAttachment',' doPost try');

            CalloutLoggerService.initializeUpdateCalloutLog(null, httpResponse, RestContext.request.requestBody.toString(), 0, '', 'GEDUpdateAttachment','','');
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('GEDUpdateAttachment', 'doPost', e);

            responseGEDAttach.Esito = '0';
            finalResponseGEDAttach = JSON.serialize(responseGEDAttach);

            HttpResponse httpResponse = CalloutHelper.setHttpResponse(e.getMessage().abbreviate(100), 500, finalResponseGEDAttach, null, 'GEDUpdateAttachment',' doPost catch');

            RestResponse restResponse = CalloutHelper.setRestResponse(500, finalResponseGEDAttach, new Map<String, String>{'Content-Type' => 'application/json'}, 'GEDUpdateAttachment',' doPost catch');

            CalloutLoggerService.initializeUpdateCalloutLog(null, httpResponse, RestContext.request.requestBody.toString(), 0, '', 'GEDUpdateAttachment','','');
        }
        DebugService.printLimits('GEDUpdateAttachment', 'doPost', 'end');
    }
}