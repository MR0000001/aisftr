/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_U_PopulateSrType_TEST – Test Class for XC_TR_WorkOrder_U_PopulateServiceType
*/ 

@isTest
public class XC_TR_WorkOrder_U_PopulateSrType_TEST {

    @TestSetup
    static void insertCustomSetting (){
        Test.startTest();
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

        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        
        
        User u = XC_DF_User.createUserAdmin();
        u.Username = 'noCandidate@gmail.com';
        insert u;
        
        ServiceResource servRes = new ServiceResource(Name = Label.XC_CL_NoCandidateFound, 
                                                      XC_Account__c = accList[0].Id, 
                                                      isCapacityBased = true,
                                                      RelatedRecordId = u.Id, 
                                                      isActive = true );
        insert servRes;
        XC_CM_WorkOrderServiceType__mdt mdtNew = new XC_CM_WorkOrderServiceType__mdt(
        XC_WorkType__c = 'Return',
        XC_ProductName__c = 'OK Gas',
        XC_ServiceType__c = 'test new');
        Test.stopTest();
    }

    static testMethod void onInsert() {
        NE__Product__c prod = new NE__Product__c();
        prod.RecordTypeId = Schema.SObjectType.NE__Product__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
		prod.XC_Product_Type__c = 'Equipment';
        prod.XC_Product_Subtype__c = 'Boiler';
        insert prod;
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        List<XC_ProductCategoryOfInterest__c> prodInt = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c];
        List<Lead> leadWo = XC_DF_Lead.createResidentialLeads(1);
        leadWo[0].XC_MainLegalEntity__c = 'EndesaX';
        leadWo[0].XC_DocumentCountry__c = 'Spain';
        leadWo[0].XC_ProductCategoryOfInterest__c = prodInt[0].Name;
        insert leadWo;
        List<WorkOrder> woCommericalVisit = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        woCommericalVisit[0].XC_Lead__c = leadWo[0].Id;
        List<Asset> assetListBefore = XC_DF_Asset.createAssets(1);
        insert assetListBefore;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].NE__ProdId__c = prod.Id;
        assetList[0].NE__Bundle_Configuration__c = assetListBefore[0].Id;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_SubType__c = 'Boiler';
        insert assetList;
        Test.startTest();
        List<WorkOrder> woMaintenance = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        woMaintenance[0].AssetId = assetList[0].Id;
        List<WorkOrder> woRepair = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        NE__Order__c orderInserted2 = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried2 = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<NE__OrderItem__c> orderItemInserted2 = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueried2.Id];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderInserted.Id];
        orderItemInserted[0].NE__ProdId__c = prod.Id;
        orderItemInserted[0].NE__Bundle_Configuration__c = orderItemInserted2[0].Id;
        update orderItemInserted;
        List<WorkOrder> woDeliveryInstall = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woDeliveryInstall[0].XC_Configuration_Item__c = orderItemInserted[0].Id;
        List<WorkOrder> woListAll = new List<WorkOrder>();
        woListAll.addAll(woCommericalVisit);
        woListAll.addAll(woMaintenance);
        woListAll.addAll(woRepair);
        woListAll.addAll(woDeliveryInstall);
        insert woListAll;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(4, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    
    static testMethod void onInsert2() {
        NE__Product__c prod = new NE__Product__c();
        prod.RecordTypeId = Schema.SObjectType.NE__Product__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
		prod.XC_Product_Type__c = 'Service';
        prod.XC_LIC_Product_Name__c = 'OK Gas';
        prod.XC_Product_Subtype__c = 'Gas';
        insert prod;
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        List<XC_ProductCategoryOfInterest__c> prodInt = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c];
        List<Lead> leadWo = XC_DF_Lead.createResidentialLeads(1);
        leadWo[0].XC_MainLegalEntity__c = 'EndesaX';
        leadWo[0].XC_DocumentCountry__c = 'Spain';
        leadWo[0].XC_ProductCategoryOfInterest__c = prodInt[0].Name;
        insert leadWo;
        List<WorkOrder> woCommericalVisit = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        woCommericalVisit[0].XC_Lead__c = leadWo[0].Id;
        List<Asset> assetListBefore = XC_DF_Asset.createAssets(1);
        insert assetListBefore;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].NE__ProdId__c = prod.Id;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_SubType__c = 'Boiler';
        //assetList[0].NE__Bundle_Configuration__c = assetListBefore[0].Id;
        insert assetList;
        Test.startTest();
        List<WorkOrder> woMaintenance = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        woMaintenance[0].AssetId = assetList[0].Id;
        woMaintenance[0].XC_PositionInMaintenancePlan__c = 1;
        List<WorkOrder> woRepair = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        NE__Order__c orderInserted2 = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried2 = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<NE__OrderItem__c> orderItemInserted2 = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueried2.Id];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderInserted.Id];
        orderItemInserted[0].NE__ProdId__c = prod.Id;
        orderItemInserted[0].NE__Bundle_Configuration__c = orderItemInserted2[0].Id;
        update orderItemInserted;
        List<WorkOrder> woDeliveryInstall = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woDeliveryInstall[0].XC_Configuration_Item__c = orderItemInserted[0].Id;
        List<WorkOrder> woListAll = new List<WorkOrder>();
        woListAll.addAll(woCommericalVisit);
        woListAll.addAll(woMaintenance);
        woListAll.addAll(woRepair);
        woListAll.addAll(woDeliveryInstall);
        insert woListAll;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(4, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
        static testMethod void onInsert3() {
        NE__Product__c prod1 = new NE__Product__c();
        prod1.RecordTypeId = Schema.SObjectType.NE__Product__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
		prod1.XC_Product_Type__c = 'Service';
        prod1.XC_LIC_Product_Name__c = 'OK Gas';
        prod1.XC_Product_Subtype__c = 'Gas';
        insert prod1;
        NE__Product__c prod2 = new NE__Product__c();
        prod2.RecordTypeId = Schema.SObjectType.NE__Product__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
		prod2.XC_Product_Type__c = 'Equipment';
        prod2.XC_LIC_Product_Name__c = 'Baxi Sistema Termosifonico STS 150'; 
        prod2.XC_Product_Subtype__c = 'Solar Thermal';
        insert prod2;
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        List<XC_ProductCategoryOfInterest__c> prodInt = [SELECT Id, Name FROM XC_ProductCategoryOfInterest__c];
        List<Lead> leadWo = XC_DF_Lead.createResidentialLeads(1);
        leadWo[0].XC_MainLegalEntity__c = 'EndesaX';
        leadWo[0].XC_DocumentCountry__c = 'Spain';
        leadWo[0].XC_ProductCategoryOfInterest__c = prodInt[0].Name;
        insert leadWo;
        List<WorkOrder> woCommericalVisit = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        woCommericalVisit[0].XC_Lead__c = leadWo[0].Id;
        List<Asset> assetListBefore = XC_DF_Asset.createAssets(1);
        assetListBefore[0].RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        assetListBefore[0].XC_LegalEntity__c = 'EndesaX';
        assetListBefore[0].XC_Product_SubType__c = 'Boiler';
        insert assetListBefore;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].NE__ProdId__c = prod1.Id;
        assetList[0].NE__Bundle_Configuration__c = assetListBefore[0].Id;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_SubType__c = 'Boiler';
        insert assetList;
        Test.startTest();
        List<WorkOrder> woMaintenance = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        woMaintenance[0].AssetId = assetList[0].Id;
        woMaintenance[0].XC_PositionInMaintenancePlan__c = 1;
        List<WorkOrder> woRepair = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        NE__Order__c orderInserted2 = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried2 = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<NE__OrderItem__c> orderItemInserted2 = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueried2.Id];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderInserted.Id];
        orderItemInserted[0].NE__ProdId__c = prod2.Id;
        orderItemInserted[0].NE__Bundle_Configuration__c = orderItemInserted2[0].Id;
        update orderItemInserted;
        List<WorkOrder> woDeliveryInstall = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woDeliveryInstall[0].AssetId = assetList[0].Id;
        woDeliveryInstall[0].XC_Configuration_Item__c = orderItemInserted[0].Id;
        List<WorkOrder> woListAll = new List<WorkOrder>();
        woListAll.addAll(woCommericalVisit);
        woListAll.addAll(woMaintenance);
        woListAll.addAll(woRepair);
        woListAll.addAll(woDeliveryInstall);
        insert woListAll;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(4, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    static testMethod void onInsert4() {
        NE__Product__c prod1 = new NE__Product__c();
        prod1.RecordTypeId = Schema.SObjectType.NE__Product__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
		prod1.XC_Product_Type__c = 'Service';
        prod1.XC_LIC_Product_Name__c = 'OK Gas';
        prod1.XC_Product_Subtype__c = 'Gas';
        insert prod1;
        NE__Product__c prod2 = new NE__Product__c();
        prod2.RecordTypeId = Schema.SObjectType.NE__Product__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
		prod2.XC_Product_Type__c = 'Equipment';
        prod2.XC_LIC_Product_Name__c = 'Baxi Sistema Termosifonico STS 150'; 
        prod2.XC_Product_Subtype__c = 'Solar Thermal';
        insert prod2;
        List<Account> accListToInsert = XC_DF_Account.createResidentialAccounts(1);
        insert accListToInsert;
        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(1);
        contList[0].AccountId = accList[0].Id;
        insert contList;  
       
        List<Contact> cctList = [SELECT Id from Contact WHERE AccountId =: accList[0].Id];
        List<WorkOrder> woCommericalVisit = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
         List<Asset> assetListBefore = XC_DF_Asset.createAssets(1);
            assetListBefore[0].RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        assetListBefore[0].XC_LegalEntity__c = 'EndesaX';
        assetListBefore[0].XC_Product_SubType__c = 'Boiler';
        insert assetListBefore;
        
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].NE__ProdId__c = prod2.Id;
        assetList[0].Status = 'Active';
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_SubType__c = 'Boiler';
        assetList[0].ContactId = contList[0].Id;
        assetList[0].AccountId = accList[0].Id;
        assetList[0].NE__Bundle_Configuration__c = assetListBefore[0].Id;
        insert assetList;
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].AssetId = assetList[0].Id;
        caseList[0].ContactId = cctList[0].Id;
        caseList[0].AccountId = accList[0].Id;
        insert caseList;	
         Test.startTest();
        List<WorkOrder> woMaintenance = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        woMaintenance[0].AssetId = assetList[0].Id;
        woMaintenance[0].XC_PositionInMaintenancePlan__c = 1;
        List<WorkOrder> woRepair = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woRepair[0].CaseId = caseList[0].Id;
        woRepair[0].XC_Urgent_Repair__c = true;
        NE__Order__c orderInserted2 = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried2 = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<NE__OrderItem__c> orderItemInserted2 = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueried2.Id];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderInserted.Id];
        orderItemInserted[0].NE__ProdId__c = prod1.Id;
        orderItemInserted[0].NE__Bundle_Configuration__c = orderItemInserted2[0].Id;
        update orderItemInserted;
        List<WorkOrder> woDeliveryInstall = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woDeliveryInstall[0].AssetId = assetList[0].Id;
        woDeliveryInstall[0].XC_Configuration_Item__c = orderItemInserted[0].Id;
        List<WorkOrder> woListAll = new List<WorkOrder>();
        woListAll.addAll(woCommericalVisit);
        woListAll.addAll(woMaintenance);
        woListAll.addAll(woRepair);
        woListAll.addAll(woDeliveryInstall);
        
        insert woListAll;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(4, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
    static testMethod void onInsert5() {
        NE__Product__c prod1 = new NE__Product__c();
        prod1.RecordTypeId = Schema.SObjectType.NE__Product__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
		prod1.XC_Product_Type__c = 'Equipment';
        //prod1.XC_LIC_Product_Name__c = 'OK Gas';
        prod1.XC_Product_Subtype__c = 'Boiler';
        insert prod1;
        List<Account> accListToInsert = XC_DF_Account.createResidentialAccounts(1);
        insert accListToInsert;
        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(1);
        contList[0].AccountId = accList[0].Id;
        insert contList;
        List<Contact> cctList = [SELECT Id from Contact WHERE AccountId =: accList[0].Id];
        List<WorkOrder> woCommericalVisit = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        List<Asset> assetListBefore = XC_DF_Asset.createAssets(1);
        assetListBefore[0].RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        assetListBefore[0].XC_LegalEntity__c = 'EndesaX';
        assetListBefore[0].XC_Product_SubType__c = 'Boiler';
        insert assetListBefore; 
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].NE__ProdId__c = prod1.Id;
        assetList[0].Status = 'Active';
        assetList[0].ContactId = cctList[0].Id;
        assetList[0].AccountId = accList[0].Id;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_SubType__c = 'Boiler';
        assetList[0].NE__Bundle_Configuration__c = assetListBefore[0].Id;
        insert assetList;
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].AssetId = assetList[0].Id;
        caseList[0].ContactId = contList[0].Id;
        caseList[0].AccountId = accList[0].Id;
        insert caseList;	
        Test.startTest();
        List<WorkOrder> woMaintenance = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        woMaintenance[0].AssetId = assetList[0].Id;
        woMaintenance[0].XC_PositionInMaintenancePlan__c = 1;
        List<WorkOrder> woRepair = XC_DF_WorkOrder.createWorkOrders(1, 'Return');
        woRepair[0].CaseId = caseList[0].Id;
        woRepair[0].XC_Urgent_Repair__c = true;
        NE__Order__c orderInserted2 = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried2 = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<NE__OrderItem__c> orderItemInserted2 = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueried2.Id];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderInserted.Id];
        orderItemInserted[0].NE__ProdId__c = prod1.Id;
        orderItemInserted[0].NE__Bundle_Configuration__c = orderItemInserted2[0].Id;
        update orderItemInserted;
        List<WorkOrder> woDeliveryInstall = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woDeliveryInstall[0].AssetId = assetList[0].Id;
        woDeliveryInstall[0].XC_Configuration_Item__c = orderItemInserted[0].Id;
        List<WorkOrder> woListAll = new List<WorkOrder>();
        woListAll.addAll(woCommericalVisit);
        woListAll.addAll(woMaintenance);
        woListAll.addAll(woRepair);
        woListAll.addAll(woDeliveryInstall);
        
        insert woListAll;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(4, listInsertedWorkOrders.size());
        Test.stopTest();
    }
    
       
    static testMethod void onInsert6() {
        NE__Product__c prod1 = new NE__Product__c();
        prod1.RecordTypeId = Schema.SObjectType.NE__Product__c.getRecordTypeInfosByDeveloperName().get('Equipment').getRecordTypeId();
		prod1.XC_Product_Type__c = 'Service';
        prod1.XC_LIC_Product_Name__c = 'OK Gas';
        //prod1.XC_Product_Subtype__c = 'Boiler';
        insert prod1;
        List<Account> accListToInsert = XC_DF_Account.createResidentialAccounts(1);
        insert accListToInsert;
        List<Account> accList = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'XC_GLO_Account_Residential'];
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(1);
        contList[0].AccountId = accList[0].Id;
        insert contList;
        List<Contact> cctList = [SELECT Id from Contact WHERE AccountId =: accList[0].Id];
        List<WorkOrder> woCommericalVisit = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        List<Asset> assetListBefore = XC_DF_Asset.createAssets(1);
        assetListBefore[0].RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        assetListBefore[0].XC_LegalEntity__c = 'EndesaX';
        assetListBefore[0].XC_Product_SubType__c = 'Boiler';
        insert assetListBefore; 
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].NE__ProdId__c = prod1.Id;
        assetList[0].Status = 'Active';
        assetList[0].ContactId = cctList[0].Id;
        assetList[0].AccountId = accList[0].Id;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        //assetList[0].XC_Product_SubType__c = 'Boiler';
        //assetList[0].NE__Bundle_Configuration__c = assetListBefore[0].Id;
        insert assetList;
        List<Case> caseList = XC_DF_Case.createCases(1);
        caseList[0].AssetId = assetList[0].Id;
        caseList[0].ContactId = contList[0].Id;
        caseList[0].AccountId = accList[0].Id;
        insert caseList;	
        Test.startTest();
        List<WorkOrder> woMaintenance = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        woMaintenance[0].AssetId = assetList[0].Id;
        woMaintenance[0].XC_PositionInMaintenancePlan__c = 3;
        List<WorkOrder> woRepair = XC_DF_WorkOrder.createWorkOrders(1, 'Return');
        woRepair[0].CaseId = caseList[0].Id;
        woRepair[0].XC_Urgent_Repair__c = true;
        NE__Order__c orderInserted2 = XC_DF_Order.createOrder('InOrder');
        NE__Order__c orderQueried2 = [SELECT Id, RecordType.DeveloperName, XC_Status__c FROM NE__Order__c];
        List<NE__OrderItem__c> orderItemInserted2 = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderQueried2.Id];
        NE__Order__c orderInserted = XC_DF_Order.createOrder('InOrder');
        List<NE__OrderItem__c> orderItemInserted = [SELECT Id FROM NE__OrderItem__c WHERE NE__OrderId__c =: orderInserted.Id];
        orderItemInserted[0].NE__ProdId__c = prod1.Id;
        orderItemInserted[0].NE__Bundle_Configuration__c = orderItemInserted2[0].Id;
        update orderItemInserted;
        List<WorkOrder> woDeliveryInstall = XC_DF_WorkOrder.createWorkOrders(1, 'Delivery & Installation');
        woDeliveryInstall[0].AssetId = assetList[0].Id;
        woDeliveryInstall[0].XC_Configuration_Item__c = orderItemInserted[0].Id;
        List<WorkOrder> woListAll = new List<WorkOrder>();
        woListAll.addAll(woCommericalVisit);
        woListAll.addAll(woMaintenance);
        woListAll.addAll(woRepair);
        woListAll.addAll(woDeliveryInstall);
        
        insert woListAll;
        List<WorkOrder> listInsertedWorkOrders = [SELECT Id FROM WorkOrder];
        System.assertEquals(4, listInsertedWorkOrders.size());
        Test.stopTest();
    }

}