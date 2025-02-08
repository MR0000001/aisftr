@isTest
public class XC_LCC201_SendPRToGlovia_Controller_TEST {
	@TestSetup
    static void setup(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        
        List<Account> acc = XC_DF_Account.insertPartnerAccounts(1);
		NE__Order__c o = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];
    
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status = 'Approved';
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
        
        ProductRequired pr = new ProductRequired();
        pr.ParentRecordId=woli.id;
        pr.Product2Id=p2.Id;
        insert pr;
        
        XC_ProductConsumed__c prodCo=new XC_ProductConsumed__c();
        prodCo.XC_WorkOrder__c  = wo.Id;
        prodCo.XC_WorkOrderLineItem__c=woli.Id;
        prodCo.XC_Product2Id__c =p2.Id;
        prodCo.XC_QuantityConsumed__c=1;
        prodCo.XC_WBE__c = '1234567';
        prodCo.XC_CostCenter__c = '1234567';
        prodCo.XC_ProductRequired__c = pr.id;
        prodCo.XC_CategoryPosition__c = '9';
        prodCo.XC_AccountAssignmentCategory__c = 'P';
        insert prodCo;
    }
    
    static testMethod void test11(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        XC_LCC201_SendPRToGlovia_Controller.getAllProductRequired((String)itemList[0].Id);  
    }
    
    static testMethod void test1(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        itemList[0].Status = 'Approved';
        update itemList;
        XC_LCC201_SendPRToGlovia_Controller.getAllProductRequired((String)itemList[0].Id);
       
    }
    

    static testMethod void test12(){
        List<WorkOrderLineItem> itemList = [SELECT id,WorkOrder.id from WorkOrderLineItem];
       	itemList[0].Status = 'Completed';
        update itemList[0];
        XC_LCC201_SendPRToGlovia_Controller.getAllProductRequired((String)itemList[0].Id);  
    }
    
    static testMethod void test2(){
        Boolean err = false;
        XC_LCC201_SendPRToGlovia_Controller.chechMandatoryField('', 'XXX',err);
        
    }
    
    static testMethod void test3(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        XC_LCC201_SendPRToGlovia_Controller.checkAddPr(itemList[0].Id);        
    }
     static testMethod void test4(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        XC_LCC201_SendPRToGlovia_Controller.getCommercialItemList(itemList[0].Id);        
    }
     static testMethod void test5(){
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c limit 1];
        XC_LCC201_SendPRToGlovia_Controller.getParamToGlovia(itemList[0].Id);        
    }
    
    static testMethod void test6(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        itemList[0].XC_WOLIType__c = 'Material supply';
        itemList[0].Status = 'Completed';
        update itemList[0];
        XC_LCC201_SendPRToGlovia_Controller.getAllProductRequired((String)itemList[0].Id);
    }

    static testMethod void test61(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        List<RecordType> deliveryRT = [SELECT id, developername from RecordType WHERE SobjectType = 'workorderlineitem' ANd  (name like '%delivery%' or  name like '%ita%')];
        itemList[0].XC_WOLIType__c = 'Delivery';
        itemList[0].XC_StatusReason__c = 'Delivery Processed';
        itemList[0].RecordTypeId = deliveryRT[0].id;
        update itemList[0];
        XC_LCC201_SendPRToGlovia_Controller.getAllProductRequired((String)itemList[0].Id);
    }

    static testMethod void test7(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        itemList[0].XC_WarehouseId__c = null;
        itemList[0].XC_IsaDelivery__c = false;
        update itemList;
        List<WorkOrder> woList = [SELECT id from WorkOrder];
        woList[0].XC_Country__c = 'Italy';
        update woList;
        XC_LCC201_SendPRToGlovia_Controller.getAllProductRequired((String)itemList[0].Id);
    }

    static testMethod void test8(){
        String erroMsg = '((ProductErrorWrapper:[prodCode=345678, prodId=a7G0D0000008neWUAQ, warehouseIds=a9N9E0000000XbcUAE, warehouseQuantity=121], ProductErrorWrapper:[prodCode=76543, prodId=a7G0D0000008nebUAA, warehouseIds=a9N9E0000000XbcUAE, warehouseQuantity=0]))';
        XC_LCC201_SendPRToGlovia_Controller.convertMessage(erroMsg);
    }

}