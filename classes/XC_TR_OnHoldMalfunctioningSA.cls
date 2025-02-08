/**
 * @author Nicola Arrigo - narrigo@deloitte.it
 * @date Creation 12/03/2021
 * @description XC_OnHoldMalfunctioningCase 
 */
public with sharing class XC_TR_OnHoldMalfunctioningSA {
    public static void OnHoldMalfunctioningSA( List<ServiceAppointment> listNew, Map<id,ServiceAppointment> mapOld){
      List<id> WorkOrderListIds=new List<Id>();
      List<ServiceAppointment> saList=new List<ServiceAppointment>(); 
       for(ServiceAppointment sa:listNew){
           system.debug('reason for suspencion SA'+sa.XC_ReasonforSuspension__c);
           if(
               sa.Status=='On Hold' &&
               sa.Status!=mapOld.get(sa.id).Status &&
               sa.XC_ReasonforSuspension__c!=null  && 
               sa.XC_Notesforsuspensionandresolution__c!=null &&
               (sa.XC_Segment__c=='B2B' || sa.XC_Segment__c=='B2G')
               ){
                WorkOrderListIds.add(sa.ParentRecordId);
                system.debug('parent record id '+sa.ParentRecordId);  
                saList.add(sa); 
           }
        }
        if( saList.isEmpty()){
            system.debug('List Service Appointment empty');
            return;
        }
        Map<id,WorkOrder> woMap=new Map<id,WorkOrder>([select id,XC_ReasonforSuspension__c,XC_Notesforsuspensionandresolution__c from workorder
                                                        where id IN:WorkOrderListIds AND 
                                                        Status!='On Hold' AND
                                                         (Status='Assigned'or Status='In Progress')]);
         if(woMap.values().isEmpty()){
             system.debug('No WO to be Updated');
             return;
         }                                               

         system.debug('woMap '+woMap);                                               
         for(ServiceAppointment sa:saList){
             system.debug('Parent Record Id '+sa.ParentRecordId);
             if(woMap.get(sa.ParentRecordId)!=null){
                WorkOrder wo=woMap.get(sa.ParentRecordId);
                wo.XC_ReasonforSuspension__c=sa.XC_ReasonforSuspension__c;
                if(sa.XC_Notesforsuspensionandresolution__c!=null){
                    wo.XC_Notesforsuspensionandresolution__c=sa.XC_Notesforsuspensionandresolution__c;
                }
                wo.Status='On Hold';
             }
         }
         update woMap.values();
    }
    public static void replanningSA(List<ServiceAppointment> listNew, Map<id,ServiceAppointment> mapOld){
        system.debug('enter on OnHoldMalfunctioningSA.replanningSA');
        List<id> WorkOrderListIds=new List<Id>();
        List<ServiceAppointment> saList=new List<ServiceAppointment>(); 
        for(ServiceAppointment sa:listNew){
            if(
                (sa.Status=='In Progress' || 
                  sa.status=='Scheduled'   ||
                  sa.Status=='Completed'
                ) &&
                sa.Status!=mapOld.get(sa.id).Status &&
                mapOld.get(sa.id).Status=='On Hold' &&
                sa.XC_NotesforResolution__c!=null   &&
                (sa.XC_Segment__c=='B2B' || sa.XC_Segment__c=='B2G')
                ){
                 WorkOrderListIds.add(sa.ParentRecordId);  
                 saList.add(sa); 
                }
            }
            if( saList.isEmpty()){
                return;
            }

           Map<id,WorkOrder> woMap=new Map<id,WorkOrder>([select id,XC_ReasonforSuspension__c,XC_Notesforsuspensionandresolution__c from workorder
                                                          where id IN:WorkOrderListIds AND 
                                                           Status='On Hold']);
        system.debug('woMap '+woMap);                                                 
         if(woMap.values().isEmpty()){
             system.debug('No WO to be Updated');
             return;
         }
                                            
         for(ServiceAppointment sa:saList){
             system.debug('Parent Record Id '+sa.ParentRecordId);
             if(woMap.get(sa.ParentRecordId)!=null){
                 system.debug('Note for resolution line 76'+sa.XC_NotesforResolution__c);
                WorkOrder wo=woMap.get(sa.ParentRecordId);
                wo.XC_NotesforResolution__c=sa.XC_NotesforResolution__c;
                if(sa.Status=='In Progress'){
                    wo.Status='In Progress';
                }else if(sa.status=='Scheduled'){
                    wo.Status='Assigned';
                }else if(sa.status=='Completed'){
                    wo.Status='In Progress';
                }
                
             }
         }
         update woMap.values();                                               
    }
}