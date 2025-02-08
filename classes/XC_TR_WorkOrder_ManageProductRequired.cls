/**
* @author Roberta Porrega - roberta.porrega@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/09/2019
* @description XC_TR_WorkOrder_ManageProductRequired - Class to manage product required
*/

public without sharing class XC_TR_WorkOrder_ManageProductRequired {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_ManageProductRequired');
     
    /** 
    * @description Method to create product required linked to Work Orders in input
    * @param listNew - List<WorkOrder>
    */ 
    public static void createProductRequired(List<WorkOrder> listNew) { 
        List<WorkOrder> listWorkOrderToManage = new List<WorkOrder>();
        List<String> listLEWorkOrderToManage = new List<String>();
        for(WorkOrder wo : listNew) { 
            if(checkWorkTypeCategory(wo.XC_WorkTypeCategory__c)) {
                listWorkOrderToManage.add(wo);
                if(!String.isBlank(wo.XC_LegalEntity__c)){
                    listLEWorkOrderToManage.add(wo.XC_LegalEntity__c);
                }
            } 
        }
        if(listWorkOrderToManage.isEmpty()) {
            return;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWorkOrderToManage -> ' + listWorkOrderToManage);

        List<ProductRequired> prodReqList = new List<ProductRequired>(); 
        Map<Id, List<String>> mapWOCommProdListCatalogItem = new Map<Id, List<String>>();
        Map<String, Decimal> mapCatalogItemQuantity = new Map<String, Decimal>(); 

        List<Id> listWorkOrderIds = XC_UTIL_Sobject.getIds(listWorkOrderToManage);
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id, XC_WorkTypeCategory__c,XC_AssignedPartner__c, Asset.Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__CatalogItem__c, 
                    XC_Configuration_Item__r.XC_Product_Type__c, XC_Configuration_Item__r.XC_Product_Subtype__c, XC_Configuration_Item__r.NE__OrderId__c,
                    XC_Configuration_Item__r.NE__Qty__c, Asset.XC_BillingModel__c,
                    Asset.XC_CMCostCenter__c, Asset.XC_WBE__c
            FROM WorkOrder 
            WHERE Id IN: listWorkOrderIds
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ List WorkOrder for createProductRequired -> ' + listWorkOrder);

        List<Id> listConfItemPhotovoltaicId = new List<Id>();
        List<WorkOrder> listWoTechProd = new List<WorkOrder>();
        List<WorkOrder> listWoNotTechProd = new List<WorkOrder>(); 
        for(WorkOrder wo : listWorkOrder){ 
            if(wo.XC_Configuration_Item__r.NE__CatalogItem__c != null){        
                if(!mapWOCommProdListCatalogItem.containsKey(wo.Id)){
                    mapWOCommProdListCatalogItem.put(wo.Id, new List<String>());
                }    
                mapWOCommProdListCatalogItem.get(wo.Id).add(wo.XC_Configuration_Item__r.NE__CatalogItem__c); 
                // Generally (1-WO -> 1-CatalogItem) -> List is used to manage Photovoltaic
                mapCatalogItemQuantity.put(wo.XC_Configuration_Item__r.NE__CatalogItem__c, wo.XC_Configuration_Item__r.NE__Qty__c);
            }
            if(wo.XC_Configuration_Item__r.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && wo.XC_Configuration_Item__r.XC_Product_Subtype__c == Label.XC_CL_Subtype_Photovoltaic) {
                listConfItemPhotovoltaicId.add(wo.XC_Configuration_Item__c);
            }
            if(wo.XC_Configuration_Item__r.XC_Product_Type__c == Label.XC_CL_Technical && wo.XC_Configuration_Item__r.XC_Product_Subtype__c == Label.XC_CL_ProductSubTypeValue) {
                listWoTechProd.add(wo); 
            } else {
                listWoNotTechProd.add(wo);
            } 
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapWOCommProdListCatalogItem -> ' + mapWOCommProdListCatalogItem);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapCatalogItemQuantity -> ' + mapCatalogItemQuantity);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listConfItemPhotovoltaicId -> ' + listConfItemPhotovoltaicId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWoTechProd -> ' + listWoTechProd);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listWoNotTechProd -> ' + listWoNotTechProd);

        if(!listWoNotTechProd.isEmpty()){
            if(!listConfItemPhotovoltaicId.isEmpty()){
                Map<Id, NE__OrderItem__c> mapConfItemPhotovoltaic = new Map<Id, NE__OrderItem__c>([
                    SELECT Id, 
                        (SELECT Id, NE__Qty__c, NE__CatalogItem__c
                        FROM NE__Parent_Order_Item__r
                        WHERE   (XC_Product_Type__c = :Label.XC_CL_Technical AND XC_Product_Subtype__c = :Label.XC_CL_PVStructure)
                                OR (XC_Product_Type__c = :Label.XC_CL_ProductTypeEquipment AND XC_Product_Subtype__c = 'Inverter')
                                OR (XC_Product_Type__c = :Label.XC_CL_ProductTypeEquipment AND XC_Product_Subtype__c = :Label.XC_CL_Subtype_Photovoltaic))
                    FROM NE__OrderItem__c
                    WHERE Id IN:listConfItemPhotovoltaicId]
                );
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapConfItemPhotovoltaic -> ' + mapConfItemPhotovoltaic);
                for(WorkOrder wo : listWoNotTechProd){
                    if(wo.XC_Configuration_Item__r.XC_Product_Type__c == Label.XC_CL_ProductTypeEquipment && wo.XC_Configuration_Item__r.XC_Product_Subtype__c == Label.XC_CL_Subtype_Photovoltaic){
                        if(mapConfItemPhotovoltaic.containsKey(wo.XC_Configuration_Item__c)){ 
                            NE__OrderItem__c parentOi = mapConfItemPhotovoltaic.get(wo.XC_Configuration_Item__c);
                            for(NE__OrderItem__c childOi : parentOi.NE__Parent_Order_Item__r){
                                if(!mapWOCommProdListCatalogItem.containsKey(wo.Id)){
                                    mapWOCommProdListCatalogItem.put(wo.Id, new List<String>());
                                }
                                mapWOCommProdListCatalogItem.get(wo.Id).add(childOi.NE__CatalogItem__c);
                                mapCatalogItemQuantity.put(childOi.NE__CatalogItem__c, childOi.NE__Qty__c); 
                            } 
                        }
                    }
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapCatalogItemQuantity -> ' + mapCatalogItemQuantity);
            }

            List<String> listAllCatalogItem = new List<String>();
            for(Id woId : mapWOCommProdListCatalogItem.keySet()){
                listAllCatalogItem.addAll(mapWOCommProdListCatalogItem.get(woId));
            }
            Map<String, Map<String, Decimal>> mapCommercialListTechnicalProduct = getMapCommercialListTechnicalProduct(listAllCatalogItem, listLEWorkOrderToManage);      
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapCommercialListTechnicalProduct -> ' + mapCommercialListTechnicalProduct);
            List<String> listTechProdId = new List<String>();
            for(String commId : mapCommercialListTechnicalProduct.keySet()){
                listTechProdId.addAll(mapCommercialListTechnicalProduct.get(commId).keySet());
            } 
            Map<Id,Product2> productMap = new Map<Id, Product2> ([SELECT Id FROM Product2 WHERE Id IN :listTechProdId]);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ productMap -> ' + productMap);
            if(productMap.isEmpty()){
                return;
            }  
            
            for(WorkOrder wo : listWoNotTechProd){
                List<String> catalogItemIdList = mapWOCommProdListCatalogItem.get(wo.Id);
                for(String catalogItem : catalogItemIdList){
                    if(mapCommercialListTechnicalProduct.containskey(catalogItem)){
                        Map<String, Decimal> techProductIdList = mapCommercialListTechnicalProduct.get(catalogItem);
                        prodReqList.addAll(createProductRequired(wo, techProductIdList, mapCatalogItemQuantity.get(catalogItem)));                    
                    }
                }
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ prodReqList -> ' + prodReqList);
        }

        if(!listWoTechProd.isEmpty()){
            List<Id> listConfId = new List<Id>();
            List<String> listAssetTechProd = XC_UTIL_Sobject.getListFieldValues(listWoTechProd, 'AssetId');


            for(WorkOrder wo : listWoTechProd){
                if(wo.XC_Configuration_Item__r.NE__OrderId__c != null){
                    listConfId.add(wo.XC_Configuration_Item__r.NE__OrderId__c);
                }
            }     
            Map<Id, NE__OrderItem__c> mapOI = new Map<Id, NE__OrderItem__c>([
                SELECT Id, NE__Qty__c
                FROM NE__OrderItem__c
                WHERE NE__OrderId__c IN: listConfId 
                AND XC_Product_Type__c =: Label.XC_CL_Technical 
                AND XC_Product_Subtype__c =: Label.XC_CL_ProductSubTypeValue
                AND XC_NeedProvisioning__c = false
            ]);
            Map<Id, List<Asset>> mapConfIdListAsset = new Map<Id, List<Asset>>();
            if(!mapOI.isEmpty()){
                List<Asset> listAsset = new List<Asset>([
                    SELECT Id, NE__Order_Config__c, XC_Configuration_Item__c, XC_BillingModel__c, XC_Wbe__c, XC_CMCostCenter__c  
                    FROM Asset
                    WHERE XC_Configuration_Item__c IN: mapOI.keySet()
                ]); 
                for(Asset a : listAsset ){
                    if(!mapConfIdListAsset.containsKey(a.NE__Order_Config__c)){
                        mapConfIdListAsset.put(a.NE__Order_Config__c, new List<Asset>());
                    }
                    mapConfIdListAsset.get(a.NE__Order_Config__c).add(a);
                    listAssetTechProd.add(a.Id);
                }   
            }
        
        
            List<NE__AssetItemAttribute__c> listAssetItemAttr = new List<NE__AssetItemAttribute__c>([
                SELECT Id,NE__Value__c,NE__Asset__c                
                FROM NE__AssetItemAttribute__c 
                WHERE   XC_DeveloperName__c = 'Referencia' AND NE__Asset__r.XC_Product_Type__c = 'Technical'
                        AND NE__Asset__r.XC_Product_Subtype__c = 'Product' AND NE__Asset__c IN: listAssetTechProd
            ]);

            Map<Id, List<String>> mapAssetIdListProductCodes = new Map<Id, List<String>>();
            List<String> listProdCodes = XC_UTIL_Sobject.getListFieldValues(listAssetItemAttr, 'NE__Value__c');
            for(NE__AssetItemAttribute__c attr : listAssetItemAttr){
                if(!mapAssetIdListProductCodes.containsKey(attr.NE__Asset__c)){
                    mapAssetIdListProductCodes.put(attr.NE__Asset__c, new List<String>());
                }
                mapAssetIdListProductCodes.get(attr.NE__Asset__c).add(attr.NE__Value__c);
            }  

            List<Product2> listProduct2 = new List<Product2>([ 
                SELECT Id, ProductCode, giic_SerialControlled__c 
                FROM Product2
                WHERE ProductCode IN : listProdCodes AND giic_LegalEntity__c = :listNew[0].XC_LegalEntity__c
            ]);
            Map<String, Product2> mapProductCodeProduct = new Map<String, Product2>(); 
            for(Product2 p : listProduct2){
                mapProductCodeProduct.put(p.ProductCode, p);
            }
 
            for(WorkOrder wo : listWoTechProd){
                Id assetId = wo.assetId;
                if(assetId != null && mapAssetIdListProductCodes.containsKey(assetId)){
                    List<String> listProductCode = mapAssetIdListProductCodes.get(assetId);
                    for(String code : listProductCode){
                        if(mapProductCodeProduct.containsKey(code)){
                            Product2 product = mapProductCodeProduct.get(code); 
                            ProductRequired prodReq = new ProductRequired();       
                            prodReq.ParentRecordId = wo.Id;
                            prodReq.Product2Id = product.Id;
                            prodReq.QuantityRequired = wo.XC_Configuration_Item__r.NE__Qty__c; 
                            if(wo.AssetId != null && wo.Asset.XC_BillingModel__c != null && wo.Asset.XC_BillingModel__c.contains('renting') ){
                                prodReq.XC_OwnedByEnelX__c = true;
                            } 
                            prodReq.XC_Mode__c = getProductRequiredMode(wo.XC_WorkTypeCategory__c);  
                            prodReq.XC_SerialControlled__c = product.giic_SerialControlled__c;
                            prodReq.XC_Asset__c = wo.Asset.Id;
                            prodReq.XC_Concat_AssetId__c = wo.Asset.Id;
                            prodReq.XC_ConcatenatedWBE__c = wo.Asset.XC_WBE__c; 
                            prodReq.XC_ConcatenatedCostCenter__c = wo.Asset.XC_CMCostCenter__c;  
                            prodReqList.add(prodReq); 
                        }
                    }
                }
                if(mapConfIdListAsset.containsKey(wo.XC_Configuration_Item__r.NE__OrderId__c)){
                    List<Asset> listAsset = mapConfIdListAsset.get(wo.XC_Configuration_Item__r.NE__OrderId__c);
                    for(Asset a : listAsset){
                        if(a.Id != null && mapAssetIdListProductCodes.containsKey(a.Id)){
                            List<String> listProductCode = mapAssetIdListProductCodes.get(a.Id);
                            for(String code : listProductCode){
                                if(mapProductCodeProduct.containsKey(code)){
                                    Product2 product = mapProductCodeProduct.get(code); 
                                    ProductRequired prodReq = new ProductRequired();       
                                    prodReq.ParentRecordId = wo.Id;
                                    prodReq.Product2Id = product.Id;
                                    prodReq.QuantityRequired = mapOI.get(a.XC_Configuration_Item__c).NE__Qty__c; 
                                    if(a.Id != null && a.XC_BillingModel__c.contains('renting') ){
                                        prodReq.XC_OwnedByEnelX__c = true;
                                    } 
                                    prodReq.XC_Mode__c = getProductRequiredMode(wo.XC_WorkTypeCategory__c);  
                                    prodReq.XC_SerialControlled__c = product.giic_SerialControlled__c;
                                    prodReq.XC_Asset__c = a.Id;
                                    prodReq.XC_Concat_AssetId__c = a.Id;
                                    prodReq.XC_ConcatenatedWBE__c = a.XC_WBE__c; 
                                    prodReq.XC_ConcatenatedCostCenter__c = a.XC_CMCostCenter__c;  
                                    prodReqList.add(prodReq); 
                                }
                            }
                        }
                    }
                }
                
            }
        }  
        List<ProductRequired> listMerged = mergeProductRequired(prodReqList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ prodReqList -> ' + prodReqList);
        XC_UTIL_Sobject.insertListRecords(listMerged);
    }

    /** 
    * @description Method to merge Products Required
    * @date Creation 02/12/2020
    * @param prodReqList - List<ProductRequired>
    * @return List<ProductRequired> - Merged list
    */ 
    public static List<ProductRequired> mergeProductRequired(List<ProductRequired> prodReqList) {
        List<ProductRequired> listMerged = new List<ProductRequired>();

        // Create map WOId+ProdId -> List Product Required:
        Map<String, List<ProductRequired>> mapProdReq = new Map<String, List<ProductRequired>>();
        for(ProductRequired pr : prodReqList) {
            String keyProd = String.valueOf(pr.ParentRecordId)+String.valueOf(pr.Product2Id);
            if(!mapProdReq.containsKey(keyProd)) {
                mapProdReq.put(keyProd, new List<ProductRequired>());
            }
            mapProdReq.get(keyProd).add(pr);
        }

        // Merge product required for key:
        for(String key : mapProdReq.keySet()) {
            if(mapProdReq.get(key).size() == 1) {
                listMerged.addAll(mapProdReq.get(key));
            } else if(mapProdReq.get(key).size() > 1) {
                ProductRequired newPr = new ProductRequired();
                newPr.ParentRecordId = mapProdReq.get(key)[0].ParentRecordId;
                newPr.Product2Id = mapProdReq.get(key)[0].Product2Id;
                newPr.XC_OwnedByEnelX__c = mapProdReq.get(key)[0].XC_OwnedByEnelX__c;
                newPr.XC_Mode__c = mapProdReq.get(key)[0].XC_Mode__c;
                newPr.XC_SerialControlled__c = mapProdReq.get(key)[0].XC_SerialControlled__c;
                newPr.QuantityRequired = 0;
                List<String> listAssetIds = new List<String>();
                List<String> listWBEs = new List<String>();
                List<String> listCostCenter = new List<String>();
                for(ProductRequired oldPr : mapProdReq.get(key)) {
                    newPr.QuantityRequired += oldPr.QuantityRequired; 
                    listAssetIds.add(oldPr.XC_Concat_AssetId__c);
                    listWBEs.add(oldPr.XC_ConcatenatedWBE__c);
                    listCostCenter.add(oldPr.XC_ConcatenatedCostCenter__c); 
                }
                newPr.XC_Concat_AssetId__c = String.join(listAssetIds, ';');
                newPr.XC_Concat_AssetId__c = newPr.XC_Concat_AssetId__c.replace(';;', ';');
                newPr.XC_ConcatenatedWBE__c = String.join(listWBEs, ';');
                newPr.XC_ConcatenatedCostCenter__c = String.join(listCostCenter, ';');
                listMerged.add(newPr);
            }
        }
        return listMerged;
    }

    /** 
    * @description Method to check Work Type Category
    * @date Creation 23/09/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param workTypeCategory - String
    * @return Boolean
    */ 
    private static Boolean checkWorkTypeCategory(String workTypeCategory) {
        return workTypeCategory == Label.XC_CL_WorkType_DeliveryInstallation || workTypeCategory == Label.XC_CL_WorkType_Return ||  workTypeCategory ==  Label.XC_CL_WorkType_Delivery;
    }

    /**
    * @description Method to calculate Serial Controlled
    * @param product2 - Set<String>
    * @return Map<String, Product2>
    */  
    @testVisible
    private static  Map<String, Product2> getSerialController(Set<String> product2){
        Map<String, Product2> mapSerialControlled = new Map<String, Product2>();
        Map<Id, Product2> prGloviaMap = new Map<Id, Product2>([
                SELECT Id, giic_SerialControlled__c, giic_ProcurementType__c
                FROM Product2 
                WHERE Id IN : product2]
        );  
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ prGloviaMap -> ' + prGloviaMap);
         
        for(Product2 pr : prGloviaMap.values()){
            mapSerialControlled.put(pr.Id, pr);
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapSerialControlled -> ' + mapSerialControlled);
        return mapSerialControlled;
    } 

    /**
    * @description Method to calculate the list of Product Required to insert
    * @param wo - WorkOrder
    * @param productTechMap - Map<String, Decimal>
    * @param quantity - Decimal
    * @return List<ProductRequired>
    */
    @testVisible
    private static List<ProductRequired> createProductRequired(WorkOrder wo, Map<String, Decimal> productTechMap, Decimal quantity){
        List<ProductRequired> prodReqList = new List<ProductRequired>();
        Map<String, Product2> mapTechnicalSerialControlled =  getSerialController(productTechMap.keySet());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapTechnicalSerialControlled -> ' + mapTechnicalSerialControlled);

        for(String prodTech : productTechMap.keySet()){
            ProductRequired prodReq = new ProductRequired();       
            prodReq.ParentRecordId = wo.Id;
            prodReq.Product2Id = prodTech;
            prodReq.QuantityRequired = (productTechMap.get(prodTech) != 0) ? quantity * productTechMap.get(prodTech)  : quantity;
            prodReq.XC_ProcurementType__c = mapTechnicalSerialControlled.get(prodTech).giic_ProcurementType__c;
            if(wo.AssetId != null && wo.Asset.XC_BillingModel__c != null && wo.Asset.XC_BillingModel__c.contains('renting') ){
                prodReq.XC_OwnedByEnelX__c = true;
            }
            
            prodReq.XC_Mode__c = getProductRequiredMode(wo.XC_WorkTypeCategory__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For prodReq -> ' + prodReq);
          
            if(mapTechnicalSerialControlled.containsKey(prodTech)){
                prodReq.XC_SerialControlled__c = mapTechnicalSerialControlled.get(prodTech).giic_SerialControlled__c;
            }
            prodReq.XC_Asset__c = wo.Asset.Id;
            prodReq.XC_Concat_AssetId__c = wo.Asset.Id;
            prodReq.XC_ConcatenatedWBE__c = wo.Asset.XC_WBE__c; 
            prodReq.XC_ConcatenatedCostCenter__c = wo.Asset.XC_CMCostCenter__c;  
            prodReqList.add(prodReq);
        } 
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ prodReqList -> ' + prodReqList);
        return prodReqList;
    }

    /** 
    * @description Method to calculate PR's Mode
    * @param workTypeCategory - String
    * @return String
    */ 
    private static String getProductRequiredMode(String workTypeCategory) {
        String mode;
        if(workTypeCategory == Label.XC_CL_WorkType_DeliveryInstallation || workTypeCategory ==  Label.XC_CL_WorkType_Delivery  ){
            mode = 'Add';
        } else if(workTypeCategory == Label.XC_CL_WorkType_Return){
            mode = 'Remove';
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Mode ' + mode + ' for worktype ' + workTypeCategory);
        return mode;
    }

    /** 
    * @description Method to calculate a list of Technical Product for Commercial Products in input
    * @param commercialProduct - List<String>
    * @return Map<String, Map<String, Decimal>>
    */
    public static Map<String, Map<String, Decimal>> getMapCommercialListTechnicalProduct(List<String> commercialProduct, List<String> listLEWorkOrderToManage) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For product -> ' + commercialProduct);
        Map<String, Map<String, Decimal>> mapCommercialToTechnical = new Map<String, Map<String, Decimal>>();
        Map<Id, B2WExtCat__External_Catalog_Association__c>  mapProdExternalCatalog = new Map<Id, B2WExtCat__External_Catalog_Association__c>(
            [SELECT Id,  Name, XC_TechnicalProduct__c,XC_Quantity__c, B2WExtCat__Commercial_Product__r.XC_LIC_Product_Name__c, B2WExtCat__Commercial_Product__c , B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c 
            FROM B2WExtCat__External_Catalog_Association__c  
            WHERE B2WExtCat__Commercial_Catalog_Item__c IN :commercialProduct AND XC_TechnicalProduct__c != null AND XC_TechnicalProduct__r.giic_LegalEntity__c IN: listLEWorkOrderToManage
                  //WHERE B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c IN :commercialProduct
                  //OR B2WExtCat__Commercial_Product__c IN :commercialProduct ]);
        ]);
        List<String> techProd = new List<String>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapProdExternalCatalog -> ' + mapProdExternalCatalog);
        for(B2WExtCat__External_Catalog_Association__c extCat : mapProdExternalCatalog.values()){ 
            String catalogItemId = extCat.B2WExtCat__Commercial_Catalog_Item__c;//;(extCat.B2WExtCat__Commercial_Product__c !=null) ? extCat.B2WExtCat__Commercial_Product__c : extCat.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__c;
            if(!mapCommercialToTechnical.containsKey(catalogItemId)){
                mapCommercialToTechnical.put(catalogItemId, new Map<String, Decimal>());
            }
            Decimal quantity = (extCat.XC_Quantity__c !=null) ? extCat.XC_Quantity__c : 1.0;
            mapCommercialToTechnical.get(catalogItemId).put(extCat.XC_TechnicalProduct__c, quantity);  
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ mapCommercialToTechnical -> ' + mapCommercialToTechnical);
        return mapCommercialToTechnical;
    }
    
}