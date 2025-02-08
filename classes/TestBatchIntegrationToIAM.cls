/**
 * Created by snekkanti002 on 22/11/2022.
 */

@IsTest
public without sharing class TestBatchIntegrationToIAM {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        TestDataFactory.createIamBatchSetting();
        TestDataFactory.createAccounts();
    }

    @IsTest
    public static void batchIntegrationToIAM() {
        List<Account> accounts = [SELECT Date_Time_Sent_To_IAM__pc, ToBeSentIAM__pc, PersonEmail, PersonHomePhone, PersonMobilePhone, Fax, Fiscal_Code__pc FROM Account];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseIAM());

        Test.startTest();
        BatchIntegrationToIAM batch = new BatchIntegrationToIAM();
        Database.executeBatch(batch, 200);
        batch.execute(null, accounts);

        System.schedule('BatchIntegrationToIAM', '0 17 * ? * * *', batch);
        Test.stopTest();
    }
}