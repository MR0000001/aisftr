/**
* @author FSL Team - marco.rosa@nttdata.com
* @date Creation 10/06/2020
* @description  – XC_UTIL_WOCreateSalesOrder_TEST -  
*/ 
@isTest
public without sharing class XC_UTIL_WOCreateSalesOrder_TEST {
    
    @testSetup
    static void testSetup() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
         
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        Id partnerAccountId = listSR[0].XC_Account__c;
        
        List<WorkOrder> listWo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_DeliveryInstallation);
        WorkOrder wo = listWo[0];
        wo.XC_Segment__c = 'B2C';
        wo.XC_LegalEntity__c = 'EndesaX';
        wo.PostalCode = '28050';
        wo.XC_FSLAssignmentKey__c = '28050'; 
        wo.XC_AssignedPartner__c = partnerAccountId;
        insert wo; 
         
        gii__WarehouseGroup__c  wareHouseGroup = new gii__WarehouseGroup__c(
            Name='Test-Network'
        );
        insert wareHouseGroup;
        gii__Warehouse__c whCentral = new gii__Warehouse__c(
            gii__WareHouseCountry__c = 'Spain',
            gii__WareHouseStateProvince__c = 'Madrid',
            gii__WareHouseStreet__c = 'Test',
            gii__WareHouseZipPostalCode__c = '28050',
            gii__WareHouseCity__c = 'Madrid',
            giic_WarehouseCode__c = 'Test',
            giic_LegalEntity__c = 'EndesaX',
            gii__WarehouseGroup__c = wareHouseGroup.Id
         );
        insert whCentral;
        gii__Warehouse__c wh = new gii__Warehouse__c(
            gii__Account__c = partnerAccountId,
            gii__WareHouseCountry__c = 'Spain',
            gii__WareHouseStateProvince__c = 'Madrid',
            gii__WareHouseStreet__c = 'Test',
            gii__WareHouseZipPostalCode__c = '28050',
            gii__WareHouseCity__c = 'Madrid',
            giic_WarehouseCode__c = 'Test2',
            giic_LegalEntity__c = 'EndesaX',
            gii__WarehouseGroup__c = wareHouseGroup.Id,
            giic_ParentWarehouse__c = whCentral.Id
        );
        insert wh;
        gii__Location__c objLocationCentral = new gii__Location__c(
            Name='Central Location',
            gii__Warehouse__c=wh.Id,
            giic_LocationCode__c = 'CLWH', 
            giic_LocationType__c = 'Sales'
        );
        insert objLocationCentral;
        
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Propano',
            XC_ProductSubType__c = 'Enel Spare Part',
            XC_Country__c = 'Spain',
            giic_LegalEntity__C = 'EndesaX'
        ); 
        Product2 p3 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Propano2',
            XC_ProductSubType__c = 'Enel Spare Part',
            giic_LegalEntity__C = 'EndesaX',
            XC_Country__c = 'Spain'
        );
        insert new List<Product2>{p2, p3};
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id, gii__ProductReference__c
            FROM gii__Product2Add__c
            LIMIT 2
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        pAdd[0].gii__ProductCode__c = 'Propano';
        pAdd[1].giic_ProcurementType__c = 'Transfer';
        pAdd[1].gii__ProductCode__c = 'Propano2'; 
        padd[1].gii__ProductStyle__c = pAdd[0].Id;
        update pAdd;
        ProductRequired pr = new ProductRequired(
            ParentRecordId = wo.Id,
            Product2Id = p2.Id,
            XC_ProcurementType__c = 'Transfer',
            QuantityRequired = 1,
            XC_Mode__c = 'Add',
            XC_ConcatenatedWBE__c = 'AAAAAAAAAAAAAAAAAA',
            XC_ConcatenatedCostCenter__c = 'AAAAAAAA'
        );
        insert pr; 

        gii__ProductInventory__c pi2 = new gii__ProductInventory__c(
            giic_AccountId__c = partnerAccountId,
            gii__Warehouse__c = wh.Id,
            gii__Product__c = pAdd[0].Id
        );
        gii__ProductInventory__c pi3 = new gii__ProductInventory__c(
            giic_AccountId__c = partnerAccountId,
            gii__Warehouse__c = wh.Id,
            gii__Product__c = pAdd[1].Id
        );
        insert new List<gii__ProductInventory__c>{pi2,pi3};
        gii__ProductInventorybyLocation__c pil2 = new gii__ProductInventorybyLocation__c(
            gii__ProductInventory__c = pi2.Id,
            gii__Product__c = pAdd[0].Id,
            gii__Warehouse__c = wh.Id,
            giic_SalesOnHand__c = 1
        );
        gii__ProductInventorybyLocation__c pil3 = new gii__ProductInventorybyLocation__c(
            gii__ProductInventory__c = pi3.Id,
            gii__Product__c = pAdd[1].Id,
            gii__Warehouse__c = wh.Id,
            giic_SalesOnHand__c = 1
        );
        insert new List<gii__ProductInventorybyLocation__c>{pil2,pil3};
        insert XC_DF_ServiceAppointment.createServiceAppointment(new List<WorkOrder>{wo});
    } 
    
    @isTest
    static void GoodIssueDI(){ 
        String query = XC_UTIL_SObject.selectAllFieldsGetSelect('WorkOrder') + ' FROM WorkOrder LIMIT 1';
        List<WorkOrder> listWo = Database.query(query);
        Test.startTest();  
        XC_UTIL_WOCreateSalesOrder.createSalesOrder(listWo); 
        XC_UTIL_WOCreateSalesOrder.createSOLineWrapper(1, null, null, null, null, null);
        Test.stopTest();
    }
    
    @isTest
    static void GoodIssueDelivery(){ 
        List<WorkOrder> listWo = [SELECT Id FROM WorkOrder LIMIT 1];
        Test.startTest();  
        XC_UTIL_WOCreateSalesOrder.createSalesOrderDelivery(listWo[0].Id); 
        Test.stopTest();
    }
    
    @isTest
    static void GoodIssueRepair(){    
        List<Account> listAcc = XC_DF_Account.createResidentialAccounts(1);
        listAcc[0].XC_Country__c = 'Spain';
        insert listAcc;     
        List<WorkOrder> listWo = [SELECT Id FROM WorkOrder LIMIT 1];
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        insert order;
        NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(order);
        insert orderItem;  
        Opportunity opportunityToInsert = new Opportunity();
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('XC_Opportunity_Spain').getRecordTypeId(); 
        opportunityToInsert.recordTypeId = recordTypeId;
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.AccountId = listAcc[0].Id;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Termo';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        opportunityToInsert.XC_WorkOrder__c = listWo[0].Id;
        insert opportunityToInsert;
        order.NE__OptyId__c = opportunityToInsert.Id;
        order.XC_LegalEntity__c = 'EndesaX';
        Test.startTest();  
        update order;
        
        Asset asst = new Asset();
        asst.Name = 'Test Asset';
        asst.AccountId = listAcc[0].Id;
        asst.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        asst.XC_LegalEntity__c = Label.XC_CL_EndesaX;
        asst.XC_Segment__c  = 'B2C';
        asst.NE__Order_Config__c = order.Id;
        asst.XC_Configuration_Item__c = orderItem.Id;
		asst.XC_Product_Type__c = 'Technical';
		asst.XC_Product_Subtype__c = 'Product';
        insert asst;
        
        NE__DynamicPropertyDefinition__c b = new NE__DynamicPropertyDefinition__c();
        b.XC_LIC_DynamicPropertyDefinition__c = 'Referencia';
        insert b;
        
        NE__Family__c f = new NE__Family__c();
        insert f;
        
        NE__ProductFamilyProperty__c a = new NE__ProductFamilyProperty__c();
        a.NE__PropId__c = b.Id;
        a.NE__FamilyId__c = f.Id;
        insert a;
        
        NE__AssetItemAttribute__c ais = new NE__AssetItemAttribute__c();
        ais.Name = 'Referencia';
        ais.NE__Value__c = 'Propano';
        ais.NE__FamPropId__c = a.Id;
        ais.NE__Asset__c = asst.Id;
        insert ais;
		
        XC_UTIL_WOCreateSalesOrder.createSalesOrderFromConfig(order.Id); 
        Test.stopTest();
    }

    @isTest
    static void cancelSalesOrder(){ 
        String query = XC_UTIL_SObject.selectAllFieldsGetSelect('WorkOrder') + ' FROM WorkOrder LIMIT 1';
        List<WorkOrder> listWo = Database.query(query);
        Test.startTest();  
        XC_UTIL_WOCreateSalesOrder.cancelSalesOrder(listWo[0]); 
        Test.stopTest();
    }
}