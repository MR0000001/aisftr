/**
 * @author      : Federico Amici - federico.amici@nttdata.com
 * @date        : 18/03/2019
 * @description : DAO for XC_IN015_UpdateRenting
 */
public without sharing class XC_IN015_UpdateRenting_D {

        /**
         * @description  Wrapper Maps
         */
        private class WrapperMaps{
                Map<Id, NE__OrderItem__c> mapOldItems = new Map<Id, NE__OrderItem__c>();
                Map<Id, NE__OrderItem__c> mapNewItems = new Map<Id, NE__OrderItem__c>();
                Set<Id> setOldItemIds; 
                Set<Id> setNewItemIds;
                NE__OrderItem__c item;
        }

        /**
         * @author      : Federico Amici - federico.amici@nttdata.com
         * @date        : 18/03/2019
         * @description : WrapperAssetItem
         */
        public class WrapperAssetItems {
                public List<Asset> listAsset;
                public Map<Id, NE__OrderItem__c> mapOldItems;
                public Map<Id, NE__OrderItem__c> mapNewItems;
                public String orderId;
                public String zQuoteId;
                public String confItemId;
                public String penaltyId;
                public Boolean mixedVat; 
        }

        /**
         * @description getItemsByOrderId
         * @author Federico Amici - federico.amici@nttdata.com
	 * @param orderId the order id
	 * @param orderItemId the order item id
	 * @return the items by order id
	 */
        public static Map<Id, NE__OrderItem__c> getItemsByOrderId(String orderId, String orderItemId) {
                if(!Schema.sObjectType.NE__Order__c.isAccessible() && !Schema.SObjectType.NE__OrderItem__c.isAccessible()){
                        return new Map<Id,NE__OrderItem__c>();
                }

                Map<ID,NE__Order__c> ordMap = new Map<Id,NE__Order__c>([SELECT Id, (SELECT Id, Name, NE__Action__c,
                                                                XC_Max_Months_Renting__c, NE__Qty__c, 
                                                                NE__RecurringChargeOv__c
                                                                FROM NE__Order_Items__r 
                                                                WHERE ID = :orderItemId OR
                                                                Name = :Label.XC_CL_Asset_Penalty)
                                                FROM NE__Order__c
                                                WHERE Id = :orderId
                                                LIMIT 1]);

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
        public static WrapperAssetItems getItemsByIds(List<Id> listItemIds, String orderId) {
                if(!Schema.sObjectType.Asset.isAccessible() && !Schema.sObjectType.NE__Order__c.isAccessible()){
                        return null;
                }
                Map<Id,Asset> listAssetMap = new Map<Id,Asset>([SELECT Id, XC_Original_Creation_OrderItem__c, XC_Configuration_Item__c
                                        FROM Asset
                                        WHERE XC_Configuration_Item__c IN :listItemIds]);
                List<Asset> listAsset = listAssetMap.values();



                Set<Id> setOldItemIds = new Set<Id>();
                Set<Id> setNewItemIds = new Set<Id>();
                for(Asset a : listAsset) {
                    setOldItemIds.add(a.XC_Original_Creation_OrderItem__c);
                    setNewItemIds.add(a.XC_Configuration_Item__c);
                }
                String zQuoteId;

                if(!Schema.SObjectType.NE__OrderItem__c.isAccessible()) {
                    return new WrapperAssetItems();
                }

                Map<Id,NE__Order__c> ordMap = new Map<Id,NE__Order__c>([SELECT Id, (SELECT Id, Name, NE__Action__c, XC_ZQuoteId__c, NE__OrderId__c, NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c,
                                                NE__Activation_Date__c, XC_Max_Months_Renting__c,
                                                NE__Qty__c, NE__RecurringChargeOv__c
                                                FROM NE__Order_Items__r
                                                WHERE Id IN :setOldItemIds OR
                                                        Id IN :setNewItemIds OR
                                                        Name = 'Penalty')
                                    FROM NE__Order__c
                                    WHERE Id = :orderId]);
                

                NE__Order__c ord = new NE__Order__c();
                ord = ordMap.values();

                Map<Id, NE__OrderItem__c> mapOldItems = new Map<Id, NE__OrderItem__c>();
                Map<Id, NE__OrderItem__c> mapNewItems = new Map<Id, NE__OrderItem__c>();
                WrapperAssetItems wr = new WrapperAssetItems();
                List<NE__OrderItem__c> listItems = ord.NE__Order_Items__r;

             	WrapperMaps wrMaps = new WrapperMaps();
                wrMaps.setNewItemIds = setNewItemIds;
                wrMaps.setOldItemIds = setOldItemIds;
            
                for(NE__OrderItem__c item : listItems) {
                        wrMaps.item = item;// = populateMapOldAndNew(item,setNewItemIds,setOldItemIds);
                    	populateMapOldAndNew(wrMaps);
                        //mapOldItems = wrMaps.mapOldItems;
                        //mapNewItems = wrMaps.mapNewItems;
                        if(item.Name == 'Penalty') {
                                mapNewItems.put(item.Id, item); 
                                wr.penaltyId = item.Id;
                        }
                }

                wr.listAsset = listAsset;
                wr.mapOldItems = wrMaps.mapOldItems;
                wr.mapNewItems = wrMaps.mapNewItems;
                for(NE__OrderItem__c item : wrMaps.mapOldItems.values()) {
                    if(String.isNotBlank(item.XC_ZQuoteId__c)) {
                        zQuoteId = item.XC_ZQuoteId__c;
                        break;
                    }
                }
                wr.zQuoteId = zQuoteId;
                
                return wr;
	}

        /*private static WrapperMaps populateMapOldAndNew(NE__OrderItem__c item, Set<Id> setNewItemIds, Set<Id> setOldItemIds){
                WrapperMaps wrMaps = new WrapperMaps();
                Map<Id, NE__OrderItem__c> mapOldItems = new Map<Id, NE__OrderItem__c>();
                Map<Id, NE__OrderItem__c> mapNewItems = new Map<Id, NE__OrderItem__c>();
                if(setOldItemIds.contains(item.Id)) {
                        mapOldItems.put(item.Id, item);
                } else if(setNewItemIds.contains(item.Id)) {
                        mapNewItems.put(item.Id, item);
                }
                wrMaps.mapOldItems = mapOldItems;
                wrMaps.mapNewItems = mapNewItems;

                return wrMaps;
        }*/
    
    private static void populateMapOldAndNew(WrapperMaps wrapperMaps){

                if(wrapperMaps.setOldItemIds.contains(wrapperMaps.item.Id)) {
                        wrapperMaps.mapOldItems.put(wrapperMaps.item.Id, wrapperMaps.item);
                } else if(wrapperMaps.setNewItemIds.contains(wrapperMaps.item.Id)) {
                        wrapperMaps.mapNewItems.put(wrapperMaps.item.Id, wrapperMaps.item);
                }
              
        }

}