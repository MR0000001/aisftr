/**
 * The Class XC_IN034_UploadFreekWh_D.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 07/10/2019
 * @date Modification : 
 * @description       : DAO for the XC_IN034_UploadFreekWh class
 **/


public without sharing class XC_IN034_UploadFreekWh_D {
    /**
     * @description get Order Item
     * @param confItemId the configuration item id
     * @return the order item
     */
    public static NE__OrderItem__c getOrderItem(String confItemId) {

        Map<Id, NE__OrderItem__c> itemMap = new Map<Id, NE__OrderItem__c>([SELECT ID, XC_BillingProfileLineItem__r.XC_ZuoraId__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.XC_eMobTransactionId__c,
                                                                            (SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c FROM Assets__r),
                                                                            (SELECT Id, NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c, NE__FamPropId__r.NE__PropId__r.XC_LIC_DynamicPropertyDefinition__c, NE__Value__c FROM NE__Order_Item_Attributes__r)
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

        Map<Id, zqu__Quote__c> mapZquote = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__ZuoraSubscriptionNumber__c, zqu__ZuoraSubscriptionID__c, zqu__ZuoraAccountID__c, XC_LastSubscriptionId__c
                                                                        FROM zqu__Quote__c 
                                                                        WHERE Id =: zquoteId]);

        return mapZquote.values()[0];
    }
}