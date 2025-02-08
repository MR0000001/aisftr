@IsTest
public class XC_UTIL_WOLICreateMatTranRep_TEST {
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
        
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test1'
        );
        insert p2;
        
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT id,gii__ProductReference__c
            FROM gii__Product2Add__c
            LIMIT 1]);
        

             
        XC_ProductConsumed__c prodCo=new XC_ProductConsumed__c();
        prodCo.XC_WorkOrder__c  = wo.Id;
        prodCo.XC_WorkOrderLineItem__c=woli.Id;
        prodCo.XC_Product2Id__c =pAdd[0].gii__ProductReference__c;
        prodCo.XC_QuantityConsumed__c=1;
        prodCo.XC_WBE__c = '1234567';
        prodCo.XC_CostCenter__c = '1234567';
        prodCo.XC_CategoryPosition__c = '9';
        prodCo.XC_AccountAssignmentCategory__c = 'P';
        prodCo.XC_RepairCost__c=5;
        prodCo.XC_TransportCost__c=5;
        prodCo.CurrencyIsoCode='EUR';
        
        //prodCo.XC_Product2Id__r.ProductCode ='00000002';   
            
        insert prodCo;
    }
 static testMethod void test1(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(itemList[0].Id);
        XC_UTIL_WOLICreateMatTranRep.createMTR(lstWOLI);
        
    }   
    
    static testMethod void test2(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(itemList[0].Id);        
        try{
            XC_UTIL_WOLICreateMatTranRep.createMaterialTranRep(lstWOLI);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    static testMethod void test3(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        List<WorkOrderLineItem> lstWOLI = (List<WorkOrderLineItem>) XC_UTIL_Sobject.selectAllFields(itemList[0].Id);   
        List<XC_ProductConsumed__c> pclist = [SELECT id from XC_ProductConsumed__c];
        for(XC_ProductConsumed__c pc : pclist){
            pc.XC_WorkOrderLineItem__c = null;
        }
        update pclist;
        try{
            XC_UTIL_WOLICreateMatTranRep.createMaterialTranRep(lstWOLI);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}