/**
 * Created by SNEKKANTI00 on 07/07/2021.
 */

@IsTest
public with sharing class TestBrogliaccioPullBatch {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createCasesBrogliaccioPull();
        TestDataFactory.createBatchPullSettings();
    }

    @IsTest
    public static void testBrogliaccioPullBatchOK() {
        TestDataFactory.createBatchPullSettings();
        List<Case> cases = [SELECT Id, Last_Batch_Date_Time__c, CreatedDate, Case_Specification__c, ExternalSystemId_Brogliaccio__c, Comment_User__c, Sent_to_External__c, ClosedDate__c FROM Case];

        Test.startTest();
        BrogliaccioPullBatch batch = new BrogliaccioPullBatch();
        Database.executeBatch(batch, 200);
        batch.execute(null, cases);
        System.schedule('TestBrogliaccioPullBatch', '0 17 * ? * * *', new BrogliaccioPullBatch());
        Test.stopTest();
    }

    @IsTest
    public static void testBrogliaccioPullBatchKO() {
        Test.startTest();
        Database.executeBatch(new BrogliaccioPullBatch(), 200);
        System.schedule('TestBrogliaccioPullBatch', '0 17 * ? * * *', new BrogliaccioPullBatch());
        Test.stopTest();
    }
}