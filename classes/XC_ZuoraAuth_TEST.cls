/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 02-02-2021
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   02-02-2021   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public  class XC_ZuoraAuth_TEST {

    private static Map<String,String> authProviderConfiguration = new Map<String,String>{
        'XC_ClientId__c' => '12345',
        'XC_ClientSecret__c' => '67890',
        'XC_Callback__c' => 'https://test.salesforce.com'
    };

    private static final String STATE = 'dummy';


    private class AuthMock implements HttpCalloutMock {
        private String body = '{ "access_token": "1234567890" }';

        public HttpResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatus('SUCCESS');
            response.setStatusCode(200);
            response.setBody(body);
            return response;
        }
    }


    @isTest
    static void getCustomMetadataTypeTest() {
        XC_ZuoraAuth ma = new XC_ZuoraAuth();
        System.assert(ma.getCustomMetadataType() == 'XC_CM_ZuoraSingleAuth__mdt');
    }

    @isTest
    static void initiateTest() {
        XC_ZuoraAuth ma = new XC_ZuoraAuth();
        PageReference pr = ma.initiate(authProviderConfiguration, STATE);
        System.assert(pr.getUrl() == authProviderConfiguration.get('XC_Callback__c') + '?state=' + STATE);
    }

    @isTest
    static void handleCallbackTest() {
        Test.setMock(HttpCalloutMock.class, new AuthMock());
        Map<String,String> queryParams = new Map<String,String>{
            'state' => authProviderConfiguration.get('State_c')
        };
        XC_ZuoraAuth ma = new XC_ZuoraAuth();
        Auth.AuthProviderTokenResponse tokenRes = ma.handleCallback(authProviderConfiguration, new Auth.AuthProviderCallbackState(null,null,queryParams));
        System.assert(tokenRes.oauthToken == '1234567890');
    }

    @isTest
    static void refreshTest() {
        Test.setMock(HttpCalloutMock.class, new AuthMock());
        XC_ZuoraAuth ma = new XC_ZuoraAuth();
        Auth.OAuthRefreshResult tokenRes = ma.refresh(authProviderConfiguration, null);
        System.assert(tokenRes.accessToken == '1234567890');
    }

    @isTest
    static void getUserInfoTest() {
        XC_ZuoraAuth ma = new XC_ZuoraAuth();
        ma.getUserInfo(null, null);
    }

}