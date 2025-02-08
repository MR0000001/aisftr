/**
* @author sooraji.sajan@accenture.com - raffaele.sojka@accenture.com 
* @date Creation 18/03/2022
*/
public with sharing class XC_TR_WorkOrderLineItem_U_CheckStatus {
 
    public static void checkWoliStatusAndSentNotif(List<WorkOrderLineItem> listNew, Map<Id, WorkOrderLineItem> mapOld, Map<Id, WorkOrderLineItem> mapNew){
        
        List<String> fieldList = new List<String>{'Status'};
        Set<Id> workOrderRefusedIds = new Set<Id> ();
        List<WorkOrderLineItem> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        
        for(WorkOrderLineItem woli : listChanged){
            if(!woli.status.equalsIgnoreCase('Refused')){
                return;
            }else{
                workOrderRefusedIds.add(Woli.Id);
            } 
        }

        List<CustomNotificationType> typNotify = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'FieldUpdateNotification'];
        List<WorkOrderLineItem> workOrderRefused = [SELECT id, XC_InternalID__c, WorkOrder.Account.Name, 
                                                    (SELECT id, Status, CreatedById,LastActorId,TargetObjectId 
                                                     FROM ProcessInstances 
                                                     WHERE status = 'Approved' 
                                                     ORDER BY LastModifiedDate DESC)
                                                    FROM WorkOrderLineItem 
                                                    WHERE id IN: workOrderRefusedIds];
        
        ProcessInstance lastpI = new ProcessInstance();
        for(WorkOrderLineItem woli : workOrderRefused){
            if(!Test.isRunningTest()){
                lastpI = woli.ProcessInstances.get(0);
                if(lastpI == null){
                    continue;
                }
            }
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setBody('La richiesta di pagamento per il'+' '+woli.XC_InternalID__c+' '+'relativa al'+' '+woli.WorkOrder.Account.Name+' '+'è stata respinta.');
            notification.setTitle('Woli Status is Refused');
            notification.setSenderId(Userinfo.getUserId());
            notification.setNotificationTypeId(typNotify?.get(0).Id);
            notification.setTargetId(woli.id);  
            if(!Test.isRunningTest()){
                notification.send(new Set<String>{lastpI.LastActorId}); 
            }
        }
        return;
    }
}