/**
 * Created by snekkanti002 on 18/10/2021.
 */

@IsTest
public with sharing class TestSigeudCallout {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        List<Account> accounts = TestDataFactory.createAccounts();
        TestDataFactory.createSigeudContacts(accounts);
    }

    @IsTest
    public static void sigeudCallout() {
        String fiscalCodePersonAccount = [SELECT Fiscal_Code__pc FROM Account WHERE Fiscal_Code__pc != null LIMIT 1].Fiscal_Code__pc;

        List<String> accIds = new List<String>();

        for(Account acc : [SELECT Id FROM Account]) {
            accIds.add(acc.Id);
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSigeud());
        LegalEntitiesController.sigeudCallout(fiscalCodePersonAccount, accIds[0]);
        Test.stopTest();
    }
}