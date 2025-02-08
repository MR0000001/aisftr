/**
 * @author            :  Luisana Rocco lrocco@deloitte.it
 * @date Creation     :  12/11/2020
 * @date Modification :  dd/mm/yyyy
 * @description       :  DAO for the XC_IN064_ManageZPayment class
*/

public without sharing class  XC_IN064_ManageZPayment_D {


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

        Map<Id, NE__OrderItem__c> itemMap = new Map<Id, NE__OrderItem__c>([SELECT NE__OrderId__r.NE__One_Time_Fee_Total__c, NE__OrderId__r.NE__Recurring_Charge_Total__c, 
                                                                            NE__OrderId__r.XC_PaymentTransactionDetails__c, NE__OrderId__r.XC_PaymentTransactionID__c, 
                                                                            NE__OrderId__r.XC_PaymentTransactionDate__c, XC_BillingProfileLineItem__r.XC_ZuoraId__c, XC_PaymentMethod__c,
                                                                            NE__OrderId__r.Name, CurrencyIsoCode
                                                                            FROM NE__OrderItem__c 
                                                                            WHERE Id = :confItemId]);

        return itemMap.get(confItemId);
    }

    
    /**
    * @description get steps to complete
    * @param orderId the order id
    * @return Map<Id, XC_Provisioning_Step__c>
    */
    public static Map<Id, XC_Provisioning_Step__c> getStepsToComplete(String orderId) {

        Map<Id, XC_Provisioning_Step__c > provStepMap = new Map<Id, XC_Provisioning_Step__c>([SELECT  Id, XC_Status__c 
                                                                                              FROM XC_Provisioning_Step__c  
                                                                                              WHERE XC_Flow_API_Name__c =: Label.XC_CL_ProvisioningManagePayment_Flow AND XC_Configuration_Item__r.NE__OrderId__c =: orderId AND XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress]);

        return provStepMap;
    }


}