/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 03/05/2019
* @description XC_TR_Asset_U_FillFieldsByOrderItem – Util class for Asset to fill fields by OrderItem
*/ 

public without sharing class XC_TR_Asset_U_FillFieldsByOrderItem {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Asset_U_FillFieldsByOrderItem');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @description Populate WBE field from ConfigurationItem
    * @param listAsset - List<Asset>
    */
    public static void populateWBEFields(List<Asset> listAsset) {
        List<Id> listOrderItemId = XC_UTIL_Sobject.getListFieldValues(listAsset, 'XC_Configuration_Item__c');
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()) {
            return;
        }
        Map<Id, NE__OrderItem__c> mapAssetWithConf = new Map<Id, NE__OrderItem__c>([
            SELECT Id, XC_WBE__c, XC_CMProfitCenter__c, XC_CMCostCenter__c
            FROM NE__OrderItem__c 
            WHERE Id IN :listOrderItemId]); 
        
        for(Asset asset : listAsset) {
            if(mapAssetWithConf.containsKey(asset.XC_Configuration_Item__c)) { 
                asset.XC_WBE__c = mapAssetWithConf.get(asset.XC_Configuration_Item__c).XC_WBE__c;
                asset.XC_CMProfitCenter__c = mapAssetWithConf.get(asset.XC_Configuration_Item__c).XC_CMProfitCenter__c;
                asset.XC_CMCostCenter__c = mapAssetWithConf.get(asset.XC_Configuration_Item__c).XC_CMCostCenter__c;
            }
        }
    }

}