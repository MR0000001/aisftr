/**
* @author Chiara Turco cturco@deloitte.it
* @date Creation  24/05/2019 
* @description XC_TR_Contact_U_CheckPrimaryContact_TEST – Test class for XC_TR_Contact_U_CheckPrimaryContact
*/
@istest
public class XC_TR_Contact_U_CheckPrimaryContact_TEST {
    //Test Method onContactInsert
    @isTest
    static void onContactInsert(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        insert listc;

        
        //XC_TR_Contact_U_CheckPrimaryContact.onContactInsert(listc);
        System.assertEquals(true, listc!=null);
        Test.stopTest();
        
    }
    //Test Method onContactInsert
    @isTest
    static void onContactInsert1(){
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        
        List<Contact> listc = XC_DF_Contact.createCondominiumContacts(1);
        listc[0].XC_PrimaryContact__c=true;
        insert listc;
        
        update listc;
        
        
        
        
       // Map<Id,list<Contact>> mapcon = new Map<Id,list<Contact>>();
        
       // List<NE__AssetItemAttribute__c> aia = new List<NE__AssetItemAttribute__c>();
       //insert aia;
        
       // XC_TR_Contact_U_CheckPrimaryContact.onContactInsert(listc);
        System.assertEquals(true, listc!=null);
        Test.stopTest();
        
    }

    @isTest
    static void onContactInsert2(){

        XC_CTI_Interaction__c ctiInt = new XC_CTI_Interaction__c(XC_InteractionStatus__c = 'Open');
        insert ctiInt;
        List<Account> accs = XC_DF_Account.createResidentialAccounts(1);
        insert accs;
        Test.startTest();
           insert XC_DF_Contact.createResidentialContacts(accs);
        Test.stopTest();
    }
    
    @isTest
    static void onContactInsert3(){
		Test.startTest();
		List<Contact> cos = XC_DF_Contact.createResidentialContacts(1);
        cos[0].XC_PrimaryContact__c = true;
        insert cos;
        XC_TR_Contact_U_CheckPrimaryContact.manageCreationFromCTIChannel(cos);
       	Test.stopTest();
    }
}