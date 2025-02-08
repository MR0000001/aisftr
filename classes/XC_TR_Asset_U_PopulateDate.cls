/**
 * The Class XC_TR_Asset_U_PopulateDate.
 *
 * @author Salvatore Scarpato salvatore.scarpato@nttdata.com
 * @date Creation 07/02/2019
 * @date Modification dd/mm/yyyy
 * @description  – Class to populate Date on Asset
 */
public without sharing class XC_TR_Asset_U_PopulateDate {

    /**
     * @description Populate purchased date on insert.
     * @param listNew the list new
     */
    public static void populatePurchasedDateOnInsert(List<Asset> listNew){
        for(Asset a : listNew){
            if(a.Status == Label.XC_CL_Asset_StatusPurchased){ 
                a.PurchaseDate = Date.Today();
            }
        }
    }

    /* @description Populate ActivationDate on Update .
     * @param listNew
     * @param mapOld
     * @param mapNew
     */
    public static void populateActivationDateOnUpdate(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        //START DATE MANAGEMENT
        List<String> fieldList = new List<String>{'XC_ActivationDate__c'};
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        // 
        List<String> confItemList = XC_UTIL_Sobject.getListFieldValues(listChanged, 'XC_Configuration_Item__c');
        Map<Id,List<NE__Order_Item_Attribute__c>> mapConfigurationItemListAttribute=XC_UTIL_ConfigurationItem.getOrderItemAttributeMap(confItemList);
        //
        if(!listChanged.isEmpty()){
            for(Asset a : listChanged){
                if(a.XC_ContractStartDate__c == null) a.XC_ContractStartDate__c = Date.valueOf(a.XC_ActivationDate__c);
            }
        }
        //END DATE MANAGEMENT //[MC 20191115]
        fieldList = new List<String>{'XC_ContractStartDate__c','XC_BillingModel__c'};
        listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            for(Asset ass : listChanged){
                List<NE__Order_Item_Attribute__c> listAttributeConfItem = ass.XC_Configuration_Item__c!=null && mapConfigurationItemListAttribute.containsKey(ass.XC_Configuration_Item__c) ? mapConfigurationItemListAttribute.get(ass.XC_Configuration_Item__c) : new List<NE__Order_Item_Attribute__c>();
                populateEndDateContract(ass,listAttributeConfItem);
                XC_TR_Asset_U_FillFields.populateRenewalDurationAsset(ass,listAttributeConfItem);
            }
        }
    }
    
    /**
     * @description populate EndDateContract on asset in input, 
     * adding months exspected by the selected XC_BillingModel__c
     * to the contract start date.
     * @param asset 
     */
    public static void populateEndDateContract(Asset asset,  List<NE__Order_Item_Attribute__c> listAttributeConfItem){
        if(asset.XC_ContractStartDate__c == null || asset.XC_BillingModel__c == null){
            return;
        }
       // Integer validityMonths = XC_UTIL_Asset.getActivationMonthsFromBillingModel(asset.XC_BillingModel__c);
        Integer validityMonths = XC_UTIL_Asset.getActivationMonths(asset.XC_BillingModel__c,listAttributeConfItem);
        if(validityMonths > 0) {
            if(asset.XC_ContractEndDate__c == null) asset.XC_ContractEndDate__c = (asset.XC_ContractStartDate__c).addMonths(validityMonths);
        }
    }
    
    /**
     * @description Update installed date on update.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    /*public static void updateInstalledDateOnUpdate(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<Asset> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            for(Asset a : listChanged){
                if(a.Status == Label.XC_CL_Asset_StatusInstalled){
                    a.InstallDate = Date.today();
                }
            }
        }
    }*/
    
    /**
     * @description Update activation date on update.
     * @author Federica Tavera@nttdata.com
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @date Creation 07/02/2019
     * @date Modification dd/mm/yyyy
     * @description  – Method to populate Asset Activation Date when the Asset is in Status "Active"
     */
    /*public static void updateActivationDateOnUpdate(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<Asset> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<Asset> activeAssets = new List<Asset>();
        for(Asset a : listChanged) {
            if(a.Status == Label.XC_CL_Asset_StatusActive) {
                activeAssets.add(a);
            }
        }
        if(activeAssets.isEmpty()) {
            return;
        }

        Set<Id> orderIds = XC_UTIL_SObject.getSetIdsOnField(activeAssets, 'NE__Order_Config__c');
        Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([SELECT Id, XC_ActivationDateOverride__c FROM NE__Order__c WHERE Id IN: orderIds AND XC_ActivationDateOverride__c != null]);

        for(Asset a : activeAssets){
            a.XC_ActivationDate__c = (orderMap.containsKey(a.NE__Order_Config__c)) ? orderMap.get(a.NE__Order_Config__c).XC_ActivationDateOverride__c : System.now();
        }
    }*/

    /**
 * @description Update installed date on update.
 * @author Dario Tramontin dtramontin@deloitte.it
 * @param listNew the list new
 * @param mapOld the map old
 * @param mapNew the map new
 */
    /*public static void updateDisconnectionDateOnUpdate(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<Asset> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            for(Asset a : listChanged){
                if(a.Status == Label.XC_CL_Asset_StatusInactive){
                    a.XC_DisconnectionDate__c = Date.today();
                }
            }
        }
    }*/


    /**
     * @description Update Installed, Disconnection and Activation date on update.
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void updateDatesOnUpdate(List<Asset> listNew, Map<Id,Asset> mapOld, Map<Id,Asset> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<Asset> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        
        List<Asset> activeAssets = new List<Asset>();
        for(Asset a : listChanged){
            if(a.Status == Label.XC_CL_Asset_StatusInactive){
                a.XC_DisconnectionDate__c = Date.today();
            } else if(a.Status == Label.XC_CL_Asset_StatusInstalled) {
                Id standardRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
                a.InstallDate = (a.RecordTypeId == standardRecordTypeId || a.InstallDate == null) ? Date.today() : a.InstallDate;
            } else if(a.Status == Label.XC_CL_Asset_StatusActive) {
                activeAssets.add(a);
            }
        }

        if(activeAssets.isEmpty()) {
            return;
        }
        Map<String,DateTime> orderItemActivationDateMap = new Map<String,DateTime>();
        Map<String,Date> orderItemEndDateMap = new Map<String,Date>();
        Map<String,Boolean> orderItemIDExistingWO= new Map<String, Boolean>();
        Set<Id> orderItemIds = XC_UTIL_SObject.getSetIdsOnField(activeAssets, 'XC_Configuration_Item__c');
        Map<Id, Ne__OrderItem__c> orderItemMap = new Map<Id, Ne__OrderItem__c>([SELECT Id, NE__OrderId__r.XC_ActivationDateOverride__c,
                                                                                    (SELECT Id, EndDate, XC_ActualEndDate__c FROM Work_Orders__r WHERE XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_DeliveryInstallation AND Status =: Label.XC_CL_Completed) 
                                                                                FROM Ne__OrderItem__c WHERE Id IN: orderItemIds]);
        //Map<Id, NE__Order__c> orderMap = new Map<Id, NE__Order__c>([SELECT Id, XC_ActivationDateOverride__c FROM NE__Order__c WHERE Id IN: orderIds AND XC_ActivationDateOverride__c != null]);
        for(Ne__OrderItem__c orderItem : orderItemMap.values()){
            DateTime DeliveryAndInstallationWOEndDateTime;
            Date DeliveryAndInstallationWOEndDate;
            if(!orderItem.Work_Orders__r.isEmpty()){
                DeliveryAndInstallationWOEndDateTime = String.isNotBlank(String.valueOf(orderItem.Work_Orders__r[0].XC_ActualEndDate__c)) ? Date.newInstance(orderItem.Work_Orders__r[0].XC_ActualEndDate__c.year(), orderItem.Work_Orders__r[0].XC_ActualEndDate__c.month(), orderItem.Work_Orders__r[0].XC_ActualEndDate__c.day()) : orderItem.Work_Orders__r[0].EndDate;
                orderItemIDExistingWO.put(orderItem.Id, true);
            } else {
                orderItemIDExistingWO.put(orderItem.Id, false);
            }
            if(DeliveryAndInstallationWOEndDateTime != null){
                DeliveryAndInstallationWOEndDate = Date.newinstance(DeliveryAndInstallationWOEndDateTime.year(), DeliveryAndInstallationWOEndDateTime.month(), DeliveryAndInstallationWOEndDateTime.day());
            }
            orderItemActivationDateMap.put(orderItem.Id, orderItem.NE__OrderId__r.XC_ActivationDateOverride__c);
            orderItemEndDateMap.put(orderItem.Id, DeliveryAndInstallationWOEndDate);
        }
        for(Asset a : activeAssets){
            if(a.XC_ActivationDate__c == null) a.XC_ActivationDate__c = (orderItemActivationDateMap.containsKey(a.XC_Configuration_Item__c) && orderItemActivationDateMap.get(a.XC_Configuration_Item__c) != null) ? orderItemActivationDateMap.get(a.XC_Configuration_Item__c) : System.now();
            a.InstallDate = (orderItemEndDateMap.containsKey(a.XC_Configuration_Item__c) && a.InstallDate == null) ? orderItemEndDateMap.get(a.XC_Configuration_Item__c) : a.InstallDate;
            if(a.InstallDate == null && a.XC_ActivationDate__c != null && orderItemIDExistingWO.containsKey(a.XC_Configuration_Item__c) && orderItemIDExistingWO.get(a.XC_Configuration_Item__c)){
                a.InstallDate = Date.newinstance(a.XC_ActivationDate__c.year(), a.XC_ActivationDate__c.month(), a.XC_ActivationDate__c.day());
            }  
        }
    }


    /**
     * @author Luca Calicchio lcalicchio@deloitte.it
     * @date 09/11/2021
     * @description This method set asset start date(NR1652)
     * 
     */
    public static void updateStartDate(List<Asset> listNew){
        //Retrieve the ids of Configuration Item from Assets
        List<Id> configurationItemIds=XC_UTIL_SObject.getListFieldValues(listNew,'XC_Configuration_Item__c');
        //Query to retrieve the NE__StartDate__c field
        Map<Id,NE__OrderItem__c> configurationItems=new Map<Id,NE__OrderItem__c>([SELECT Id, NE__StartDate__c FROM NE__OrderItem__c WHERE Id IN :configurationItemIds]);
        //Set the CI start date for all the assets
        for(Asset asset : listNew){
            if(configurationItems.get(asset.XC_Configuration_Item__c)!=null){              
            	asset.NE__StartDate__c = configurationItems.get(asset.XC_Configuration_Item__c).NE__StartDate__c;
            }
        }
    }
    
    
}