/**
 * @author            :  Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  30/04/2020
 * @date Modification :  dd/mm/yyyy
 * @description       :  DAO for the XC_IN051_BillingDisconnectionProcess class  
*/


public without sharing class XC_IN051_BillingDisconnectionProcess_D {


    /* @description get Steps
    *  @param listStepIds the list of step id
    *  @return the steps
    */
    public static Map<Id, XC_Provisioning_Step__c> getMapSteps(List<Id> listStepIds) {
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            return new Map<Id, XC_Provisioning_Step__c>();
        }
		Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c
                FROM XC_Provisioning_Step__c 
                WHERE Id IN: listStepIds]);
		return mapSteps;
	}


    /**
    * @description get Order Item
    * @param confItemId the configuration item id
    * @return the order item
    */
    public static NE__OrderItem__c getOrderItem(String confItemId) {

        Map<Id, NE__OrderItem__c> itemMap = new Map<Id, NE__OrderItem__c>([SELECT NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, XC_ZQuoteId__c, NE__OrderId__r.XC_Subtype__c,
                                                                            (SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_SubscriptionName__c FROM Assets__r)
                                                                            FROM NE__OrderItem__c 
                                                                            WHERE Id = :confItemId]);

        return itemMap.get(confItemId);
    }


    /**
    * @description get zQuote
    * @param zquoteId the zQuote id
    * @return the zQuote
    */
    public static zqu__Quote__c getZquote(String zquoteId) {

        Map<Id, zqu__Quote__c> mapZquote = new Map<Id, zqu__Quote__c>([SELECT Id,  zqu__ZuoraSubscriptionID__c, zqu__ZuoraAccountID__c, XC_LastSubscriptionId__c
                                                                        FROM zqu__Quote__c 
                                                                        WHERE Id =: zquoteId]);

        return mapZquote.values()[0];
    }

    
    /**
    * @description get ZSubscription
    * @param subNumber the number of the subscription
    * @return the Subscription
    */
    public static Zuora__Subscription__c getSubscription(String subNumber) {

        Map<Id, Zuora__Subscription__c> zuoraSubMap = new  Map<Id, Zuora__Subscription__c>([SELECT Zuora__Status__c, Zuora__External_Id__c
                                                                                            FROM Zuora__Subscription__c
                                                                                            WHERE Zuora__SubscriptionNumber__c =: subNumber LIMIT 1]);

        return zuoraSubMap.values()[0];
    }

}