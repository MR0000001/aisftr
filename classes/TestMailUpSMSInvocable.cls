/**
 * Created by SNEKKANTI00 on 16/03/2021.
 */

@isTest
public with sharing class TestMailUpSMSInvocable {

    @isTest
    public static void mailUpSMSInvocableTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpCreateMail());

        List<MailUpSMSInvocable.FlowInput> flowInputs = TestDataFactory.createMailUpSMSFlowInputs();

        Test.startTest();
        MailUpSMSInvocable.mailUpSMS(flowInputs);
        Test.stopTest();
    }
}