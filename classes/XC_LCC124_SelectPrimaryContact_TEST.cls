/**
* TEST Class for XC_LCC124_SelectPrimaryContact
* @author Francesco Imperioli - fimperioli@deloitte.it
* @description test class for XC_LCC124_SelectPrimaryContact component
*/
@isTest
public  class XC_LCC124_SelectPrimaryContact_TEST {

    @TestSetup
    static void setup(){
        
        List<Account> accList = XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<Contact> cons = XC_DF_Contact.createResidentialContacts(accList);
        insert cons;

    }

    @isTest
    static void test1(){
        List<Account> accs = [SELECT ID FROM Account LIMIT 1];
        Test.startTest();
            XC_LCC124_SelectPrimaryContact.getContactListFromAccount(accs[0].Id);
        Test.stopTest();
    }

    @isTest
    static void test2(){
        List<Account> accs = [SELECT ID FROM Account LIMIT 1];
        Test.startTest();
        XC_LCC124_SelectPrimaryContact.getContactListFromAccountWithAdministrator(accs[0].Id);
        Test.stopTest();
    }

    @isTest
    static void test3(){
        List<Account> accs = [SELECT ID FROM Account LIMIT 1];
        List<Contact> cons = [SELECT ID FROM Contact LIMIT 1];
        Test.startTest();
        XC_LCC124_SelectPrimaryContact.updatePrimaryContact(cons[0].Id,accs[0].Id);
        Test.stopTest();
    }

    @isTest
    static void test4(){
        List<Account> accs = [SELECT ID FROM Account LIMIT 1];
        List<Contact> cons = [SELECT ID FROM Contact LIMIT 1];
        Test.startTest();
        XC_LCC124_SelectPrimaryContact.updateAdministrator(cons[0].Id,accs[0].Id);
        Test.stopTest();
    }

}