/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  16/05/2019 
* @description XC_TR_Asset_U_PopulateOriginalOrder_TEST – Test class for XC_TR_Asset_U_PopulateOriginalOrder
*/ 
@isTest
private class XC_TR_Asset_U_PopulateOriginalOrder_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
    
    static testMethod void onUpdate() {
        Integer n = 5;
        List<Asset> assetListFirst  = XC_DF_Asset.createAssets(n);
        insert assetListFirst;
        List<Asset> assetList  = XC_DF_Asset.createAssets(n);
        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(n);
        insert orderItems;
        for(Asset ast : assetList){
            ast.XC_Configuration_Item__c = orderItems[0].Id;
        }
        insert assetList;
        System.assertEquals(n, assetList.size());
    }
}