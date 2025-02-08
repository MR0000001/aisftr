/**
 * Created by FMARCHEGIA00 on 09/02/2021.
 */

@IsTest
private class BatchDeleteAccountDraftTest {

    @TestSetup static void setup() {
        TestDataFactory.createAccountWithParams('PSDSRA37A61H501R');
        TestDataFactory.createAccountWithParams('PSDSRA37A61H501Z');
        List<Account> accs = [SELECT Id, isDraft__c FROM Account];
        System.debug('accs -> '+ accs);
        for (Account tmpAcc : accs) {
            tmpAcc.isDraft__c = true;
        }
        update accs;
        Contact con = new Contact();
        con.LastName =  'Tester';
        con.Persona_Fisica__c = accs[0].Id;
        insert con;
        TestDataFactory.createCasesWithAccountContact(accs[0].Id, con.Id);
    }

    @IsTest static void testClass() {
        Test.startTest();
        Database.executeBatch(new BatchDeleteAccountDraft(), 200);
        Test.stopTest();
        List<Account> resAccounts = [SELECT Id, isDraft__c FROM Account];
        System.debug('resAccounts -> ' + resAccounts);
        System.assertEquals(resAccounts.size(), 1);
        System.assertEquals(resAccounts[0].isDraft__c, false);
    }


}