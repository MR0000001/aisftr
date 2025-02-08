/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 19/04/2019
* @description XC_UTIL_ResourcePreference_U_CheckFor - Methods check for XC_UTIL_ResourcePreference_U
**/

public without sharing class XC_UTIL_ResourcePreference_U_CheckFor {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ResourcePreference_U_CheckFor');

    /**
    *@description Method to mapWorkOrderExistingResourcePreferences
    *@param mapWorkOrderExistingResourcePreferences
    *@param workOrderId
    *@param serviceResourceId
    *@return Boolean boolean
    **/
    public static Boolean checkIfPreferenceExists(Map<Id, List<ResourcePreference>> mapWorkOrderExistingResourcePreferences, Id workOrderId, Id serviceResourceId){
         if(mapWorkOrderExistingResourcePreferences.containsKey(workOrderId)){
            List<ResourcePreference> listExistingResourcePreferences = mapWorkOrderExistingResourcePreferences.get(workOrderId);
            for (ResourcePreference existingResourcePreference : listExistingResourcePreferences ){
                if(existingResourcePreference.ServiceResourceId == serviceResourceId ){
                    return false;
                }
            }
         }
        return true;
    }

    /** 
    * @param preferredWrapper - PreferredWrapper
    * @description Method to populate PreferredWrapper
    */    
    public static void checkForInstallerCommercialVisit(XC_UTIL_ResourcePreference.PreferredWrapper preferredWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listToCheckInstallerAndCommercialVisit->' + preferredWrapper.listToCheckInstallerAndCommercialVisit);  
        Map<Id, Asset> mapAsset = new Map<Id, Asset>([
            SELECT Id, XC_InstallationAssignedResource__r.XC_Account__c, XC_MaintenanceAssignedResource__r.XC_Account__c 
            FROM Asset 
            WHERE Id IN: preferredWrapper.setIdAsset
        ]);
        for(Workorder wo: preferredWrapper.listToCheckInstallerAndCommercialVisit){ 
            if(mapAsset.containsKey(wo.AssetId)){
                Asset asset = mapAsset.get(wo.AssetId);
                if(wo.XC_PositionInMaintenancePlan__c == 1){
                    populatePreferredWrapper(asset, preferredWrapper, wo);
                } else if(wo.XC_PositionInMaintenancePlan__c > 1){
                    preferredWrapper.mapWorkOrderPreferredResourceAccount.put(wo.Id, asset.XC_MaintenanceAssignedResource__r.XC_Account__c); 
                }
            } 
        }
    }

    /** 
    * @param asset - Asset
    * @param preferredWrapper - PreferredWrapper
    * @param wo - WorkOrder
    * @description Method to populate PreferredWrapper
    */    
    private static void populatePreferredWrapper(Asset asset, XC_UTIL_ResourcePreference.PreferredWrapper preferredWrapper, WorkOrder wo) {
        if(!String.isBlank(asset.XC_InstallationAssignedResource__r.XC_Account__c)){
            preferredWrapper.mapWorkOrderPreferredResourceAccount.put(wo.Id, asset.XC_InstallationAssignedResource__r.XC_Account__c); 
        } else {
            preferredWrapper.listToCheckCommercialVisit.add(wo);
            if(wo.XC_Configuration__c != null) {
                preferredWrapper.setIdConfiguration.add(wo.XC_Configuration__c);
            }
        }
    }

    /** 
    * @param preferredWrapper - PreferredWrapper
    * @description Method to populate PreferredWrapper
    */    
    public static void checkForCommercialVisit(XC_UTIL_ResourcePreference.PreferredWrapper preferredWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'listToCheckCommercialVisit->' + preferredWrapper.listToCheckCommercialVisit); 
        Map<Id,NE__Order__c> mapConf = new Map<ID, NE__Order__c>([
            SELECT Id, NE__OptyId__c, NE__OptyId__r.XC_CommercialVisitAssignedPartner__c, NE__OptyId__r.AccountId, NE__OptyId__r.Account.XC_CommercialVisitAssignedPartner__c, XC_LegalEntity__c, OwnerId, 
                    (SELECT Id, XC_AssignedPartner__c FROM Work_Orders__r WHERE XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_SiteInspection)
            FROM NE__Order__c 
            WHERE Id IN: preferredWrapper.setIdConfiguration
        ]);
        List<Id> listOfConfOwner = new List<Id>();
        for (NE__Order__c conf : mapConf.values()){
            listOfConfOwner.add(conf.OwnerId);
        }
        Map<Id, User> mapUser = new Map<Id, User>();
        if(!listOfConfOwner.isEmpty()){
            mapUser = new Map<Id, User>([SELECT Id, AccountId FROM User WHERE Id IN:listOfConfOwner]);
        }
        Map<Id, WorkOrder> mapWoSiteInspection = new Map<Id, WorkOrder>();        
        for(Workorder wo: preferredWrapper.listToCheckCommercialVisit){
            String partnerId = '';
            if(mapconf.containsKey(wo.XC_Configuration__c) || mapconf.containsKey(wo.XC_Configuration_Item__r.NE__OrderId__c)){
                NE__Order__c conf = new NE__Order__c();
                if(mapconf.get(wo.XC_Configuration__c) != null){
                    conf = mapconf.get(wo.XC_Configuration__c);
                }else if (mapconf.containsKey(wo.XC_Configuration_Item__r.NE__OrderId__c)){
                    conf = mapconf.get(wo.XC_Configuration_Item__r.NE__OrderId__c);
                }
                /*if(conf.XC_LegalEntity__c == Label.XC_CL_EndesaX){
                    if(conf.NE__OptyId__c != null && !String.isBlank(conf.NE__OptyId__r.XC_CommercialVisitAssignedPartner__c)){
                        partnerId = conf.NE__OptyId__r.XC_CommercialVisitAssignedPartner__c; 
                    } else if(conf.NE__OptyId__c != null && conf.NE__OptyId__r.AccountId != null && !String.isBlank(conf.NE__OptyId__r.Account.XC_CommercialVisitAssignedPartner__c)){
                        partnerId = conf.NE__OptyId__r.Account.XC_CommercialVisitAssignedPartner__c; 
                    }                       
                }else*/ if(conf.XC_LegalEntity__c == Label.XC_CL_LegalEntity_Italy || conf.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilityItalia || conf.XC_LegalEntity__c == Label.XC_CL_EndesaX || conf.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain){
                    for(WorkOrder woSiteInspection : conf.Work_Orders__r){ 
                        mapWoSiteInspection.put(conf.Id, woSiteInspection);
                    }
                    if(mapWoSiteInspection.isEmpty()){
                        partnerId = mapUser.get(conf.OwnerId).AccountId;
                    }else{
                        partnerId = mapWoSiteInspection.get(conf.Id).XC_AssignedPartner__c;
                    }                    
                }
                if(!String.isBlank(partnerId)) {
                    preferredWrapper.mapWorkOrderPreferredResourceAccount.put(wo.Id, partnerId);
                }
            } 
        }
    }

    /** 
    * @param asset - Asset
    * @param preferredWrapper - PreferredWrapper
    * @param wo - WorkOrder
    * @description Check for Maintenance Assigned Partner (FOR CYCLOMATIC COMPLEXITY)
    */    
    private static void checkMaintenanceAssignedPartner(Asset asset, XC_UTIL_ResourcePreference.PreferredWrapper preferredWrapper, WorkOrder wo) {
        if((Date.Today() - 15) < asset.XC_LastMaintenanceDate__c ){
            if(!String.isBlank(asset.XC_MaintenanceAssignedResource__r.XC_Account__c)){
                preferredWrapper.mapWorkOrderPreferredResourceAccount.put(wo.Id, asset.XC_MaintenanceAssignedResource__r.XC_Account__c);  
            }
        } 
    }

    /** 
    * @param asset - Asset
    * @param preferredWrapper - PreferredWrapper
    * @param wo - WorkOrder
    * @description Method to check asset for WorkOrder
    */    
    public static void checkAsset(Asset asset, XC_UTIL_ResourcePreference.PreferredWrapper preferredWrapper, WorkOrder wo) {
        if((Date.Today().addMonths(-6)) < asset.XC_LastMaintenanceDate__c){
            checkMaintenanceAssignedPartner(asset, preferredWrapper, wo);
        }else if((Date.Today().addMonths(-6)) < asset.XC_LastRepairDate__c){
            if(!String.isBlank(asset.XC_RepairAssignedResource__r.XC_Account__c)) {
                preferredWrapper.mapWorkOrderPreferredResourceAccount.put(wo.Id, asset.XC_RepairAssignedResource__r.XC_Account__c); 
            }
        }//else if( (Date.Today().addMonths(-6)) < asset.InstallDate ){
        else if(!String.isBlank(asset.XC_InstallationAssignedResource__r.XC_Account__c)){
            preferredWrapper.mapWorkOrderPreferredResourceAccount.put(wo.Id, asset.XC_InstallationAssignedResource__r.XC_Account__c); 
        }
        //}
    }

    /** 
    * @param preferredWrapper - PreferredWrapper
    * @description Method to populate PreferredWrapper
    */    
    public static void checkForRepair(XC_UTIL_ResourcePreference.PreferredWrapper preferredWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'listToCheckForRepair->' + preferredWrapper.listToCheckForRepair);  
        Map<Id, Asset> mapAsset = new Map<Id, Asset>([
            SELECT Id, InstallDate,XC_LastMaintenanceDate__c, XC_LegalEntity__c, XC_InstallationAssignedResource__r.XC_Account__c,XC_MaintenanceAssignedResource__r.XC_Account__c,XC_RepairAssignedResource__r.XC_Account__c,XC_LastRepairDate__c, XC_MaintenanceAssignedResource__c, XC_RepairAssignedResource__c, XC_Segment__c
            FROM Asset 
            WHERE Id IN: preferredWrapper.setIdAsset
        ]);
        for(Workorder wo: preferredWrapper.listToCheckForRepair){ 
            if(mapAsset.containsKey(wo.AssetId)){
            Asset asset = mapAsset.get(wo.AssetId);
                if(((asset.InstallDate != null ) || //&&  (Date.Today().addMonths(-6)) < asset.InstallDate 
                    (asset.XC_LastMaintenanceDate__c != null && (Date.Today().addMonths(-6)) < asset.XC_LastMaintenanceDate__c ) || 
                    (asset.XC_LastRepairDate__c != null && (Date.Today().addMonths(-6)) < asset.XC_LastRepairDate__c)) && (asset.XC_LegalEntity__c == Label.XC_CL_EndesaX || asset.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain)) { 
                        checkAsset(asset, preferredWrapper, wo);
                    }else if(asset.InstallDate != null && asset.XC_Segment__c== 'B2C'){
                        if(!String.isBlank(asset.XC_InstallationAssignedResource__r.XC_Account__c)){
                            preferredWrapper.mapWorkOrderPreferredResourceAccount.put(wo.Id, asset.XC_InstallationAssignedResource__r.XC_Account__c); 
                        }
                    }
            }                  
        }
    }
}