/**
 * Created by SNEKKANTI00 on 27/04/2021.
 */

@isTest
public with sharing class TestEmailMessageService {

    @TestSetup
    public static void setup() {
        TestDataFactory.createEmailMessages();
    }

    @isTest
    public static void insertEmailMessages() {
        List<EmailMessage> emailMessages = [SELECT Id, Subject, Status FROM EmailMessage];
        List<MailUpMailWrapper> mailUpMailWrappers = TestDataFactory.createMailUpMailWrappers();

        Test.startTest();
        EmailMessageService.insertEmailMessages(emailMessages, true);
        EmailMessageService.insertEmailMessages(emailMessages, false);

        EmailMessageService.createEmailMessages(mailUpMailWrappers[0]);
        Test.stopTest();
    }
}