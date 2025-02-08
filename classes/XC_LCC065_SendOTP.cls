/**
 * @description The Class XC_LCC065_SendOTP.
 */
public without sharing class XC_LCC065_SendOTP {
    
    /**
     * @description New email for customer.
     * @param interactionValues the interaction values
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper newEmailForCustomer(String interactionValues){
        return XC_LCC039_CustomerInteraction.newEmailForCustomer(interactionValues);
    }
    
    /**
     * @description Retrieve phone number.
     *
     * @param recordId the record id
     * @return the string
     */
    @AuraEnabled
    public static String retrievePhoneNumber(String recordId) {
        String phoneNumber = '';
        Map<Id,NE__Order__c> ordersMap = new Map<Id,NE__Order__c>([SELECT id, NE__OptyId__c, NE__OptyId__r.XC_Contact__c FROM NE__Order__c WHERE Id =: recordId]);
        List<NE__Order__c> orders = ordersMap.values();


        if(!orders.isEmpty() && orders[0].NE__OptyId__r.XC_Contact__c!=null){
            Map<Id,Contact> cMap = new Map<Id,Contact>([SELECT id, MobilePhone FROM Contact WHERE Id =: orders[0].NE__OptyId__r.XC_Contact__c]);
            List<Contact> c = cMap.values();
            if(c[0].MobilePhone!=null){
                 return c[0].MobilePhone;
            }
           
        }
            return phoneNumber;
        
    }
    
    /**
     * @description Retrieve email.
     *
     * @param recordId the record id
     * @return the string
     */
    @AuraEnabled
    public static String retrieveEmail(String recordId) {
    String email = '';
        Map<Id,NE__Order__c> ordersMap = new Map<Id,NE__Order__c>([SELECT id, NE__OptyId__c, NE__OptyId__r.XC_Contact__c FROM NE__Order__c WHERE Id =: recordId]);
        List<NE__Order__c> orders = ordersMap.values();
        if(!orders.isEmpty() && orders[0].NE__OptyId__r.XC_Contact__c!=null){
            Map<Id,Contact> cMap = new Map<Id,Contact>([SELECT id, Email FROM Contact WHERE Id =: orders[0].NE__OptyId__r.XC_Contact__c]);
            List<Contact> c = cMap.values();
            if(c[0].Email!=null){
                 return c[0].Email;
            }
           
        }
            return email;
        
    }

}