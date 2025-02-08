/**
 * Created by SNEKKANTI00 on 16/03/2021.
 */

@isTest
public with sharing class TestMailUpMailInvocable {

    @isTest
    public static void mailUpMailInvocableTest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpCreateSMS());

        List<MailUpMailInvocable.FlowInput> flowInputs = TestDataFactory.createMailUpMailFlowInputs();

        Test.startTest();
        MailUpMailInvocable.mailUpMail(flowInputs);
        Test.stopTest();
    }
}