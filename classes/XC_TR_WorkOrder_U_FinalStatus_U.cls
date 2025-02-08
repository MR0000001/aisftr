/**
 * @author Marco Rosa - marco.rosa@nttdata.com - Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date 16-11-2018
 * @description Class to manage final status of Work order
 */ 

public without sharing class XC_TR_WorkOrder_U_FinalStatus_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_FinalStatus_U'); 
    

    /**
    * @description Method to retrieve the Provisioning Steps
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param stepStatus 
    * @param psList
    * @param wo
    * @return List<XC_Provisioning_Step__c> 
    */ 
    public static List<XC_Provisioning_Step__c> retrieveProvisioningStep (String stepStatus, List<XC_Provisioning_Step__c> psList, WorkOrder wo){
        List<XC_Provisioning_Step__c> listStep = new List<XC_Provisioning_Step__c>();
        for(XC_Provisioning_Step__c ps : psList){
            listStep = retrieveBySingleProvisioningStep(stepStatus, ps, wo);
        }
        return listStep;
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param stepStatus
    * @param ps
    * @param wo
    * @return List<XC_Provisioning_Step__c> 
    * @description Method to retrieve the Provisioning Steps
    */ 
    private static List<XC_Provisioning_Step__c> retrieveBySingleProvisioningStep (String stepStatus, XC_Provisioning_Step__c ps, WorkOrder wo){
        List<XC_Provisioning_Step__c> listStep = new List<XC_Provisioning_Step__c>();
        listStep = retrieveProvisioningStepOne(stepStatus, ps, wo);
        Boolean conditionDiagnostic = wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic && ps.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningMaintenanceInspection_Flow;
        Boolean conditionReturn = wo.XC_WorkTypeCategory__c== Label.XC_CL_WorkType_Return && (ps.XC_Flow_API_Name__c == Label.XC_CL_DeprovisioningMPSendForReturn_Flow || ps.XC_Flow_API_Name__c == Label.XC_CL_SendForReturn_Flow);
        Boolean conditionSubstitution = wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Substitution && ps.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningMPUninstallingInstalling_Flow;
        Boolean conditionSiteInspection = wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_SiteInspection && ps.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningMPSendForInstallation_Flow;
        Boolean conditionRepair = wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair && ps.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningMPSendForInstallation_Flow;
        if(conditionDiagnostic || conditionReturn || conditionSubstitution || conditionSiteInspection || conditionRepair){
            ps.XC_Status__c = stepStatus;
            listStep.add(ps);   
        } 
        return listStep;
    }

    /**
    * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
    * @param stepStatus
    * @param ps
    * @param wo
    * @return List<XC_Provisioning_Step__c> 
    * @description Method to retrieve the Provisioning Steps
    */
    private static List<XC_Provisioning_Step__c> retrieveProvisioningStepOne (String stepStatus, XC_Provisioning_Step__c ps, WorkOrder wo){
        List<XC_Provisioning_Step__c> listStep = new List<XC_Provisioning_Step__c>();
        if( (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Diagnostic || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Delivery || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Installation) &&
                (ps.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningDeliveryInstallation_Flow || 
                 ps.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningMPSendForInstallation_Flow ||
                 ps.XC_Flow_API_Name__c == Label.XC_CL_ProvisioningMPBookAppointment_Flow ||
                 ps.XC_Flow_API_Name__c == Label.XC_CL_MaintExecution_Flow ||
                 ps.XC_Flow_API_Name__c == 'XC_FL_CheckWOB2B')){
                 ps.XC_Status__c = stepStatus;
                listStep.add(ps);
        }
        return listStep;  
    }

    /**
     * Creates the work order maintenance.
     *
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listWorkOrder the list work order
     * @description Method to create next Maintenance Work Order
     */   
    public static void createWorkOrderMaintenance(List<WorkOrder> listWorkOrder){  
        List<WorkOrder> listWOToInsert = new List<WorkOrder>(); 
        List<WorkOrder> listWorkOrderToCheckMaintenance = new List<WorkOrder>(); 
        for(WorkOrder wo : listWorkOrder){
            if(wo.Status == Label.XC_CL_Completed 
                && wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance){ 
                listWorkOrderToCheckMaintenance.add(wo);
            }  
        }
        if(listWorkOrderToCheckMaintenance.isEmpty()){
            return;
        }
        
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new InsertNewMaintenance(listWorkOrderToCheckMaintenance));
        }else{
            insertWoMaintenance(listWorkOrderToCheckMaintenance);
        }        
    }

    /**
     * Gets the map work order maintenance.
     *
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listWorkOrder the list work order
     * @return Map<Id, XC_UTIL_Asset.MaintenanceWrapper>
     * @description Method to get a Map workOrderId -> Maintenance Asset Active
     */
    public static Map<Id, XC_UTIL_Asset.MaintenanceWrapper> getMapWorkOrderMaintenance(List<WorkOrder> listWorkOrder){ 
        Map<Id, XC_UTIL_Asset.MaintenanceWrapper> mapWorkOrderMaintenance = new Map<Id, XC_UTIL_Asset.MaintenanceWrapper>();
        List<String> listAssetIds = XC_UTIL_SObject.getListFieldValues(listWorkOrder, 'AssetId');
        
        Map<Id, XC_UTIL_Asset.MaintenanceWrapper> mapAssetMaintenance = XC_UTIL_Asset.getMapAssetMaintenance(listAssetIds);
        for(WorkOrder wo : listWorkOrder){
            if(mapAssetMaintenance.containsKey(wo.AssetId)){ 
                mapWorkOrderMaintenance.put(wo.Id, mapAssetMaintenance.get(wo.AssetId));
            } else {
                XC_UTIL_Asset.MaintenanceWrapper wr = new XC_UTIL_Asset.MaintenanceWrapper();
                mapWorkOrderMaintenance.put(wo.Id, wr);
            } 
        }  
        return mapWorkOrderMaintenance;
    } 

    /**
    * @description moved from XC_TR_WorkOrder_U_FinalStatus for PMD
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 19/11/2019 
    * @param wo 
    * @return Boolean 
    **/
    public static Boolean checkForGoodIssue(WorkOrder wo){
        return wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation && wo.ParentWorkOrderId == null &&
            (wo.Status == Label.XC_CL_WorkOrder_Completed || wo.Status == Label.XC_CL_Cancelled || wo.Status == Label.XC_CL_CannotComplete) ;   // SS 17/06/2020 before also  && !wo.XC_SentGoodIssue__c   
    }

    private static void insertWoMaintenance(List<WorkOrder> listWorkOrderToCheckMaintenance){
        List<WorkOrder> listWOToInsert = new List<WorkOrder>();
        List<String> listCoverageId = XC_UTIL_Sobject.getListFieldValues(listWorkOrderToCheckMaintenance, 'XC_Coverage__c');
        Map<Id, Asset> mapIdCoverage = new Map<Id, Asset>();
        if(!listCoverageId.isEmpty()){
            mapIdCoverage = new Map<Id, Asset>([
                SELECT Id, Status FROM Asset WHERE ID IN: listCoverageId
            ]);
        }
        Map<Id, XC_UTIL_Asset.MaintenanceWrapper> mapWorkOrderMaintenance = getMapWorkOrderMaintenance(listWorkOrderToCheckMaintenance);    
        for(WorkOrder wo : listWorkOrderToCheckMaintenance){ 
            if(mapWorkOrderMaintenance.containsKey(wo.Id)){
                Boolean checkCoverageOnWO = wo.XC_Coverage__c != null && mapIdCoverage.containsKey(wo.XC_Coverage__c) && mapIdCoverage.get(wo.XC_Coverage__c).status == 'Active';
                Boolean checkCoverageOnAsset = mapWorkOrderMaintenance.get(wo.Id).isMaintenanceAssetActive;
                if(mapWorkOrderMaintenance.get(wo.Id).isAssetActive && (checkCoverageOnWO || checkCoverageOnAsset)){ 
                    WorkOrder nextWorkOrder = new WorkOrder();
                    nextWorkOrder.WorkTypeId = wo.WorkTypeId; 
                    nextWorkOrder.AssetId = wo.AssetId;
                    nextWorkOrder.XC_RequiredPartnerId__c = String.isBlank(wo.XC_RequiredPartnerId__c) ? wo.XC_AssignedPartner__c : wo.XC_RequiredPartnerId__c;
                    //nextWorkOrder.XC_Configuration_Item__c = wo.XC_Configuration_Item__c;  
                    nextWorkOrder.XC_Provisioning_Step__c = wo.XC_Provisioning_Step__c;   
                    nextWorkOrder.XC_PositionInMaintenancePlan__c = wo.XC_PositionInMaintenancePlan__c + 1;            
                    nextWorkOrder.XC_PreviousMaintenanceWorkOrder__c = wo.Id;
                    nextWorkOrder.XC_MaintenanceYearFrequency__c = mapWorkOrderMaintenance.get(wo.Id).yearFrequency;
                    nextWorkOrder.XC_CreateMaintenanceServiceAppointment__c = true;
                    nextWorkOrder.XC_Coverage__c = wo.XC_Coverage__c;
                    nextWorkOrder.XC_CreatedAutomaticallyBySystem__c = true;
                    listWOToInsert.add(nextWorkOrder);
                }
            }
        } 
        XC_UTIL_Sobject.insertListRecords(listWOToInsert);
    }

    /**

    * @description INNER QUEABLE CLASS
    * @author Domenico Del Prete - domenico.delprete@nttdata.com | 22/07/2020
    * @return Boolean
    */
    public class InsertNewMaintenance implements Queueable{
        List<WorkOrder> listWorkOrderToCheckMaintenance;
        public InsertNewMaintenance(List<WorkOrder> listWorkOrderToCheckMaintenance){
            this.listWorkOrderToCheckMaintenance = listWorkOrderToCheckMaintenance;
        }

        public void execute(QueueableContext context) {
            insertWoMaintenance(this.listWorkOrderToCheckMaintenance);
        }
    }
    
}