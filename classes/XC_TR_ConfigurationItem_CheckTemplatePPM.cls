/**
     * @author Donato Lombardi - dolombardi@deloitte.it
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return void
    **/
public with sharing class XC_TR_ConfigurationItem_CheckTemplatePPM {
    public static void confItemCheckTemplateOnProjectIsFilled(Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Project_Template__c'};
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(confItemListChanged.isEmpty()){
            return;
        }
        for(NE__OrderItem__c ne :confItemListChanged){
            ne.XC_IsAProduct__c = true;
        }
    }


    public static void orderCheckTemplateOnProjectIsFilled(Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        List<String> fieldList = new List<String>{'XC_Project_Template__c'};
        List<NE__Order__c> confListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(confListChanged.isEmpty()){
            return;
        }
        List<NE__OrderItem__c> orderItemsToUpdate = new List<NE__OrderItem__c>();
        orderItemsToUpdate = retrieveConfigurationItemParent(confListChanged);
        if(!orderItemsToUpdate.isEmpty()&& Schema.sObjectType.NE__OrderItem__c.isUpdateable()){
            update orderItemsToUpdate;

        }


    }


    private static List<NE__OrderItem__c> retrieveConfigurationItemParent(List<NE__Order__c> confListChanged){
        Set<Id> setOrderId = new Set<Id>();
        setOrderId = XC_UTIL_Sobject.getSetIds(confListChanged);
        List<NE__OrderItem__c> listOrderItemsParent = new List<NE__OrderItem__c>();
        if(Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            listOrderItemsParent = [select id, NE__Parent_Order_Item__c, NE__OrderId__c, XC_IsAProduct__c from NE__OrderItem__c where NE__OrderId__c IN :setOrderId AND NE__Parent_Order_Item__c = NULL];

        }
        List<NE__OrderItem__c> listOrderItemToUpdate = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c ne : listOrderItemsParent){
            if(ne.XC_IsAProduct__c == False)
            ne.XC_IsAProduct__c = True;
            listOrderItemToUpdate.add(ne);
        }
        return listOrderItemToUpdate;
    }

}