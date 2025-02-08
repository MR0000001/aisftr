/**
 * @Author Andrea Bravaccino - andrea.bravaccino@nttdata.com
 * @date 29/08/2019
 * @description Set ProductSubtype on work order
**/

public without sharing class XC_TR_WorkOrder_U_PopulateWorkType_U {
    
    /**
    * @description setProductSubtype
    * @author Roberta Cossiga - rcossiga@deloitte.it | 29/8/2019
    * @param listNew List<WorkOrder> 
    */
    public static void setProductSubtypeAndLegalEntity (List<WorkOrder> listNew){
        for(WorkOrder wo : listNew){
            if(wo.XC_Segment__c == 'B2C'){
                populateProdCatOfInterestText(listNew);
            }
        }
        List<WorkOrder> woListWithProdOfInterest = new List<WorkOrder>();
        List<WorkOrder> woListWithAsset = new List<WorkOrder>();
        List<WorkOrder> woListWithConfItem = new List<WorkOrder>();
        List<WorkOrder> woListWithConf = new List<WorkOrder>();
        for(WorkOrder wo : listNew){
            if(!String.isEmpty(wo.XC_ProdCatOfInterestText__c)){
                woListWithProdOfInterest.add(wo);
            } else if (!String.isEmpty(wo.AssetId)){
               woListWithAsset.add(wo);
            } else if (!String.isEmpty(wo.XC_Configuration_Item__c)){
                woListWithConfItem.add(wo);
            } else if(!String.isEmpty(wo.XC_Configuration__c)) {
                woListWithConf.add(wo);
            }
        }
        if(!woListWithProdOfInterest.isEmpty()){
            manageCommercialVisit(woListWithProdOfInterest);
            populateRecordTypeId(woListWithProdOfInterest);
        }
        if(!woListWithAsset.isEmpty()){
            manageByAsset(woListWithAsset);
            populateRecordTypeId(woListWithAsset);
        }
        if(!woListWithConfItem.isEmpty()){
            manageByConfItem(woListWithConfItem);
            populateRecordTypeId(woListWithConfItem);
        }
        if(!woListWithConf.isEmpty()){
            manageByConf(woListWithConf);
            populateRecordTypeId(woListWithConf);
            populateWorkTypeCategoryOnItalianSiteInspection(woListWithConf);
        }
    }

    /**
    * @description 
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 26/6/2020 
    * @param woListWithConf 
    **/
    private static void populateWorkTypeCategoryOnItalianSiteInspection(List<WorkOrder> woListWithConf){
        Map<String, WorkOrder> configuratioIdWOMap = new Map<String, WorkOrder>();
        Map<String, String> configurationIdSubtype = new Map<String, String>();
        for(WorkOrder wo : woListWithConf){
            if((wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia || wo.XC_LegalEntity__c == Label.XC_CL_EndesaX || 
                wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain || wo.XC_LegalEntity__c == 'EnelXMobilityChile' || wo.XC_LegalEntity__c == 'EnelX' ||  wo.XC_LegalEntity__c == 'Codensa') && 
                 (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SalesSiteInspection)){
                configuratioIdWOMap.put(wo.XC_Configuration__c, wo);
            }
        }
        if(!configuratioIdWOMap.isEmpty()){
            List<NE__OrderItem__c> orderItemList = new List<NE__OrderItem__c>([SELECT Id, XC_Product_Subtype__c,NE__OrderId__c  
                                                                                FROM NE__OrderItem__c 
                                                                                WHERE NE__OrderId__c IN: configuratioIdWOMap.keySet() 
                                                                                AND XC_SiteInspectionRequired__c =: true
                                                                                LIMIT 1]);
            for(NE__OrderItem__c oi : orderItemList){
                configurationIdSubtype.put(oi.NE__OrderId__c, oi.XC_Product_Subtype__c);
            }
        }
        for(WorkOrder wo : woListWithConf){
            if(!configurationIdSubtype.isEmpty() && configurationIdSubtype.containsKey(wo.XC_Configuration__c) && !String.isBlank(configurationIdSubtype.get(wo.XC_Configuration__c))){
                wo.XC_ProductSubType__c = configurationIdSubtype.get(wo.XC_Configuration__c);
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 16/01/2020
     * @description Manage Work Order linked to Configuration
     * @param woListWithConf - List<WorkOrder> 
     */
    private static void manageByConf(List<WorkOrder>  woListWithConf) {
        List<String> confIds = new  List<String>(); //XC_UTIL_Sobject.getListFieldValues(woListWithConf, 'XC_Configuration__c');   // SS 26/06/2020 Fix to avoid the query if legal entity already set in populateProdCatOfInterestText
        for(WorkOrder wo : woListWithConf){
            if(String.isEmpty(wo.XC_LegalEntity__c)){
                confIds.add(wo.XC_Configuration__c);
            }
        }
        if(!confIds.isEmpty()){
            List<NE__Order__c> listConf = new List<NE__Order__c>([
                SELECT Id, XC_LegalEntity__c 
                FROM NE__Order__c
                WHERE Id IN: confIds
            ]); 
            Map<String, String> mapConfItemIdLegalEntity = new Map<String, String>();
            for(NE__Order__c order : listConf){
                mapConfItemIdLegalEntity.put(order.Id, order.XC_LegalEntity__c);
            }
            for(WorkOrder wo : woListWithConf){
                wo.XC_LegalEntity__c = mapConfItemIdLegalEntity.get(wo.XC_Configuration__c);
            }
        }
    }

    /**
     * @description Populate ProfCatOfInterest WorkOrder
     * @param listNew - List<WorkOrder> 
     */
    private static void populateProdCatOfInterestText(List<WorkOrder> listNew){
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        List<String> leadIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Lead__c');
        List<String> opportunityIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Opportunity__c');
        if(!leadIds.isEmpty()){
            leadMap = new Map<Id, Lead>([SELECT ID, XC_ProductCategoryOfInterest__c, XC_MainLegalEntity__c FROM Lead WHERE Id IN :leadIds]);
        }
        if(!opportunityIds.isEmpty()){
            opportunityMap = new Map<Id, Opportunity>([SELECT ID, XC_ProductCategoryOfInterest__c, XC_LegalEntity__c FROM Opportunity WHERE Id IN :opportunityIds]);
        }
        
        for (WorkOrder wo : listNew) {
            System.debug('wo.XC_ProductCategoryOfInterest__c: ' + wo.XC_ProductCategoryOfInterest__c);
            if(!leadMap.isEmpty() && leadMap.containsKey(wo.XC_Lead__c)){
                wo.XC_ProdCatOfInterestText__c = leadMap.get(wo.XC_Lead__c).XC_ProductCategoryOfInterest__c;
                wo.XC_LegalEntity__c = leadMap.get(wo.XC_Lead__c).XC_MainLegalEntity__c;
            }else if(!opportunityMap.isEmpty() && opportunityMap.containsKey(wo.XC_Opportunity__c)){
                wo.XC_LegalEntity__c = opportunityMap.get(wo.XC_Opportunity__c).XC_LegalEntity__c;
                if((wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia || wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || wo.XC_LegalEntity__c == Label.XC_CL_EndesaX || wo.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain) && (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Delivery )){
                    continue;
                } else {
                    wo.XC_ProdCatOfInterestText__c = opportunityMap.get(wo.XC_Opportunity__c).XC_ProductCategoryOfInterest__c;
                }
            }
        }
    }
    
    /**
    * @description manageCommercialVisit
    * @author Roberta Cossiga - rcossiga@deloitte.it | 29/8/2019
    * @param woListWithProdOfInterest List<WorkOrder> 
    */
    private static void manageCommercialVisit (List<WorkOrder> woListWithProdOfInterest){
        List<String> productCategorieNames = XC_UTIL_Sobject.getListFieldValues(woListWithProdOfInterest, 'XC_ProdCatOfInterestText__c');  
        List<XC_ProductCategoryOfInterest__c> listProductOfInterest = new List<XC_ProductCategoryOfInterest__c>([
            SELECT Id, XC_ProductSubType__c , Name
            FROM XC_ProductCategoryOfInterest__c
            WHERE Name IN: productCategorieNames]); 
        Map<String, String> mapProductCategorySubType = new Map<String, String>();
        for(XC_ProductCategoryOfInterest__c prod : listProductOfInterest){
            mapProductCategorySubType.put(prod.Name, prod.XC_ProductSubType__c);
        }
        for(WorkOrder wo : woListWithProdOfInterest){
           wo.XC_ProductSubType__c =  mapProductCategorySubType.get(wo.XC_ProdCatOfInterestText__c);
        }
    }

    /**
    * @description manageByAsset
    * @author Roberta Cossiga - rcossiga@deloitte.it | 29/8/2019
    * @param woListWithAsset List<WorkOrder> 
    */
    private static void manageByAsset (List<WorkOrder> woListWithAsset){
        List<WorkOrder> listWoCheckCase = new List<WorkOrder>();
        List<String> assetIds = XC_UTIL_Sobject.getListFieldValues(woListWithAsset, 'AssetId');
        assetIds.addAll(XC_UTIL_Sobject.getListFieldValues(woListWithAsset, 'XC_Coverage__c'));  
        Map<Id, Asset> mapAsset = new Map<Id, Asset>([
            SELECT Id, XC_Product_Subtype__c, NE__ProdId__r.XC_Product_Subtype__c, XC_LegalEntity__c, XC_Segment__c, XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c, XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c,
                NE__CatalogItem__r.XC_TechnicalSkill__c, NE__Bundle_Configuration__c, NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_TechnicalSkill__c, NE__Root_Order_Item__r.NE__CatalogItem__r.XC_TechnicalSkill__c
            FROM Asset
            WHERE Id IN: assetIds]);
        for(WorkOrder wo : woListWithAsset){
            Asset asset = mapAsset.get(wo.assetId);
            if(String.isBlank(wo.XC_Segment__c) && String.isBlank(asset.XC_Segment__c)){
                wo.XC_Segment__c = asset.XC_Configuration_Item__r.NE__OrderId__r.XC_Segment__c;
            }
            wo.XC_LegalEntity__c = (asset.XC_LegalEntity__c != null) ? asset.XC_LegalEntity__c : asset.XC_Configuration_Item__r.NE__OrderId__r.XC_LegalEntity__c;
             
            if(wo.XC_Coverage__c != null && mapAsset.containsKey(wo.XC_Coverage__c)){
                Asset coverageAsset = mapAsset.get(wo.XC_Coverage__c);                
                wo.XC_CoverageSkill__c = coverageAsset.NE__CatalogItem__r.XC_TechnicalSkill__c;
                if(coverageAsset.NE__Bundle_Configuration__c != null){
                    wo.XC_CoverageParentSkill__c = coverageAsset.NE__Bundle_Configuration__r.NE__CatalogItem__r.XC_TechnicalSkill__c;
                } else {
                    wo.XC_CoverageParentSkill__c = coverageAsset.NE__Root_Order_Item__r.NE__CatalogItem__r.XC_TechnicalSkill__c;
                }
                wo.XC_LegalEntity__c = String.isBlank(wo.XC_LegalEntity__c) ? coverageAsset.XC_LegalEntity__c : wo.XC_LegalEntity__c;
                wo.XC_Segment__c = String.isBlank(wo.XC_Segment__c) ? coverageAsset.XC_Segment__c : wo.XC_Segment__c;
            }
            if((String.isBlank(wo.XC_LegalEntity__c) || String.isBlank(wo.XC_Segment__c)) && wo.CaseId != null){
                listWoCheckCase.add(wo);
            }
        }
        if(!listWoCheckCase.isEmpty()){
            List<String> caseIds = XC_UTIL_Sobject.getListFieldValues(woListWithAsset, 'caseId'); 
            Map<Id,Case> mapCase = new Map<Id,Case>([SELECT Id, XC_LegalEntity__c, XC_Segment__c FROM Case WHERE ID IN: caseIds]);
            for(WorkOrder wo : listWoCheckCase){
                wo.XC_LegalEntity__c = String.isBlank(wo.XC_LegalEntity__c) ? mapCase.get(wo.CaseId).XC_LegalEntity__c : wo.XC_LegalEntity__c;
                wo.XC_Segment__c = String.isBlank(wo.XC_Segment__c) ? mapCase.get(wo.CaseId).XC_Segment__c : wo.XC_Segment__c;
            }
        } 
        for(WorkOrder wo : woListWithAsset){
            Asset asset = mapAsset.get(wo.assetId);
            if(wo.XC_Segment__c == 'B2C' || asset.XC_Segment__c == 'B2C' || ((asset.XC_Segment__c == 'B2B' || asset.XC_Segment__c == 'B2G') && wo.XC_ProductSubType__c == null) ){
                wo.XC_ProductSubType__c =  String.isNotBlank(asset.XC_Product_Subtype__c) ? asset.XC_Product_Subtype__c : asset.NE__ProdId__r.XC_Product_Subtype__c;               
            }
        }
    }

    /**
    * @description manageByConfItem
    * @author Roberta Cossiga - rcossiga@deloitte.it | 29/8/2019
    * @param woListWithConfItem List<WorkOrder> 
    */
    private static void manageByConfItem(List<WorkOrder> woListWithConfItem){
        List<String> confItemIds = XC_UTIL_Sobject.getListFieldValues(woListWithConfItem, 'XC_Configuration_Item__c');  
        List<NE__OrderItem__c> listConfItem = new List<NE__OrderItem__c>([
            SELECT Id, NE__ProdId__r.XC_Product_Subtype__c, NE__OrderId__r.XC_LegalEntity__c 
            FROM NE__OrderItem__c
            WHERE Id IN: confItemIds]); 
        Map<String, String> mapConfItemIdSubType = new Map<String, String>();
        Map<String, String> mapConfItemIdLegalEntity = new Map<String, String>();
        for(NE__OrderItem__c item : listConfItem){
            mapConfItemIdSubType.put(item.Id, item.NE__ProdId__r.XC_Product_Subtype__c);
            mapConfItemIdLegalEntity.put(item.Id, item.NE__OrderId__r.XC_LegalEntity__c);
        }
        for(WorkOrder wo : woListWithConfItem){
           wo.XC_ProductSubType__c =  mapConfItemIdSubType.get(wo.XC_Configuration_Item__c);
           wo.XC_LegalEntity__c = mapConfItemIdLegalEntity.get(wo.XC_Configuration_Item__c);
        }
    }
    
    /**
    * @description populateRecordTypeId - method to populate the record type on WO
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 14/1/2020
    * @dateModification 22/04/2020 by Nicola Mariniello - nmariniello@deloitte.it
    * @param woList List<WorkOrder> 
    */    
    private static void populateRecordTypeId(List<WorkOrder> woList){
        /*List<String> legalEntityList = new List<String>();
        for(WorkOrder wo : woList){
            legalEntityList.add(wo.XC_LegalEntity__c);
        }
        List<XC_CM_LegalEntity_Configuration__mdt>  legalEntityConfigList = new List<XC_CM_LegalEntity_Configuration__mdt>(
            [SELECT Id, XC_LegalEntity__c, XC_RecordType_WorkOrder__c FROM XC_CM_LegalEntity_Configuration__mdt
            WHERE XC_LegalEntity__c IN: legalEntityList AND XC_RecordType_WorkOrder__c != '' LIMIT 1]);
        Map<String,String> mapLegalEntityRecordType = new Map<String,String>();

        for(XC_CM_LegalEntity_Configuration__mdt legalEnt : legalEntityConfigList){
            Id recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(legalEnt.XC_RecordType_WorkOrder__c).getRecordTypeId();
            mapLegalEntityRecordType.put(legalEnt.XC_LegalEntity__c, recordTypeId);
        }
        if(mapLegalEntityRecordType!= null){
            for(WorkOrder wo : woList){
                if(mapLegalEntityRecordType.get(wo.XC_LegalEntity__c) != null){
                    wo.RecordTypeId = mapLegalEntityRecordType.get(wo.XC_LegalEntity__c); 
                }        
            }
        }*/

        Set<String> legalEntitySet = XC_UTIL_Sobject.getSetIdsStringOnField(woList, 'XC_LegalEntity__c');
        Set<String> streamSet = XC_UTIL_Sobject.getSetIdsStringOnField(woList, 'XC_Segment__c'); 
        Map<String, XC_SegmentUtilities.RTConfigWrapper> recordTypesMap = XC_SegmentUtilities.getLegEntityConfig(legalEntitySet, streamSet);

        for(WorkOrder wo : woList){
            if(recordTypesMap.get(wo.XC_LegalEntity__c+wo.XC_Segment__c) != null && String.isNotBlank(recordTypesMap.get(wo.XC_LegalEntity__c+wo.XC_Segment__c).workOrderRT)) {
                wo.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get(recordTypesMap.get(wo.XC_LegalEntity__c+wo.XC_Segment__c).workOrderRT).getRecordTypeId();
            }
            if(recordTypesMap.get(wo.XC_LegalEntity__c+wo.XC_Segment__c) != null && String.isNotBlank(recordTypesMap.get(wo.XC_LegalEntity__c+wo.XC_Segment__c).legalEntityOverrideForLogistic)) {
                wo.XC_LegalEntity__c = recordTypesMap.get(wo.XC_LegalEntity__c+wo.XC_Segment__c).legalEntityOverrideForLogistic;
            }
        }
    }

}