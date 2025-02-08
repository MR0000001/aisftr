/**
* @author Marco Rosa - marco.rosa@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 19/09/2018
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_ServiceAppointment_Handler – Handler for XC_TR_ServiceAppointment Trigger
*/ 

public without sharing class XC_TR_ServiceAppointment_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceAppointment_Handler');
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed); 
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        //mapTriggerStopped.put(Trigger.operationType, true);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com 
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<ServiceAppointment> listNew){
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            XC_TR_ServiceAppointment_U_CheckStatus.checkInsertServiceAppointment(listNew);
            XC_TR_ServiceAppointment_U_FillFieldByWO.populateFieldsFromWorkOrder(listNew);  
            XC_TR_ServiceAppointment_U_FillCoverage.populateZipCodeWorkType(listNew);
        }
	XC_TR_Autoschedule_ServiceAppointment.autoScheduleServiceAppointment(listNew);
        //JJP 01-12-2021 - Start
        if(XC_UTIL_OneOrg.isRightCountry('Colombia') || XC_UTIL_OneOrg.isRightCountry('Chile')){
            XC_TR_ServiceAppointment_U_FillFieldByWO.populateFieldsFromWorkOrderCH(listNew);
        }
        //JJP 01-12-2021 - End
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        Map<Id, ServiceAppointment> mapOld = (Map<Id, ServiceAppointment>) mapOldS; 
        Map<Id, ServiceAppointment> mapNew = (Map<Id, ServiceAppointment>) mapNews;
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);    
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<ServiceAppointment> listNew = mapNewS.values(); 
            XC_TR_ServiceAppointment_U_CheckStatus.manageChangeStatus(listNew, mapOld, mapNew);
            XC_TR_ServiceAppointment_U_CheckStatus.checkToBeDigitalized(listNew, mapOld, mapNew);
            XC_TR_ServiceAppointment_U_FillCoverage.checkZipCodeChanged(listNew, mapOld, mapNew);
            XC_TR_ServiceAppointment_U_Rescheduling.checkDateChanges(mapOld, mapNew); 
            XC_TR_ServiceAppointment_U_WoliClosure.checkWOLIBeforeClosure(listNew, mapOld, mapNew);
            XC_TR_ServiceAppointment_U_Notification.sendNotificationServiceAppointment(mapOld, mapNew);//CR763
        }
        XC_TR_ServiceAppointment_U_CheckStatus.checkMalfunctioningSACompletion(mapOld, mapNew); 
    } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on before delete
     * @param mapOld - map Id -> old value of record
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
        }        
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after insert
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS) { 
          if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<ServiceAppointment> listNew = mapNewS.values();
            XC_TR_ServiceAppointment_U_FillCoverage.encryptServiceAppointmentIds(listNew);
            XC_TR_ServiceAppointment_U_FillFieldOnWO.populateFieldsFromWorkOrder(listNew);

           // XC_TR_NewWoScheduleRecord.NewWoScheduleRecord(listNew);
            //XC_TR_ServiceApp_U_CreateCustomInter.afterInsertCICreation(listNew);

          } 
      } 
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after update
     * @param mapOldS - map Id -> old value of record
     * @param mapNewS - map Id -> new value of record
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){ 
        Map<Id, ServiceAppointment> mapOld = (Map<Id, ServiceAppointment>) mapOldS; 
        Map<Id, ServiceAppointment> mapNew = (Map<Id, ServiceAppointment>) mapNews; 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            List<ServiceAppointment> listNew = mapNewS.values();
            
			 XC_TR_OnHoldMalfunctioningSA.OnHoldMalfunctioningSA(listNew,mapOld);
            XC_TR_OnHoldMalfunctioningSA.replanningSA(listNew,mapOld);
            XC_TR_ServiceAppointment_U_UpdateWO.manageWorkOrder(listNew, mapOld, mapNew);
            XC_TR_ServiceApp_U_CaringManagement.manageCase(listNew, mapOld, mapNew);
            XC_TR_ServiceAppointment_U_OptySubSt.updateSubstatusPicklist(listNew, mapOld, mapNew);
            XC_TR_ServiceApp_U_CreateCustomInter.afterServiceAppointmentUpdate(listNew, mapOld, mapNew);  // NM LR - 26/11/2018 - ESCEP-526
            XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntServiceAppointmentConfirmed(mapOld, mapNew); //GDB 18/08/2020
            XC_TR_ServiceAppointment_U_Survey.createSurvey( mapOld, mapNew);            
        }
        XC_TR_ServiceAppointment_U_CheckStatus.checkServiceAppointmentWhenCompleted(mapOld, mapNew);
    }
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after delete
     * @param mapOld - map Id -> old value of record
    */
    public void onAfterDelete(Map<Id, SObject> mapOld){ 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);            
        }           
    } 

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Method to be executed on after undelete
     * @param mapNew - map Id -> new value of record
    */
    public void onAfterUnDelete(Map<Id, SObject> mapNew) { 
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        }           
    }    
}