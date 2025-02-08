/**
* @author Monica Cutillo - mcutillo@deloitte.it + Eleni Tsiolaki - etsiolaki@deloitte.gr
* @date Creation 02/04/2021
* @description DAO Class for the XC_AMP_LCP019_BillingProfileDefinition Controller
*/
public without sharing class XC_AMP_LCC019_BillingProfileDefinition_D {

    /**
     * @description retrieveDataFromOpportunity
     * @param opportunityId
     * @return Opportunity result Object
     */
    public static Opportunity retrieveDataFromOpportunity(String opportunityId){
        Map<Id,Opportunity> oppData = new Map<Id,Opportunity>([
            SELECT Id, AccountId, XC_Contact__c, ContactId, XC_Address__c, XC_LegalEntity__c, XC_Segment__c, Account.XC_DocumentCountry__c, Account.IdentityNumber__c, 
            Account.IdentityType__c, Account.XC_RecordTypeDeveloperName__c, XC_Contact__r.Name,XC_Address__r.XC_StreetType__c, XC_Address__r.XC_StreetTypeText__c, 
            XC_Address__r.XC_AddressCountry__c, XC_Address__r.XC_City__c, XC_Address__r.XC_Address__c, XC_Address__r.XC_DeliveryAddress__c,XC_Address__r.XC_BillingAddress__c,
            XC_Address__r.XC_PostalCode__c , XC_Address__r.XC_InstallationAddress__c, XC_Address__r.XC_StreetNumber__c,
            XC_AMP_Order__c
            FROM Opportunity
             WHERE Id =: opportunityId
        ]);
        Id oppId = opportunityId;
        return oppData.get(oppId);
    }
    
    /**
     * @description retrieveAddresData from id
     * @param addressId
     *@return the XC_Address__c
    */
    public static XC_Address__c retrieveAddresData(String addressId){
        Map<Id,XC_Address__c> listAddMap = new Map<Id,XC_Address__c>([
            SELECT Id,XC_GasCUPS__c,XC_ElectricCUPS__c, XC_AddressCountry__c, XC_Account__r.IdentityType__c, XC_Account__r.IdentityNumber__c
            FROM XC_Address__c 
             WHERE Id =:addressId LIMIT 1
        ]);
        
        return listAddMap.values()[0];
    }

    /**
    *@author: Eleni Tsiolaki
    *@description : retrieve Billing Profile Line Items related to the Account, with the same Contact and Address.
    *@createddate 2021-04-07
    * @param accountId
    * @param contactId
    * @param addressId
    * @return a Map with the Payment Method as key, and the List of available BillingProfileLineItem objects per payment method as values.
    **/
    @AuraEnabled
    public static Map<String,List<XC_BillingProfileLineItem__c>> getAvailableBillingProfiles(String accountId, String contactId, String addressId){
        List<XC_BillingProfileLineItem__c > billProfiles = [SELECT Id, Name, XC_Account__c, XC_PaymentMethod__c, XC_BillingProfileName__c 
                FROM XC_BillingProfileLineItem__c 
                WHERE XC_Account__c =: accountId 
                AND XC_BillToAddress__c =: addressId 
                AND XC_SoldToAddress__c =: addressId 
                AND XC_BillToContactId__c =: contactId 
                AND XC_SoldToContactId__c =: contactId
                AND XC_Status__c IN ( 'Active', 'Sent To Zuora') ];
        Map<String,List<XC_BillingProfileLineItem__c>> paymentMethodToBillingProfileMap = new Map<String,List<XC_BillingProfileLineItem__c>>();
        for(XC_BillingProfileLineItem__c billPr : billProfiles) {
            if(!paymentMethodToBillingProfileMap.containsKey(billPr.XC_PaymentMethod__c)) {
                paymentMethodToBillingProfileMap.put(billPr.XC_PaymentMethod__c, new List<XC_BillingProfileLineItem__c>());
            }
            paymentMethodToBillingProfileMap.get(billPr.XC_PaymentMethod__c).add(billPr);
        }
        return paymentMethodToBillingProfileMap;
    }

    /**
     * @description retrieveOrderItemsFromOpportunity
     * @param orderId
     * @return List<NE__OrderItem__c>
     */
    public static List<NE__OrderItem__c> retrieveOrderItemsFromOpportunity(String orderId){
        List<NE__OrderItem__c> ordeItems = [SELECT Id,  XC_Product_Subtype__c, NE__Billing_Account__c, NE__Account__c, XC_BillingModel__c FROM NE__OrderItem__c WHERE NE__OrderId__c  =: orderId];
        return ordeItems;
    }
}