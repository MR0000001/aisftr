/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 10/07/2019
* @description XC_SC015_CancelMaintenanceWorkOrder – Batch to cancel old Maintenance Work Orders
*/
public with sharing class XC_SC015_CancelMaintenanceWorkOrder implements Schedulable, Database.Batchable<sObject> {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC015_CancelMaintenanceWorkOrder');
    
    /**
     * @author Roberta Cossiga - rcossiga@deloitte.it
     * @description start
     * @param bc - BatchableContext 
     * @return Database.getQueryLocator
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!Schema.sObjectType.ServiceAppointment.isAccessible()){
            return null;
        }
        String query =  'SELECT Id, XC_WorkTypeLabel__c, DueDate, Status' + 
                        ' FROM ServiceAppointment ' +
                        ' WHERE XC_WorkTypeCategory__c= \'' + Label.XC_CL_WorkType_PlannedMaintenance + '\''+
                        ' AND Status != \'' + Label.XC_CL_ServiceAppointment_StatusCannotComplete + '\''+ 
                        ' AND Status != \'' + Label.XC_CL_ServiceAppointment_Completed + '\'' +
                        ' AND Status != \'' + Label.XC_CL_ServiceAppointment_Canceled + '\'' +
                        ' AND Status != \'' + Label.XC_CL_ServiceAppointment_Dispatched + '\'';
        System.debug('@@@query-->' + query);                
        return Database.getQueryLocator(query);
    }

       /**
     * @description execute method
     * @param sc - SchedulableContext
    */
	public void execute(SchedulableContext sc) { 
		Id batchId = Database.executeBatch(new XC_SC015_CancelMaintenanceWorkOrder());
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'batch XC_SC015_CancelMaintenanceWorkOrder ' + batchId); 
	}


    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> scope) {
        List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  
        List<ServiceAppointment> saListToUpdate = new List<ServiceAppointment>();
        for(ServiceAppointment sa : scope){
            if(System.Today() > sa.DueDate.addMonths(3) && (sa.Status != Label.XC_CL_ServiceAppointment_None || sa.Status != Label.XC_CL_ServiceAppointment_Scheduled)){
                sa.Status = Label.XC_CL_ServiceAppointment_CannotComplete;
                sa.XC_Reason_Cannot_Complete__c = 'Rethinking_FINAL';
                saListToUpdate.add(sa);
            }
            else if(System.Today() > sa.DueDate.addMonths(3) && (sa.Status == Label.XC_CL_ServiceAppointment_None || sa.Status != Label.XC_CL_ServiceAppointment_Scheduled)){
                sa.Status = Label.XC_CL_ServiceAppointment_Canceled;
                saListToUpdate.add(sa);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> listWrapperResult = XC_UTIL_Sobject.updateListRecords(saListToUpdate);
        for(XC_UTIL_Sobject.WrapperResult wr : listWrapperResult){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC015_CancelMaintenanceWorkOrder';
                bel.XC_ErrorMessage__c = wr.errorMessage; 
                bel.XC_TypeOfOperation__c = 'Update Service Appointment';
                bel.XC_RecordId__c = wr.errorObjectId;
                errorLog.add(bel);
            }
        }
		XC_UTIL_Sobject.insertListRecords(errorLog);
    }

    /** 
     * @description execute method
     * @param bc - BatchableContext 
    */
    public void finish(Database.BatchableContext bc) { 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'FINISH batch XC_SC015_CancelMaintenanceWorkOrder ID');
    }
}