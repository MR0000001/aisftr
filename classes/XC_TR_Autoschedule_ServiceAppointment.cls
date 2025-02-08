public with sharing class XC_TR_Autoschedule_ServiceAppointment {
    public static void autoScheduleServiceAppointment(List<ServiceAppointment> newList){
          List<ServiceAppointment> saList=new List<ServiceAppointment>();
          List<Id> parentIdList=new List<id>();
          Map<ServiceAppointment,id> mapSA=new Map<ServiceAppointment,id>();
          system.debug('enter method'+' '+'autoScheduleServiceAppointment');
          for(ServiceAppointment sa:newList){
             if(sa.FSL__Auto_Schedule__c==false){
                parentIdList.add(sa.ParentRecordId);
                system.debug('parent id'+' '+sa.ParentRecordId);
                mapSA.put(sa,sa.ParentRecordId);
                saList.add(sa);
             }

      
            // mapSA.put(sa.ParentRecordId,sa);
          }
         Map<Id,WorkOrder> woMap=new Map<id,WorkOrder>([select id,XC_Segment__c, XC_LegalEntity__c,XC_WorkTypeCategory__c,DurationInMinutes, 
                                                         startDate,EndDate,XC_DueDate__c 
                                                        from workorder 
                                                        where ( id IN:parentIdList and
                                                                xc_worktypecategory__c='Malfunctioning' and 
                                                                (XC_Segment__c='B2B' or XC_Segment__c ='B2G') 
                                                                )]); 
         system.debug('woSizeList'+' '+woMap.values().size());               
           /* for(WorkOrder wo:woList){
               for(ServiceAppointment sa:wo.serviceappointments){ 
                system.debug('autoschedule sa'+' '+sa.FSL__Auto_Schedule__c); 
                if(!sa.FSL__Auto_Schedule__c){
                      sa.FSL__Auto_Schedule__c=true;
                  }
              }

            }*/
            for(ServiceAppointment sa:newList){           
                if(woMap.get(sa.ParentRecordId)!= Null){          
                    WorkOrder wo=woMap.get(sa.ParentRecordId);
                    //sa.FSL__Auto_Schedule__c=true; //DeAv 31.03.2022 CR775
                    sa.EarliestStartTime=wo.startDate;
                    sa.DueDate=wo.XC_DueDate__c;
                    //sa.EarliestStartTime = Datetime.now().addMinutes(10);
                    //sa.DueDate = wo.DurationInMinutes != null ? Datetime.now().addMinutes(Integer.valueOf(wo.DurationInMinutes)+10) : XC_UTIL_Schedule_D.getDueDate(Datetime.now(), 10);
                    //sa.Description = 'Test Prova';
                    System.debug('Service Appointment'+ sa);
                    System.debug('Service Appointment Auto Schedule'+ sa.FSL__Auto_Schedule__c);
                }
            }


         /*
            List<ServiceAppointment> saToInsert=new List<ServiceAppointment>();
            if(woMap.values().size()>0){
                for(ServiceAppointment sa:saList){
                id woId=mapSA.get(sa);
                system.debug('enter 2°if');
                if(woMap.get(woId)!=null){
                    sa.FSL__Auto_Schedule__c=true;
                    system.debug('autoscheduled'+' '+sa.FSL__Auto_Schedule__c);
                    saToInsert.add(sa);
                }
            }
         }*/
        // insert saToInsert; 
    }
}