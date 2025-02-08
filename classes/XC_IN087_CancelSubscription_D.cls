/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  03/03/2022
 * @date Modification :  dd/mm/yyyy
 * @description       :  DAO for the XC_IN087_CancelSubscription class
*/

public without sharing class XC_IN087_CancelSubscription_D {

/* @description get Steps
    *  @param listStepIds the list of step id
    *  @return the steps
    */
    public static Map<Id, XC_Provisioning_Step__c> getMapSteps(List<Id> listStepIds) {
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, 
                XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c, XC_Configuration_Item__r.NE__Parent_Order_Item__c, XC_LastInvoiceDate__c
                FROM XC_Provisioning_Step__c 
                WHERE Id IN: listStepIds]);
        return mapSteps;
    }


    /**
    * @description get Order Item information
    * @param confItemId the configuration item id
    * @param parentOiId the parent item id
    * @return the order item mat
    */
    public static Map<Id, NE__OrderItem__c> getOrderItemInfo(String confItemId, String parentOiId) {

        Map<Id, NE__OrderItem__c> itemMap = new Map<Id, NE__OrderItem__c>();
        if(!String.isBlank(parentOiId)){
            itemMap = new Map<Id, NE__OrderItem__c>([SELECT id,
                                                    (SELECT Id, XC_SubscriptionName__c, RootAssetId  FROM Assets__r)
                                                    FROM NE__OrderItem__c 
                                                    WHERE Id =: parentOiId OR NE__Parent_Order_Item__c =: parentOiId]);
        }else{
            itemMap = new Map<Id, NE__OrderItem__c>([ SELECT id,
                                                    (SELECT Id, XC_SubscriptionName__c, RootAssetId  FROM Assets__r)
                                                    FROM NE__OrderItem__c 
                                                    WHERE Id =: confItemId OR NE__Parent_Order_Item__c =: confItemId]);
        }
        return itemMap;
    }

}