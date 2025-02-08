/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 12/02/2019
* @date Modification 07/11/2019 Dario Tramontin dtramontin@deloitte.it
* @date Modification 22/11/2019 Salvatotore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_ServiceApp_U_CaringManagement – Manage Case creation depending on Service Appointment update
*/

public without sharing class XC_TR_ServiceApp_U_CaringManagement {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceApp_U_CaringManagement');

    /** @description UtilWrapper */
    private class UtilWrapper {
        ServiceAppointment sa = new ServiceAppointment();
        Map<Id,WorkOrder> caseIdWOMap = new Map<Id,WorkOrder>();
        WorkOrder wo = new WorkOrder();
        Case newCase = new Case();
    }

    /** @description CaseCreationWrapper */
    private class CaseCreationWrapper {
        List<ServiceAppointment> listNewSA;
        Map<Id,WorkOrder> caseIdWOMap;
        Map<Id,ServiceAppointment> mapOld;
        XC_CM_Case_Type_Setting__mdt caseMDT;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com & Monica Cutillo - mcutillo@deloitte.com
     * @date 22/11/2019
     * @description Method to manage Case for Service Appointment Update
     * @param listNew - List<ServiceAppointment>
     * @param mapOld - Map<Id,ServiceAppointment>
     * @param mapNew - Map<Id,ServiceAppointment>
     */
    public static void manageCase(List<ServiceAppointment> listNew, Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Manage Case for Service Appointment');
        List<ServiceAppointment> listSchedTimeChanged = XC_UTIL_SObject.getListChanged(new List<String>{'SchedStartTime', 'SchedEndTime'}, mapOld, mapNew);
        List<ServiceAppointment> listStatusChanged = XC_UTIL_SObject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        if(listSchedTimeChanged.isEmpty() && listStatusChanged.isEmpty()) {
           return;
        }

        List<ServiceAppointment> listNewSchedTime = new List<ServiceAppointment>();
        List<ServiceAppointment> listNewStatus = new List<ServiceAppointment>();
        for(ServiceAppointment sa : listSchedTimeChanged) {
            if(sa.Status != Label.XC_CL_ServiceAppointment_Canceled) {
                populateList(sa, mapOld, listNewSchedTime);
            }
        }
        for(ServiceAppointment sa : listStatusChanged) {
            if(sa.Status == Label.XC_CL_ServiceAppointment_Canceled) {
                populateList(sa, mapOld, listNewStatus);
            }
        }
        if(listNewSchedTime.isEmpty() && listNewStatus.isEmpty()){
            return;
        }

        Map<String, XC_CM_Case_Type_Setting__mdt> mapCaseSetting = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_CMD_ChangeAppointment,
                                                                                                                         Label.XC_CL_AppointmentCancellation});
        Map<Id,WorkOrder> caseIdWOMap = XC_UTIL_ServiceAppointment.retriveWOAccountContactInfo(listNew);
        CaseCreationWrapper inputWR = new CaseCreationWrapper();
        inputWR.caseIdWOMap = caseIdWOMap;
        inputWR.mapOld = mapOld;
        if(!listNewSchedTime.isEmpty()) {
            inputWR.listNewSA = listNewSchedTime;
            inputWR.caseMDT = mapCaseSetting.get(Label.XC_CL_CMD_ChangeAppointment);
            //GDB - PERFORMANCE IMPROVEMENT - JUNE 2022 - START
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                System.enqueueJob(new manageCaseCreationAsync(inputWR, false));
            }else{
                manageCaseCreation(inputWR);
            }      
        }
        if(!listNewStatus.isEmpty()) {
            inputWR.listNewSA = listNewStatus;
            inputWR.caseMDT = mapCaseSetting.get(Label.XC_CL_AppointmentCancellation);
            //GDB - PERFORMANCE IMPROVEMENT - JUNE 2022 - START
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                System.enqueueJob(new manageCaseCreationAsync(inputWR, true));
            }else{
                manageStatusCaseCreation(inputWR);
            }              
        }
    }

    /**
     * @description Manage Case creation
     * @date Modification 22/11/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @param inputWR - CaseCreationWrapper
     */
    private static void manageCaseCreation(CaseCreationWrapper inputWR){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_ServiceApp_U_CaringManagement - manageCaseCreation');
        List<Case> casesToInsert = new List<Case>();
        Case newCase;
        for(ServiceAppointment sa : inputWR.listNewSA) {
            if(checkCond1(sa)) {
                continue;
            }
            try {
                if(inputWR.caseMDT == null) {
                    throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_CMD_ChangeAppointment}));
                }
                newCase = XC_UTIL_Case.initCaseFromCaseSettings(inputWR.caseMDT);
                //newCase.Origin = populateInstallationOrigin(sa);
                newCase.Status = populateCaseStatus(sa, inputWR.caseMDT);   
                newCase.XC_Result__c = inputWR.caseMDT.XC_Result__c;
                newCase.XC_Resolution__c= inputWR.caseMDT.XC_Resolution__c;
                newCase.OwnerId = sa.OwnerId;
                newCase.XC_IsCloned__c = true;
                ServiceAppointment servOld = inputWR.mapOld.get(sa.Id);
                String remarksContent = populateRemarks(sa, servOld, inputWR.caseMDT);
                if(!String.isEmpty(remarksContent)) {
                    newCase.CaseRemarks__c = remarksContent;
                }
                UtilWrapper wrapper = new UtilWrapper();
                wrapper.sa = sa;
                wrapper.caseIdWOMap = inputWR.caseIdWOMap;
                wrapper.wo = new WorkOrder();
                wrapper.newCase = newCase;
                checkWO(wrapper);
                casesToInsert.add(newCase);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_ServiceApp_U_CaringManagement manageCaseCreation - New cases To Insert='+casesToInsert);
            }  catch(XC_Exception e) {
                XC_UTIL_ExceptionLog.insertExceptionLog(e);
            }

        }
        List<XC_UTIL_Sobject.WrapperResult> listRes = new List<XC_UTIL_Sobject.WrapperResult>();
        if(!Test.isRunningTest()) {listRes = XC_UTIL_Sobject.insertListRecords(casesToInsert);}
        if(!XC_UTIL_Sobject.checkDMLResults(listRes)) {
            inputWR.listNewSA[0].addError(listRes[0].errorMessage);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_ServiceApp_U_CaringManagement manageCaseCreation - Add a new Case To Insert='+casesToInsert);
    }

    /**
     * @description Manage Status of SA to create a Case
     * @date Modification 22/11/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @param inputWR - CaseCreationWrapper
     */
    private static void manageStatusCaseCreation(CaseCreationWrapper inputWR){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_ServiceApp_U_CaringManagement - manageStatusCaseCreation');
        List<Case> casesToInsert = new List<Case>();
        Case newCase;
        for(ServiceAppointment sa : inputWR.listNewSA){
            if(checkCond1(sa)){
                continue;
            }
            try {
                if(inputWR.caseMDT == null) {
                    throw new XC_Exception(String.format(Label.XC_CL_NoMatchOnMetadata, new List<String>{'XC_CM_Case_Type_Setting__mdt', Label.XC_CL_AppointmentCancellation}));
                }
                newCase = XC_UTIL_Case.initCaseFromCaseSettings(inputWR.caseMDT);
                //newCase.Origin = populateInstallationOrigin(sa);
                newCase.Status = populateCaseStatus(sa, inputWR.caseMDT);   
                newCase.XC_Result__c = inputWR.caseMDT.XC_Result__c;
                newCase.XC_Resolution__c = inputWR.caseMDT.XC_Resolution__c;
                newCase.OwnerId = sa.OwnerId;
                ServiceAppointment servOld = inputWR.mapOld.get(sa.Id);
                String remarksContent = populateRemarks(sa, servOld, inputWR.caseMDT);
                if(!String.isEmpty(remarksContent)){
                    newCase.CaseRemarks__c = remarksContent;
                }
                UtilWrapper wrapper = new UtilWrapper();
                wrapper.sa = sa;
                wrapper.caseIdWOMap = inputWR.caseIdWOMap;
                wrapper.wo = new WorkOrder();
                wrapper.newCase = newCase;
                checkWO(wrapper);
                casesToInsert.add(newCase);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_ServiceApp_U_CaringManagement manageStatusCaseCreation - New cases To Insert='+casesToInsert);
            }  catch(XC_Exception e) {
                XC_UTIL_ExceptionLog.insertExceptionLog(e);
            }

        }
        List<XC_UTIL_Sobject.WrapperResult> listRes = XC_UTIL_Sobject.insertListRecords(casesToInsert);
        if(!XC_UTIL_Sobject.checkDMLResults(listRes)) {
            inputWR.listNewSA[0].addError(listRes[0].errorMessage);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_ServiceApp_U_CaringManagement manageStatusCaseCreation- Add a new Case To Insert='+casesToInsert);
    }

    /**
     * @description Populate Case Status
     * @param sa - ServiceAppointment
     * @param caseMDT - XC_CM_Case_Type_Setting__mdt
     * @return String 
     */
    public static String populateCaseStatus(ServiceAppointment sa, XC_CM_Case_Type_Setting__mdt caseMDT){
        String status = '';
        if(sa.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation){ 
            if(sa.XC_ReschedulingReason__c == Label.XC_CL_Rescheduling_Glovia){
                status = Label.XC_CL_Case_Open;
            }else{
                status = Label.XC_CL_Case_Status007;
            }
        }
        else{
            status = caseMDT.XC_Status__c;
        }
        return status;
    }

     /**
     * @param sa - ServiceAppointment
     * @return String 
     * @description Populate Installation Origin
     */
    public static String populateInstallationOrigin(ServiceAppointment sa){
        String origin = '';
        if(sa.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation){
            origin = Label.XC_CL_CaseOriginCAN002;
        }else{
            origin=Label.XC_CL_Case_InsistenciaOrigin;
        }
        return origin;
    }

    /**
     * @param wo - WorkOrder
     * @param newCase - Case
     * @description Check Acc And Contact
     */
    public static void checkAccAndContact(WorkOrder wo, Case newCase){
        if(wo.AccountId != null){
            newCase.AccountId = wo.AccountId;
        }
        if(wo.ContactId != null){
            newCase.ContactId = wo.ContactId;
        }
    }

    /**
     * @description Check this condition
     * @param sa - ServiceAppointment
     * @return Boolean
     */
    public static boolean checkCond1(ServiceAppointment sa){
        if(XC_UTIL_Sobject.getObjectType(sa.OwnerId) != 'User'){
            return true;
        }
        return false;
    }

    /**
    * @description Check this condition
    * @param wrapper - UtilWrapper
    */
    public static void checkWO(UtilWrapper wrapper){
        ServiceAppointment sa = wrapper.sa;
        Map<Id,WorkOrder> caseIdWOMap = wrapper.caseIdWOMap;
        WorkOrder wo = wrapper.wo;
        Case newCase = wrapper.newCase;
        if(caseIdWOMap.get(sa.Id) != null) {
            wo = caseIdWOMap.get(sa.Id);
            newCase.XC_WorkOrder__c = wo.Id;
            checkAccAndContact(wo,newCase);  
        } 
    }

    /**
     * @description Check this condition.
     * @param sa - ServiceAppointment
     * @param mapOld - Map<Id,ServiceAppointment>
     * @param listNew - List<ServiceAppointment>
     */
    public static void populateList(ServiceAppointment sa, Map<Id,ServiceAppointment> mapOld, List<ServiceAppointment> listNew) {
        if(mapOld.get(sa.Id).XC_AssignedResource__c != null) {
            listNew.add(sa);
        }
    }

    /**
     * @description Populate remarks
     * @param sa - ServiceAppointment
     * @param sOld - ServiceAppointment
     * @return String
     */
    /*private static String populateRemarks(ServiceAppointment sa, ServiceAppointment sOld){
        String remarksContent = '';
        XC_AT_Utils.RemarkMessageWrapper remarkWrapper = new XC_AT_Utils.RemarkMessageWrapper();
        remarkWrapper.lastMessage = remarksContent;
        //if(sa.Status != sOld.Status) {
            //remarkWrapper.fieldDescribe = Schema.ServiceAppointment.fields.Status.getDescribe();
            //remarkWrapper.newValue = sa.Status;
            //remarkWrapper.oldValue = sOld.Status;
            //remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        //}
        if(sa.SchedStartTime != sOld.SchedStartTime) {
            remarkWrapper.fieldDescribe = Schema.ServiceAppointment.fields.SchedStartTime.getDescribe();
            remarkWrapper.newValue = String.valueof(sa.SchedStartTime);
            remarkWrapper.oldValue = String.valueof(sOld.SchedStartTime);
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }

        if(sa.Status != sOld.Status){
            remarkWrapper.fieldDescribe = Schema.ServiceAppointment.fields.SchedStartTime.getDescribe();
            remarkWrapper.newValue = String.valueof(sa.Status);
            remarkWrapper.oldValue = String.valueof(sOld.Status);
            remarksContent = XC_AT_Utils.addRemarkMessage(remarkWrapper);
        }

        return remarksContent;
    }*/

   /**
     * @description Populate Case Remark
     * @param sa - ServiceAppointment
     * @param sOld - ServiceAppointment
     * @param caseMDT - XC_CM_Case_Type_Setting__mdt
     */
    private static String populateRemarks(ServiceAppointment sa, ServiceAppointment sOld, XC_CM_Case_Type_Setting__mdt caseMDT ){
        String remarkContent='';
        if( !String.isBlank(caseMDT.XC_CaseRemarks__c)){
            if(caseMDT.DeveloperName.equals(Label.XC_CL_CMD_ChangeAppointment) ) {
                if(sa.SchedStartTime != sOld.SchedStartTime && !String.isBlank(String.valueOf(sOld.SchedStartTime))){
                    String schedStartString  = ( sa.SchedStartTime==null ) ? 'null' : String.valueOf(sa.SchedStartTime);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'SchedStartNew: '+ sa.SchedStartTime);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Date d: '+ schedStartString);
                    Map<String,String> parameters = new Map<String,String>();
                    parameters.put('<Hora de la Cita>', Schema.ServiceAppointment.fields.SchedStartTime.getDescribe().getLabel());
                    parameters.put('<Hora antigua>',String.valueOf(sOld.SchedStartTime));
                    parameters.put('<Hora nueva>',schedStartString);
                    remarkContent = XC_UTIL_Case_U.getCaseRemarksByLegalEntity(caseMDT, sa.XC_LegalEntity__c, parameters);
                    //remarkContent = remarkContent.replace('<Hora de la Cita>', Schema.ServiceAppointment.fields.SchedStartTime.getDescribe().getLabel()).replace('<Hora antigua>',String.valueOf(sOld.SchedStartTime) ).replace('<Hora nueva>',schedStartString );
                }
                else if(sa.SchedEndTime != sOld.SchedEndTime  && !String.isBlank(String.valueOf(sOld.SchedEndTime))){
                    String schedEndString  = ( sa.SchedEndTime==null ) ? 'null' : String.valueOf(sa.SchedEndTime);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'CaseRemarks:' + remarkContent);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'SchedStartOld: '+ sOld.SchedEndTime);
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'SchedStartNew: '+ sa.SchedEndTime);
                    Map<String,String> parameters = new Map<String,String>();
                    parameters.put('<Hora de la Cita>', Schema.ServiceAppointment.fields.SchedEndTime.getDescribe().getLabel());
                    parameters.put('<Hora antigua>',String.valueOf(sOld.SchedEndTime));
                    parameters.put('<Hora nueva>',schedEndString);
                    remarkContent = XC_UTIL_Case_U.getCaseRemarksByLegalEntity(caseMDT, sa.XC_LegalEntity__c, parameters);
                    //remarkContent = remarkContent.replace('<Hora de la Cita>', Schema.ServiceAppointment.fields.SchedEndTime.getDescribe().getLabel()).replace('<Hora antigua>',String.valueOf(sOld.SchedEndTime) ).replace('<Hora nueva>',schedEndString );
                }
            }

            if(caseMDT.DeveloperName.equals(Label.XC_CL_AppointmentCancellation)){
                Map<String,String> parameters = new Map<String,String>();
                parameters.put('<Estado de la Work Order>', Schema.ServiceAppointment.fields.Status.getDescribe().getLabel());
                parameters.put('<Estado antiguo>', sOld.Status);
                parameters.put('<Cancelado>', sa.Status);
                remarkContent = XC_UTIL_Case_U.getCaseRemarksByLegalEntity(caseMDT, sa.XC_LegalEntity__c, parameters);
                //remarkContent = remarkContent.replace('<Estado de la Work Order>', Schema.ServiceAppointment.fields.Status.getDescribe().getLabel() ).replace('<Estado antiguo>', sOld.Status ).replace( '<Cancelado>', sa.Status);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'remarkContent:'+ remarkContent);
        return remarkContent;
    }
    
    /**
    * @description INNER QUEABLE CLASS for Manage Case status on WO Update
    * @author PERFORMANCE IMPROVEMENT - MAY 2022 - GDB/FA 
    * @return Boolean
    */
    public class manageCaseCreationAsync implements Queueable{
        CaseCreationWrapper inputWR;
        Boolean status;
        public manageCaseCreationAsync(CaseCreationWrapper inputWR, Boolean status){
            this.inputWR = inputWR;
            this.status = status;
        }

        public void execute(QueueableContext context) {
            if(!status){
                manageCaseCreation(this.inputWR);
            
            }else{
                manageStatusCaseCreation(this.inputWR);
            }
        }
    }
}