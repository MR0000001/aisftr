/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_LCC_056_CalculateWBS_UU {
    /**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listItems - List<NE__OrderItem__c>
     * @return List<NE__OrderItem__c>
    **/
    public static List<NE__OrderItem__c> wbeTOCol(List<NE__OrderItem__c> listItems){
        Set<Id> wbeSet = new Set<Id>();
        List<NE__OrderItem__c> itemsToUpdate = new List<NE__OrderItem__c>();
        List<XC_CM_WBEChannelMapping__mdt> cmCodeChannel = new List<XC_CM_WBEChannelMapping__mdt>();
        if(Schema.sObjectType.XC_CM_WBEChannelMapping__mdt.isAccessible()){
            cmCodeChannel = [SELECT XC_ChannelCode__c,XC_ChannelName__c, XC_WBE__c, XC_Profit_Center__c, XC_Cost_Center__c  FROM XC_CM_WBEChannelMapping__mdt];
        }
        itemsToUpdate = checkChannel(listItems,cmCodeChannel);
        if(Schema.sObjectType.NE__OrderItem__c.isUpdateable() && !itemsToUpdate.isEmpty()) {
            Database.update(itemsToUpdate);
        }
        return itemsToUpdate;

    }
    /**
    * @author Donato Lombardi - dolombardi@deloitte.it
    * @description Method to retrieve a Map of Work Order -> List skills requested
    * @param listItems - List<NE__OrderItem__c>
    * @param cmCodeChannel - List<XC_CM_WBEChannelMapping__mdt>
    * @return Map<Id,String>
   **/

    private static List<NE__OrderItem__c> checkChannel(List<NE__OrderItem__c> listItems, List<XC_CM_WBEChannelMapping__mdt> cmCodeChannel){
        Map<Id,String>mapIdCICode = new Map<Id, String>();
        Set<Id> wbsSet = new Set<Id>();
        List<NE__OrderItem__c> itemsToupdate = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c ne : listItems){
            for(XC_CM_WBEChannelMapping__mdt cm :cmCodeChannel){
                if(ne.NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c == cm.XC_ChannelName__c && String.isNotBlank(cm.XC_WBE__c)){
                    System.debug('listItemsColWBE--> '+ ne);
                    System.debug('listItemsColWBE--> '+ cm);
                    ne.XC_Wbe__c= cm.XC_WBE__c;
                    ne.XC_CMProfitCenter__c= cm.XC_Profit_Center__c;
                    ne.XC_CMCostCenter__c= cm.XC_Cost_Center__c;
                    itemsToupdate.add(ne);

                }
            }
        }
        return itemsToupdate;
    }

    /**
* @author Donato Lombardi - dolombardi@deloitte.it
* @description Method to retrieve a Map of Work Order -> List skills requested
* @param listItems - List<NE__OrderItem__c>
* @return Boolean
**/

    public static Boolean checkSalesChannel(List<NE__OrderItem__c>listItems){
        Boolean salesChannel = False;
        for(NE__OrderItem__c ne : listItems){
            if(ne.NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c== NULL){
                salesChannel = True;
            }
        }
        return salesChannel;
    }

}