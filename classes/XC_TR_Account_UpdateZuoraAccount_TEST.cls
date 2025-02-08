@isTest
public class XC_TR_Account_UpdateZuoraAccount_TEST {
    @testSetup static void setup() {
        // Init Custom Setting
       	Zuora_OAuth__c zoa = new  Zuora_OAuth__c();
        zoa.EntityName__c = 'Enel Spain B2C';
        zoa.Client_Id__c = '123456'; 
        zoa.Client_Secret__c = '78910'; 
        zoa.EntityId__c = '1234567890764332';
        zoa.Host__c = 'rest.sandbox.eu.zuora.com';
        zoa.apiToken__c = '171173687168716368713718736183';

        insert zoa;
    }
    
	@isTest
    public static void testUpdate1(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> bpli = [select id,XC_Account__c from XC_BillingProfileLineItem__c limit 1];
        
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(1);
        listOfContact[0].AccountId = bpli[0].XC_Account__c;
        insert listOfContact;
        
        XC_Address__c address = XC_DF_Address.createAddress(1)[0];
        address.XC_Account__c =  bpli[0].XC_Account__c;
        insert address;
        
        bp[0].XC_Segment__c = 'B2B'; 
        bp[0].XC_LegalEntity__c = 'EnelXItalia';
        update bp;
        Zuora__CustomerAccount__c ca = new 	Zuora__CustomerAccount__c();
        ca.Zuora__Zuora_Id__c = '123456';//8adcba9c75e5b1dd01761ee90d2479b0';
        ca.Zuora__Account__c = bpli[0].XC_Account__c;
        insert ca;
        
        Test.startTest();
        	bpli[0].XC_BillToContactId__c = listOfContact[0].Id;
            bpli[0].XC_SoldToContactId__c = listOfContact[0].Id;
            bpli[0].XC_BillToAddress__c = address.Id;
            bpli[0].XC_SoldToAddress__c = address.Id;
            bpli[0].XC_RecipientCodeB2B__c = '1234567';
        	bpli[0].XC_CustomerAccount__c = ca.Id;
        	bpli[0].XC_LegalEntity__c = 'EnelXItalia';
            update bpli;
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdate2(){
        Test.setMock(HttpCalloutMock.class, new ZuoraWebservice_Mock_TEST());
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<NE__Billing_Profile__c> bp = XC_DF_BillingProfile.createBillingProfile(1);
        List<XC_BillingProfileLineItem__c> bpli = [select id,XC_Account__c from XC_BillingProfileLineItem__c limit 1];
        
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(1);
        listOfContact[0].AccountId = bpli[0].XC_Account__c;
        insert listOfContact;
        
        XC_Address__c address = XC_DF_Address.createAddress(1)[0];
        address.XC_Account__c =  bpli[0].XC_Account__c;
        insert address;
        
        bp[0].XC_Segment__c = 'B2B'; 
        bp[0].XC_LegalEntity__c = 'EnelXItalia';
        update bp;
        Zuora__CustomerAccount__c ca = new 	Zuora__CustomerAccount__c();
        ca.Zuora__Zuora_Id__c = '123456';//8adcba9c75e5b1dd01761ee90d2479b0';
        ca.Zuora__Account__c = bpli[0].XC_Account__c;
        insert ca;
        bpli[0].XC_BillToContactId__c = listOfContact[0].Id;
        bpli[0].XC_SoldToContactId__c = listOfContact[0].Id;
        bpli[0].XC_BillToAddress__c = address.Id;
        bpli[0].XC_SoldToAddress__c = address.Id;
        bpli[0].XC_RecipientCodeB2B__c = '1234567';
        bpli[0].XC_CustomerAccount__c = ca.Id;
        bpli[0].XC_LegalEntity__c = 'EnelXItalia';
        update bpli;
        Test.startTest();
            Account acc = [select id from Account where id = :bpli[0].XC_Account__c][0];
            acc.IdentityNumber__c = 'abcdefghilm';
        	acc.XC_Segment__c = 'B2B';
            update acc;
        Test.stopTest();
    }
}