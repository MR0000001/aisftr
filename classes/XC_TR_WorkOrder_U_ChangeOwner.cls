/**
* @author D.Lombardi
* @date Creation 16/03/2021
* @date Modification MAY 2022 - FA/GDB - PERFORMANCE IMPROVEMENT
* @description XC_TR_WorkOrder_U_ChangeOwner
*/

public with sharing class XC_TR_WorkOrder_U_ChangeOwner {
    
    public static void isChangePreferedPartner(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew){
    
        Map<Id,WorkOrder> mapIdWorkOrderChanger = new Map<Id,WorkOrder>();
        Map<Id,WorkOrder> mapIdWorkOrderCH = new Map<Id,WorkOrder>();
        for(WorkOrder woOld : mapOld.values()){
            
            WorkOrder woNew = mapNew.get(woOld.Id);
            XC_UTIL_Debug.debug(false, 'Old-->'+woOld.XC_PreferredPartner__c);
            XC_UTIL_Debug.debug(false, 'New-->'+woNew.XC_PreferredPartner__c);

            if(woOld.XC_PreferredPartner__c != woNew.XC_PreferredPartner__c && woNew.XC_Segment__c!= 'B2C'){
                mapIdWorkOrderChanger.put(woNew.id,woNew);
            }
        }
        XC_UTIL_Debug.debug(false, 'EMPTY-->'+mapIdWorkOrderChanger.isEmpty());
        if(mapIdWorkOrderChanger.isEmpty()){
            return;
        }
        updateSkipFilteredResources(mapIdWorkOrderChanger, mapNew);
        
    }
    
    
    private static void updateSkipFilteredResources(Map<Id,WorkOrder> mapIdWorkOrderChanger, Map<Id,WorkOrder> mapNew){
        List<ServiceAppointment> listServiceAppointments = new List<ServiceAppointment>();
        List<ServiceAppointment> listServiceAppointmentsToUpdate = new List<ServiceAppointment>();
        listServiceAppointments = retrieveServiceAppointments(mapIdWorkOrderChanger);
        if(listServiceAppointments.isEmpty()){
            XC_UTIL_Debug.debug(false, 'EMPTY-->'+listServiceAppointments.isEmpty());
            return;
        }
        
        for(ServiceAppointment sa : listServiceAppointments){
            if(mapIdWorkOrderChanger.containsKey(sa.ParentRecordId)){
                if(sa.XC_SkipFilteredOnResource__c){
                    sa.XC_SkipFilteredOnResource__c = false;
                    listServiceAppointmentsToUpdate.add(sa);
                }
            }
        }
        //GDB - PERFORMANCE IMPROVEMENT - MAY 2022
        updateTriggersOFF(listServiceAppointmentsToUpdate);
    }
    
    
    public static void isChangeAssignedResources(List<WorkOrder> listNew, Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew){
        Map<Id,WorkOrder> mapIdWorkOrderChanger = new Map<Id,WorkOrder>();
        Map<Id,WorkOrder> mapIdWorkOrderCH = new Map<Id,WorkOrder>();
        for(WorkOrder woOld : mapOld.values()){
            
            WorkOrder woNew = mapNew.get(woOld.Id);
            XC_UTIL_Debug.debug(false, 'Old-->'+woOld.XC_AssignedResource__c);
            XC_UTIL_Debug.debug(false, 'New-->'+woNew.XC_AssignedResource__c);
            if(woOld.XC_AssignedResource__c != woNew.XC_AssignedResource__c && woNew.XC_Segment__c!= 'B2C'){
                XC_UTIL_Debug.debug(false, 'Old-->'+woOld.XC_AssignedResource__c);
                XC_UTIL_Debug.debug(false, 'New-->'+woNew.XC_AssignedResource__c);
                mapIdWorkOrderChanger.put(woNew.id,woNew);
            }
        }
        XC_UTIL_Debug.debug(false, 'EMPTY-->'+mapIdWorkOrderChanger.isEmpty());
        if(mapIdWorkOrderChanger.isEmpty()){
            return;
        }
        
        updateSkipFilteredForAssignerResources(mapIdWorkOrderChanger,mapNew);
        
    }
    
    private static void updateSkipFilteredForAssignerResources(Map<Id,WorkOrder> mapIdWorkOrderChanger, Map<Id,WorkOrder> mapNew){
        List<ServiceAppointment> listServiceAppointments = new List<ServiceAppointment>();
        List<ServiceAppointment> listServiceAppointmentsToUpdate = new List<ServiceAppointment>();
        listServiceAppointments = retrieveServiceAppointments(mapIdWorkOrderChanger);
        if(listServiceAppointments.isEmpty()){
            XC_UTIL_Debug.debug(false, 'EMPTY-->'+listServiceAppointments.isEmpty());
            return;
        }
        
        for(ServiceAppointment sa : listServiceAppointments){
            if(mapIdWorkOrderChanger.containsKey(sa.ParentRecordId)){
                if(!sa.XC_SkipFilteredOnResource__c){
                    sa.XC_SkipFilteredOnResource__c = true;
                    listServiceAppointmentsToUpdate.add(sa);
                }
            }
        }
        //GDB - PERFORMANCE IMPROVEMENT - MAY 2022
        updateTriggersOFF(listServiceAppointmentsToUpdate);
    }
    
    public static void updateTriggersOFF(List<ServiceAppointment> listServiceAppointmentsToUpdate){
        
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        update listServiceAppointmentsToUpdate;
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ServiceAppointment_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        
    }
    
    private static List<ServiceAppointment> retrieveServiceAppointments(Map<Id,WorkOrder> mapIdWorkOrderChanger){
        XC_UTIL_Debug.debug(false, 'New-->'+mapIdWorkOrderChanger);
        List<ServiceAppointment> listServiceAppointments = [select id, ParentRecordId, XC_SkipFilteredOnResource__c from ServiceAppointment where ParentRecordId = :mapIdWorkOrderChanger.keySet()];
        return listServiceAppointments;
    }
}