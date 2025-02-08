/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 08/03/2019
 * @date Modification dd/mm/yyyy
 * @description  DAO for the  XC_IN011_ChangeProvBillingProcess class
 */ 
public without sharing class XC_IN011_ChangeProvBillingProcess_D {

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description The Class WrapperAssetItems.
     */
    public class WrapperAssetItems {
        
        /** The list asset. */
        public List<Asset> listAsset;
        
        /** The map old items. */
        public Map<Id, NE__OrderItem__c> mapOldItems;
        
        /** The map new items. */
        public Map<Id, NE__OrderItem__c> mapNewItems;
        
        /** The z quote id. */
        public String zQuoteId;
        
        /** The conf item id. */
        public String confItemId;
        
        /** The order id. */
        public String orderId;

        /** The  mixedVat. */
        public Boolean mixedVat; 
    }

	/** 
     * @author Federico Amici - federico.amici@nttdata.com 
	 * @param listStepIds the list step ids
	 * @return Map<Id, XC_Provisioning_Step__c> the map steps
     * @description getMapSteps Gets the map steps  
	 */
	public static Map<Id, XC_Provisioning_Step__c> getMapSteps(List<Id> listStepIds) {
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            return new Map<Id, XC_Provisioning_Step__c>();
        }
		Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT ID, XC_Status__c, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c,
                    XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c, XC_Template_Name__c,
                    XC_Configuration_Item__r.NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, XC_LastInvoiceDate__c 
                 FROM XC_Provisioning_Step__c 
                 WHERE Id IN: listStepIds]);
		return mapSteps;
	}

	/**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Gets the items by order id.
	 * @param orderId the list step ids
	 * @return the items by order id
	 */
	public static List<NE__OrderItem__c> getItemsByOrderId(String orderId) {
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return new List<NE__OrderItem__c>();
        }
        List<NE__OrderItem__c> configItemList =  [SELECT Id, Name, NE__Action__c, NE__CatalogItem__r.XC_AutoRenewal__c, NE__OrderId__r.XC_Segment__c
                                                    FROM NE__OrderItem__c 
                                                    WHERE (NE__Action__c  = 'Remove' OR 
                                                           NE__Action__c = 'Add' OR NE__Action__c = 'None')
                                                    AND NE__OrderId__c =: orderId
                                                    AND NE__ProdName__c != 'Penalty'];
		return configItemList;
	}

    
      /**
	 * @author Federico Amici - federico.amici@nttdata.com
	 * @description Gets the items by order id.
	 * @param orderId the list step ids
	 * @return the items by order id
	 */
    public static List<NE__OrderItem__c> getItemsByOrderIdB2B(String orderId) {
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return new List<NE__OrderItem__c>();
        }
        List<NE__OrderItem__c> configItemList =  [SELECT Id, Name, NE__Action__c, NE__CatalogItem__r.XC_AutoRenewal__c
        FROM NE__OrderItem__c
        WHERE (NE__Action__c  = 'Remove' OR
        NE__Action__c = 'Add' OR NE__Action__c = 'None' OR NE__Action__c = 'Change')
        AND NE__OrderId__c =: orderId
        AND NE__ProdName__c != 'Penalty'];
        return configItemList;
    }
   

    /**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Gets the junction rate plan to item.
	 * @param listItemIds the list item ids
	 * @return the junction rate plan to item
	 */
	public static List<B2WExtCat__Work_Order_Item__c> getJunctionRatePlanToItem(List<Id> listItemIds) {
        if(!Schema.sObjectType.B2WExtCat__Work_Order_Item__c.isAccessible()){
            return new List<B2WExtCat__Work_Order_Item__c>();
        }
        List<B2WExtCat__Work_Order_Item__c> b2wList = [  SELECT Id , B2WExtCat__Work_Order_Item_Name__c, B2WExtCat__Configuration_Item__c,
                                                                        B2WExtCat__Work_Order_Item_Code__c, B2WExtCat__Configuration_Item__r.NE__Action__c
                                                                    FROM B2WExtCat__Work_Order_Item__c
                                                                    WHERE B2WExtCat__Configuration_Item__c IN : listItemIds];
        
		return b2wList;
	}

	/**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Gets the junction rate plan to item.
	 * @param listItemIds the list item ids
	 * @return the junction rate plan to item
	 */
	public static List<B2WExtCat__Work_Order_Item__c> getJunctionRatePlanToItem(List<Id> listItemIds, Map<String, List<String>> prpcConfItemsMap) {
        if(!Schema.sObjectType.B2WExtCat__Work_Order_Item__c.isAccessible()){
            return new List<B2WExtCat__Work_Order_Item__c>();
        }
        List<B2WExtCat__Work_Order_Item__c> b2wList = [  SELECT Id , B2WExtCat__Work_Order_Item_Name__c, B2WExtCat__Configuration_Item__c,
                                                                        B2WExtCat__Work_Order_Item_Code__c, B2WExtCat__Configuration_Item__r.NE__Action__c
                                                                    FROM B2WExtCat__Work_Order_Item__c
                                                                    WHERE B2WExtCat__Configuration_Item__c IN : listItemIds];
        
        List<String> listRatePlan = XC_UTIL_SObject.getListFieldValues(b2wList, 'B2WExtCat__Work_Order_Item_Code__c');
        Map<Id, zqu__ProductRatePlanCharge__c> prodRatePlanChargeMap = new Map<Id, zqu__ProductRatePlanCharge__c>([SELECT Id, zqu__ProductRatePlan__c
                                                                                                                    FROM zqu__ProductRatePlanCharge__c
                                                                                                                    WHERE zqu__ProductRatePlan__c IN :listRatePlan]);       
        for(zqu__ProductRatePlanCharge__c prpc : prodRatePlanChargeMap.values()) {
            prpcConfItemsMap.put(prpc.Id, new List<String>());
            for(B2WExtCat__Work_Order_Item__c wo : b2wList){
                if(wo.B2WExtCat__Work_Order_Item_Code__c == prpc.zqu__ProductRatePlan__c && wo.B2WExtCat__Configuration_Item__r.NE__Action__c == 'Add') {
                    prpcConfItemsMap.get(prpc.Id).add(wo.B2WExtCat__Configuration_Item__c);
                }
            }
        }

		return b2wList;
	}

	/**
     * @author Federico Amici - federico.amici@nttdata.com
     * @description Gets the items by old ids.
	 * @param listItemIds the list item ids
	 * @return the items by old ids
	 */
	public static WrapperAssetItems getItemsByOldIds(List<Id> listItemIds) {
        if(!Schema.sObjectType.Asset.isAccessible() && !Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return null;
        }
        List<Asset> listAsset = [SELECT Id, XC_Original_Configuration_Item__c,XC_Original_Creation_OrderItem__c, XC_Configuration_Item__c, XC_SubscriptionName__c	
                                FROM Asset
                                WHERE XC_Configuration_Item__c IN :listItemIds];

        Set<Id> setOldItemIds = new Set<Id>();
        Set<Id> setNewItemIds = new Set<Id>();
        for(Asset a : listAsset) {
            setOldItemIds.add(a.XC_Original_Configuration_Item__c);
            setNewItemIds.add(a.XC_Configuration_Item__c);
        }
        String zQuoteId;

        Map<Id, NE__OrderItem__c> mapItems = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__Action__c, XC_ZQuoteId__c, NE__OrderId__c, NE__CatalogItem__r.XC_AutoRenewal__c,
                                                                                NE__Activation_Date__c, XC_Max_Months_Renting__c, NE__CatalogItem__r.XC_Mixed_VAT__c,
                                                                                NE__Qty__c, NE__RecurringChargeOv__c, NE__OrderId__r.XC_Subtype__c
                                                                                FROM NE__OrderItem__c
                                                                                WHERE Id IN :setOldItemIds OR Id IN : setNewItemIds]);

        /*Map<Id, NE__OrderItem__c> mapNewItems = new Map<Id, NE__OrderItem__c>([SELECT Id, NE__Action__c, NE__CatalogItem__r.XC_AutoRenewal__c,
                                                                               XC_ZQuoteId__c, NE__OrderId__c, NE__Activation_Date__c, XC_Max_Months_Renting__c,
                                                                               NE__Qty__c, NE__RecurringChargeOv__c
                                                                                FROM NE__OrderItem__c
                                                                                WHERE Id IN :setNewItemIds]);*/

        Map<Id, NE__OrderItem__c> mapNewItems = new  Map<Id, NE__OrderItem__c>();
        Map<Id, NE__OrderItem__c> mapOldItems = new  Map<Id, NE__OrderItem__c>();

        for(NE__OrderItem__c item : mapItems.values()) {
           
            if(setOldItemIds.contains(item.id)){
                mapOldItems.put(item.Id, item);
            } 
            if(setNewItemIds.contains(item.Id)){
                mapNewItems.put(item.Id, item);
            }
        }

        // check mixedVAT
        Boolean mixedVat = false; 
        for(NE__OrderItem__c item : mapNewItems.values()) {
            if((item.NE__Action__c != 'Remove') && item.NE__CatalogItem__r.XC_Mixed_VAT__c){
                mixedVat = true; 
            }
        }

        WrapperAssetItems wr = new WrapperAssetItems();
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