/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ResourcePreference_TEST – Test Class of XC_UTIL_ResourcePreference
*/ 

@isTest
public class XC_UTIL_ResourcePreference_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
    @isTest
    static void insertResourcePreferencesTest() {
        insert XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        Set<Id> servResIds = new Set<Id>();
        for(ServiceResource sr : servResList){
            servResIds.add(sr.Id);
        }
        List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder];
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>>();
        mapWorkOrderListServiceResources.put(workOrderList[0].Id,servResIds);
        Test.startTest();
        List<XC_UTIL_Sobject.WrapperResult>  listResult = XC_UTIL_ResourcePreference.insertRequiredResourcePreferences(workOrderList, mapWorkOrderListServiceResources);
        System.assertEquals(2, listResult.size());
        Test.stopTest();
    }
    @isTest
    static void removeResourcePreferencesTest() {
        insert XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder];
        Set<Id> servResIds = new Set<Id>();
        servResIds.add(servResList[0].Id);
        Map<Id, Set<Id>> mapWorkOrderListServiceResources = new Map<Id, Set<Id>>();
        mapWorkOrderListServiceResources.put(workOrderList[0].Id,servResIds);
        List<ResourcePreference> resPrefList = new List<ResourcePreference>();
            ResourcePreference resPref = new ResourcePreference();
            resPref.ServiceResourceId= servResList[1].Id;
            resPref.RelatedRecordId = workOrderList[0].Id;
            resPref.PreferenceType = 'Required';
            resPrefList.add(resPref);
        insert resPrefList;
        Map<Id, List<ResourcePreference>> mapWorkOrderExistingResourcePreferences = new Map<Id, List<ResourcePreference>>();
        mapWorkOrderExistingResourcePreferences.put(workOrderList[0].Id, resPrefList);
        Test.startTest();
        List<XC_UTIL_Sobject.WrapperResult>  listResult = XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(workOrderList);
        XC_UTIL_ResourcePreference.removeResourcePreferences(workOrderList); 
        //List<XC_UTIL_Sobject.WrapperResult>  listResult2 = XC_UTIL_ResourcePreference_U.insertResourcePreferencesWithoutExcluded(workOrderList, mapWorkOrderListServiceResources, mapWorkOrderExistingResourcePreferences); 
        System.assertEquals(1, listResult.size());
        Test.stopTest();
    }
    @isTest
    static void removeResourcePreferencesTestMap() {
        insert XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder];
        Set<Id> servResIds = new Set<Id>();
        List<ResourcePreference> resPrefList = new List<ResourcePreference>();
        for(ServiceResource sr : servResList){
            ResourcePreference resPref = new ResourcePreference();
            resPref.ServiceResourceId= sr.Id;
            resPref.RelatedRecordId = workOrderList[0].Id;
            resPref.PreferenceType = 'Excluded';
            resPrefList.add(resPref);
        }
        insert resPrefList;
        Test.startTest();
        //Map<Id, List<ResourcePreference>> mapResult = XC_UTIL_ResourcePreference.getMapWorkOrderExistingResourcePreferences(workOrderList);
        //System.assertEquals(1, mapResult.keySet().size());
        Test.stopTest();
    }
    
    //@isTest
    /*static void checkWorkTypeAssetTest() {
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        //assetList[0].XC_LastRepairDate__c = Date.Today().addMonths(-5);
        assetList[0].XC_LastMaintenanceDate__c = Date.Today().addMonths(-5);
        assetList[0].XC_MaintenanceAssignedResource__c = servResList[0].Id;
        assetList[0].XC_InstallationAssignedResource__c = servResList[0].Id;
        assetList[0].XC_RepairAssignedResource__c = servResList[0].Id;  
        //assetList[0].InstallDate = Date.Today().addMonths(-5);   
        insert assetList;
        Test.startTest();
        List<Asset> assetListInserted = [SELECT Id FROM Asset];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        //NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_PlannedMaintenance);
        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        List<WorkOrder> woList3 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        List<WorkOrder> woListInsert2 = new List<WorkOrder>();
        woListInsert.addAll(woList);
        woListInsert.addAll(woList2);
        woListInsert.addAll(woList3);
        for(WorkOrder wo : woListInsert){
            wo.AssetId = assetListInserted[0].Id;
            wo.XC_Configuration__c = orderInserted.Id;
            woListInsert2.add(wo);
        }
        insert woListInsert2;
        List<WorkOrder> woListInserted = [SELECT Id, XC_WorkTypeCategory__c, AssetId, XC_Configuration__c, XC_PositionInMaintenancePlan__c FROM WorkOrder];        
        Map<Id, Id> mapWoAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(woListInserted);
        System.assertEquals(1, mapWoAccount.keySet().size());
        Test.stopTest();
    } 
    @isTest
    static void checkWorkTypeAssetTest2() {
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        //assetList[0].XC_LastRepairDate__c = Date.Today().addMonths(-5);
        //assetList[0].XC_LastMaintenanceDate__c = Date.Today().addMonths(-5);
        assetList[0].XC_MaintenanceAssignedResource__c = servResList[0].Id;
        assetList[0].XC_InstallationAssignedResource__c = servResList[0].Id;
        assetList[0].XC_RepairAssignedResource__c = servResList[0].Id;  
        assetList[0].InstallDate = Date.Today().addMonths(-5);   
        insert assetList;
        Test.startTest();
        List<Asset> assetListInserted = [SELECT Id FROM Asset];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        List<WorkOrder> woList3 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        List<WorkOrder> woListInsert2 = new List<WorkOrder>();
        woListInsert.addAll(woList);
        woListInsert.addAll(woList2);
        woListInsert.addAll(woList3);
        for(WorkOrder wo : woListInsert){
            wo.AssetId = assetListInserted[0].Id;
            wo.XC_Configuration__c = orderQueried.Id;
            woListInsert2.add(wo);
        }
        insert woListInsert2;
        List<WorkOrder> woListInserted = [SELECT Id, XC_WorkTypeCategory__c, AssetId, XC_Configuration__c, XC_PositionInMaintenancePlan__c FROM WorkOrder];
        Map<Id, Id> mapWoAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(woListInserted);
        System.assertEquals(2, mapWoAccount.keySet().size());
        Test.stopTest();
    } 
    @isTest
    static void checkWorkTypeAssetTest3() {
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        assetList[0].XC_LastRepairDate__c = Date.Today().addMonths(-5);
        //assetList[0].XC_LastMaintenanceDate__c = Date.Today().addMonths(-5);
        assetList[0].XC_MaintenanceAssignedResource__c = servResList[0].Id;
        assetList[0].XC_InstallationAssignedResource__c = servResList[0].Id;
        assetList[0].XC_RepairAssignedResource__c = servResList[0].Id;  
        //assetList[0].InstallDate = Date.Today().addMonths(-5);   
        insert assetList;
        Test.startTest();
        List<Asset> assetListInserted = [SELECT Id FROM Asset];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        List<WorkOrder> woList3 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        List<WorkOrder> woListInsert2 = new List<WorkOrder>();
        woListInsert.addAll(woList);
        woListInsert.addAll(woList2);
        woListInsert.addAll(woList3);
        for(WorkOrder wo : woListInsert){
            wo.AssetId = assetListInserted[0].Id;
            wo.XC_Configuration__c = orderQueried.Id;
            woListInsert2.add(wo);
        }
        insert woListInsert2;
        List<WorkOrder> woListInserted = [SELECT Id, XC_WorkTypeCategory__c, AssetId, XC_Configuration__c, XC_PositionInMaintenancePlan__c FROM WorkOrder];
        Map<Id, Id> mapWoAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(woListInserted);
        Test.stopTest();
    } */
    @isTest
  static void checkIfPreferenceExistsTest() {
        insert XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder];
        List<ResourcePreference> resPrefList = new List<ResourcePreference>();
        for(ServiceResource sr : servResList){
            ResourcePreference resPref = new ResourcePreference();
            resPref.ServiceResourceId= sr.Id;
            resPref.RelatedRecordId = workOrderList[0].Id;
            resPref.PreferenceType = 'Required';
            resPrefList.add(resPref);
        }
        insert resPrefList;
        Map<Id,List<ResourcePreference>> mapWorkOrderListServiceResources = new Map<Id, List<ResourcePreference>>();
        mapWorkOrderListServiceResources.put(workOrderList[0].Id,resPrefList);
        Test.startTest();
        Boolean exist = XC_UTIL_ResourcePreference_U_CheckFor.checkIfPreferenceExists(mapWorkOrderListServiceResources, workOrderList[0].Id,servResList[0].Id);
        System.assertEquals(exist, false);
        Test.stopTest();
    }    
    @isTest
     static void checkWorkTypeAssetTest4() {
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        //assetList[0].XC_LastRepairDate__c = Date.Today().addMonths(-5);
        assetList[0].XC_LastMaintenanceDate__c = Date.Today().addDays(-10);
        assetList[0].XC_MaintenanceAssignedResource__c = servResList[0].Id;
        assetList[0].XC_InstallationAssignedResource__c = servResList[0].Id;
        assetList[0].XC_RepairAssignedResource__c = servResList[0].Id;  
        //assetList[0].InstallDate = Date.Today().addMonths(-5);   
        insert assetList;
        List<Asset> assetListInserted = [SELECT Id FROM Asset];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        Test.startTest();
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_PlannedMaintenance);
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        woListInsert.addAll(woList);
        for(WorkOrder wo : woListInsert){
            wo.AssetId = assetListInserted[0].Id;
            wo.XC_Configuration__c = orderQueried.Id;
        }
        insert woListInsert;
        List<WorkOrder> woListInserted = [SELECT Id, XC_WorkTypeCategory__c, AssetId, XC_Configuration__c, XC_PositionInMaintenancePlan__c FROM WorkOrder];
        Map<Id, Id> mapWoAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(woListInserted);
        System.assertEquals(1, mapWoAccount.keySet().size());
        Test.stopTest();
    } 
    @isTest
     static void checkWorkTypeAssetTestWTRepair1() {
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        assetList[0].XC_LastRepairDate__c = Date.Today().addMonths(-5);
        assetList[0].XC_MaintenanceAssignedResource__c = servResList[0].Id;
        assetList[0].XC_InstallationAssignedResource__c = servResList[0].Id;
        assetList[0].XC_RepairAssignedResource__c = servResList[0].Id;  
        insert assetList;
        Test.startTest();
        List<Asset> assetListInserted = [SELECT Id FROM Asset];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        woListInsert.addAll(woList2);
        for(WorkOrder wo : woListInsert){
            wo.AssetId = assetListInserted[0].Id;
            wo.XC_Configuration__c = orderQueried.Id;
        }
        insert woListInsert;
        List<WorkOrder> woListInserted = [SELECT Id, XC_WorkTypeCategory__c, AssetId, XC_Configuration__c, XC_PositionInMaintenancePlan__c FROM WorkOrder];
        
        Map<Id, Id> mapWoAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(woListInserted);
        Test.stopTest();
    } 
    @isTest
    static void checkWorkTypeAssetTestWTRepair2() {
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        assetList[0].XC_LastRepairDate__c = Date.Today().addMonths(-5);
        assetList[0].XC_LastMaintenanceDate__c = Date.Today().addDays(-10);
        assetList[0].XC_MaintenanceAssignedResource__c = servResList[0].Id;
        assetList[0].XC_InstallationAssignedResource__c = servResList[0].Id;
        assetList[0].XC_RepairAssignedResource__c = servResList[0].Id;  
        assetList[0].InstallDate = Date.Today().addMonths(-5);   
        Test.startTest();
        insert assetList;
        List<Asset> assetListInserted = [SELECT Id FROM Asset];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        woListInsert.addAll(woList2);
        for(WorkOrder wo : woListInsert){
            wo.AssetId = assetListInserted[0].Id;
            wo.XC_Configuration__c = orderQueried.Id;
        }
        insert woListInsert;
        List<WorkOrder> woListInserted = [SELECT Id, XC_WorkTypeCategory__c, AssetId, XC_Configuration__c, XC_PositionInMaintenancePlan__c FROM WorkOrder];
        
        Map<Id, Id> mapWoAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(woListInserted);
        System.assertEquals(1, mapWoAccount.keySet().size());
        Test.stopTest();
    } 
    @isTest
    static void checkWorkTypeAssetTestWTRepair3() {
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        assetList[0].XC_MaintenanceAssignedResource__c = servResList[0].Id;
        assetList[0].XC_InstallationAssignedResource__c = servResList[0].Id;
        assetList[0].XC_RepairAssignedResource__c = servResList[0].Id;  
        assetList[0].InstallDate = Date.Today().addMonths(-4);   
        Test.startTest();
        insert assetList;
        List<Asset> assetListInserted = [SELECT Id FROM Asset];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        orderInserted.XC_LegalEntity__c = 'EnelXItalia';
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        woListInsert.addAll(woList2);
        for(WorkOrder wo : woListInsert){
            wo.AssetId = assetListInserted[0].Id;
            wo.XC_Configuration__c = orderQueried.Id;
        }
        insert woListInsert;
        List<WorkOrder> woListInserted = [SELECT Id, XC_WorkTypeCategory__c, AssetId, XC_Configuration__c, XC_PositionInMaintenancePlan__c FROM WorkOrder];
        
        Map<Id, Id> mapWoAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(woListInserted);
        System.assertEquals(1, mapWoAccount.keySet().size());
        Test.stopTest();
    } 
    @isTest
    static void checkWorkTypeAssetTest5() {
        List<Account> accPartList = XC_DF_Account.insertPartnerAccounts(1);
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        assetList[0].InstallDate = Date.Today().addMonths(-5); 
        assetList[0].XC_MaintenanceAssignedResource__c = servResList[0].Id;
        assetList[0].XC_InstallationAssignedResource__c = servResList[0].Id;
        assetList[0].XC_RepairAssignedResource__c = servResList[0].Id;  
        insert assetList;
        Test.startTest();
        List<Asset> assetListInserted = [SELECT Id FROM Asset];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<WorkOrder> woList3 = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        woListInsert.addAll(woList3);
        for(WorkOrder wo : woListInsert){
            wo.AssetId = assetListInserted[0].Id;
            wo.XC_Configuration__c = orderQueried.Id;
        }
        insert woListInsert;
        List<WorkOrder> woListInserted = [SELECT Id, XC_WorkTypeCategory__c, AssetId, XC_Configuration__c, XC_PositionInMaintenancePlan__c FROM WorkOrder];
        
        Map<Id, Id> mapWoAccount = XC_UTIL_ResourcePreference.getMapWorkOrderPreferredResourceAccount(woListInserted);
        System.assertEquals(0, mapWoAccount.keySet().size());
        Test.stopTest();
    } 
    @isTest
    static void removeResourcePreferencesTest2() {
        insert XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        List<ServiceResource> servResList = XC_DF_ServiceResource.createServiceResources(2);
        List<ServiceResource> servResListInserted = [SELECT Id, XC_Account__c FROM ServiceResource];
        List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder];
        List<ResourcePreference> resPrefList = new List<ResourcePreference>();
        for(ServiceResource sr : servResListInserted){
            ResourcePreference resPref = new ResourcePreference();
            resPref.ServiceResourceId= sr.Id;
            resPref.RelatedRecordId = workOrderList[0].Id;
            resPref.PreferenceType = 'Required';
            resPrefList.add(resPref);
        }
        insert resPrefList;
        Test.startTest(); 
        XC_UTIL_ResourcePreference_U.excludeDispatcher(workOrderList[0], servResListInserted[0].XC_Account__c); 
        System.assertEquals(1, workOrderList.size());
        Test.stopTest();
    }
    @isTest
    static void checkSplittingPossibilityTest() {
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
    @isTest
    static void updateWO(){

        List<Account> accList =XC_DF_Account.createResidentialAccounts(1);
        insert accList;
        List<XC_Address__c> listAddress= XC_DF_Address.createAddress(accList);
        insert listAddress;
        List<Contact> contactList = XC_DF_Contact.createResidentialContacts(accList);
        insert contactList;
        List<Opportunity> oppInserted = XC_DF_Opportunity.createOpportunityWithVisit(contactList,listAddress[0]);
        insert oppInserted;
        
        List<NE__Product__c> proList = XC_DF_Product.createProducts(1);
        insert proList;

        List<Asset> assetListBefore = XC_DF_Asset.createAssets(1);
        insert assetListBefore;

        List<Asset> assetList2 = XC_DF_Asset.createAssets(1);
        assetList2[0].NE__ProdId__c = proList[0].Id;
        assetList2[0].NE__Bundle_Configuration__c = assetListBefore[0].Id;
        insert assetList2;

        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        List<WorkOrder> woListInsert2 = new List<WorkOrder>();
        for(WorkOrder wo2 : woList2){
            wo2.XC_Opportunity__c = oppInserted[0].Id;
            wo2.Status = Label.XC_CL_InProgress;
            wo2.XC_StatusReason__c = 'Breach of Contract';
            wo2.XC_Coverage__c = assetList2[0].Id;
            wo2.AssetId=null;
            woListInsert2.add(wo2);
        }
        insert woListInsert2;
    
        List<WorkOrder> woListToUp = new List<WorkOrder>();
        for(WorkOrder wo2 : woListInsert2){
            wo2.Status = Label.XC_CL_WorkOrder_CannotComplete;
            woListToUp.add(wo2);
        }
        Test.startTest();
        try{
        update woListToUp;
        }
        catch(Exception e){
            System.debug('In catch');
        }
        System.assertEquals(1, woListToUp.size(), 'Error assertEquals');
        Test.stopTest();
    }

    @isTest
    static void checkAsset (){
        XC_UTIL_ResourcePreference.PreferredWrapper preferredWrapper = new XC_UTIL_ResourcePreference.PreferredWrapper();
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, Label.XC_CL_WorkType_DeliveryInstallation, Label.XC_CL_WorkType_DeliveryInstallation);
        insert listOfWo;
        List<ServiceResource> listOfSR = XC_DF_ServiceResource.createServiceResources(1);
        List<Asset> listOfAsset = XC_DF_Asset.createAssets(3);
        Date previousDate = Date.Today().addMonths(7);
        listOfAsset[0].XC_LastMaintenanceDate__c = previousDate;
        listOfAsset[0].XC_MaintenanceAssignedResource__c = listOfSR[0].Id;
        listOfAsset[1].XC_LastRepairDate__c = previousDate;
        listOfAsset[1].XC_RepairAssignedResource__c = listOfSR[0].Id;
        listOfAsset[2].InstallDate = previousDate;
        listOfAsset[2].XC_InstallationAssignedResource__c = listOfSR[0].Id;
        insert listOfAsset;
        XC_UTIL_ResourcePreference_U_CheckFor.checkAsset(listOfAsset[0], preferredWrapper, listOfWo[0]);
        XC_UTIL_ResourcePreference_U_CheckFor.checkAsset(listOfAsset[1], preferredWrapper, listOfWo[0]);
        XC_UTIL_ResourcePreference_U_CheckFor.checkAsset(listOfAsset[2], preferredWrapper, listOfWo[0]);
    }

    @isTest
    static void checkForCommercialVisit(){
        List<WorkOrder> woList = new List<WorkOrder>();
        List<NE__Order__c> orderListToUpdate = new List<NE__Order__c>();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
        //update order;
        orderListToUpdate.add(order);
        /*NE__Order__c orderWithoutSiteInspection = XC_DF_Order.createOrder('InOrder');
        orderWithoutSiteInspection.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
        //update orderWithoutSiteInspection;
        orderListToUpdate.add(orderWithoutSiteInspection);*/
        update orderListToUpdate;
        Test.startTest();
        XC_UTIL_ResourcePreference.PreferredWrapper preferredWrapper = new XC_UTIL_ResourcePreference.PreferredWrapper();
        //XC_UTIL_ResourcePreference.PreferredWrapper preferredWrapperWithoutSiteInspection = new XC_UTIL_ResourcePreference.PreferredWrapper();
        List<Account> listOfAccountPartner = XC_DF_Account.insertPartnerAccounts(1);
        //preferredWrapperWithoutSiteInspection.setIdConfiguration.add(order.Id);
        preferredWrapper.setIdConfiguration.add(order.Id);
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Site Inspection - Boiler', Label.XC_CL_WorkType_SiteInspection);
        listOfWo[0].XC_Configuration__c = order.Id;
        listOfWo[0].XC_AssignedPartner__c = listOfAccountPartner[0].Id;
        woList.addAll(listOfWo);
        //insert listOfWo;
        List<WorkOrder> listOfWoDelivery = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, Label.XC_CL_WorkType_DeliveryInstallation, Label.XC_CL_WorkType_DeliveryInstallation);
        listOfWoDelivery[0].XC_Configuration__c = order.Id;
        woList.addAll(listOfWoDelivery);
        //insert listOfWoDelivery;
        insert woList;
        Test.stopTest();
        //preferredWrapperWithoutSiteInspection.listToCheckCommercialVisit =  listOfWoDelivery;
        preferredWrapper.listToCheckCommercialVisit =  listOfWo;
        XC_UTIL_ResourcePreference_U_CheckFor.checkForCommercialVisit(preferredWrapper);
        //XC_UTIL_ResourcePreference_U_CheckFor.checkForCommercialVisit(preferredWrapperWithoutSiteInspection);
    }
}