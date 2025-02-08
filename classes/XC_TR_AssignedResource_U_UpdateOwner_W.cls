/**
* @author Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 19/04/2019
* @date Modification dd/mm/yyyy
* @description Wrapper Class for XC_TR_AssignedResource_U_UpdateOwner
*/ 
public class XC_TR_AssignedResource_U_UpdateOwner_W {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_AssignedResource_U_UpdateOwner');

    /** @description UpdateServiceAppointmentWrapper */  
    public class UpdateServiceAppointmentWrapper {
        public Map<Id, ServiceAppointment> mapServiceAppointment = new Map<Id, ServiceAppointment>();
        public Map<Id,Id> mapServiceAppointmentServiceResourceAccount = new Map<Id,Id>();
        public Map<Id,Id> mapServiceAppointmentServiceResource = new Map<Id,Id>();
        public Map<String, String> mapServiceAppointmentTerritory = new Map<String, String>();
    }

    /** @description Wrapper for updateCommercialVisitRelatedObjects parameters */
    public class UpdateRecordWrapper{
        public List<WorkOrder> listWorkOrder = new List<WorkOrder>(); 
        public Map<Id,Id> mapServiceAppointmentOwner = new Map<Id, Id>(); 
        public Map<Id,Id> mapWorkOrderServiceAppointmentId = new Map<Id, Id>(); 
        public Map<Id,Id> mapServiceAppointmentServiceResource = new Map<Id, Id>(); 
        public Map<Id,Id> mapServiceAppointmentServiceResourceAccount = new Map<Id, Id>(); 
        public Map<Id,Id> mapServiceAppointmentServiceTerritoryId = new Map<Id, Id>(); 
        public Map<Id, ServiceAppointment> mapServiceAppointment = new Map<Id, ServiceAppointment>();
        public Map<String, String> mapServiceAppointmentTerritory = new Map<String, String>();
    }
    
}