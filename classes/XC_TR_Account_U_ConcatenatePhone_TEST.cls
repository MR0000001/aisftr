/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  03/05/2019 
* @description XC_TR_Account_U_ConcatenatePhone_TEST – Test class for XC_TR_Lead_U_HandleMapping
*/ 
@isTest
private  class XC_TR_Account_U_ConcatenatePhone_TEST {
    
    static testMethod void onInsert() {
        Test.startTest();
        List<Account> accountsWithoutPhone = XC_DF_Account.createResidentialAccounts(100);
        List<Account> accountWithPhone = new List<Account>();
        insert accountsWithoutPhone;
        List<Account> listInsertedAccounts = [SELECT Name FROM Account];
        Integer i = 0;
        for(Account accountToInsert : listInsertedAccounts) {
            Account newAccount = new Account();
            newAccount.Name = accountToInsert.Name + i;
            newAccount.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
            newAccount.IdentityType__c='Passport';
            newAccount.IdentityNumber__c='38729173'+ (Math.random()*Math.random()) + i;
            newAccount.PrimaryEmail__c = 'test_r' + (Math.random()*Math.random()) + '@email' + i + '.com'; 
            newAccount.XC_AccountPhonePrefix__c = '+39';
            newAccount.XC_MainPhonePrefix__c = '+39';
            newAccount.XC_AccountPhone__c = '07980988' + i;
            newAccount.XC_AccountMainPhone__c = '01090388' + i;
            i++;
            accountWithPhone.add(newAccount);
        }

        
        
        insert accountWithPhone;
        
        System.assertEquals(100, accountsWithoutPhone.size());
        System.assertEquals(100, accountWithPhone.size());
        Test.stopTest();
    }
    
    static testMethod void onUpdate() {
        insert XC_DF_Account.createResidentialAccounts(100);
        List<Account> listInsertedAccount = [SELECT Id FROM Account];
        System.assertEquals(listInsertedAccount.size(), 100);
        
        Test.startTest();
        Integer i = 0;
        for(Account acc : listInsertedAccount){
            acc.XC_AccountPhonePrefix__c = '+61';
            acc.XC_AccountPhone__c = '199191' + i;
            acc.XC_MainPhonePrefix__c = '+61';
            acc.XC_AccountMainPhone__c = '919991' + i;
            i++;
        }
        update listInsertedAccount;
        System.assertEquals(listInsertedAccount.size(), 100);
        Test.stopTest();
    }
}