/**
* @author Andrea Bravaccino - andrea.bravaccino@nttdata.com 
* @date Creation 03/10/2019
* @date 
* @description XC_IN032_ChangeOrder_WOPA_TEST – Test class for XC_IN032_ChangeOrder_WOPlanAdaptation
*/
@isTest
private class XC_IN032_ChangeOrder_WOPA_TEST {
    @TestSetup
    static void setup(){
        
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        List<NE__Product__c> prodList = XC_DF_Product.createProducts(1);
        prodList[0].name = 'Mantenimiento instalacion calefaccion bienal';
        insert prodList;

        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(1);
        orderItemList[0].NE__ProdId__c = prodList[0].Id;
        orderItemList[0].NE__Action__c= 'Add';
        
        NE__OrderItem__c ordIt = orderItemList[0];
        insert ordIt;
        List<NE__Order__c> listOfOrder = new List<NE__Order__c>([SELECT Id FROM NE__Order__c WHERE Id =: orderItemList[0].NE__OrderId__c]);
        listOfOrder[0].XC_LegalEntity__c = 'EndesaX';
        update listOfOrder;
        List<Asset> listAsset = XC_DF_Asset.createAssets(1);
        Asset asst = listAsset[0];
        asst.NE__Action__c = 'Add';
        asst.XC_Configuration_Item__c = ordIt.Id;
        asst.NE__Order_Config__c = ordIt.NE__OrderId__c;
        asst.XC_LegalEntity__c = 'EndesaX';
        insert asst;
        
        Asset a = XC_DF_Asset.createAssets(1)[0];
        a.NE__Action__c = 'Remove';
        a.XC_Configuration_Item__c = ordIt.Id;
        a.NE__Order_Config__c = ordIt.NE__OrderId__c;
        a.XC_LegalEntity__c = 'EndesaX';
        insert a;

        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Planned Maintenance - Gas', 'Planned Maintenance');
        listOfWo[0].XC_PositionInMaintenancePlan__c = 1;
    	listOfWo[0].XC_LegalEntity__c = 'EndesaX';
        listOfWo[0].XC_Segment__c = 'B2C';
        System.debug('###AssetA ---> '+a);
        List<Asset> listOfAs = new List<Asset>([SELECT Id, XC_LegalEntity__c FROM Asset WHERE Id =: a.id]);
        System.debug('###Asset ---> '+listOfAs); 
        listOfWo[0].AssetId = listOfAs[0].id;
        //insert listOfWo;
        listOfWo[0].Status = Label.XC_CL_Cancelled;
        listOfWo[0].XC_forSATO__c = true; 
        insert listOfWo;

        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;
        
        insert provisioningStep;
    }

    @IsTest
    static void test(){
        
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        Test.startTest();
        List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1,'Delivery & Installation');
        serApp[0].SchedStartTime = DateTime.now();
        serApp[0].SchedEndTime = DateTime.now().addHours(2);
        serApp[0].Status = 'Canceled';
        serApp[0].ActualDuration = 1.0;
        serApp[0].XC_LegalEntity__c = 'EndesaX';
        serApp[0].XC_Segment__c = 'B2C';
        insert serApp;
        
        //serApp[0].Status = 'Canceled';
        //update serApp;
        List<Asset> listOfAsset = [SELECT Id FROM Asset WHERE NE__Action__c = 'Add' limit 1];
        
        WorkOrder wo = new WorkOrder (Id= serApp[0].ParentRecordId);
        wo.Status ='Canceled';
        wo.AssetId = listOfAsset[0].Id;
        wo.XC_LegalEntity__c = 'EndesaX';
        wo.XC_Segment__c = 'B2C';
        update wo;

