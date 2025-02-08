/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 11/05/2019
* @description XC_UTIL_WBE_U – Util class for WBE
*/ 

public without sharing class XC_UTIL_WBE_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_WBE'); 
     
    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method for Product Line and Product Service Type for WBE
    * @param idCatalogItem - String
    * @return NE__Catalog_Item__c 
    */
    public static NE__Catalog_Item__c getCodeFromCatalogItem(String idCatalogItem) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getCodeFromCatalogItem START');
        Map<Id, NE__Catalog_Item__c> mapCatalogItem = new Map<Id, NE__Catalog_Item__c>([SELECT XC_ProductLine__c, XC_ProductServiceType__c 
                                                                                        FROM NE__Catalog_Item__c 
                                                                                        WHERE Id =: idCatalogItem]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getCodeFromCatalogItem END');
        return mapCatalogItem.values().isEmpty() ? new NE__Catalog_Item__c() : mapCatalogItem.values()[0];                                                                                 
    }
    
    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @param listOrderItem - List<NE__OrderItem__c>
    * @param mapOrder - Map<Id, NE__Order__c>
    * @description Method to retrieve a map where key->CompanyName and value->CompanyCode
    * @return Map<String, String> 
    */
    public static Map<String, String> getMapCompanyCode(List<NE__OrderItem__c> listOrderItem, Map<Id, NE__Order__c> mapOrder) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapCompanyCode(listOrderItem, mapOrder) START');
        Map<String, String> mapCompanyCode = new Map<String, String>(); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapCompanyCode(listOrderItem, mapOrder) Verify accessible');
        if(!Schema.sObjectType.XC_CM_LegalEntity_Configuration__mdt.isAccessible()){
            mapCompanyCode.put('', '0000');
	        return mapCompanyCode;
        }
        List<XC_CM_LegalEntity_Configuration__mdt> listCompanyCM = [ 
            SELECT XC_LegalEntity__c , XC_CompanyCode__c
            FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_OrgId__c =: UserInfo.getOrganizationId() LIMIT 50000
        ];
        Map<String, String> mapCompanyCM = new Map<String, String>();
        for(XC_CM_LegalEntity_Configuration__mdt companyCM : listCompanyCM) {
            mapCompanyCM.put(companyCM.XC_LegalEntity__c , companyCM.XC_CompanyCode__c);
        }
        for(NE__OrderItem__c orderItem : listOrderItem) {
            String checkCompanyName = mapOrder.get(orderItem.NE__OrderId__c).NE__OptyId__r.XC_LegalEntity__c; 
            if(mapCompanyCM.containsKey(checkCompanyName)) {
                mapCompanyCode.put(checkCompanyName, mapCompanyCM.get(checkCompanyName));
            } else {
                mapCompanyCode.put(checkCompanyName, '0000');
            }
        }
        //If null, it returns '0'
        if(mapCompanyCode.isEmpty()) {
            mapCompanyCode.put('', '0000');
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - mapCompanyCode: ' + mapCompanyCode);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapCompanyCode(listOrderItem, mapOrder) END');
        return mapCompanyCode;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method to retrieve a list of possible values of Company code
    * @return List<String>
    */
    public static List<String> getMapCompanyCode() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapCompanyCode START');
        List<String> listCompanyCode = new List<String>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapCompanyCode Verify accessible');
        if(!Schema.sObjectType.XC_CM_LegalEntity_Configuration__mdt.isAccessible()){
            listCompanyCode.add('0000');
	        return listCompanyCode;
        }
        List<XC_CM_LegalEntity_Configuration__mdt> listCompanyCM = [
            SELECT XC_LegalEntity__c, XC_CompanyCode__c
            FROM XC_CM_LegalEntity_Configuration__mdt WHERE XC_OrgId__c =: UserInfo.getOrganizationId() LIMIT 50000
        ];
        for(XC_CM_LegalEntity_Configuration__mdt cmCompany : listCompanyCM) {
            listCompanyCode.add(cmCompany.XC_CompanyCode__c);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - listCompanyCode: ' + listCompanyCode);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapCompanyCode END');
        return listCompanyCode;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method to retrieve a map where key->BusinessModelName and value->BusinessModelCode
    * @param listOrderItem - List<NE__OrderItem__c>
    * @param mapOrder - Map<Id, NE__Order__c>
    * @return Map<String, String>
    */ 
    public static Map<String, String> getMapBusinessModel(List<NE__OrderItem__c> listOrderItem, Map<Id, NE__Order__c> mapOrder) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapBusinessModel(listOrderItem, mapOrder) START');
        Map<String, String> mapBusinessModelCode = new Map<String, String>();
        for(NE__OrderItem__c orderItem : listOrderItem) {
            String billingModel = orderItem.XC_BillingModel__c;
            if(!String.isBlank(billingModel)) { 
                if(billingModel.contains(Label.XC_CL_ConfigurationItem_Renting)) {
                    mapBusinessModelCode.put(orderItem.Id, '3');
                } else if(billingModel == Label.XC_CL_ExternalFinancing) {
                    mapBusinessModelCode.put(orderItem.Id, '4');
                } else if(billingModel == Label.XC_CL_BillingModel_Recurring) {
                    mapBusinessModelCode.put(orderItem.Id, '2');
                } else {
                    mapBusinessModelCode.put(orderItem.Id, '1');
                }
            }
        }

        //If null, it returns '0'
        if(mapBusinessModelCode.isEmpty()) {
            mapBusinessModelCode.put('', '0');
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - mapBusinessModelCode: ' + mapBusinessModelCode);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapBusinessModel(listOrderItem, mapOrder) END');
        return mapBusinessModelCode;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method to retrieve a possible values for Business Model
    * @return List<String>
    */ 
    public static List<String> getMapBusinessModel() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapBusinessModel');
        return new List<String>{'1', '2', '3', '4'};
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method to retrieve a map where key->ChannelName and value->ChannelCode
    * @param listOrderItem - List<NE__OrderItem__c>
    * @param mapOrder - Map<Id, NE__Order__c>
    * @return Map<String, String> 
    */
    public static Map<String, String> getMapChannel(List<NE__OrderItem__c> listOrderItem, Map<Id, NE__Order__c> mapOrder) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapChannel(listOrderItem, mapOrder) START');
        Map<String, String> mapChannelCode = new Map<String, String>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapChannel(listOrderItem, mapOrder) Verify accessible');
        if(!Schema.sObjectType.XC_CM_WBEChannelMapping__mdt.isAccessible()){
            mapChannelCode.put('', '0');
	        return mapChannelCode;
        }
        List<XC_CM_WBEChannelMapping__mdt> listChannelCM = [ 
            SELECT XC_ChannelName__c, XC_ChannelCode__c
            FROM XC_CM_WBEChannelMapping__mdt LIMIT 50000
        ];
        Map<String, String> mapChannelCM = new Map<String, String>();
        for(XC_CM_WBEChannelMapping__mdt channelCM : listChannelCM) {
            mapChannelCM.put(channelCM.XC_ChannelName__c, channelCM.XC_ChannelCode__c);
        }
        for(NE__OrderItem__c orderItem : listOrderItem) {
            String checkChannelName = mapOrder.get(orderItem.NE__OrderId__c).NE__OptyId__r.XC_ReceivingChannel__c; 
            if(mapChannelCM.containsKey(checkChannelName)) {
                mapChannelCode.put(checkChannelName, mapChannelCM.get(checkChannelName));
            } else {
                mapChannelCode.put(checkChannelName, 'X');
            }
        }

        //If null, it returns '0'
        if(mapChannelCode.isEmpty()) {
            mapChannelCode.put('', '0');
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - mapChannelCode: ' + mapChannelCode);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapChannel(listOrderItem, mapOrder)  END');
        return mapChannelCode;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
    * @date Creation 02/05/2019
    * @description Method to retrieve a list of possible channel code
    * @return List<String> 
    */
    public static List<String> getMapChannel() {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapChannel START');
        List<String> listChannelCode = new List<String>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapChannel Verify accessible');
        if(!Schema.sObjectType.XC_CM_WBEChannelMapping__mdt.isAccessible()){
            listChannelCode.add('0');
	        return listChannelCode;
        }
        List<XC_CM_WBEChannelMapping__mdt> listChannelCM = [
            SELECT XC_ChannelName__c, XC_ChannelCode__c
            FROM XC_CM_WBEChannelMapping__mdt LIMIT 50000
        ];
        for(XC_CM_WBEChannelMapping__mdt cmChannel : listChannelCM) {
            listChannelCode.add(cmChannel.XC_ChannelCode__c);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - listChannelCode: ' + listChannelCode);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ XC_UTIL_WBE_U - getMapChannel END');
        return listChannelCode;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 30/03/2020
     * @description Method to recalculate WBE for ProdName and LegalEntity
     * @param wrapper - WBEWrapper
     * @param orderItem - NE__OrderItem__c
     * @param listOrderItems - List<NE__OrderItem__c>
     * @return String
     */
    public static String recalculationWBE(XC_UTIL_WBE.WBEWrapper wrapper, NE__OrderItem__c orderItem, List<NE__OrderItem__c> listOrderItems) {
        String wbe = '';

        //******************************************************************************* Check for Subsidy: 
        if(orderItem.XC_Product_Type__c == 'Billing' && orderItem.XC_Product_Subtype__c == 'Promotion' && String.isNotBlank(orderItem.XC_RelatedProduct__c)) {
            for(NE__OrderItem__c oi : listOrderItems) {
                if(orderItem.XC_RelatedProduct__c == oi.NE__Item_Code__c && orderItem.NE__OrderId__c == oi.NE__OrderId__c) {
                    wbe = oi.XC_WBE__c;
                    break;
                }
            }
        } else {
            wbe = XC_UTIL_WBE.getWBE(wrapper);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WBE recalculated -> ' + wbe);
            if(wbe.length() > XC_UTIL_WBE.numberDigit) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ERROR: WBE is too long!');
            }
        }
        /*Boolean subsidyFound = false;
        if(orderItem.NE__ProdName__c != Label.XC_CL_SubsidyProductName) {
            wbe = XC_UTIL_WBE.getWBE(wrapper);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WBE recalculated -> ' + wbe);
            if(wbe.length() > XC_UTIL_WBE.numberDigit) {
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ERROR: WBE is too long!');
            }
            subsidyFound = true;
        }
        if(!subsidyFound) {
            for(NE__OrderItem__c oi : listOrderItems) {
                if(orderItem.id == oi.NE__Parent_Order_Item__c && oi.XC_WBE__c != null) {
                    wbe = oi.XC_WBE__c;
                }
            }
        }*/

        //******************************************************************************* Check for LegalEntity: 
        if(String.isBlank(orderItem.XC_WBE__c) && String.isBlank(wbe)) {  
            return '';   
        }    
        List<String> tempWbe = String.isNotBlank(wbe) ? wbe.split('') : orderItem.XC_WBE__c.split('');   
        if((orderItem.XC_LegalEntityFormula__c == Label.XC_CL_EndesaX || orderItem.XC_LegalEntityFormula__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain) && tempWbe.size() == 18) {   
            tempWbe[8] = 'M';
            tempWbe[9] = 'R';
        }
        
        // For digit channel (digit 18):
        List<String> listLegalEntityToSkipDefaultValue = new List<String>{};
        if(!listLegalEntityToSkipDefaultValue.contains(orderItem.XC_LegalEntityFormula__c) && tempWbe.size() == 18) {
            tempWbe[17] = '0';
        } 
        
        wbe = String.join(tempWbe, '');

        return wbe;
    }
    
}