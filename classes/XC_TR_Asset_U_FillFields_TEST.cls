/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation 21/05/2019 
* @description XC_TR_Asset_U_FillFields_TEST – Test class 
*/
@isTest
private  class XC_TR_Asset_U_FillFields_TEST {
    static testMethod void populateFields() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
 
        List<Asset> assetList = XC_DF_Asset.createAssets(100);
        	for(Asset a : assetList){
           		 a.NE__Order_Config__c =order.id;
            }
        insert assetList;
        List<Asset> assetListInsert = [SELECT Id FROM Asset];
        System.assertEquals(100, assetListInsert.size());
        Test.stopTest();
    }
    
    static testMethod void populateFields2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
 
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        	for(Asset a : assetList){
           		 a.NE__Order_Config__c = null;
            }
        insert assetList;
        List<Asset> assetListInsert = [SELECT Id FROM Asset];
        assetListInsert[0].XC_SubscriptionId__c = '111';
        update assetListInsert;
        System.assertEquals(1, assetListInsert.size());
        Test.stopTest();
    }
}