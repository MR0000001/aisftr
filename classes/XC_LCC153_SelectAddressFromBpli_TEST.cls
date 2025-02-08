/**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com 
* @date Creation 05/09/2019
* @date Modification 
* @description XC_LCC153_SelectAddressFromBpli_TEST 
*/  
@isTest
public class XC_LCC153_SelectAddressFromBpli_TEST {
    
     /**
* @author Lorenzo Orlanducci -lorenzo.orlanducci@nttdata.com 
* @description  Method to test retrieveQuoteId
*/
static testMethod void getAccountIdTest(){

     insert XC_DF_OneOrg.createOneOrg('Spain');
     Test.startTest();
    	
     NE__Billing_Profile__c billingProfile = XC_DF_BillingProfile.createBillingProfile(1)[0];
	
     XC_BillingProfileLineItem__c bpli = new XC_BillingProfileLineItem__c();
     List<Contact> contacts = XC_DF_Contact.createResidentialContacts(1);
     insert contacts;
     bpli.XC_SoldToContactId__c = contacts[0].Id;
     bpli.XC_BillingProfile__c = billingProfile.Id;
     insert bpli;
     XC_LCC153_SelectAddressFromBpli.getAccountId(bpli.id);
     Test.stopTest();
    
    
}

}