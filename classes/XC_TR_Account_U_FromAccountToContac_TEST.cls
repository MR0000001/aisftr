/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  06/05/2019 
* @description XC_TR_Account_U_FromAccountToContactTEST – Test class for XC_TR_Account_U_FromAccountToContact
*/ 
@isTest
private class XC_TR_Account_U_FromAccountToContac_TEST{
    
    
    static testMethod void onUpdate() {
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(1);
        List<Contact> contactToInsertList = new List<Contact>();
        List<String> accountIdList = new List<String>();
        for(Contact cont : contactList){
            cont.XC_PrimaryContact__c = true;
            contactToInsertList.add(cont);
        }
        insert contactToInsertList;
        
        for(Contact cont : contactToInsertList){
            accountIdList.add(cont.AccountId);
        }
        List<Account> accountList = [SELECT Id FROM Account WHERE Id IN : accountIdList];
        Test.startTest();
        Integer i = 0;        
        for(Account acc: accountList){
            acc.XC_AccountNationality__c = 'Italian';
            acc.PrimaryEmail__c = 'testfromaccounttocontact' + i + '@test.com';
            acc.XC_MainPhonePrefix__c = '+39';
            acc.XC_AccountMainPhone__c = '01011001' + i;
            acc.XC_AccountPhonePrefix__c = '+39';
            acc.XC_AccountPhone__c = '01011011' + i;
            i++;
        }
        update accountList;
        Test.stopTest();
        
    }
}