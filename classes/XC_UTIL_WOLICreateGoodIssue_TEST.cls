/**
* @author dpalamides
* @date 14/10/2020
* @description: classes.XC_UTIL_WOLICreateRMA_TEST
*/

@IsTest
public class XC_UTIL_WOLICreateGoodIssue_TEST {
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
        wo.XC_AssignedPartner__c = acc[0].Id;
        insert wo;
        
                      
        WorkOrderLineItem woli2 = new WorkOrderLineItem();
        woli2.Status='New';
        woli2.WorkOrderId = wo.Id;       
        woli2.XC_AccountId__c = acc[0].Id;
        woli2.XC_WOLIType__c = 'Material Supply';
        woli2.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_MR_WOLI').getRecordTypeId();
        insert woli2;
        
        woli.WorkOrderId = wo.Id;
        woli.XC_MaterialRequest__c = woli2.Id;
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
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem where XC_MaterialRequest__c != null];
        List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(itemList[0].Id);
        XC_UTIL_WOLICreateGoodIssue.createGoodIssueFromSalesOrder(lstWOLI);
        
    }
    
    static testMethod void test2(){
        List<Product2> itemList = [SELECT id from Product2];
        XC_UTIL_WOLICreateGoodIssue.getGloviaProduct(new List<String>{String.valueOf(itemList[0].Id)});
        
    }
    
    static testMethod void test3(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem where XC_MaterialRequest__c != null];
        List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(itemList[0].Id);
        
        
        lstWOLI[0].Status = Label.XC_CL_Cancelled;
        update lstWOLI;
        
        XC_UTIL_WOLICreateGoodIssue.createGoodIssueFromSalesOrder(lstWOLI);
        
    }
    
    
}