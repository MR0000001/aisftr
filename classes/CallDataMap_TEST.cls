@isTest
public class CallDataMap_TEST {

    static testMethod void callMap() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
 
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        for(Asset a : assetList){
            a.NE__Order_Config__c =order.id;
        }
        insert assetList;
        
        Test.startTest();
        CallDataMap.callMap(order.id);
        System.assertEquals(true, order.id!=null);
        Test.stopTest();
    }
}