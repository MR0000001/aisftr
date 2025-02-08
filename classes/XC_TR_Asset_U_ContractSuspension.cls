/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 10/06/2019
* @description XC_TR_Asset_U_ContractSuspension – Util class for Asset trigger 
*/ 

public without sharing class XC_TR_Asset_U_ContractSuspension {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Asset_U_ContractSuspension');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 10/06/2019 
     * @description Method to check if it is necessary to change the status of service appointment if Asset is 'Suspended'
     * @param mapOld - Map<Id, Asset>
     * @param mapNew - Map<Id, Asset> 
    */
    public static void manageServiceAppointmentStatusForSuspendedAsset(Map<Id, Asset> mapOld, Map<Id, Asset> mapNew) {  
        List<Asset> listChanged = XC_UTIL_SObject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        List<Asset> listAssetToSuspended = new List<Asset>();
        for(Asset asset : listChanged) { 
            if(asset.Status == Label.XC_CL_Asset_StatusSuspended) {
                listAssetToSuspended.add(asset);
            }
        } 
        if(!listAssetToSuspended.isEmpty()) {
            updatetServiceAppointmentStatusBySuspendedAsset(listAssetToSuspended);
            updateWorkOrderBySuspendedAsset(listAssetToSuspended);
            //createCaseForSuspendedAsset(listAssetToSuspended);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 10/06/2019 
     * @description Method to check if it is necessary to change the status of service appointment if Asset is 'Active'
                    and with 'Dunning' reason
     * @param mapOld - Map<Id, Asset>
     * @param mapNew - Map<Id, Asset>
    */
    public static void manageServiceAppointmentStatusForActivatedAsset(Map<Id, Asset> mapOld, Map<Id, Asset> mapNew) {  
        List<Asset> listAssetToCheck = new List<Asset>();
        for(Asset asset : mapNew.values()){
            Id assetId = (Id) asset.get('Id');
            if(assetId != null) {
                if(mapNew.get(assetId).get('Status') == Label.XC_CL_Asset_StatusActive &&
                    mapOld.get(assetId).get('Status') == Label.XC_CL_Asset_StatusSuspended) {
                    listAssetToCheck.add(asset);
                }
            }
        }

        if(!listAssetToCheck.isEmpty()) {
            updatetServiceAppointmentStatusByActivatedAsset(listAssetToCheck);
            updateWorkOrderByActivatedAsset(listAssetToCheck);
            //createCaseForReactivatedAsset(listAssetToCheck);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 10/06/2019 
     * @description Method to update Service Appointment Status when asset is 'Active'
                    and 'Dunning' reason
     * @param listAsset - List<Asset>
    */
    private static void updatetServiceAppointmentStatusByActivatedAsset(List<Asset> listAsset) {        
        if(!Schema.sObjectType.WorkOrder.isAccessible() || !Schema.sObjectType.ServiceAppointment.isAccessible()){
	        return;
        }
        List<String> listAssetIds = XC_UTIL_Sobject.getIds(listAsset);
        List<WorkOrder> listWorkOrder = [
            SELECT Id
            FROM WorkOrder
            WHERE AssetId IN :listAssetIds
            OR XC_Coverage__c IN: listAssetIds 
        ];
        List<String> listWorkOrderIds = XC_UTIL_Sobject.getIds(listWorkOrder);
        List<ServiceAppointment> listServiceAppointment = [
            SELECT Id, SchedEndTime
            FROM ServiceAppointment
            WHERE ParentRecordId IN :listWorkOrderIds
                AND Status = :Label.XC_CL_ServiceAppointment_OnHold
                AND XC_Reason_Cannot_Complete__c = :Label.XC_CL_ServiceAppointment_Dunning
                ];

        for(ServiceAppointment sa : listServiceAppointment) {
            sa.XC_IgnoreReschedulingLock__c = true;
            if(sa.SchedEndTime == null){
                sa.Status = Label.XC_CL_ServiceAppointment_None;
                sa.XC_Reason_Cannot_Complete__c = '';
                sa.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician;
            }
            else if(sa.SchedEndTime > DateTime.now()) {
                sa.Status = Label.XC_CL_ServiceAppointment_Scheduled;
                sa.XC_Reason_Cannot_Complete__c = '';
                sa.XC_StatusReason__c = Label.XC_CL_Workable;
            } else {
                sa.Status = Label.XC_CL_ServiceAppointment_StatusCannotComplete;
                sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_ServiceAppointment_RejectionReason;
            }
        }

        XC_UTIL_Sobject.updateListRecords(listServiceAppointment);
    }

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @date 16/09/2019
     * @description Method to update WOrkOrder in  On Hold
     * @param listAsset - List<Asset>
    */
    public static void updateWorkOrderByActivatedAsset(List<Asset> listAsset) {      
        List<String> listAssetIds = XC_UTIL_Sobject.getIds(listAsset);
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id, XC_LegalEntity__c,
            	(SELECT Id, Status
                FROM ServiceAppointments)
            FROM WorkOrder
            WHERE (AssetId IN :listAssetIds OR XC_Coverage__c IN: listAssetIds)
            AND (Status =: Label.XC_CL_WorkOrder_Assigned OR Status =: Label.XC_CL_ServiceAppointment_OnHold OR Status =: Label.XC_CL_WorkOrder_New)
        ]);

        List<String> legalEntities = XC_UTIL_Sobject.getListFieldValues(listWorkOrder, 'XC_LegalEntity__c');
        Map<String, String> mapQueues = getMapQueueDispatcher(legalEntities);
        for(WorkOrder wo : listWorkOrder){
            if(wo.ServiceAppointments.isEmpty()){
                wo.Status = Label.XC_CL_WorkOrder_New;
            }else{
                for(ServiceAppointment sa: wo.ServiceAppointments){
                    if(sa.Status == Label.XC_CL_ServiceAppointment_CannotComplete){
                        wo.Status = Label.XC_CL_ServiceAppointment_OnHold;
                        if(mapQueues.containsKey(wo.XC_LegalEntity__c)) {
                            wo.OwnerId = mapQueues.get(wo.XC_LegalEntity__c);
                        }
                    }else if(sa.Status == Label.XC_CL_ServiceAppointment_None){
                        wo.Status = Label.XC_CL_WorkOrder_New;
                    }
                    else{
                        wo.Status = Label.XC_CL_WorkOrder_Assigned;
                    }
                }                
            }
            wo.XC_StatusReason__c = Label.XC_CL_Workable;
        }
        XC_UTIL_Sobject.updateListRecords(listWorkOrder);                
    }

    /**
    * @description Method to get Queue Dispatcher Map
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param legalEntity - List<String> 
    * @return Map<String, String>
    */
    private static Map<String, String> getMapQueueDispatcher(List<String> legalEntities) {
        Map<String, String> mapResult = new Map<String, String>();
        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BODispatcherQueue__c, XC_LegalEntity__c  
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c IN :legalEntities AND XC_BODispatcherQueue__c != null
        ]);
        if(listCM.isEmpty()) {
            return mapResult;
        }
        List<String> listNameQueues = XC_UTIL_Sobject.getListFieldValues(listCM, 'XC_BODispatcherQueue__c');
        Map<String, String> mapQueues = XC_UTIL_WorkOrder.getMapQueueIds(listNameQueues);
        
        for(String nameQueue : mapQueues.keySet()) {
            for(XC_CM_LegalEntity_Configuration__mdt cm : listCM) {
                if(nameQueue == cm.XC_BODispatcherQueue__c) {
                    mapResult.put(cm.XC_LegalEntity__c, mapQueues.get(nameQueue));
                    break;
                }
            }
        }
        return mapResult;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 10/06/2019 
     * @description Method to update Service Appointment Status when asset is 'Suspended'
     * @param listAsset - List<Asset>
    */
    private static void updatetServiceAppointmentStatusBySuspendedAsset(List<Asset> listAsset) {  
        if(!Schema.sObjectType.WorkOrder.isAccessible() || !Schema.sObjectType.ServiceAppointment.isAccessible()){
	        return;
        }
        List<String> listAssetIds = XC_UTIL_Sobject.getIds(listAsset);
        List<WorkOrder> listWorkOrder = [
            SELECT Id
            FROM WorkOrder
            WHERE AssetId IN :listAssetIds
            OR XC_Coverage__c IN: listAssetIds
        ];
        List<String> listWorkOrderIds = XC_UTIL_Sobject.getIds(listWorkOrder);
        
        List<ServiceAppointment> listServiceAppointment = [
            SELECT Id, Status
            FROM ServiceAppointment
            WHERE ParentRecordId IN :listWorkOrderIds
                AND Status != :Label.XC_CL_ServiceAppointment_CannotComplete
                AND Status != :Label.XC_CL_ServiceAppointment_Completed
                AND Status != :Label.XC_CL_ServiceAppointment_Canceled];

        for(ServiceAppointment sa : listServiceAppointment) {
            if(sa.Status != Label.XC_CL_ServiceAppointment_OnHold){
                sa.Status = Label.XC_CL_ServiceAppointment_OnHold;
                sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_ServiceAppointment_Dunning; 
                sa.XC_StatusReason__c = Label.XC_CL_DunningProcess;
            }else{
                sa.XC_IgnoreReschedulingLock__c = true;
                sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_ServiceAppointment_Dunning; 
                sa.XC_StatusReason__c = Label.XC_CL_DunningProcess;
            }
        }
        XC_UTIL_Sobject.updateListRecords(listServiceAppointment);                
    }

        
    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @date 16/09/2019
     * @description Method to update WOrkOrder in  On Hold
     * @param listAsset - List<Asset>
    */
    private static void updateWorkOrderBySuspendedAsset(List<Asset> listAsset) {        
        List<String> listAssetIds = XC_UTIL_Sobject.getIds(listAsset);
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id
            FROM WorkOrder
            WHERE (AssetId IN :listAssetIds OR XC_Coverage__c IN: listAssetIds)
            AND (Status != : Label.XC_CL_WorkOrder_Canceled  
            AND Status != : Label.XC_CL_WorkOrder_Completed  AND Status != : Label.XC_CL_WorkOrder_CannotComplete)
        ]);
        for(WorkOrder wo : listWorkOrder){
            wo.Status = Label.XC_CL_ServiceAppointment_OnHold;
            wo.XC_StatusReason__c = Label.XC_CL_DunningProcess;
        }
        XC_UTIL_Sobject.updateListRecords(listWorkOrder);                
    }
    
    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @date 24/09/2019
     * @description Method to update WOrkOrder in  On Hold
     * @param listAsset - List<Asset>
    */
    /*private static void createCaseForSuspendedAsset(List<Asset> listAsset) { 
        List<Id> assetIds = XC_UTIL_Sobject.getIds(listAsset);
        Map<Id,Asset> mapAssetCatalog = new Map<Id,Asset>([SELECT Id, NE__Catalog__r.XC_LIC_Name__c FROM Asset WHERE Id IN: assetIds]);
        List<Case> listCase = new List<Case>();
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_AssetSuspension});
         XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_AssetSuspension);
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_AssetSuspension}));
        }
        for(Asset ass : listAsset){
            if(mapAssetCatalog.get(ass.Id).NE__Catalog__r.XC_LIC_Name__c == Label.XC_CL_Catalog_eHome){
                Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
                c.ContactId = ass.ContactId;
                c.AccountId = ass.AccountId;
                c.AssetId = ass.Id;
                //c.Origin = Label.XC_CL_CaseOriginCAN002;
                c.XC_Resolution__c = caseMDT.XC_Resolution__c;
                c.XC_Result__c = caseMDT.XC_Result__c;
                listCase.add(c);
            }    
        }   
        XC_UTIL_Sobject.insertListRecords(listCase);      
    }*/
    
    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @date 24/09/2019
     * @description Method to update WOrkOrder in  On Hold
     * @param listAsset - List<Asset>
    */
    /*private static void createCaseForReactivatedAsset(List<Asset> listAsset) { 
        List<Id> assetIds = XC_UTIL_Sobject.getIds(listAsset);
        Map<Id,Asset> mapAssetCatalog = new Map<Id,Asset>([SELECT Id, NE__Catalog__r.XC_LIC_Name__c FROM Asset WHERE Id IN: assetIds]);
        List<Case> listCase = new List<Case>();
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_WorkOrderReactivation});
         XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_WorkOrderReactivation);
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_WorkOrderReactivation}));
        }
        for(Asset ass : listAsset){
            if(mapAssetCatalog.get(ass.Id).NE__Catalog__r.XC_LIC_Name__c == Label.XC_CL_Catalog_eHome){
                Case c = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
                c.ContactId = ass.ContactId;
                c.AccountId = ass.AccountId;
                c.AssetId = ass.Id;
                c.Status = Label.XC_CL_Case_Open;
                //c.Origin = Label.XC_CL_CaseOriginCAN002;
                listCase.add(c);
            }    
        }   
        XC_UTIL_Sobject.insertListRecords(listCase);      
    }*/

}