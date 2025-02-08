/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation  29/04/2019 
* @description XC_TR_WorkOrder_U_FillFieldByAsset_TEST – Test class for XC_TR_WorkOrder_U_FillFieldByAsset
*/
@isTest
private class XC_TR_WorkOrder_U_FillFieldByAsset_TEST {
    
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(1);
        insert addressList;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        for(Asset a : assetList){
            a.XC_Address__c = addressList[0].Id;
        }
        insert assetList; 
        /*        List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true];
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
    static void fillFieldsFromAsset1() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Asset> assetList = new List<Asset>([SELECT Id FROM Asset LIMIT 1]);
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_Installation);
        for(WorkOrder wo : woList){
            wo.AssetId = assetList[0].Id;
        }
        insert woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    @isTest
    static void fillFieldsFromAsset2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Asset> assetList = new List<Asset>([SELECT Id FROM Asset LIMIT 1]);
        List<WorkOrder> woList5 =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList5){
            wo.AssetId = assetList[0].Id;
        }
        insert woList5;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    @isTest
    static void fillFieldsFromAsset3() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Asset> assetList = new List<Asset>([SELECT Id FROM Asset LIMIT 1]);
        List<WorkOrder> woList2 =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_PlannedMaintenance);
        for(WorkOrder wo : woList2){
            wo.AssetId = assetList[0].Id;
        }
        insert woList2;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    @isTest
    static void fillFieldsFromAsset4() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Asset> assetList = new List<Asset>([SELECT Id FROM Asset LIMIT 1]);
        List<WorkOrder> woList4 =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_PlannedMaintenance);
        for(WorkOrder wo : woList4){
            wo.AssetId = assetList[0].Id;
            wo.XC_SubStatus__c = Label.XC_CL_WorkOrder_Anomalies;
        }
        insert woList4;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    @isTest
    static void fillFieldsFromAsset6() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Asset> assetList = new List<Asset>([SELECT Id FROM Asset LIMIT 1]);
        List<WorkOrder> woList1 =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        List<WorkOrder> woList4 =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_PlannedMaintenance);
        for(WorkOrder wo : woList4){
            wo.AssetId = assetList[0].Id;
            wo.XC_SubStatus__c = Label.XC_CL_WorkOrder_Anomalies;
        }
        insert woList4;
        for(WorkOrder wo : woList1){
            wo.AssetId = assetList[0].Id;
            wo.StartDate = DateTime.now().addDays(-10);
            wo.EndDate = DateTime.now().addDays(-10);
            wo.XC_Urgent_Repair__c = true;
        }
        insert woList1;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(2, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    @isTest
    static void fillFieldsFromAsset5() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Asset> assetList = new List<Asset>([SELECT Id FROM Asset LIMIT 1]);
        List<WorkOrder> woList1 =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        for(WorkOrder wo : woList1){
            wo.AssetId = assetList[0].Id;
            wo.StartDate = DateTime.now().addDays(-10);
            wo.EndDate = DateTime.now().addDays(-10);
            wo.XC_Urgent_Repair__c = true;
            wo.XC_Address__c = null;
        }
        insert woList1;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    @isTest
    static void checkChangedWarrantyResolution() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        insert woList;
        for(WorkOrder wo : woList){ 
            wo.XC_WarrantyResolution__c =  Label.XC_CL_WarrantyResolution;
            wo.XC_Urgent_Repair__c = true;
        }
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
	    @isTest
    static void fillFieldsFromAssetOnUpdate(){
                insert XC_DF_OneOrg.createOneOrg('Spain');
         id rtIdB2B =Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        Test.startTest();
        List<Asset> assetList = new List<Asset>([SELECT Id FROM Asset LIMIT 1]);
        List<WorkOrder> woList1 =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        for(WorkOrder wo : woList1){
           // wo.AssetId = assetList[0].Id;
            wo.StartDate = DateTime.now().addDays(-10);
            wo.EndDate = DateTime.now().addDays(-10);
            wo.XC_Urgent_Repair__c = true;
          //  wo.XC_Segment__c='B2B';
        }
        insert woList1;
        woList1[0].RecordTypeId=rtIdB2B;
        woList1[0].XC_Segment__c='B2B'; 
        update woList1;
       for(WorkOrder wo : woList1){
            wo.AssetId = assetList[0].Id;
        }
        update woList1;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listInsertedWorkOrders.size());
        Test.stopTest();
    }
}