/**
*@author Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
*@author Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com
*@date   08/02/2019
*@description XC_UTIL_ResourcePreference - The class is an utility class for the Resource Preference managment
**/
public without sharing class XC_UTIL_ResourcePreference {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ResourcePreference');

    /** @description Wrapper for Check RP */
    private class CheckWrapper {
        List<WorkOrder> listToCheckCommercialVisit = new List<WorkOrder>();
        Set<Id> setIdConfiguration = new Set<Id>();
        List<WorkOrder> listToCheckInstallerAndCommercialVisit = new List<WorkOrder>(); 
        Set<Id> setIdAsset = new Set<Id>();
        List<WorkOrder> listToCheckForRepair = new List<WorkOrder>();
    }

    /** @description PreferredWrapper */
    public class PreferredWrapper {
        public Set<Id> setIdConfiguration = new Set<Id>();
        public List<WorkOrder> listToCheckCommercialVisit = new List<WorkOrder>();
        public List<WorkOrder> listToCheckInstallerAndCommercialVisit = new List<WorkOrder>();
        public List<WorkOrder> listToCheckForRepair = new List<WorkOrder>();
        public Set<Id> setIdAsset = new Set<Id>();
        public Map<Id, Id> mapWorkOrderPreferredResourceAccount = new Map<Id, Id>();
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it
    * @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 05/12/2019
    * @description Method to Insert Resource Preference
    * @param woIds - Set<Id>
    * @param mapWorkOrderListServiceResources - Map<Id, Set<Id>>
    * @param preferenceType - String
    * @return List<XC_UTIL_Sobject.WrapperResult>
    **/
    private static List<XC_UTIL_Sobject.WrapperResult> insertResourcePreferences(Set<Id> woIds, Map<Id, Set<Id>> mapWorkOrderListServiceResources, String preferenceType) {
        List<ResourcePreference> resourceToInsert = new List<ResourcePreference> ();
        List<String> listIdServiceResourceTemp = new List<String>();
        List<String> listIdRelatedRecordTemp = new List<String>();

        for (Id woId : woIds) {
            if (mapWorkOrderListServiceResources.containsKey(woId)) {
                Set<Id> serviceResourceIds = mapWorkOrderListServiceResources.get(woId);
                for(Id srId: serviceResourceIds) {
                    ResourcePreference rp = new ResourcePreference();
                    rp.ServiceResourceId = srId;
                    rp.RelatedRecordId = woId;
                    rp.PreferenceType = preferenceType;
                    resourceToInsert.add(rp);
                    listIdServiceResourceTemp.add((String) srId);
                    listIdRelatedRecordTemp.add((String) woId);
                }
            }
        }

        // Check if Resource Preference already exists:
        List<ResourcePreference> listResourcePreferenceAlreadyExists = new List<ResourcePreference>([
            SELECT Id,ServiceResourceId, RelatedRecordId
            FROM ResourcePreference
            WHERE ServiceResourceId = :listIdServiceResourceTemp AND RelatedRecordId = :listIdRelatedRecordTemp
        ]);
        List<ResourcePreference> resourceToDelete = new List<ResourcePreference>();
        for(ResourcePreference rpToInsert : resourceToInsert) {
            Boolean found = false;
            String resourceFounded = '';
            for(ResourcePreference rpExist : listResourcePreferenceAlreadyExists) {
                if(rpToInsert.ServiceResourceId == rpExist.ServiceResourceId && rpToInsert.RelatedRecordId == rpExist.RelatedRecordId) {
                    found = true;
                    resourceFounded = rpExist.Id;
                    break;
                }
            }
            if(found) {
                resourceToDelete.add(new ResourcePreference(Id = resourceFounded));
                break;
            }
        }
        XC_UTIL_Sobject.deleteListRecords(resourceToDelete);
        return XC_UTIL_Sobject.insertListRecords(resourceToInsert);
    }
    
    /**
    *@author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it
    *@param mapWorkOrderListServiceResources
    *@return insertResourcePreferences
    *@description method to  insertRequiredResourcePreferences.
    */   
    public static List<XC_UTIL_Sobject.WrapperResult> insertRequiredResourcePreferences(Map<Id, Set<Id>> mapWorkOrderListServiceResources) {
        return insertResourcePreferences(mapWorkOrderListServiceResources.keySet(), mapWorkOrderListServiceResources, 'Required') ;
    }
        
    /**
    *@author: Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it
    *@param listNew
    *@param mapWorkOrderListServiceResources
    *@return insertResourcePreferences
    *@description method to  insertRequiredResourcePreferences.
    */   
    public static List<XC_UTIL_Sobject.WrapperResult> insertRequiredResourcePreferences(List<WorkOrder> listNew, Map<Id, Set<Id>> mapWorkOrderListServiceResources) {
        return insertResourcePreferences(XC_UTIL_Sobject.getSetIds(listNew), mapWorkOrderListServiceResources, 'Required') ;
    }
    /**
    *@author Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it
    *@param listWorkOrder list of work order
    *@return removeRequiredResourcePreferences
    *@description method to get a list of work order id and delete all the service preferences required related.
    **/          
    public static List<XC_UTIL_Sobject.WrapperResult> removeRequiredResourcePreferences(List<WorkOrder> listWorkOrder){
        List<String> listWorkOrderId = XC_UTIL_Sobject.getIds(listWorkOrder);
        return removeRequiredResourcePreferences(listWorkOrderId);
    }

    /**
    *@author Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it
    *@description Method to removeRequiredResourcePreferences
    *@param listWorkOrderId
    *@return list of wrapper
    **/
    public static List<XC_UTIL_Sobject.WrapperResult> removeRequiredResourcePreferences(List<Id> listWorkOrderId){
        List<XC_UTIL_Sobject.WrapperResult> wrapperResult = new List<XC_UTIL_Sobject.WrapperResult>();
        Map<Id, WorkOrder> mapResourcePreferenceRequired =  getMapResourcePreference(listWorkOrderId, 'Required');
        List<ResourcePreference> listToDelete = new  List<ResourcePreference>();
        for (Id woId : mapResourcePreferenceRequired.keySet() ){
            listToDelete.addAll(mapResourcePreferenceRequired.get(woId).ResourcePreferences);
        }
        if(!listToDelete.isEmpty()){
            wrapperResult = XC_UTIL_Sobject.deleteListRecords(listToDelete);
        } else {
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            wr.errorMessage = '';
            wr.success = true;
            wrapperResult.add(wr);
        }        
        return wrapperResult;
    } 

    /**
    *@description Method to getMapResourcePreference
    *@param listWorkOrderId
    *@param preferenceType
    *@return map with id and WorkOrder 
    **/   
    public static Map<Id, WorkOrder> getMapResourcePreference(List<Id> listWorkOrderId, String preferenceType){
        //List<String> listWorkOrderId = XC_UTIL_Sobject.getIds(listWorkOrder);
        Map<Id, WorkOrder> mapResourcePreferenceRequired = new Map<Id, WorkOrder>([SELECT Id, 
                                                                                   (SELECT Id,ServiceResourceId FROM ResourcePreferences WHERE PreferenceType =: preferenceType) 
                                                                                   FROM WorkOrder 
                                                                                   WHERE Id IN: listWorkOrderId]);
        return  mapResourcePreferenceRequired;
    }

    /**
    * @author  Salvatore Scarpato - salvatore.scarpato@nttadata.com 
    * @date   14/02/2019
    * @param listWorkOrderId
    * @description method to get a list of work order id and delete all the service preferences related.
    **/       
    public static List<XC_UTIL_Sobject.WrapperResult> removeResourcePreferences(List<Id> listWorkOrderId){
        List<XC_UTIL_Sobject.WrapperResult> wrapperResult = new List<XC_UTIL_Sobject.WrapperResult>();
        Map<Id, WorkOrder> mapResourcePreference = new Map<Id, WorkOrder>([SELECT Id, 
                                                                           (SELECT Id FROM ResourcePreferences) 
                                                                           FROM WorkOrder 
                                                                           WHERE Id IN: listWorkOrderId]); 
        List<ResourcePreference> listToDelete = new  List<ResourcePreference>();
        for (Id woId : mapResourcePreference.keySet() ){
            listToDelete.addAll(mapResourcePreference.get(woId).ResourcePreferences);
        }
        if(!listToDelete.isEmpty()){
            wrapperResult = XC_UTIL_Sobject.deleteListRecords(listToDelete);
        } else {
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            wr.errorMessage = '';
            wr.success = true;
            wrapperResult.add(wr);
        }        
        return wrapperResult;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
    * @author Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com, Salvatore Scarpato salvatore.scarpato@nttdata.com
    * @date   08/02/2019
    * @param listWorkOrder
    * @description method to removeResourcePreferences
    */    
    public static List<XC_UTIL_Sobject.WrapperResult> removeResourcePreferences(List<WorkOrder> listWorkOrder){
        List<String> listWorkOrderId = XC_UTIL_Sobject.getIds(listWorkOrder);
        return removeResourcePreferences(listWorkOrderId);
    }

    /**
    * @param wo - WorkOrder
    * @param checkWrapper - CheckWrapper
    * @description Check by WorkOrder (FOR CYCLOMATIC COMPLEXITY WARNING)
    */    
    public static void checkWorkTypeAsset(WorkOrder wo, CheckWrapper checkWrapper) {
        if(
            wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance
            || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Return
            //|| wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair
        ){
            checkWrapper.listToCheckInstallerAndCommercialVisit.add(wo);
            if(wo.AssetId != null) {
                checkWrapper.setIdAsset.add(wo.AssetId);
            }
        } else if(XC_UTIL_WorkType.isRepair( wo.XC_WorkTypeCategory__c )){ 
            checkWrapper.listToCheckForRepair.add(wo);
            if(wo.AssetId != null) {
                checkWrapper.setIdAsset.add(wo.AssetId); //TO CHECK
            }
        }
    }

    /** 
    * @param listWorkOrder - List<WorkOrder>
    * @description Method to populate CheckWrapper
    * @return CheckWrapper
    */    
    public static CheckWrapper populateCheckWrapper(List<WorkOrder> listWorkOrder) {
        List<Id> idWO = XC_UTIL_Sobject.getIds(listWorkOrder);
        List<WorkOrder> listOfWo = new List<WorkOrder>([SELECT Id, XC_WorkTypeCategory__c, XC_Configuration__c, XC_Configuration_Item__r.NE__OrderId__c, AssetId, XC_PositionInMaintenancePlan__c   FROM WorkOrder WHERE Id IN : idWO]);
        CheckWrapper checkWrapper = new CheckWrapper();
        for(Workorder wo : listOfWo){
            if( wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation 
                || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Installation){
                checkWrapper.listToCheckCommercialVisit.add(wo);
                if(wo.XC_Configuration__c != null) {
                    checkWrapper.setIdConfiguration.add(wo.XC_Configuration__c);
                } else{
                    checkWrapper.setIdConfiguration.add(wo.XC_Configuration_Item__r.NE__OrderId__c);
                }
            } else {
                checkWorkTypeAsset(wo, checkWrapper);
            }
        }
        return checkWrapper;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it
    * @param listWorkOrder
    * @description method to getMapWorkOrderPreferredResourceAccount
    * @return mapWorkOrderPreferredResourceAccount
    */      
    public static Map<Id, Id> getMapWorkOrderPreferredResourceAccount(List<WorkOrder> listWorkOrder){
        Map<Id, String> mapWOPreviousSR = new Map<Id,String>(); 
        Map<Id, Id> mapWorkOrderPreferredResourceAccount = new Map<Id,Id>(); 
        CheckWrapper checkWrapper = populateCheckWrapper(listWorkOrder);
        List<WorkOrder> listToCheckCommercialVisit = checkWrapper.listToCheckCommercialVisit;
        Set<Id> setIdConfiguration = checkWrapper.setIdConfiguration;
        List<WorkOrder> listToCheckInstallerAndCommercialVisit = checkWrapper.listToCheckInstallerAndCommercialVisit; 
        Set<Id> setIdAsset = checkWrapper.setIdAsset;
        List<WorkOrder> listToCheckForRepair = checkWrapper.listToCheckForRepair;
        
        PreferredWrapper preferredWrapper = new PreferredWrapper();
        preferredWrapper.setIdConfiguration = setIdConfiguration;
        preferredWrapper.listToCheckForRepair = listToCheckForRepair;
        preferredWrapper.listToCheckCommercialVisit = listToCheckCommercialVisit;
        preferredWrapper.listToCheckInstallerAndCommercialVisit = listToCheckInstallerAndCommercialVisit;
        preferredWrapper.setIdAsset = setIdAsset;
        preferredWrapper.mapWorkOrderPreferredResourceAccount = mapWorkOrderPreferredResourceAccount;
        if(!preferredWrapper.listToCheckInstallerAndCommercialVisit.isEmpty() && !preferredWrapper.setIdAsset.isEmpty()) {
            XC_UTIL_ResourcePreference_U_CheckFor.checkForInstallerCommercialVisit(preferredWrapper);
        }
        if(!preferredWrapper.listToCheckCommercialVisit.isEmpty() && !preferredWrapper.setIdConfiguration.isEmpty()) {
            XC_UTIL_ResourcePreference_U_CheckFor.checkForCommercialVisit(preferredWrapper);
        }
        if(!listToCheckForRepair.isEmpty() && !setIdAsset.isEmpty() ){
            XC_UTIL_ResourcePreference_U_CheckFor.checkForRepair(preferredWrapper);
        }
        
        return preferredWrapper.mapWorkOrderPreferredResourceAccount; 
    } 
}