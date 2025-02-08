/**
 * The Class XC_LCC156_NotPerformNearMaintenance.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 20/09/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC156_NotPerformNearMaintenance – Controller for XC_LCP156_NotPerformRepairNearMaintenance Component
 */
public without sharing class XC_LCC156_NotPerformNearMaintenance {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC156_NotPerformNearMaintenance');
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
    * @author Del Prete Domenico | 25/9/2019 
    * @param recordId - Id
    * @return ResultWrapper 
    **/
    @AuraEnabled
    public static ResultWrapper notPerformNearMaintenance (Id recordId){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ METHOD ENTRY XC_LCC156_NotPerformNearMaintenance.notPerformNearMaintenance');
        ResultWrapper rw= new ResultWrapper ();

        List<WorkOrder> listOfWo = new List<WorkOrder> ([SELECT Id, AccountId, XC_WorkTypeCategory__c, DurationInMinutes, XC_MaintenanceIsNear__c, XC_Country__c, 
                                                                XC_Urgent_Repair__c, XC_Commitment__c, XC_HierarchyLevel__c, XC_isTree__c, AssetId
                                                         FROM WorkOrder
                                                         WHERE Id =: recordId]);
        WorkOrder woMaster = listOfWo[0];
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ WoMaster: '+woMaster);
        if(!woMaster.XC_MaintenanceIsNear__c){
            rw.message = Label.XC_CL_NoAppointmentScheduled;
            return rw;
        }
        List<ServiceAppointment> listOfSa = new List<ServiceAppointment>([SELECT Id, EarliestStartTime, DueDate, SchedEndTime, SchedStartTime, XC_Country__c
                                                                                          FROM ServiceAppointment
                                                                                          WHERE ParentRecordId =: woMaster.Id 
                                                                                          AND Status =: Label.XC_CL_ServiceAppointment_None]);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listOfServiceAppointment: '+listOfSa);
        if(!Label.XC_CL_Repair.equals(woMaster.XC_WorkTypeCategory__c)){
            rw.message = Label.XC_CL_WorkTypeNameNotRepair;
            return rw;
        }
        if(listOfSa.isEmpty()){
            rw.message = Label.XC_CL_NoServiceAppointment;
            return rw;
        }
        woMaster.XC_MaintenanceIsNear__c = false;
        XC_UTIL_Sobject.WrapperResult dmlResultWo = XC_UTIL_Sobject.updateRecord(woMaster);
        if(!dmlResultWo.success) {
            return populateWrapperError(new List<XC_UTIL_Sobject.WrapperResult> {dmlResultWo}, rw);
        }
        XC_UTIL_Sobject.WrapperResult dmlResultSa = XC_UTIL_Sobject.deleteRecord(listOfSa[0]);
        if(!dmlResultSa.success) {
            return populateWrapperError(new List<XC_UTIL_Sobject.WrapperResult> {dmlResultSa}, rw);               
        }
        rw = getResourcePreferences(listOfWo, rw);
        if (!rw.message.equals('Error')){
            return rw;
        }
        rw.success = true;
        rw.message = Label.XC_CL_OperationCompleted;
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ METHOD EXIT XC_LCC156_NotPerformNearMaintenance.notPerformNearMaintenance');
        return rw;
    }

    private static ResultWrapper getResourcePreferences(List<WorkOrder> listOfWo, ResultWrapper rw){
        List<XC_UTIL_Sobject.WrapperResult> listDmlResult = XC_UTIL_ResourcePreference.removeRequiredResourcePreferences(listOfWo);
        if(!XC_UTIL_Sobject.checkDMLResults(listDmlResult)){            
            return populateWrapperError(listDmlResult, rw);
        }
        listDmlResult = XC_TR_WorkOrder_U_RequiredResMgmt.manageRequiredResourcesOnInsert(listOfWo);
        if(!XC_UTIL_Sobject.checkDMLResults(listDmlResult)){
            return populateWrapperError(listDmlResult, rw);   
        }
        return new ResultWrapper();
    }

        /**
    * @description 
    * @author Del Prete Domenico | 12/3/2020 
    * @param dmlResults 
    * @param rw 
    * @return XC_LCC139_DocumentVerification.ResultWrapper 
    **/
    public static ResultWrapper populateWrapperError(List<XC_UTIL_Sobject.WrapperResult> dmlResults, ResultWrapper rw){
        rw.message = dmlResults[0].errorMessage;
        return rw;        
    }
}