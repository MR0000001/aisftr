/**
 * The Class XC_ConfItem_U_CheckOrderType.
 * @author Nicola Arrigo - narrrigo@deloitte.it
 * @date Creation 16/07/2020
 * @description XC_ConfItem_U_CheckOrderType – Class to retrieve the Order Type 
 */


public with sharing class XC_ConfItem_U_CheckOrderType {
    /**
     * @author Nicola Arrigo - narrigo@deloitte.it 
     * @description method to retrieve the Configuration Type
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void retrieveOrderType(Map<Id, NE__Order__c> mapOld,Map<Id, NE__Order__c> mapNew){
      
        List<id> orderList=new List<id>();
        map<id,string> mapOrderType=new map<id,string>();
        List<NE__OrderItem__c> orderItemList=new List<NE__OrderItem__c>();
        for(NE__Order__c order:mapNew.values()){
            if((order.XC_Segment__c=='B2B' || order.XC_Segment__c=='B2G')&&
                mapNew.get(order.id).NE__Type__c!=mapOld.get(order.id).NE__Type__c 
                ){
                    orderList.add(order.id);
                    mapOrderType.put(order.id,order.NE__Type__c);
                }   
         }
        if(orderList.isEmpty()){
            return;
        }
        orderItemList=[select id,XC_ConfigurationType__c,NE__OrderId__c from NE__OrderItem__c 
                                              where NE__OrderId__c IN:orderList];
        for(NE__OrderItem__c confItem:orderItemList){
            confItem.XC_ConfigurationType__c=mapOrderType.get(confItem.NE__OrderId__c);
        }
        
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(orderItemList);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Configuration_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);                                          
    } 
}