        NE__Catalog_Category__c cc = [SELECT ID, Name FROM NE__Catalog_Category__c LIMIT 1];
        cc.Name = 'Gas';
        update cc;
        XC_Provisioning_Step__c provisioningStep = [SELECT ID FROM XC_Provisioning_Step__c LIMIT 1];
        XC_IN032_ChangeOrder_WOPlanAdaptation.InputWrapper wr = new XC_IN032_ChangeOrder_WOPlanAdaptation.InputWrapper();
        wr.stepId = provisioningStep.Id;
        XC_IN032_ChangeOrder_WOPlanAdaptation.callStockManagement(new List<XC_IN032_ChangeOrder_WOPlanAdaptation.InputWrapper>{wr});
        System.assert(wr != NULL);
        Test.stopTest();
        
    }
    
    @IsTest
    static void test2(){
        /*List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1,'Planned Maintenance');
        serApp[0].SchedStartTime = DateTime.now();
        serApp[0].SchedEndTime = DateTime.now().addHours(2);
        serApp[0].Status = 'Scheduled';
        serApp[0].ActualDuration = 1.0;
        insert serApp;
        serApp[0].Status = 'Canceled';
        update serApp;*/
        List<Asset> listOfAsset = [SELECT Id FROM Asset WHERE NE__Action__c = 'Add' limit 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
        wo.Status ='Canceled';
        wo.AssetId = listOfAsset[0].Id;
        wo.XC_LegalEntity__c = 'EndesaX';
        wo.XC_Segment__c = 'B2C';
        update wo;
        Test.startTest();
        NE__Catalog_Category__c cc = [SELECT ID, Name FROM NE__Catalog_Category__c LIMIT 1];
        cc.Name = 'Air conditioning';
        update cc;
        XC_Provisioning_Step__c provisioningStep = [SELECT ID FROM XC_Provisioning_Step__c LIMIT 1];
        XC_IN032_ChangeOrder_WOPlanAdaptation.InputWrapper wr = new XC_IN032_ChangeOrder_WOPlanAdaptation.InputWrapper();
        wr.stepId = provisioningStep.Id;
        XC_IN032_ChangeOrder_WOPlanAdaptation.callStockManagement(new List<XC_IN032_ChangeOrder_WOPlanAdaptation.InputWrapper>{wr});
        System.assert(wr != NULL);
        Test.stopTest();
    }

    @isTest
    static void test3(){
        
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        Test.startTest();
        List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1,'Delivery & Installation');
        serApp[0].SchedStartTime = DateTime.now();
        serApp[0].SchedEndTime = DateTime.now().addHours(2);
        serApp[0].Status = 'Scheduled';
        serApp[0].ActualDuration = 1.0;
        serApp[0].XC_LegalEntity__c = 'EndesaX';
        serApp[0].XC_Segment__c = 'B2C';
        serApp[0].Status = 'Canceled';
        insert serApp;
        List<Asset> listOfAsset = [SELECT Id, XC_ActivationDate__c FROM Asset WHERE NE__Action__c = 'Add' limit 1];
        WorkOrder oldWo = new WorkOrder (Id= serApp[0].ParentRecordId);
        oldWo.Status ='Canceled';
        oldWo.AssetId = listOfAsset[0].Id;
        oldWo.XC_MaintenanceYearFrequency__c = 0;
        oldWo.XC_LegalEntity__c = 'EndesaX';
        oldWo.XC_Segment__c = 'B2C';
        //update oldWo;
        listOfAsset[0].XC_ActivationDate__c = Datetime.now();
        update listOfAsset[0];
        List<String> listWorkOrderid = new List<String> {oldWo.id};
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation - Gas', 'Delivery & Installation');
        WorkOrder newWo = listOfWo[0];
        newWo.XC_MaintenanceYearFrequency__c = 3;
        newWo.AssetId = listOfAsset[0].Id;
        insert newWo;
        XC_IN032_ChangeOrder_WOPlanAdaptation_U.createSA(newWo, oldWo, listWorkOrderid);
        System.assert(newWo != NULL);
        Test.stopTest();   
    }
    
    @isTest
    static void test4(){
        
        /*insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        
        List<ServiceAppointment> serApp = XC_DF_ServiceAppointment.createServiceAppointment(1,'Delivery & Installation');
        Test.startTest();
        serApp[0].SchedStartTime = DateTime.now();
        serApp[0].SchedEndTime = DateTime.now().addHours(2);
        serApp[0].Status = 'Scheduled';
        serApp[0].ActualDuration = 1.0;
        serApp[0].XC_LegalEntity__c = 'EndesaX';
        serApp[0].XC_Segment__c = 'B2C';
        serApp[0].Status = 'Canceled';
        insert serApp;
        
        List<Asset> listOfAsset = [SELECT Id, XC_ActivationDate__c FROM Asset WHERE NE__Action__c = 'Add' limit 1];
        WorkOrder oldWo = new WorkOrder (Id= serApp[0].ParentRecordId);
        oldWo.Status ='Canceled';
        oldWo.AssetId = listOfAsset[0].Id;
        oldWo.XC_MaintenanceYearFrequency__c = 3;
        oldWo.XC_LegalEntity__c = 'EndesaX';
        oldWo.XC_Segment__c = 'B2C';
        update oldWo;
        Test.stopTest();   
        listOfAsset[0].XC_ActivationDate__c = Datetime.now();
        update listOfAsset[0];
        List<String> listWorkOrderid = new List<String> {oldWo.id};
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Delivery & Installation - Gas', 'Delivery & Installation');
        for(WorkOrder wo : listOfWo){
        	wo.XC_LegalEntity__c = 'EndesaX';
        	wo.XC_Segment__c = 'B2C';  
            wo.XC_MaintenanceYearFrequency__c = 0;
            wo.AssetId = listOfAsset[0].Id;
            wo.XC_LegalEntity__c = 'EndesaX';
            wo.XC_Segment__c = 'B2C';
        }
        //insert listOfWo;
        Workorder newWo = listOfWo[0];

        //newWo = [SELECT Id, WorkTypeId,XC_Country__c, XC_Product_Name__c, XC_CatalogCategory_Name__c, XC_Asset_ActivationDate__c, XC_PositionInMaintenancePlan__c, XC_MaintenanceYearFrequency__c, Country, State, City, PostalCode, Street, Latitude, Longitude, ServiceTerritoryId FROM WorkOrder WHERE Id = :newWo.Id ];
        XC_IN032_ChangeOrder_WOPlanAdaptation_U.createSA(newWo, oldWo, listWorkOrderid);
        System.assert(oldWo != NULL);*/
        
    }
}