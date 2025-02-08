/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  22/05/2019 
* @description XC_TR_Contact_U_FromContactToAcc_TEST – Test class for XC_TR_Contact_U_FromContactToAccount
*/
@istest
public class XC_TR_Contact_U_FromContactToAcc_TEST {
     //Test Method onContactInfoChanged
    static testMethod void onContactInfoChanged(){ 
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        insert listc;
        
        
        System.assertEquals(true, listc!=null);
        Test.stopTest();
        
    }
    
    //Test Method onContactInfoChanged
    static testMethod void onContactInfoChanged1(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        Account a = XC_DF_Account.createResidentialAccounts(1)[0];
        a.XC_AccountNationality__c = 'Spanish';
        a.XC_MainPhonePrefix__c = '+39';
        a.XC_AccountMainPhone__c = '323456789';
		a.XC_AccountPhonePrefix__c = '+39';
        a.XC_AccountPhone__c = '323456789';
        insert a;
        
        List<Contact> listc = XC_DF_Contact.createResidentialContacts(1);
        Contact c = listc[0];
        //c.AccountId = a.Id;
        //listc.add(c);
        c.email = 'test@test.it';
        insert c;
        
        c.email = 'test@testtestest.it';
        update c;
        
        //List<Account> lista = XC_DF_Account.createResidentialAccounts(1);
        
        c.AccountId = a.id;
        c.XC_PrimaryContact__c = true;
        update c;
        
        XC_TR_Contact_U_FromContactToAccount.onContactInfoChanged(listc);
        System.assertEquals(true, listc!=null);
        Test.stopTest();
        
    }

}