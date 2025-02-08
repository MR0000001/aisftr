/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation  18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC067_RelatedAssetsByAccount UTIL
*/

public without sharing class XC_LCC067_RelatedAssetsByAccount_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC067_RelatedAssetsByAccount');
    
    /** @description The Class AssetCustom wrapper */
    public class AssetCustom {
        /** @description The id. */
        @AuraEnabled public Id id {get;set;}
        /** @description The account id. */
        @AuraEnabled public Id accountId {get;set;}
        /** @description rootOrderItem */
        @AuraEnabled public String rootOrderItem {get;set;}
        /** @description bundleConfiguration */
        @AuraEnabled public String bundleConfiguration {get;set;}
        /** @description productType */
        @AuraEnabled public String productType {get;set;}
        /** @description productSubType */
        @AuraEnabled public String productSubType {get;set;}
        /** @description SLA */
        @AuraEnabled public String sla {get;set;}
        /** @description address */
        @AuraEnabled public String address {get;set;}
        /** @description addressName */
        @AuraEnabled public String addressName {get;set;}
        
        /** @description The name. */
        @AuraEnabled public String name {get;set;}
        
        /** @description The link. */
        @AuraEnabled  public String link {get;set;}
        
        /** @description The catalog name. */
        @AuraEnabled  public String catalogName {get;set;}
        
        /** @description The status. */
        @AuraEnabled  public String status {get;set;}
        
        /** @description The install date. */
        @AuraEnabled  public Date installDate {get;set;}
        
        /** @description The contract line item name. */
        @AuraEnabled  public String contractLineItemName {get;set;}
        
        /** @description The contract line item link. */
        @AuraEnabled  public String contractLineItemLink {get;set;}
        
        /** @description The bundle configuration name. */
        @AuraEnabled  public String bundleConfigurationName {get;set;}
        
        /** @description The bundle configuration link. */
        @AuraEnabled  public String bundleConfigurationLink {get;set;}
        
        /** @description The install date. */
        @AuraEnabled  public String startDate {get;set;}
        
        /** @description The install date. */
        @AuraEnabled  public String endDate {get;set;}
        
        /** @description The Related Product. */
        @AuraEnabled  public String relatedProduct {get;set;}
        
        /** @description The NE item Code. */
        @AuraEnabled  public String itemCode {get;set;}
        
        /** @description The parent Related Product. */
        @AuraEnabled  public String parentRelatedProduct {get;set;}

        /**
        * @description Instantiates a new asset custom.
        * NB: non cancellare!!!
        */
        public AssetCustom(){
            XC_UTIL_Debug.debug(false, 'AssetCustom creation');
        }
    }

    /**
    * @description extract AssetCustom root(Service) from all Assets related the Account
    * @param assetCustoms all AssetCustom related the Account
    * @return the AssetCustom Service
    */
    public static List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> getServiceRoots(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms){
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> result = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
        Set<Id> rootIds = new Set<Id>();
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom asset : assetCustoms){
            if(Label.XC_CL_ProductTypeService == asset.productType || 
            (Label.XC_CL_ProductTypeBundle == asset.productType && String.isEmpty(asset.bundleConfigurationName)) || 
            (Label.XC_CL_ProductTypeCoverage == asset.productType && String.isBlank(asset.bundleConfigurationName) && String.isBlank(asset.rootOrderItem))){ // && Label.XC_CL_ProductTypeBundle == asset.productSubType (MC RC -20190911)
                if(!rootIds.contains(asset.Id)){
                    result.add(asset);
                    rootIds.add(asset.Id);
                }
            }
            //Service with RelatedProduct - NR1112
            else if(Label.XC_CL_ProductTypeService == asset.productType && String.isNotBlank(asset.relatedProduct)){
                if(!rootIds.contains(asset.Id)){
                    result.add(asset);
                    rootIds.add(asset.Id);
                }
            }
            //Coverage with RelatedProduct and without Root - NR1112
            else if(Label.XC_CL_ProductTypeCoverage == asset.productType && String.isNotBlank(asset.relatedProduct) && String.isBlank(asset.rootOrderItem)){
                if(!rootIds.contains(asset.Id)){
                    result.add(asset);
                    rootIds.add(asset.Id);
                }
            }

        }
        return result;
    }

    /**
    * @description extract AssetCustom children Coverage from all Assets related the Account
    * @param assetCustoms all AssetCustom related the Account
    * @return the Map with Key <Asset Root Id> -> Value <Asset Children>
    */
    public static Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getCoverageChildren(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms){ //, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetRoots
        //Set<Id> ids = new Set<Id>();
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> treeMap = new Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>();
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> childrenList;
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom asset : assetCustoms){
            if(Label.XC_CL_ProductTypeCoverage == asset.productType && asset.rootOrderItem != null){
                if(treeMap.get(asset.rootOrderItem) == null){
                    treeMap.put(asset.rootOrderItem, new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>());
                }
                //to have unique child
                //if(!ids.contains(asset.Id)){
                (treeMap.get(asset.rootOrderItem)).add(asset);
                    //ids.add(asset.Id);
                //}
            }
        }

        return addBundleChildren(assetCustoms, treeMap);//assetRoots
        //return treeMap;
    }

    /**
    * @description to extract AssetCustom Coverage retrieved by RelatedProduct, from all Assets related the Account
    * @param assetCustoms all AssetCustom related the Account
    * @return the Map with Key <RelatedProduct> -> Value <Asset Coverage>
    */
    public static Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getRelatedProductCoverage(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms){
        String relProd;
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> treeMap = new Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>();
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> childrenList;
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom asset : assetCustoms){
            if(Label.XC_CL_ProductTypeCoverage == asset.productType){
                //we take all Coverage WITH Root
                if((String.isNotBlank(asset.relatedProduct) && String.isNotBlank(asset.rootOrderItem)) || String.isNotBlank(asset.parentRelatedProduct)){
                    relProd = (String.isNotBlank(asset.relatedProduct)) ? asset.relatedProduct : asset.parentRelatedProduct;
                    if(treeMap.get(relProd) == null){
                        treeMap.put(relProd, new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>());
                    }
                    (treeMap.get(relProd)).add(asset);
                }
            }
        }
        return treeMap;
    }

    /**
    * @description extract AssetCustom children Equipment from all Assets related the Account
    * and add it to the treeMap
    * @param assetCustoms all AssetCustom related the Account
    * @param assetRoot all AssetCustom root
    * @return the Map with Key <Asset Root Id> -> Value <Asset Children>
    */ 
    /* tolto @ param treeMap all asset associations parent -> child */
    public static Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getEquipmentChildren(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetRoot){ //, Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> treeMap
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> resDataMap = new  Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> ();
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> childrenList;
        Map<Id,Set<Id>> ids = new Map<Id,Set<Id>>();
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom child : assetCustoms){
            if(Label.XC_CL_ProductTypeEquipment != child.productType){
                continue;
            }
            //search a root asset with same address
            for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom item : assetRoot){
                if(checkGlobalEquipmentChildren(item, child)){
                    if(resDataMap.get(item.id) == null){
                        childrenList = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
                        resDataMap.put(item.id, childrenList);
                    }
                    //to have unique child for a root
                    if(ids.get(item.id)!=null && ids.get(item.id).contains(child.Id)){
                        continue;
                    }
                    if(ids.get(item.id)==null){
                        ids.put(item.id, new Set<Id>());
                    }
                    (resDataMap.get(item.id)).add(child);
                    (ids.get(item.id)).add(child.Id);
                    //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ GET EquipmentChildren - child.id = '+ child.id);
                }
            }
        }
        return resDataMap; // treeMap;
    }
    
    /**
    * @description Check all equipment children Conditions
    * @param item
    * @param child
    * @return Boolean
    */
    public static Boolean checkGlobalEquipmentChildren(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom item, XC_LCC067_RelatedAssetsByAccount_U.AssetCustom child){
        return (checkAddressConditions(item, child) || checkBundleConditions(item, child) || checkRelatedProductConditions(item, child));
    }

    /**
    * @description Check Address Conditions
    * @param item
    * @param child
    * @return Boolean
    */
    private static Boolean checkAddressConditions(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom item, XC_LCC067_RelatedAssetsByAccount_U.AssetCustom child){
        if(Label.XC_CL_ProductTypeService == item.productType && String.isNotBlank(item.address) && item.address == child.address){
            //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ checkAddressConditions true - item.id = '+ item.id);
            return true;
        }
        return false;
    }

    /**
    * @description Check RelatedProduct Coverage Conditions
    * @param item
    * @param child
    * @return Boolean
    */
    public static Boolean checkRelatedProductConditions(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom item, XC_LCC067_RelatedAssetsByAccount_U.AssetCustom child){
        return (String.isNotBlank(child.itemCode) && (child.itemCode == item.relatedProduct || child.itemCode == item.parentRelatedProduct));
    }

    /**
    * @description Check Bundle Conditions
    * @param item
    * @param child
    * @return Boolean
    */
    private static Boolean checkBundleConditions(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom item, XC_LCC067_RelatedAssetsByAccount_U.AssetCustom child){
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ checkBundleConditions - item.id = '+ item.id);
        if(String.valueOf(item.id) == child.bundleConfiguration){ //Label.XC_CL_ProductTypeService == item.productType && 
            //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ checkBundleConditions true - item.id = '+ item.id);
            return true;
        }
        return false;
    }

    /**
    * @description extract AssetCustom children Coverage and Equipment of Bundle Asset
    * from all Assets related the Account and add it to the treeMap
    * @param assetCustoms all AssetCustom related the Account
    * @param treeMap all asset associations parent -> child
    * @return the Map with Key <Asset Root Id> -> Value <Asset Children>
    */
    //public static Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> addBundleChildren(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetRoot, Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> treeMap){
    public static Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> addBundleChildren(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms, Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> treeMap){
        Map<String,Set<Id>> ids = new Map<String,Set<Id>>();
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> childrenList;
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom child : assetCustoms){
            if( Label.XC_CL_ProductTypeCoverage == child.productType // || Label.XC_CL_ProductTypeEquipment == child.productType)
                && child.bundleConfiguration != null){
                
                if(ids.get(child.bundleConfiguration)==null){
                    ids.put(child.bundleConfiguration, new Set<Id>());
                }
                if(treeMap.get(child.bundleConfiguration) == null){
                    childrenList = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
                    treeMap.put(child.bundleConfiguration, childrenList);
                }
                //to have unique child for a root
                if(!(ids.get(child.bundleConfiguration)).contains(child.Id)){
                    (treeMap.get(child.bundleConfiguration)).add(child);
                    (ids.get(child.bundleConfiguration)).add(child.Id);
                }
            }
        }
        return treeMap;
    }
}