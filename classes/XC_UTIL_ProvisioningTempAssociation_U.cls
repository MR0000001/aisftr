/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 23/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ProvisioningTempAssociation_U – Methods for check match for XC_UTIL_ProvisioningTemplateAssociation
*/ 

public without sharing class XC_UTIL_ProvisioningTempAssociation_U {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ProvisioningTempAssociation_U');

    /** @description Wrapper for Exact Match */
    public class MatchWrapper {
        public Map<Id, String> mapConfItemTemplateName = new Map<Id, String>();
        public Map<Id, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper> mapConfItemIdWrapper = new Map<Id, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper>();
        public List<XC_CM_Provisioning_Template_Association__mdt> listSteps = new List<XC_CM_Provisioning_Template_Association__mdt>();
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description This method matches all the field of the Wrapper with all the fields of a XC_CM_Provisioning_Template_Association__mdt Custom Metadata
    * @param confItemId - String
    * @param exactMatchWrapper - MatchWrapper
    **/ 
    public static void checkExactMatch(String confItemId, MatchWrapper exactMatchWrapper) {
        XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper = exactMatchWrapper.mapConfItemIdWrapper.get(confItemId);
        for(XC_CM_Provisioning_Template_Association__mdt stepMD : exactMatchWrapper.listSteps){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '#### wrapper' + wrapper);
            if(checkConditionsExactMatch(stepMD, wrapper)
                && wrapper.country == stepMD.XC_CM_Country__c
                && wrapper.bit2winBundle == stepMD.XC_BundleBit2Win__c
                && wrapper.billingMethod == stepMD.XC_CM_Billing_Method__c
                && wrapper.spareParts == stepMD.XC_SpareParts__c
                && wrapper.paymentMethod == stepMD.XC_CM_PaymentMethod__c
                && (checkDeliveryMethod(stepMD, wrapper) || checkPhotovoltaicScenario(stepMD, wrapper) || checkAccessoriesInventoryScenario(stepMD, wrapper) || checkAirConditioningChileScenario(stepMD, wrapper) || checkHiddenProductItalyScenario(stepMD, wrapper) )
                //&& wrapper.channel == stepMD.XC_CM_Channel__c  
                //wrapper.provider == stepMD.XC_CM_Provider__c
            ){
                exactMatchWrapper.mapConfItemTemplateName.put(confItemId, stepMD.XC_CM_Template_Name__c);
                break;
            }
        }
    }

    /**
    * @description Method to check conditions for Exact Match (For cyclomatic complexity)
    * @param stepMD - XC_CM_Provisioning_Template_Association__mdt
    * @param wrapper - ConfigurationItemWrapper
    * @return Boolean
    **/ 
    private static Boolean checkConditionsExactMatch(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper) {
        if(wrapper.orderType == stepMD.XC_CM_Order_Type__c 
            && wrapper.orderSubType == stepMD.XC_CM_OrderSubtype__c
            && wrapper.orderItemAction == stepMD.XC_CM_Action__c            
            && wrapper.productServiceCategory == stepMD.XC_CM_Product_Service_Category__c
            && wrapper.catalogItem == stepMD.XC_CM_Catalog_Item__c
            && wrapper.productSubtype == stepMD.XC_CM_ProductSubtype__c
            ) {
                return true;
        }
        return false;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @description This method matches all the field of the Wrapper with all the fields of a XC_CM_Provisioning_Template_Association__mdt Custom Metadata or with the wildcard '*' for certain fields
    * @param confItemId - String
    * @param exactMatchWrapper - MatchWrapper
    **/ 
    public static void checkWildCardMatch(String confItemId, MatchWrapper exactMatchWrapper) {
        XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper = exactMatchWrapper.mapConfItemIdWrapper.get(confItemId);
        for(XC_CM_Provisioning_Template_Association__mdt stepMD : exactMatchWrapper.listSteps){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '#### wrapper' + wrapper);
            if(checkConditionsWildCardMatch(stepMD, wrapper)
                && wrapper.country == stepMD.XC_CM_Country__c
                && (wrapper.billingMethod == stepMD.XC_CM_Billing_Method__c || stepMD.XC_CM_Billing_Method__c =='*')
                && (wrapper.paymentMethod == stepMD.XC_CM_PaymentMethod__c || stepMD.XC_CM_PaymentMethod__c == '*')
                && wrapper.bit2winBundle == stepMD.XC_BundleBit2Win__c 
                && wrapper.spareParts == stepMD.XC_SpareParts__c
                //&& wrapper.channel == stepMD.XC_CM_Channel__c
                //&&wrapper.provider == stepMD.XC_CM_Provider__c   
            ){
                exactMatchWrapper.mapConfItemTemplateName.put(confItemId, stepMD.XC_CM_Template_Name__c);
                break;
            }
        } 
    }

    /**
    * @description Method to check conditions for WildCard Match (For cyclomatic complexity)
    * @param stepMD - XC_CM_Provisioning_Template_Association__mdt
    * @param wrapper - ConfigurationItemWrapper
    * @return Boolean
    **/ 
    private static Boolean checkConditionsWildCardMatch(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper) {
        if(wrapper.orderType == stepMD.XC_CM_Order_Type__c
            && (wrapper.orderSubType == stepMD.XC_CM_OrderSubtype__c || stepMD.XC_CM_OrderSubtype__c == '*')
            && (wrapper.orderItemAction == stepMD.XC_CM_Action__c || stepMD.XC_CM_Action__c == '*')          
            && wrapper.productServiceCategory == stepMD.XC_CM_Product_Service_Category__c
            && chechCatalogItem(stepMD, wrapper)
            && checkProductSubtype(stepMD, wrapper)
            && (checkDeliveryMethod(stepMD, wrapper) || checkPhotovoltaicScenario(stepMD, wrapper) || checkAccessoriesInventoryScenario(stepMD, wrapper)) || checkAirConditioningChileScenario(stepMD, wrapper) || checkHiddenProductItalyScenario(stepMD, wrapper) ) {  
                return true;
        }
        return false;
    }
    
    private static Boolean chechCatalogItem(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper){
        if(wrapper.catalogItem == stepMD.XC_CM_Catalog_Item__c || stepMD.XC_CM_Catalog_Item__c == '*'){
            return true;
        }
        return false;
    }

    private static Boolean checkProductSubtype(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper){
        if(wrapper.productSubtype == stepMD.XC_CM_ProductSubtype__c || stepMD.XC_CM_ProductSubtype__c == '*'){
            return true;
        }
        return false;
    }
    private static Boolean checkDeliveryMethod(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper){
        return ( !checkHiddenProductItaly(stepMD, wrapper) && !checkAirConditioningChile(stepMD) && stepMD.XC_CM_Product_Service_Category__c != 'Photovoltaic' && stepMD.XC_CM_Product_Service_Category__c != 'Photovoltaic Plug And Play' && stepMD.XC_CM_Product_Service_Category__c != 'Accessories Inventory') && ( (stepMD.XC_BundleBit2Win__c == true && wrapper.bit2winBundle == true) || (stepMD.XC_BundleBit2Win__c == false && wrapper.bit2winBundle == false   
               && (wrapper.deliveryMethod == null || (wrapper.deliveryMethod != null && wrapper.deliveryMethod == stepMD.XC_DeliveryMethod__c))));  
    }

    private static Boolean checkPhotovoltaicScenario(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper){
        return (stepMD.XC_CM_Product_Service_Category__c == 'Photovoltaic' || stepMD.XC_CM_Product_Service_Category__c == 'Photovoltaic Plug And Play') && stepMD.XC_BundleBit2Win__c == true && wrapper.bit2winBundle == true 
            && wrapper.deliveryMethod == stepMD.XC_DeliveryMethod__c;
    }

    private static Boolean checkAccessoriesInventoryScenario(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper){    
        return stepMD.XC_CM_Product_Service_Category__c == 'Accessories Inventory' && stepMD.XC_BundleBit2Win__c == true && wrapper.bit2winBundle == true        
            && wrapper.deliveryMethod == stepMD.XC_DeliveryMethod__c;      
    }     

    private static Boolean checkAirConditioningChileScenario(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper){  
        return checkAirConditioningChile(stepMD) && ((stepMD.XC_BundleBit2Win__c == true && wrapper.bit2winBundle == true) || (stepMD.XC_BundleBit2Win__c == false && wrapper.bit2winBundle == false ))
                    && wrapper.deliveryMethod == stepMD.XC_DeliveryMethod__c;
    }  

    private static Boolean checkAirConditioningChile(XC_CM_Provisioning_Template_Association__mdt stepMD){  
        List<String> categories = new List<String>{'Accessories Inventory','Air conditioning','Electric Vehicle Recharge','Fans','Heater','Instalación Calefactores de Piscina','Photovoltaic','Pool Heater','Technical Catalog','Termo','Electric Hob'};
        return (categories.contains(stepMD.XC_CM_Product_Service_Category__c) )  && stepMD.XC_CM_Country__c == 'Chile';  
    }  
    private static Boolean checkHiddenProductItaly(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper){ 
        return stepMD.XC_CM_Product_Service_Category__c == 'Hidden Products' && stepMD.XC_CM_Country__c == 'Italy' && stepMD.XC_BundleBit2Win__c == false && wrapper.bit2winBundle == false;  
    }  
    private static Boolean checkHiddenProductItalyScenario(XC_CM_Provisioning_Template_Association__mdt stepMD, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper){ 
        return checkHiddenProductItaly(stepMD,wrapper) && wrapper.deliveryMethod == stepMD.XC_DeliveryMethod__c && wrapper.productServiceCategory == stepMD.XC_CM_Product_Service_Category__c;  
    }  
}