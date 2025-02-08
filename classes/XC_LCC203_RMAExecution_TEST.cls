@isTest
public class XC_LCC203_RMAExecution_TEST {
	@TestSetup
    static void setup(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        
        List<Account> acc = XC_DF_Account.insertPartnerAccounts(1);
		NE__Order__c o = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];
    
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        WorkOrder wo = new WorkOrder();
        wo.XC_Configuration__c= o.Id;
        wo.XC_Configuration_Item__c = itemList[0].Id;
        wo.XC_PreferredPArtner__c = acc[0].Id;
        wo.State = 'Italy';
        insert wo;
        woli.WorkOrderId = wo.Id;
        //woli.AccountId = acc[0].Id;
        woli.XC_AccountId__c = acc[0].Id;
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
        
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test'
        );
        insert p2;
        
        XC_ProductConsumed__c prodCo=new XC_ProductConsumed__c();
        prodCo.XC_WorkOrder__c  = wo.Id;
        prodCo.XC_WorkOrderLineItem__c=woli.Id;
        prodCo.XC_Product2Id__c =p2.Id;
        prodCo.XC_QuantityConsumed__c=1;
        prodCo.XC_WBE__c = '1234567';
        prodCo.XC_CostCenter__c = '1234567';
        prodCo.XC_CategoryPosition__c = '9';
        prodCo.XC_AccountAssignmentCategory__c = 'P';
        insert prodCo;
    }
    
    static testMethod void test1(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        XC_LCC203_RMAExecution.createRMA(itemList[0].Id);
       
    }
    
    static testMethod void test2(){
        Boolean err = false;
        XC_LCC203_RMAExecution.chechMandatoryField('', 'XXX',err);
        
    }
    
    static testMethod void test3(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        XC_LCC203_RMAExecution.checkAddPr(itemList[0].Id);        
    }
      static testMethod void test4(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        XC_LCC203_RMAExecution.getCommercialItemList(itemList[0].Id);        
    }
     static testMethod void test5(){
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c limit 1];
        XC_LCC203_RMAExecution.getParamToGlovia(itemList[0].Id);        
    }
    
}