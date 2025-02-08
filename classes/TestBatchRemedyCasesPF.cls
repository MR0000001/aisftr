/**
 * Created by snekkanti002 on 15/12/2022.
 */

@IsTest
public without sharing class TestBatchRemedyCasesPF {
    @TestSetup
    public static void setup() {
        List<Account> accounts = TestDataFactory.createAccounts();
        String rtId = [SELECT Id FROM RecordType WHERE Name = 'Person Account Certificate' LIMIT 1].Id;

        for(Account a : accounts) {
            a.RecordTypeId = rtId;
        }

        update accounts;
    }

    @IsTest
    public static void execute() {
        Test.startTest();
        Database.executeBatch(new BatchRemedyCasesPF(), 200);
        Test.stopTest();
    }

    @IsTest static void testClass() {
        Test.startTest();
        System.schedule('TestBatchRemedyCasesPF', '0 0 0,2,4,6 * * ?', new BatchRemedyCasesPF());
        Test.stopTest();
    }
}