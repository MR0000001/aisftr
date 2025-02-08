@isTest
public class XC_AMP_LCC010_OrderComposer_TEST {

    @TestSetup
    static void setup(){
        List<Account> partnerAccountList = XC_DF_Account.insertPartnerAccounts(1);
        List<Contact> partnerContactList = XC_DF_Contact.createPartnerContacts(partnerAccountList);
        insert partnerContactList;

        User communityUser = XC_DF_User.createAutomotiveCommunityUsers(partnerContactList,false)[0];
        insert communityUser;
        
        /*List<XC_Address__c> address =  XC_DF_Address.createAddress(partnerAccountList);
        insert address;
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunityWithoutVisit(partnerContactList,address[0]);
        opp[0].XC_LegalEntity__c = 'EnelXItalia';
        insert opp;*/
    }

    @isTest
    static void initOrderComposer(){
        
        Test.startTest();
        	List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        	accounts[0].XC_Segment__c = 'B2C';
         	accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
        	insert accounts;
        
        	List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        	contacts[0].XC_CountryLegalEntity__c = 'Italy';
            contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        	contacts[0].XC_Segment__c = 'B2C';
        	insert contacts;
        	
        	List<XC_Address__c> address =  XC_DF_Address.createItalianAddress(accounts);
        	insert address;
        
        	List<Opportunity> opp = XC_DF_Opportunity.createOpportunityWithVisit(contacts, address[0]);
        	opp[0].XC_LegalEntity__c = 'EnelXItalia';
            opp[0].XC_Segment__c = 'B2C';
        	opp[0].XC_ProductCategoryOfInterest__c = 'Maintenance & Repair';
        	opp[0].XC_IsSimplifiedSales__c = true;
        	insert opp;
        	
            Map<String,Object> params = new Map<String,Object>();
            params.put('isFullFlow',false);
            params.put('opportunityId',opp[0].Id);
        
            Map<String,Object> result = XC_AMP_LCC010_OrderComposer.initOrderComposer(params); 
            System.assert(result!=null && !result.isEmpty());
        test.stopTest();
    }

    @isTest
    static void initOrderComposer_FullFlow(){
        
        Test.startTest();
        	List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        	accounts[0].XC_Segment__c = 'B2C';
         	accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
        	insert accounts;
        
        	List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        	contacts[0].XC_CountryLegalEntity__c = 'Italy';
            contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        	contacts[0].XC_Segment__c = 'B2C';
        	insert contacts;
        	
        	List<XC_Address__c> address =  XC_DF_Address.createItalianAddress(accounts);
        	insert address;
        
        	List<Opportunity> opp = XC_DF_Opportunity.createOpportunityWithVisit(contacts, address[0]);
        	opp[0].XC_LegalEntity__c = 'EnelXItalia';
            opp[0].XC_Segment__c = 'B2C';
        	opp[0].XC_ProductCategoryOfInterest__c = 'Maintenance & Repair';
        	opp[0].XC_IsSimplifiedSales__c = true;
        	insert opp;
        	
            Map<String,Object> params = new Map<String,Object>();
            params.put('isFullFlow',true);
            params.put('opportunityId',opp[0].Id);
        	
            Map<String,Object> result = XC_AMP_LCC010_OrderComposer.initOrderComposer(params); 
            System.assert(result!=null && !result.isEmpty());
        test.stopTest();
    }
}