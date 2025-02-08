/**
 * Created by snekkanti002 on 06/10/2021.
 */

public without sharing class SigeudCallout {
    public static ResponseSigeud sigeudCallout(String fiscalCodePersonAccount) {
        DebugService.printLimits('SigeudCallout', 'sigeudCallout', 'start');
        System.debug('fiscalCodePersonAccount ' + fiscalCodePersonAccount);
        CalloutHelper.setStartTime();
        Long totalTime;
        Http http = new Http();
        HttpResponse res = null;

        ResponseSigeud responseSigeud = new ResponseSigeud();
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        HttpRequest req = CalloutHelper.initializeRequest('callout:SIGEUD/'+fiscalCodePersonAccount, 'GET', 30000, 'application/json', 'Bearer '+accessToken, 'application/json', null);
        DebugService.printRequest('SigeudCallout', 'sigeudCallout', req);

        try {
            totalTime = CalloutHelper.getTotalTime();
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'Sigeud','callout:SIGEUD/'+fiscalCodePersonAccount, '');

            DebugService.printResponse('SigeudCallout', 'sigeudCallout', res);

            if(res.getStatusCode() == 200) {
                System.debug('Entered Response OK');
                responseSigeud = (ResponseSigeud) System.JSON.deserialize(parseResponse(res.getBody()), ResponseSigeud.class);
            }
        } catch(Exception e) {
            DebugService.printException('SigeudCallout', 'sigeudCallout', e);
            CalloutHelper.handleException(res, req, req.getBody(), totalTime, 'Sigeud', 'callout:SIGEUD/'+fiscalCodePersonAccount, e);
        }

        return responseSigeud;
    }

    public static String parseResponse(String response) {
        String parsedResponse = '';
        JSONParser parser = JSON.createParser(response);

        while(parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                parsedResponse += '\"' + parser.getText().replaceAll('-', '_') + '\":';
            } else if(parser.getCurrentToken() == JSONToken.VALUE_STRING || parser.getCurrentToken() == JSONToken.VALUE_FALSE || parser.getCurrentToken() == JSONToken.VALUE_TRUE || parser.getCurrentToken() == JSONToken.VALUE_NUMBER_FLOAT || parser.getCurrentToken() == JSONToken.VALUE_NUMBER_INT || parser.getCurrentToken() == JSONToken.VALUE_NULL) {
                parsedResponse += '\"' + parser.getText() + '\",';
            } else if(parser.getCurrentToken() == JSONToken.END_OBJECT || parser.getCurrentToken() == JSONToken.END_ARRAY) {
                parsedResponse = parsedResponse.removeEnd(',');
                parsedResponse += parser.getText() + ',';
            } else {
                parsedResponse += parser.getText();
            }
        }
        parsedResponse = parsedResponse.removeEnd(',');
        System.debug('parsedResponse ' + parsedResponse);

        return parsedResponse;
    }
}