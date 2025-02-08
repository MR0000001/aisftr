public without sharing class TA_LCC226_CartContainer {

    public class CartContainerBag {
        @AuraEnabled
        public String catalogCategoryId {get; set;}
        @AuraEnabled
        public Map<String, List<String>> mapComponentStep {get; set;}
    }

    public class InfoBag {
        @AuraEnabled
        public List<Product2Wrapper> technicalProductsList          {get; set;}
        @AuraEnabled
        public List<Product2Wrapper> technicalWorkList              {get; set;}
        @AuraEnabled
        public List<Product2Wrapper> selectedTechnicalProductsList  {get; set;}
        @AuraEnabled
        public List<Product2Wrapper> selectedTechnicalWorkList      {get; set;}
        @AuraEnabled
        public String selectedTechnicalProductTotalAmount           {get; set;}
        @AuraEnabled
        public String selectedTechnicalWorkTotalAmount              {get; set;}
        @AuraEnabled
        public String genericTechnicalProductTotalAmount            {get; set;}
    }

    public class Product2Wrapper {
        @AuraEnabled
        public String  productId    {get; set;}
        @AuraEnabled
        public String  description  {get; set;}
        @AuraEnabled
        public Double  unitPrice    {get; set;}
        @AuraEnabled
        public String  productCode  {get; set;}
        @AuraEnabled
        public Integer quantity     {get; set;}
        @AuraEnabled
        public String  name         {get; set;}
        @AuraEnabled
        public Decimal  precioPenalizacion  {get; set;}
        @AuraEnabled
        public String  assetRepairedSubtype     {get; set;}
        @AuraEnabled
        public String  modelo     {get; set;}
        @AuraEnabled
        public String  familia     {get; set;}
        @AuraEnabled
        public String  fabricante     {get; set;}
        @AuraEnabled
        public String  producto     {get; set;}
        @AuraEnabled
        public Decimal  partnerReimbursement     {get; set;}
    }

    @AuraEnabled
    public static String initialize_TA_LCP230_CartTechnicalCatalog() {
        System.debug('TA_LCC226_CartContainer: init');
        InfoBag infoBag = new InfoBag();
        try {
            String userLegalEntity = XC_UTIL_User.getLegalEntityFromUser();
            system.debug('@@>> userLegalEntity >>> ' + userLegalEntity);

            String technicalProductsQuery = 'SELECT Id, Name, Description, XC_ProductSubType__c, XC_CatalogProduct__c, XC_Family__c, ProductCode, XC_Price__c, XC_Penalty__c, XC_Model__c, XC_Brand__c, XC_ProductCategory__c, giic_PartnerReimbursement__c ' + 
                                            'FROM Product2 ' + 
                                            'WHERE giic_LegalEntity__c = \'' + userLegalEntity + '\' ' +
                                            'AND XC_Product_Type__c = \'Technical Catalog\' ' + 
                                            'AND ((XC_ProductSubType__c = \'Enel Spare Part\') OR (XC_ProductSubType__c = \'Partner Spare Part\')) ' + 
                                            'ORDER BY Name';

            
            String technicalWorkQuery = 'SELECT Id, Name, Description, XC_ProductSubType__c, XC_CatalogProduct__c, XC_Family__c, ProductCode, XC_Price__c, XC_Penalty__c, XC_Model__c, XC_Brand__c, XC_ProductCategory__c, giic_PartnerReimbursement__c ' + 
                                        'FROM Product2 ' + 
                                        'WHERE giic_LegalEntity__c = \'' + userLegalEntity + '\' ' +
                                        'AND XC_Product_Type__c = \'Technical Catalog\' ' + 
                                        'AND XC_ProductSubType__c = \'Extra Service\' ' + 
                                        'ORDER BY Name';
            
            List<Product2> technicalProductsListFromDB = Database.query(technicalProductsQuery);
            List<Product2> technicalWorkListFromDB = Database.query(technicalWorkQuery);
            system.debug('@@>> technicalProductsListFromDB >>> ' + technicalProductsListFromDB);
            system.debug('@@>> technicalProductsListFromDB >>> ' + technicalWorkListFromDB);

            List<Product2Wrapper> technicalProductsList = new List<Product2Wrapper>();
            List<Product2Wrapper> technicalWorkList = new List<Product2Wrapper>();

            if(!technicalProductsListFromDB.isEmpty()){
                for(Product2 product : technicalProductsListFromDB){
                    Product2Wrapper product2Wrapper = new Product2Wrapper();
                    product2Wrapper.productId = product.Id;
                    product2Wrapper.description = product.Description;
                    product2Wrapper.unitPrice = product.XC_Price__c;
                    product2Wrapper.productCode = product.ProductCode;
                    product2Wrapper.name = product.Name;
                    product2Wrapper.quantity = 0;
                    product2Wrapper.precioPenalizacion = product.XC_Penalty__c;
                    product2Wrapper.assetRepairedSubtype = product.XC_ProductSubType__c;
                    product2Wrapper.modelo = product.XC_Model__c;
                    product2Wrapper.familia = product.XC_Family__c;
                    product2Wrapper.fabricante = product.XC_Brand__c;
                    product2Wrapper.producto = product.XC_ProductCategory__c;
                    product2Wrapper.partnerReimbursement = product.giic_PartnerReimbursement__c;
                    system.debug('@@>> technicalProductsListFromDB - product2Wrapper >>> ' + product2Wrapper);
                    
                    technicalProductsList.add(product2Wrapper);
                }

                infoBag.technicalProductsList = technicalProductsList;
            } 

            if(!technicalWorkListFromDB.isEmpty()){
                for(Product2 product : technicalWorkListFromDB){
                    Product2Wrapper product2Wrapper = new Product2Wrapper();
                    product2Wrapper.productId = product.Id;
                    product2Wrapper.description = product.Description;
                    product2Wrapper.unitPrice = product.XC_Price__c;
                    product2Wrapper.productCode = product.ProductCode;
                    product2Wrapper.name = product.Name;
                    product2Wrapper.quantity = 0;
                    product2Wrapper.precioPenalizacion = product.XC_Penalty__c;
                    product2Wrapper.assetRepairedSubtype = product.XC_ProductSubType__c;
                    product2Wrapper.modelo = product.XC_Model__c;
                    product2Wrapper.familia = product.XC_Family__c;
                    product2Wrapper.fabricante = product.XC_Brand__c;
                    product2Wrapper.producto = product.XC_ProductCategory__c;
                    product2Wrapper.partnerReimbursement = product.giic_PartnerReimbursement__c;
                    system.debug('@@>> technicalWorkListFromDB - product2Wrapper >>> ' + product2Wrapper);
                    
                    technicalWorkList.add(product2Wrapper);
                }

                infoBag.technicalWorkList = technicalWorkList;
            }

            infoBag.selectedTechnicalProductsList = new List<Product2Wrapper>();
            infoBag.selectedTechnicalWorkList = new List<Product2Wrapper>();
            infoBag.selectedTechnicalProductTotalAmount = '0.00';
            infoBag.selectedTechnicalWorkTotalAmount = '0.00';
            infoBag.genericTechnicalProductTotalAmount = '0.00';
            
            system.debug('@@>> infoBag >>> ' + infoBag);
            return JSON.serialize(infoBag);
                    
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC226_CartContainer] init - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC226_CartContainer', 'init', errorMessage, 0, errorMessage, null);
            return null;
        }
    }

    @AuraEnabled
    public static Map<String, String> initialize_TA_LCP229_CartMainProduct(String listOfItemsSerialized) {

        List<Object> listOfItems = new List<Object>();
        Map<String, String> params = new Map<String, String>();

        try {
            listOfItems = (List<Object>) JSON.deserializeUntyped(listOfItemsSerialized);

            List<String> productEngineCodeList = new List<String>();
            for(Object mainProduct : listOfItems) {
                Map<String, Object> mainProductMap = (Map<String, Object>) mainProduct;
                if(mainProductMap.containsKey('fields')) {
                    Map<String, Object> mainProductFields = (Map<String, Object>) mainProductMap.get('fields');
                    if(mainProductFields.containsKey('productenginecode')) {
                        String productEngineCode = (String) mainProductFields.get('productenginecode');
                        if(!String.isBlank(productEngineCode)) {
                            productEngineCodeList.add(productEngineCode);
                        }
                    }
                }
            }

            List<B2WExtCat__External_Catalog_Association__c> listExtCatalogAssociation = [SELECT B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__r.NE__Engine_Code__c,
                                                                                                XC_TechnicalProduct__c
                                                                                            FROM B2WExtCat__External_Catalog_Association__c
                                                                                            WHERE B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__r.NE__Engine_Code__c IN :productEngineCodeList
                                                                                                AND XC_TechnicalProduct__c != null];

            if(listExtCatalogAssociation.size() > 0) {
                Map<String, Set<String>> mapProductEngineTechnicalProductSet = new Map<String, Set<String>>();
                Set<String> totalTechnicalProductSet = new Set<String>();
                for(B2WExtCat__External_Catalog_Association__c extCatalogAssociation : listExtCatalogAssociation) {
                    totalTechnicalProductSet.add(extCatalogAssociation.XC_TechnicalProduct__c);

                    Set<String> technicalProductSet = new Set<String>();
                    if(mapProductEngineTechnicalProductSet.containsKey(extCatalogAssociation.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__r.NE__Engine_Code__c)) {
                        technicalProductSet = mapProductEngineTechnicalProductSet.get(extCatalogAssociation.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__r.NE__Engine_Code__c);
                    }
                    technicalProductSet.add(extCatalogAssociation.XC_TechnicalProduct__c);
                    mapProductEngineTechnicalProductSet.put(extCatalogAssociation.B2WExtCat__Commercial_Catalog_Item__r.NE__ProductId__r.NE__Engine_Code__c, technicalProductSet);
                }

                List<Product2> listProduct2 = [SELECT Id,
                                                    ProductCode
                                                FROM Product2
                                                WHERE Id IN :totalTechnicalProductSet];

                if(listProduct2.size() > 0) {
                    Map<String, Set<String>> mapTechnicalProductProduct2Set = new Map<String, Set<String>>();
                    Set<String> totalProduct2Set = new Set<String>();
                    for(Product2 product2 : listProduct2) {
                        totalProduct2Set.add(product2.ProductCode);

                        Set<String> product2Set = new Set<String>();
                        if(mapTechnicalProductProduct2Set.containsKey(product2.Id)) {
                            product2Set = mapTechnicalProductProduct2Set.get(product2.Id);
                        }
                        product2Set.add(product2.ProductCode);
                        mapTechnicalProductProduct2Set.put(product2.Id, product2Set);
                    }

                    Id contactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()][0].ContactId;
                    Id accountId = [SELECT AccountId FROM Contact WHERE Id = :contactId][0].AccountId;

                    List<gii__ProductInventory__c> listProductInventory = [SELECT gii__Product__r.gii__ProductCode__c,
                                                                                giic_SalesOnHand__c
                                                                            FROM gii__ProductInventory__c
                                                                            WHERE gii__Product__r.gii__ProductCode__c IN :totalProduct2Set
                                                                                AND gii__Warehouse__r.gii__Account__c = :accountId];

                    if(listProductInventory.size() > 0) {
                        Map<String, Integer> mapProduct2ProductInventory = new Map<String, Integer>();
                        for(gii__ProductInventory__c productInventory : listProductInventory) {
                            mapProduct2ProductInventory.put(productInventory.gii__Product__r.gii__ProductCode__c, (Integer) productInventory.giic_SalesOnHand__c);
                        }

                        for(Object mainProduct : listOfItems) {
                            Map<String, Object> mainProductMap = (Map<String, Object>) mainProduct;
                            if(mainProductMap.containsKey('fields')) {
                                Map<String, Object> mainProductFields = (Map<String, Object>) mainProductMap.get('fields');
                                if(mainProductFields.containsKey('productenginecode')) {
                                    String productEngineCode = (String) mainProductMap.get('productenginecode');
                                    if(!String.isBlank(productEngineCode) && mapProductEngineTechnicalProductSet.containsKey(productEngineCode)) {
                                        for(String technicalProductValue : mapProductEngineTechnicalProductSet.get(productEngineCode)) {
                                            if(mapTechnicalProductProduct2Set.containsKey(technicalProductValue)) {
                                                for(String product2Value : mapTechnicalProductProduct2Set.get(technicalProductValue)) {
                                                    if(mapProduct2ProductInventory.containsKey(product2Value)) {
                                                        mainProductMap.put('TA_availabilityLocalWarehouse', mapProduct2ProductInventory.get(product2Value));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            mainProduct = (Object) mainProductMap;
                        }   
                    }
                }
            }

            params.put('listOfItems', JSON.serialize(listOfItems));

            List<Organization> currentOrgs = [SELECT Id, InstanceName FROM Organization WHERE Id = :UserInfo.getOrganizationId()];

            if(Test.isRunningTest()){
                if(!currentOrgs.isEmpty()) {
                    Organization currentOrg = currentOrgs[0];
                    List<TA_Store_URL__c> storeUrls = [SELECT Id, TA_URL__c 
                                                        FROM TA_Store_URL__c 
                                                        WHERE TA_Environment__c = :currentOrg.InstanceName
                                                        AND TA_Permission_Set_Name__c = 'Italy_Set'];
                    if(!storeUrls.isEmpty()) {
                        params.put('storeUrl', storeUrls[0].TA_URL__c);
                    }
                }
            } else {
                List<PermissionSetAssignment> currentUserPermissions = [SELECT PermissionSet.Name
                                                                        FROM PermissionSetAssignment
                                                                        WHERE AssigneeId =: UserInfo.getUserId()
                                                                        AND PermissionSet.Description = 'TA_Configuration_Language'];

                if(!currentOrgs.isEmpty() && !currentUserPermissions.isEmpty()) {
                    Organization currentOrg = currentOrgs[0];
                    List<TA_Store_URL__c> storeUrls = [SELECT Id, TA_URL__c 
                                                        FROM TA_Store_URL__c 
                                                        WHERE TA_Environment__c = :currentOrg.InstanceName
                                                        AND TA_Permission_Set_Name__c = :currentUserPermissions[0].PermissionSet.Name];
                    if(!storeUrls.isEmpty()) {
                        params.put('storeUrl', storeUrls[0].TA_URL__c);
                    }
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC226_CartContainer] initialize_TA_LCP229_CartMainProduct - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC226_CartContainer', 'initialize_TA_LCP229_CartMainProduct', errorMessage, 0, errorMessage, null);
        }
        return params;
    }

    @AuraEnabled
    public static String initialize_TA_LCP226_CartContainer(String customConfigSerialized) {
        CartContainerBag cartContainerBag = new CartContainerBag();
        cartContainerBag.mapComponentStep = new Map<String, List<String>>();
        try {
            Map<String, Object> customConfig = (Map<String, Object>) JSON.deserializeUntyped(customConfigSerialized);
            String catalogCategoryName = String.valueOf(customConfig.get('catalogCategoryName'));
            if(String.isNotBlank(catalogCategoryName)) {
                List<NE__Catalog_Category__c> listCatalogCategory = [SELECT Id FROM NE__Catalog_Category__c WHERE Name = :catalogCategoryName];
                cartContainerBag.catalogCategoryId = listCatalogCategory.size() > 0 ? listCatalogCategory[0].Id : null;
            }

            List<TA_Step_Catalog_Configuration__mdt> stepCatalogConfigurationList = [SELECT MasterLabel,
                                                                                        TA_BundleElementName__c
                                                                                    FROM TA_Step_Catalog_Configuration__mdt];

            for(TA_Step_Catalog_Configuration__mdt stepCatalogConfiguration : stepCatalogConfigurationList) {
                List<String> bundleElementNameList = new List<String>();
                bundleElementNameList = stepCatalogConfiguration.TA_BundleElementName__c.split(',');
                cartContainerBag.mapComponentStep.put(stepCatalogConfiguration.MasterLabel, bundleElementNameList);
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC226_CartContainer] initialize_TA_LCP229_CartMainProduct - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC226_CartContainer', 'initialize_TA_LCP229_CartMainProduct', errorMessage, 0, errorMessage, null);
        }
        return JSON.serialize(cartContainerBag);
    }

    // @AuraEnabled
    // public static void changeOrderRecordType(Id configurationId) {
    //     try {
    //         if(String.isNotBlank(configurationId)) {
    //             XC_UTIL_Order.OrderIFWrapper orderIfWrapper = new XC_UTIL_Order.OrderIFWrapper();
    //             orderIfWrapper.OrderID = configurationId;
    //             System.debug('orderIfWrapper >>> ' + orderIfWrapper);

    //             XC_REST_Order_U.WrapperPUTRequest wrReq = new XC_REST_Order_U.WrapperPUTRequest();
    //             wrReq.Order = orderIfWrapper;

    //             XC_REST_Order_U.WrapperRes wrResp = new XC_REST_Order_U.WrapperRes();

    //             Map<String,String> header = new Map<String,String> {
    //                 'ClientSystem' => 'XInstaller',
    //                 'DateTimeMessage' => DateTime.now().format('yyyyMMddHHmmssSSS'),
    //                 'TransactionID' => 'acceptQuote',
    //                 'Operation' => 'Create',
    //                 'Functionality' => 'CreateOrder',
    //                 'ServerSystem' => 'XCustomerB2C'
    //             };

    //             Map<String, Object> mapUtil = new Map<String, Object> {
    //                                                                 'header'=> header,
    //                                                                 'wrReq' => wrReq,
    //                                                                 'direction'=> 'Inbound'
    //                                                                 //'Account' => accMap
    //                                                             }; 

    //             XC_UTIL_Integration.WrapperResult responseValidation = XC_UTIL_RESTInbound.checkObjectPermission('NE__Order__c', 'create');
    //             if(responseValidation.errorFlag) {
    //                 wrResp.Result.Message = responseValidation.errorMessage; 
    //                 wrResp.Result.ErrorCode = '400';
    //                 System.debug('responseValidation >>> ' + responseValidation);
    //             }                                                                        

    //             String recordTypeDevName = [SELECT RecordType.DeveloperName FROM NE__Order__c WHERE Id =: configurationId].RecordType.DeveloperName;
    //             System.debug('recordTypeDevName >>> ' + recordTypeDevName);

    //             Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemIdOIA = new  Map<String, List<NE__Order_Item_Attribute__c>>();
    //             Map<String, Object> mapOrder = new Map<String, Object>{ 'mapOrdItemIdOIA'=> mapOrdItemIdOIA,
    //                                                                     'wrReq' => wrReq,
    //                                                                     'clientSystem' => header.get('ClientSystem'),
    //                                                                     'recordTypeOrder' => recordTypeDevName
    //                                                                   };

    //             responseValidation = XC_REST_Order_Z.validateReq(mapUtil);
    //             if(responseValidation.errorFlag) {
    //                 wrResp.Result.Message = 'ERROR. ' + responseValidation.errorMessage;
    //                 wrResp.Result.ErrorCode = (responseValidation.errorCode != '401' && responseValidation.errorCode != '402') ? '400' : responseValidation.errorCode;
    //                 wrResp.Order = null;
    //                 System.debug('responseValidation >>> ' + responseValidation);
    //             } else if(recordTypeDevName == 'Opty') {
    //                 XC_REST_Order_U.manageOptyToQuote(mapOrder, wrResp, 'Quote');
    //                 System.debug('mapOrder after manageOptyToQuote >>> ' + mapOrder);
    //                 System.debug('wrResp after manageOptyToQuote >>> ' + wrResp);
    //             }
    //         }
    //     } catch (Exception e) {
    //         String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
    //         System.debug('[TA_LCC226_CartContainer] changeOrderRecordType - EXCEPTION HANDLER: ' + errorMessage);
    //         TA_UTIL_LogManagement.createLog('TA_LCC226_CartContainer', 'changeOrderRecordType', errorMessage, 0, errorMessage, null);
    //     }
    // }

    @AuraEnabled
    public static String getDynamicLookupValue(String listAttributeDynamicLookupSerialized, String legalEntity, String kType, String rType, String sType) {
        List<Object> listAttributeDynamicLookup = (List<Object>) JSON.deserializeUntyped(listAttributeDynamicLookupSerialized);
        List<Map<String, Object>> listAttributeDynamicLookupResult = new List<Map<String, Object>>();
        try {
            // Query nel for per poter gestire logiche di B2W - Al momento si tratta solo di 1 o 2 record nella lista, se dovessero aumentare bisogna trovare un work around.
            for(Object attributeDynamicLookup : listAttributeDynamicLookup) {
                Map<String, Object> attribute = (Map<String, Object>) attributeDynamicLookup;
                Map<String, Object> attributeFields = (Map<String, Object>) attribute.get('fields');
                String dynamicLookupName = String.valueOf(attributeFields.get('dynamiclookup'));
                List<NE__Dynamic_Lookup__c> dynamicLookupList = [SELECT Id, NE__Columns__c, NE__Search_specification__c, NE__sObject__c
                                                                FROM NE__Dynamic_Lookup__c
                                                                WHERE NE__Name__c = :dynamicLookupName];
                
                if(dynamicLookupList.size() > 0) {
                    String dynamicQuery = 'SELECT ' + dynamicLookupList[0].NE__Columns__c + ' FROM ' + dynamicLookupList[0].NE__sObject__c + ' WHERE ' + dynamicLookupList[0].NE__Search_specification__c;
                    if(legalEntity != null) {
                        dynamicQuery = dynamicQuery.replace('{!legalEntity}', legalEntity);
                    }
                    if(kType != null) {
                        dynamicQuery = dynamicQuery.replace('{!kType}', kType);
                    }
                    if(rType != null) {
                        dynamicQuery = dynamicQuery.replace('{!rType}', rType);
                    }
                    if(sType != null) {
                        dynamicQuery = dynamicQuery.replace('{!sType}', sType);
                    }
                    List<SObject> listItem = Database.query(dynamicQuery);
                    attribute.put('listOfDomains', listItem);
                    listAttributeDynamicLookupResult.add(attribute);
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC226_CartContainer] getDynamicLookupValue - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC226_CartContainer', 'getDynamicLookupValue', errorMessage, 0, errorMessage, null);
        }
        return JSON.serialize(listAttributeDynamicLookupResult);
    }
}