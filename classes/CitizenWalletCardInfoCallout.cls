/**
 * Created by SNEKKANTI00 on 07/06/2021.
 */

public with sharing class CitizenWalletCardInfoCallout {

    public static Map<String, Object> citizenWalletCardInfoCallout(String cardCode) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        List<Callout_logger__c> calloutLoggers = new List<Callout_logger__c>();
        HttpRequest req = new HttpRequest();
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        req.setMethod('GET');
        req.setTimeout(30000);
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Accept', 'application/json');
        req.setHeader(System.Label.CitizenWallets_OriginHeaderKey, System.Label.CitizenWallets_OriginHeaderValue);
        req.setHeader(System.Label.CitizenWallets_DomecVersionHeaderKey, System.Label.CitizenWallets_DomecVersionHeaderValue);

        req.setEndpoint(
                'callout:Citizen_Wallets/'+cardCode
        );
        Http http = new Http();
        HttpResponse res = null;

        try {
            Map<String, Object> returnResponse = new Map<String, Object>();
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            calloutLoggers.add(CalloutLoggerService.createCalloutLog(req, res, req.getBody(), totalTime, '', 'Card Info','callout:Citizen_Wallets/'+cardCode,''));
            System.debug('res.getBody() ' + res.getBody());
            System.debug('res.getStatusCode() ' + res.getStatusCode());
            ResponseCitizenWalletCardInfo responseCitizenWalletCardInfo = new ResponseCitizenWalletCardInfo();
            if(res.getStatusCode() == 200) {
                responseCitizenWalletCardInfo = (ResponseCitizenWalletCardInfo) System.JSON.deserialize(res.getBody(), ResponseCitizenWalletCardInfo.class);
                ResponseCitizenWalletTransactions responseCitizenWalletTransactions = CitizenWalletTransactionsCallout.citizenWalletTransactionsCallout(cardCode);
                returnResponse.put('Card', responseCitizenWalletCardInfo);
                returnResponse.put('Transactions', responseCitizenWalletTransactions);
            } else if(res.getStatusCode() == 400 || res.getStatusCode() == 404) {
                responseCitizenWalletCardInfo = (ResponseCitizenWalletCardInfo) System.JSON.deserialize(res.getBody(), ResponseCitizenWalletCardInfo.class);

                returnResponse.put('Card', responseCitizenWalletCardInfo);
            }

            CalloutLoggerService.insertCalloutLoggers(calloutLoggers, false);
            return returnResponse;
        } catch(Exception e) {
            System.debug('Exception at CitizenWalletCardInfoCallout getMessage: ' + e.getMessage());
            System.debug('Exception at CitizenWalletCardInfoCallout getStackTraceString: ' + e.getStackTraceString());
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'Card Info', 'callout:Citizen_Wallets/'+cardCode, '');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                 errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return new Map<String, Object>();
    }
}