/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 17/12/2018
* @description XC_TR_ConfigurationItem_U_CheckIfProduct - When create a Configuration Item, check if it's a product or not based on the logic on a custom metadata.
*/

public without sharing class XC_TR_ConfigurationItem_U_CheckIfProduct {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_CheckIfProduct');
    
    /**
     * @description onBeforeInsert
     * @param listNew the list new
     */
    public static void onBeforeInsert(List<NE__OrderItem__c> listNew){
        checkIfConfigurationItemIsProduct(listNew);
        setProvisioningSpareParts(listNew);
    }

    /**
     * @description onBeforeUpdate
     * @param listNew the list new  
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void onBeforeUpdate(List<NE__OrderItem__c> listNew, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'NE__CatalogItem__c'};       
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!confItemListChanged.isEmpty()){
            checkIfConfigurationItemIsProduct(confItemListChanged);
        }
    }

    /**
    * @description Check if the configuration item is a real product
    * @param listConfigurationItem
    */
    public static void checkIfConfigurationItemIsProduct(List<NE__OrderItem__c> listConfigurationItem){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@listConfigurationItem --->' + listConfigurationItem);
        List<String> catalogItemIds = XC_UTIL_Sobject.getListFieldValues(listConfigurationItem, 'NE__CatalogItem__c');
        if(catalogItemIds.isEmpty()){
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@catalogItemIds --->' + catalogItemIds);
        Map<Id, NE__Catalog_Item__c> catalogItemMap =  new Map<Id, NE__Catalog_Item__c>([SELECT Id, NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c 
                                                    FROM NE__Catalog_Item__c
                                                    WHERE Id IN: catalogItemIds]);
        List<String> productList = new List<String>();
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@catalogItemMap --->' + catalogItemMap);
        for(NE__OrderItem__c orderItem : listConfigurationItem){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@orderItem.NE__CatalogItem__c  ---> ' + orderItem.NE__CatalogItem__c);
            if(!catalogItemMap.containsKey(orderItem.NE__CatalogItem__c) || String.isBlank(catalogItemMap.get(orderItem.NE__CatalogItem__c ).NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c)){
                continue;
            }
            productList.add(catalogItemMap.get(orderItem.NE__CatalogItem__c ).NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@productList --->' + productList);  
        Map<String, Boolean> mapConfItemReal = XC_UTIL_ConfigurationItem.getMapRealProducts(productList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@mapConfItemReal --->' + mapConfItemReal);
        
        for(NE__OrderItem__c orderItem : listConfigurationItem){
            if(!catalogItemMap.containsKey(orderItem.NE__CatalogItem__c)){
                continue;
            }
            if(mapConfItemReal.containsKey(catalogItemMap.get(orderItem.NE__CatalogItem__c).NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c)){
                if(mapConfItemReal.get(catalogItemMap.get(orderItem.NE__CatalogItem__c).NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c)){
                    orderItem.XC_IsAProduct__c = true;
                }
            }
        }                                              
    } 

    /**
    * @description Check if the configuration item is a real product
    * @param listConfigurationItem
    */
    public static void setProvisioningSpareParts(List<NE__OrderItem__c> listConfigurationItem){
        List<NE__OrderItem__c> listItemSpareParts = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> couponSpareParts = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c orderItem : listConfigurationItem){
            if(orderItem.NE__Bundle_Configuration__c == null && orderItem.XC_Product_Type__c == 'Technical' && orderItem.XC_Product_Subtype__c == 'Product'){
                listItemSpareParts.add(orderItem);
            } else if(orderItem.NE__Bundle_Configuration__c == null && orderItem.XC_Product_Type__c == Label.XC_CL_OrderItem_ProductType && orderItem.XC_Product_Subtype__c == Label.XC_CL_OrderItemSubtype_Coupon){
                couponSpareParts.add(orderItem);
            }
        }
        if(!listItemSpareParts.isEmpty()){
            listItemSpareParts[0].XC_ProvisioningSpareParts__c = true; //only 1 of the spare parts needs to be sent to provisioning
        }
        if(!couponSpareParts.isEmpty()){
            couponSpareParts[0].XC_ProvisioningSpareParts__c = true; //only 1 of the spare parts needs to be sent to provisioning
        }
    }

    /**
     * @description Check if configuration item is product
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    /*public static void checkIfConfigurationItemIsProduct(List<NE__OrderItem__c> listNew, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'NE__CatalogItem__c'};       
        List<NE__OrderItem__c> confItemListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        
        List<String> productList = new List<String>();
        List<String> orderItemIds = new List<String>() ;
        Map<String, String> orderItemProduct = new Map<String, String>();
        for(NE__OrderItem__c orderItem : confItemListChanged){
            orderItemProduct.put(orderItem.Id, orderItem.NE__CatalogItem__c);
        }

        Map<Id, NE__Catalog_Item__c> catalogItemWithProduct = new Map<Id, NE__Catalog_Item__c>([SELECT Id, NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c 
                                                    FROM NE__Catalog_Item__c
                                                    WHERE Id IN: orderItemProduct.values()]);
        System.debug('catalogItemWithProduct --> '+ catalogItemWithProduct);
        for(NE__Catalog_Item__c catItem : catalogItemWithProduct.values()){
            productList.add(catItem.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c);
        }                                            
        Map<String, Boolean> mapConfItemReal = XC_UTIL_ConfigurationItem.getMapRealProducts(productList);
        System.debug('@@@ mapConfItemReal -->'+ mapConfItemReal);                                            
        for(Id newConfItemId: orderItemProduct.keySet()){
            String product = '';
            if(orderItemProduct.containsKey(newConfItemId) && catalogItemWithProduct.containsKey(orderItemProduct.get(newConfItemId))){
                String catalogId = orderItemProduct.get(newConfItemId);
                product = catalogItemWithProduct.get(catalogId).NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c;
            }
            if(mapConfItemReal.containsKey(product) && mapConfItemReal.get(product)){  // FIX SS 28/03/2019
                System.debug('@@@ product -->' + product);
                NE__OrderItem__c ordItem = mapNew.get(newConfItemId);
                ordItem.XC_IsAProduct__c = true;
            }
        }
    } */

}