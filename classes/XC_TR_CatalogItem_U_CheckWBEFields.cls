/**
 * @author Nicola Mariniello nmariniello@deloitte.it
 * @date Creation 12/07/2021
 * @date Modification
 * @description XC_TR_Configuration_U_FillFields – Class to fill Configuration Fields
 */

public without sharing class XC_TR_CatalogItem_U_CheckWBEFields {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_CatalogItem_U_CheckWBEFields');


    /**
     * @description check Fields. 
     * @param listNew the list new
     */
    public static void checkFields(List<NE__Catalog_Item__c> listNew) {

        Set<String> setCostCenter = new Set<String>();
        Set<String> setProfitCenter = new Set<String>();
        Set<String> setProductServiceType = new Set<String>();
        Set<String> setProductLine = new Set<String>();

        // Check catalog
        String checkWBEBasedOnExcludedCatalog = (XC_CS_UtilityGlobalValues__c.getInstance('CheckWBEBasedOnExcludedCatalog') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('CheckWBEBasedOnExcludedCatalog').Value__c : null;
        String checkWBETrackingBasedOnExcludedCatalog = (XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETrackingBasedOnExcludedCatalog') != null) ? XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETrackingBasedOnExcludedCatalog').Value__c : null;
        List<String> catalogsName = (checkWBEBasedOnExcludedCatalog != null) ? checkWBEBasedOnExcludedCatalog.split(';') : new List<String>();
        List<String> catalogsNameForWBETrackingOnly = (checkWBETrackingBasedOnExcludedCatalog != null) ? checkWBETrackingBasedOnExcludedCatalog.split(';') : new List<String>();
        Set<String> allCatalogs = new Set<String>(catalogsName);
        if(!catalogsNameForWBETrackingOnly.isEmpty()) {
            allCatalogs.addAll(catalogsNameForWBETrackingOnly);
        }
        Map<Id, NE__Catalog__c> excludedCatalogsForBlankValuesWBEMap = new Map<Id, NE__Catalog__c>();   // Map of Catalogs to exclude for Blank Values check
        Map<Id, NE__Catalog__c> excludedCatalogsForWBETrackingMap = new Map<Id, NE__Catalog__c>();      // Map of Catalogs to exclude for WBE Tracking check
        if(!allCatalogs.isEmpty()) {
            excludedCatalogsForWBETrackingMap = new Map<Id, NE__Catalog__c>([SELECT Id, XC_LIC_Name__c
                                                                                FROM NE__Catalog__c
                                                                                WHERE XC_LIC_Name__c IN :allCatalogs]);
            for(NE__Catalog__c c : excludedCatalogsForWBETrackingMap.values()) {
                if(catalogsName.contains(c.XC_LIC_Name__c)) {
                    excludedCatalogsForBlankValuesWBEMap.put(c.Id, c);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'catalogsName: ' + catalogsName);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'excludedCatalogsForBlankValuesWBEMap: ' + excludedCatalogsForBlankValuesWBEMap.values());
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'catalogsNameForWBETrackingOnly: ' + catalogsNameForWBETrackingOnly);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'allCatalogs: ' + allCatalogs);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'excludedCatalogsForWBETrackingMap: ' + excludedCatalogsForWBETrackingMap);

        // Get Catalog Category Name for bundle
        Map<Id, NE__Catalog_Category__c> catalogCategoryMap = new Map<Id, NE__Catalog_Category__c>([SELECT Id, XC_LIC_Category_Name__c
                                                                                                    FROM NE__Catalog_Category__c
                                                                                                    WHERE XC_LIC_Category_Name__c = 'bundleItem']);

        // Check Required Fields
        String checkBlankValuesWBE = XC_CS_UtilityGlobalValues__c.getInstance('CheckBlankValuesWBE') != null ? XC_CS_UtilityGlobalValues__c.getInstance('CheckBlankValuesWBE').Value__c : 'false';
        if(checkBlankValuesWBE == 'true') {
            for(NE__Catalog_Item__c ci : listNew) {
                if(ci.XC_WbeMode__c != null && ci.XC_WbeMode__c.contains('ECA')){
                    continue;
                }
                Boolean activeCatalogItem = ci.NE__Active__c && ci.NE__Visible__c;
                Boolean blankFieldsProduct = ci.NE__Type__c == Label.XC_CL_ProductSubTypeValue && String.isNotBlank(ci.NE__Catalog_Category_Name__c) && catalogCategoryMap.containsKey(ci.NE__Catalog_Category_Name__c) && (String.isBlank(ci.XC_CostCenter__c) || String.isBlank(ci.XC_ProfitCenter__c) || String.isBlank(ci.XC_ProductServiceType__c) || String.isBlank(ci.XC_ProductLine__c));
                Boolean blankFieldsNoProduct = /*ci.NE__Type__c != Label.XC_CL_ProductSubTypeValue &&*/ (String.isNotBlank(ci.XC_CostCenter__c) || String.isNotBlank(ci.XC_ProfitCenter__c) || String.isNotBlank(ci.XC_ProductServiceType__c) || String.isNotBlank(ci.XC_ProductLine__c)) &&
                                                !(String.isNotBlank(ci.XC_CostCenter__c) && String.isNotBlank(ci.XC_ProfitCenter__c) && String.isNotBlank(ci.XC_ProductServiceType__c) && String.isNotBlank(ci.XC_ProductLine__c));
                Boolean checkCatalog = String.isNotBlank(ci.NE__Catalog_Id__c) && !excludedCatalogsForBlankValuesWBEMap.containsKey(ci.NE__Catalog_Id__c);
                
                if(checkCatalog && activeCatalogItem && (blankFieldsProduct || blankFieldsNoProduct)) {
                    ci.addError(Label.XC_CL_CatalogItem_MissingWBEFields);
                }
                
                if(checkCatalog && activeCatalogItem) {
                    if(String.isNotBlank(ci.XC_CostCenter__c))          {setCostCenter.add(ci.XC_CostCenter__c);}
                    if(String.isNotBlank(ci.XC_ProfitCenter__c))        {setProfitCenter.add(ci.XC_ProfitCenter__c);}
                    if(String.isNotBlank(ci.XC_ProductServiceType__c))  {setProductServiceType.add(ci.XC_ProductServiceType__c);}
                    if(String.isNotBlank(ci.XC_ProductLine__c))         {setProductLine.add(ci.XC_ProductLine__c);}
                }
            }
        }

        // Check WBE Tracking:
        String checkWBETracking = XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETracking') != null  ? XC_CS_UtilityGlobalValues__c.getInstance('CheckWBETracking').Value__c : 'false';
        if(checkWBETracking != 'true' || (checkWBETracking == 'true' && (setCostCenter.isEmpty() || setProfitCenter.isEmpty() || setProductServiceType.isEmpty() || setProductLine.isEmpty()))) {
            return;
        }

        List<XC_WbeTracking__c> listWBETracking = new List<XC_WbeTracking__c>([SELECT XC_CostCenter__c, XC_ProfitCenter__c, XC_ProductService__c, XC_ProductLine__c
                                                                                FROM XC_WbeTracking__c 
                                                                                WHERE XC_Status__c          =  :Label.XC_CL_Configuration_Approved  AND
                                                                                    XC_CostCenter__c        IN :setCostCenter                       AND
                                                                                    XC_ProfitCenter__c      IN :setProfitCenter                     AND
                                                                                    XC_ProductService__c    IN :setProductServiceType               AND
                                                                                    XC_ProductLine__c       IN :setProductLine]);

        for(NE__Catalog_Item__c ci : listNew) {
            if(ci.XC_WbeMode__c != null && ci.XC_WbeMode__c.contains('ECA')){
                continue;
            }
            if(String.isNotBlank(ci.NE__Catalog_Id__c) && !excludedCatalogsForWBETrackingMap.containsKey(ci.NE__Catalog_Id__c) && ci.NE__Active__c && ci.NE__Visible__c
                && String.isNotBlank(ci.XC_CostCenter__c) && String.isNotBlank(ci.XC_ProfitCenter__c) && String.isNotBlank(ci.XC_ProductServiceType__c) && String.isNotBlank(ci.XC_ProductLine__c)) {
                    Boolean found = false;
                    for(XC_WbeTracking__c track : listWBETracking) {
                        if(ci.XC_CostCenter__c == track.XC_CostCenter__c && ci.XC_ProfitCenter__c == track.XC_ProfitCenter__c && ci.XC_ProductServiceType__c == track.XC_ProductService__c && ci.XC_ProductLine__c == track.XC_ProductLine__c) {
                            found = true;
                            break;
                        }
                    }
                    if(!found) {
                        ci.addError(Label.XC_CL_CatalogItem_WBEFieldsNotValid);
                    }
            }
        }

    }


    /**
     * @description Change Fields update. 
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void changeFieldsUpdate(List<NE__Catalog_Item__c> listNew, Map<Id,NE__Catalog_Item__c> mapOld, Map<Id,NE__Catalog_Item__c> mapNew){
        List<String> fieldList = new List<String> {'NE__Type__c', 'NE__Active__c', 'NE__Visible__c', 'XC_CostCenter__c', 'XC_ProfitCenter__c', 'XC_ProductServiceType__c', 'XC_ProductLine__c'};
        List<NE__Catalog_Item__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        
        if(!listChanged.isEmpty()){  
            checkFields(listChanged);
        }
    }

}