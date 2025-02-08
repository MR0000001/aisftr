/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 01-29-2021
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   01-29-2021   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
public without sharing class XC_ZuoraAuth extends Auth.AuthProviderPluginClass {

    private static final String AUTHORIZATION_CREDENTIAL = 'callout:XC_ZuoraAuth';
    private String authProvider = 'Zuora';
    private String tokenType = 'secret';

    public String getCustomMetadataType() {
        System.debug('XC_ZuoraAuth - getCustomMetadataType');
        return 'XC_CM_ZuoraSingleAuth__mdt';
    }

    public PageReference initiate(Map<String,String> authProviderConfiguration, String stateToPropagate) {
        System.debug('XC_ZuoraAuth - initiate');
        System.Debug('AUTH PROVIDER CONFIGURATION ' + authProviderConfiguration);
        return new PageReference(authProviderConfiguration.get('XC_Callback__c') + '?state=' + stateToPropagate);
    }

    public Auth.AuthProviderTokenResponse handleCallback(Map<String,String> authProviderConfiguration, Auth.AuthProviderCallbackState callbackState) {
        System.debug('XC_ZuoraAuth - handleCallback');
        return new Auth.AuthProviderTokenResponse(authProvider, retrieveToken(authProviderConfiguration), tokenType, callbackState.queryParameters.get('state'));
    }

    /**
     * refresh called if the first callout returns 401
     */
    public override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) {
        System.debug('XC_ZuoraAuth - refresh');
        return new Auth.OAuthRefreshResult(retrieveToken(authProviderConfiguration), tokenType);
    }

    private String retrieveToken(Map<String,String> authProviderConfiguration) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(AUTHORIZATION_CREDENTIAL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        //client_id and client_secrete retrieved from XC_MasheryAuth.namedCredential (saved as username and password)
        req.setBody('grant_type=client_credentials&client_id='+authProviderConfiguration.get('XC_ClientId__c')+'&client_secret=' + EncodingUtil.urlEncode(authProviderConfiguration.get('XC_ClientSecret__c'),'UTF-8'));

        System.Debug('REQUEST::: ' + req.getBody());

        HTTPResponse res = new Http().send(req);
        String jsonBody = res.getBody();
        Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        System.debug(body);
        return (String)body.get('access_token');
    }

    // non serve
    public Auth.UserData getUserInfo(Map<String,String> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {
        System.debug('getUserInfo');
        return new Auth.UserData(null, null, null, null, null, null, 'userName', null, authProvider, null, new Map<String,String>());
    }
    

}