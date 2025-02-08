/**
 * The Class XC_IN031_DeactivateAutomaticRenewal_D.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 04/09/2019
 * @date Modification : 
 * @description       : DAO for the XC_IN031_DeactivateAutomaticRenewal class
 **/


public without sharing class XC_IN031_DeactivateAutomaticRenewal_D {


    public class DeactivateAutoRenwalWrapperResponse {
        public Boolean success = false;
        public String errorMessage='';
        public String subscriptionId;
    }


    /**
     * @description manageResponsesDeactivateAutomaticRenewal
     * @param respOwnerTransf
     * @param respDisconnection
     * @return DeactivateAutoRenwalWrapperResponse
     */
    public static  DeactivateAutoRenwalWrapperResponse manageResponsesDeactivateAutoRenewal(XC_REST_ZuoraOwnerTransfer_U.WrapperResponse respOwnerTransf, XC_REST_Disconnection.WrapperResponse respDisconnection) {
        DeactivateAutoRenwalWrapperResponse wResponse = new DeactivateAutoRenwalWrapperResponse();
        if(respOwnerTransf!= null && respOwnerTransf.results!=null && !respOwnerTransf.results.isEmpty()) {
            if(respOwnerTransf.results[0].success) {
                wResponse.success = true;
                wResponse.subscriptionId = respOwnerTransf.results[0].subscriptionId;
            } else {
                wResponse.success = false;
                wResponse.errorMessage = respOwnerTransf.results[0].errors[0].message;
            }
        } else if(respDisconnection!=null) {
            if(respDisconnection.success) {
                wResponse.success = true;
            } else {
                wResponse.success = false;
                wResponse.errorMessage = respDisconnection.reasons[0].message;
            }
        } 
        return wResponse;
    }


    /**
     * @description get Order Item
     * @param confItemId the configuration item id
     * @return the order item
     */
    public static NE__OrderItem__c getOrderItem(String confItemId) {

        Map<Id, NE__OrderItem__c> itemMap = new Map<Id, NE__OrderItem__c>([SELECT ID, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c, XC_ZQuoteId__c, NE__OrderId__r.XC_eMobTransactionId__c,
                                                                                NE__BillingProfId__r.Zuora_Account_Id__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Segment__c,NE__OrderId__r.XC_Subtype__c, NE__OrderId__r.XC_LegalEntity__c,
                                                                                (SELECT Id, XC_SubscriptionName__c, XC_Subscription__c, XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__InitialTerm__c,
                                                                                    XC_Subscription__r.Zuora__InitialTermPeriodType__c, XC_Subscription__r.Zuora__RenewalTerm__c, XC_Subscription__r.Zuora__RenewalTermPeriodType__c,
                                                                                    XC_Subscription__r.Zuora__TermSettingType__c, XC_Subscription__r.Zuora__Status__c, XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Service_Last_Renewal_Date__c,
                                                                                    NE__Activation_Date__c, XC_ContractEndDate__c, XC_Configuration_Item__c, XC_Configuration_Item__r.XC_ZQuoteId__c, XC_ZQuoteId__c FROM Assets__r),
                                                                                (SELECT Id, Name, NE__Value__c, XC_DeveloperName__c, NE__FamPropId__r.NE__FamilyId__r.XC_LIC_Family_Name__c FROM NE__Order_Item_Attributes__r)
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

        Map<Id, zqu__Quote__c> mapZquote = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__ZuoraSubscriptionNumber__c, zqu__ZuoraSubscriptionID__c, zqu__ZuoraAccountID__c, zqu__Subscription_Term_Type__c,
                                                                        XC_LastSubscriptionId__c, zqu__InitialTerm__c, zqu__InitialTermPeriodType__c, zqu__RenewalTerm__c, zqu__RenewalTermPeriodType__c, zqu__Account__c
                                                                        FROM zqu__Quote__c 
                                                                        WHERE Id =: zquoteId]);

        return (mapZquote.isEmpty()) ? null : mapZquote.values()[0];
    }


    /**
     * @description get subscription
     * @param subNumber the subscription Number
     * @return the subscription
     */
    public static Zuora__Subscription__c getSubscription(String subNumber) {

        Map<Id, Zuora__Subscription__c> mapSubscription = new Map<Id, Zuora__Subscription__c>([SELECT Id, Zuora__External_Id__c, Zuora__InitialTerm__c, Zuora__InitialTermPeriodType__c, Zuora__TermSettingType__c,
                                                                                                    Zuora__RenewalTerm__c, Zuora__RenewalTermPeriodType__c, Zuora__Status__c
                                                                                                FROM Zuora__Subscription__c 
                                                                                                WHERE Zuora__SubscriptionNumber__c =: subNumber]);

        return (mapSubscription.isEmpty()) ? null : mapSubscription.values()[0];
    }

}