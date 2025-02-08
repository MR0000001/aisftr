/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  09/05/2019 
* @description XC_TR_Account_U_DeleteChildren_TEST – Test class for XC_TR_Account_U_DeleteChildren
*/ 
@isTest
private class XC_TR_Account_U_DeleteChildren_TEST {
    
    static testMethod void onDelete() {
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        insert accounts;
        List<Account> listInsertedAccounts = [SELECT Name FROM Account];
        System.assertEquals(1, listInsertedAccounts.size());
        
        Test.startTest();
        delete accounts;
		Test.stopTest();        
    }
}