/**
* @author De Blasio Valentina
* @date Creation 15/04/2022
* @date Modification
* @description Apex Class send notification tecnico
*/
public without sharing class XC_TR_ServiceAppointment_U_Notification {
    public static void sendNotificationServiceAppointment(Map<Id,ServiceAppointment> mapOld, Map<Id,ServiceAppointment> mapNew) {
        Set<Id> workOrderIdList = new Set<Id>();
        Set<Id> accountIdsp=new Set<Id>();
        Set<Id> saId=new Set<Id>();
        System.debug('@@mapOld'+ mapOld);
        System.debug('@@mapNew'+ mapNew);
        List<String> fieldList = new List<String>{'Status','XC_ReasonforSuspension__c'};
        List<ServiceAppointment> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
        System.debug('List changed'+listChanged);
        if(!listChanged.isEmpty()){
          for(ServiceAppointment sa:listChanged){
            if(sa.Status =='On Hold' && sa.XC_ReasonforSuspension__c=='Richiesta Preventivo'){
              saId.add(sa.id);
              workOrderIdList.add(sa.ParentRecordId);
              accountIdsp.add(sa.AccountId);
           }
        System.debug('@@@listSerciceAppID'+saId);
        System.debug('@@@@@workOrderIdList'+workOrderIdList);
         }
        }
        List<WorkOrder> woList=new List<WorkOrder>();
        List<CustomNotificationType> cnt =[SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='FieldUpdateNotification'];
        
        if(!workOrderIdList.isEmpty()){
          woList=[Select id,WorkOrderNumber,XC_LegalEntity__c,Account.name,AccountId,XC_WorkTypeCategory__c,XC_Segment__c,Case.XC_BusinessLine__c from WorkOrder where id in:workOrderIdList and (XC_LegalEntity__c = 'EnelSole' or XC_LegalEntity__c='EnelXItalia') and XC_WorkTypeCategory__c ='Malfunctioning' and (XC_Segment__c='B2B' or XC_Segment__c ='B2G') and Case.XC_BusinessLine__c='eCity'];
            /*for(WorkOrder wo :woList)  {
                accountIdsp.add(wo.AccountId);
            } */
        if(!woList.isEmpty() && !accountIdsp.isEmpty()){
          List<AccountTeamMember> listmember=[select id,userid from AccountTeamMember where AccountId in:accountIdsp and TeamMemberRole='Tecnico Gestionale'];
          if(!listmember.isEmpty()){
           for(ServiceAppointment sa:listChanged){
            for(WorkOrder wo:woList){
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Nuova notifica');
                notification.setBody('Il Service Appointment'+' '+sa.AppointmentNumber+' '+'relativo al Work Order di guasto'+' '+wo.WorkOrderNumber+' '+'aperto sul'+' '+wo.Account.Name+' '+'è in attesa per Richiesta Preventivo');
                notification.setSenderId(listmember[0].userid);
                notification.setNotificationTypeId(cnt?.get(0).Id );
                notification.setTargetId(sa.id);
                notification.send(new Set<String>{listmember[0].userid});
                System.debug('@@@notification'+notification);
             }
          }
        }
       }
      }
     }
    }