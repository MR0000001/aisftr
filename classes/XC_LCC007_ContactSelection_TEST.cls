/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  13/05/2019 
* @description XC_LCC007_ContactSelection_TEST – Test class for XC_LCC007_ContactSelection
*/ 
@isTest
public class XC_LCC007_ContactSelection_TEST {
    //Test method getContactListFromAccount
    static testMethod void getContactListFromAccount(){
    	insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        String accountId = accList[0].Id;

        List<Contact> result = XC_LCC007_ContactSelection.getContactListFromAccount(accountId);
        Test.stopTest();
        }
    

}