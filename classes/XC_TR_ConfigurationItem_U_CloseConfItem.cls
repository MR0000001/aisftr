/**
 * The Class XC_TR_ConfigurationItem_U_CloseConfItem.
 *
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com, Fabrizio Antonioli - fabrizio.antonioli@nttdata.com, Giovanni Schioppa - giovanni.schioppa@nttdata.com
 * @date Creation 28/11/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_ConfigurationItem_U_CloseConfItem – Class to close the Order Item when two roll-up fields on the children are equal.
 */
public without sharing class XC_TR_ConfigurationItem_U_CloseConfItem {

    /**
     * @description Close configuration item.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void closeConfigurationItem(List<NE__OrderItem__c> listNew, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){      
        List<String> fieldList = new List<String>{'XC_Number_of_Completed_Steps__c'};       
	    List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        List<NE__OrderItem__c> listOrderItemToCheck = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c orderItem: confItemListChanged){
            if(orderItem.XC_Number_of_Completed_Steps__c == orderItem.XC_NumberOfSteps__c){
                listOrderItemToCheck.add(orderItem);
            }
        }
        if(!listOrderItemToCheck.isEmpty()){
            List<NE__OrderItem__c> listOrderItemToUpdate = getOrderItemToClose(listOrderItemToCheck);
            
            for(NE__OrderItem__c orderItem : listOrderItemToUpdate){
                orderItem.NE__Status__c = Label.XC_CL_Configuration_Item_Completed;
            }
        }
    }

    /**
     * Gets the order item to close.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param orderItemList the order item list
     * @return the order item to close
     * @description Method to get a list of Order Item to update based on the cases on the connected Order
     */
   public static List<NE__OrderItem__c> getOrderItemToClose(List<NE__OrderItem__c> orderItemList){
        List<NE__OrderItem__c> listOrderItemToUpdate = new List<NE__OrderItem__c>();
        Map<String,String> mapOrderItemOrder = new Map<String,String>();
        for(NE__OrderItem__c orderItem : orderItemList){
            mapOrderItemOrder.put(orderItem.Id, orderItem.NE__OrderId__c);
        }
        Map<Id, NE__Order__c> mapOrderWithCases =  getMapOrderCases(mapOrderItemOrder.values());                                                                   
        Map<String, List<Case>> mapOrderListCases = new Map<String, List<Case>>();

        for(Id orderId : mapOrderWithCases.keyset() ){
            List<Case> casesList = mapOrderWithCases.get(orderId).XC_Cases__r;
            mapOrderListCases.put(orderId,casesList);
        }

        for(NE__OrderItem__c orderItem : orderItemList){
            String orderId = mapOrderItemOrder.get(orderItem.Id);
            if(mapOrderListCases.get(orderId).isEmpty()){
                listOrderItemToUpdate.add(orderItem);
            }     
        }
        return listOrderItemToUpdate;
    }

    /**
     * Gets the map order cases.
     *
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param orderItemIdList the order item id list
     * @return the map order cases
     * @description Method to create a map querying the order and the closed cases with type Administrative Tasks children.
     */
    public static Map<Id, NE__Order__c>  getMapOrderCases(List<String> orderItemIdList){
        List<String> closedState = new List<String>{'Completed', 'ESTA007','ESTA008','CNT0008','CNT0009'};
        Map<Id, NE__Order__c> mapOrderCases = new Map<Id, NE__Order__c>([SELECT Id, 
                                                                            (select Id,Status,Reason,Type FROM XC_Cases__r WHERE Type =: Label.XC_CL_Administrative_Tasks AND Status NOT IN: closedState) 
                                                                            FROM NE__Order__c WHERE Id IN: orderItemIdList]);
        return mapOrderCases;
    }
}