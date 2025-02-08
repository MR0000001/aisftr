/**
* @author Roberta Cossiga - rcossiga@deloitte.it & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 15/05/2019
* @description XC_LCC084_AssignToBackOffice_TEST – Test Class for XC_LCC084_AssignToBackOffice
*/ 

@isTest
public class XC_TR_Opportunity_U_PopulateFields_TEST {
    
    @TestSetup
    static void insertCustomSetting() {
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        User u = XC_DF_User.createUserAdmin();
        u.XC_LegalEntity__c = 'EndesaX';
        insert u;
    }

    @isTest
    static void onInsertOpportunity() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        //insert XC_DF_Address.createAddress(accList);
        //List<XC_Address__c> listAddress = [SELECT Id, XC_PricinRegion__c FROM XC_Address__c];
        //insert XC_DF_Contact.createResidentialContacts(accList);
        //List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        XC_Address__c addressToInsert = new XC_Address__c();
        addressToInsert.XC_Account__c = accList[0].Id;
        addressToInsert.XC_Address__c = 'Test';
        addressToInsert.XC_City__c = 'Roma';
        addressToInsert.XC_AddressCountry__c = 'Italy';
        addressToInsert.XC_PostalCode__c = '28080';
        addressToInsert.XC_AddressProvince__c = 'Roma';
        addressToInsert.XC_StreetNumber__c = '11' + Math.random();
        addressToInsert.XC_StreetType__c = 'Street'; 
        addressToInsert.XC_Municipality__c   = 'Test' + Math.random();
        insert addressToInsert;
        Test.startTest();
        Opportunity opportunityToInsert = new Opportunity();
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_ITA').getRecordTypeId();
        opportunityToInsert.recordTypeId = recordTypeId;
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.AccountId = accList[0].Id;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Boiler';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_LegalEntity__c = 'EnelXItalia';
        opportunityToInsert.XC_Address__c = addressToInsert.ID;
        insert opportunityToInsert;
        //insert XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
        System.assertEquals(oppinserted.size() , 1);
        Test.stopTest();
    }

    @isTest
    static void onInsertOpportunityPopulateLegalEntity() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        //insert XC_DF_Address.createAddress(accList);
        //List<XC_Address__c> listAddress = [SELECT Id, XC_PricinRegion__c FROM XC_Address__c];
        //insert XC_DF_Contact.createResidentialContacts(accList);
        //List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        XC_Address__c addressToInsert = new XC_Address__c();
        addressToInsert.XC_Account__c = accList[0].Id;
        addressToInsert.XC_Address__c = 'Test';
        addressToInsert.XC_City__c = 'Roma';
        addressToInsert.XC_AddressCountry__c = 'Italy';
        addressToInsert.XC_PostalCode__c = '28080';
        addressToInsert.XC_AddressProvince__c = 'Roma';
        addressToInsert.XC_StreetNumber__c = '11' + Math.random();
        addressToInsert.XC_StreetType__c = 'Street'; 
        addressToInsert.XC_Municipality__c   = 'Test' + Math.random();
        insert addressToInsert;
        User u = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        System.runAs(u) {
            Opportunity opportunityToInsert = new Opportunity();
            Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_ITA').getRecordTypeId();
            opportunityToInsert.recordTypeId = recordTypeId;
            opportunityToInsert.Name = 'OP00001';
            opportunityToInsert.AccountId = accList[0].Id;
            opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Boiler';
            opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
            opportunityToInsert.StageName = 'Draft';
            opportunityToInsert.XC_ReceivingChannel__c = 'Web';
            opportunityToInsert.XC_LegalEntity__c = 'EnelXItalia';
            opportunityToInsert.XC_Address__c = addressToInsert.ID;
            insert opportunityToInsert;
            //insert XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
            List<Opportunity> oppinserted = [SELECT Id FROM Opportunity];
            System.assertEquals(oppinserted.size() , 1);
            List<Lead> ld = XC_DF_Lead.createResidentialLeads(1);
            ld[0].XC_CampaignProduct__c = 'test';
            ld[0].XC_CampaignPlatform__c = 'test';
            ld[0].XC_CampaignCode__c = 'test';
            insert ld;
            oppinserted[0].XC_Lead__c = ld[0].Id;
            update(oppinserted); 
        }
        Test.stopTest();
    }

     @isTest
    static void onInsertOpportunityPopulateShippingCost() {
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account];
        
        XC_Address__c addressToInsert = new XC_Address__c();
        addressToInsert.XC_Account__c = accList[0].Id;
        addressToInsert.XC_Address__c = 'Test';
        addressToInsert.XC_City__c = 'Roma';
        addressToInsert.XC_AddressCountry__c = 'Italy';
        addressToInsert.XC_PostalCode__c = '28080';
        addressToInsert.XC_AddressProvince__c = 'Roma';
        addressToInsert.XC_StreetNumber__c = '11' + Math.random();
        addressToInsert.XC_StreetType__c = 'Street'; 
        addressToInsert.XC_Municipality__c   = 'Test' + Math.random();
        insert addressToInsert;

        XC_ShippingCostZone__c zoneToInsert = new XC_ShippingCostZone__c();
        zoneToInsert.XC_Country__c = 'Italy';
        zoneToInsert.XC_KeyValue__c = '28080';
        zoneToInsert.XC_Area__c ='Test';
        insert zoneToInsert;
        
        User u = [SELECT Id FROM User LIMIT 1];
        
        Test.startTest();
        System.runAs(u) {
            Opportunity opportunityToInsert = new Opportunity();
            Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_ITA').getRecordTypeId();
            opportunityToInsert.recordTypeId = recordTypeId;
            opportunityToInsert.Name = 'OP00001';
            opportunityToInsert.AccountId = accList[0].Id;
            opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Boiler';
            opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
            opportunityToInsert.StageName = 'Draft';
            opportunityToInsert.XC_ReceivingChannel__c = 'Web';
            opportunityToInsert.XC_LegalEntity__c = 'EnelXItalia';
            opportunityToInsert.XC_Address__c = addressToInsert.ID;
            insert opportunityToInsert;
        }
        Test.stopTest();
    }
}