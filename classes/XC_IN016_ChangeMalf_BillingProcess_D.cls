/**
 * @author              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation       08/01/2020
 * @date Modification   dd/mm/yyyy
 * @description         XC_IN016_ChangeMalf_BillingProcess_D – DAO for XC_IN016_ChangeMalf_BillingProcess
 */


public without sharing class XC_IN016_ChangeMalf_BillingProcess_D {
    
    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN016_ChangeMalf_BillingProcess_D');

    /* 
     * @author Federico Amici - federico.amici@nttdata.com
     * @description getItemsByOrderId
     * @param orderId the order id
     * @param orderItemId the order item id
     * @return the items by order id
    */
    public static Map<Id, NE__OrderItem__c> getItemsByOrderId(String orderId, String orderItemId) {

        if(!Schema.sObjectType.NE__Order__c.isAccessible() && !Schema.SObjectType.NE__OrderItem__c.isAccessible()){
            return new Map<Id,NE__OrderItem__c>();
        }

        Map<ID,NE__Order__c> ordMap = new Map<Id,NE__Order__c>([SELECT Id, (SELECT Id, Name, NE__Action__c, XC_Max_Months_Renting__c, NE__Qty__c, 
                                                        NE__RecurringChargeOv__c, NE__OneTimeFeeOv__c, XC_Duration__c, NE__CatalogItem__r.XC_AutoRenewal__c, 
                                                        NE__CatalogItem__r.CurrencyIsoCode, NE__BaseOneTimeFee__c, NE__BaseRecurringCharge__c, 
                                                        NE__OrderId__r.NE__Type__c, NE__OrderId__r.XC_Subtype__c
                                                        FROM NE__Order_Items__r 
                                                        WHERE (NE__Action__c  = 'Remove' OR 
                                                        NE__Action__c = 'Add' OR NE__Action__c = 'None') AND 
                                                        NE__ProdName__c != :Label.XC_CL_Asset_Penalty)
                                        FROM NE__Order__c
                                        WHERE Id = :orderId]);

        NE__Order__c ord = new NE__Order__c();
        ord = ordMap.values();
                        
        List<NE__OrderItem__c> listItem = ord.NE__Order_Items__r;
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>();

        for(NE__OrderItem__c item : listItem) {
            mapItem.put(item.Id, item);
        }

        return mapItem;
    }


    /**
    * @author Federico Amici - federico.amici@nttdata.com
    * @description get Items By Ids
    * @param listItemIds the list item ids
    * @param orderId the order id
    * @return wrapperAssetItems
    */
    public static XC_IN015_UpdateRenting_D.WrapperAssetItems getItemsByIds(List<Id> listItemIds, String orderId) {

        if(!Schema.sObjectType.Asset.isAccessible() && !Schema.sObjectType.NE__Order__c.isAccessible()){
            return null;
        }
        Map<Id,Asset> listAssetMap = new Map<Id,Asset>([SELECT Id, XC_Original_Creation_OrderItem__c, XC_Configuration_Item__c, XC_Original_Configuration_Item__c, XC_SubscriptionName__c
                                FROM Asset
                                WHERE XC_Configuration_Item__c IN :listItemIds]);
        List<Asset> listAsset = listAssetMap.values();

        Set<Id> setOldItemIds = new Set<Id>();
        Set<Id> setNewItemIds = new Set<Id>();
        for(Asset a : listAsset) {
            setOldItemIds.add(a.XC_Original_Configuration_Item__c);
            setNewItemIds.add(a.XC_Configuration_Item__c);
        }
        String zQuoteId;

        if(!Schema.SObjectType.NE__OrderItem__c.isAccessible()) {
            return new XC_IN015_UpdateRenting_D.WrapperAssetItems();
        }

        Map<Id, NE__OrderItem__c> mapItems = new Map<Id, NE__OrderItem__c>([SELECT Id, Name, NE__Action__c, XC_ZQuoteId__c, NE__OrderId__c, NE__CatalogItem__r.XC_AutoRenewal__c,
                                                                                NE__Activation_Date__c, XC_Max_Months_Renting__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c,
                                                                                NE__Qty__c, NE__RecurringChargeOv__c, NE__OneTimeFeeOv__c, NE__BaseOneTimeFee__c, NE__BaseRecurringCharge__c,
                                                                                NE__OrderId__r.XC_Subtype__c, NE__OrderId__r.NE__Type__c, NE__CatalogItem__r.XC_Mixed_VAT__c, NE__OrderId__r.NE__AccountId__r.XC_RecordTypeDeveloperName__c
                                                                                FROM NE__OrderItem__c
                                                                                WHERE Id IN :setOldItemIds OR Id IN : setNewItemIds]);
                                                                                

        Map<Id, NE__OrderItem__c> mapNewItems = new  Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapOldItems = new  Map<Id, NE__OrderItem__c>();

        for(NE__OrderItem__c item : mapItems.values()) {

            if(setOldItemIds.contains(item.id)){
                mapOldItems.put(item.Id, item);
            } 
            if(setNewItemIds.contains(item.Id) ){
                mapNewItems.put(item.Id, item);
            }
            
        }


        // check mixedVAT
        Boolean mixedVat = false; 
        for(NE__OrderItem__c item : mapNewItems.values()) {
            if((item.NE__Action__c != 'Remove') && item.NE__CatalogItem__r.XC_Mixed_VAT__c && item.NE__OrderId__r.NE__AccountId__r.XC_RecordTypeDeveloperName__c.containsIgnoreCase('Residential')) {
                mixedVat = true; 
            }
        }

    
        XC_IN015_UpdateRenting_D.WrapperAssetItems wr = new XC_IN015_UpdateRenting_D.WrapperAssetItems();
        wr.listAsset = listAsset;
        wr.mapOldItems = mapOldItems;
        wr.mapNewItems = mapNewItems;
        for(NE__OrderItem__c item : mapOldItems.values()) {
            if(String.isNotBlank(item.XC_ZQuoteId__c)) {
                zQuoteId = item.XC_ZQuoteId__c;
                break;
            }
        }
        wr.zQuoteId = zQuoteId;
        wr.mixedVat = mixedVat; 
        
        return wr;
    }
    

}