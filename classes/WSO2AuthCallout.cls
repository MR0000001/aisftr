public with sharing class WSO2AuthCallout {
    public static String WSO2AuthCallout() {
        WSO2Keys__c wso2k = WSO2KeysSelector.getWSO2Keys();
        String clientId;
        String clientSecret;
        if(wso2k != null){
            clientId = wso2k.Consumer_Key__c;
            clientSecret = wso2k.Consumer_Secret__c;
        }
        String auth = EncodingUtil.Base64Encode(Blob.valueOf(clientId+':'+clientSecret));
        String accessToken;
        HttpRequest req = new HttpRequest();

        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Basic '+auth);
        String request='grant_type=client_credentials';
        req.setBody(request);
        req.setEndpoint(
                'callout:WSO2Token'
        );
        Http http = new Http();
        try{
            HttpResponse res = http.send(req);
            if(res.getStatusCode()==200){
                Object result = (Object) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> tempMap = (Map<String, Object>) result;
                accessToken = (String) (tempMap.get('access_token'));
            }
        }catch(Exception e){
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e);               //true per dire che è eccezione
            // Call method to publish events
            Database.SaveResult results = ErrorLogEventHandler.publishEventDMLSafe(errorEvent);

        }
        return accessToken;
    }
}