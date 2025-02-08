@isTest
public class XC_AMP_LCC021_RedirectSimplSales_TEST {
	
    @isTest
    static void evaluateRedirect_emptyOpp(){
        Test.startTest();
            XC_UTIL_ResultWrapper result = XC_AMP_LCC021_RedirectSimplifiedSales.evaluateRedirect(''); 
        
            XC_UTIL_ResultWrapper result1 = XC_AMP_LCC021_RedirectSimplifiedSales.evaluateRedirect('xxx');
        	
            System.assert(result!=null && !result.success);
            System.assert(result1!=null && !result1.success);
        test.stopTest();
    }
    
    @isTest
    static void evaluateRedirect_NotSimpleFlow(){
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
        	insert opp;
        
            XC_UTIL_ResultWrapper result = XC_AMP_LCC021_RedirectSimplifiedSales.evaluateRedirect(opp[0].Id); 
            System.assert(result!=null && !result.success);
        test.stopTest();
    }
    
    @isTest
    static void evaluateRedirect(){
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
        
            XC_UTIL_ResultWrapper result = XC_AMP_LCC021_RedirectSimplifiedSales.evaluateRedirect(opp[0].Id); 
            System.assert(result!=null && result.success);
        test.stopTest();
    }
}