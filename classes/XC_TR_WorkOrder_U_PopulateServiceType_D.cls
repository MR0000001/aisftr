/**
 * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
 * @date: 16-05-2019
 * @description Util class for XC_TR_WorkOrder_U_PopulateServiceType
*/  

public without sharing class XC_TR_WorkOrder_U_PopulateServiceType_D {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_PopulateServiceType');
    
    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to retrieve ServiceType Metadata based on Information on Asset
    * @param listWorkOrder - List<WorkOrder>   
    * @param mapAsset - Map<Id,Asset>
    * @return Map<Id, XC_CM_WorkOrderServiceType__mdt> 
    */

    public static Map<Id, XC_CM_WorkOrderServiceType__mdt> retrieveCustomMetadatabyAsset(List<WorkOrder> listWorkOrder, Map<Id,Asset> mapAsset){
        Set<String> workTypeNames = new Set<String>(); 
        Set<String> productNames = new Set<String>();
        Set<String> subTypeNames = new Set<String>();
        for(WorkOrder wo : listWorkOrder){
            workTypeNames.add(wo.XC_WorkTypeCategory__c);
            Asset a  = mapAsset.get(wo.AssetId);
            if(a != null && a.NE__ProdId__c != null){
                productNames.add(a.NE__ProdId__r.XC_LIC_Product_Name__c);
                subTypeNames.add(a.NE__ProdId__r.XC_Product_Subtype__c); 
            }
        }  
        if(productNames.isEmpty() && subTypeNames.isEmpty()) {
            return new Map<Id, XC_CM_WorkOrderServiceType__mdt>();
        }
        productNames.add('');
        subTypeNames.add('');
        Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes = new Map<Id, XC_CM_WorkOrderServiceType__mdt>([
            SELECT Id, XC_ProductName__c, XC_PositionOfMaintenanceWorkOrder__c, XC_WorkType__c, XC_ServiceType__c, XC_SubType__c, XC_Bundle__c, XC_ProductCategoryOfInterest__c
            FROM XC_CM_WorkOrderServiceType__mdt
            WHERE XC_WorkType__c IN: workTypeNames
            AND XC_ProductName__c IN: productNames 
            AND XC_SubType__c IN: subTypeNames
        ]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### mapServiceTypes' + mapServiceTypes); 
        return mapServiceTypes;
    }

        /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to retrieve ServiceType Metadata based on Information on Asset
    * @param listWorkOrder - List<WorkOrder>  
    * @param mapCase - Map<Id,Case>
    * @return Map<Id, XC_CM_WorkOrderServiceType__mdt> 
    */

    public static Map<Id, XC_CM_WorkOrderServiceType__mdt> retrieveCustomMetadatabyCase(List<WorkOrder> listWorkOrder, Map<Id,Case> mapCase){
        Set<String> workTypeNames = new Set<String>(); 
        Set<String> productNames = new Set<String>();
        Set<String> subTypeNames = new Set<String>();
        for(WorkOrder wo : listWorkOrder){
            if (wo.CaseId != null){
                workTypeNames.add(wo.XC_WorkTypeCategory__c);
                Case c  = mapCase.get(wo.CaseId);
                if(c.Asset.NE__ProdId__c != null){
                    productNames.add(c.Asset.NE__ProdId__r.XC_LIC_Product_Name__c);
                    subTypeNames.add(c.Asset.NE__ProdId__r.XC_Product_Subtype__c); 
                }
            }
            
        }
        System.debug('@@@productNames-->'+productNames);  
        productNames.add('');
        subTypeNames.add('');
        Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes = new Map<Id, XC_CM_WorkOrderServiceType__mdt>([
            SELECT Id, XC_ProductName__c, XC_PositionOfMaintenanceWorkOrder__c, XC_WorkType__c, XC_ServiceType__c, XC_SubType__c, XC_Bundle__c, XC_ProductCategoryOfInterest__c
            FROM XC_CM_WorkOrderServiceType__mdt
            WHERE XC_WorkType__c IN: workTypeNames
            AND XC_ProductName__c IN: productNames 
            AND XC_SubType__c IN: subTypeNames
        ]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### mapServiceTypes' + mapServiceTypes); 
        return mapServiceTypes;
    }

    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to retrieve ServiceType Metadata based on Information on Asset
    * @param listWorkOrder - List<WorkOrder>  
    * @param mapConfItem - Map<Id,NE__OrderItem__c>
    * @return Map<Id, XC_CM_WorkOrderServiceType__mdt> 
    */

    public static Map<Id, XC_CM_WorkOrderServiceType__mdt> retrieveCustomMetadataByConfItem(List<WorkOrder> listWorkOrder, Map<Id,NE__OrderItem__c> mapConfItem){
        Set<String> workTypeNames = new Set<String>(); 
        Set<String> productNames = new Set<String>();
        Set<String> subTypeNames = new Set<String>();
        for(WorkOrder wo : listWorkOrder){
            workTypeNames.add(wo.XC_WorkTypeCategory__c);
            NE__OrderItem__c confItem  = mapConfItem.get(wo.XC_Configuration_Item__c);
            if(confItem.NE__ProdId__c != null){
                productNames.add(confItem.NE__ProdId__r.XC_LIC_Product_Name__c);
                subTypeNames.add(confItem.NE__ProdId__r.XC_Product_Subtype__c);
            }
        } 
        productNames.add('');
        subTypeNames.add('');
        Map<Id, XC_CM_WorkOrderServiceType__mdt> mapServiceTypes = new Map<Id, XC_CM_WorkOrderServiceType__mdt>([
            SELECT Id, XC_ProductName__c, XC_WorkType__c, XC_ServiceType__c, XC_SubType__c, XC_Bundle__c, XC_ProductCategoryOfInterest__c
            FROM XC_CM_WorkOrderServiceType__mdt
            WHERE XC_WorkType__c IN: workTypeNames
            AND XC_ProductName__c IN: productNames 
            AND XC_SubType__c IN: subTypeNames
        ]); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### mapServiceTypes' + mapServiceTypes); 
        return mapServiceTypes;
    }

    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to retrieve Asset Map
    * @param listWorkOrder - List<WorkOrder>   
    * @return Map<Id, Asset> 
    */

    public static Map<Id,Asset> getMapAsset(List<WorkOrder> listWorkOrder){
        List<String> listAssetIds = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'AssetId');
        Map<Id,Asset> mapAsset = new Map<Id,Asset>([
            SELECT Id, NE__ProdId__c, NE__ProdId__r.XC_LIC_Product_Name__c, NE__ProdId__r.XC_Product_Subtype__c, NE__Bundle_Configuration__c
            FROM Asset
            WHERE Id IN: listAssetIds
        ]);
        return mapAsset;
    }

    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to retrieve Asset Map
    * @param listWorkOrder - List<WorkOrder>   
    * @return Map<Id, Asset> 
    */

    public static Map<Id,NE__OrderItem__c> getMapConfItem(List<WorkOrder> listWorkOrder){
        List<String> listConfItemIds = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_Configuration_Item__c');
        Map<Id,NE__OrderItem__c> mapConfItem = new Map<Id,NE__OrderItem__c>([
            SELECT Id, NE__ProdId__c, NE__ProdId__r.XC_LIC_Product_Name__c, NE__ProdId__r.XC_Product_Subtype__c, NE__Bundle_Configuration__c
            FROM NE__OrderItem__c
            WHERE Id IN: listConfItemIds
        ]);
        return mapConfItem;
    }

    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to retrieve NE__OrderItem__c Map
    * @param listWorkOrder - List<WorkOrder>   
    * @return Map<Id, NE__OrderItem__c> 
    */

    public static Map<Id, NE__OrderItem__c> getMapConfigurationItem(List<WorkOrder> listWorkOrder){
        List<String> listConfigurationItemIds = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_Configuration_Item__c');
        Map<Id,NE__OrderItem__c> mapConfigurationItem = new Map<Id,NE__OrderItem__c>([
            SELECT Id, NE__ProdId__r.XC_LIC_Product_Name__c, NE__ProdId__r.XC_Product_Subtype__c, NE__Bundle_Configuration__c
            FROM NE__OrderItem__c
            WHERE Id IN: listConfigurationItemIds
        ]);
        return mapConfigurationItem;
    }

    /**
    * @author: Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
    * @description Method to retrieve Case Map
    * @param listWorkOrder - List<WorkOrder>   
    * @return Map<Id, Case> 
    */

    public static Map<Id,Case> getMapCase(List<WorkOrder> listWorkOrder){
        List<String> listCaseIds = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'CaseId');
        Map<Id, Case> mapCase = new Map<Id,Case>([
            SELECT Id, Asset.NE__ProdId__c, Asset.NE__ProdId__r.XC_LIC_Product_Name__c, Asset.NE__ProdId__r.XC_Product_Subtype__c, Asset.NE__Bundle_Configuration__c
            FROM Case
            WHERE Id IN: listCaseIds
        ]);
        return mapCase;
    }
}