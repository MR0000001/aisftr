@isTest
public class XC_LCC213_MaterialTranRep_TEST {
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
            Name = 'Test'
        );
        insert p2;
        
		ProductRequired pr = new ProductRequired();
        pr.ParentRecordId= woli.id;
        pr.Product2Id= p2.id;
        pr.QuantityRequired=2;
        
        insert pr;
		
		XC_ProductConsumed__c prodCo=new XC_ProductConsumed__c();
        prodCo.XC_WorkOrder__c  = wo.Id;
        prodCo.XC_WorkOrderLineItem__c=woli.Id;
        prodCo.XC_Product2Id__c =p2.Id;
        prodCo.XC_QuantityConsumed__c=1;
        prodCo.XC_WBE__c = '1234567';
        prodCo.XC_CostCenter__c = '1234567';
        prodCo.XC_CategoryPosition__c = '9';
        prodCo.XC_AccountAssignmentCategory__c = 'P';
		prodCo.XC_UnitPrice__c = 5;
		prodCo.XC_Product2Id__C = p2.Id;
		prodCo.CurrencyIsoCode = 'EUR';
        insert prodCo;
    }
    
    	
	static testMethod void test1(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        XC_LCC213_MaterialTranRep.createMTR(itemList[0].Id);
       
    }
	
	 static testMethod void test2(){
        Boolean err = false;
        XC_LCC213_MaterialTranRep.chechMandatoryField('', 'XXX',err);
        
    }
	
	
	static testMethod void test3(){
        List<WorkOrderLineItem> itemList = [SELECT id from WorkOrderLineItem];
        XC_LCC213_MaterialTranRep.checkAddPr(itemList[0].Id);        
    }

}