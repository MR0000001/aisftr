/**
* @author Monica Cutillo - monica.cutillo@nttdata.com + Salvatore Agrillo - salvatore.agrillo@nttdata.com for PMD
* @date Creation  06/05/2019
* @description XC_LCC067_RelatedAssetsByAccount_U_Nodes - UTIL Class for XC_LCC067_RelatedAssetsByAccount
*/

public without sharing class XC_LCC067_RelatedAssetsByAccount_U_Nodes {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC067_RelatedAssetsByAccount');

    
    /**
    * @description Builds a list of Node from the Asset list in input
    * @param assetEqRoots assets root
    * @param assetChildrenMap  map of children nodes
    * @return the asset nodes list
    */
    public static List<Map<String,Object>> buildAssetProductTreeNodes(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetEqRoots, Map<String,Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>> assetChildrenMap){
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> serviceRootChildren = assetChildrenMap.get('Service');
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> coverageChildren = assetChildrenMap.get('Coverage');
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> relatedProdCoverage = assetChildrenMap.get('RelatedProdCoverage');
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> allCoverage = new Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>();
        allCoverage.putAll(coverageChildren);
        allCoverage.putAll(relatedProdCoverage);
        Map<Id,Map<String,String>> productMapping = XC_UTIL_AssetCoverage.retrieveAllCoverageProduct(allCoverage);
        
        List<Map<String,Object>> serviceNodes;
        List<Map<String,Object>> result = new List<Map<String,Object>>();
        Map<String,Object> nodeEq;
        Map<String,Object> nodeSer;
        //costruisco i nodi root equipment
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetEq : assetEqRoots) {
            serviceNodes = new List<Map<String,Object>>();
            nodeEq = XC_LCC067_RelatedAssetsByAccount.populateNodeFromAsset(assetEq, true);
            if(serviceRootChildren == null || serviceRootChildren.isEmpty() || serviceRootChildren.get(assetEq.id) == null){
                result.add(nodeEq);
                continue;
            }else{
                //costruisco i sotto alberi con le root service e tutti i coverage figli
                for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetServ : serviceRootChildren.get(assetEq.id)) {
                    nodeSer = XC_LCC067_RelatedAssetsByAccount.populateNodeFromAsset(assetServ, true);
                    List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> covChildrenAsset = coverageChildren.get(assetServ.Id);
                    List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> filteredCoverage = filterCoverageByProduct(assetEq, covChildrenAsset, productMapping);
                    
                    if(assetServ.productType == Label.XC_CL_ProductTypeCoverage && assetEq.itemCode == assetServ.relatedProduct && checkProductCoverage(assetEq, assetServ, productMapping)){ //NR1112
                        nodeSer.put('nodeName', 'Coverage');
                        serviceNodes.add(nodeSer);
                        continue;
                    }
                    else if(filteredCoverage == null || filteredCoverage.isEmpty()){
                        //serviceNodes.add(nodeSer);
                        continue;
                    }else{
                        Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> children = new Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>
                        { 'Coverage'  => filteredCoverage };
                        nodeSer = buildNode(nodeSer, children, productMapping);//assetServ
                        serviceNodes.add(nodeSer);
                    }
                }
                if(!serviceNodes.isEmpty()){
                    nodeEq.put('_children', serviceNodes);
                }
                result.add(nodeEq);
            }
        }
        
        return result;
    }

    /**
    * @description filterCoverageByProduct
    * @param assetEq equipment assets
    * @param covChildrenAsset coverage asset
    * @param productMapping
    * @return the asset nodes list
    */
    private static List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> filterCoverageByProduct(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetEq, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> covChildrenAsset, Map<Id,Map<String,String>> productMapping){
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> result = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
        if(covChildrenAsset==null || covChildrenAsset.isEmpty()){
            return result;
        }
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom cov : covChildrenAsset){
            //String coveredProdType = productMapping.get(cov.id);
            //String coveredProdType = (productMapping.get(cov.id) != null) ? (productMapping.get(cov.id)).get('Coverage Type') : null;
            //if(String.isNotBlank(coveredProdType) && (coveredProdType.toUpperCase()).contains((assetEq.productSubType).toUpperCase())){
            if(checkProductCoverage(assetEq, cov, productMapping)){
                result.add(cov);
            }
        }
        return result;
    }

    /**
    * @description check the Coverage By Product
    * @param assetEq equipment assets
    * @param cov coverage asset
    * @param productMapping
    * @return the asset nodes list
    */
    private static Boolean checkProductCoverage(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetEq, XC_LCC067_RelatedAssetsByAccount_U.AssetCustom cov, Map<Id,Map<String,String>> productMapping){
        String coveredProdType = (productMapping.get(cov.id) != null) ? (productMapping.get(cov.id)).get('Coverage Type') : null;
        return (String.isNotBlank(coveredProdType) && (coveredProdType.toUpperCase()).contains((assetEq.productSubType).toUpperCase()));
    }

    /**
    * @description Builds a list of Node from the Asset list in input
    * @param assetRoots assets root
    * @param assetChildrenMaps map of child node
    * @return the asset nodes list
    */
    public static List<Map<String,Object>> buildAssetTreeNodes(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetRoots, Map<String,Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>> assetChildrenMaps ){
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ buildAssetTreeNodes - input assetRoots = '+ assetRoots);
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> coverageChildren = assetChildrenMaps.get('Coverage');
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> equipmentChildren = assetChildrenMaps.get('Equipment');
        Map<Id,Map<String,String>> productMapping = XC_UTIL_AssetCoverage.retrieveAllCoverageProduct(coverageChildren);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ buildAssetTreeNodes - input assetRoots = '+ assetRoots);
        List<Map<String,Object>> result = new List<Map<String,Object>>();
        Map<String,Object> node;

        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom asset : assetRoots) {
            
            node = XC_LCC067_RelatedAssetsByAccount.populateNodeFromAsset(asset, true);
            List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> covChildrenAsset = coverageChildren.get(asset.Id); //assetChildrenMap 
            List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> equipChildrenAsset = equipmentChildren.get(asset.Id);
            
            //NR1112 - Coverage Root for RelatedProduct
            if(Label.XC_CL_ProductTypeCoverage == asset.productType){
                Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> children = new Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>
                {
                    'Equipment' => equipChildrenAsset,
                    'CoverageRoot' => new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>{asset}
                };
                node = buildNodeWithoutCoverageLevel(node, children, productMapping);
            }
            else if(covChildrenAsset == null || covChildrenAsset.isEmpty()){
                result.add(node);
                continue;
            }else{
                Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> children = new Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>>
                {
                    'Coverage'  => covChildrenAsset,
                    'Equipment' => equipChildrenAsset
                };
                node = buildNode(node, children, productMapping);//asset
            }
            result.add(node);
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ buildAssetTreeNodes - result = '+ result);
        return result;
    }

    /**
    * @description Builds a root node
    * @param node node root
    * @param childrenMap map of child node
    * @param productMapping all product Mapping
    * @return the asset nodes list
    */
    private static Map<String,Object> buildNode(Map<String,Object> node, Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> childrenMap, Map<Id,Map<String,String>> productMapping){ //XC_LCC067_RelatedAssetsByAccount_U.AssetCustom asset, 
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ buildNode - initial node = '+ node);
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> childrenCovAsset = childrenMap.get('Coverage');
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> childrenEquipAsset = childrenMap.get('Equipment');
        //Map<Id,String> productMapping = retrieveProductForCoverage(childrenCovAsset);

        List<Map<String,Object>> childrenNodes = new List<Map<String,Object>>();
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetCovChild : childrenCovAsset){
            Map<String,Object> nodeChildren = XC_LCC067_RelatedAssetsByAccount.populateNodeFromAsset(assetCovChild, false);
            nodeChildren.put('nodeName', Label.XC_CL_ProductTypeCoverage);
            childrenNodes.add(nodeChildren);
            //gestione sub nodes Equipment
            //String coveredProdType = productMapping.get(assetCovChild.id);
            String coveredProdType = (productMapping.get(assetCovChild.id) != null) ? (productMapping.get(assetCovChild.id)).get('Coverage Type') : '';
            //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ coveredProdType = '+ coveredProdType);
            List<Map<String,Object>> subChildrenNodes = buildSubNodes(childrenEquipAsset, coveredProdType);
            if(!subChildrenNodes.isEmpty()){
                nodeChildren.put('_children', subChildrenNodes);
            }
        }
        if(!childrenNodes.isEmpty()){
            node.put('_children', childrenNodes);
        }
        
        return node;
    }

    /**
    * @description Builds a root Coverage node
    * @param node node root
    * @param childrenMap map of child node
    * @param productMapping all product Mapping
    * @return the asset nodes list
    */
    @TestVisible
    private static Map<String,Object> buildNodeWithoutCoverageLevel(Map<String,Object> node, Map<String, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> childrenMap, Map<Id,Map<String,String>> productMapping){ //XC_LCC067_RelatedAssetsByAccount_U.AssetCustom asset, 
        XC_LCC067_RelatedAssetsByAccount_U.AssetCustom coverageRoot = childrenMap.get('CoverageRoot')[0];
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> childrenEquipAsset = childrenMap.get('Equipment');
        if(childrenEquipAsset == null || childrenEquipAsset.isEmpty()){
            return node;
        }
        
        List<Map<String,Object>> childrenNodes = new List<Map<String,Object>>();
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetChild : childrenEquipAsset){
            if(!checkProductCoverage(assetChild, coverageRoot, productMapping)){
                continue;
            }
            Map<String,Object> nodeChildren = XC_LCC067_RelatedAssetsByAccount.populateNodeFromAsset(assetChild, false);
            nodeChildren.put('nodeName', '');
            childrenNodes.add(nodeChildren);
        }
        if(!childrenNodes.isEmpty()){
            node.put('_children', childrenNodes);
        }
        
        return node;
    }

    /**
    * @description build Equipment SubNodes
    * @param childrenEquipAsset all Equipment Asset
    * @param coveredProdType covered Prod Types concatenated
    * @return equipment assets children
    */
    private static List<Map<String,Object>> buildSubNodes(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> childrenEquipAsset, String coveredProdType){
        List<Map<String,Object>> subChildrenNodes = new List<Map<String,Object>>();
        if(childrenEquipAsset==null || childrenEquipAsset.isEmpty()){
            return subChildrenNodes;
        }
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom assetSubChild : childrenEquipAsset){
            //subChildrenNodes = new List<Map<String,Object>>(); // MC BSN 313
            //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ assetSubChild.XC_Product_Subtype__c = '+ assetSubChild.productSubType);
            if(String.isNotBlank(coveredProdType) && (coveredProdType.toUpperCase()).contains((assetSubChild.productSubType).toUpperCase())){
                Map<String,Object> subNodeChildren = XC_LCC067_RelatedAssetsByAccount.populateNodeFromAsset(assetSubChild, false);
                subChildrenNodes.add(subNodeChildren);
            }
        }
        return subChildrenNodes;
    }
    
    /**
    * @description extract AssetCustom Equipment roots from all Assets related the Account
    * @param assetCustoms all AssetCustom related the Account
    * @return AssetCustom Equipment roots
    */
    public static List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> getEquipmentRoots(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms){
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> result = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
        Set<Id> ids = new Set<Id>();
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom asset : assetCustoms){
            if(Label.XC_CL_ProductTypeEquipment == asset.productType){
                if(!ids.contains(asset.id)){
                    ids.add(asset.id);
                    result.add(asset);
                }
            }
        }
        return result;
    }

    /**
    * @description extract AssetCustom Service from related Equipment roots
    * @param assetEqRoots all Equipment roots
    * @param assetCustoms all AssetCustom related the Account
    * @return AssetCustom Equipment roots
    */
    public static Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> getServiceCoverageFromEquipments(List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetEqRoots, List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetCustoms){
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> assetServiceRoots = XC_LCC067_RelatedAssetsByAccount_U.getServiceRoots(assetCustoms);
        Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> resDataMap = new  Map<String,List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>> ();
        List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom> servChildrenList;
        //Map<Id,Set<Id>> ids = new Map<Id,Set<Id>>();
        for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom eqRoot : assetEqRoots){
            Set<Id> ids = new Set<Id>();
            servChildrenList = new List<XC_LCC067_RelatedAssetsByAccount_U.AssetCustom>();
            for(XC_LCC067_RelatedAssetsByAccount_U.AssetCustom service : assetServiceRoots){
            //search a root asset with same address
                if(XC_LCC067_RelatedAssetsByAccount_U.checkGlobalEquipmentChildren(service, eqRoot)){
                    if(!ids.contains(service.id)){
                        ids.add(service.id);
                        servChildrenList.add(service);
                    }
                }
            }
            //XC_UTIL_Debug.debug(DEBUGACTIVE, '>>>>>>>>>>>>>>>>>>>>>>>>>> servChildrenList.size() = '+ servChildrenList.size());
            resDataMap.put(eqRoot.id, servChildrenList);
        }
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getServiceCoverageFromEquipments - resDataMap = '+ resDataMap);
        return resDataMap;
    }
}