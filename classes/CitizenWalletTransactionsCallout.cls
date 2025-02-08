/**
 * Created by SNEKKANTI00 on 07/06/2021.
 */

public with sharing class CitizenWalletTransactionsCallout {
    public static ResponseCitizenWalletTransactions citizenWalletTransactionsCallout(String cardCode) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        HttpRequest req = new HttpRequest();
        String accessToken = WSO2AuthCallout.WSO2AuthCallout();
        req.setMethod('GET');
        req.setTimeout(30000);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setHeader(System.Label.CitizenWallets_OriginHeaderKey, System.Label.CitizenWallets_OriginHeaderValue);
        req.setHeader(System.Label.CitizenWallets_DomecVersionHeaderKey, System.Label.CitizenWallets_DomecVersionHeaderValue);

        req.setEndpoint(
                'callout:Citizen_Wallets/'+cardCode+'/transactions'
        );
        Http http = new Http();
        HttpResponse res = null;

        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'Card Info','callout:Citizen_Wallets/'+cardCode+'/transactions','');
            System.debug('res.getBody() ' + res.getBody());
            System.debug('res.getStatusCode() ' + res.getStatusCode());
            ResponseCitizenWalletTransactions responseCitizenWalletTransactions = new ResponseCitizenWalletTransactions();
            if(res.getStatusCode() == 200) {
                responseCitizenWalletTransactions = (ResponseCitizenWalletTransactions) System.JSON.deserialize(res.getBody(), ResponseCitizenWalletTransactions.class);
            } else if(res.getStatusCode() == 400 || res.getStatusCode() == 404) {
                responseCitizenWalletTransactions = (ResponseCitizenWalletTransactions) System.JSON.deserialize(res.getBody(), ResponseCitizenWalletTransactions.class);
            }

            return responseCitizenWalletTransactions;
        } catch(Exception e) {
            System.debug('Exception at CitizenWalletTransactionsCallout: ' + e.getMessage());
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'Card Info', 'callout:Citizen_Wallets/'+cardCode+'/transactions', '');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }
        return new ResponseCitizenWalletTransactions();
    }
}