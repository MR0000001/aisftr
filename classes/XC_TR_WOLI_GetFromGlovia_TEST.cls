@isTest
public class XC_TR_WOLI_GetFromGlovia_TEST {

    static testMethod void test(){
		List<Account> acc = XC_DF_Account.insertPartnerAccounts(1);
		NE__Order__c o = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];
    
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status = 'Approved';
        woli.XC_WarehouseId__c = '10';
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
        
        
        new Map<String,String>();
        XC_TR_WorkOrderLineItem_GetFromGlovia.getWarehouseList(new List<String>{woli.Id}, new Map<String,String>());
        XC_TR_WorkOrderLineItem_GetFromGlovia.setWarehouseCode(new List<String>{woli.Id});
                
    }
}