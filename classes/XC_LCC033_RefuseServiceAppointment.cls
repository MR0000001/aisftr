/**
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it -
 * @date Creation 05/11/2018
 * @date Modification Salvatore Scarpato - Roberta Cossiga - Roberta Porrega - Sara Miozza - Marco Rosa - 14/02/2018
 * @date Modification 26/11/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_LCC033_RefuseServiceAppointment - Refusing Service Appointment
 */

public without sharing class XC_LCC033_RefuseServiceAppointment {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC033_RefuseServiceAppointment');
    private static Map<Id,WorkOrder> workOrderToChangeMap;

    /** @description Result Wrapper */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String message = '';
    }

    /** @description Parameter Wrapper */
    public class ParameterWrapper {
        @AuraEnabled
        public XC_UTIL_Sobject.WrapperResult dmlResult = new XC_UTIL_Sobject.WrapperResult();
        @AuraEnabled
        public ServiceAppointment serAppToChange = new ServiceAppointment();
        @AuraEnabled
        public WorkOrder workOrderToChange = new WorkOrder();
        @AuraEnabled
        public String partnerIdCurrentResource = '';
        @AuraEnabled
        public User currentUser = new User();
        @AuraEnabled
        public ResultWrapper result = new ResultWrapper();
        @AuraEnabled
        public ServiceResource currentSr;
    }

    /**
    * @description Change Service Appointment to Refuse
    * @date Modification 26/11/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param serviceAppId - String
    * @param newRefusingReason - String
    * @return ResultWrapper
    */
    @AuraEnabled
    public static ResultWrapper changesSerAppointment(String serviceAppId, String newRefusingReason) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'changesSerAppointment: ');
        ParameterWrapper parameterWrapper = new ParameterWrapper();
        try {
            List<User> currentUserMap = new List<User>([
                SELECT Id, ContactId,
                    (SELECT Id, XC_Account__c, IsCapacityBased, AccountId, XC_IsManager__c, ResourceType, XC_LegalEntity__c, RelatedRecord.Profile.Name
                    FROM ServiceResources
                    WHERE isActive = true) //ResourceType = 'T' AND 
                FROM User WHERE Id =: UserInfo.getUserId()
            ]);
            populateWrapper(parameterWrapper, currentUserMap, serviceAppId);
            String queueDispatcher = getQueueDispatcher(parameterWrapper.serAppToChange.XC_LegalEntity__c, parameterWrapper.workOrderToChange.XC_Segment__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ parameterWrapper -> ' + parameterWrapper);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ currentUserMap -> ' + currentUserMap);
            
            if(currentUserMap[0].ServiceResources.isEmpty()){
                parameterWrapper.result.success = false;
                parameterWrapper.result.message = Label.XC_CL_OnlyTechOrPartnerCanRefuseAppError;
                return parameterWrapper.result;
            }

            List<AssignedResource> assResource = new List<AssignedResource>([
                SELECT Id, ServiceResourceId, ServiceResource.AccountId, ServiceResource.XC_IsManager__c 
                FROM AssignedResource 
                WHERE ServiceAppointmentId =:serviceAppId
            ]);


            ServiceResource currentSr = new ServiceResource();//currentUserMap[0].ServiceResources[0];
            currentSr.Id = assResource[0].ServiceResourceId;
            currentSr.AccountId = assResource[0].ServiceResource.AccountId;
            currentSr.XC_IsManager__c = assResource[0].ServiceResource.XC_IsManager__c;
            parameterWrapper.currentSr = currentSr; 

            Boolean isPartnerForSpain = (currentUserMap[0].ServiceResources[0].XC_LegalEntity__c == Label.XC_CL_EndesaX || currentUserMap[0].ServiceResources[0].XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain) && (currentUserMap[0].ServiceResources[0].RelatedRecord.Profile.Name == 'XC_ESP_PartnerAdmin' || currentUserMap[0].ServiceResources[0].ResourceType == 'D');
            Boolean isPartner = currentSr.XC_IsManager__c; //|| currentUserMap[0].ServiceResources[0].ResourceType == 'D'; //currentSr.IsCapacityBased 
            if(isPartner) {
                parameterWrapper.serAppToChange.XC_AssignToPartner__c = true;
            }/*else {
                checkOtherTechs(workOrderToChangeMap, parameterWrapper, currentSr); 
            }*/
            parameterWrapper = updateWorkOrderAndServiceAppointment(parameterWrapper, newRefusingReason);
            parameterWrapper = setDatesAndSendToBackOffice(parameterWrapper, queueDispatcher, (isPartner || isPartnerForSpain));
        } catch (Exception e) {
            populateWrapperResult(parameterWrapper, false, e.getMessage());
        }
        return parameterWrapper.result;
    }

    /**
    * @description Method to create a Case for SA Refuse
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 26/11/2019
    * @param workOrder - WorkOrder
    * @return Boolean
    */
    public static XC_UTIL_Sobject.WrapperResult createCaseForRefuse(WorkOrder workOrder) {
        // Da modificare la label
        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_ServiceAppointment_Refuse'});
        XC_CM_Case_Type_Setting__mdt caseMDT = mapCaseSetting.get('XC_ServiceAppointment_Refuse');
        if(caseMDT == null) {
            throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', 'XC_ServiceAppointment_Refuse'}));
        }
        AssignmentRule ar = new AssignmentRule();
        ar = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
        Database.DMLOptions opts = new Database.DMLOptions();
        opts.AssignmentRuleHeader.AssignmentRuleId = ar.Id;

        Case newCase = XC_UTIL_Case.initCaseFromCaseSettings(caseMDT);
        newCase.AccountId = workOrder.AccountId;
        newCase.ContactId = workOrder.ContactId;
        newCase.XC_WorkOrder__c = workOrder.Id;
        newCase.setOptions(opts);
        /*
        Case newCase = new Case(
            Reason = caseMDT.XC_Case_Reason__c,
            SubCause__c = caseMDT.XC_Sub_Cause__c,
            XC_Subtype__c = caseMDT.XC_Sub_Type__c,
            Origin = caseMDT.XC_Origin__c,
            AccountId = workOrder.AccountId,
            ContactId = workOrder.ContactId,
            XC_WorkOrder__c = workOrder.Id
        );*/

        return XC_UTIL_Sobject.insertRecord(newCase);
    }

    /**
    * @description Method to get Queue Dispatcher
    * @param legalEntity - String
    * @param segment - String
    * @return String
    */
    private static String getQueueDispatcher(String legalEntity, String segment){
        List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_BODispatcherQueue__c  
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c =: legalEntity AND XC_BODispatcherQueue__c != null AND XC_Stream__c = :segment
        ]);
        if(listCM.isEmpty()) return null;
        Map<String, String> mapQueue = XC_UTIL_WorkOrder.getMapQueueIds(new List<String>{listCM[0].XC_BODispatcherQueue__c});
        if(mapQueue.values().isEmpty() || String.isBlank(mapQueue.values()[0])) return null;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Queue for Legal Entity ' + legalEntity + ' : ' + mapQueue.values()[0]);
        return mapQueue.values()[0];
    }

    /**
    * @description Method to populate ParameterWrapper
    * @param parameterWrapper - ParameterWrapper
    * @param currentUserMap - Map<Id,User>
    * @param serviceAppId - String
    */
    private static void populateWrapper(ParameterWrapper parameterWrapper, List<User> currentUserMap, String serviceAppId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'populateWrapper: ');
        parameterWrapper.currentUser = currentUserMap[0];
        
        Map<Id,ServiceAppointment> serAppToChangeMap =  new Map<Id,ServiceAppointment>([SELECT Id, XC_LegalEntity__c, XC_WorkTypeLabel__c, XC_ZipCedeWorkType__c, XC_AssignToPartner__c, XC_AssignedResource__c, XC_AssignedResource__r.FSL__Picture_Link__c, XC_WorkTypeCategory__c, XC_StatusReason__c, Status, ParentRecordId, OwnerId, XC_Refusing_Reason__c, SchedStartTime, SchedEndTime,
                                                                                        XC_Country__c, ArrivalWindowStartTime, ArrivalWindowEndTime, PostalCode, ServiceTerritory.OperatingHoursId, XC_IgnoreReschedulingLock__c,
                                                                                        (SELECT Id, ServiceResource.IsCapacityBased, ServiceResource.XC_IsManager__c
                                                                                        FROM ServiceResources)
                                                                                        FROM ServiceAppointment
                                                                                        WHERE Id =: serviceAppId]);
        parameterWrapper.serAppToChange = serAppToChangeMap.values();

        workOrderToChangeMap = new Map<Id,WorkOrder> ([ SELECT Id, XC_Segment__c, Status, XC_WorkTypeLabel__c, XC_StatusReason__c, OwnerId, XC_Refusing_Reason__c, XC_WorkTypeCategory__c, WorkType.XC_AssignToPartner__c, AccountId, ContactId, WorkTypeId,
                                                            (SELECT Id, ServiceResourceId, PreferenceType, ServiceResource.IsCapacityBased, ServiceResource.AccountId, ServiceResource.XC_IsManager__c
                                                            FROM ResourcePreferences)
                                                        FROM WorkOrder
                                                        WHERE Id =: parameterWrapper.serAppToChange.ParentRecordId]);
        parameterWrapper.workOrderToChange = workOrderToChangeMap.values();
        //return workOrderToChangeMap;
    }

    /**
    * @description Method to assign to partner
    * @param parameterWrapper - ParameterWrapper
    * @param currentSr - ServiceResource
    */
    private static void assignToPartner(ParameterWrapper parameterWrapper, ServiceResource currentSr){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'assignToPartner: ');
        // start - ASSIGN TO PARTNER
        List<XC_UTIL_Sobject.WrapperResult> res;
        XC_UTIL_Sobject.WrapperResult result;
        
        Datetime arrivalWindowStart = parameterWrapper.serAppToChange.SchedStartTime;
        Datetime arrivalWindowEndTime = parameterWrapper.serAppToChange.SchedEndTime;
        ServiceAppointment serviceAppointment = parameterWrapper.serAppToChange;
        Id operatingHoursId = parameterWrapper.serAppToChange.ServiceTerritory.OperatingHoursId;
        if(parameterWrapper.serAppToChange.ArrivalWindowStartTime!= null && parameterWrapper.serAppToChange.ArrivalWindowEndTime != null) {
            arrivalWindowStart = parameterWrapper.serAppToChange.ArrivalWindowStartTime;
            arrivalWindowEndTime = parameterWrapper.serAppToChange.ArrivalWindowEndTime;
        }

        if(parameterWrapper.workOrderToChange.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation ||
          parameterWrapper.workOrderToChange.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit){

            parameterWrapper.serAppToChange.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician;
            parameterWrapper.workOrderToChange.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician;
        }

        /*serviceAppointment.ArrivalWindowEndTime = arrivalWindowEndTime;
        serviceAppointment.ArrivalWindowStartTime = arrivalWindowStart;
        
        result = XC_UTIL_Sobject.updateRecord(serviceAppointment);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'result sa' + result);*/
        List<ServiceResource> srPartenr = new List<ServiceResource>([
            SELECT ID 
            FROM ServiceResource 
            WHERE AccountId = :currentSr.AccountId AND XC_IsManager__c = true]);
        Id partnerId = !srPartenr.isEmpty() ? srPartenr[0].Id : null;
        if (parameterWrapper.serAppToChange.ServiceResources.isEmpty()){ 
            result = insertAssignedResouce(parameterWrapper, partnerId);
        }else {
            List<SObject> recordToUpdate = new List<SObject>();
            for(AssignedResource ar : parameterWrapper.serAppToChange.ServiceResources) {
                ar.ServiceResourceId = partnerId != null ? partnerId : ar.ServiceResourceId;
                recordToUpdate.add(ar);
            }
            res = XC_UTIL_Sobject.updateListRecords(recordToUpdate);
        }
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'res otherTech ' + res);
        // end - ASSIGN TO PARTNER
    }

    @TestVisible
    private static XC_UTIL_Sobject.WrapperResult insertAssignedResouce(ParameterWrapper parameterWrapper, String partnerId){
        AssignedResource ar = new AssignedResource();
        ar.ServiceAppointmentId = parameterWrapper.serAppToChange.id;
        ar.ServiceResourceId = partnerId;
        return XC_UTIL_Sobject.insertRecord(ar);
    }

    /*private static Boolean checkOtherTechs(Map<Id,WorkOrder> workOrderToChangeMap, ParameterWrapper parameterWrapper, ServiceResource currentSr){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkOtherTechs: ');
        // start - VERIFICA SE ESISTE UN ALTRO TECNICO DIVERSO DA CHI STA RIFIUTANDO
        List<ResourcePreference> rpList;
        Boolean otherTech = false;
        WorkOrder wo = workOrderToChangeMap.values()[0];
        rpList = wo.ResourcePreferences;
        Integer index = 0;
        while (!otherTech && index < rpList.size()) {
            ResourcePreference rp = rpList.get(index);
            otherTech = !rp.ServiceResource.IsCapacityBased && 
                        rp.ServiceResource.Id != currentSr.Id && 
                        currentSr.AccountId == rp.ServiceResource.AccountId &&
                        rp.PreferenceType != 'Excluded';
            index ++;
        }
        parameterWrapper.serAppToChange.XC_AssignToPartner__c = !otherTech;
        if(!otherTech){
            assignToPartner(parameterWrapper, currentSr, rpList);
        }
        return otherTech;
        // end - VERIFICA SE ESISTE UN ALTRO TECNICO DIVERSO DA CHI STA RIFIUTANDO
    }*/

    /**
    * @description Send To Backoffice and set dates of SA
    * @param parameterWrapper - ParameterWrapper
    * @param queueDispatcher - String
    * @param isPartner - Boolean
    * @return ResultWrapper
    */
    private static ParameterWrapper setDatesAndSendToBackOffice (ParameterWrapper parameterWrapper, String queueDispatcher, Boolean isPartner){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'setDatesAndSendToBackOffice: ');
        if(isPartner){
            if(String.isBlank(queueDispatcher)) {
                populateWrapperResult(parameterWrapper, false, Label.XC_CL_QueueNotFound + ' (' + parameterWrapper.serAppToChange.XC_LegalEntity__c + ')'); 
                return parameterWrapper;
            }
            sendToBO(parameterWrapper, queueDispatcher, isPartner);
            parameterWrapper.result.success = true;
            parameterWrapper.result.message = Label.XC_CL_OperationCompleted;
            return parameterWrapper;
        }
        if(parameterWrapper.dmlResult.success) {
            Datetime arrivalWindowStart = parameterWrapper.serAppToChange.SchedStartTime;
            Datetime arrivalWindowEndTime = parameterWrapper.serAppToChange.SchedEndTime;
            if(parameterWrapper.serAppToChange.ArrivalWindowStartTime!= null && parameterWrapper.serAppToChange.ArrivalWindowEndTime != null) {
                arrivalWindowStart = parameterWrapper.serAppToChange.ArrivalWindowStartTime;
                arrivalWindowEndTime = parameterWrapper.serAppToChange.ArrivalWindowEndTime;
            }
            XC_UTIL_AutoSchedule.AutoScheduleInputWrapper scheduleWrapper = new XC_UTIL_AutoSchedule.AutoScheduleInputWrapper();
            scheduleWrapper.serviceAppointment = parameterWrapper.serAppToChange;
            scheduleWrapper.preferredStart = arrivalWindowStart;
            scheduleWrapper.preferredEnd = arrivalWindowEndTime;
            scheduleWrapper.operatingHoursId = parameterWrapper.serAppToChange.ServiceTerritory.OperatingHoursId;
            XC_UTIL_AutoSchedule.AutoSchedulingResult resultScheduling = new XC_UTIL_AutoSchedule.AutoSchedulingResult();
            if(!Test.isRunningTest()){ 
                resultScheduling = XC_UTIL_AutoSchedule.autoScheduleAppointmentToFixedSlot(scheduleWrapper);
            }

            if(resultScheduling.success == false) {
                if(!isPartner){
                    assignToPartner(parameterWrapper, parameterWrapper.currentSr);
                    ServiceAppointment sa = new ServiceAppointment();
                    sa.Id = parameterWrapper.serAppToChange.Id;
                    WorkOrder wo = new WorkOrder();
                    wo.Id = parameterWrapper.workOrderToChange.Id;
                    wo.XC_StatusReason__c = parameterWrapper.workOrderToChange.XC_StatusReason__c;
                    sa.XC_StatusReason__c = parameterWrapper.serAppToChange.XC_StatusReason__c;
                    XC_UTIL_Sobject.updateRecord(sa);
                    XC_UTIL_Sobject.updateRecord(wo);
                }else {
                    if(String.isBlank(queueDispatcher)) { 
                        populateWrapperResult(parameterWrapper, false, Label.XC_CL_QueueNotFound + ' (' + parameterWrapper.serAppToChange.XC_LegalEntity__c + ')');
                        return parameterWrapper;
                    }
                    sendToBO(parameterWrapper, queueDispatcher, isPartner);
                    populateWrapperResult(parameterWrapper, true, Label.XC_CL_OperationCompleted); 
                    return parameterWrapper;
                }
                
            }else {
                updateWoAndSA(parameterWrapper);
            }            
            populateWrapperResult(parameterWrapper, true, Label.XC_CL_OperationCompleted); 
        } else {
            populateWrapperResult(parameterWrapper, parameterWrapper.dmlResult.success, parameterWrapper.dmlResult.errorMessage);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'dmlMessage-->' + parameterWrapper.result.message);
        return parameterWrapper;
    }

    private static void populateWrapperResult(ParameterWrapper parameterWrapper, Boolean success, String errorMessage){
        parameterWrapper.result.success = success;
        parameterWrapper.result.message = errorMessage;
    } 

    @TestVisible
    private static void updateWoAndSA(ParameterWrapper parameterWrapper){ 
        ServiceAppointment sa = new ServiceAppointment();
        sa.Id = parameterWrapper.serAppToChange.Id;
        WorkOrder wo = new WorkOrder();
        wo.Id = parameterWrapper.workOrderToChange.Id;
        wo.XC_StatusReason__c = null;
        sa.XC_StatusReason__c = Label.XC_CL_StatusReason_ReassignedTechnician;
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
        XC_UTIL_Sobject.updateRecord(wo);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);  
        XC_UTIL_Sobject.updateRecord(sa);
    }

    /**
    * @description Method to send to BO
    * @param parameterWrapper - ParameterWrapper
    * @param queueDispatcher - String
    * @param isPartner - Boolean
    */
    private static void sendToBO(ParameterWrapper parameterWrapper, String queueDispatcher, Boolean isPartner){
        String workTypeCategory = parameterWrapper.workOrderToChange.XC_WorkTypeCategory__c;
        /*Boolean conditionDICV = workTypeCategory == Label.XC_CL_WorkType_CommercialVisit || workTypeCategory == Label.XC_CL_WorkType_DeliveryInstallation;
        Boolean conditionPMRe = workTypeCategory == Label.XC_CL_WorkType_PlannedMaintenance || workTypeCategory == Label.XC_CL_WorkType_Repair;
        
        if(conditionDICV){            
            parameterWrapper.serAppToChange.XC_StatusReason__c = Label.XC_CL_StatusReason_PDSrejectsservice;
            parameterWrapper.serAppToChange.Status = Label.XC_CL_ServiceAppointment_None;
            parameterWrapper.workOrderToChange.XC_StatusReason__c = isPartner ? Label.XC_CL_WorkOrder_AssignmentError : Label.XC_CL_StatusReason_PteContact;    
        }else if(conditionPMRe){*/
            parameterWrapper.serAppToChange.XC_StatusReason__c = Label.XC_CL_StatusReason_Partnerrefusesservice;
            parameterWrapper.workOrderToChange.XC_StatusReason__c = Label.XC_CL_StatusReason_Partnerrefusesservice;
            parameterWrapper.serAppToChange.Status = Label.XC_CL_ServiceAppointment_None;
        //}        

        XC_UTIL_WorkOrder.SendToBackOfficeWrapper wrSendToBackOffice = new XC_UTIL_WorkOrder.SendToBackOfficeWrapper();
        wrSendToBackOffice.serAppToChange = parameterWrapper.serAppToChange;
        wrSendToBackOffice.workOrderToChange = parameterWrapper.workOrderToChange;
        wrSendToBackOffice.partnerIdCurrentResource = parameterWrapper.partnerIdCurrentResource;
        wrSendToBackOffice.queueId = queueDispatcher;
        wrSendToBackOffice.mapWorkType = XC_UTIL_WorkType.getMapAssignToPartnerByWorkTypeId(new List<String> {parameterWrapper.workOrderToChange.WorkTypeId});
        XC_UTIL_WorkOrder.sendToBackOffice(wrSendToBackOffice);
        createCaseForRefuse(parameterWrapper.workOrderToChange);
    }

    /**
    * @description Send To Backoffice and set dates of SA
    * @param parameterWrapper - ParameterWrapper
    * @param newRefusingReason - String
    * @return ResultWrapper
    */
    @TestVisible
    private static ParameterWrapper updateWorkOrderAndServiceAppointment(ParameterWrapper parameterWrapper, String newRefusingReason){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'updateWorkOrderAndServiceAppointment: ');
        if(!parameterWrapper.currentUser.ServiceResources.isEmpty() && parameterWrapper.currentUser.ServiceResources[0] != null) {
            parameterWrapper.partnerIdCurrentResource = parameterWrapper.currentUser.ServiceResources[0].XC_Account__c;
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@partnerIdCurrentResource-->' + parameterWrapper.partnerIdCurrentResource);
            parameterWrapper.dmlResult = setResourceToExcluded(parameterWrapper.currentUser,parameterWrapper.workOrderToChange); 
        } else {
            populateWrapperResult(parameterWrapper, false, Label.XC_CL_User_NoResource); 
        }
        System.debug(parameterWrapper.dmlResult.success);
        if(parameterWrapper.dmlResult.success) {
            parameterWrapper.dmlResult = updateWorkOrder(parameterWrapper.workOrderToChange, newRefusingReason, parameterWrapper.serAppToChange.XC_AssignToPartner__c);
            if(parameterWrapper.dmlResult.success) {
                parameterWrapper.dmlResult = updateServiceAppointment(parameterWrapper.serAppToChange, newRefusingReason, parameterWrapper.serAppToChange.XC_AssignToPartner__c);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'ParameterWrapper-->' + parameterWrapper);
        return parameterWrapper;
    }


    /**
    * @param currentUser the current user
    * @param workOrderToChange the work order to change
    * @return the x C UTI L sobject. wrapper result
    * @description Set the Resource to Excluded
    */
    public static XC_UTIL_Sobject.WrapperResult setResourceToExcluded(User currentUser, WorkOrder workOrderToChange){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ setResourceToExcluded: ');
        XC_UTIL_Sobject.WrapperResult dmlResult = new XC_UTIL_Sobject.WrapperResult();
        ServiceResource serviceResourceToExclude = currentUser.ServiceResources[0];

        List<ResourcePreference> listExistingPreferences = new List<ResourcePreference>([
            SELECT id,ServiceResourceId FROM ResourcePreference WHERE RelatedRecordId =: workOrderToChange.Id
        ]);
        Map<Id,Id> mapSrPref = new Map<Id,Id>();
        for(ResourcePreference rp : listExistingPreferences){
            mapSrPref.put(rp.ServiceResourceId, rp.Id);
        }

        if (serviceResourceToExclude != null){
            if(serviceResourceToExclude.ResourceType == 'T' && !serviceResourceToExclude.XC_isManager__c){ 
                ResourcePreference rp = createResourcePreference(serviceResourceToExclude.Id, mapSrPref, workOrderToChange.Id); 
                dmlResult = XC_UTIL_Sobject.upsertRecord(rp);
            } else { 
                List<ResourcePreference> listToUpsert = new List<ResourcePreference>(); 
                for(ServiceResource sr : [SELECT Id FROM ServiceResource WHERE AccountId =: serviceResourceToExclude.AccountId AND ResourceType = 'T' AND isActive = true]){
                    ResourcePreference rp = createResourcePreference(sr.Id, mapSrPref, workOrderToChange.Id); 
                    listToUpsert.add(rp);
                }
                dmlResult = XC_UTIL_Sobject.getGlobalDMLResults(XC_UTIL_Sobject.upsertListRecords(listToUpsert));
            }
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, '### dmlResult->' + dmlResult);
        dmlResult.success = true;
        return dmlResult;
    }

    private static ResourcePreference createResourcePreference(Id srId, Map<Id,Id> mapSrPref, Id woId){
        ResourcePreference rp = new ResourcePreference();
        if(mapSrPref.containsKey(srId)){
            rp.Id = mapSrPref.get(srId);
        } else {
            rp.RelatedRecordId = woId;
            rp.ServiceResourceId = srId;
        }
        rp.PreferenceType = 'Excluded';
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ resourcePreferenceToUpdate-->' + rp); 
        return rp;
    }

    /**
    * @param serAppToChange the ser app to change
    * @param newRefusingReason the new refusing reason
    * @return the x C UTI L sobject. wrapper result
    * @description Update Service Appointment
    */
    public static XC_UTIL_Sobject.WrapperResult updateServiceAppointment(ServiceAppointment serAppToChange, String newRefusingReason, Boolean assignToPartner){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### updateServiceAppointment: ');
        serAppToChange.XC_IgnoreReschedulingLock__c = true;
        serAppToChange.XC_Reason_of_Rejection__c = newRefusingReason; 
        serAppToChange.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician; 
        serAppToChange.ArrivalWindowStartTime = null;
        serAppToChange.ArrivalWindowEndTime = null;
        XC_UTIL_Sobject.WrapperResult dmlResult = new XC_UTIL_Sobject.WrapperResult();
        dmlResult.success = true;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### dmlResult->' + dmlResult);
        return dmlResult;
    } 

    /**
    * @param workOrderToChange the work order to change
    * @param newRefusingReason the new refusing reason
    * @return the x C UTI L sobject. wrapper result
    * @description Update Work Order
    */
    public static XC_UTIL_Sobject.WrapperResult updateWorkOrder(WorkOrder workOrderToChange, String newRefusingReason, Boolean assignToPartner){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### updateWorkOrder:');
        workOrderToChange.XC_Refusing_Reason__c = newRefusingReason; 
        workOrderToChange.XC_IgnoreReschedulingLock__c = true; 
        workOrderToChange.XC_StatusReason__c = Label.XC_CL_StatusReason_Pendingassigntechnician; 
        XC_UTIL_Sobject.WrapperResult dmlResult = new XC_UTIL_Sobject.WrapperResult();
        dmlResult.success = true;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### dmlResult->' + dmlResult);
        return dmlResult;
    }  
}