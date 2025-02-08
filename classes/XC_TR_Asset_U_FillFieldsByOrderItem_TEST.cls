/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 21/05/2019 
* @description XC_TR_Asset_U_FillFieldsByOrderItem_TEST – Test class 
*/
@isTest
private class XC_TR_Asset_U_FillFieldsByOrderItem_TEST {
	static testMethod void populateWBEFields() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
           
 		List<NE__OrderItem__c> orderItem = XC_DF_OrderItem.createOrderItems(1);
        insert orderItem;
        List<Asset> assetList = XC_DF_Asset.createAssets(100);
        	for(Asset a : assetList){
           		 a.XC_Configuration_Item__c =orderItem[0].id;
            }
        insert assetList;
        List<Asset> assetListInsert = [SELECT Id FROM Asset];
        System.assertEquals(100, assetListInsert.size());
        Test.stopTest();
    }
}