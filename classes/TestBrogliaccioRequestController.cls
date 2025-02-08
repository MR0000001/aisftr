/**
 * Created by SNEKKANTI00 on 23/03/2021.
 */
@isTest
public with sharing class TestBrogliaccioRequestController {
    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
    }
    @isTest
    public static void sendRequestTest() {
        List<Case> cases = TestDataFactory.createCasesWithoutCities();
        Test.setMock(HttpCalloutMock.class, new MockResponseBrogliaccioCase(cases[0].Id, ''));
        Test.startTest();
        BrogliaccioRequestController.sendRequest(cases[0].id);
        Test.stopTest();
    }
}