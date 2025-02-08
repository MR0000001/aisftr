/**
 * The Class XC_TR_ConfigurationItem_U_FillFields.
 *
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 13/12/2019
 * @date Modification 02/04/2020
 * @description Cless to fill ConfigurationItem fields
 */


public without sharing class XC_TR_ConfigurationItem_U_FillFields {

    private class UtilWrapperMaps {
        Map<String, String> prodIdLanguageMap = new Map<String, String>();
        Map<String, String> prodIdDescriptionMap = new Map<String, String>();
    }


    /**
     * @description Before order item insert
     * @param listNew the list new
     */
    /*public static void fillFieldsOnInsert(List<NE__OrderItem__c> listNew) {
        
        Set<Id> orderIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'NE__OrderId__c');
        Map<Id, NE__Order__c> ordersMap = new Map<Id, NE__Order__c>([SELECT Id, NE__Type__c, XC_Subtype__c,
                                                                    (SELECT Id, XC_PaymentMethod__c, NE__BillingProfId__c, XC_BillingProfileLineItem__c FROM NE__Order_Items__r WHERE XC_BillingProfileLineItem__c != null)
                                                                    FROM NE__Order__c
                                                                    WHERE Id IN :orderIds]);
        
        for(NE__OrderItem__c oi : listNew) {
            NE__Order__c order = ordersMap.get(oi.NE__OrderId__c);
            if(order.NE__Order_Items__r.size()>0 && order.NE__Type__c == 'ChangeOrder' && (order.XC_Subtype__c == 'Substitution (Malfunction)' || order.XC_Subtype__c == 'Substitution (Change of equipment)' || order.XC_Subtype__c == 'Service Upgrade/Downgrade')) {
                oi.XC_PaymentMethod__c = ordersMap.get(oi.NE__OrderId__c).NE__Order_Items__r[0].XC_PaymentMethod__c;
                oi.NE__BillingProfId__c = ordersMap.get(oi.NE__OrderId__c).NE__Order_Items__r[0].NE__BillingProfId__c;
                oi.XC_BillingProfileLineItem__c = ordersMap.get(oi.NE__OrderId__c).NE__Order_Items__r[0].XC_BillingProfileLineItem__c;
            }
        }
    }*/


    /**
     * @description Before order item update
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void fillFieldsOnUpdate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {

        Map<Id, NE__OrderItem__c> oiToProcessForPayment = new Map<Id, NE__OrderItem__c>();
        List<String> prodList = new List<String>();

        for(NE__OrderItem__c oi : mapNew.values()) {

            if(String.isBlank(oi.NE__Item_Code__c)) {
                oi.NE__Item_Code__c = oi.Name;
                //oi.CurrencyIsoCode = 'COP'; TEST
            }

            if((String.isBlank(oi.XC_PaymentMethod__c) || String.isBlank(oi.XC_BillingProfileLineItem__c)) &&
                (String.isNotBlank(oi.NE__Bundle_Configuration__c) || String.isNotBlank(oi.NE__Root_Order_Item__c))) {
                    oiToProcessForPayment.put(oi.Id, oi);
            }

            if(String.isBlank(oi.XC_ProductOwner__c)){
                prodList.add(oi.NE__ProdId__c);
            }
        }
        /*
        if(!prodList.isEmpty()){
            setProductOwner(prodList,mapNew.values());
        }*/

        if(!oiToProcessForPayment.isEmpty()) {
            fillPaymentMethodFields(oiToProcessForPayment, mapNew);
        }

    }

    public static void setProductOwner(List<String> idProduct, List<NE__OrderItem__c> orderItemList){

        Map<Id, NE__DocumentationCharacterist__c> mapProdDoc = new Map<Id, NE__DocumentationCharacterist__c>();

        if(!idProduct.isEmpty() && !orderItemList.isEmpty() ){
            Map<Id, NE__DocumentationCharacterist__c> dcs = XC_REST_Order_U_D.getDocCharactPartner(idProduct);

            for(NE__DocumentationCharacterist__c docChar: dcs.values() ){
                mapProdDoc.put(docChar.NE__Product__c, docChar);
            }

            for(NE__OrderItem__c orderItem : orderItemList) {
                if( !mapProdDoc.isEmpty() && mapProdDoc.get(orderItem.NE__ProdId__c)!= null ){
                    orderItem.XC_ProductOwner__c = mapProdDoc.get(orderItem.NE__ProdId__c).NE__Value__c;
                }
            }
        }
    }

    /**
     * @description fill Payment Method Fields
     * @param oiToProcess the oi map to process
     */
    public static void fillPaymentMethodFields(Map<Id, NE__OrderItem__c> oiToProcess, Map<Id, NE__OrderItem__c> mapNew) {

        System.debug(LoggingLevel.FINEST, '@@@ oiToProcess: ' + oiToProcess);

        Set<Id> orderIds = XC_UTIL_Sobject.getSetIdsOnField(oiToProcess.values(), 'NE__OrderId__c');
        Map<Id, NE__Order__c> ordersMap = new Map<Id, NE__Order__c>([SELECT Id, NE__Type__c, XC_Subtype__c,
                                                                    (SELECT Id, XC_PaymentMethod__c, NE__BillingProfId__c, XC_BillingProfileLineItem__c FROM NE__Order_Items__r WHERE XC_BillingProfileLineItem__c != null)
                                                                    FROM NE__Order__c
                                                                    WHERE Id IN :orderIds]);
        
        Map<Id, NE__OrderItem__c> oiFathersMap = new Map<Id, NE__OrderItem__c>();

        for(NE__OrderItem__c oi : oiToProcess.values()) {
            System.debug(LoggingLevel.FINEST, '@@@ oi: ' + oi);

            NE__Order__c order = ordersMap.get(oi.NE__OrderId__c);
            if(checkChangeOrder(order)) {

                if(String.isNotBlank(oi.NE__Bundle_Configuration__c)) {  // For oi child of Bundle

                    setPaymentMethodOnOI(oi, order);

                    if(!mapNew.containsKey(oi.NE__Bundle_Configuration__c)) {
                        NE__OrderItem__c itemFather = new NE__OrderItem__c (Id = oi.NE__Bundle_Configuration__c);
                        setPaymentMethodOnOI(itemFather, order);
                        oiFathersMap.put(itemFather.Id, itemFather);
                    } else {
                        mapNew.get(oi.NE__Bundle_Configuration__c).XC_PaymentMethod__c = order.NE__Order_Items__r[0].XC_PaymentMethod__c;
                        mapNew.get(oi.NE__Bundle_Configuration__c).NE__BillingProfId__c = order.NE__Order_Items__r[0].NE__BillingProfId__c;
                        mapNew.get(oi.NE__Bundle_Configuration__c).XC_BillingProfileLineItem__c = order.NE__Order_Items__r[0].XC_BillingProfileLineItem__c;
                    }

                } else if(String.isNotBlank(oi.NE__Root_Order_Item__c)) {   // For oi child of Service

                    if(!mapNew.containsKey(oi.NE__Root_Order_Item__c)) {
                        NE__OrderItem__c itemFather = new NE__OrderItem__c (Id = oi.NE__Root_Order_Item__c);
                        setPaymentMethodOnOI(itemFather, order);
                        oiFathersMap.put(itemFather.Id, itemFather);
                    } else {
                        mapNew.get(oi.NE__Root_Order_Item__c).XC_PaymentMethod__c = order.NE__Order_Items__r[0].XC_PaymentMethod__c;
                        mapNew.get(oi.NE__Root_Order_Item__c).NE__BillingProfId__c = order.NE__Order_Items__r[0].NE__BillingProfId__c;
                        mapNew.get(oi.NE__Root_Order_Item__c).XC_BillingProfileLineItem__c = order.NE__Order_Items__r[0].XC_BillingProfileLineItem__c;
                    }
                }
            }
        }

        if(!oiFathersMap.isEmpty()) {
            XC_UTIL_Sobject.updateListRecords(oiFathersMap.values());
        }
    }


    /**
     * @description check Change Order
     * @param order the order
     * @return the result of the check
     */
    private static Boolean checkChangeOrder(NE__Order__c order) {
        if(order.NE__Order_Items__r.size()>0 && order.NE__Type__c == Label.XC_CL_Configuration_TypeChangeOrder && String.isNotBlank(order.XC_Subtype__c) && 
            (order.XC_Subtype__c.containsIgnoreCase('Substitution') || order.XC_Subtype__c == 'Service Upgrade/Downgrade')) {
                return true;
        }

        return false;
    }


    /**
     * @description set Payment Method On OrderItem from Order
     * @param oi the order item
     * @param order the order
     */
    private static void setPaymentMethodOnOI(NE__OrderItem__c oi, NE__Order__c order) {
        oi.XC_PaymentMethod__c = order.NE__Order_Items__r[0].XC_PaymentMethod__c;
        oi.NE__BillingProfId__c = order.NE__Order_Items__r[0].NE__BillingProfId__c;
        oi.XC_BillingProfileLineItem__c = order.NE__Order_Items__r[0].XC_BillingProfileLineItem__c;
    }


    /**
     * @description fill Credit Assignment On Update
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void fillCreditAssignmentOnUpdate(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew) {
		
        List<String> fieldList = new List<String>{'XC_CreditAssignmentAvailable__c'};       
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(confItemListChanged.isEmpty()) {
            return;
        }

        Map<Id, NE__OrderItem__c> oisToUpdate = new Map<Id, NE__OrderItem__c>();
        for(NE__OrderItem__c oi : confItemListChanged) {
            if(oi.XC_Product_Subtype__c == 'Incentive' && String.isNotBlank(oi.NE__Bundle_Configuration__c)) {
                oisToUpdate.put(oi.NE__Bundle_Configuration__c, new NE__OrderItem__c(Id = oi.NE__Bundle_Configuration__c, XC_CreditAssignmentAvailable__c = oi.XC_CreditAssignmentAvailable__c));
            }
        }
		
        XC_UTIL_SObject.updateListRecords(oisToUpdate.values());
    }

    /**
    * @description fill the field XC_TranslatedProductName__c on order item based on legal entity and product name
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 26/4/2020 
    * @param listNew 
    **/
    public static void fillTranslatedProductName(List<NE__OrderItem__c> listNew){
        List<String> productIdList = new List<String>();
        List<String> legalEntityList = new List<String>();
        for(NE__OrderItem__c orderItem : listNew){
            productIdList.add(orderItem.NE__ProdId__c);
            legalEntityList.add(orderItem.XC_LegalEntityFormula__c);
        }

        if(!productIdList.isEmpty() && !legalEntityList.isEmpty()){
            Map<String,String> legalEntityLanguageMap = getLanguageFromCMDT(legalEntityList);
            if(!legalEntityLanguageMap.isEmpty()){
                UtilWrapperMaps wrapper = getTranslationInfo(legalEntityLanguageMap, productIdList);
                Map<String,String> prodIdLanguageMap = wrapper.prodIdLanguageMap;
                Map<String,String> prodIdDescriptionMap = wrapper.prodIdDescriptionMap;
                for(NE__OrderItem__c orderItemToChange : listNew){
                    if(legalEntityLanguageMap.containsKey(orderItemToChange.XC_LegalEntityFormula__c)){
                        String language = legalEntityLanguageMap.get(orderItemToChange.XC_LegalEntityFormula__c);
                        String key = orderItemToChange.NE__ProdId__c + '-' + language;
                        if(!prodIdLanguageMap.isEmpty() && prodIdLanguageMap.containsKey(key)){
                            orderItemToChange.XC_TranslatedProductName__c = prodIdLanguageMap.get(key);
                            orderItemToChange.XC_TranslatedProductDescription__c = prodIdDescriptionMap.get(key);
                        } else {
                            orderItemToChange.XC_TranslatedProductName__c = orderItemToChange.NE__ProdName__c;
                        }
                    } else {
                        orderItemToChange.XC_TranslatedProductName__c = orderItemToChange.NE__ProdName__c;
                    }
                }
            }
        }
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 26/4/2020 
    * @param legalEntityList 
    * @return Map<String, String> 
    **/
    private static Map<String,String> getLanguageFromCMDT(List<String> legalEntityList){
        Map<String,String> legalEntityLanguageMap = new Map<String,String>();
        List<XC_CM_LegalEntity_Configuration__mdt> legalEntityConfList = new List<XC_CM_LegalEntity_Configuration__mdt>([SELECT id, Label, DeveloperName, XC_Country__c, XC_Language__c ,XC_LegalEntity__c 
                                                                                                                        FROM XC_CM_LegalEntity_Configuration__mdt
                                                                                                                        WHERE XC_LegalEntity__c IN: legalEntityList LIMIT 1]);
        for(XC_CM_LegalEntity_Configuration__mdt legEntity : legalEntityConfList){
            legalEntityLanguageMap.put(legEntity.XC_LegalEntity__c, legEntity.XC_Language__c);
        } 
        return legalEntityLanguageMap;                                                                                                       
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 26/4/2020 
    * @param legalEntityLanguageMap 
    * @param productIdList 
    * @return Map<String, String> 
    **/
    private static UtilWrapperMaps getTranslationInfo(Map<String,String> legalEntityLanguageMap, List<String> productIdList){
        UtilWrapperMaps wrapper = new UtilWrapperMaps();
        Map<String, String> prodIdLanguageMap = new Map<String, String>();
        Map<String, String> prodIdDescriptionMap = new Map<String, String>();
        List<NE__Translation__c> translationProdNameList = new List<NE__Translation__c>([SELECT id, name, NE__Language_user__c, NE__Text__c,NE__Commercial_Product__c, NE__Description__c
                                                                                        FROM NE__Translation__c 
                                                                                        WHERE NE__Commercial_Product__c IN: productIdList 
                                                                                        AND NE__Language_user__c IN: legalEntityLanguageMap.values()]);
        for(NE__Translation__c translation : translationProdNameList){
            prodIdLanguageMap.put(translation.NE__Commercial_Product__c + '-' + translation.NE__Language_user__c, translation.NE__Text__c);
            if(!String.isEmpty(translation.NE__Description__c)){
                prodIdDescriptionMap.put(translation.NE__Commercial_Product__c + '-' + translation.NE__Language_user__c, translation.NE__Description__c + '<br><br>');
            } else {
                prodIdDescriptionMap.put(translation.NE__Commercial_Product__c + '-' + translation.NE__Language_user__c, '<br>');        
            }
        }
        wrapper.prodIdLanguageMap = prodIdLanguageMap;
        wrapper.prodIdDescriptionMap = prodIdDescriptionMap;
        return wrapper;
    }

    /**
    * @description populates fields on order when a BPLI of external financing type is placed on the orderItem
    * @author Francesco Imperioli - fimperioli@deloitte.it | 29/4/2020 
    * @param mapOld 
    * @param mapNew 
    * @return void 
    **/
    public static void populateExternalFinancingFieldsOnOrder(Map<Id, NE__OrderItem__c> mapOld, Map<Id, NE__OrderItem__c> mapNew){

        List<NE__OrderItem__c> updatedOis = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_BillingProfileLineItem__c'},mapOld,mapNew);
        Set<String> bplisId = new Set<String>();

        for(NE__OrderItem__c oi : updatedOis){
            if(String.isNotBlank(oi.XC_BillingProfileLineItem__c)){
                bplisId.add(oi.XC_BillingProfileLineItem__c);
            }
        }

        if(!bplisId.isEmpty()){

            Set<NE__Order__c> ordersToUpdate = new Set<NE__Order__c>();

            Map<Id,XC_BillingProfileLineItem__c> bplisMap = new Map<Id,XC_BillingProfileLineItem__c>([
            SELECT Id,XC_BillingProfile__r.XC_FinancialInstitute__c,XC_BillingProfile__r.XC_OtherFinancialInstitute__c 
            FROM XC_BillingProfileLineItem__c  
            WHERE XC_BillingProfile__r.NE__Payment__c = 'External Financing' AND Id IN :bplisId]);

            for(NE__OrderItem__c oi : updatedOis){
                if(bplisMap.containsKey(oi.XC_BillingProfileLineItem__c)){
                    String financialInsitutionString = String.isNotBlank(bplisMap.get(oi.XC_BillingProfileLineItem__c).XC_BillingProfile__r.XC_OtherFinancialInstitute__c) ?
                    bplisMap.get(oi.XC_BillingProfileLineItem__c).XC_BillingProfile__r.XC_OtherFinancialInstitute__c :
                    bplisMap.get(oi.XC_BillingProfileLineItem__c).XC_BillingProfile__r.XC_FinancialInstitute__c;
                    NE__Order__c relatedOrder= new NE__Order__c(Id = oi.NE__OrderId__c,XC_FinancialInstitution__c = financialInsitutionString);
                    ordersToUpdate.add(relatedOrder);
                }
            }

            if(!ordersToUpdate.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(new List<NE__Order__c>(ordersToUpdate));
            }

        }

    }
}