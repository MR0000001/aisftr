/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  15/06/2021
 * @date Modification :  dd/mm/yyyy
 * @description       :  DAO for the XC_IN077_ChangeInvoiceDeliveryPreference class
*/

public without sharing class XC_IN077_ChangeInvoiceDeliveryPref_D {

    /* @description get Steps
    *  @param listStepIds the list of step id
    *  @return the steps
    */
    public static Map<Id, XC_Provisioning_Step__c> getMapSteps(List<Id> listStepIds) {
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            return new Map<Id, XC_Provisioning_Step__c>();
        }
        Map<Id, XC_Provisioning_Step__c> mapSteps = new Map<Id, XC_Provisioning_Step__c>(
                [SELECT XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, 
                XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c, XC_Configuration_Item__r.NE__OrderId__r.XC_InvoiceDeliveryPreference__c
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

        Map<Id, NE__OrderItem__c> itemMap = new Map<Id, NE__OrderItem__c>([ SELECT XC_BillingProfileLineItem__r.XC_InvoiceDeliveryPreference__c,XC_BillingProfileLineItem__r.XC_BillingProfile__c,
                                                                            XC_BillingProfileLineItem__r.XC_ZuoraId__c, XC_BillingProfileLineItem__r.XC_BillToContactId__c,
                                                                            XC_BillingProfileLineItem__r.XC_SoldToContactId__c, XC_BillingProfileLineItem__r.XC_BillToAddress__c,
                                                                            XC_BillingProfileLineItem__r.XC_SoldToAddress__c, NE__OrderId__r.XC_InvoiceDeliveryPreference__c,
                                                                            (SELECT Id, XC_InvoiceDeliveryPreference__c FROM Assets__r)
                                                                            FROM NE__OrderItem__c 
                                                                            WHERE Id = :confItemId]);

        return itemMap.get(confItemId);
    }


}