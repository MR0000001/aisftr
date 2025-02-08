/**
 * Created by SNEKKANTI00 on 11/03/2021.
 */

@isTest
public with sharing class TestMailUpSendSMSCallout {
    @testSetup
    public static void setup() {
        TestDataFactory.createCasesWithoutCities();
        // TestDataFactory.createServiceAppointments();
    }

    @isTest
    public static void mailUpSendSMSCalloutTest() {
        List<SMSWrapper> smsWrappers = TestDataFactory.createSMSWrapper();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpSendSMS(false));

        Test.startTest();
        MailUpSendSMSCallout.mailUpSendSMSCallout(smsWrappers[0], 1);
        Test.stopTest();
    }

    @isTest
    public static void mailUpSendSMSCalloutTestException() {
        List<SMSWrapper> smsWrappers = TestDataFactory.createSMSWrapper();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpSendSMS(true));

        Test.startTest();
        MailUpSendSMSCallout.mailUpSendSMSCallout(smsWrappers[0], 1);
        Test.stopTest();
    }

    @isTest
    public static void getCaseThreadIdByCaseIdTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpSendSMS(false));

        List<Case> cases = [SELECT id FROM Case];

        Test.startTest();
        List<GetThreadId.FlowInput> inputs = new List<GetThreadId.FlowInput>();
        GetThreadId.FlowInput input = new GetThreadId.FlowInput();
        input.caseId = cases[0].id;
        inputs.add(input);
        List<GetThreadId.FlowOutput> outputs = GetThreadId.getCaseThreadIdByCaseId(inputs);
        system.assert(outputs.size() > 0);
        Test.stopTest();
    }

}