/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 05/08/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC138_SplitWorkOrders_TEST – Test Class of XC_LCC138_SplitWorkOrders
*/
@isTest
public class XC_LCC138_SplitWorkOrders_TEST {
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
    
    static testMethod void checkSplittingPossibilityTest() {
        insert XC_DF_CatalogItem.createCatalogItem();
        List<NE__Catalog_Category__c> catCategory = [SELECT Id, XC_TechnicalSkill__c FROM NE__Catalog_Category__c];
        catCategory[0].XC_TechnicalSkill__c = 'Boiler';
        update catCategory[0];
        List<WorkOrder> woParent = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woParent[0].XC_HierarchyLevel__c = 0;

        insert woParent;
        List<WorkOrder> woChilds = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woChilds[0].XC_HierarchyLevel__c = 2;
        woChilds[0].ParentWorkOrderId = woParent[0].Id;
        woChilds[0].XC_CatalogCategory__c = catCategory[0].Id;
        insert woChilds;
        insert XC_DF_WorkOrder.createWorkOrderSkillRequirement(woChilds); 
        test.startTest();
        XC_UTIL_ResultWrapper resWrap = XC_LCC138_SplitWorkOrders.checkSplittingPossibility(woParent[0].Id);
        XC_UTIL_ResultWrapper resWrap2 = XC_LCC138_SplitWorkOrders.checkHierarchyLevelAndSplit(woParent[0].Id);
        System.assertEquals(true, woParent != null);
        test.stopTest();
        
    }
    
        static testMethod void checkSplittingPossibilityTestNotGood() {
        List<WorkOrder> woParent = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        woParent[0].XC_HierarchyLevel__c = 0;
        insert woParent;
        List<WorkOrder> woChilds = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woChilds[0].XC_HierarchyLevel__c = 2;
        woChilds[0].ParentWorkOrderId = woParent[0].Id;
        insert woChilds;
        List<WorkOrder> woParent2 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woParent2[0].XC_HierarchyLevel__c = 0;
        insert woParent2;
        insert XC_DF_WorkOrder.createWorkOrderSkillRequirement(woChilds);   
        test.startTest();
        XC_UTIL_ResultWrapper resWrap = XC_LCC138_SplitWorkOrders.checkSplittingPossibility(woParent[0].Id);
        XC_UTIL_ResultWrapper resWrap2 = XC_LCC138_SplitWorkOrders.checkSplittingPossibility(woParent2[0].Id);
        System.assertEquals(true, woParent != null); 
        test.stopTest();
    }
    
    static testMethod void checkSplittingPossibilityTestNotGood2() {
        List<WorkOrder> woParent = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woParent[0].XC_HierarchyLevel__c = 0;
        insert woParent;
        List<WorkOrder> woChilds = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        woChilds[0].XC_HierarchyLevel__c = 2;
        woChilds[0].ParentWorkOrderId = woParent[0].Id;
        insert woChilds;
        List<WorkOrder> woParent2 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woParent2[0].XC_HierarchyLevel__c = 0;
        insert woParent2;
        insert XC_DF_WorkOrder.createWorkOrderSkillRequirement(woChilds);   
        test.startTest();
        XC_UTIL_ResultWrapper resWrap = XC_LCC138_SplitWorkOrders.checkSplittingPossibility(woParent[0].Id);
        System.assertEquals(true, woParent != null);  
        test.stopTest();
    }
    
    static testMethod void checkSplittingPossibilityTest3() {
        insert XC_DF_CatalogItem.createCatalogItem();
        List<NE__Catalog_Category__c> catCategory = [SELECT Id, XC_TechnicalSkill__c FROM NE__Catalog_Category__c];
        catCategory[0].XC_TechnicalSkill__c = 'Boiler';
        update catCategory[0];
        NE__Order__c orderInserted2 = XC_DF_Order.createOrder('InOrder');
        //NE__Order__c orderQueried2 = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<NE__OrderItem__c> orderItemInserted2 = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderInserted2.Id];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderInserted.Id];
        orderItemInserted[0].NE__Bundle_Configuration__c = orderItemInserted2[0].Id;
        test.startTest();
        update orderItemInserted;
        List<WorkOrder> woParent = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woParent[0].XC_HierarchyLevel__c = 0;
        insert woParent;
        List<WorkOrder> woChilds = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        woChilds[0].XC_HierarchyLevel__c = 2;
        woChilds[0].ParentWorkOrderId = woParent[0].Id;
        woChilds[0].XC_Configuration_Item__c = orderItemInserted[0].Id;
        insert woChilds;
        
        insert XC_DF_WorkOrder.createWorkOrderSkillRequirement(woChilds); 
        
        XC_UTIL_ResultWrapper resWrap = XC_LCC138_SplitWorkOrders.checkSplittingPossibility(woParent[0].Id);
        XC_UTIL_ResultWrapper resWrap2 = XC_LCC138_SplitWorkOrders.checkHierarchyLevelAndSplit(woParent[0].Id);
        System.assertEquals(true, woParent != null);
        test.stopTest();
        
    }
    
        static testMethod void checkSplittingPossibilityTest4() {
        insert XC_DF_CatalogItem.createCatalogItem();
        List<NE__Catalog_Category__c> catCategory = [SELECT Id, XC_TechnicalSkill__c FROM NE__Catalog_Category__c];
        catCategory[0].XC_TechnicalSkill__c = 'Boiler';
        update catCategory[0];
        List<WorkOrder> woParent = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woParent[0].XC_HierarchyLevel__c = 1;
        insert woParent;
        List<WorkOrder> woChilds = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woChilds[0].XC_HierarchyLevel__c = 2;
        woChilds[0].ParentWorkOrderId = woParent[0].Id;
        woChilds[0].XC_CatalogCategory__c = catCategory[0].Id;
        insert woChilds;
        insert XC_DF_WorkOrder.createWorkOrderSkillRequirement(woChilds); 
        test.startTest();
        XC_UTIL_ResultWrapper resWrap = XC_LCC138_SplitWorkOrders.checkSplittingPossibility(woParent[0].Id);
        XC_UTIL_ResultWrapper resWrap2 = XC_LCC138_SplitWorkOrders.checkHierarchyLevelAndSplit(woParent[0].Id);
        System.assertEquals(true, woParent != null);
        test.stopTest();
        
    }

}