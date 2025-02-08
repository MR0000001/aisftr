/**
* @author Davide De Dona - Davide.DeDona@nttdata.com 
* @date Creation 27/11/2018
* @date Modification 06/06/2019 - Salvatore Scarpato salvatore.scarpato@nttdata.com
* @description XC_TR_ConfigurationItem_U_UpdateAsset
*/
public without sharing class XC_TR_ConfigurationItem_U_UpdateAsset {

    private final static Boolean DEBUGACTIVE = true; //XC_UTIL_Debug.isActive('XC_TR_ConfigurationItem_U_UpdateAsset');

    /**
     * @description Update on status completed
     * @param confItemUpdate the conf item update
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void updateBillingProfileLineItemOnAsset(List<NE__OrderItem__c> confItemUpdate, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ENTER IN XC_TR_ConfigurationItem_U_UpdateAsset.updateBillingProfileLineItemOnAsset');
        List<String> fieldList = new List<String>{'XC_BillingProfileLineItem__c'};  
        List<NE__OrderItem__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
        	updateBpliOnAsset(listChanged);
        }
    } 
 
    private static void updateBpliOnAsset(List<NE__OrderItem__c> listChanged){
        
        Map<String, Asset> checkAssetMap = checkAsset(listChanged);
        List<Asset> assetsToUpdate = new List<Asset>();
        for(NE__OrderItem__c orderItem : listChanged){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@0606 orItem changed before-->'+ orderItem);
            if(checkAssetMap.containsKey(orderItem.Id) && checkAssetMap.get(orderItem.Id) != null){
                Asset ast = checkAssetMap.get(orderItem.Id);
                ast.XC_BillingProfileLineItem__c = orderItem.XC_BillingProfileLineItem__c;
                ast.XC_PaymentMethod__c = orderItem.XC_PaymentMethod__c;
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@0606 orItem changed -->'+ orderItem);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@0606 XC_BillingProfileLineItem__c -->'+ orderItem.XC_BillingProfileLineItem__c);
                assetsToUpdate.add(ast);
            }
        }

        XC_UTIL_Sobject.updateListRecords(assetsToUpdate);
    }

    private static Map<String, Asset> checkAsset(List<NE__OrderItem__c> listChanged){
        Map<String, Asset> confItemIdAsset = new Map<String, Asset>();
        List<String> confItemIds = XC_UTIL_Sobject.getIds(listChanged);
        Map<Id, NE__OrderItem__c> conftItemMap = new Map<Id, NE__OrderItem__c>([SELECT Id, XC_BillingProfileLineItem__c, 
                                                (SELECT Id, XC_BillingProfileLineItem__c FROM Assets__r)  
                                                FROM NE__OrderItem__c 
                                                WHERE Id IN: confItemIds]);
        List<NE__OrderItem__c> conftItemList = conftItemMap.values();                       
        for(NE__OrderItem__c orderItem : conftItemList){
            if(!orderItem.Assets__r.isEmpty()){
                confItemIdAsset.put(orderItem.Id, orderItem.Assets__r[0]);
            } else {
                confItemIdAsset.put(orderItem.Id, null);
            }
        }
        return confItemIdAsset;
    }
    /**
     * @description Update on status completed
     * @param confItemUpdate the conf item update
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void updateOnStatusCompleted(List<NE__OrderItem__c> confItemUpdate, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){

        List<String> fieldList = new List<String>{'NE__Status__c'};  
        List<NE__OrderItem__c> listChanged = XC_UTIL_SObject.getListChanged( fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            Set<Id> idConfigurationItem = new Set<Id>();
            for(NE__OrderItem__c confi : listChanged){
                if( String.isEmpty(confi.NE__Bundle_Configuration__c) && mapold.get(confi.Id).NE__Status__c != Label.XC_CL_Configuration_OrderCancelled && mapNew.get(confi.Id).NE__Status__c==Label.XC_CL_Configuration_Item_Completed){
                    idConfigurationItem.add(confi.id);
                }
            }
            retrieveListAssetByConfItem(idConfigurationItem);
        }
    }

    /**
     * @description Retrieve List Asset By ConfItem
     * @param idConfigurationItem - Set<Id>
     */
    private static void retrieveListAssetByConfItem(Set<Id> idConfigurationItem) {
        if(!idConfigurationItem.isEmpty()){
            if(!Schema.sObjectType.Asset.isAccessible()){
                return;
            } 
            List<Asset> listOfAsset = [  SELECT  ID,XC_Configuration_Item__c,Status,XC_Configuration_Item__r.NE__Status__c
                                        FROM    Asset 
                                        WHERE   XC_Configuration_Item__r.Id In :idConfigurationItem];

            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@List of Asset ' + listOfAsset);

            populateFieldAsset(listOfAsset);
        }
    }

    /**
     * @description Populate Field Asset
     * @param listOfAsset - List<Asset>
     */
    private static void populateFieldAsset(List<Asset> listOfAsset) {
        Integer counter = 0;
        if(!listOfAsset.isEmpty()){     
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@PHASE 1');
            for(Asset asset :listOfAsset){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@Asset ' + counter);
                if(asset.XC_Configuration_Item__r.NE__Status__c==Label.XC_CL_Configuration_Item_Completed && asset.Status==Label.XC_CL_Asset_StatusPurchased){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@PHASE');
                    counter++;
                    asset.Status = Label.XC_CL_Asset_StatusActive;
                }
            }
            if(counter == listOfAsset.size()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@UPDATE THE LIST OF ASSET');
                XC_UTIL_SObject.updateListRecords(listOfAsset);
            }   
        }
    }

    /**
     * @description Update original billing profile
     * @param confItemUpdate the conf item update
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void updateOriginalBillingProfile(List<NE__OrderItem__c> confItemUpdate, Map<Id,NE__OrderItem__c> mapOld, Map<Id,NE__OrderItem__c> mapNew){
        List<String> fieldList = new List<String>{'NE__BillingProfId__c'};  
        List<NE__OrderItem__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){ 
            if(! mapNew.keySet().isEmpty()){
                List<Asset> listOfAsset= [  SELECT  Id, XC_OriginalBillingProfile__c, XC_Original_Creation_OrderItem__c
                                            FROM    Asset 
                                            WHERE   XC_Original_Creation_OrderItem__c IN: mapNew.keySet()];

                for(Asset ast : listOfAsset){
                    ast.XC_OriginalBillingProfile__c = mapNew.get(ast.XC_Original_Creation_OrderItem__c).NE__BillingProfId__c;
                }
                XC_UTIL_SObject.updateListRecords(listOfAsset);
            }
        }
    }
}