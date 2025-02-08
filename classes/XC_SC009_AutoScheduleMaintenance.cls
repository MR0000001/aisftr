/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
* @date Creation 27/02/2019 
* @date Modification 01/10/2019
* @description XC_SC009_AutoScheduleMaintenance – Batch used to automatically schedule maintenance appointment
*/

public with sharing class XC_SC009_AutoScheduleMaintenance implements Schedulable, Database.Batchable<sObject> {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC009_AutoScheduleMaintenance');

    /** @description Assign Wrapper */ 
    private class AssignWrapper {
        Map<String, Boolean> mapWorkTypeLabelAssignToPartner = new Map<String, Boolean>();
        Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>();
    }

    /** @description ManageAssignmentFailureWrapper */
    private class ManageAssignmentFailureWrapper {
        WorkOrder wo = new WorkOrder();
        ServiceAppointment sa = new ServiceAppointment();
        Case cs = new Case();
        String idOwner = '';
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description execute
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC009_AutoScheduleMaintenance(), 1);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description start
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BODispatcherQueue__c, XC_LegalEntity__c  
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_BODispatcherQueue__c != null AND XC_AutoscheduleMaintenance__c = true
        ]);
        List<String> listLeAutoschedule = new List<String>();
        List<String> listNameQueues = new List<String>();
        for(XC_CM_LegalEntity_Configuration__mdt cm : listCM) {
            listLeAutoschedule.add(cm.XC_LegalEntity__c);
            listNameQueues.add(cm.XC_BODispatcherQueue__c);
        }

        if(Schema.sObjectType.ServiceAppointment.isAccessible()) {
            return Database.getQueryLocator('SELECT Id, XC_LegalEntity__c, ParentRecordId, ArrivalWindowEndTime, ArrivalWindowStartTime, XC_Country__c, OwnerId, XC_AssignedResource__c ' +
                                            'FROM ServiceAppointment ' + 
                                            'WHERE XC_WorkTypeCategory__c = \'' + Label.XC_CL_WorkType_PlannedMaintenance + '\' ' +
                                            'AND Status = \'' + Label.XC_CL_ServiceAppointment_None + '\' ' +
                                            'AND XC_LegalEntity__c IN :listLeAutoschedule ' +
                                            'AND (NOT Owner.Name LIKE \'%Dispatcher Queue\')');
        } else {
            insertBatchError(null, Label.XC_CL_AutoSchedMaint_Access, Label.XC_CL_AutoSchedMaint_ErrorQuery + 'ServiceAppointment');               
        }
        return null;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description execute
     * @param bc - BatchableContext 
     * @param scope - List<ServiceAppointment> 
    */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        if(!scope.isEmpty()) {
            try {
                List<Id> workOrderIds = XC_UTIL_Sobject.getListFieldValues(scope, 'ParentRecordId');
                List<XC_UTIL_Sobject.WrapperResult> wrapperResult = XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(workOrderIds);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ [XC_SC009_AutoScheduleMaintenance] WrapperResult ---> ' + wrapperResult[0]);
                AssignWrapper assignWrapper = assignWorkOrder(wrapperResult, workOrderIds);   
                if(assignWrapper != null) {
                    scheduleServiceAppointment(scope, assignWrapper);
                }   
            } catch(Exception e) {
                List<XC_BatchErrorLog__c> listBatchError = new List<XC_BatchErrorLog__c>();
                for(ServiceAppointment sa : scope) {
                    listBatchError.add(populateBatchError(sa.Id, e.getMessage(), Label.XC_CL_AutoSchedMaint_ErrorSchedule));
                }
                XC_UTIL_Sobject.insertListRecords(listBatchError);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ [XC_SC009_AutoScheduleMaintenance] Error in "execute" ---> ' + e.getMessage());
            }
        } 
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
     * @description finish
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC009_AutoScheduleMaintenance ID'); 
    }    

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 11/04/2019
     * @description assignWorkOrder
     * @param wrapperResult - XC_UTIL_Sobject.WrapperResult 
     * @param workOrderIds - List Id
     * @return assignWrapper
    */
    private AssignWrapper assignWorkOrder(List<XC_UTIL_Sobject.WrapperResult> wrapperResult, List<Id> workOrderIds) {
        AssignWrapper assignWrapper = null;
        if(wrapperResult[0].success) {
            assignWrapper = new AssignWrapper();
            assignWrapper.mapWorkOrder = new Map<Id,WorkOrder>([
                SELECT Id, XC_WorkTypeCategory__c, ServiceTerritoryId, OwnerId, XC_AssignedResource__c, PostalCode, AssetId, XC_PositionInMaintenancePlan__c, XC_Configuration__c, XC_WorkTypeLabel__c, WorkType.XC_AssignToPartner__c
                FROM WorkOrder 
                WHERE Id IN :workOrderIds]); 
            for(WorkOrder wo : assignWrapper.mapWorkOrder.values()) {
                assignWrapper.mapWorkTypeLabelAssignToPartner.put(wo.XC_WorkTypeLabel__c, wo.WorkType.XC_AssignToPartner__c);
            }
        }
        return assignWrapper;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 11/04/2019
     * @description scheduleServiceAppointment
     * @param scope - List ServiceAppointment
     * @param assignWrapper - AssignWrapper
    */
    private void scheduleServiceAppointment(List<ServiceAppointment> scope, AssignWrapper assignWrapper) {
        List<String> legalEntities = XC_UTIL_Sobject.getListFieldValues(scope, 'XC_LegalEntity__c');
        Map<String, String> mapQueues = getMapQueueDispatcher(legalEntities);
        XC_UTIL_AutoSchedule.AutoScheduleInputWrapper inputWr = new XC_UTIL_AutoSchedule.AutoScheduleInputWrapper();
        List<Case> listCaseToInsert = new List<Case>();
        List<WorkOrder> listWorkOrderToUpdate = new List<WorkOrder>();
        List<ServiceAppointment> listServiceAppointmentToUpdate = new List<ServiceAppointment>();
        Map<String, String> mapServiceAppointmentAccountName = getMapServiceAppointmentAccount(scope);
        
        for(ServiceAppointment sa : scope) {     
            if(!mapQueues.containsKey(sa.XC_LegalEntity__c)){
                break;
            }           
            inputWr.serviceAppointment = sa;
            inputWr.preferredStart = null;
            inputWr.preferredEnd = null;
            inputWr.operatingHoursId = null;  
            XC_UTIL_AutoSchedule.AutoSchedulingResult res = new XC_UTIL_AutoSchedule.AutoSchedulingResult();
            if(!Test.isRunningTest()) {
                res = XC_UTIL_AutoSchedule.autoScheduleAppointment(inputWr); 
                if(!res.success) {
                    insertBatchError(sa.Id, Label.XC_CL_AutoSchedMan_ImpossibleSentBO, Label.XC_CL_AutoSchedMan_ScheduleApp);
                }
            } 
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ [XC_SC009_AutoScheduleMaintenance] InputWrapper ---> ' + inputWr);
            if(!res.success || Test.isRunningTest()) { 
                XC_UTIL_WorkOrder.SendToBackOfficeWrapper wrSendToBackOffice = new XC_UTIL_WorkOrder.SendToBackOfficeWrapper();
                wrSendToBackOffice.serAppToChange = sa;
                wrSendToBackOffice.workOrderToChange = assignWrapper.mapWorkOrder.get(sa.ParentRecordId);
                wrSendToBackOffice.partnerIdCurrentResource = null;
                wrSendToBackOffice.queueId = mapQueues.get(sa.XC_LegalEntity__c);
                wrSendToBackOffice.mapWorkType = assignWrapper.mapWorkTypeLabelAssignToPartner;
                XC_UTIL_Sobject.WrapperResult resSendToBackOffice = XC_UTIL_WorkOrder.sendToBackOffice(wrSendToBackOffice);
                if(!resSendToBackOffice.success) {
                    insertBatchError(sa.Id, Label.XC_CL_AutoSchedMan_ImpossibleSentBO, Label.XC_CL_AutoSchedMan_ScheduleApp);
                }
                WorkOrder wo = new WorkOrder(Id = sa.ParentRecordId);
                Case cs = new Case();
                ManageAssignmentFailureWrapper manageWrapper = new ManageAssignmentFailureWrapper();
                manageWrapper.wo = new WorkOrder(Id = sa.ParentRecordId, AccountId = mapServiceAppointmentAccountName.get(sa.Id));
                manageWrapper.sa = sa;
                manageWrapper.idOwner = mapQueues.get(sa.XC_LegalEntity__c);
                manageAssignmentFailure(manageWrapper);
                listCaseToInsert.add(manageWrapper.cs);
                listWorkOrderToUpdate.add(manageWrapper.wo);
                listServiceAppointmentToUpdate.add(manageWrapper.sa);
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ [XC_SC009_AutoScheduleMaintenance] Send to Back Office ---> SA:[' + sa + '] &&& WO: [' + assignWrapper.mapWorkOrder.get(sa.ParentRecordId) + ']');
            }
        }
        manageDmlOperation(listCaseToInsert, listWorkOrderToUpdate, listServiceAppointmentToUpdate);
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 11/04/2019
     * @description scheduleServiceAppointment
     * @param listSa - List<ServiceAppointment>
     * @return Map<String, String>
    */
    private Map<String, String> getMapServiceAppointmentAccount(List<ServiceAppointment> listSa) {
        Map<String, String> mapServiceAppointmentAccountName = new Map<String, String>();
        List<String> listIdsWorkOrder = XC_UTIL_Sobject.getListFieldValues(listSa, 'ParentRecordId');
        List<WorkOrder> listWorkOrder = new List<WorkOrder>([
            SELECT Id, AccountId,
                (SELECT Id FROM ServiceAppointments)
            FROM WorkOrder
            WHERE Id IN :listIdsWorkOrder
        ]);
        for(WorkOrder wo : listWorkOrder) {
            for(ServiceAppointment sApp : wo.ServiceAppointments) {
                mapServiceAppointmentAccountName.put(sApp.Id, wo.AccountId);
            }
        }
        return mapServiceAppointmentAccountName;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 01/10/2019
     * @description Methot to insert Case and update WO and SA
     * @param listCaseToInsert - List<Case>
     * @param listWorkOrderToUpdate - List<WorkOrder>
     * @param listServiceAppointmentToUpdate - List<ServiceAppointment>
    */
    private static void manageDmlOperation(List<Case> listCaseToInsert, List<WorkOrder> listWorkOrderToUpdate, List<ServiceAppointment> listServiceAppointmentToUpdate) {
        List<XC_UTIL_Sobject.WrapperResult> resCaseToInsert = XC_UTIL_Sobject.insertListRecords(listCaseToInsert);
        List<XC_UTIL_Sobject.WrapperResult> resWoToUpdate = XC_UTIL_Sobject.updateListRecords(listWorkOrderToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> resSaToUpdate = XC_UTIL_Sobject.updateListRecords(listServiceAppointmentToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(resCaseToInsert) || !XC_UTIL_Sobject.checkDMLResults(resWoToUpdate) || !XC_UTIL_Sobject.checkDMLResults(resSaToUpdate)) {
            XC_BatchErrorLog__c batchError = new XC_BatchErrorLog__c();
            batchError.XC_TypeOfOperation__c = 'DML operations for SC009 in Failure Assignment';
            XC_UTIL_Sobject.insertRecord(batchError);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 11/09/2019
     * @description insert Batch Error
     * @param saId - Id ServiceAppointment
     * @param errorMessage - String
     * @param typeOfOperation - String
    */
    @TestVisible
    private static void insertBatchError(Id saId, String errorMessage, String typeOfOperation){
        XC_UTIL_Sobject.insertRecord(populateBatchError(saId, errorMessage, typeOfOperation));
    }
    
    private static XC_BatchErrorLog__c populateBatchError(Id saId, String errorMessage, String typeOfOperation) {
        XC_BatchErrorLog__c batchError = new XC_BatchErrorLog__c();
        batchError.XC_ErrorMessage__c = errorMessage;
        batchError.XC_TypeOfOperation__c = typeOfOperation;
        batchError.XC_RecordId__c = saId;
        return batchError;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 01/10/2019
     * @description Method to create a case when it is not possible to assign the Work Order, and update Status Reason for WO and SA
     * @param manageWrapper - ManageAssignmentFailureWrapper
    */
    private static void manageAssignmentFailure(ManageAssignmentFailureWrapper manageWrapper) {
        // Create Case:
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_MantenanceCaseSettingsName});
        XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get(Label.XC_CL_MantenanceCaseSettingsName);
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_MantenanceCaseSettingsName}));
        }
        manageWrapper.cs = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
        manageWrapper.cs.OwnerId = manageWrapper.idOwner;
        manageWrapper.cs.XC_WorkOrder__c = manageWrapper.wo.id;
        manageWrapper.cs.AccountId = manageWrapper.wo.AccountId;

        // Update Status Reason:
        manageWrapper.wo.XC_StatusReason__c = Label.XC_CL_WorkOrder_AssignmentError;
        manageWrapper.sa.XC_StatusReason__c = Label.XC_CL_WorkOrderServiceAppointment_SubStatus_Not_Workable;
    }

}