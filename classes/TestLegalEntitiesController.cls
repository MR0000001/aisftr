/**
 * Created by snekkanti002 on 18/10/2021.
 */

@IsTest
public with sharing class TestLegalEntitiesController {

    @TestSetup
    public static void setup() {
        TestDataFactory.createWSO2Keys();
        List<Account> accounts = TestDataFactory.createAccounts();
        TestDataFactory.createSigeudContacts(accounts);
    }

    @IsTest
    public static void getLegalEntities() {
        String fiscalCodePersonAccount = [SELECT Fiscal_Code__pc FROM Account WHERE Fiscal_Code__pc != null LIMIT 1].Fiscal_Code__pc;

        Test.startTest();
        LegalEntitiesController.getLegalEntities(fiscalCodePersonAccount);
        Test.stopTest();
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

    @IsTest
    public static void saveSigeudRecords() {
        LegalEntitiesController.SigeudContact sigeudContact = new LegalEntitiesController.SigeudContact();

        sigeudContact.firstName = 'test first name';
        sigeudContact.lastName = 'test last name';
        sigeudContact.role = 'test role';
        sigeudContact.roleDescription = 'test role description';
        sigeudContact.startDate = System.today();
        sigeudContact.endDate = System.today()+1;
        sigeudContact.sigeudDate = System.today();
        sigeudContact.isDeleted = false;
        sigeudContact.contactKey = 'FRRGNN41S21G513Y';
        sigeudContact.sigeudAccount = new LegalEntitiesController.SigeudAccount();
        sigeudContact.sigeudAccount.alreadyExists = true;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseSigeud());
        LegalEntitiesController.saveSigeudRecords(new List<LegalEntitiesController.SigeudContact>{sigeudContact});
        Test.stopTest();
    }

    @IsTest
    public static void checkUtil() {
        test.startTest();

        String stringTest = 'questo e\' un test?';
        Integer lenStringTest = stringTest.length()-2;
        String finalTest = LegalEntitiesController.removeSpecialCharacterForUrl(stringTest);
        system.assertEquals(finalTest.length(), lenStringTest);

        test.stopTest();
    }
}