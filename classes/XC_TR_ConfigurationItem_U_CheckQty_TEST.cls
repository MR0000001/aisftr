/**
* @author Francesco Imperioli fimperioli@deloitte.it
* @date Creation  24/06/2019 
* @description XC_TR_ConfigurationItem_U_CheckQty_TEST – Test class for XC_TR_ConfigurationItem_U_CheckQty_TEST
*/

@isTest
private class XC_TR_ConfigurationItem_U_CheckQty_TEST {

	@TestSetup
	public static void setup(){
		NE__Order__c order = XC_DF_Order.createOrder('InOrder');

	}
	
	@isTest static void splitConfigurationItem() {
		NE__OrderItem__c item = [SELECT ID,NE__Qty__c FROM NE__OrderItem__c LIMIT 1];
		item.NE__Qty__c=2;
		update item;
		XC_TR_ConfigurationItem_U_CheckQuantity check = new XC_TR_ConfigurationItem_U_CheckQuantity();

		Test.startTest();
			check.splitConfigurationItem(item);
		Test.stopTest();

	}

	
}