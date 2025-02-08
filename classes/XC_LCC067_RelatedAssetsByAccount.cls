/**
* @author           VBV - vbarquero@deloitte.es
* @version          V0.1
* @author           Monica Cutillo - monica.cutillo@nttdata.com
* @version          V0.2
* @className        XC_LCC067_RelatedAssetsByAccount
* @description      Controller from XC_LCP067_RelatedAssetsByAccount
* @dateCreated      2018/01/02
* @Modify           20190614 Monica Cutillo 
*/
public  without sharing class XC_LCC067_RelatedAssetsByAccount {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC067_RelatedAssetsByAccount');
   
    /** @description Rapresent a Root Node of Assets Tree */
    public class AssetNode {
        /* the Root Node*/
        @AuraEnabled XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetNode {get;set;}
        /* Children Nodes*/
        @AuraEnabled List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> children {get;set;}
        
        /**
        * @description Instantiates a new asset node.
        * NB: non cancellare!!!
        */
        public AssetNode(){
            XC_UTIL_Debug.debug(false, 'AssetNode creation');
        }
    }
    
    /**
    * @description Gets the asset equipment Tree.
    * @param recordId the record id (Account or Contact)
    * @return the asset product Tree
    */
    @AuraEnabled 
    public static List<Map<String,Object>> getTreeAssetProducts(Id recordId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CALL getTreeAssetProducts - recordId='+recordId);
        List<Asset> assets = retrieveAllRelatedAsset(recordId);
        List<Map<String,Object>> dataTree = new List<Map<String,Object>>();
        if(assets.isEmpty()){
            return dataTree;
        }
        
        Boolean isCommunity = isCommunity();
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms = populateAssetsCustom(assets, isCommunity);
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetEqRoots = XC_LCC067_RelatedAssetsByAccount_U_Nodes.getEquipmentRoots(assetCustoms);
        //List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetServRoots = XC_LCC067_RelatedAssetsByAccount_U.getServiceRoots(assetCustoms);
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> assetCoverageChildren = XC_LCC067_RelatedAssetsByAccount_U.getCoverageChildren(assetCustoms); //assetServRoots
        
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> serviceCoverageChildren = XC_LCC067_RelatedAssetsByAccount_U_Nodes.getServiceCoverageFromEquipments(assetEqRoots, assetCustoms);
        
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> relatedProductCoverage = XC_LCC067_RelatedAssetsByAccount_U.getRelatedProductCoverage(assetCustoms);

        Map<String,Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>> allAssetChildren = new Map<String,Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>>
        {
            'Coverage'              => assetCoverageChildren,
            'Service'               => serviceCoverageChildren,
            'RelatedProdCoverage'   => relatedProductCoverage
        };
        if(assetEqRoots!=null && !(assetEqRoots.isEmpty())){
            dataTree = XC_LCC067_RelatedAssetsByAccount_U_Nodes.buildAssetProductTreeNodes(assetEqRoots, allAssetChildren);
        }
        return dataTree;
    }

    /**
    * @description Gets the asset services Tree.
    * @param recordId the record id (Account or Contact)
    * @return the asset service Tree
    */
    @AuraEnabled 
    public static List<Map<String,Object>> getTreeAssetServices(Id recordId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ CALL getTreeAssetServices - recordId='+recordId);
        List<Asset> assets = retrieveAllRelatedAsset(recordId);
        List<Map<String,Object>> dataTree = new List<Map<String,Object>>();
        if(assets.isEmpty() || assets == null){
            return dataTree;
        }

        Boolean isCommunity = isCommunity();
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms = populateAssetsCustom(assets, isCommunity);
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetRoots = XC_LCC067_RelatedAssetsByAccount_U.getServiceRoots(assetCustoms);
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> assetCoverageChildren = XC_LCC067_RelatedAssetsByAccount_U.getCoverageChildren(assetCustoms); //assetRoots
        //Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> assetChildren = XC_LCC067_RelatedAssetsByAccount_U.addEquipmentChildren(assetCustoms, assetRoots, assetCoverageChildren);
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> assetEquipmentChildren = XC_LCC067_RelatedAssetsByAccount_U.getEquipmentChildren(assetCustoms, assetRoots);
        //assetChildren = XC_LCC067_RelatedAssetsByAccount_U.addBundleChildren(assetCustoms, assetRoots, assetChildren);
        Map<String,Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>> allAssetChildren = new Map<String,Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>>
        {
            'Coverage'  => assetCoverageChildren,
            'Equipment' => assetEquipmentChildren
        };
        if(assetRoots!=null && !(assetRoots.isEmpty())){
            dataTree = XC_LCC067_RelatedAssetsByAccount_U_Nodes.buildAssetTreeNodes(assetRoots, allAssetChildren); //assetChildren
        }
        return dataTree;
    }

     

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description evaluate if the user is in Community
     * @return the WrapperDoInit
     */
    private static Boolean isCommunity() {
        String idUser = UserInfo.getUserId();
        Map<Id,User> user = new Map<Id,User>([SELECT Id, Country__c FROM User WHERE Id = :idUser  AND Profile.UserLicense.Name = 'Partner Community']);
        if(!user.isEmpty()){
            return true;
        }
        return false;
    }

    /**
    * @description populate an asset node map from an asset object
    * @param asset the asset object
    * @param setNodeName if true set node name
    * @return the map node populated
    */
    public static Map<String,Object> populateNodeFromAsset(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom asset, Boolean setNodeName){
        Map<String,Object> node =  new Map<String,Object>();
        node.put('id', asset.Id);
        node.put('name', asset.name);
        if(setNodeName){
            node.put('nodeName', asset.name);
        }
        node.put('link', asset.link);
        node.put('catalogName', asset.catalogName);
        node.put('productType', asset.productType);
        node.put('productSubtype', asset.productSubtype);
        node.put('status', asset.status);
        node.put('installDate', asset.installDate);
        node.put('contractLineItemName', asset.contractLineItemName);
        node.put('contractLineItemLink', asset.contractLineItemLink);
        node.put('bundleConfigurationName', asset.bundleConfigurationName);
        node.put('bundleConfigurationLink', asset.bundleConfigurationLink);
        node.put('startDate', asset.startDate);
        node.put('endDate', asset.endDate);
        node.put('addressName', asset.addressName);
        return node;
    }

    /**
    * @description Populate assets custom.
    * @param assList the ass list
    * @return the list
    */
    public static List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> populateAssetsCustom(List<Asset> assList){
        return populateAssetsCustom(assList, false);

    }
    /**
    * @description Populate assets custom.
    * @param assList the ass list
    * @param isCommunity
    * @return the list
    */
    public static List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> populateAssetsCustom(List<Asset> assList, Boolean isCommunity){
        //vb info Catalog category
        //vb Map SAL contains as key AssetId en as value the catalog category Name
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> acList = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
        Map<Id, String> catalogCategoryNamesMap = new Map<Id, String>();
        Set<Id> assetIds = XC_UTIL_Sobject.getSetIds(assList);

        catalogCategoryNamesMap = XC_AT_Utils.getCatalogCategoryNamesMap(assetIds);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, catalogCategoryNamesMap);

        XC_LCC067_RelatedAssetsByAccount_U.AssetCustom ac;
        for(Asset a : assList){
            ac = fillAssetCustom(a, catalogCategoryNamesMap.get(a.Id), isCommunity);
            acList.add(ac);
        } 

        //XC_UTIL_Debug.debug(DEBUGACTIVE, acList);
        return acList; 
    }

    /**
    * @description Builds two folder nodes Coverage and Equipment with its children
    * @param rootId
    * @param childrenNodeList nodes 
    * @return the list with two folder nodes
    */
    public static List<Map<String,Object>> createChildrenFolders(String rootId, List<Map<String,Object>> childrenNodeList){
        List<Map<String,Object>> childrenCoverage = new List<Map<String,Object>>();
        List<Map<String,Object>> childrenEquipment = new List<Map<String,Object>>();
        for(Map<String,Object> node : childrenNodeList){
            if(node.get('productType') == Label.XC_CL_ProductTypeCoverage){
                childrenCoverage.add(node);
            }else if(node.get('productType') == Label.XC_CL_ProductTypeEquipment){
                childrenEquipment.add(node);
            }
        }
        List<Map<String,Object>> childrenFolder = new List<Map<String,Object>>();
        if(!childrenCoverage.isEmpty()){
            Map<String,Object> coverageNode = populateFolderNode(rootId, Label.XC_CL_ProductTypeCoverage);
            coverageNode.put('_children', childrenCoverage);
            childrenFolder.add(coverageNode);
        }
        if(!childrenEquipment.isEmpty()){
            Map<String,Object> equipmentNode = populateFolderNode(rootId, Label.XC_CL_ProductTypeEquipment);
            equipmentNode.put('_children', childrenEquipment);
            childrenFolder.add(equipmentNode);
        }
        return childrenFolder;
    }

    /**
    * @description populate an asset node map from an asset object
    * @param rootId 
    * @param folderName
    * @return the map node populated
    */
    private static Map<String,Object> populateFolderNode(String rootId, String folderName){
        Map<String,Object> node =  new Map<String,Object>();
        node.put('id', rootId+'_'+folderName);
        node.put('nodeName', folderName);
        return node;
    }

    /**
    * @description fill an AssetCustom from an Asset.
    * @param a base Asset
    * @param catalogCategoryName the catalogue category name
    * @param isCommunity
    * @return the AssetCustom filled
    */
    private static XC_LCC067_RelatedAssetsByAccount_U.AssetCustom fillAssetCustom(Asset a, String catalogCategoryName, Boolean isCommunity){
        XC_LCC067_RelatedAssetsByAccount_U.AssetCustom ac = new XC_LCC067_RelatedAssetsByAccount_U.AssetCustom();
        if(a==null){
            return ac;
        }
        ac.id = a.Id;
        ac.accountId = a.AccountId;
        ac.rootOrderItem = (a.NE__Root_Order_Item__c != null) ? String.valueOf(a.NE__Root_Order_Item__c) : '';
        ac.bundleConfiguration = (a.NE__Bundle_Configuration__c != null) ? String.valueOf(a.NE__Bundle_Configuration__c) : '';
        ac.productType = (a.XC_Product_Type__c != null) ? a.XC_Product_Type__c : '';
        ac.productSubType = (a.XC_Product_Subtype__c != null) ? a.XC_Product_Subtype__c : '';
        ac.address = (a.XC_Address__c != null) ? String.valueOf(a.XC_Address__c) : '';
        ac.addressName = (a.XC_Address__r.Name != null) ? a.XC_Address__r.Name : '';
        ac.name = a.Name;
        ac.catalogName = catalogCategoryName;
        if(isCommunity){
            ac.link = '/partner/s/asset/'+ a.Id;
        }else{
            ac.link = '/'+ a.Id; // '/one/one.app?#/sObject/' + a.Id + '/view';
        }
        ac.status = a.Status;
        ac.installDate = a.InstallDate;
        ac.bundleConfigurationName = (a.NE__Bundle_Configuration__r.Name != null) ? a.NE__Bundle_Configuration__r.Name : '';
        ac.bundleConfigurationLink = (a.NE__Bundle_Configuration__r.Id != null) ? ('/one/one.app?#/sObject/' + a.NE__Bundle_Configuration__r.Id + '/view') : '';
        if(a.XC_ContractStartDate__c != null){
        	ac.startDate = (a.XC_ContractStartDate__c).format();
        }
        if(a.XC_ContractEndDate__c != null){
        	ac.endDate = (a.XC_ContractEndDate__c).format();
        }
        ac.relatedProduct = a.XC_RelatedProduct__c;
        ac.itemCode = a.NE__Item_Code__c;
        ac.parentRelatedProduct = a.NE__Root_Order_Item__r.XC_RelatedProduct__c;
        return ac;
    }
    
    /**
    * @description retrieveAllRelatedAsset to the Id in input
    * @param recordId the record id (Account or Contact)
    * @return related assets
    */
    private static List<Asset> retrieveAllRelatedAsset(Id recordId) {
        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        //retrieve all Node
        Map<Id,Asset> assets = new Map<Id,Asset>();
        if(sobjectType == 'Account'){
            assets  = new Map<Id,Asset>([
                SELECT id, AccountId, contactId, Name, XC_Product_Catalog_Category__c, toLabel(Status), InstallDate, NE__Bundle_Configuration__r.Name, 
                XC_Product_Type__c, XC_Product_Subtype__c, NE__Root_Order_Item__c, XC_Address__c, NE__Bundle_Configuration__c, XC_ContractStartDate__c, XC_ContractEndDate__c, XC_Address__r.Name, 
                XC_RelatedProduct__c, NE__Item_Code__c, NE__Root_Order_Item__r.XC_RelatedProduct__c
                FROM Asset 
                WHERE AccountId=:recordId
            ]);
        }
        else if(sobjectType == 'Contact'){
            assets  = new Map<Id,Asset>([
                SELECT id, AccountId, contactId, Name, XC_Product_Catalog_Category__c, toLabel(Status), InstallDate, NE__Bundle_Configuration__r.Name, 
                XC_Product_Type__c, XC_Product_Subtype__c, NE__Root_Order_Item__c, XC_Address__c, NE__Bundle_Configuration__c, XC_ContractStartDate__c, XC_ContractEndDate__c, XC_Address__r.Name, 
                XC_RelatedProduct__c, NE__Item_Code__c, NE__Root_Order_Item__r.XC_RelatedProduct__c
                FROM Asset 
                WHERE ContactId=:recordId
            ]);
        }
        return assets.values();
    }
}