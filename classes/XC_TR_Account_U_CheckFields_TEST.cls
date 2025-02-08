/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/03/2020
* @description XC_TR_Account_U_CheckFields_TEST – Test class for XC_TR_Account_U_CheckFields
*/  

@isTest
private class XC_TR_Account_U_CheckFields_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Account_U_CheckFields_TEST');

    @isTest
    static void onInsertedAccountWithoutError() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Account acc = XC_DF_Account.createResidentialAccounts(1)[0];
        acc.XC_BirthDate__c = Date.today().addYears(-100);
        acc.XC_GiveDataTo_EndesaX__c = true;

        Test.startTest();
        insert acc;
        acc = [SELECT Id, Name, XC_BirthDate__c FROM Account WHERE Id =: acc.Id];
        acc.XC_BirthDate__c = Date.today().addYears(-90);
        update acc;
        System.assertNotEquals(acc.Id, null);
        Test.stopTest();
    }

    @isTest
    static void onChangeNamePartnerAccount() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Account acc = XC_DF_Account.insertPartnerAccounts(1, 'Active')[0];

        Test.startTest();
        acc.Name = 'Test Name Changed';
        update acc;
        System.assertNotEquals(acc.Id, null);
        Test.stopTest();
    }


}