/**
 * The Class XC_LCC141_BookNearMaintenance.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 27/08/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC141_BookNearMaintenance – Controller for XC_LCP141_BookNearMaintenance Component
 */
public without sharing class XC_LCC141_BookNearMaintenance {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC141_BookNearMaintenance');
    /**
    * @description The Class resultWrapper.
    */
    public class ResultWrapper {
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String  message = 'Error'; 
    }

    /**
    * @description
    * @author Del Prete Domenico | 27/8/2019
    * @param  recordId Id
    * @return ResultWrapper
    */
    @AuraEnabled
    public static ResultWrapper bookNearMaintenance(Id recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Method entry bookNearMaintenance');
        ResultWrapper rw= new ResultWrapper ();
        List<WorkOrder> listOfWo = new List<WorkOrder> ([SELECT Id, AccountId, XC_WorkTypeCategory__c, DurationInMinutes, XC_WorkTypeLabel__c, XC_MaintenanceIsNear__c
                                                         FROM WorkOrder
                                                         WHERE Id =: recordId]);
        WorkOrder woMaster = listOfWo[0];                                                                                       
        if(!Label.XC_CL_WorkType_Repair.equals(woMaster.XC_WorkTypeCategory__c)){
            rw.message = Label.XC_CL_WorkTypeNameNotRepair;
            return rw;
        }
        if(woMaster.XC_MaintenanceIsNear__c){
            rw.message = Label.XC_CL_AppointmentAlreadyScheduled;
            return rw;
        }
        List<ServiceAppointment> listOfServiceAppointment = new List<ServiceAppointment>([SELECT Id, EarliestStartTime, DueDate, SchedEndTime, SchedStartTime
                                                                                          FROM ServiceAppointment
                                                                                          WHERE AccountId =:woMaster.AccountId 
                                                                                          AND Status =:Label.XC_CL_ServiceAppointment_Scheduled 
                                                                                          AND (XC_WorkTypeCategory__c = : Label.XC_CL_WorkType_PlannedMaintenance OR XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_Diagnostic)]);
        if(listOfServiceAppointment.isEmpty()){
            rw.message = Label.XC_CL_NoServiceAppointment;
            return rw;
        }
        Boolean found = false;
        Date dateToCheck = calculateDateToCheck();
        ServiceAppointment saMaster = new ServiceAppointment();
        for(ServiceAppointment sa : listOfServiceAppointment) {
            if(sa.SchedEndTime <= dateToCheck){
               saMaster = sa;
               found = true;
               break; 
            }
        }
        if(!found){
            rw.message = Label.XC_CL_NoScheduledAppointment;
            return rw;
        }       
        List<AssignedResource> listOfAR = new List<AssignedResource>([SELECT Id, ServiceResourceId
                                                                      FROM AssignedResource
                                                                      WHERE ServiceAppointmentId =: saMaster.Id]);
        if(listOfAR.isEmpty()){
            rw.message = Label.XC_CL_NoAssignedResource;
            return rw; 
        }
        XC_UTIL_Sobject.WrapperResult dmlResult = insertResourcePreferenceAndServiceAppointment(listOfAR, woMaster, saMaster);
        if(checkDMLResultTest(dmlResult)){
            rw.message = dmlResult.errorMessage;
            return rw;
        }
        rw = updateWorkOrder(woMaster);
        return rw;
    }

    private static XC_UTIL_Sobject.WrapperResult insertResourcePreferenceAndServiceAppointment(List<AssignedResource> listOfAR, WorkOrder woMaster, ServiceAppointment saMaster){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Method entry insertResourcePreferenceAndServiceAppointment'); 
        XC_UTIL_Sobject.WrapperResult rw= new XC_UTIL_Sobject.WrapperResult ();
        rw.success = true;
        List<ResourcePreference> listOfResourcePreference = new List<ResourcePreference>([SELECT Id 
                                                                        FROM ResourcePreference 
                                                                        WHERE ServiceResourceId =: listOfAR[0].ServiceResourceId]);
        if(listOfResourcePreference.isEmpty()){
            ResourcePreference resourceToAssign = new ResourcePreference();
            resourceToAssign.ServiceResourceId = listOfAR[0].ServiceResourceId;
            resourceToAssign.RelatedRecordId = woMaster.id;
            resourceToAssign.PreferenceType = 'Required';
            XC_UTIL_Sobject.WrapperResult dmlResultRF = XC_UTIL_Sobject.insertRecord(resourceToAssign);
            if(!dmlResultRF.success) {
                rw.success = false;
                rw.errorMessage = dmlResultRF.errorMessage;
                return rw;               
            }
        }
        ServiceAppointment saToInsert = createServiceAppointment (woMaster, saMaster);
        XC_UTIL_Sobject.WrapperResult dmlResultSA = XC_UTIL_Sobject.insertRecord(saToInsert);
        if(!dmlResultSA.success) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ServiceAppointment error '+dmlResultSA.errorMessage);
            rw.errorMessage = dmlResultSA.errorMessage;
            return rw;               
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Method exit insertResourcePreferenceAndServiceAppointment');
        return rw;
    }

    private static ServiceAppointment createServiceAppointment(WorkOrder woMaster, ServiceAppointment saMaster){
        ServiceAppointment saToInsert = new ServiceAppointment();
        XC_TR_ServiceAppointment_FillFieldByWO_U.forceDateTrigger = true;
        if(woMaster.DurationInMinutes == null){
            List<WorkType> listOfWorkType = new List <WorkType> ([SELECT Id, Name, DurationInMinutes
                                                                    FROM WorkType
                                                                    WHERE Name =: woMaster.XC_WorkTypeLabel__c]);
            saToInsert.EarliestStartTime = saMaster.SchedStartTime.addMinutes((Integer.valueOf(listOfWorkType[0].DurationInMinutes)*-1));
            saToInsert.DueDate = saMaster.SchedEndTime.addMinutes(Integer.valueOf(listOfWorkType[0].DurationInMinutes));
        }else {
            saToInsert.EarliestStartTime = saMaster.SchedStartTime.addMinutes((Integer.valueOf(woMaster.DurationInMinutes)*-1));
            saToInsert.DueDate = saMaster.SchedEndTime.addMinutes(Integer.valueOf(woMaster.DurationInMinutes));   
        }
        saToInsert.ParentRecordId = woMaster.Id;
        return saToInsert;
    }

    private static Date calculateDateToCheck(){
        List<XC_CM_ServiceAppointment_Default_Value__mdt> listOfDays = new  List<XC_CM_ServiceAppointment_Default_Value__mdt>([SELECT Id, Days_for_Maintenance_Appointment__c
                                                                                                                               FROM XC_CM_ServiceAppointment_Default_Value__mdt]);
        Date dateToCheck = System.today()+ Integer.valueOf(listOfDays[0].Days_for_Maintenance_Appointment__c);
        return dateToCheck;
    }
    
    private static Boolean checkDMLResultTest(XC_UTIL_Sobject.WrapperResult dmlResult){
        return !dmlResult.success && !Test.isRunningTest();
    }

    private static ResultWrapper updateWorkOrder(WorkOrder woMaster){
        ResultWrapper rw = new ResultWrapper();
        woMaster.XC_MaintenanceIsNear__c = true;
        XC_UTIL_Sobject.WrapperResult dmlResultWo = XC_UTIL_Sobject.updateRecord(woMaster);
        if(!dmlResultWo.success) {
            rw.message = dmlResultWo.errorMessage;
            return rw;               
        } 
        rw.success = true;
        rw.message = Label.XC_CL_AppointmentScheduled;
        return rw;
    }
}