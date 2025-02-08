public with sharing class XC_TR_WOLI_U_ClosureManagementB2B {

    public static void closeWoli(List<WorkOrderLineItem> listNew, Map<Id, WorkOrderLineItem> mapOld, Map<Id, WorkOrderLineItem> mapNew){
        List<String> fieldList = new List<String>{'Status'};
        List<WorkOrderLineItem> woliToConsider = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        
         if(!listChanged.isEmpty()){
             for(WorkOrderLineItem w : listChanged){
                 if( w.Status == 'Completed' && !String.isEmpty(w.XC_ProvisioningStep__c)){
                     WoliToConsider.add(w);
                    // system.debug('DL++++W' + w);
                     //system.debug('DL++++WoliToConsider' + WoliToConsider);
                 }
             }
             
         }
         
          List<XC_Provisioning_Step__c> stepsToUpdate = new List<XC_Provisioning_Step__c>();
        for(WorkOrderLineItem w : woliToConsider){
            XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(Id = w.XC_ProvisioningStep__c);
            if( w.Status == 'Completed' && w.XC_WOLIType__c !='Technical Asset' && w.XC_WOLIType__c !='Partner Payment'){
                step.XC_Status__c = Label.XC_CL_Completed_Ok;
            }
           
            else if ( w.Status == 'Cancelled') {
                step.XC_Status__c = Label.XC_CL_Step_CompletedKO; 
            }
            //system.debug('DL++++w.Status' + w.Status);
            //system.debug('DL++++step.XC_Status__c' + step.XC_Status__c);
            stepsToUpdate.add(step);	
            //system.debug('DL++++stepsToUpdate' + stepsToUpdate);
        }
        XC_UTIL_Sobject.updateListRecords(stepsToUpdate);
        //system.debug('DL++++stepsToUpdate2' + stepsToUpdate);
   }
}