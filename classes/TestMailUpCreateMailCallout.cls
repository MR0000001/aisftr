/**
 * Created by SNEKKANTI00 on 10/03/2021.
 */

@isTest
public with sharing class TestMailUpCreateMailCallout {

    @isTest
    public static void mailUpCreateMailCalloutTest() {
        List<MailUpMailWrapper> mailUpMailWrappers = TestDataFactory.createMailUpMailWrappers();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpCreateMail());

        Test.startTest();
        MailUpCreateMailCallout.mailUpCreateMailCallout(mailUpMailWrappers[0]);
        Test.stopTest();
    }

    @isTest
    public static void mailUpCreateMailCalloutKOTest() {
        List<MailUpMailWrapper> mailUpMailWrappers = TestDataFactory.createMailUpMailWrappers();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseMailUpKO());

        Test.startTest();
        MailUpCreateMailCallout.mailUpCreateMailCallout(mailUpMailWrappers[0]);
        Test.stopTest();
    }
}