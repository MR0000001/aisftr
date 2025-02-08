/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_U_PopulateSkills_TEST – Test Class of XC_TR_WorkOrder_U_PopulateSkills
*/

@isTest
public class XC_TR_WorkOrder_U_PopulateSkills_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        /*List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        List<ServiceResource> serviceResourcesToInsert = new List<ServiceResource>();
            ServiceResource serviceRes = new ServiceResource();
            serviceRes.Name = 'No Candidate Found';
            serviceRes.XC_Account__c = accountList[0].Id;
            serviceRes.IsActive = true;
            serviceRes.IsCapacityBased = true;
            serviceRes.XC_AutomaticDeactivation__c = true;
            serviceRes.RelatedRecordId = usersList[1].Id; // serviceRes.RelatedRecordId = accnt.Users[0].Id
            serviceResourcesToInsert.add(serviceRes);
        insert serviceResourcesToInsert;*/
    }

    @isTest
    static  void onInsert() {
        insert XC_DF_Lead.createResidentialLead();
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prInserted = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_ProductCategoryOfInterest.productSkillRequired(prInserted);
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        insert XC_DF_Address.createAddress(accList);
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        insert XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        List<Opportunity> oppInserted = [SELECT Id FROM Opportunity];
        List<WorkOrder> woListWithOpp = new List<WorkOrder>();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_CommercialVisit);
        for(Opportunity op: oppInserted){
            for (WorkOrder wo : woList){
                wo.XC_Opportunity__c = op.Id; 
                woListWithOpp.add(wo);
            }
        }
        Test.startTest();
        insert woListWithOpp;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    @isTest
    static  void onInsertNotCV() {
        List<WorkOrder> woListToInsert = new List<WorkOrder>();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(100, 'Planned Maintenance');
        WorkType woType = [SELECT Id, XC_WorkTypeCategory__c FROM WorkType];
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prInserted = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_ProductCategoryOfInterest.productSkillRequired(prInserted);
        insert XC_DF_ProductCategoryOfInterest.productSkillAssociation(prInserted,woType);
        insert XC_DF_Account.createResidentialAccounts(1);
        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        insert XC_DF_Address.createAddress(accList);
        insert XC_DF_CatalogItem.createCatalogItem();
        List<NE__Catalog_Category__c> catCategory = [SELECT Id, XC_TechnicalSkill__c FROM NE__Catalog_Category__c];
        catCategory[0].XC_TechnicalSkill__c = 'Boiler';
        update catCategory[0];
        List<XC_Address__c> listAddress = [SELECT Id FROM XC_Address__c];
        insert XC_DF_Contact.createResidentialContacts(accList);
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact];
        insert XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        List<Opportunity> oppInserted = [SELECT Id FROM Opportunity];
        for(Opportunity op : oppInserted){
            for (WorkOrder wo: woList){
                    wo.XC_CatalogCategory__c = catCategory[0].Id;
                    wo.XC_Opportunity__c = op.Id;
                    woListToInsert.add(wo);
            }
        }    
        Test.startTest();
        insert woListToInsert;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(100, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    @isTest
    static  void onUpdate() {
        Test.startTest();
        WorkType woType = XC_DF_WorkType.createWorkType ('Planned Maintenance');
        insert woType;
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prInserted = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_ProductCategoryOfInterest.productSkillRequired(prInserted);
        insert XC_DF_ProductCategoryOfInterest.productSkillAssociation(prInserted,woType);
        insert XC_DF_CatalogItem.createCatalogItem();
        List<NE__Catalog_Category__c> catCategory = [SELECT Id, XC_TechnicalSkill__c FROM NE__Catalog_Category__c];
        catCategory[0].XC_TechnicalSkill__c = 'Boiler';
        update catCategory[0];
        List<Asset> listasset = XC_DF_Asset.createAssets(1);
        listasset[0].XC_CatalogCategory__c = catCategory[0].Id;
        insert listasset; 
        List<WorkOrder> wolist = XC_DF_WorkOrder.createWorkOrdersForLead (1);
        wolist[0].XC_CatalogCategory__c = catCategory[0].Id; 
        wolist[0].XC_Coverage__c = listasset[0].Id;
        insert wolist;
        wolist[0].WorkTypeId = woType.Id;
        update wolist; 
        System.assertEquals(woType!=null, true);      
        Test.stopTest();
    }
    
}