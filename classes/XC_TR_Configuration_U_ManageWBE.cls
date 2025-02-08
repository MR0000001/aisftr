/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 27/01/2020  
* @description XC_TR_Configuration_U_ManageWBE – Utility class for managing WBE 
*/

public with sharing class XC_TR_Configuration_U_ManageWBE {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_ManageWBE');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 02/12/2019
    * @description Method to generate WBE for all configuration item for Order (with Record Type Order)
    * @param listNew - List<NE__Order__c>
    * @param mapOld - Map<Id, NE__Order__c>
    * @param mapNew - Map<Id, NE__Order__c>
    */
    public static void generateWBE(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){ 
        List<NE__Order__c> listOrder = XC_UTIL_Sobject.getListChanged(new List<String>{'RecordTypeId'}, mapOld,  mapNew);        
        List<NE__Order__c> listOrderType = XC_UTIL_Sobject.getListChanged(new List<String>{'NE__Type__c'}, mapOld,  mapNew);
        if(listOrder.isEmpty() && listOrderType.isEmpty()) {
            return;
        } 
        
        Set<Id> listOrderId = new Set<Id>();
        List<String> listRecordTypePrev = new List<String>{Label.XC_CL_Order_RecordTypeOpty, Label.XC_CL_Order_RecordTypeQuote};
        for(NE__order__c order : listOrder) {
            if(listRecordTypePrev.contains(XC_UTIL_Sobject.retrieveRecordTypNameFromId(mapOld.get(order.Id).RecordTypeId)) && XC_UTIL_Sobject.retrieveRecordTypNameFromId(mapNew.get(order.Id).RecordTypeId) == Label.XC_CL_Order_RecordTypeOrder) {
                listOrderId.add(order.Id);
            }
        }
        listOrderId.addAll(XC_UTIL_Sobject.getIds(listOrderType));
        if(listOrderId.isEmpty()) {
            return;
        }
        
        // Filter by Record Type Order and query for Parent's fields:
        String query = XC_UTIL_Sobject.selectAllFieldsGetSelect('NE__OrderItem__c');
        String labelRecordTypeOrder = Label.XC_CL_Order_RecordTypeOrder; 
        query = query + ', NE__ProdId__r.XC_LIC_Product_Name__c, NE__Parent_Order_Item__r.XC_CMProfitCenter__c, NE__Parent_Order_Item__r.XC_CMCostCenter__c, NE__OrderId__r.RecordType.DeveloperName, ' +
            ' NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductLine__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProductServiceType__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_ProfitCenter__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_CostCenter__c, ' +
            ' NE__CatalogItem__r.Id, NE__CatalogItem__r.XC_ProfitCenter__c, NE__CatalogItem__r.XC_CostCenter__c, NE__CatalogItem__r.XC_ProductServiceType__c, NE__CatalogItem__r.XC_ProductLine__c, NE__OrderId__r.XC_Country__c, NE__OrderId__r.XC_LegalEntity__c, ' +
            ' NE__OrderId__r.Id, NE__OrderId__r.NE__OptyId__r.Id, NE__OrderId__r.XC_Segment__c, NE__OrderId__r.NE__OptyId__r.XC_Company__c, NE__OrderId__r.NE__OptyId__r.Business__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c, NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__CatalogItem__r.XC_WbeMode__c ' +
            ' FROM NE__OrderItem__c ' +
            ' WHERE NE__OrderId__c IN :listOrderId';
        List<NE__OrderItem__c> listOrderItemFiltered = Database.query(String.escapeSingleQuotes(query));
        if(listOrderItemFiltered.isEmpty()) {
            return;
        }   
        List<NE__OrderItem__c> listOrderItemB2C = XC_TR_ConfigurationItem_U_GenerateWBE.filterByB2C(listOrderItemFiltered);
        List<NE__OrderItem__c> listOrderItemToUpdate = XC_TR_ConfigurationItem_U_GenerateWBE.populateWBEfields(listOrderItemB2C);
        
        populateWBEFromBundle(listOrderItemToUpdate);
        
        List<XC_UTIL_Sobject.WrapperResult> listWrRs = XC_UTIL_Sobject.updateListRecords(listOrderItemToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(listWrRs)) {
            listNew[0].addError(listWrRs[0].errorMessage);
        }
    }
    
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @date 23/01/2020
    * @description Method to calculate WBE from bundle
    * @param listOrderItemToUpdate - List<NE__OrderItem__c>
    */
    public static void populateWBEFromBundle(List<NE__OrderItem__c> listOrderItemToUpdate){
        Map<Id, List<NE__OrderItem__c>> mapBundleIdListConfItem = new Map<Id, List<NE__OrderItem__c>>();
        Map<Id, NE__OrderItem__c> mapBundleIdWBE = new Map<Id, NE__OrderItem__c>();
        
        for(NE__OrderItem__c oi : listOrderItemToUpdate){
            if(oi.NE__Bundle_Configuration__c != null){
                if(!mapBundleIdListConfItem.containsKey(oi.NE__Bundle_Configuration__c)){
                    mapBundleIdListConfItem.put(oi.NE__Bundle_Configuration__c, new List<NE__OrderItem__c>());
                }
                mapBundleIdListConfItem.get(oi.NE__Bundle_Configuration__c).add(oi);
            } else if(oi.XC_Wbe__c != null){
                mapBundleIdWBE.put(oi.Id, oi);
            }
        } 
        for(Id bundleId : mapBundleIdListConfItem.keySet()){
            if(mapBundleIdWBE.containsKey(bundleId)) {
                for(NE__OrderItem__c oi : mapBundleIdListConfItem.get(bundleId)){
                    if(String.isNotBlank(mapBundleIdWBE.get(bundleId).XC_Wbe__c)){
                        oi.XC_Wbe__c = mapBundleIdWBE.get(bundleId).XC_Wbe__c;
                    }
                    if(String.isNotBlank(mapBundleIdWBE.get(bundleId).XC_CMProfitCenter__c)) {
                        oi.XC_CMProfitCenter__c = mapBundleIdWBE.get(bundleId).XC_CMProfitCenter__c;
                    }
                    if(String.isNotBlank(mapBundleIdWBE.get(bundleId).XC_CMCostCenter__c)) {
                        oi.XC_CMCostCenter__c = mapBundleIdWBE.get(bundleId).XC_CMCostCenter__c;
                    }
                    if(String.isNotBlank(mapBundleIdWBE.get(bundleId).XC_ProductLine__c)) {
                        oi.XC_ProductLine__c = mapBundleIdWBE.get(bundleId).XC_ProductLine__c;
                    }
                    if(String.isNotBlank(mapBundleIdWBE.get(bundleId).XC_ProductServiceType__c)) {
                        oi.XC_ProductServiceType__c = mapBundleIdWBE.get(bundleId).XC_ProductServiceType__c;
                    }
                }
            }
        }
    } 

}