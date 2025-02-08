/**
 * @File Name          : gl_CustomLookupController_Test.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 2/7/2020, 15:15:03
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2/7/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
@isTest
private class gl_CustomLookupController_Test {
    static testMethod void performSearchByFields_Test() {
        gl_CustomLookupController lookup = new gl_CustomLookupController();
        Id [] fixedSearchResults= new Id[9];

        List<Account> accList = XC_DF_Account.createResidentialAccounts(4);
        accList[1].Phone = '7777';
        insert accList;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        contactList[1].Phone = '1111';
        insert contactList;
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(2);
        leadList[1].Email = 'test2@gmail.com';
        insert leadList;
        fixedSearchResults[0] = contactList[0].Id;
        fixedSearchResults[1] = contactList[1].Id;
        fixedSearchResults[2] = contactList[2].Id;
        fixedSearchResults[3] = contactList[3].Id;
        fixedSearchResults[4] = accList[0].Id;
        fixedSearchResults[5] = accList[1].Id;
        fixedSearchResults[6] = accList[2].Id;
        fixedSearchResults[7] = leadList[0].Id;
        fixedSearchResults[8] = leadList[1].Id; 

        Test.setFixedSearchResults(fixedSearchResults);         

        PageReference pageRef = Page.gl_CustomLookup;   
        pageRef.getParameters().put('lksrch','');
        pageRef.getParameters().put('ixnId','1234567');
        pageRef.getParameters().put('inServiceCloudConsole','false');
        pageRef.getParameters().put('frm','');
        pageRef.getParameters().put('txt','');
        Test.setCurrentPage(pageRef);
        
        lookup.performSearchByFields('Phone', '1111');
        //System.assert(lookup.contact_results.size() != 0);
        
        lookup.performSearchByFields('Phone', '7777');
        ////System.assert(lookup.account_results.size() != 0);
        
        lookup.performSearchByFields('Email', 'test2@gmail.com');
        //System.assert(lookup.lead_results.size() != 0);
                
        lookup.searchString = '4444';
        lookup.firstName = 'Pat';
        lookup.lastName = 'Ty';
        lookup.email = 'test@gmail.com';
        PageReference pr = lookup.search(); 
        
    }  
    
    static testMethod void search_Test() {
    PageReference pageRef = Page.gl_CustomLookup;   
        pageRef.getParameters().put('lksrch','test');
        pageRef.getParameters().put('ixnId','1234567');
        pageRef.getParameters().put('searchFieldName','Name');
        pageRef.getParameters().put('searchFieldValue','test');
        pageRef.getParameters().put('searchFieldsMap','{"test":"test"}');
        Test.setCurrentPage(pageRef);
        gl_CustomLookupController lookup = new gl_CustomLookupController();
        Id [] fixedSearchResults= new Id[9];
        List<Account> accList = XC_DF_Account.createResidentialAccounts(4);
        accList[1].Phone = '7777';
        insert accList;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        contactList[1].Phone = '1111';
        insert contactList;
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(2);
        leadList[1].Email = 'test2@gmail.com';
        insert leadList;
        fixedSearchResults[0] = contactList[0].Id;
        fixedSearchResults[1] = contactList[1].Id;
        fixedSearchResults[2] = contactList[2].Id;
        fixedSearchResults[3] = contactList[3].Id;
        fixedSearchResults[4] = accList[0].Id;
        fixedSearchResults[5] = accList[1].Id;
        fixedSearchResults[6] = accList[2].Id;
        fixedSearchResults[7] = leadList[0].Id;
        fixedSearchResults[8] = leadList[1].Id; 
        
        Test.setFixedSearchResults(fixedSearchResults);
        
        lookup.searchString = '7777';
        lookup.firstName = 'Pat';
        lookup.lastName = 'Ty';
        lookup.email = 'test@gmail.com';
        PageReference pr = lookup.search();     
        System.debug('*** results = ' + lookup.contact_results);
        //System.assert(lookup.lead_results.size() != 0);
        //System.assert(lookup.contact_results.size() != 0);
        //System.assert(lookup.account_results.size() != 0);
    } 
}