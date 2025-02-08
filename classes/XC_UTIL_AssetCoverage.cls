/**
* @author Monica Cutillo - monica.cutillo@nttdata.com + Salvatore Agrillo - salvatore.agrillo@nttdata.com for PMD
* @date Creation  06/05/2019
* @description XC_LCC067_RelatedAssetsByAccount_U_Nodes - UTIL Class for XC_LCC067_RelatedAssetsByAccount
*/
public without sharing class XC_UTIL_AssetCoverage {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC067_RelatedAssetsByAccount');
    
    /**
    * @description this method filter the getAssetsCoverage result by subtype
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 8/1/2020 
    * @param assetIds 
    * @param subtype 
    * @return Map<Id, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> 
    **/
    public static Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getAssetsCoverageFileteredBySubtype(List<Id> assetIds, String subtype){
        Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> allAssetCoverage = getAssetsCoverage(assetIds);

        for (Id assetId : allAssetCoverage.keySet()) {
            List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> newListOfCoverages = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();

            for (XC_LCC067_RelatedAssetsByAccount_U.AssetCustom cov : allAssetCoverage.get(assetId)) {
                if(cov.productSubType == subtype){
                    newListOfCoverages.add(cov);
                }
            }
            allAssetCoverage.put(assetId, newListOfCoverages);
        }
        return allAssetCoverage;
    }


    /**
    * @description from an asset ids list, retrieve all related assets coverage lists
    * @param assetIds the asset ids list
    * @return the asset coverage mapping: equipment asset id -> coverage assets list
    */
    public static Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getAssetsCoverage(List<Id> assetIds){
        Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> result = new Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>();
        if(assetIds==null || assetIds.isEmpty()){
            return result;
        }

        List<Asset> assetsData = retrieveAssetsData(assetIds);
        List<String> accountIds = XC_UTIL_Sobject.getListFieldValues(assetsData, 'AccountId');
        Set<String> accSetIds = new Set<String>(accountIds);
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assets = XC_LCC067_RelatedAssetsByAccount.populateAssetsCustom(assetsData);
        
        //Map AccountId -> Lista Service assets
        Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> servRoots = getServiceBundleRoots(assets, accSetIds);
        //Map EquipAssetId -> Lista All Coverage assets associati
        Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> allCoverageAssetMap = getAllParentCoverage(assets, accSetIds, servRoots);
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getAssetCoverage - allCoverageAssetMap = '+ allCoverageAssetMap);
        //recupero le coperture di tutte tutte le coverage
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> allCoverageAssets = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
        for(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> coverages : allCoverageAssetMap.values()){
            allCoverageAssets.addAll(coverages);
        }
        Map<Id,Map<String,String>> productCoverage = retrieveProductForCoverage(allCoverageAssets);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getAssetCoverage - productCoverage = '+ productCoverage);
        Map<String,String> prodInfoItem;
        
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> entryResult;
        for (XC_LCC067_RelatedAssetsByAccount_U.AssetCustom eqAsset : assets) {
            entryResult = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
            if(allCoverageAssetMap.get(eqAsset.id) == null){
                continue;
            }
            for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom covAss : allCoverageAssetMap.get(eqAsset.id)){
                prodInfoItem = productCoverage.get(covAss.id);
                if (prodInfoItem==null){
                    continue;
                }
                String coveredProdType = prodInfoItem.get('Coverage Type');
                if(String.isNotBlank(coveredProdType) && (coveredProdType.toUpperCase()).contains((eqAsset.productSubType).toUpperCase())){
                    covAss.sla = prodInfoItem.get('SLA');
                    entryResult.add(covAss);
                }
            }
            result.put(eqAsset.id,entryResult);
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getAssetsCoverage - result = '+ result);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getAssetsCoverage - size   = '+ result.size());
        return result;

    }
    
    /** METODO SU ASSET SINGOLO >>> DA COMMENTARE
    * @description from an asset id retrieve the asset coverage list
    * @param assetId the asset id
    * @return the asset coverage list
    */
    /*public static List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> getAssetCoverage(Id assetId){
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> result = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
        if(assetId==null){
            return result;
        }
        List<Asset> assetData = retrieveAssetsData(new List<Id>{assetId});
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assets = XC_LCC067_RelatedAssetsByAccount.populateAssetsCustom(assetData);
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> servRoot = getServiceCoverage(assets[0]);
        
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> allCoverageAsset = getParentCoverage(assets[0], servRoot);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getAssetCoverage - all coverageAsset = '+ allCoverageAsset);
        Map<Id,String> productCoverage = retrieveProductForCoverage(allCoverageAsset);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getAssetCoverage - productCoverage = '+ productCoverage);
        
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom covAss : allCoverageAsset){
            String coveredProdType = productCoverage.get(covAss.id);
            if(coveredProdType!= null && coveredProdType.contains(assets[0].productSubType)){
                result.add(covAss);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getAssetCoverage - result = '+ result);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getAssetCoverage - size = '+ result.size());
        return result;
    }*/

    /**
    * @description extract AssetCustom Service from related Equipment roots
    * @param assetsEquipment Equipment roots
    * @param accountIds account Ids
    * @param servRoots assets Service related to eqAssId
    * @return related AssetCustom Coverage mapping
    */
    private static Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getAllParentCoverage(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetsEquipment, Set<String> accountIds, Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> servRoots){
        Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> result = new Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>();
        Map<Id,List<Asset>> assetsCovData = retrieveCoverageByAccounts(accountIds);

        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> coverageCustoms;
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> coverageRelateds;
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assEq : assetsEquipment){
            Id accId = assEq.accountId;
            if((servRoots.get(accId) == null || servRoots.get(accId).isEmpty()) && (assetsCovData.get(accId) == null || assetsCovData.get(accId).isEmpty())){
                continue;
            }
            coverageCustoms = XC_LCC067_RelatedAssetsByAccount.populateAssetsCustom(assetsCovData.get(accId));
            coverageRelateds = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
            Boolean coverageAdded = false;
            for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom coverage : coverageCustoms){
                /*if(servRoots.get(accId) == null || servRoots.get(accId).isEmpty()){
                    continue;
                }*/
                coverageAdded = false;
                if((servRoots.get(accId) != null && !servRoots.get(accId).isEmpty())){
                    if(checkServiceCoverageParent(assEq, coverage, servRoots.get(accId))){
                        coverageRelateds.add(coverage);
                        coverageAdded = true;
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@  add Coverage by root= '+ coverage);
                    }else if(checkBundleCoverageParent(assEq, coverage, servRoots.get(accId))){
                        coverageRelateds.add(coverage);
                        coverageAdded = true;
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@  add Coverage by address = '+ coverage);
                    }
                }
                if(!coverageAdded){
                    if(XC_LCC067_RelatedAssetsByAccount_U.checkRelatedProductConditions(coverage,assEq)){
                        coverageRelateds.add(coverage);
                        coverageAdded = true;
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@  add Coverage by Related Product = '+ coverage);
                    }
                }
            }
            Id eqId = assEq.id;
            result.put(eqId, coverageRelateds);
        }

        return result;
    }
    
    /**  METODO SU ASSET SINGOLO >>> DA COMMENTARE
    * @description extract AssetCustom Service from related Equipment roots
    * @param assetEquipment Equipment roots
    * @param servRoot asset Service
    * @return related AssetCustom Coverage
    */
    /*private static List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> getParentCoverage(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetEquipment, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> servRoot){
        List<Asset> assetsCovData = retrieveCoverageData(assetEquipment);
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> covAssets = XC_LCC067_RelatedAssetsByAccount.populateAssetsCustom(assetsCovData);
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> relatedCovAssets = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom covAsset : covAssets){
            if(checkServiceCoverageParent(assetEquipment, covAsset, servRoot)){
                relatedCovAssets.add(covAsset);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@  add Coverage by root= '+ covAsset);
            }else if(checkBundleCoverageParent(assetEquipment, covAsset, servRoot)){
                relatedCovAssets.add(covAsset);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@  add Coverage by address = '+ covAsset);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getParentCoverage - size = '+ relatedCovAssets.size());
        return relatedCovAssets;
    }*/

    /**
    * @description checkServiceCoverageParent
    * @param assetEquipment Equipment roots
    * @param covAsset Coverage to check
    * @param servRoot asset Service
    * @return true if relates, else false
    */
    private static Boolean checkServiceCoverageParent(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetEquipment, XC_LCC067_RelatedAssetsByAccount_U.AssetCustom covAsset, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> servRoot){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ checkServiceCoverageParent - servRoot size = '+ servRoot.size());
        if(assetEquipment.rootOrderItem != null && assetEquipment.rootOrderItem == covAsset.rootOrderItem){
            for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom serv: servRoot){
                if(serv.id != null && String.isNotBlank(covAsset.bundleConfiguration) && serv.id == covAsset.bundleConfiguration){
                    return true;
                }
            }
        }
        return false;
    }

    /**
    * @description checkBundleCoverageParent
    * @param assetEquipment Equipment roots
    * @param covAsset Coverage to check
    * @param servRoot asset Service
    * @return true if relates, else false
    */
    private static Boolean checkBundleCoverageParent(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetEquipment, XC_LCC067_RelatedAssetsByAccount_U.AssetCustom covAsset, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> servRoot){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ checkBundleCoverageParent - servRoot size = '+ servRoot.size());
        if(String.isNotBlank(assetEquipment.address) && String.isNotBlank(covAsset.rootOrderItem)){
            for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom serv: servRoot){
                if(serv.address == assetEquipment.address && serv.Id == covAsset.rootOrderItem){
                    return true;
                }
            }
        }
        return false;
    }
    
    /**
    * @description extract AssetCustom Service and Bundle from related Equipment roots
    * @param assetsEquipment Equipment roots
    * @param accountIds Equipment account Ids
    * @return map with accountId equipment Id -> related service assets list
    */
    private static Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getServiceBundleRoots(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetsEquipment, Set<String> accountIds){
        Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> result = new Map<Id,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>();
        if(assetsEquipment==null || assetsEquipment.isEmpty()){
            return result;
        }
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> servRootCustoms;
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> servChildrenList;
        Map<Id,List<Asset>> servDataRoots = retrieveServiceRootsByAccounts(accountIds);
        
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assEq : assetsEquipment){
            Id accId = assEq.accountId;
            if(servDataRoots.get(accId) == null || servDataRoots.get(accId).isEmpty()){
                continue;
            }
            servRootCustoms = XC_LCC067_RelatedAssetsByAccount.populateAssetsCustom(servDataRoots.get(accId));
            //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ servRootCustoms size = '+ servRootCustoms.size());
            //servChildrenList = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
            if(result.get(accId)==null){
                result.put(accId, new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>());
            }
            servChildrenList = result.get(accId);
            for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom service : servRootCustoms){
                if(XC_LCC067_RelatedAssetsByAccount_U.checkGlobalEquipmentChildren(service, assEq)){
                    servChildrenList.add(service);
                }
            }
            result.put(accId, servChildrenList);
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getServiceBundleRoots - result = '+ result);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getServiceBundleRoots - result size (list4Account) = '+ result.size());
        return result;
    }
    
    /** METODO SU ASSET SINGOLO >>> DA COMMENTARE
    * @description extract AssetCustom Service from related Equipment roots
    * @param assetEquipment Equipment roots
    * @return AssetCustom Equipment roots
    */
    /*private static List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> getServiceCoverage(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetEquipment){
        List<Asset> servRoot = retrieveServiceRootData(assetEquipment);
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> servRootCustoms = XC_LCC067_RelatedAssetsByAccount.populateAssetsCustom(servRoot);
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> servChildrenList = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom service : servRootCustoms){
            if(XC_LCC067_RelatedAssetsByAccount_U.checkGlobalEquipmentChildren(service, assetEquipment)){
                //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getServiceCoverage - add id = '+ service.id);
                //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getServiceCoverage - bundleConfiguration = '+ assetEquipment.bundleConfiguration);
                //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getServiceCoverage - address service = '+ service.address);
                //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getServiceCoverage - address eqp = '+ assetEquipment.address);
                servChildrenList.add(service);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getServiceCoverage - size = '+ servChildrenList.size());
        return servChildrenList;
    }*/

    /**
    * @description retrieveAllCoverageProduct
    * @param coverageChildrenMap coverage map
    * @return the map with all Coverage Product
    */
    public static Map<Id,Map<String,String>> retrieveAllCoverageProduct(Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> coverageChildrenMap){
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> allCoverage = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
        for(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> item : coverageChildrenMap.values()){
            allCoverage.addAll(item);
        }
        return retrieveProductForCoverage(allCoverage);
    }
    
    /**
    * @description retrieveProductForCoverage
    * @param assets assets AssetCustom
    * @return Map<Id,String> that map Asset Id -> covered products
    */
    private static Map<Id,Map<String,String>> retrieveProductForCoverage(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assets){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ retrieveProductForCoverage - input assets = '+ assets);
        List<String> assIds = new List<Id>();
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom ass : assets){
            if(ass.id!=null) {
                assIds.add(ass.id);
            }
        }
        Map<Id,Asset> assetData = new Map<Id,Asset> ([
            SELECT Id, NE__CatalogItem__r.NE__ProductId__c, NE__CatalogItem__r.NE__Product_Name__c, XC_ContractStartDate__c, XC_ContractEndDate__c 
                   , XC_Address__r.Name
            FROM asset 
            WHERE Id IN: assIds
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ retrieved assetData = '+ assetData);
        List<String> prodIds = new List<String>(); // XC_UTIL_Sobject.getListFieldValues(assetData.values(), 'NE__CatalogItem__r.NE__ProductId__c');
        for(Asset ass : assetData.values()){
            if(ass.id!=null) {
                prodIds.add(ass.NE__CatalogItem__r.NE__ProductId__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ prodIds = '+ prodIds);
        Map<Id,NE__DocumentationCharacterist__c> covTypeData = new Map<Id,NE__DocumentationCharacterist__c> (
            [SELECT Id, Name, NE__Value__c, NE__Product__c, NE__Product__r.XC_LIC_Product_Name__c
               FROM NE__DocumentationCharacterist__c 
              WHERE Name IN ('Coverage Type','SLA') AND NE__Product__c IN: prodIds]);
        
        Map<Id,Map<String,String>> result = new Map<Id,Map<String,String>>();
        for(NE__DocumentationCharacterist__c doc : covTypeData.values()){
            for(Asset ass : assetData.values()){
                if(result.get(ass.Id) == null){
                    result.put(ass.Id, new Map<String,String> ());
                }
                if(ass.NE__CatalogItem__r.NE__ProductId__c == doc.NE__Product__c){
                    if('Coverage Type' == doc.Name ){
                        (result.get(ass.Id)).put('Coverage Type', doc.NE__Value__c);
                    }else if('SLA' == doc.Name ){
                        (result.get(ass.Id)).put('SLA', doc.NE__Value__c);
                    }
                }
            }
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ retrieveProductForCoverage - result = '+ result);
        return result;
    }
    
    /**
    * @description retrieveServiceRootsByAccounts
    * @param accountIds account Ids
    * @return assets data
    */
    private static Map<Id,List<Asset>> retrieveServiceRootsByAccounts(Set<String> accountIds) {
        Map<Id,Asset> assets = new Map<Id,Asset>(
            [SELECT id, AccountId, contactId, Name, XC_Product_Catalog_Category__c, toLabel(Status), InstallDate,XC_ContractStartDate__c, XC_ContractEndDate__c, NE__Bundle_Configuration__r.Name, 
                    XC_Product_Type__c, XC_Product_Subtype__c, NE__Root_Order_Item__c, XC_Address__c, NE__Bundle_Configuration__c 
                    , XC_Address__r.Name, XC_RelatedProduct__c, NE__Item_Code__c, NE__Root_Order_Item__r.XC_RelatedProduct__c
               FROM Asset 
              WHERE AccountId IN: accountIds AND Status =: Label.XC_CL_Asset_StatusActive 
                AND (XC_Product_Type__c =: Label.XC_CL_ProductTypeService OR 
                    (XC_Product_Type__c =: Label.XC_CL_ProductTypeBundle AND NE__Bundle_Configuration__c = null))]); //( .. AND XC_Product_Subtype__c =: Label.XC_CL_ProductTypeBundle) > (MC RC -20190911
        
        Map<Id,List<Asset>> result = new  Map<Id,List<Asset>>();
        for(Asset ass : assets.values()){
            if(result.get(ass.AccountId)==null){
                result.put(ass.AccountId, new List<Asset>());
            }
            (result.get(ass.AccountId)).add(ass);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ retrieveServiceRootsByAccounts - result = '+ result);
        return result;
    }
    
    /**
    * @description retrieveCoverageByAccounts
    * @param accountIds account Ids
    * @return assets data mapping Account Id -> related coverage assets list
    */
    private static Map<Id,List<Asset>> retrieveCoverageByAccounts(Set<String> accountIds) {
        Map<Id,Asset> assets = new Map<Id,Asset>(
            [SELECT id, AccountId, contactId, Name, XC_Product_Catalog_Category__c, toLabel(Status), InstallDate,XC_ContractStartDate__c, XC_ContractEndDate__c, 
                    NE__Bundle_Configuration__r.Name, XC_Product_Type__c, XC_Product_Subtype__c, NE__Root_Order_Item__c, XC_Address__c, NE__Bundle_Configuration__c 
                    , XC_Address__r.Name, XC_RelatedProduct__c, NE__Item_Code__c, NE__Root_Order_Item__r.XC_RelatedProduct__c
               FROM Asset 
              WHERE AccountId IN: accountIds AND Status =: Label.XC_CL_Asset_StatusActive AND XC_Product_Type__c =: Label.XC_CL_ProductTypeCoverage]);

        Map<Id,List<Asset>> result = new  Map<Id,List<Asset>>();
        for(Asset ass : assets.values()){
            if(result.get(ass.AccountId)==null){
                result.put(ass.AccountId, new List<Asset>());
            }
            (result.get(ass.AccountId)).add(ass);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ retrieveCoverageByAccounts - result = ' + result);
        return result;
    }
    
    /**
    * @description retrieve Assets Data
    * @param assetIds asset ids list
    * @return assets data
    */
    private static List<Asset> retrieveAssetsData(List<Id> assetIds) {
        Map<Id,Asset> assets = new Map<Id,Asset>([
            SELECT id, AccountId, contactId, Name, XC_Product_Catalog_Category__c, toLabel(Status), InstallDate, NE__Bundle_Configuration__r.Name, 
                    XC_Product_Type__c, XC_Product_Subtype__c, NE__Root_Order_Item__c, XC_Address__c, NE__Bundle_Configuration__c, XC_ContractStartDate__c, XC_ContractEndDate__c 
                    , XC_Address__r.Name, XC_RelatedProduct__c, NE__Item_Code__c, NE__Root_Order_Item__r.XC_RelatedProduct__c
            FROM Asset 
            WHERE Id IN: assetIds
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ retrieveAssetsData - result = '+ assets.values());
        return assets.values();
    }
}