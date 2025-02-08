/**
 * Created by snekkanti002 on 11/11/2022.
 */

@IsTest
public without sharing class TestAutoreturnController {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }

    @IsTest
    public static void getVehicles() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseAutoreturn());

        Test.startTest();
        AutoreturnController.getVehicles('FK527MH');
        Test.stopTest();
    }

    @IsTest
    public static void getPageSize() {
        Test.startTest();
        try {
            AutoreturnController.getPageSize();
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('TestAutoreturnController', 'getPageSize', e);
        }
        Test.stopTest();
    }
}