/**
* @author Marco Rosa - marco.rosa@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 26/11/2018
* @date Modification dd/mm/yyyy
* @description XC_SC007_AutoCancelServiceAppointment – Batch used in order to check all the Installation/Delivery Work Order 
    having the related Configuration Item with Bank Transfer as a Payment Method. 
    If the Appointment Start is tomorrow, and the payment has not been completed, 
    the status of the SA must be changed to Cannot Complete (not final reason) 
    and a Case to a specific queue must be opened (the BO will check with the customer in order 
    to open a new SA or cancel the WO).
*/
 
public with sharing class XC_SC007_AutoCancelServiceAppointment implements Schedulable, Database.Batchable<sObject>{
 
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC007_AutoCancelServiceAppointment');

    /** @description ServiceAppointmentToUpdateWrapper */
    private class ServiceAppointmentToUpdateWrapper {
        WorkOrder wo;
        ServiceAppointment sa;
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<Id> confItemIdToCreateCase = new List<Id>();
    }

    /**
     * @description execute method
     * @param sc - SchedulableContext
    */
    public void execute(SchedulableContext sc) { 
        Id batchId = Database.executeBatch(new XC_SC007_AutoCancelServiceAppointment());
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC007_AutoCancelServiceAppointment ID ' + batchId);
    }

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = ' SELECT Id, SchedStartTime, ParentRecordId ' + 
                       ' FROM ServiceAppointment ' + 
                       ' WHERE SchedStartTime = TOMORROW ' +  
                       ' AND ( XC_WorkTypeLabel__c = \'' + Label.XC_CL_WorkType_DeliveryInstallation + '\''+
                       ' OR XC_WorkTypeLabel__c = \'' + Label.XC_CL_WorkType_Installation + '\')'+
                       ' AND XC_Payment_Type__c = \'' + Label.XC_CL_BankTransfer + '\''; 
        return Database.getQueryLocator(query);
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {  
        XC_UTIL_Debug.debug(DEBUGACTIVE, scope);
        Set<Id> setWoId = new Set<Id>();
        for(ServiceAppointment sa : scope){
            setWoId.add(sa.ParentRecordId);
        }
        Map<Id, WorkOrder> mapWO = new Map<Id, WorkOrder>([SELECT Id,XC_Configuration_Item__c,XC_Configuration_Item__r.XC_Payment_Check_OK__c
                                  FROM WorkOrder 
                                  WHERE Id IN:setWoId]);
        List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
        List<Id> confItemIdToCreateCase = new List<Id>();
        for(ServiceAppointment sa : scope){
            if(mapWO.containsKey(sa.ParentRecordId)) {
                WorkOrder wo = mapWo.get(sa.ParentRecordId);
                if(wo.XC_Configuration_Item__c != null) {
                    ServiceAppointmentToUpdateWrapper saToUpdateWrapper = new ServiceAppointmentToUpdateWrapper();
                    saToUpdateWrapper.wo = wo;
                    saToUpdateWrapper.sa = sa;
                    saToUpdateWrapper.saToUpdate = saToUpdate;
                    saToUpdateWrapper.confItemIdToCreateCase = confItemIdToCreateCase;
                    checkServiceAppointmentToUpdate(saToUpdateWrapper);
                    saToUpdate = saToUpdateWrapper.saToUpdate;
                    confItemIdToCreateCase = saToUpdateWrapper.confItemIdToCreateCase;
                }
            }
        }
        if(!saToUpdate.isEmpty()){
            for(ServiceAppointment sa : saToUpdate){
                sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
                sa.XC_Reason_Cannot_Complete__c = Label.XC_CL_ServiceAppointment_Payment_Not_Done;
            }
        }
        if(!confItemIdToCreateCase.isEmpty()){
            //List<NE__OrderItem__c> confItemList = XC_UTIL_Sobject.selectAllFields(confItemIdToCreateCase, 'NE__OrderItem__c');
            String query = XC_UTIL_SObject.selectAllFieldsGetSelect('NE__OrderItem__c'); 
            query += ', NE__OrderId__r.NE__OptyId__r.XC_Contact__c';
            query += ' FROM NE__OrderItem__c WHERE id IN : confItemIdToCreateCase';
            List<NE__OrderItem__c> confItemList = Database.query(query);
            XC_UTIL_Case.createPaymentVerificationCases(confItemList);   
        }
    }

    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
    public void finish(Database.batchablecontext bc) {     
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC007_AutoCancelServiceAppointment ID');
    }

    /**
     * @description Check for ServiceAppointment to update
     * @param wrapper - ServiceAppointmentToUpdateWrapper 
    */
    private void checkServiceAppointmentToUpdate(ServiceAppointmentToUpdateWrapper wrapper) {     
        if(!wrapper.wo.XC_Configuration_Item__r.XC_Payment_Check_OK__c){
            wrapper.saToUpdate.add(wrapper.sa);
            wrapper.confItemIdToCreateCase.add(wrapper.wo.XC_Configuration_Item__c);
        }
    }
}