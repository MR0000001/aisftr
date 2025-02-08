@isTest
private class XC_MasheryAuth_Test {

    private static Map<String,String> authProviderConfiguration = new Map<String,String>{
        'ClientId__c' => '12345',
        'ClientSecret_c' => '67890',
        'Callback__c' => 'https://test.salesforce.com'
    };

    private static final String STATE = 'dummy';

    @isTest
    static void getCustomMetadataTypeTest() {
        XC_MasheryAuth ma = new XC_MasheryAuth();
        System.assert(ma.getCustomMetadataType() == 'XC_MasheryAuthCredential__mdt');
    }

    @isTest
    static void initiateTest() {
        XC_MasheryAuth ma = new XC_MasheryAuth();
        PageReference pr = ma.initiate(authProviderConfiguration, STATE);
        System.assert(pr.getUrl() == authProviderConfiguration.get('Callback__c') + '?state=' + STATE);
    }

    @isTest
    static void handleCallbackTest() {
        Test.setMock(HttpCalloutMock.class, new AuthMock());
        Map<String,String> queryParams = new Map<String,String>{
            'state' => authProviderConfiguration.get('State_c')
        };
        XC_MasheryAuth ma = new XC_MasheryAuth();
        Auth.AuthProviderTokenResponse tokenRes = ma.handleCallback(authProviderConfiguration, new Auth.AuthProviderCallbackState(null,null,queryParams));
        System.assert(tokenRes.oauthToken == '1234567890');
    }

    @isTest
    static void refreshTest() {
        Test.setMock(HttpCalloutMock.class, new AuthMock());
        XC_MasheryAuth ma = new XC_MasheryAuth();
        Auth.OAuthRefreshResult tokenRes = ma.refresh(authProviderConfiguration, null);
        System.assert(tokenRes.accessToken == '1234567890');
    }

    @isTest
    static void getUserInfoTest() {
        XC_MasheryAuth ma = new XC_MasheryAuth();
        ma.getUserInfo(null, null);
    }

    // MOCK
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
}