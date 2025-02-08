/**
 * Created by SNEKKANTI00 on 11/03/2021.
 */

@isTest
public with sharing class TestMailUpSendMailCallout {

    @isTest
    public static void mailUpSendMailCalloutTest() {
        List<MailUpMailWrapper> mailUpMailWrappers = TestDataFactory.createMailUpMailWrappers();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpSendMail(false));

        Test.startTest();
        MailUpSendMailCallout.mailUpSendMailCallout(mailUpMailWrappers[0], '1');
        Test.stopTest();
    }

    @isTest
    public static void mailUpSendMailCalloutTestException() {
        List<MailUpMailWrapper> mailUpMailWrappers = TestDataFactory.createMailUpMailWrappers();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpSendMail(true));

        Test.startTest();
        MailUpSendMailCallout.mailUpSendMailCallout(mailUpMailWrappers[0], '1');
        Test.stopTest();
    }
}