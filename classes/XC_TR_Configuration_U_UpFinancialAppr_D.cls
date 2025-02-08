/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 19/10/2018
* @date Modification dd/mm/yyyy
* @description  XC_TR_Configuration_U_UpFinancialAppr_D – DAO for the XC_TR_Configuration_U_UpFinancialAppr class
*/

public without sharing  class XC_TR_Configuration_U_UpFinancialAppr_D {
    
    /*public static Map<Id, List<NE__OrderItem__c>> getOrderItemByOrderId(List<Id> listConfigurationItemId) {

        //SELECT ID, (SELECT Id FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id IN ('a1a1w00000007hUAAQ')
        //System.debug(listOrder.get(0) .NE__Order_Items__r.get(0));

        /* Get all the configuration's children */
            /*List<NE__OrderItem__c> listOrderItems = [SELECT ID, NE__ProdId__c, NE__OrderID__c 
        FROM NE__OrderItem__c
        WHERE Id
        IN :listConfigurationItemId];

        Map<Id, List<NE__OrderItem__c>> mapOrderIdToOrderItems = new Map<Id, List<NE__OrderItem__c>>();
        List<NE__OrderItem__c> listOrderItemsTmp;

        /* Fill the map with the (key, value) filled with the configuration id and the configuration items linked to the configuration. They contain
        the link to the NE__Product__c  */
            /*for(NE__OrderItem__c item : listOrderItems) {
        if(mapOrderIdToOrderItems.get(item.NE__OrderId__c) != null) {
        listOrderItemsTmp = mapOrderIdToOrderItems.get(item.NE__OrderId__c);
        } else {
        listOrderItemsTmp = new List<NE__OrderItem__c>();
        }
        listOrderItemsTmp.add(item);
        mapOrderIdToOrderItems.put(item.NE__OrderId__c, listOrderItems);
        System.debug('@@@ in for ' + mapOrderIdToOrderItems);
        }

    //List<NE__OrderItem__c> listOrderItems = [SELECT ID, NE__ProdId__c FROM NE__OrderItem__c WHERE Id IN :setOrderItemIds];
    return mapOrderIdToOrderItems;				
    }*/
    
    /**
     * @description Gets the order by list id.
     * @param listOrderIds the list order ids
     * @return the order by list id
     */
    public static List<NE__Order__c> getOrderByListId(List<Id> listOrderIds) {
        
        Map<Id,NE__Order__c> oMap = new Map<Id,NE__Order__c>([SELECT Id, XC_Status__c, XC_FinancialApproval__c, 
                                        XC_Compliance_Approval__c, XC_DeliveryType__c,
                                        RecordTypeId, RecordType.DeveloperName, (SELECT ID, NE__ProdId__c, NE__OrderID__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_Compliance_Verification__c 
                                                                                 FROM NE__Order_Items__r)
                                        FROM NE__Order__c
                                        WHERE Id IN :listOrderIds]);

        List<NE__Order__c> listOrder = oMap.values(); 
        return listOrder;
        
    }
    
    /*public static Map<Id, NE__Catalog_Category__c> getCatalogCategoryByOrder(List<NE__Order__c> listOrder) {

        Map<Id, Id> mapOrderToCatalogId = getCatalogIds(listOrder);

        List<NE__Catalog_Category__c> listCatalogCategory = [SELECT Id, name, NE__CatalogId__c
        FROM NE__catalog_category__C
        WHERE NE__CatalogId__c IN :mapCatalogIdListOrderId.values()];

        Map<Id, NE__Catalog_Category__c> mapOrderToCatalog = new Map<Id, NE__Catalog_Category__c>();
        List<Id> listOrderIdTmp;

        for(Id orderId : mapCatalogIdListOrderId.keySet()) {
        mapOrderToCatalog.put(orderId, )
        }    
    return mapOrderToCatalog;
    }

    private static Map<Id, Id> getCatalogIds(List<NE__Order__c> listOrder) {

        Map<Id, List<Id>> mapIds = new Map<Id, List<Id>>();
        List<Id> listIdTmp;

        for(NE__Order__c order: listOrder) {
            mapIds.put(order.Id, order.NE__CatalogId__c);
        }

        return mapIds; 
    }*/
    
    /**
     *@description  Gets the list catalog category.
     *
     * @param listOrder the list order
     * @return the list catalog category
     */
    /*private static List<Decimal> getListCatalogCategory(List<NE__Order__c> listOrder) {
        
        List<Decimal> listCatalogCategory = new List<Decimal>();
        
        for(NE__Order__c order : listOrder) {
            for(NE__OrderItem__c item : order.NE__Order_Items__r){
                listCatalogCategory.add(item.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_Approval_To_Start__c);
            }
        }
        
        return listCatalogCategory;
        
    }*/
    
    /**
     *@description  Populate map category.
     * @param listRecordsMetadata the list records metadata
     * @return the map
     */
    /*private static Map<String, Decimal> populateMapCategory(List<XC_Configuration_Flow_Map__mdt> listRecordsMetadata) {
        
        Map<String, Decimal> mapCategoryToFlow = new Map<String, Integer>();
        
        for(XC_Configuration_Flow_Map__mdt cm : listRecordsMetadata){
            mapCategoryToFlow.put(cm.Catalog_Category__c, cm.Process_To_Activate__c);
        }
        return mapCategoryToFlow;
    }*/
    
    /*public static Map<String, Decimal> getMapRecordsMetadata(List<NE__Order__c> listOrder) {

        List<Decimal> listCatalogCategory = getListCatalogCategory(listOrder);

        List<XC_Configuration_Flow_Map__mdt> listRecordsMetadata = [SELECT Catalog_Category__c, Process_To_Activate__c 
        FROM XC_Configuration_Flow_Map__mdt
        WHERE Catalog_Category__c IN :listCatalogCategory]; 

        Map<String, Decimal> mapCategoryToFlow = populateMapCategory(listRecordsMetadata);

        return mapCategoryToFlow;
    }*/
}