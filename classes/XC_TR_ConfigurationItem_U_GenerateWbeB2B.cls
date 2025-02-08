/**
 * @author Donato Lombardi - dolombardi@deloitte.it
 * @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_TR_ConfigurationItem_U_GenerateWbeB2B - Util Class to manage WBE for B2B and Technical Product
**/

public without sharing class XC_TR_ConfigurationItem_U_GenerateWbeB2B {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_GenerateWbeB2B'); 

    /**
     * @description Method to manage WBE for ChangeOrder
     * @param listNew - List<NE__OrderItem__c>
    **/
    public static void wbeChangeOrder(List<NE__OrderItem__c> listNewN){
        List<NE__OrderItem__c> listNewB2B = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> listNewB2C = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi: listNewN){
            if((oi.XC_NE_Type__c == Label.XC_CL_Configuration_TypeChangeOrder || oi.XC_NE_Type__c == 'Disconnection') && oi.XC_Segment__c != 'B2C' && String.isEmpty(oi.XC_Wbe__c)){
                listNewB2B.add(oi);
             }
        }

        for(NE__OrderItem__c oi: listNewN){
            if(oi.XC_Segment__c == 'B2C' && oi.XC_Product_Type__c == Label.XC_CL_Technical && oi.XC_Product_Subtype__c == Label.XC_CL_ProductSubTypeValue && String.isEmpty(oi.XC_Wbe__c)){
                listNewB2C.add(oi);
            }
        }
        if(listNewB2B.isEmpty() && listNewB2C.isEmpty()){
            return;
        }
        List<NE__OrderItem__c> listAllItems = new List<NE__OrderItem__c>();
        listAllItems.addAll(listNewB2B);
        listAllItems.addAll(listNewB2C);





        List<NE__OrderItem__c> queryOrderItems = queryOrderItems(listAllItems);
        if(queryOrderItems.isEmpty()){
            return;
        }
        List<NE__OrderItem__c> listForB2B = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> listForB2CTechProd = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi : queryOrderItems) {
            if(oi.XC_NE_Type__c == Label.XC_CL_Configuration_TypeChangeOrder || (oi.XC_NE_Type__c == 'Disconnection' && oi.NE__OrderId__r.XC_Segment__c != 'B2C')) {
                listForB2B.add(oi);
            }
            if(oi.NE__OrderId__r.XC_Segment__c == 'B2C' && oi.XC_Product_Type__c == Label.XC_CL_Technical && oi.XC_Product_Subtype__c == Label.XC_CL_ProductSubTypeValue) {
                listForB2CTechProd.add(oi);
            }
        }

        // For B2B:
        if(!listForB2B.isEmpty()) {
            List<NE__OrderItem__c> orderItemsToAppliesWBE = retrieveConfItem(listForB2B);
            if(orderItemsToAppliesWBE.isEmpty()){
                return;
            }
            appliedWBE(listAllItems, orderItemsToAppliesWBE);
        }
        // For B2C tech prod (temp):
        if(!listForB2CTechProd.isEmpty()) {
            List<NE__OrderItem__c> listOrderItemToUpdate = XC_TR_ConfigurationItem_U_GenerateWBE.populateWBEfields(listForB2CTechProd);
            for(NE__OrderItem__c oi : listOrderItemToUpdate) {
                for(NE__OrderItem__c originalOi : listAllItems) {
                    if(oi.Id == originalOi.Id) {
                        originalOi.XC_Wbe__c = oi.XC_Wbe__c;
                        originalOi.XC_CMCostCenter__c = oi.XC_CMCostCenter__c;
                        originalOi.XC_CMProfitCenter__c = oi.XC_CMProfitCenter__c;
                        break;
                    }
                }
            }
        }
    }

    /**
     * @description Method to retrieve conf item
     * @param listToQuery - List<NE__OrderItem__c>
     * @return List<NE__OrderItem__c>
    **/
    private static List<NE__OrderItem__c> retrieveConfItem(List<NE__OrderItem__c> listToQuery) {
        List<NE__OrderItem__c> listItemsFiltered = new List<NE__OrderItem__c>();
        /*List<String> listCountryOrder = new List<String>();
        List<String> listLegalEntityOrder = new List<String>();
        for(NE__OrderItem__c oi : listToQuery){
            listCountryOrder.add(oi.NE__OrderId__r.XC_Country__c);
            listLegalEntityOrder.add(oi.NE__OrderId__r.XC_LegalEntity__c);
        }
        List<XC_CM_CountryLegalEntityAssociation__mdt> listLegalEntityAss = new List<XC_CM_CountryLegalEntityAssociation__mdt>();
        listLegalEntityAss = [
            SELECT Id, XC_LegalEntity__c, XC_Country__c, XC_Category__c
                        FROM XC_CM_CountryLegalEntityAssociation__mdt
                        WHERE XC_LegalEntity__c IN :listLegalEntityOrder AND XC_Country__c IN :listCountryOrder
            ];
        for(NE__OrderItem__c oi : listToQuery) {
            for(XC_CM_CountryLegalEntityAssociation__mdt cmdt : listLegalEntityAss) {
                if(oi.NE__OrderId__r.XC_Country__c == cmdt.XC_Country__c && oi.NE__OrderId__r.XC_LegalEntity__c == cmdt.XC_LegalEntity__c && cmdt.XC_Category__c == 'B2B') {
                    listItemsFiltered.add(oi);
                }
            }
        }*/
        for(NE__OrderItem__c oi : listToQuery) {
            if(oi.NE__OrderId__r.XC_Segment__c == 'B2B') {
                listItemsFiltered.add(oi);
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listItemsFiltered: ' + listItemsFiltered);
        return listItemsFiltered;
    }

    /**
     * @description Method to query conf item
     * @param listNew - List<NE__OrderItem__c>
     * @return List<NE__OrderItem__c>
    **/
    private static List<NE__OrderItem__c> queryOrderItems(List<NE__OrderItem__c> listNew){
        Set<Id> setIdItems = new Set<Id>();
        for(NE__OrderItem__c ne : listNew){
            setIdItems.add(ne.NE__OrderId__c);
        }
        /*List<NE__OrderItem__c> listToQuery = new List<NE__OrderItem__c>([
            SELECT Id, NE__OrderId__r.XC_Segment__c, XC_NE_Type__c, NE__ProdName__c, NE__OrderId__c,  XC_Wbe__c, XC_CMProfitCenter__c, XC_CMCostCenter__c, NE__Parent_Order_Item__c, NE__OrderId__r.XC_Subtype__c ,NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Country__c 
            FROM NE__OrderItem__c 
            WHERE NE__OrderId__c IN :setIdItems AND (XC_NE_Type__c = :Label.XC_CL_Configuration_TypeChangeOrder OR (XC_Product_Type__c =: Label.XC_CL_Technical  AND XC_Product_Subtype__c =: Label.XC_CL_ProductSubTypeValue))
        ]);*/
        String labelChangeOrder = Label.XC_CL_Configuration_TypeChangeOrder;
        String labelDisconnection = 'Disconnection';
        String labelProduct = Label.XC_CL_ProductSubTypeValue;
        String labelTech = Label.XC_CL_Technical;
        String labelInOrder = Label.XC_CL_Order_RecordTypeOrder;
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__OrderItem__c');
        query = query + ', NE__ProdId__r.XC_LIC_Product_Name__c, NE__Parent_Order_Item__r.XC_CMProfitCenter__c, NE__Parent_Order_Item__r.XC_CMCostCenter__c, NE__OrderId__r.RecordType.DeveloperName, ' +
            ' NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductLine__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductServiceType__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProfitCenter__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_CostCenter__c, ' +
            ' NE__CatalogItem__r.Id, NE__CatalogItem__r.XC_ProfitCenter__c, NE__CatalogItem__r.XC_CostCenter__c, NE__CatalogItem__r.XC_ProductServiceType__c, NE__CatalogItem__r.XC_ProductLine__c, NE__OrderId__r.XC_Country__c, NE__OrderId__r.XC_LegalEntity__c, NE__OrderId__r.XC_Subtype__c, ' +
            ' NE__OrderId__r.Id, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.NE__OptyId__r.Id, NE__OrderId__r.NE__OptyId__r.XC_Company__c, NE__OrderId__r.NE__OptyId__r.Business__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_WbeMode__c ' +
            ' FROM NE__OrderItem__c ' +
            ' WHERE NE__OrderId__c IN :setIdItems AND (XC_NE_Type__c = :labelChangeOrder OR (NE__OrderId__r.RecordTypeAUX__c = :labelInOrder AND XC_Product_Type__c = :labelTech AND XC_Product_Subtype__c = :labelProduct) OR XC_NE_Type__c = :labelDisconnection )';
        List<NE__OrderItem__c> listToQuery = Database.query(String.escapeSingleQuotes(query));
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listToQuery: ' + listToQuery);
        return listToQuery;
    }

    /**
     * @description Method to write WBE on conf item
     * @param listNew - List<NE__OrderItem__c>
     * @param orderItemsToAppliesWBE - List<NE__OrderItem__c>
    **/
    private static void appliedWBE(List<NE__OrderItem__c> listNew, List<NE__OrderItem__c> orderItemsToAppliesWBE){
        List<NE__OrderItem__c> orderItemsParent = new List<NE__OrderItem__c>();
        Map<id, NE__OrderItem__c> mapNew = new Map<id, NE__OrderItem__c>(listNew);
        for(NE__OrderItem__c ne : listNew){
            for(NE__OrderItem__c oi : orderItemsToAppliesWBE){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ NEOrderID: ' + ne.NE__OrderId__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ OIOrderID: ' + oi.NE__OrderId__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ne.NE__ProdName__c: ' + ne.NE__ProdName__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ oi.NE__ProdName__c: ' + oi.NE__ProdName__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ne.XC_Wbe__c: ' + ne.XC_Wbe__c);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ oi.XC_Wbe__c: ' + oi.XC_Wbe__c);
                if(ne.NE__OrderId__c == oi.NE__OrderId__c && ne.XC_Wbe__c == null && oi.XC_Wbe__c !=null){
                    if(ne.NE__ProdName__c == oi.NE__ProdName__c){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ condizione: ' + ne.NE__OrderId__c + oi.NE__OrderId__c + ne.XC_Wbe__c + oi.XC_Wbe__c);
                    ne.XC_Wbe__c = oi.XC_Wbe__c;
                    ne.XC_CMCostCenter__c = oi.XC_CMCostCenter__c;
                    ne.XC_CMProfitCenter__c = oi.XC_CMProfitCenter__c;
                        
                        ne.XC_BillingProfileLineItem__c = oi.XC_BillingProfileLineItem__c;
                        ne.XC_PaymentMethod__c = oi.XC_PaymentMethod__c;
                        ne.XC_WBE_Status__c = oi.XC_WBE_Status__c;
                        ne.XC_BlockWBE_User__c = true;
                        ne.XC_BillingModel__c = oi.XC_BillingModel__c;
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ne.XC_Wbe__cdentroIF: ' + ne.XC_Wbe__c);
                    }
                }
            }
        }
        for(NE__OrderItem__c oi : listNew){
            if(oi.NE__Parent_Order_Item__c  != null && mapNew.get(oi.NE__Parent_Order_Item__c)!= null ){
                oi.XC_Wbe__c =  mapNew.get(oi.NE__Parent_Order_Item__c).XC_Wbe__c;
                oi.XC_BillingProfileLineItem__c =  mapNew.get(oi.NE__Parent_Order_Item__c).XC_BillingProfileLineItem__c;
                oi.XC_PaymentMethod__c =  mapNew.get(oi.NE__Parent_Order_Item__c).XC_PaymentMethod__c;
            }
        }
    }

}