/**
* @author Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 20/11/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ProvisioningTemplateAssociation – Util class for XC_UTIL_Provisioning Template Association methods
*/ 

public without sharing class XC_UTIL_ProvisioningTemplateAssociation {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ProvisioningTemplateAsso');

    /** @description Wrapper for ConfigurationItem */
    public class ConfigurationItemWrapper {
        public String country;
        public String orderType;
        public String orderSubType;
        public String orderItemAction;
        public String catalogItem;
        public String productServiceCategory;
        public Boolean bit2winBundle = false;
        public Boolean spareParts = false;
        public String billingMethod;
        public String paymentMethod;
        public String productSubtype;
        public String deliveryMethod;
        //public String channel; 
        //public String provider;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description This methods populates a map ConfigurationItemId -> Provisioning Template Name
    * @param listConfItem - List<NE__OrderItem__c>
    * @return Map<Id, String> 
    **/
    public static Map<Id, String> getTemplate(List<NE__OrderItem__c> listConfItem){
        List<Id> listConfItemIds = XC_UTIL_SObject.getIds(listConfItem);
        return getTemplate(listConfItemIds);
    }

    /**
    * @description Method to get templace from list confItems
    * @param listConfItemIds - List<Id>
    * @return Map<Id, String> 
    **/
    public static Map<Id, String> getTemplate(List<Id> listConfItemIds){
        XC_UTIL_ProvisioningTempAssociation_U.MatchWrapper matchWrapper = new XC_UTIL_ProvisioningTempAssociation_U.MatchWrapper();
        List<NE__OrderItem__c> orderItemList = getConfigurationItemFields(listConfItemIds);        
        matchWrapper.mapConfItemIdWrapper = createMapConfItemIdWrapper(orderItemList);
        matchWrapper.listSteps = getProvisioningTemplateAssociation(matchWrapper.mapConfItemIdWrapper);

        for(NE__OrderItem__c confItem : orderItemList){
            XC_UTIL_ProvisioningTempAssociation_U.checkExactMatch(confItem.Id, matchWrapper);
        }
        for(NE__OrderItem__c confItem : orderItemList){
            if(!matchWrapper.mapConfItemTemplateName.containsKey(confItem.Id)){
                XC_UTIL_ProvisioningTempAssociation_U.checkWildCardMatch(confItem.Id, matchWrapper);
            }
        }  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapConfItemTemplateName->' + matchWrapper.mapConfItemTemplateName);
        return matchWrapper.mapConfItemTemplateName;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description This method populates a ConfigurationItemWrapper using data from the NE__OrderItem__c
    * @param orderItemList - List<NE__OrderItem__c> 
    * @return Map<Id, ConfigurationItemWrapper>
    **/
    public static Map<Id, ConfigurationItemWrapper> createMapConfItemIdWrapper(List<NE__OrderItem__c> orderItemList){
        Map<Id, ConfigurationItemWrapper> mapConfItemIdWrapper = new  Map<Id, ConfigurationItemWrapper>();

        for(NE__OrderItem__c orderItem : orderItemList){ 
            ConfigurationItemWrapper wrapper = new ConfigurationItemWrapper();
            wrapper.country = orderItem.XC_CountryFormula__c;     
            //wrapper.channel = orderItem.NE__OrderId__r.NE__OptyId__r.XC_Channel__c;
            wrapper.orderType = orderItem.NE__OrderId__r.NE__Type__c;   
            wrapper.orderSubType = orderItem.NE__OrderId__r.XC_Subtype__c; 
            wrapper.orderItemAction = orderItem.NE__Action__c;
            wrapper.catalogItem = orderItem.NE__ProdId__r.XC_LIC_Product_Name__c;  // FIX 09/05/2019 - previous was NE__ProdName__c
            wrapper.productServiceCategory = orderItem.NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c;
            wrapper.paymentMethod = orderItem.XC_PaymentMethod__c;
            wrapper.productSubtype = orderItem.XC_Product_Subtype__c;
            if(wrapper.productServiceCategory == Label.XC_CL_HiddenProducts && orderItem.NE__ProdName__c == Label.XC_CL_Asset_Penalty ){
                wrapper.productServiceCategory = Label.XC_CL_Asset_Penalty;
            }
            for(NE__Order_Item_Attribute__c orderItemAttr : orderItem.NE__Order_Item_Attributes__r){
                if(orderItemAttr.XC_DeveloperName__c == Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel){
                    wrapper.billingMethod = orderItemAttr.NE__Value__c;
                }
                else if(orderItemAttr.XC_DeveloperName__c == Label.XC_CL_DeliveryMethod) {
                    wrapper.deliveryMethod = orderItemAttr.NE__Value__c;
                }
            }
            if(orderItem.NE__Bundle_Configuration__c != null){
                wrapper.bit2winBundle = true;  
            }
            if(orderItem.XC_ProvisioningSpareParts__c != null && orderItem.XC_ProvisioningSpareParts__c){
                wrapper.spareParts = true;  
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'WRAPPER----->' + wrapper);
            mapConfItemIdWrapper.put(orderItem.Id, wrapper);
        }
        
        return mapConfItemIdWrapper;
    }
       
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com - Fabrizio Antonioli - fabrizio.antonioli@nttdata.com
    * @description Retrieve all values from the Configuration Items in input
    * @param listConfId
    * @return List<NE__OrderItem__c>
    **/
    public static List<NE__OrderItem__c> getConfigurationItemFields(List<Id> listConfId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@#@#@ listConfId --->'+ listConfId);
        String query = XC_UTIL_SObject.selectAllFieldsGetSelect('NE__OrderItem__c'); 
        query += ', NE__OrderId__r.XC_Subtype__c, NE__OrderId__r.NE__OptyId__r.XC_ReceivingChannel__c, NE__OrderId__r.NE__Type__c, NE__CatalogItem__r.NE__Catalog_Category_Name__r.XC_LIC_Category_Name__c, NE__ProdId__r.XC_Product_Type__c';
        query += ', NE__CatalogItem__r.NE__RequestId__c, NE__ProdId__r.XC_LIC_Product_Name__c ';
        query +=' ,(SELECT Id, Name, NE__Value__c, XC_DeveloperName__c FROM NE__Order_Item_Attributes__r) ';
        query += ' FROM NE__OrderItem__c WHERE id IN : listConfId'; 
        List<NE__OrderItem__c> orderItemList = Database.query(query);
        return orderItemList;
    }
    
    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com - Fabrizio Antonioli - fabrizio.antonioli@nttdata.com
    * @description This method retrieves XC_CM_Provisioning_Template_Association__mdt custom metadata records based on ConfigurationItemWrapper values
    * @param mapConfItemIdWrapper - Map<Id, ConfigurationItemWrapper>
    * @return List<XC_CM_Provisioning_Template_Association__mdt>
    **/
    public static List<XC_CM_Provisioning_Template_Association__mdt> getProvisioningTemplateAssociation(Map<Id, ConfigurationItemWrapper> mapConfItemIdWrapper) {
        Set<String> countryValueSet = new Set<String>();
        Set<String> orderTypeValueSet = new Set<String>();
        Set<String> orderSubTypeValueSet = new Set<String>();
        Set<String> orderItemActionValueSet = new Set<String>();
        Set<String> catalogItemSet = new Set<String>();
        Set<String> productServiceCategoryValueSet = new Set<String>();
        Set<String> billingMethodValueSet = new Set<String>();
        Set<String> paymentMethodValueSet = new Set<String>();
        Set<String> productSubtypeValueSet = new Set<String>();
        //Set<String> channelValueSet = new Set<String>();
        //Set<String> providerValueSet = new Set<String>();
        for(ConfigurationItemWrapper wrapper : mapConfItemIdWrapper.values()){
            countryValueSet.add(wrapper.country);
            orderTypeValueSet.add(wrapper.orderType);
            orderSubTypeValueSet.add(wrapper.orderSubType);
            orderItemActionValueSet.add(wrapper.orderItemAction);
            catalogItemSet.add(wrapper.catalogItem);
            productServiceCategoryValueSet.add(wrapper.productServiceCategory);
            billingMethodValueSet.add(wrapper.billingMethod);
            paymentMethodValueSet.add(wrapper.paymentMethod);
            productSubtypeValueSet.add(wrapper.productSubtype);
            //channelValueSet.add(wrapper.channel);
            //providerValueSet.add(wrapper.provider); 
        }
        orderSubTypeValueSet.add('*');
        orderItemActionValueSet.add('*');
        catalogItemSet.add('*');
        billingMethodValueSet.add('*');
        paymentMethodValueSet.add('*');
        productSubtypeValueSet.add('*');
        List<XC_CM_Provisioning_Template_Association__mdt> listTemplateAssociation = new List<XC_CM_Provisioning_Template_Association__mdt>([
                SELECT XC_CM_Country__c, XC_CM_Billing_Method__c, XC_CM_Channel__c, 
                    XC_CM_Order_Type__c, XC_CM_Product_Service_Category__c, 
                    XC_CM_Provider__c, XC_CM_Template_Name__c,XC_SpareParts__c, XC_BundleBit2Win__c, XC_CM_Catalog_Item__c,
                    XC_CM_OrderSubtype__c, XC_CM_Action__c, XC_CM_PaymentMethod__c, XC_CM_ProductSubtype__c, XC_DeliveryMethod__c
                    FROM XC_CM_Provisioning_Template_Association__mdt
                    WHERE XC_CM_Country__c IN: countryValueSet 
                    AND XC_CM_Order_Type__c IN: orderTypeValueSet
                    AND XC_CM_OrderSubtype__c IN: orderSubTypeValueSet
                    AND XC_CM_Action__c IN: orderItemActionValueSet
                    AND XC_CM_Product_Service_Category__c IN: productServiceCategoryValueSet 
                    AND XC_CM_Catalog_Item__c IN: catalogItemSet
                    AND XC_CM_Billing_Method__c IN: billingMethodValueSet
                    AND XC_CM_PaymentMethod__c IN: paymentMethodValueSet
                    AND XC_CM_ProductSubtype__c IN : productSubtypeValueSet
                    //AND XC_CM_Channel__c IN: channelValueSet   
                    //AND XC_CM_Provider__c IN: providerValueSet
                    ORDER BY XC_CM_PaymentMethod__c DESC, XC_CM_OrderSubtype__c DESC ,XC_CM_Catalog_Item__c DESC, XC_CM_ProductSubtype__c DESC
        ]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '#### listTemplateAssociation' + listTemplateAssociation);
        return listTemplateAssociation;  
    }  
}