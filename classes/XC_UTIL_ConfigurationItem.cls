/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 26/11/2018
* @description XC_UTIL_ConfigurationItem – Util class for Cart Configuration Item methods
*/ 

public without sharing class XC_UTIL_ConfigurationItem {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ConfigurationItem');

    /** @description CheckBillingProfileWrapper */
    public class CheckBillingProfileWrapper {
        public Boolean checkBillingProfile = false;
        public List<NE__OrderItem__c> listOrderItem = new List<NE__OrderItem__c>();
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @description Method to determine if a configuration item Product type represents a Real Product
     * @return Boolean
     * @param prodName
    **/ 
    public static Boolean isThisARealProduct(String prodName){
        Map<String, Boolean> mapConfItemReal = getMapRealProducts(new List<String>{prodName});
        return mapConfItemReal.get(prodName);
    }
    
    /**
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description New method to determine if a configuration item Product type represents a Real Product - it is based on the custom metadata
                    that defines if a configuration item needs provisioning (cm: Provisioning Template Associations);
     * @param listProdName
     * @return mapConfItemReal
    **/ 
    public static Map<String, Boolean> getMapRealProducts(List<String> listProdName){
        Map<String, Boolean> mapConfItemReal = new Map<String, Boolean>(); 
        List<XC_CM_Provisioning_Template_Association__mdt> listCM = new List<XC_CM_Provisioning_Template_Association__mdt> ([
            SELECT Id, XC_CM_Product_Service_Category__c 
            FROM XC_CM_Provisioning_Template_Association__mdt
            WHERE XC_CM_Product_Service_Category__c IN:listProdName]);
        if(!listCM.isEmpty()){
            List<String> isRealProdNameList = XC_UTIL_Sobject.getListFieldValues(listCM, 'XC_CM_Product_Service_Category__c');
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'listCM: '+listCM);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'isRealProdNameList: '+isRealProdNameList);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'listProdName: '+listProdName);
            Set<String> isRealProdNameSet = new Set<String>();
            for(String prod : isRealProdNameList){
                isRealProdNameSet.add(prod.toLowerCase());
            } 
            for(String prodName : listProdName){
                if(isRealProdNameSet.isEmpty()||prodName==null){
                    continue;
                }
                if(isRealProdNameSet.contains(prodName.toLowerCase())){
                    mapConfItemReal.put(prodName, true);
                } else {
                    mapConfItemReal.put(prodName, false);
                }
            }
        } 
        return mapConfItemReal;
    }

    /**
    * @description Get a map with OI Id as Keys and Site Inspection as Values
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 30/10/2019 
    * @param oiList 
    * @return Map<Id, Boolean> 
    **/
    public static Map<Id, Boolean> getOrderItemSiteInspectionMap(List<NE__OrderItem__c> oiList){
        Map<Id, Boolean> orderItemSiteInspectionMap = new Map<Id, Boolean>();
        for (NE__OrderItem__c oi : oiList) {
            //! TODO si deve creare un campo Boolean chiamato Site Inspection, isPromo è temporaneo e solo per testare
            orderItemSiteInspectionMap.put(oi.Id, oi.NE__IsPromo__c); 
        }
        return orderItemSiteInspectionMap;
    }

    /**
     * @description returns a map with OI and a list of Maps that represent configuration item attributes
     * @author Francesco Imperioli - fimperioli@deloitte.it
     * @return Map<Id,List<Map,String,String>>
     */
    public static Map<Id,List<Map<String,String>>> getOrderItemAttributeNameValueMap(List<String> oiIds){
        //querying attributes and map the values as strings
        Map<Id,NE__Order_Item_Attribute__c> oiAttrMap = new Map<Id,NE__Order_Item_Attribute__c>([SELECT Id,Name,XC_DeveloperName__c,NE__Value__c,NE__Order_Item__c 
        FROM NE__Order_Item_Attribute__c 
        WHERE NE__Order_Item__c IN : oiIds]);

        Map<Id,List<Map<String,String>>> result = new Map<Id,List<Map<String,String>>>();

        for(NE__Order_Item_Attribute__c attr : oiAttrMap.values()){
            Map<String,String> tmpMap = new Map<String,String>{attr.XC_DeveloperName__c=>attr.NE__Value__c};
            if(result.containsKey(attr.NE__Order_Item__c)){
                result.get(attr.NE__Order_Item__c).add(tmpMap);
            }else{
                List<Map<String,String>> tmpList = new List<Map<String,String>>{tmpMap};
                result.put(attr.NE__Order_Item__c,tmpList);
            }
        }
        return result;
    }

    /**
     * @description returns a map with OI and a list of orderitem attributes
     * @author Francesco Imperioli - fimperioli@deloitte.it
     * @return Map<Id,List<Map,String,String>>
     */
    public static Map<Id,List<NE__Order_Item_Attribute__c>> getOrderItemAttributeMap(List<String> oiIds){
        Map<Id,NE__Order_Item_Attribute__c> oiAttrMap = new Map<Id,NE__Order_Item_Attribute__c>([SELECT Id,Name,XC_DeveloperName__c,NE__Value__c,NE__Order_Item__c 
        FROM NE__Order_Item_Attribute__c 
        WHERE NE__Order_Item__c IN : oiIds]);
        Map<Id,List<NE__Order_Item_Attribute__c>> result = new Map<Id,List<NE__Order_Item_Attribute__c>>();
        for(NE__Order_Item_Attribute__c attr : oiAttrMap.values()){
            if(result.containsKey(attr.NE__Order_Item__c)){
                result.get(attr.NE__Order_Item__c).add(attr);
            }else{
                List<NE__Order_Item_Attribute__c> tmpList = new List<NE__Order_Item_Attribute__c>{attr};
                result.put(attr.NE__Order_Item__c,tmpList);
            }
        }
        return result;
    }

    /**
     * @description Method to check BPLI and to get correct Order Item
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listOrderItem - List<NE__OrderItem__c>
     * @param fromOperation - String
     * @return CheckBillingProfileWrapper
     */
    public static CheckBillingProfileWrapper getCorrectBillingProfile(List<NE__OrderItem__c> listOrderItem, String fromOperation) {
        CheckBillingProfileWrapper outputWrapper = new CheckBillingProfileWrapper();
        // Calculate list for this check:
        List<NE__OrderItem__c> listOrderItemToBeProcessed = new List<NE__OrderItem__c>();
        for(NE__OrderItem__c oi : listOrderItem) {
            Boolean isItalianNoPaymentRequired = (oi.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_Italy || oi.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia || oi.XC_LegalEntityFormula__c == 'EnelXMobilitySpain' || FeatureManagement.checkPermission('XC_Brazil_MVP'))  && (oi.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_NoPaymentRequired || oi.XC_PaymentMethod__c == Label.XC_CL_PaymentMethod_CommodityOffer); //DCR 17022022 - Add condition for MVP Brazil
            if(!isItalianNoPaymentRequired) {
                listOrderItemToBeProcessed.add(oi);
            }
        }
        // Check for billing profile:
        Map<String, List<NE__OrderItem__c>> mapLegalEntityOrderItem = new Map<String, List<NE__OrderItem__c>>();
        List<String> listLegalEntity = new List<String>();
        for(NE__OrderItem__c oi : listOrderItemToBeProcessed) {
            if(!mapLegalEntityOrderItem.containsKey(oi.XC_LegalEntityFormula__c+'_'+oi.XC_Segment__c)) {
                mapLegalEntityOrderItem.put(oi.XC_LegalEntityFormula__c+'_'+oi.XC_Segment__c, new List<NE__OrderItem__c>());
                listLegalEntity.add(oi.XC_LegalEntityFormula__c);
            }
            mapLegalEntityOrderItem.get(oi.XC_LegalEntityFormula__c+'_'+oi.XC_Segment__c).add(oi);
        }

        List<XC_CM_LegalEntity_Configuration__mdt> listCMconf = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BillingProfileMandatoryOn__c, XC_LegalEntity__c, XC_Stream__c
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_BillingProfileMandatoryOn__c != null AND XC_LegalEntity__c IN :listLegalEntity
        ]);
        
        //20220126 HotTopic_PROV_41 - [DO] – start        
        if(fromOperation == 'Change of ownership') {
            outputWrapper.checkBillingProfile = true;
            for(NE__OrderItem__c oi : listOrderItemToBeProcessed) {
                
                if(oi.XC_PaymentMethodNeeded__c) {
                    if(String.isBlank(oi.XC_BillingProfileLineItem__c) && oi.XC_BillingModel__c != 'Capex') {
                        outputWrapper.checkBillingProfile = false;
                    } else {
                        outputWrapper.listOrderItem.add(oi);
                    }
                }
            }
            return outputWrapper;
        }
        //20220126 HotTopic_PROV_41 - [DO] – end

        Map<String, String> mapLEcheck = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt conf : listCMconf) {
            mapLEcheck.put(conf.XC_LegalEntity__c+'_'+conf.XC_Stream__c, conf.XC_BillingProfileMandatoryOn__c);
        }

        outputWrapper.checkBillingProfile = true;
        for(String keyLeSeg : mapLegalEntityOrderItem.keySet()) {
            String operationAllowed = mapLEcheck.containsKey(keyLeSeg) ? mapLEcheck.get(keyLeSeg) : '';
            if(operationAllowed.split(',').contains(fromOperation)) {
                for(NE__OrderItem__c oi : mapLegalEntityOrderItem.get(keyLeSeg)) {
                    if(oi.XC_PaymentMethodNeeded__c) {
                        if(String.isBlank(oi.XC_BillingProfileLineItem__c) && oi.XC_BillingModel__c != 'Capex') {
                            outputWrapper.checkBillingProfile = false;
                        } else {
                            outputWrapper.listOrderItem.add(oi);
                        }
                    }
                }
            }
        }

        return outputWrapper;
    }

    /**
     * @description Method to check BPLI
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @param listOrderItem - List<NE__OrderItem__c>
     * @param fromOperation - String
     * @return Boolean
     */
    public static Boolean checkBillingProfile(List<NE__OrderItem__c> listOrderItem, String fromOperation){
        return getCorrectBillingProfile(listOrderItem, fromOperation).checkBillingProfile;
    }

}