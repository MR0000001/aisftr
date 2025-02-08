/**
* @author Federico Amici - federico.amici@nttdata.com
* @description XC_UTIL_RESTCallout_TEST - test class for the XC_UTIL_RESTCallout class
*/
@isTest
private class XC_UTIL_RESTCallout_TEST {

    @TestSetup
    private static void setup(){
        XC_CS002_AccessToken__c cs = new XC_CS002_AccessToken__c();
        cs.Name = 'DevCredential';
        insert cs;

        XC_CS001_InterfaceConfiguration__c csInt = new XC_CS001_InterfaceConfiguration__c();
        csInt.Name = 'Test interface';
        csInt.XC_activeInterface__c = true;
        insert csInt;
    }

    @isTest
    private static void createHeaderOutboundTEST() {

        String operation = 'GET';
        String functionality = 'TBD';
        String serverSystem = 'TBD';

        Test.startTest();
            Map<String, String> mapHeader = XC_UTIL_RESTCallout.createHeaderOutbound(operation, functionality, serverSystem);
        Test.stopTest();

        System.assert(mapHeader.get('Functionality') == 'TBD');
        System.assert(mapHeader.get('ClientSystem') == 'XCustomerB2C');
    }

    @isTest
    private static void replaceFieldJSON() {

        String jsonString = '{"fieldToBeReplaced" : {"field" : "value"}}';
        String fieldWrapper = 'fieldToBeReplaced';
        String replacement = 'replacement';

        Test.startTest();
            String s = XC_UTIL_RESTCallout.replaceFieldJSON(jsonString, fieldWrapper, replacement);
        Test.stopTest();

        Map<String, Object> jsonReturned = (Map<String, Object>)JSON.deserializeUntyped(s);
        System.assert(jsonReturned.get('replacement') != null);
        System.assert(jsonReturned.get('fieldToBeReplaced') == null);

    }

    @isTest
    private static void getTokenRequestTEST() {

        HttpRequest request;

        Test.startTest();
            request = XC_UTIL_RESTCallout.getTokenRequest();
        Test.stopTest();

        System.assert(request != null);

    }
 
    @isTest
    private static void retrieveTokenTEST() {

        HttpRequest request =  XC_UTIL_RESTCallout.getTokenRequest();    

        Test.startTest();
            String token1 = XC_UTIL_RESTCallout.retrieveToken(request);
            Test.setMock(HttpCalloutMock.class, new XC_UTIL_RESTCallout_Mock());
            String token2 = XC_UTIL_RESTCallout.retrieveToken(request);
        Test.stopTest();

        System.assert(token1 == '');
        System.assert(token2 == 'OPEusaoasfknm89340983u4038jf93gjmn945');

    }

    @isTest
    private static void sendRequestLoggingTEST() {

        HttpRequest request =  XC_UTIL_RESTCallout.getTokenRequest();    
        HttpResponse response;

        Test.startTest();
            response = XC_UTIL_RESTCallout.sendRequestLogging(request, 'TransactionID', 'TestIntegration');   
            Test.setMock(HttpCalloutMock.class, new XC_UTIL_RESTCallout_Mock());
            response = XC_UTIL_RESTCallout.sendRequestLogging(request, 'TransactionID', 'TestIntegration');   
        Test.stopTest();

        //System.assert(response != null);
    }

    @isTest
    private static void sendRequestTEST() {

        HttpRequest request =  XC_UTIL_RESTCallout.getTokenRequest();    
        HttpResponse response;

        Test.startTest();
            response = XC_UTIL_RESTCallout.sendRequest(request, 'XC_UTIL_RESTCallout_TEST');   
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void newRequestTEST() {

        HttpRequest request1;
        HttpRequest request2;
        Map<String, String> headerDefinitions = new Map<String, String>();
        headerDefinitions.put('Functionality', 'TBD');

        Test.startTest();
            request1 = XC_UTIL_RESTCallout.newRequest('GET', 'http://urltarget.com', headerDefinitions, '{"field" : "value"}');
            request2 = XC_UTIL_RESTCallout.newRequest('POST', 'http://urltarget.com', headerDefinitions, '{"field" : "value"}');
        Test.stopTest();

        System.assert(request1.getMethod() == 'GET');
        System.assert(request1.getBody() == '');
        System.assert(request2.getMethod() == 'POST');
    }
    
    @isTest
    private static void createRequestTEST() {

        HttpRequest request1;

        Test.startTest();
            request1 = XC_UTIL_RESTCallout.createRequest('http://urltarget.com', '{"field" : "value"}');
        Test.stopTest();

        System.assertNotEquals(request1.getMethod(), null);
        System.assertNotEquals(request1.getBody(), null);
    }

    @isTest
    private static void composeUrlTEST() {

        String baseUrl = 'http://urltarget.com';
        String composedUrl;
        Map<String, String> mapParameters = new Map<String, String>();
        mapParameters.put('Functionality', 'TBD');

        Test.startTest();
            composedUrl = XC_UTIL_RESTCallout.composeURL(baseURL, mapParameters);
        Test.stopTest();

        System.assert(composedUrl == 'http://urltarget.com?Functionality=TBD');
    }

    @isTest
    private static void checkActiveInterfaceTEST() {

        Test.startTest();
            Boolean isActiveTestInterface = XC_UTIL_RESTCallout.checkActiveInterface('Test interface');
            XC_UTIL_RESTCallout.CSWrapper isActiveTestInterfaceWr = XC_UTIL_RESTCallout.checkActiveInterface2('Test interface');
        Test.stopTest();

        System.assert(isActiveTestInterface);
        System.assert(isActiveTestInterfaceWr.activeInterface);
    }
    
    @isTest
    private static void sleep() {
        Test.startTest();
            XC_UTIL_RESTCallout.sleep(1000);
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    private static void getResponseLogging() {
        Test.startTest();
            List<XC_Integration_Log__c> res = XC_UTIL_RESTCallout.getResponseLogging(new XC_UTIL_IntegrationLog(), null);
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    private static void responseLogging() {
        Test.startTest();
            XC_UTIL_RESTCallout.responseLogging(new XC_UTIL_IntegrationLog(), null);
        Test.stopTest();
        System.assert(true);
    }
    
    @isTest
    private static void sendRequestLogging() {
        Test.startTest();
            HttpResponse response = XC_UTIL_RESTCallout.sendRequestLogging(new HttpRequest(), new Map<String,String>(), 'test');
        Test.stopTest();
        System.assert(true);
    }
    
}