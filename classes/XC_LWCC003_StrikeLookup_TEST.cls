@isTest
public without sharing class XC_LWCC003_StrikeLookup_TEST {

    @isTest
    static void strikeLookupTest(){
        List<Account> listOfAcc = XC_DF_Account.insertPartnerAccounts(5);
        XC_LWCC003_StrikeLookup.fetchLookupData('Test Account n','Account', 'Name');
        XC_LWCC003_StrikeLookup.fetchDefaultRecord(listOfAcc[0].Id,'Account');
    }

}