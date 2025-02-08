/**
* @author FSL Team: Marco Rosa - marco.rosa@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com 
* @date Creation 16/03/2021
* @description XC_SC044_AutoscheduleUsingAPI – Schedulable class to use FSL API call to autoschedule Service Appointments
*/

public without sharing class XC_SC044_AutoscheduleUsingAPI implements Schedulable, Database.Batchable<sObject> {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC044_AutoscheduleUsingAPI');

    /**
     * @date Creation 16/03/2021
     * @description Method to schedule class
     * @param sc - SchedulableContext
     */
    public void execute(SchedulableContext sc) { 
        Database.executeBatch(new XC_SC044_AutoscheduleUsingAPI(), 1); 
    } 
    
    /**
     * @date Creation 16/03/2021
     * @description Method to start batch
     * @param bc - Database.BatchableContext
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Integer totalSize = 20; 
        List<XC_CM_Scheduling_Default_Value__mdt> listCM = [
            SELECT XC_SizeAutoScheduleWithAPI__c 
            FROM XC_CM_Scheduling_Default_Value__mdt 
            WHERE XC_SizeAutoScheduleWithAPI__c != null 
            LIMIT 1
        ];
        if(!listCM.isEmpty()){
            totalSize = Integer.valueOf(listCM[0].XC_SizeAutoScheduleWithAPI__c);
        }
        
        String queryB2B = 'SELECT Id FROM ServiceAppointment';
        queryB2B += ' WHERE XC_ProcessedWithCustomAutoschedule__c = false AND XC_ProcessedWithStandardAutoschedule__c = true AND Status =\'None\'';
        queryB2B += ' AND (XC_Segment__c = \'B2B\' OR XC_Segment__c = \'B2G\')';
        queryB2B += ' LIMIT ' + totalSize;
        
        List<ServiceAppointment> listSAB2B = Database.query(queryB2B);
        Integer sizeB2B = listSAB2B.size();
        Integer sizeB2C = totalSize - sizeB2B;
        
        List<String> listIds = XC_UTIL_Sobject.getIds(listSAB2B);
        if(sizeB2C > 0){
            String queryB2C = 'SELECT Id FROM ServiceAppointment';
            queryB2C += ' WHERE XC_ProcessedWithCustomAutoschedule__c = false AND XC_ProcessedWithStandardAutoschedule__c = true AND Status =\'None\'';
            queryB2C += ' AND XC_Segment__c = \'B2C\' AND XC_WorkTypeCategory__c = \'Planned Maintenance\'';
            queryB2C += ' LIMIT ' + sizeB2C;
            List<ServiceAppointment> listSAB2C = Database.query(queryB2C);
            listIds.addAll(XC_UTIL_Sobject.getIds(listSAB2C));
        }
        String query = 'SELECT Id, XC_AssignToPartner__c , XC_WorkTypeCategory__c, XC_RequiredPartnerId__c, Status, DueDate, XC_Segment__c, XC_LegalEntity__c, XC_ZipCedeWorkType__c, ParentRecordId, ArrivalWindowEndTime, ArrivalWindowStartTime, XC_Country__c FROM ServiceAppointment WHERE Id IN :listIds';
        
        List<ServiceAppointment> listToUpdate = [SELECT Id FROM ServiceAppointment WHERE Id IN :listIds];
        for(ServiceAppointment sa : listToUpdate){ 
            sa.XC_ProcessedWithCustomAutoschedule__c = true;
        }
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(listToUpdate);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
        
        return Database.getQueryLocator(query); 
    }
    
    /**
     * @date Creation 16/03/2021
     * @description Method to execute batch
     * @param bc - Database.BatchableContext
     * @param scope - List<ServiceAppointment>
     */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        ServiceAppointment sa = scope[0];
        Boolean dataOk = checkData(sa);
        if(dataOk) {
            XC_UTIL_AutoSchedule.AutoSchedulingResult resWr = new XC_UTIL_AutoSchedule.AutoSchedulingResult();
            if(!Test.isRunningTest()){
                resWr = XC_UTIL_AutoSchedule.autoScheduleAppointment(sa);
            } else {
                resWr.success = false;
                resWr.message = 'testClass';
                generateError('testClass', sa);
            }
            if(!resWr.success) {
                sa.XC_ErrorMessageAutoscheduling__c = resWr.message;
            }
        }

        sa.XC_ProcessedWithCustomAutoschedule__c = true;
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateRecord(sa);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
    }
    
    /**
     * @date Creation 16/03/2021
     * @description Method to finish batch
     * @param bc - Database.BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Finish batch XC_SC044_AutoscheduleUsingAPI');
    }

    /**
     * @date Creation 16/03/2021
     * @description Method to check errors to schedule Appointment
     * @param sa - ServiceAppointment
     * @return Boolean
     */
    public Boolean checkData(ServiceAppointment sa) {
        List<WorkOrder> listWo = new List<WorkOrder>([
            SELECT Id, Status, XC_RequiredPartnerId__c, XC_PreviousMaintenanceWorkOrder__c, XC_ApplyCoverageFilterInBooking__c, XC_FSLAssignmentKey__c, WorkTypeId, WorkType.XC_AssignToPartner__c, XC_Segment__c, XC_LegalEntity__c, WorkType.XC_Segment__c, WorkType.XC_LegalEntity__c,   
                (SELECT Id, ServiceResourceId, ServiceResource.XC_Account__c   
                FROM ResourcePreferences
                WHERE PreferenceType = 'Required'
                AND ServiceResource.XC_IsManager__c = true 
                AND ServiceResource.IsActive = true),
                (SELECT Id, SkillId   
                FROM SkillRequirements)
            FROM WorkOrder
            WHERE Id = :sa.ParentRecordId
        ]);
        WorkOrder wo = listWo[0];
        Set<Id> requiredSkillSet = new Set<Id>();
        for(SkillRequirement skillReq : wo.SkillRequirements){
            requiredSkillSet.add(skillReq.SkillId);
        }
        Boolean success = false;
        String errorMessage = '';
        //------------------------------------------------------------------------------ For all country
        // - Check Segment and Legal Entity for WO, SA, WT:
        String errorMessageSegmentLE = checkSegmentLE(sa, wo);
        if(String.isNotBlank(errorMessageSegmentLE)) return generateError(errorMessageSegmentLE, sa);

        // - Check Due Date in the past:
        success = checkDueDate(sa);
        if(!success) return generateError('Due Date in the past', sa);

        // - Check missing Zip Code Work Type
        String errorMessageZipCodeWorkType = checkZipCodeWorkType(sa, wo);
        if(String.isNotBlank(errorMessageZipCodeWorkType)) return generateError(errorMessageZipCodeWorkType, sa);
        

        //------------------------------------------------------------------------------ Only for Spain
        if((sa.XC_LegalEntity__c == Label.XC_CL_EndesaX || sa.XC_LegalEntity__c == Label.XC_CL_LegalEntity_EnelXMobilitySpain) && sa.XC_Segment__c == 'B2C') {

            // - Check wrong AssignToPartner
            success = checkAssignToPartner(sa, wo);
            if(!success) return generateError('Error for flag AssignToPartner', sa);

            // - Check wrong status (ServiceAppointment is None and WorkOrder in New?)
            success = checkStatus(sa, wo);
            if(!success) return generateError('Wrong Status', sa);
        
            // - Check missing required partner for maintenance
            String errorMessageReqRes = checkRequiredResources(wo);
            if(!String.isBlank(errorMessageReqRes)) return generateError(errorMessageReqRes, sa);

            // - If ApplyFilterInBooking is true: check Partner Coverage
            Set<String> setPartnerId = checkPartnerCoverage(wo);
            if(setPartnerId.isEmpty()) return generateError('No Partner Coverage', sa);

            // - Check missing Manager: if Account of preference has a resource T (CapacityBased and IsManager = true)
            Set<ServiceResource> setServiceResource = checkManager(setPartnerId, requiredSkillSet);
            if(setServiceResource.isEmpty()) return generateError('No Manager configured', sa);
            
            // - Check Manager Permissions: check if manager has permissions
            setServiceResource = checkManagerPermissions(setServiceResource);
            if(setServiceResource.isEmpty()) return generateError('Missing permissions on Manager', sa);

            // - Check service resource skill
            Set<String> setSrIds = checkSkill(setServiceResource, wo);
            if(setSrIds.isEmpty()) return generateError('Missing Skill', sa);

            // - Check operating hours
            Set<String> setServiceResourceId = checkOperatingHours(setSrIds);
            if(setServiceResourceId.isEmpty()) return generateError('Error for Operating Hours configuration', sa);

            // - Check Service Resource Coverage
            Set<String> setServiceResourceIdWithCoverage = checkServiceResourceCoverage(setServiceResourceId, wo);
            if(setServiceResourceIdWithCoverage.isEmpty()) return generateError('Missing Service Resource Coverage', sa);
        } 
        return success;
    }


    // ------------------------------------------------------------------------------------------------ Check method
    
    private static String checkSegmentLE(ServiceAppointment sa, WorkOrder wo) {
        if(sa.XC_LegalEntity__c != wo.XC_LegalEntity__c)             return 'Legal Entity is different between Service Appointment and Work Order';
        if(wo.XC_LegalEntity__c != wo.WorkType.XC_LegalEntity__c)    return 'Legal Entity is different between Work Order and Work Type';
        if(sa.XC_Segment__c != wo.XC_Segment__c)                     return 'Segment is different between Service Appointment and Work Order';
        if(wo.XC_Segment__c != wo.WorkType.XC_Segment__c)            return 'Segment is different between Work Order and Work Type';
        return '';
    }

    private static Boolean checkDueDate(ServiceAppointment sa) { 
        return (sa.DueDate >= System.now());
    }

    private static String checkZipCodeWorkType(ServiceAppointment sa, WorkOrder wo) {
        if(String.isBlank(sa.XC_ZipCedeWorkType__c)) return 'Missing ZipCodeWorkType on ServiceAppointment';
        List<XC_ZipCodeWorkType__c> listZipCodeWorkType = new List<XC_ZipCodeWorkType__c>([
            SELECT Id, XC_ZipCode__c, XC_WorkType__c
            FROM XC_ZipCodeWorkType__c
            WHERE Id = :sa.XC_ZipCedeWorkType__c
        ]);
        if(wo.XC_FSLAssignmentKey__c != listZipCodeWorkType[0].XC_ZipCode__c ||
            wo.WorkTypeId != listZipCodeWorkType[0].XC_WorkType__c) return 'ZipCodeWorkType is not correct';
        return '';
    }

    private static Boolean checkAssignToPartner(ServiceAppointment sa, WorkOrder wo) {
        return (sa.XC_AssignToPartner__c == wo.WorkType.XC_AssignToPartner__c);
    }

    private static Boolean checkStatus(ServiceAppointment sa, WorkOrder wo) {
        return (sa.Status == Label.XC_CL_ServiceAppointment_None && wo.Status == Label.XC_CL_WorkOrder_New);
    }
 
    private static String checkRequiredResources(WorkOrder wo) {
        Boolean reqPartnerExists = !String.isBlank(wo.XC_RequiredPartnerId__c); 
        if(wo.XC_PreviousMaintenanceWorkOrder__c != null && !reqPartnerExists){
            return 'Missing Required Partner on WO for next Maintenance';
        }
        Boolean preferenceExists = !wo.ResourcePreferences.isEmpty();
        if(preferenceExists && !reqPartnerExists){
            return 'Missing Required Partner on WO (there is a Manager Resource Preference)';
        } else if(reqPartnerExists && !preferenceExists){
            return 'Missing Manager Resource Preferences on WO (there is XC_RequiredPartnerId__c on WO)';
        } else if(preferenceExists && reqPartnerExists && wo.ResourcePreferences[0].ServiceResource.XC_Account__c != wo.XC_RequiredPartnerId__c){
            return 'Different partner between RequiredPartner on WO and Resource Preferences';
        } 
        return '';
    }

    private static Set<String> checkPartnerCoverage(WorkOrder wo) {
        Set<String> setAccountIds = new Set<String>();
        if(!wo.XC_ApplyCoverageFilterInBooking__c) {
            if(String.isNotBlank(wo.XC_RequiredPartnerId__c)) return new Set<String>{wo.XC_RequiredPartnerId__c}; 
        }

        String keyExternalIdWithAccount = '';
        String key = wo.XC_FSLAssignmentKey__c + '_' + wo.WorkTypeId;
        if(!wo.ResourcePreferences.isEmpty()){
            keyExternalIdWithAccount = wo.ResourcePreferences[0].ServiceResource.XC_Account__c + '_' + key;
        } 

        List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>();
        if(String.isNotBlank(keyExternalIdWithAccount)) {
            for(XC_PartnerCoverage__c pc : [SELECT Id, XC_Account__c FROM XC_PartnerCoverage__c WHERE XC_ExternalIdForDuplication__c = :keyExternalIdWithAccount]){
                setAccountIds.add(pc.XC_Account__c);
            }  
        } else {
            for(XC_PartnerCoverage__c pc : [SELECT Id, XC_Account__c FROM XC_PartnerCoverage__c WHERE XC_ExternalId__c = :key]){
                setAccountIds.add(pc.XC_Account__c);
            } 
        }  
        return setAccountIds;
    }

    private static Set<ServiceResource> checkManager(Set<String> setAccountIds, Set<Id> requiredSkillSet) {
        return new Set<ServiceResource>([
            SELECT Id, RelatedRecordId,
                (SELECT SkillId
                FROM ServiceResourceSkills
                WHERE SkillId IN:requiredSkillSet)
            FROM ServiceResource
            WHERE XC_Account__c IN: setAccountIds 
            AND isActive = true
            AND XC_IsManager__c = true
            AND isCapacityBased = true
            AND (XC_LegalEntity__c = 'EndesaX' OR XC_LegalEntity__c = 'EnelXMobilitySpain')
            AND ResourceType = 'T'
        ]);
    }
    
    private static Set<ServiceResource> checkManagerPermissions(Set<ServiceResource> setServiceResource) {
        Set<String> userIds = new Set<String>();
        for(Serviceresource sr : setServiceResource){
            userIds.add(sr.RelatedRecordId);
        } 
        Map<Id, User> mapUsers = new Map<Id, User>([
            SELECT Id,
                (
                    SELECT Id 
                    FROM PermissionSetAssignments
                    WHERE PermissionSet.Name IN ('FSL_Resource_Permissions','FSL_Resource_License')
                )
            FROM User
            WHERE Id IN:userIds 
        ]);
        Set<ServiceResource> setServiceResourceOutput = new Set<ServiceResource>();
        for(ServiceResource sr : setServiceResource){
            if(mapUsers.containsKey(sr.RelatedRecordId)){
                List<PermissionSetAssignment> listPSA =  mapUsers.get(sr.RelatedRecordId).PermissionSetAssignments;
                if(!listPSA.isEmpty()) setServiceResourceOutput.add(sr);
            }
        }
        return setServiceResourceOutput;
    }

    private static Set<String> checkSkill(Set<ServiceResource> setServiceResource, WorkOrder wo) {
        Set<String> setSrIds = new Set<String>();
        for(ServiceResource sr : setServiceResource){
            setSrIds.add(sr.Id);
        }
        if(wo.SkillRequirements.isEmpty()) return setSrIds;

        Map<String, List<String>> mapResourceSkills = new Map<String, List<String>>();
        for(ServiceResource sr : setServiceResource) {
            mapResourceSkills.put(sr.Id, new List<String>());
            for(ServiceResourceSkill srs : sr.ServiceResourceSkills) {
                mapResourceSkills.get(sr.Id).add(srs.SkillId);
            }
        }
        List<String> listServiceResourceExcluded = new List<String>();
        for(String srId : mapResourceSkills.keySet()) {
            for(SkillRequirement skillReq : wo.SkillRequirements) {
                if(!mapResourceSkills.get(srId).contains(skillReq.SkillId)) {
                    listServiceResourceExcluded.add(srId);
                    break;
                }
            }
        }

        if(listServiceResourceExcluded.isEmpty()) return setSrIds;
        Set<String> setOutput = new Set<String>();
        for(String keyInput : setSrIds) {
            if(!listServiceResourceExcluded.contains(keyInput)) {
                setOutput.add(keyInput);
            }
        }
        return setOutput;
    }

    private static Set<String> checkOperatingHours(Set<String> setInputSRId) {
        Map<Id, Id> mapSrOp = new Map<Id, Id>();
        for(ServiceTerritoryMember stm : [SELECT Id,ServiceResourceId , OperatingHoursId, ServiceTerritory.OperatingHoursId FROM ServiceTerritoryMember WHERE ServiceResourceId IN:setInputSRId]){
            if(stm.OperatingHoursId != null){
                mapSrOp.put(stm.ServiceResourceId, stm.OperatingHoursId);
            } else if(stm.ServiceTerritory.OperatingHoursId != null){
                mapSrOp.put(stm.ServiceResourceId, stm.ServiceTerritory.OperatingHoursId);
            }
        }
        Map<Id, OperatingHours> mapOp = new Map<Id, OperatingHours>([
            SELECT Id,
                (SELECT Id, FSL__Designated_Work_Boolean_Fields__c 
                FROM TimeSlots)
            FROM OperatingHours 
            WHERE Id IN: mapSrOp.values()
        ]);
        Set<String> setSRId = new Set<String>();
        for(Id srId : mapSrOp.keySet()) {
            Id opId = mapSrOp.get(srId);
            if(mapOp.containsKey(opId)) {
                for(TimeSlot ts : mapOp.get(opId).TimeSlots) {
                    if(ts.FSL__Designated_Work_Boolean_Fields__c == null || ts.FSL__Designated_Work_Boolean_Fields__c.containsIgnoreCase('XC_IsPlannedMaintenance__c')){
                        setSRId.add(srId);
                        break;
                    }
                }
            }
        }   
        return setSRId;
    }

    private static Set<String> checkServiceResourceCoverage(Set<String> setServiceResource, WorkOrder wo) {
        List<String> listKeys = new List<String>();
        for(String srId : setServiceResource) {
            listKeys.add(srId+'_'+wo.XC_FSLAssignmentKey__c+'_'+wo.WorkTypeId);
        } 
        Set<String> setServiceResourceIds = new Set<String>();
        for(XC_ServiceResourceCoverage__c src : [SELECT Id, XC_ServiceResourceId__c FROM XC_ServiceResourceCoverage__c WHERE XC_ExternalIdForDuplication__c IN :listKeys]) {
            setServiceResourceIds.add(src.XC_ServiceResourceId__c);
        }
        return setServiceResourceIds;
    }

    // ---------------------------------------------------------------------------------------------------------------------

    private static Boolean generateError(String errorMessage, ServiceAppointment sa) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error: ' + errorMessage);
        sa.XC_ErrorMessageAutoscheduling__c = errorMessage;
        return false;
    }

}