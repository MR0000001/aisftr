/**
 * @description       : 
 * @author            : Francesco Imperioli - fimperioli@deloitte.it
 * @group             : 
 * @last modified on  : 12-22-2020
 * @last modified by  : Francesco Imperioli - fimperioli@deloitte.it
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   12-22-2020   Francesco Imperioli - fimperioli@deloitte.it   Initial Version
**/
@isTest
public class XC_AMP_LCC002_OrderMainView_TEST {

    @TestSetup
    static void setup(){
        //List<Account> accounts = XC_DF_Account.createResidentialAccounts(2);
        List<Account> accounts = XC_DF_Account.insertPartnerAccounts(2, Label.XC_CL_Account_StatusActive);
        //partnerAccountList[0].XC_AMP_LogoURL__c = 'test.com';
        //update partnerAccountList;

        accounts[0].XC_FirstName__c = 'TestAccount';
        accounts[0].XC_LastName__c = 'TestTestAccount';
        accounts[0].XC_ConfirmationByCustomer__c = false;
        accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
        accounts[0].XC_DocumentCountry__c = 'Italy';
        accounts[0].IdentityType__c ='CF';
        accounts[0].IdentityNumber__c = 'TSTTTC80A01H501R';
        accounts[0].XC_AMP_Partner__c = 'MERCEDES';
        accounts[1].XC_FirstName__c = 'FCATestAccount';
        accounts[1].XC_LastName__c = 'FCATestTestAccount';
        accounts[1].XC_ConfirmationByCustomer__c = false;
        accounts[1].XC_GiveDataTo_EnelXItalia__c = true;
        accounts[1].XC_DocumentCountry__c = 'Italy';
        accounts[1].IdentityType__c ='CF';
        accounts[1].IdentityNumber__c = 'FCTFTS80A01H501C';
        accounts[1].XC_AMP_Partner__c = 'FCA_Jeep';
        accounts[1].XC_AMP_AvailableCatalogCategories__c = 'Home Check';
        update accounts;

        List<Contact> contacts = XC_DF_Contact.createPartnerContacts(accounts);
       // List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        contacts[0].XC_CountryLegalEntity__c = 'Italy';
        contacts[0].FirstName = 'testContactAccount';
        contacts[0].LastName = 'testConatctAccount';
        contacts[1].XC_MainLegalEntity__c = 'EnelXItalia';
        contacts[1].XC_CountryLegalEntity__c = 'Italy';
        contacts[1].FirstName = 'FCATestAccount';
        contacts[1].LastName = 'FCATestTestAccount';
        insert contacts;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'Partner' order by LastModifiedDate  LIMIT 1];
            User communityUser = XC_DF_User.createAutomotiveCommunityUsers(contacts, false)[0];
            communityUser.XC_LegalEntity__c = 'EnelXItalia';
            communityUser.XC_EnabledToSkip__c = true;
            communityUser.Country__c = 'Italy';
            communityUser.XC_Document_Country__c = 'Italy';
            User communityUserFCA = XC_DF_User.createAutomotiveCommunityUsers(contacts, false)[1];
            communityUserFCA.XC_LegalEntity__c = 'EnelXItalia';
            communityUserFCA.XC_EnabledToSkip__c = true;
            communityUserFCA.Country__c = 'Italy';
            communityUserFCA.XC_Document_Country__c = 'Italy';
            insert new List<User>{
                    communityUser, communityUserFCA
            };

        }

        List<XC_Address__c> address =  XC_DF_Address.createAddress(accounts);
        insert address;
        
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunityWithoutVisit(contacts,address[0]);
        insert opp;
    }


    @isTest
    static void initNewCreationConfig_TEST(){
        User automotiveUser = [SELECT Id, AccountId, Account.XC_AMP_Partner__c FROM User WHERE Account.XC_AMP_Partner__c = 'MERCEDES' LIMIT 1];
        System.debug('Account: ' + automotiveUser.AccountId);
        System.debug('Account: ' + automotiveUser.Account.XC_AMP_Partner__c);
        
        System.runAs(automotiveUser){
            List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
            accounts[0].XC_FirstName__c = 'Test';
            accounts[0].XC_LastName__c = 'TestTest';
            accounts[0].XC_ConfirmationByCustomer__c = false;
            accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
            accounts[0].XC_DocumentCountry__c = 'Italy';
            accounts[0].IdentityType__c ='CF';
            accounts[0].IdentityNumber__c = 'TSTTST80A01F839I';
            accounts[0].XC_AMP_Partner__c = 'VOLVO';
        	insert accounts;
            
            automotiveUser.XC_AccountId__c = accounts[0].Id;
			update automotiveUser;
            
            List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
            contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        	contacts[0].XC_CountryLegalEntity__c = 'Italy';
            contacts[0].FirstName = 'testContact';
            contacts[0].LastName = 'testConatctL';
            insert contacts;
            
            List<XC_Address__c> address =  XC_DF_Address.createAddress(accounts);
            Test.startTest();
                XC_AMP_LCC002_OrderMainViewBuilder.initNewCreationConfig(accounts[0].RecordTypeId, null);
            Test.stopTest();
        }
    }
    
    @isTest
    static void initNewCreationConfig_WithExtraSections_TEST(){
        User automotiveUser = [SELECT Id, AccountId, Account.XC_AMP_Partner__c FROM User WHERE Account.XC_AMP_Partner__c = 'FCA_Jeep' LIMIT 1];
        System.debug('Account: ' + automotiveUser.AccountId);
        System.debug('Account: ' + automotiveUser.Account.XC_AMP_Partner__c);
        
        System.runAs(automotiveUser){
            List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
            accounts[0].XC_FirstName__c = 'Test';
            accounts[0].XC_LastName__c = 'TestTest';
            accounts[0].XC_ConfirmationByCustomer__c = false;
            accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
            accounts[0].XC_DocumentCountry__c = 'Italy';
            accounts[0].IdentityType__c ='CF';
            accounts[0].IdentityNumber__c = 'FCTFTS80A01H501C';
            accounts[0].XC_AMP_Partner__c = 'FCA_Jeep';
        	accounts[0].XC_AMP_AvailableCatalogCategories__c = 'Home Check';
        	insert accounts;
            
            automotiveUser.XC_AccountId__c = accounts[0].Id;
			update automotiveUser;
            
            List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
            contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        	contacts[0].XC_CountryLegalEntity__c = 'Italy';
            contacts[0].FirstName = 'testContact';
            contacts[0].LastName = 'testConatctL';
            insert contacts;
            
            List<XC_Address__c> address =  XC_DF_Address.createAddress(accounts);
            Test.startTest();
                XC_AMP_LCC002_OrderMainViewBuilder.initNewCreationConfig(accounts[0].RecordTypeId, null);
            	XC_AMP_UTIL_ViewConfiguration.getPartnerCatalogCategoriesInfos(new Map<String,Object>(), 'Home Check');
            Test.stopTest();
        }
    }
    
    
    @isTest
    static void initNewCreationConfigOpty_TEST(){
        User automotiveUser = [SELECT Id, AccountId, Account.XC_AMP_Partner__c FROM User WHERE Account.XC_AMP_Partner__c = 'MERCEDES' LIMIT 1];
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
        accounts[0].XC_FirstName__c = 'Test';
        accounts[0].XC_LastName__c = 'TestTest';
        accounts[0].XC_ConfirmationByCustomer__c = false;
        accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
        accounts[0].XC_DocumentCountry__c = 'Italy';
        accounts[0].IdentityType__c ='CF';
        accounts[0].IdentityNumber__c = 'TSTTST80A01F839I';
        accounts[0].XC_AMP_Partner__c = 'VOLVO';
        insert accounts;
        
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        contacts[0].XC_CountryLegalEntity__c = 'Italy';
        contacts[0].FirstName = 'testContact';
        contacts[0].LastName = 'testConatctL';
        insert contacts;
        
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accounts);
        insert address;
        List<Opportunity> opp = XC_DF_opportunity.createOpportunityWithVisit(contacts,address[0]);
        insert opp;
        System.runAs(automotiveUser){
            Test.startTest();
                XC_AMP_LCC002_OrderMainViewBuilder.initNewCreationConfig(null, opp[0].Id);
            Test.stopTest(); 
        }
    }
    
    public static Id createTestAccount(){
        List<Account> accounts = XC_DF_Account.createResidentialAccounts(2);
        accounts[0].XC_FirstName__c = 'TestDueAccount';
        accounts[0].XC_LastName__c = 'TestDueAccount';
        accounts[0].XC_ConfirmationByCustomer__c = false;
        accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
        accounts[0].XC_DocumentCountry__c = 'Italy';
        accounts[0].IdentityType__c ='CF';
        accounts[0].IdentityNumber__c = 'TSTTTD80A01H501S';
        accounts[0].XC_AMP_Partner__c = 'MERCEDES';
        accounts[0].XC_AMP_AvailableCatalogCategories__c = 'Home Check';
        insert accounts;
        
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
        contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        contacts[0].XC_CountryLegalEntity__c = 'Italy';
        contacts[0].FirstName = 'testContactAccount';
        contacts[0].LastName = 'testConatctAccount';
        insert contacts;
        
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accounts);
        insert address;

        return accounts[0].Id;
    }
    
    @isTest
    static void submitFirstStepSections_TEST(){
        User automotiveUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and IsActive=true and XC_LegalEntity__c='EnelXItalia' LIMIT 1];
     
        System.runAs(automotiveUser){
            List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
            accounts[0].XC_FirstName__c = 'PROVA';
            accounts[0].XC_LastName__c = 'PROVA';
            accounts[0].XC_ConfirmationByCustomer__c = false;
            accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
            accounts[0].XC_GiveDataTo_EnelXMSP__c = true;
            accounts[0].XC_DocumentCountry__c = 'Italy';
            accounts[0].IdentityType__c ='CF';
            accounts[0].IdentityNumber__c = 'PRVPRV80A01F839M';
            //accounts[0].XC_AMP_Partner__c = 'VOLVO';
            //insert accounts;
            
            List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
            contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
            contacts[0].XC_CountryLegalEntity__c = 'Italy';
            contacts[0].FirstName = 'testContact';
            contacts[0].LastName = 'testConatctL';
            //insert contacts;
      
            List<XC_Address__c> address =  XC_DF_Address.createAddress(accounts);
            //insert address;
            XC_AMP_Vehicle__c veh = new XC_AMP_Vehicle__c();
            List<String> accountFields = XC_UTIL_Sobject.getListAllFields('Account');
            List<XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper> sections = new List<XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper>();
            XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper section1 = new XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper();
            section1.recordTypeId = accounts[0].RecordTypeId;
            section1.sObjectName = 'Account';
            section1.sectionName = accounts[0].Name;
            Map<String,Object> mapAccount = new Map<String,Object>();
            for(String key : accountFields){
                mapAccount.put(key, accounts[0].get(key));
            }
            section1.fields = mapAccount;
            sections.add(section1);
                  
            XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper section2 = new XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper();
            section2.recordTypeId = contacts[0].RecordTypeId;
            section2.sObjectName = 'Contact';
            section2.sectionName = contacts[0].Name;
            section2.fields = new Map<String,Object>{
                'Contact' => contacts[0]};
                    sections.add(section2);
            
            XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper section3 = new XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper();
            section3.recordTypeId = address[0].RecordTypeId;
            section3.sObjectName = 'XC_Address__c';
            section3.sectionName = address[0].Name;
            section3.fields = new Map<String,Object>{
                'XC_Address__c' => address[0]};
                    sections.add(section3);
            
            XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper section4 = new XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper();
            section4.recordTypeId = accounts[0].RecordTypeId;
            section4.sObjectName = 'Account';
            section4.sectionName = accounts[0].Name;
            section4.fields = new Map<String,Object>{
                'Account' => accounts[0],
                    'XC_ConfirmationByCustomer__c' => 'false'};
                        sections.add(section4);
            
            XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper section5 = new XC_AMP_LCC002_OrderMainViewBuilder.SectionFieldsWrapper();
            section5.recordTypeId = 'recordtype';
            section5.sObjectName = 'XC_AMP_Vehicle__c';
            section5.sectionName = 'XC_AMP_Vehicle__c';
            section5.fields = new Map<String,Object>{
                //'XC_AMP_Vehicle__c' => veh,
                 'XC_AMP_ExpectedDeliveryDate__c'=>Date.today()};
            sections.add(section5);

            Map<String,Object> paramsInput = new Map<String,Object>();
            paramsInput.put('partnerAMP','VOLVO');
            paramsInput.put('isFullFlow',false);
            paramsInput.put('segment','B2C');
            
            Test.startTest();
            XC_AMP_LCC002_OrderMainViewBuilder.submitFirstStepSections(sections, paramsInput); 
            Test.stopTest();
            
        }
    }
    
    
     @isTest
    static void submitVehicle_TEST(){
        User automotiveUser = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'XC_ITA_AutomotiveAgent' LIMIT 1];
        List<Opportunity> opp = [Select Id FROM Opportunity LIMIT 1];
        System.debug('opp: '+ opp[0]);
        
        System.runAs(automotiveUser){
            
            Id accResidentialRtId =  Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
            List<Account> accounts = XC_DF_Account.createSohoAccounts(1);
            accounts[0].XC_FirstName__c = 'Test';
            accounts[0].XC_LastName__c = 'TestTest';
            accounts[0].XC_ConfirmationByCustomer__c = false;
            accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
        	insert accounts;
            
            List<Contact> contacts = XC_DF_Contact.createSohoContacts(accounts);
            contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        	contacts[0].XC_CountryLegalEntity__c = 'Italy';
            contacts[0].FirstName = 'testContact';
            contacts[0].LastName = 'testConatctL';
            insert contacts;
            
            XC_AMP_Vehicle__c veh = new XC_AMP_Vehicle__c();
            Map<String,Object> mapVeh = new Map<String,Object>{
                'XC_AMP_ExpectedDeliveryDate__c'=>Date.today()};           
            Test.startTest();
                XC_AMP_LCC002_OrderMainViewBuilder.createAccountVehicleFromSection(accounts[0].Id,mapVeh, 'VOLVO');
            Test.stopTest();
        }
    }
   
     @isTest
    static void opportunityChild_TEST(){
        User automotiveUser = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'XC_ITA_AutomotiveAgent' LIMIT 1];
        XC_AMP_Vehicle__c veh = new XC_AMP_Vehicle__c();
        insert veh;
        List<Opportunity> opp = [Select Id FROM Opportunity LIMIT 1];
        opp[0].XC_AMP_Vehicle__c = veh.Id;
        System.debug('opp: '+ opp[0]);
        
        System.runAs(automotiveUser){
            
            Id accResidentialRtId =  Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('XC_GLO_Account_Residential').getRecordTypeId();
            List<Account> accounts = XC_DF_Account.createSohoAccounts(1);
            accounts[0].XC_FirstName__c = 'Test';
            accounts[0].XC_LastName__c = 'TestTest';
            accounts[0].XC_ConfirmationByCustomer__c = false;
            accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
        	insert accounts;
            
            List<Contact> contacts = XC_DF_Contact.createSohoContacts(accounts);
            contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        	contacts[0].XC_CountryLegalEntity__c = 'Italy';
            contacts[0].FirstName = 'testContact';
            contacts[0].LastName = 'testConatctL';
            insert contacts;
            
            List<XC_Address__c> address =  XC_DF_Address.createAddress(accounts);
            insert address;
            
            Map<String,Object> mapOpp = new Map<String,Object>{
                'accountId' => accounts[0].Id,
                'parentOpportunityId'=>opp[0].Id};           
            Test.startTest();
                XC_AMP_LCC002_OrderMainViewBuilder.createChildOpportunity(mapOpp);
            	XC_AMP_LCC002_OrderMainViewBuilder.createOpportunity(accounts[0].Id, address[0].Id, mapOpp, '');
            Test.stopTest();
        }
    }
    
    
     @isTest
    static void manageDuplicate_TEST(){
        User automotiveUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' and IsActive=true and XC_LegalEntity__c='EnelXItalia' LIMIT 1];
     
        System.runAs(automotiveUser){
            
            List<Account> accounts = XC_DF_Account.createResidentialAccounts(1);
            accounts[0].XC_FirstName__c = 'PROVA';
            accounts[0].XC_LastName__c = 'PROVA';
            accounts[0].XC_ConfirmationByCustomer__c = false;
            accounts[0].XC_GiveDataTo_EnelXItalia__c = true;
        	accounts[0].XC_GiveDataTo_EnelXMSP__c = true;
            accounts[0].XC_DocumentCountry__c = 'Italy';
            accounts[0].IdentityType__c ='CF';
            accounts[0].IdentityNumber__c = 'PRVPRV80A01F839M';
        	insert accounts;
            
            List<Contact> contacts = XC_DF_Contact.createResidentialContacts(accounts);
            contacts[0].XC_MainLegalEntity__c = 'EnelXItalia';
        	contacts[0].XC_CountryLegalEntity__c = 'Italy';
            contacts[0].FirstName = 'testContact';
            contacts[0].LastName = 'testConatctL';
            insert contacts;
            
            List<XC_Address__c> address =  XC_DF_Address.createAddress(accounts);
        	insert address;
            
            List<String> accountFields = XC_UTIL_Sobject.getListAllFields('Account');
            Map<String,Map<String,Object>> sections = new Map<String,Map<String,Object>>();
            	Map<String,Object> section1 = new Map<String,Object>();
            	section1.put('country', address[0].XC_AddressCountry__c);
            	section1.put('city', address[0].XC_City__c);
            	section1.put('streetNumber', address[0].XC_StreetNumber__c);
            	section1.put('province', address[0].XC_AddressProvince__c);
            	sections.put('XC_Address__c',section1);
            Map<String,Object> mapAccount = new Map<String,Object>{
                'existingAccountId' => accounts[0].Id,
                'sections'=>sections};  
            
            Test.startTest();
                XC_AMP_LCC002_OrderMainViewBuilder.manageDuplicationCases(mapAccount);
            Test.stopTest();
        }
    }


}