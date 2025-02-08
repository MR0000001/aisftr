/**
 * Created by SNEKKANTI00 on 11/03/2021.
 */

@isTest
public with sharing class TestMailUpCreateSMSCallout {
    @testSetup
    public static void setup() {
        // TestDataFactory.createServiceAppointments();
    }

    @isTest
    public static void mailUpCreateSMSCalloutTest() {
        List<SMSWrapper> smsWrappers = TestDataFactory.createSMSWrapper();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpCreateSMS());

        Test.startTest();
        MailUpCreateSMSCallout.mailUpCreateSMSCallout(smsWrappers[0]);
        Test.stopTest();
    }

    @isTest
    public static void mailUpCreateSMSCalloutKOTest() {
        // List<ServiceAppointment> serviceAppointments = TestDataFactory.createServiceAppointments();
        List<SMSWrapper> smsWrappers = TestDataFactory.createSMSWrapper();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpKO());

        Test.startTest();
        //MailUpCreateSMSCallout.mailUpCreateSMSCallout(serviceAppointments[0].Id, '1', 'Nuovo', '12345', null, null, true, 'test subject', 'test body');
        SMSWrapper smsWrapper = new SMSWrapper();
        MailUpCreateSMSCallout.mailUpCreateSMSCallout(smsWrappers[0]);
        Test.stopTest();
    }
}