/**
 * Created by snekkanti002 on 24/02/2022.
 */

@IsTest
public without sharing class TestCalloutHelper {

    @IsTest
    public static void setStartTimeTest() {
        Test.startTest();
        CalloutHelper.setStartTime();
        Test.stopTest();
    }

    @IsTest
    public static void setFinishTimeTest() {
        Test.startTest();
        CalloutHelper.setFinishTime();
        Test.stopTest();
    }

    @IsTest
    public static void getTotalTimeTest() {
        Test.startTest();
        CalloutHelper.setStartTime();
        CalloutHelper.setFinishTime();
        CalloutHelper.getTotalTime();
        Test.stopTest();
    }

    @IsTest
    public static void initializeRequestTest() {
        Test.startTest();
        CalloutHelper.initializeRequest('testEndpoint', 'GET', 10000, 'application/json', 'bearer', 'application/json', '');
        Test.stopTest();
    }

    @IsTest
    public static void handleExceptionTest() {
        Test.startTest();
        try {
            Integer x = 1/0;
        } catch(Exception e) {
            CalloutHelper.handleException(null, null, '', null, '', '', e);
        }
        Test.stopTest();
    }

    @IsTest
    public static void setHttpResponseTest() {
        Test.startTest();
        CalloutHelper.setHttpResponse('OK', 200, '{"Esito":"1"}', null,  'TestCalloutHelper', 'setRestResponseTest');
        Test.stopTest();
    }

    @IsTest
    public static void setRestResponse() {
        Test.startTest();
        try {
            CalloutHelper.setRestResponse(200, '{"Esito":"1"}', null,  'TestCalloutHelper', 'setRestResponse');
        } catch (Exception e) {
            System.debug('Exception in TestCalloutHelper.setRestResponse: ' + e.getMessage());
        }
        Test.stopTest();
    }
}