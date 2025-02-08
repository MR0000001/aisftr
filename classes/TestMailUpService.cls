/**
 * Created by snekkanti002 on 11/07/2022.
 */

@IsTest
public with sharing class TestMailUpService {

    @IsTest
    public static void createMailRecords() {
        MailUpService.FlowInput input = new MailUpService.FlowInput();
        input.fromAddress = 'test@test.com';
        input.fromName = 'test';
        input.subject = 'test';
        input.toAddress = 'test2@test.com';

        Test.startTest();
        MailUpService.createMailRecords(new List<MailUpService.FlowInput>{input});
        Test.stopTest();
    }
}