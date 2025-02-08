public with sharing class XC_TR_U_WOChangePartnerPreferred {
     public static void WOChangePartnerPreferred(Map<id,WorkOrder> newMap, Map<id,WorkOrder> oldMap){
        List<id> woIdList=new List<id>(); 
        for(WorkOrder wo:newMap.values()){
             if(newMap.get(wo.Id).XC_PreferredPartner__c!=oldMap.get(wo.Id).XC_PreferredPartner__c){
                woIdList.add(wo.id);
             }
         }
                 if(woIdList.size()>0){
            List<ServiceAppointment> saList=[select id,ParentRecordId,XC_AssignToPartner__c 
                                            from ServiceAppointment
                                            where  ParentRecordId IN:woIdList];
            if(saList.size()>0){
                for(ServiceAppointment sa:saList){
                    sa.XC_AssignToPartner__c =true;
                }
                update saList;
            } 
         }
     }
}