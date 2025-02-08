/**
 * The Class XC_TR_ConfItem_U_SetAllowPaymentTypes.
 *
 * @author            : Nicola Mariniello nmariniello@delotte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 06/07/2020
 * @date Modification : dd/mm/yyyy
 * @description       : Class to calculate the allowable payment types
 **/ 


public without sharing class XC_TR_ConfItem_U_SetAllowPaymentTypes {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfItem_U_SetAllowPaymentTypes');


    /**
     * onAfterInsert.
     * @param listNew the list new
     * @description on After Insert
     */
    public static void onAfterInsert(List<NE__OrderItem__c> listNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_ConfItem_U_SetAllowPaymentTypes.onAfterInsert');

        Map<String, List<NE__OrderItem__c>> keyOrderItemsMap = new Map<String, List<NE__OrderItem__c>>();
        for(NE__OrderItem__c oi : listNew) {
            if(String.isBlank(oi.XC_AllowablePaymentTypes__c)) {
                //String key = oi.XC_LegalEntity__c+'-'+oi.XC_Segment__c;
                String key = oi.XC_LegalEntityFormula__c+'-'+oi.XC_Segment__c;
                if(keyOrderItemsMap.containsKey(key)) {
                    keyOrderItemsMap.get(key).add(oi);
                } else {
                    keyOrderItemsMap.put(key, new List<NE__OrderItem__c>{oi});
                }
            }
        }

        List<NE__OrderItem__c> itemsToUpdate = new List<NE__OrderItem__c> (); 
        for(String key : keyOrderItemsMap.keySet()) {
            String legalEntity = key.split('-')[0];
            String stream = key.split('-')[1];
            itemsToUpdate.addAll(calculateAllowablePaymentTypes(legalEntity, stream, keyOrderItemsMap.get(key)));
        }

        if(!itemsToUpdate.isEmpty()) {
            List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_SObject.updateListRecords(itemsToUpdate);
            System.debug('@@NM results: ' + results);
        }
    }
 

    /**
     * calculateAllowablePaymentTypes.
     * @param legalEntity the legalEntity
     * @param stream the stream
     * @param orderItems the orderItems list
     * @return List<NE__OrderItem__c>
     * @description calculate Allowable Payment Types
     */
    public static List<NE__OrderItem__c> calculateAllowablePaymentTypes(String legalEntity, String stream, List<NE__OrderItem__c> orderItems) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_ConfItem_U_SetAllowPaymentTypes.calculateAllowablePaymentTypes');

        Map<String,String> excludedMopsbyLeStr = getExcludedMops(legalEntity, stream, orderItems);

        List<NE__OrderItem__c> orderItemsToUpdate = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi : orderItems) {
            if(String.isNotBlank(excludedMopsbyLeStr.get(oi.Id))) {
                NE__OrderItem__c oiToUpdate = new NE__OrderItem__c();
                oiToUpdate.Id = oi.Id;
                oiToUpdate.XC_AllowablePaymentTypes__c = excludedMopsbyLeStr.get(oi.Id);
                orderItemsToUpdate.add(oiToUpdate);
            }
        }
        
        return orderItemsToUpdate;
    }


    /**
     * getExcludedMops.
     * @param legalEntity the legalEntity
     * @param stream the stream
     * @param orderItems the orderItems list
     * @return Map<String,String>
     * @description get Excluded Mops
     */
    private static Map<String,String> getExcludedMops(String legalEntity, String stream, List<NE__OrderItem__c> orderItems) {
        
        Map<String,List<XC_UTIL_PaymentMethodFilter.MopWrapper>> excludedMopsbyLe = XC_UTIL_PaymentMethodFilter.getAvailabeMopsForOrderItems(legalEntity, stream, orderItems);
        
        Map<String,String> excludedMopsbyLeStr = new Map<String,String>();
        for(String s : excludedMopsbyLe.keySet()) {
            List<String> l = new List<String>();
            for(XC_UTIL_PaymentMethodFilter.MopWrapper m : excludedMopsbyLe.get(s)){
                l.add(m.mopValue);
            }
            String res = String.valueOf(l);
            res = res.substring(1,res.length()-1);
            excludedMopsbyLeStr.put(s, res);
        }

        return excludedMopsbyLeStr;
    }


    /**
     * onBeforeUpdate.
     * @param mapOld the mapOld
     * @param mapNew the mapNew
     * @description on Before Update
     */
    public static void onBeforeUpdate(Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'IN XC_TR_ConfItem_U_SetAllowPaymentTypes.onBeforeUpdate');

        List<String> fieldList = new List<String>{'XC_BillingModel__c'}; 
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(confItemListChanged.isEmpty()) {
            return;
        }

        Map<String, List<NE__OrderItem__c>> keyOrderItemsMap = new Map<String, List<NE__OrderItem__c>>();
        for(NE__OrderItem__c oi : confItemListChanged) {
            //String key = oi.XC_LegalEntity__c+'-'+oi.XC_Segment__c;
            String key = oi.XC_LegalEntityFormula__c+'-'+oi.XC_Segment__c;
            if(keyOrderItemsMap.containsKey(key)) {
                keyOrderItemsMap.get(key).add(oi);
            } else {
                keyOrderItemsMap.put(key, new List<NE__OrderItem__c>{oi});
            }
        }

        Map<String,String> excludedMopsbyLeStr = new Map<String,String>();
        for(String key : keyOrderItemsMap.keySet()) {
            String legalEntity = key.split('-')[0];
            String stream = key.split('-')[1];
            List<NE__OrderItem__c> orderItems = keyOrderItemsMap.get(key);
            
            excludedMopsbyLeStr.putAll(getExcludedMops(legalEntity, stream, orderItems));
        }

        for(NE__OrderItem__c oi : confItemListChanged) {
            if(String.isNotBlank(excludedMopsbyLeStr.get(oi.Id))) {
                oi.XC_AllowablePaymentTypes__c = excludedMopsbyLeStr.get(oi.Id);
            }
        }
    }

}