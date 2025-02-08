@isTest
public class XC_LCC216_SelectWarehouse_TEST {
@TestSetup
    static void setup(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        
        List<Account> acc = XC_DF_Account.insertPartnerAccounts(1);
		NE__Order__c o = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];
    
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status = 'Approved';
        WorkOrder wo = XC_DF_WorkOrder.createWorkOrders(1,'Repair')[0];
        wo.XC_Configuration__c= o.Id;
        wo.XC_Configuration_Item__c = itemList[0].Id;
        wo.XC_PreferredPArtner__c = acc[0].Id;
        wo.State = 'Italy';
        
        insert wo;
        woli.WorkOrderId = wo.Id;
        //woli.AccountId = acc[0].Id;
        woli.XC_AccountId__c = acc[0].Id;
        woli.XC_Form_Type__c = 'RMA';
        insert woli;
        
        
        gii__WarehouseGroup__c wareHouseG = new gii__WarehouseGroup__c(Name='Test-GloviaNetwork2');
        insert wareHouseG;
        gii__Warehouse__c wa = new gii__Warehouse__c(Name = 'Local Warehouse3',
                                      giic_WarehouseType__c='Local',
                                      giic_StorageCapacity__c=400000,
                                      gii__Account__c = acc[0].Id, 
                                      gii__WarehouseGroup__c = wareHouseG.Id,
                                      giic_WarehouseCode__c = 'CW3',
                                      giic_warehousecountryPick__c = 'Italy',
                                      giic_LegalEntity__c = 'EnelXItalia'               
                                      );
        insert wa;  

        XC_FormCase__c formCase = new XC_FormCase__c(
            XC_Legal_Entity__c = 'EnelXItalia',
            XC_Return_Material__c = woli.Id,
            RecordTypeId = Schema.SObjectType.XC_FormCase__c.getRecordTypeInfosByDeveloperName().get('RMA').getRecordTypeId()
        );
        insert formCase;

    }
    
    static testMethod void test1(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        Test.startTest();
        XC_LCC216_SelectWarehouse.getWarehouseList((String)itemList[0].Id, JSON.serialize(new Map<String,Object>()));
        Test.stopTest();
    }
    
    static testMethod void test2(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        XC_UTIL_FSLLogistic.WarehouseWrapper warehouseObj = new XC_UTIL_FSLLogistic.WarehouseWrapper();
        Test.startTest();
        XC_LCC216_SelectWarehouse.setWarehouse((String)itemList[0].Id, JSON.serialize(warehouseObj));
        Test.stopTest();
    }
}