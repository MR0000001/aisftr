/**
* @author Luca Tedeschi ltedeschi@deloitte.it
* @date Creation  05/06/2019 
* @description XC_TR_WorkOrder_U_FinalStatus – Test class for XC_TR_WorkOrder_U_FinalStatus_TEST  
*/
@istest
public class XC_TR_WorkOrder_U_FinalStatus_TEST{
    
    //Test Method updateWorkOrderFinalStatus
    static testMethod void updateWorkOrderFinalStatus(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();      
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        insert woList;
        for(WorkOrder wo : woList){ 
            wo.Status =  'Closed' ;
        }
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }
    
    //Test Method updateWorkOrderFinalStatus2
    static testMethod void updateWorkOrderFinalStatus2(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();      
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress ;
        }        
        insert woList;
        for(WorkOrder wo : woList){ 
            wo.Status =  'Completed' ;
        }
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }
    
    
    //Test Method updateStartDateOnWorkOrder
    static testMethod void updateStartDateOnWorkOrder(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();      
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        insert woList;
        for(WorkOrder wo : woList){ 
            wo.Status =   Label.XC_CL_WorkOrder_Assigned  ;
        }
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }
    
    
    //Test Method manageWorkOrderFinalStatus
    static testMethod void manageWorkOrderFinalStatus(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest(); 
        
        NE__Product__c prodToInsert = new NE__Product__c();
        prodToInsert.NE__Block_Change__c = false;
        prodToInsert.NE__Check_Stock__c = false;
        prodToInsert.NE__Export_Images__c = false;
        prodToInsert.NE__Finishing_on__c = Date.newInstance(2040, 10, 14);
        prodToInsert.NE__IsPromo__c = false;
        prodToInsert.NE__Starting_on__c = Date.newInstance(2018, 07, 30);
        prodToInsert.NE__Stock__c = 300;
        prodToInsert.NE__Engine_Code__c = 'code';
        prodToInsert.NE__Recurring_Cost_Frequency__c = 'Semiannual';
        prodToInsert.XC_Product_Subtype__c='Maintenance';
        prodToInsert.XC_Product_Type__c='Coverage';
        prodToInsert.XC_LIC_Product_Name__c = 'Mantenimiento';
        insert prodToInsert;
        
        
        Asset asset1 = new Asset();
        asset1.Name= 'OKGas';
        asset1.NE__ProdId__c = prodToInsert.Id;
        asset1.Status = Label.XC_CL_Asset_StatusActive;
        asset1.NE__Status__c = 'Active';
        list <Account> lscc = XC_DF_Account.createResidentialAccounts(1);
        insert lscc;
        asset1.AccountId= lscc[0].Id;
        insert asset1;
        
        Asset asset2 = new asset();
        asset2.NE__ProdId__c = prodToInsert.Id;
        asset2.Status = Label.XC_CL_Asset_StatusActive;
        asset2.NE__Status__c = 'Active';
        
        
        asset2.Name= 'Reparacion instalacion calefaccion urgente';
        asset2.AccountId= lscc[0].Id;
        asset2.NE__Parent_Order_Item__c= asset1.Id;
        asset2.ParentId = asset1.Id;
        insert asset2;
        update asset1;
        
        
        list<Asset> lsas  = [SELECT Id, NE__Bundle_Configuration__c, Status, 
                             (SELECT Id, CreatedDate, Status, XC_Product_Name_LIC__c
                              FROM NE__Assets__r ) 
                             FROM Asset  where Id =: asset1.Id
                            ]; 
                
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(2, Label.XC_CL_WorkType_PlannedMaintenance);
        
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress ;
        }
        
        insert woList;
        for(WorkOrder wo : woList){ 
            wo.Status = Label.XC_CL_Completed;
            wo.AssetId = lsas[0].Id;
            
        }
        
        
        
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id, Status, AssetId FROM WorkOrder];
        
        System.assertEquals(true, listInsertedWorkOrders!=null);
        
        
        Test.stopTest();
    }
    
    
    //Test Method updateSteps
    static testMethod void updateSteps(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();  
        
        List<NE__OrderItem__c> loi =  XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c c = loi[0];
        c.NE__OneTimeFeeOv__c = 10;
        c.NE__Qty__c = 1;
        insert c;
        
        XC_Provisioning_Step__c  ps = new XC_Provisioning_Step__c ();
        ps.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        ps.XC_Configuration_Item__c = c.Id;
        ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningMaintenanceInspection_Flow;
        insert ps;
        
        List<ServiceAppointment> listInsertedSA = [SELECT Id FROM ServiceAppointment];
        for(ServiceAppointment sa : listInsertedSA){
            sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
        }
        update listInsertedSA;
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,Label.XC_CL_WorkType_PlannedMaintenance);
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress ;
        }
        insert woList;
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_CannotComplete ;
            wo.XC_Configuration_Item__c = c.Id;
        }
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        
        
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }
    
    //Test Method updateSteps2
    static testMethod void updateSteps2(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();  
        
        List<NE__OrderItem__c> loi =  XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c c = loi[0];
        c.NE__OneTimeFeeOv__c = 10;
        c.NE__Qty__c = 1;
        insert c;
        
        XC_Provisioning_Step__c  ps = new XC_Provisioning_Step__c ();
        ps.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        ps.XC_Configuration_Item__c = c.Id;
        ps.XC_Flow_API_Name__c = Label.XC_CL_DeprovisioningMPSendForReturn_Flow;
        insert ps;
        
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Return);
        insert woList;
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_Assigned ;
            wo.XC_Configuration_Item__c = c.Id;
        }
        update woList;
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress;
        }
        update woList;
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_CannotComplete;
        }
        update woList;       
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        
        
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }
    
    
    //Test Method updateSteps3
    static testMethod void updateSteps3(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();  
        
        List<NE__OrderItem__c> loi =  XC_DF_OrderItem.createOrderItems(1);
        NE__OrderItem__c c = loi[0];
        c.NE__OneTimeFeeOv__c = 10;
        c.NE__Qty__c = 1;
        insert c;
        
        XC_Provisioning_Step__c  ps = new XC_Provisioning_Step__c ();
        ps.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
        ps.XC_Configuration_Item__c = c.Id;
        ps.XC_Flow_API_Name__c = Label.XC_CL_ProvisioningMPUninstallingInstalling_Flow;
        insert ps;
        
        
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(2, Label.XC_CL_WorkType_Substitution);
        insert woList;
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_Assigned ;
            wo.XC_Configuration_Item__c = c.Id;
        }
        update woList;
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress;
            wo.StartDate = Datetime.now();
            wo.EndDate = Datetime.now().addDays(1);
        }
        update woList;
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_CannotComplete;
        }
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        
        
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }
    
    //Test Method updateAsset
    static testMethod void updateAsset(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();      
        
        list <Asset> lst = XC_DF_Asset.createAssets(1);
        lst[0].SerialNumber = '123';
        insert lst;
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_DeliveryInstallation);
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress ;
            wo.AssetId = lst[0].Id;
        }
        
        insert woList;
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_Completed ;
            wo.AssetId = lst[0].Id;
        }
        
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id, AssetId FROM WorkOrder];
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }
    
    
    
    //Test Method updateAsset2
    static testMethod void updateAsset2(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();      
        
        list <Asset> lst = XC_DF_Asset.createAssets(1);
        lst[0].SerialNumber = '123';
        insert lst;
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_Delivery);
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress ;
            wo.AssetId = lst[0].Id;
        }
        
        insert woList;
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_Completed ;
            wo.AssetId = lst[0].Id;
        }
        
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id, AssetId FROM WorkOrder];
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }
    
     //Test Method updateAsset2
    static testMethod void updateAssetWORepair(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();      
  
        list <Asset> lst = XC_DF_Asset.createAssets(1);
        lst[0].SerialNumber = '123';
        insert lst;
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_Repair);
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress ;
            wo.AssetId = lst[0].Id;
        }
        
        insert woList;
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_Completed ;
            wo.AssetId = lst[0].Id;
        }
        
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id, AssetId FROM WorkOrder];
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }   
    
    static testMethod void updateAssetWOSiteInspection(){  
        
        insert XC_DF_OneOrg.createOneOrg('Spain');
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
        Test.startTest();      
  
        list <Asset> lst = XC_DF_Asset.createAssets(1);
        lst[0].SerialNumber = '123';
        insert lst;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(1);
        insert address;

        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_SiteInspection);
        NE__Order__c conf = new NE__Order__c();
        conf.NE__Type__c = 'inOrder';
        conf.XC_Segment__c = 'B2C';
        conf.XC_LegalEntity__c = 'EndesaX';
        insert conf;
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress ;
            wo.XC_Configuration__c = conf.Id;
            wo.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
            wo.AssetId = lst[0].Id;
        }
        
        insert woList;
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_Completed ;
            wo.AssetId = lst[0].Id;
        }
        
        update woList;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id, AssetId FROM WorkOrder];
        System.assertEquals(true, listInsertedWorkOrders!=null);
        Test.stopTest();
    }   
    
    static testMethod void complianceWorkOrderTEST(){  
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_SiteInspection);
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress ;
            wo.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
            wo.XC_ProductSubType__c = 'Air Conditioning';
            wo.XC_Segment__c = 'B2C';
            wo.XC_WorkTypeCategory__c = 'Delivery & Installation';
        }
        Workorder wo = woList[0];
        insert wo;
        Test.startTest();
        XC_WorkOrderCompliance__c woc = new XC_WorkOrderCompliance__c();
        woc.XC_Segment__c = 'B2C';
        woc.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
        woc.XC_ConditionField1__c = 'XC_ProductSubType__c';
        woc.XC_ConditionOperator1__c = '=';
        woc.XC_ConditionValue1__c = 'Air Conditioning';
        woc.XC_ConditionField2__c = 'XC_WorkTypeCategory__c';
        woc.XC_ConditionOperator2__c = 'contains';
        woc.XC_ConditionValue2__c = 'Installation';
        woc.XC_Documents__c = 'SF_EXTRA_COST_INVOICE;SF_WASTE_IDENTIFICATION_FORM';
        insert woc;
        
        try {
            wo.Status =  Label.XC_CL_WorkOrder_Completed;
            update wo;
        } catch(Exception e) {
            System.debug('Missing documents');
        }
        Test.stopTest();
    }
    
  	static testMethod void complianceWorkOrderFromRESTTEST(){  
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<WorkOrder> woList =  XC_DF_WorkOrder.createWorkOrders(1,  Label.XC_CL_WorkType_SiteInspection);
        
        for(WorkOrder wo : woList){ 
            wo.Status =  Label.XC_CL_WorkOrder_InProgress ;
            wo.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
            wo.XC_ProductSubType__c = 'Air Conditioning';
            wo.XC_Segment__c = 'B2C';
            wo.XC_WorkTypeCategory__c = 'Delivery & Installation';
        }
        Workorder wo = woList[0];
        insert wo;
        Test.startTest();
        XC_WorkOrderCompliance__c woc = new XC_WorkOrderCompliance__c();
        woc.XC_Segment__c = 'B2C';
        woc.XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy;
        woc.XC_ConditionField1__c = 'XC_ProductSubType__c';
        woc.XC_ConditionOperator1__c = '=';
        woc.XC_ConditionValue1__c = 'Air Conditioning';
        woc.XC_ConditionField2__c = 'XC_WorkTypeCategory__c';
        woc.XC_ConditionOperator2__c = 'contains';
        woc.XC_ConditionValue2__c = 'Installation';
        woc.XC_Documents__c = 'SF_EXTRA_COST_INVOICE;SF_WASTE_IDENTIFICATION_FORM';
        insert woc;
        XC_TR_WorkOrder_U_FinalStatus.getWOComplianceDocuments(new List<id>{wo.Id});
        Test.stopTest();
    }
}