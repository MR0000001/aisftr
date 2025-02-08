/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation  08/05/2019 
* @description XC_TR_Account_U_CopyChannelOnUsers_TEST – Test class for XC_TR_Account_U_CopyChannelOnUsers
*/ 
@isTest
private class XC_TR_Account_U_CopyChannelOnUsers_TEST{ 

    static testMethod void populateChannelOnUsers() {
        List<Account> listAccounts = XC_DF_Account.insertPartnerAccounts(100);
        for(Account acc : listAccounts){
            acc.XC_ReceivingChannel__c = 'Resellers';
        }
        update listAccounts;
        List<Account> listInsertedAccounts = [SELECT Name FROM Account];
        System.assertEquals(100, listInsertedAccounts.size());
        
        Test.startTest();
        for(Account acc : listAccounts){
            acc.XC_ReceivingChannel__c = 'Web';
        }
        update listAccounts;
        Test.stopTest();
    }
}