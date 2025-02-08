/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @date Creation 15/05/2019
* @date Modification 15/05/2019 Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description XC_LCC001_SearchContact_TEST 
*/  
@isTest
public class XC_LCC001_SearchContact_TEST {

 /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com & Sara Miozza - sara.miozza@nttdata.com
* @description  Method to test getContactsList
*/
static testMethod void getContactsListTest(){

    insert XC_DF_OneOrg.createOneOrg('Spain');
    Test.startTest();
    	List<Contact> clist = XC_DF_Contact.createCondominiumContacts(1);
        insert clist;
        List<Contact> contactList = XC_LCC001_SearchContact.getContactsList('Account','Test','test_condominium@email.com');
        System.assert(!contactList.isEmpty());
    Test.stopTest();
    
   
    }
    
    
}