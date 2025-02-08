/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 06/10/2018
* @date Modification 15/11/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_ServiceAppointment_U_UpdateWO – Util Class to update WO status according to SA status
*/

public without sharing class XC_TR_ServiceAppointment_U_UpdateWO {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceAppointment_U_UpdateWO'); 
    /** Map for SA status -> WO status */
    public static Map<String, String> mapSAStatusWOStatus = new Map<String, String>{
            Label.XC_CL_ServiceAppointment_None => Label.XC_CL_WorkOrder_New,
            Label.XC_CL_ServiceAppointment_Scheduled => Label.XC_CL_WorkOrder_Assigned,
            Label.XC_CL_ServiceAppointment_Dispatched => Label.XC_CL_WorkOrder_Assigned,
            Label.XC_CL_ServiceAppointment_In_Progress => Label.XC_CL_InProgress,
            Label.XC_CL_ServiceAppointment_Completed => Label.XC_CL_Completed
            //Label.XC_CL_ServiceAppointment_OnHold => Label.XC_CL_OnHold
    };

    /** @description PopulateDmlWrapper */
    private class PopulateDmlWrapper {
        ServiceAppointment sa = new ServiceAppointment();
        WorkOrder wo = new WorkOrder();
        List<String> listOpportunityIds = new List<String>();
        List<String> listLeadIds = new List<String>();
    }

    /**
     * @description Manage work order status
     * @param listNew - List<ServiceAppointment>
     * @param mapOld - Map<Id,ServiceAppointment>
     * @param mapNew - Map<Id,ServiceAppointment>
     */
    public static void manageWorkOrder(List<ServiceAppointment> listNew, Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew){
        List<String> fieldListStatus = new List<String>{'Status','XC_StatusReason__c','SchedStartTime'};
        List<String> fieldListStatusReason = new List<String>{'XC_StatusReason__c'};
        List<String> fieldListStatusOnWo = new List<String>{'Status'};
        List<String> fieldListStartdate = new List<String>{'ActualStartTime'};
        List<String> fieldListEnddate = new List<String>{'ActualEndTime'};
        List<String> fieldMaxWallboxPower = new List<String>{'XC_MaxWallboxPower__c'};
        List<String> fieldResult = new List<String>{'XC_Result__c'};
        List<String> fieldDueDate = new List<String>{'DueDate'};
        List<ServiceAppointment> listChangedStatus = XC_UTIL_Sobject.getListChanged(fieldListStatus, mapOld, mapNew);
        List<ServiceAppointment> listChangedStatusReason = XC_UTIL_Sobject.getListChanged(fieldListStatusReason, mapOld, mapNew);
        List<ServiceAppointment> listChangedStatusOnWo = XC_UTIL_Sobject.getListChanged(fieldListStatusOnWo, mapOld, mapNew);
        List<ServiceAppointment> listChangedStartDate = XC_UTIL_Sobject.getListChanged(fieldListStartdate, mapOld, mapNew);
        List<ServiceAppointment> listChangedEndDate = XC_UTIL_Sobject.getListChanged(fieldListEnddate, mapOld, mapNew);
        List<ServiceAppointment> listChangedMaxWallboxPower = XC_UTIL_Sobject.getListChanged(fieldMaxWallboxPower, mapOld, mapNew);
        List<ServiceAppointment> listChangedResult = XC_UTIL_Sobject.getListChanged(fieldResult, mapOld, mapNew);
        List<ServiceAppointment> listDueDate = XC_UTIL_Sobject.getListChanged(fieldDueDate, mapOld, mapNew);
        Map<Id, WorkOrder> mapWorkOrder;
        List<ServiceAppointment> listChangedStatusAndStatusReason = new List<ServiceAppointment>();
        listChangedStatusAndStatusReason.addAll(listChangedStatusReason);
        listChangedStatusAndStatusReason.addAll(listChangedStatusOnWo);
        if(!listChangedStatus.isEmpty() || !listChangedStartDate.isEmpty() || !listChangedEndDate.isEmpty() || !listChangedStatusAndStatusReason.isEmpty()){
            mapWorkOrder = getMapWorkOrders(listChangedStatus, listChangedStartDate, listChangedEndDate);
        }

        if(!listChangedStatus.isEmpty()){
            //Set<String> parentWorkOrderIdsStatus = XC_UTIL_SObject_U_Retrieve.getSetFieldValues(listChangedStatus, 'ParentRecordId');
            //updateWOStatus(listChangedStatus, parentWorkOrderIdsStatus, parentMap, mapOld);
            updateWOStatus(listChangedStatus, mapWorkOrder, mapOld);
        }

        if(!listChangedStartDate.isEmpty()){
            Set<String> parentWorkOrderIdsStartDate = XC_UTIL_SObject_U_Retrieve.getSetFieldValues(listChangedStartDate, 'ParentRecordId');
            calculateHoursFromOppCreation(listChangedStartDate, parentWorkOrderIdsStartDate, mapWorkOrder);
        }
        
        if(!listChangedEndDate.isEmpty() || !listChangedMaxWallboxPower.isEmpty() || !listChangedResult.isEmpty() || !listDueDate.isEmpty() || !listChangedStatusAndStatusReason.isEmpty()){
            List<WorkOrder> listWOToUpdate = new List<WorkOrder>();  
            Map<String, WorkOrder> mapWOtoUpdate = new Map<String, WorkOrder>();
            for(ServiceAppointment sa : listChangedEndDate) {
                String key = sa.ParentRecordId;
                if(!mapWorkOrder.containsKey(key)){
                    continue;
                }
                WorkOrder wo = mapWorkOrder.get(key);
                    for(WorkOrder woChild : wo.ChildWorkOrders){
                        WorkOrder woChildToUpdate = woChild;
                        woChildToUpdate.XC_ActualEndDate__c = sa.ActualEndTime;
                        listWOToUpdate.add(woChildToUpdate);    
                    }
                wo.XC_ActualEndDate__c = sa.ActualEndTime;
                mapWOtoUpdate.put(key, wo);
            }
            for(ServiceAppointment sa : listChangedMaxWallboxPower){
                String key = sa.ParentRecordId;
                if(mapWOtoUpdate.containsKey(key)){
                    mapWOtoUpdate.get(key).XC_MaxWallboxPower__c = sa.XC_MaxWallboxPower__c;
                } else {
                    WorkOrder wo = new WorkOrder(
                        Id = key, 
                        XC_MaxWallboxPower__c = sa.XC_MaxWallboxPower__c
                    );
                    mapWOtoUpdate.put(key, wo);
                }
            }
            for(ServiceAppointment sa : listChangedResult){
                String key = sa.ParentRecordId;
                if(mapWOtoUpdate.containsKey(key)){
                    mapWOtoUpdate.get(key).XC_Result__c = sa.XC_Result__c;
                } else {
                    WorkOrder wo = new WorkOrder(Id = key, XC_Result__c = sa.XC_Result__c);
                    mapWOtoUpdate.put(key, wo);
                }
            }
            for(ServiceAppointment sa : listDueDate){
                String key = sa.ParentRecordId;
                if(mapWOtoUpdate.containsKey(key)){
                    mapWOtoUpdate.get(key).XC_DueDate__c = sa.DueDate;
                } else {
                    mapWOtoUpdate.put(key, new WorkOrder(Id = key, XC_DueDate__c = sa.DueDate));
                }
            }
            for(ServiceAppointment sa : listChangedStatusAndStatusReason){
                String key = sa.ParentRecordId;
                if(mapWOtoUpdate.containsKey(key)){
                    mapWOtoUpdate.get(key).XC_StatusReasonOfServiceAppointment__c = sa.XC_StatusReason__c;
                    mapWOtoUpdate.get(key).XC_StatusOfServiceAppointment__c = sa.Status;
                } else {
                    mapWOtoUpdate.put(key, new WorkOrder(Id = key, XC_StatusReasonOfServiceAppointment__c = sa.XC_StatusReason__c, XC_StatusOfServiceAppointment__c = sa.Status));
                }
                WorkOrder wo = mapWorkOrder.get(key);
                for(WorkOrder woChild : wo.ChildWorkOrders){
                    if(mapWOtoUpdate.containsKey(woChild.Id)){
                        mapWOtoUpdate.get(woChild.Id).XC_StatusReasonOfServiceAppointment__c = sa.XC_StatusReason__c;
                        mapWOtoUpdate.get(woChild.Id).XC_StatusOfServiceAppointment__c = sa.Status;
                    } else {
                        mapWOtoUpdate.put(woChild.Id, new WorkOrder(Id = woChild.Id, XC_StatusReasonOfServiceAppointment__c = sa.XC_StatusReason__c, XC_StatusOfServiceAppointment__c = sa.Status));
                    } 
                }
            }
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
            listWOToUpdate.addAll(mapWOtoUpdate.values()); 
            XC_UTIL_Sobject.updateListRecords(listWOToUpdate); 
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
            XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        }
    }

    /**
    * @description Update WO status
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @param listToUpdate
    * @param parentWorkOrderIds
    * @param parentMap
    * @param mapOld
    */ 
    public static void updateWOStatus(List<ServiceAppointment> listToUpdate, Map<Id, WorkOrder> mapWorkOrder, Map<Id,ServiceAppointment> mapOld){
        List<WorkOrder> parentWoList = new List<WorkOrder>();
        List<WorkOrder> listWoToUpdate = new List<WorkOrder>();
        Map<String,WorkOrder> mapIdWorkOrderChild = new Map<String,WorkOrder>();
        for (ServiceAppointment sa : listToUpdate) {
            if(mapWorkOrder.containsKey(sa.ParentRecordId)){
                parentWoList.add(mapWorkOrder.get(sa.ParentRecordId));
            }
        }        
        List<String> listOpportunityIds = XC_UTIL_SObject_U_Retrieve.getListFieldValues(parentWoList, 'XC_Opportunity__c');
        List<String> listLeadIds = XC_UTIL_SObject_U_Retrieve.getListFieldValues(parentWoList, 'XC_Lead__c');
        List<Case> listCaseToInsert = new List<Case>();
        Map<String, Boolean> mapRequestRescheduling = calculateRequiresRescheduling(listToUpdate);
        for(ServiceAppointment sa : listToUpdate) {
            WorkOrder wo = new WorkOrder();
            wo.Id = sa.ParentRecordId;
            if(mapWorkOrder.containsKey(sa.ParentRecordId)){
                wo = mapWorkOrder.get(sa.ParentRecordId);
            }
            wo.AccountId = sa.AccountId; 
            PopulateDmlWrapper wrapper = new PopulateDmlWrapper();
            wrapper.sa = sa;
            wrapper.wo = wo;
            wrapper.listOpportunityIds = listOpportunityIds;
            wrapper.listLeadIds = listLeadIds;
            populateForCase(wrapper, listCaseToInsert, mapOld);
            manageStatusReason(wrapper.wo, sa, mapOld, mapRequestRescheduling);
            setSchedulingDateonWO(wrapper.wo, sa, mapOld);
            mapIdWorkOrderChild = populateTimestampOnChildWO(wrapper.wo);
            if(!mapIdWorkOrderChild.isEmpty()){
                listWoToUpdate.addAll(mapIdWorkOrderChild.values());
            }
            listWoToUpdate.add(wrapper.wo);
        }

        List<XC_UTIL_Sobject.WrapperResult> wrapperResultList = XC_UTIL_Sobject.updateListRecords(listWoToUpdate);
        for(ServiceAppointment sa : listToUpdate){
            for(XC_UTIL_Sobject.WrapperResult wrapper : wrapperResultList){
                if(!wrapper.success && (String.isNotBlank(wrapper.errorObjectId) && sa.ParentRecordId == wrapper.errorObjectId)) {
                    sa.addError(wrapper.errorMessage);
                }
            }
        }
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, '@@@ listCaseToInsert ---> ' + listCaseToInsert);
        XC_UTIL_Sobject.insertListRecords(listCaseToInsert);
    } 

    /**
    * @description Method to calculate a new Status Reason for Work Order
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 28/02/2020
    * @param wo - WorkOrder
    * @param sa - ServiceAppointment
    * @param mapOld - Map<Id, ServiceAppointment>
    * @param mapRequestRescheduling - Map<String, Boolean>
    **/
    private static void manageStatusReason(WorkOrder wo, ServiceAppointment sa, Map<Id, ServiceAppointment> mapOld, Map<String, Boolean> mapRequestRescheduling) {
        if(sa.Status == Label.XC_CL_ServiceAppointment_Scheduled){
            if(!sa.XC_AssignToPartner__c) {
                Boolean requestRescheduling = mapRequestRescheduling.containsKey(sa.Id) ? mapRequestRescheduling.get(sa.Id) : false;
                if(requestRescheduling) {
                    if(sa.XC_StatusReason__c == Label.XC_CL_StatusReason_Assignedtothetechnician || sa.XC_StatusReason__c == Label.XC_CL_StatusReason_ToBeScheduled ) {
                        wo.XC_StatusReason__c = sa.XC_StatusReason__c;
                    }
                } else {
                    wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Assignedtothetechnician;
                    if(wo.XC_ScheduleDateTimestamp__c == null){
                        wo.XC_ScheduleDateTimestamp__c = System.now();
                    }
                }
            } else {
                if(sa.XC_StatusReason__c == Label.XC_CL_StatusReason_ToBeScheduled ) {
                	wo.XC_StatusReason__c = Label.XC_CL_StatusReason_ToBeScheduled;
                }else{
                	wo.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician;
                }
            }
        }
    }

    /**
    * @description Method to calculate Scheduling Dates on Work Order
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @date 26/03/2020
    * @param wo - WorkOrder
    * @param sa - ServiceAppointment
    * @param mapOld - Map<Id, ServiceAppointment>
    **/
    private static void setSchedulingDateonWO (WorkOrder wo, ServiceAppointment sa, Map<Id, ServiceAppointment> mapOld) {
        if(mapOld.get(sa.Id).SchedStartTime != sa.SchedStartTime){
            wo.XC_AssignmentDate__c = System.now();
            wo.XC_ScheduledStart__c = sa.SchedStartTime;
            wo.SlaStartDate = sa.SchedStartTime;
        }
        if(wo.XC_AssignmentDateTimestamp__c == null && (sa.Status == Label.XC_CL_ServiceAppointment_Scheduled || sa.Status == Label.XC_CL_ServiceAppointment_None)){
            wo.XC_AssignmentDateTimestamp__c = System.now();
        }
    }


    /**
    * @description Method to calculate a Map SA -> Request Rescheduling (from CM)
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 28/02/2020
    * @param listServiceAppointment - List<ServiceAppointment>
    * @return Map<String, Boolean>
    **/

    public static Map<String, Boolean> calculateRequiresRescheduling(List<ServiceAppointment> listServiceAppointment) {
        Set<String> listWorkOrderIds = XC_UTIL_SObject_U_Retrieve.getSetFieldValues(listServiceAppointment, 'ParentRecordId');
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>([SELECT Id, XC_Segment__c FROM WorkOrder WHERE Id IN: listWorkOrderIds]);
        return calculateRequiresRescheduling(listServiceAppointment, woMap);
    } 

    private static Map<String, Boolean> calculateRequiresRescheduling(List<ServiceAppointment> listServiceAppointment, Map<Id, WorkOrder> woMap) {
        Map<String, Boolean> mapAppointmentRequestRescheduling = new Map<String, Boolean>(); 
        Set<String> setStream = XC_UTIL_Sobject.getSetIdsStringOnField(woMap.values(), 'XC_Segment__c');
        List<String> listLegalEntity = XC_UTIL_Sobject.getListFieldValues(listServiceAppointment, 'XC_LegalEntity__c');

        List<XC_CM_LegalEntity_Configuration__mdt> listCmFromLE = new List<XC_CM_LegalEntity_Configuration__mdt>();
        if(setStream.isEmpty()) {
            listCmFromLE = new List<XC_CM_LegalEntity_Configuration__mdt>([
                    SELECT Id, XC_RequiresRescheduling__c, XC_LegalEntity__c, XC_Stream__c
                    FROM XC_CM_LegalEntity_Configuration__mdt
                    WHERE XC_LegalEntity__c IN :listLegalEntity AND XC_OrgId__c =: UserInfo.getOrganizationId()]);
        } else {
            listCmFromLE = new List<XC_CM_LegalEntity_Configuration__mdt>([
                    SELECT Id, XC_RequiresRescheduling__c, XC_LegalEntity__c, XC_Stream__c
                    FROM XC_CM_LegalEntity_Configuration__mdt
                    WHERE XC_LegalEntity__c IN :listLegalEntity AND XC_Stream__c = :setStream AND XC_OrgId__c =: UserInfo.getOrganizationId()]);
        }

        for(ServiceAppointment sa : listServiceAppointment) {
            for(XC_CM_LegalEntity_Configuration__mdt leMdt : listCmFromLE) {
                if(sa.XC_LegalEntity__c == leMdt.XC_LegalEntity__c && woMap.get(sa.ParentRecordId) != null && woMap.get(sa.ParentRecordId).XC_Segment__c == leMdt.XC_Stream__c) {
                    mapAppointmentRequestRescheduling.put(sa.Id, leMdt.XC_RequiresRescheduling__c);
                    continue;
                }
            }
        }
        return mapAppointmentRequestRescheduling;
    }

    /**
    * @description Method to calculate number of hours from Opportunity Creation
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param listChanged
    * @param parentWorkOrderIds
    * @param parentMap
    **/
    private static void calculateHoursFromOppCreation(List<ServiceAppointment> listChanged, Set<String> parentWorkOrderIds, Map<Id, WorkOrder> parentMap) {
        Map<String, DateTime> mapWorkOrderStartTime = new Map<String, DateTime>();
        for(ServiceAppointment sa : listChanged) {
            mapWorkOrderStartTime.put(sa.ParentRecordId, sa.ActualStartTime);
        }

        List<WorkOrder> listWorkOrder = new List<WorkOrder>();
        for(String parentId : parentWorkOrderIds) {
            WorkOrder parentWo = parentMap.containsKey(parentId) ? parentMap.get(parentId) : null;
            if(parentWo == null || (String.isBlank(parentWo.XC_Opportunity__c) && String.isBlank(parentWo.XC_Lead__c))) {
                continue;
            }
            if(parentWo != null) {
                listWorkOrder.add(parentWo);
            }
        }

        for(WorkOrder wo : listWorkOrder) {
            Integer numberDaysDue;
            if(String.isNotBlank(wo.XC_Lead__c)) {
                Date startDate = Date.newinstance(wo.XC_Lead__r.CreatedDate.year(), wo.XC_Lead__r.CreatedDate.month(), wo.XC_Lead__r.CreatedDate.day());
                Date endDate = Date.newinstance(mapWorkOrderStartTime.get(wo.Id).year(), mapWorkOrderStartTime.get(wo.Id).month(), mapWorkOrderStartTime.get(wo.Id).day());
                numberDaysDue = startDate.daysBetween(endDate);
                wo.XC_HoursFromOppCreation__c = mapWorkOrderStartTime.get(wo.Id).hour() - wo.XC_Lead__r.CreatedDate.hour();
            } else {
                Date startDate = Date.newinstance(wo.XC_Opportunity__r.CreatedDate.year(), wo.XC_Opportunity__r.CreatedDate.month(), wo.XC_Opportunity__r.CreatedDate.day());
                Date endDate = Date.newinstance(mapWorkOrderStartTime.get(wo.Id).year(), mapWorkOrderStartTime.get(wo.Id).month(), mapWorkOrderStartTime.get(wo.Id).day());
                numberDaysDue = startDate.daysBetween(endDate);
                wo.XC_HoursFromOppCreation__c = mapWorkOrderStartTime.get(wo.Id).hour() - wo.XC_Opportunity__r.CreatedDate.hour();
            }
            if(numberDaysDue!=0) {
                wo.XC_HoursFromOppCreation__c = wo.XC_HoursFromOppCreation__c + (numberDaysDue*24);
            }
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        List<XC_UTIL_Sobject.WrapperResult> listWrapperResult = XC_UTIL_Sobject.updateListRecords(listWorkOrder);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        if(!XC_UTIL_Sobject.checkDMLResults(listWrapperResult)) {
            listChanged[0].addError(listWrapperResult[0].errorMessage);
        }
    }

    /**
     * @description Method for populate Case to insert and work order to update
     * @param wrapper - PopulateDmlWrapper
     * @param listCaseToInsert - List<Case>
     * @param mapOld - Map<Id,ServiceAppointment>
     */
    private static void populateForCase(PopulateDmlWrapper wrapper, List<Case> listCaseToInsert, Map<Id,ServiceAppointment> mapOld) {
        Boolean isItalyB2B = wrapper.wo!=null && wrapper.wo.XC_Segment__c != null && (wrapper.wo.XC_Segment__c == 'B2B' || wrapper.wo.XC_Segment__c == 'B2G') && wrapper.wo.XC_Country__c == 'Italy';

        if(mapSAStatusWOStatus.containsKey(wrapper.sa.Status)){
            if(isItalyB2B && wrapper.sa.Status == 'Completed'){
                wrapper.wo.XC_StatusReason__c = 'Technician Works End';
            }else {
                Boolean skipUpdate = wrapper.sa.Status == Label.XC_CL_ServiceAppointment_Completed && (wrapper.sa.XC_StatusReason__c == Label.XC_CL_StatusReason_QuoteRejected || wrapper.wo.XC_StatusReason__c == 'Technically unviable installation - No viable alternative' || wrapper.wo.XC_StatusReason__c == 'Technically unviable installation - With alternative' || wrapper.wo.XC_StatusReason__c == 'Customer wants modifications with an already accepted budget');
                if(!skipUpdate){
                    wrapper.wo.Status = mapSAStatusWOStatus.get(wrapper.sa.Status);
                }
                checkIdInProgressCommercialVisit(wrapper.sa, wrapper.listOpportunityIds, wrapper.listLeadIds);
                if (mapOld.get(wrapper.sa.Id).Status != Label.XC_CL_ServiceAppointment_None && wrapper.sa.Status == Label.XC_CL_ServiceAppointment_None) {
                    wrapper.wo.XC_AssignedPartner__c = null;
                    wrapper.wo.XC_AssignedResource__c = null;
                    wrapper.wo.ServiceTerritoryId = null;
                }
            }
        } else if(wrapper.sa.Status==Label.XC_CL_ServiceAppointment_OnHold){
            if(isItalyB2B) {
                wrapper.wo.XC_StatusReason__c = 'Service Appointment On Hold';
            }else{
                manageOnHold(wrapper.sa, wrapper.wo);
            }
        } else if(wrapper.sa.Status==Label.XC_CL_ServiceAppointment_CannotComplete){
            if(isItalyB2B){
                wrapper.wo.XC_StatusReason__c = 'Service Appointment Cannot Completed';
            }else {
                Case newCase = manageCannotComplete(wrapper.sa, wrapper.wo);
                if (newCase != null) {
                    listCaseToInsert.add(newCase);
                }
            }
        } else if(wrapper.sa.Status==Label.XC_CL_ServiceAppointment_Canceled){
            if(wrapper.wo.Status != null && wrapper.wo.Status != Label.XC_CL_WorkOrder_Canceled && 
                wrapper.wo.XC_Segment__c=='B2C'){
                wrapper.wo.Status = wrapper.sa.XC_ForceWOCancellation__c ? Label.XC_CL_WorkOrder_Canceled : Label.XC_CL_WorkOrder_New;
            }
            /*Case newCase = manageCancelled(wrapper.sa, wrapper.wo);
            if(newCase != null) {
                listCaseToInsert.add(newCase);
            }*/
        }
    }

    /**
     * @description Create Case for closed Service Appointment
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 10/06/2019
     * @param workOrderId - String
     * @param accountId - String
     * @param closeWorkOrder - Boolean
     * @return Case
     */
    private static Case createCaseByServiceAppointment(String workOrderId, String accountId, Boolean closeWorkOrder) {
        String mdtCase;
        if(closeWorkOrder) {
            mdtCase = 'XC_ServiceAppointmentClosed';
        } else {
            mdtCase = 'XC_ServiceAppointmentClosedWithoutWO';
        }
        Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{mdtCase});
        XC_CM_Case_Type_Setting__mdt caseSettings = caseSettingsMap.get(mdtCase);
        if(caseSettings == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', mdtCase}));
        }
        Case cs = XC_UTIL_Case.initCaseFromCaseSettings(caseSettings);
        cs.XC_WorkOrder__c = workOrderId;
        cs.AccountId = accountId;
        cs.Status = caseSettings.XC_Status__c;
        return cs;
    }


    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it & Emanuela Cacace - ecacace@deloitte.it
    * @param sa - ServiceAppointment
    * @param listOpportunityIds - List<String>
    * @param listLeadIds - List<String>
    * @description Method to check Commercial Visit
    */
    private static void checkIdInProgressCommercialVisit(ServiceAppointment sa, List<String> listOpportunityIds, List<String> listLeadIds){
        if(sa.Status==Label.XC_CL_ServiceAppointment_In_Progress && sa.XC_WorkTypeCategory__c == Label.XC_CL_CommercialVisit){
            manageInProgress(listOpportunityIds, listLeadIds);
        }
    }

    /**
    * @author Roberta Cossiga - rcossiga@deloitte.it
    * @Modified by Salvatore Agrillo - salvatore.agrillo@nttdata.com - 15/11/2019
    * @description Method to get Opportunity from WorkOrder
    * @param listToUpdateStatus
    * @param listToUpdateStartDate
    * @param listToUpdateEndDate
    * @return Map<Id, WorkOrder>
    **/
    private static Map<Id, WorkOrder> getMapWorkOrders(List<ServiceAppointment> listToUpdateStatus, List<ServiceAppointment> listToUpdateStartDate, List<ServiceAppointment> listToUpdateEndDate){
        List<ServiceAppointment> listToUpdate = new List<ServiceAppointment>();
        listToUpdate.addAll(listToUpdateStatus);
        listToUpdate.addAll(listToUpdateStartDate);
        listToUpdate.addAll(listToUpdateEndDate);
        Set<String> listWorkOrderIds = XC_UTIL_SObject_U_Retrieve.getSetFieldValues(listToUpdate, 'ParentRecordId');

        Map<Id, WorkOrder> mapWorkOrders = new Map<Id, WorkOrder>([
                SELECT Id, XC_Opportunity__c, XC_Opportunity__r.CreatedDate, XC_Lead__c, XC_Lead__r.CreatedDate, XC_Segment__c,
                    AccountId,Status,XC_StatusReason__c, XC_Country__c, XC_WorkTypeCategory__c, XC_AssignmentDateTimestamp__c, XC_ScheduleDateTimestamp__c, XC_ScheduledStart__c,
                    (SELECT ID, XC_ActualEndDate__c FROM ChildWorkOrders)
                FROM WorkOrder
                WHERE Id IN :listWorkOrderIds //AND (XC_Opportunity__c != null OR XC_Lead__c != null)
        ]);

        return mapWorkOrders;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param sa - ServiceAppointment
     * @param wo - WorkOrder
     * @description Method to manage On Hold
     */
    private static void manageOnHold(ServiceAppointment sa, WorkOrder wo){
        if(sa.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance && sa.XC_MaintenanceSubStatus__c == Label.XC_CL_WorkOrderServiceAppointment_SubStatus_Not_Workable){
            wo.Status = Label.XC_CL_WorkOrder_Assigned;
        } else{
            wo.Status = Label.XC_CL_OnHold;
        }
    }

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it & Emanuela Cacace - ecacace@deloitte.it
     * @param listOpportunityIds - List<String>
     * @param listLeadIds - List<String>
     * @description Method to manage In Progress WO
     */
    @TestVisible
    private static void manageInProgress(List<String> listOpportunityIds, List<String> listLeadIds){
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<Lead> leadsToUpdate = new List<Lead>();
        for(String oppId : listOpportunityIds) {
            Opportunity opp = new Opportunity(
                    Id = oppId,
                    XC_CommercialVisitStarted__c = true
            );
            opportunitiesToUpdate.add(opp);
        }
        for(String leadId : listLeadIds) {
            Lead lead = new Lead(
                    Id = leadId,
                    XC_CommercialVisitStarted__c = true
            );
            leadsToUpdate.add(lead);
        }
        XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_SObject.updateListRecords(opportunitiesToUpdate);
        XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Opportunity_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);

        XC_TR_Lead_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_Lead_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_SObject.updateListRecords(leadsToUpdate);
        XC_TR_Lead_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_Lead_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
    }

    /**
    * @description Method to manage Cannot Complete WO
    * @author Roberta Cossiga - rcossiga@deloitte.it & Emanuela Cacace - ecacace@deloitte.it
    * @param sa
    * @param wo
    * @return Case
    **/
    private static Case manageCannotComplete(ServiceAppointment sa, WorkOrder wo){
        XC_UTIL_DEBUG.debug(DEBUGACTIVE, sa.XC_Check_Final_Status__c);

        // Manage Status Reason:
        if(sa.XC_StatusReason__c == Label.XC_CL_StatusReason_Customerrefusesthevisit) {
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) {
                wo.XC_StatusReason__c = Label.XC_CL_StatusReason_RequestNewVisit;
            }
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance) {
                wo.XC_StatusReason__c = Label.XC_CL_StatusReason_PendingContact;
            }
        }
        else if(sa.XC_StatusReason__c == Label.XC_CL_StatusReason_Thecustomercannotfinishthevisit && (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit ||
                wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation)) {
            wo.XC_StatusReason__c = Label.XC_CL_StatusReason_RequestNewVisit;
        }
        else if(sa.XC_StatusReason__c == Label.XC_CL_StatusReason_Thejobcannotbecompleted && (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance)) {
            wo.XC_StatusReason__c = Label.XC_CL_StatusReason_PendingContact;
        }
        else if(sa.XC_StatusReason__c == Label.XC_CL_StatusReason_Servicenotfinished && (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation)) {
            wo.XC_StatusReason__c = Label.XC_CL_StatusReason_PteContactServicenotfinished;
        }
        else if(sa.XC_StatusReason__c == Label.XC_CL_StatusReason_Failedvisit && (
                wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit ||
                        wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation ||
                        wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_PlannedMaintenance
        )) {
            wo.XC_StatusReason__c = Label.XC_CL_StatusReason_PendingContact;
        }

        // Manage Final Status and Case creation
        if(!sa.XC_Check_Final_Status__c) {
            wo.Status=Label.XC_CL_CannotComplete;
            wo.XC_Reason_Cannot_Complete__c=sa.XC_Reason_Cannot_Complete__c;
            return createCaseByServiceAppointment(wo.Id, wo.AccountId, true);
        } else {
            wo.Status=Label.XC_CL_OnHold;
            wo.XC_Reason_Cannot_Complete__c=sa.XC_Reason_Cannot_Complete__c;
            return createCaseByServiceAppointment(wo.Id, wo.AccountId, false);
        }
    }

    /**
     * @author Domenico Del Prete - domenico.delprete@nttdata.com
     * @param parentWO - WorkOrder
     * @param listWoToUpdate - List<WorkOrder>
     * @description Method to populate Timestamp field on Child WorkOrders
     */
    private static Map<String, WorkOrder> populateTimestampOnChildWO (WorkOrder parentWO){
        Map<String, WorkOrder> mapIdWorkOrderChild = new Map<String, WorkOrder>();
        for(WorkOrder woChild : parentWO.ChildWorkOrders){
            if(parentWo.XC_AssignmentDateTimestamp__c != null){
                if(mapIdWorkOrderChild.containsKey(woChild.Id)){
                    mapIdWorkOrderChild.get(woChild.Id).XC_AssignmentDateTimestamp__c = parentWo.XC_AssignmentDateTimestamp__c;
                } else {
                    WorkOrder wo = new WorkOrder(Id = woChild.Id, XC_AssignmentDateTimestamp__c = parentWo.XC_AssignmentDateTimestamp__c);
                    mapIdWorkOrderChild.put(woChild.Id, wo);
                }            }
            if(parentWo.XC_ScheduleDateTimestamp__c != null){
                if(mapIdWorkOrderChild.containsKey(woChild.Id)){
                    mapIdWorkOrderChild.get(woChild.Id).XC_ScheduleDateTimestamp__c = parentWo.XC_ScheduleDateTimestamp__c;
                } else {
                    WorkOrder wo = new WorkOrder(Id = woChild.Id, XC_ScheduleDateTimestamp__c = parentWo.XC_ScheduleDateTimestamp__c);
                    mapIdWorkOrderChild.put(woChild.Id, wo);
                }   
            }
            if(parentWo.XC_ScheduledStart__c != null){
                if(mapIdWorkOrderChild.containsKey(woChild.Id)){
                    mapIdWorkOrderChild.get(woChild.Id).XC_ScheduledStart__c = parentWo.XC_ScheduledStart__c;
                } else {
                    WorkOrder wo = new WorkOrder(Id = woChild.Id, XC_ScheduledStart__c = parentWo.XC_ScheduledStart__c);
                    mapIdWorkOrderChild.put(woChild.Id, wo);
                }   
            }
        }
        return mapIdWorkOrderChild;
    }

    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it & Emanuela Cacace - ecacace@deloitte.it
     * @param sa - ServiceAppointment
     * @param wo - WorkOrder
     * @return Case
     * @description Method to manage Cancelled WO
     */
    /*private static Case manageCancelled(ServiceAppointment sa, WorkOrder wo){
        if(sa.XC_Check_Final_Status__c){
            wo.Status=Label.XC_CL_Cancelled;
            //return createCaseByServiceAppointment(wo.Id, wo.AccountId, true);
            return null;
        } else{
            wo.Status=Label.XC_CL_OnHold;
            return createCaseByServiceAppointment(wo.Id, wo.AccountId, false);
        }
    }*/
}