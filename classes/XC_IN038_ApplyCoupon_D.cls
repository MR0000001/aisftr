/**
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       22/11/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         DAO class for  XC_IN038_ApplyCoupon
*/


public without sharing class XC_IN038_ApplyCoupon_D {


    /** 
	 * @param listStepIds the list step ids
	 * @return Map<Id, XC_Provisioning_Step__c> the map steps
     * @description getMapSteps Gets the map steps  
	 */
	public static Map<Id, XC_Provisioning_Step__c> getMapSteps(List<Id> listStepIds) {
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            return new Map<Id, XC_Provisioning_Step__c>();
        }
		Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT ID, XC_Status__c, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__Bundle_Configuration__c, XC_Configuration_Item__r.XC_Segment__c, XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c
                 FROM XC_Provisioning_Step__c 
                 WHERE Id IN: listStepIds]);
		return mapSteps;
	}


    /**
     * @description Gets the items by order id.
	 * @param orderId the list step ids
	 * @return the items by order id
	 */
	public static List<NE__OrderItem__c> getItemsByOrderId(String orderId) {
        if(!Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            return new List<NE__OrderItem__c>();
        }
        List<NE__OrderItem__c> configItemList =  [SELECT Id, Name, NE__Action__c, NE__CatalogItem__r.XC_AutoRenewal__c
                                                    FROM NE__OrderItem__c 
                                                    WHERE /*(NE__Action__c  = 'Remove' OR 
                                                    NE__Action__c = 'Add' OR NE__Action__c = 'Change')
                                                    AND*/ NE__OrderId__c =: orderId
                                                    AND NE__ProdName__c != 'Penalty'];
		return configItemList;
	}


    /**
     * @description Gets the junction rate plan to item.
	 * @param listItemIds the list item ids
	 * @return the junction rate plan to item
	 */
	public static List<B2WExtCat__Work_Order_Item__c> getJunctionRatePlanToItem(List<Id> listItemIds, Map<String, List<String>> prpcConfItemsMap) {
        if(!Schema.sObjectType.B2WExtCat__Work_Order_Item__c.isAccessible()){
            return new List<B2WExtCat__Work_Order_Item__c>();
        }
        List<B2WExtCat__Work_Order_Item__c> b2wList = [  SELECT Id , B2WExtCat__Work_Order_Item_Name__c, B2WExtCat__Configuration_Item__c,
                                                                        B2WExtCat__Work_Order_Item_Code__c, B2WExtCat__Configuration_Item__r.NE__Action__c,
                                                                        B2WExtCat__Action__c 
                                                                    FROM B2WExtCat__Work_Order_Item__c
                                                                    WHERE B2WExtCat__Configuration_Item__c IN : listItemIds];
        
        List<String> listRatePlan = XC_UTIL_SObject.getListFieldValues(b2wList, 'B2WExtCat__Work_Order_Item_Code__c');
        Map<Id, zqu__ProductRatePlanCharge__c> prodRatePlanChargeMap = new Map<Id, zqu__ProductRatePlanCharge__c>([SELECT Id, zqu__ProductRatePlan__c
                                                                                                                    FROM zqu__ProductRatePlanCharge__c
                                                                                                                    WHERE zqu__ProductRatePlan__c IN :listRatePlan]);       
        for(zqu__ProductRatePlanCharge__c prpc : prodRatePlanChargeMap.values()) {
            prpcConfItemsMap.put(prpc.Id, new List<String>());
            for(B2WExtCat__Work_Order_Item__c wo : b2wList){
                if(wo.B2WExtCat__Work_Order_Item_Code__c == prpc.zqu__ProductRatePlan__c) {
                    prpcConfItemsMap.get(prpc.Id).add(wo.B2WExtCat__Configuration_Item__c);
                }
            }
        }
		return b2wList;
	}


}