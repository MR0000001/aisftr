/**
 * Created by SNEKKANTI00 on 13/04/2021.
 */

@isTest
public with sharing class TestMailUpSendMailRecipientCallout {
    @isTest
    public static void mailUpSendMailCalloutTest() {
        List<MailUpMailWrapper> mailUpMailWrappers = TestDataFactory.createMailUpMailWrappers();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpSendMail(false));

        Test.startTest();
        MailUpSendMailRecipientCallout.mailUpSendMailRecipientCallout(mailUpMailWrappers[0], '1');
        Test.stopTest();
    }

    @isTest
    public static void mailUpSendMailCalloutTestException() {
        List<MailUpMailWrapper> mailUpMailWrappers = TestDataFactory.createMailUpMailWrappers();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpSendMail(true));

        Test.startTest();
        MailUpSendMailRecipientCallout.mailUpSendMailRecipientCallout(mailUpMailWrappers[0], '1');
        Test.stopTest();
    }
}