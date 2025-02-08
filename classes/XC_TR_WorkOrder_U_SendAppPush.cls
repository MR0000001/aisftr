/**
 * @File Name          : XC_TR_WorkOrder_U_SendAppPush.cls
 * @Description        : 
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 21/4/2020, 19:24:33
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    6/4/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_TR_WorkOrder_U_SendAppPush {

    public class QueueableWrapper{
        public WorkOrder wo;
        public String title;
        public String message;
        public String techId;
    }


    /**
    * @description send a notification to xinstaller on specific workorder status reason
    * @author Francesco Imperioli - fimperioli@deloitte.it | 6/4/2020 
    * @param listNew 
    * @param mapOld 
    * @return void 
    **/
    public static void sendPushNotificationOnWoReason(List<WorkOrder> listNew,Map<Id,WorkOrder> mapOld,Map<Id,WorkOrder> mapNew){

        List<String> fieldList = new List<String>{'XC_StatusReason__c'};
        Set<String> statusReasonFilter = new Set<String>{'To be scheduled'};
        List<WorkOrder> changedWo = XC_UTIL_Sobject.getListChanged(fieldList,mapOld,mapNew);
        Map<String,XC_CM_WorkOrderAppNotificationConfig__mdt> pushSettings = getPushNotificationSettings();

        Set<String> serviceResourcesIds = new Set<String>();
        for(WorkOrder wo : changedWo){
            if(statusReasonFilter.contains(wo.XC_StatusReason__c) &&String.isNotBlank(wo.XC_AssignedResource__c) && pushSettings.containsKey(wo.XC_LegalEntity__c)){
                serviceResourcesIds.add(wo.XC_AssignedResource__c);
            }
        }

        Map<Id,ServiceResource> srMap = new Map<Id,ServiceResource>([SELECT ID,RelatedRecordId FROM ServiceResource WHERE ID IN:serviceResourcesIds]);

        for(WorkOrder wo : changedWo){
            if(statusReasonFilter.contains(wo.XC_StatusReason__c) && String.isNotBlank(wo.XC_AssignedResource__c) && pushSettings.containsKey(wo.XC_LegalEntity__c)){
                XC_CM_WorkOrderAppNotificationConfig__mdt pushConfig = pushSettings.get(wo.XC_LegalEntity__c);
                //NB. Works only for a single WO, not for a bulk upload/update of wos
                if((Limits.getQueueableJobs()<Limits.getLimitQueueableJobs()) && pushConfig.XC_IsActive__c){
                    QueueableWrapper qw = new QueueableWrapper();
                    qw.wo = wo;
                    qw.title = pushConfig.XC_Title__c;
                    qw.message = pushConfig.XC_Text__c;
                    qw.techId = srMap.get(wo.XC_AssignedResource__c).RelatedRecordId;
                    SendAppXInstallerPushQueuable sendPushNotification = new SendAppXInstallerPushQueuable(qw);
                    System.enqueueJob(sendPushNotification);
                    break;
                }
            }
        }

    }

    public class SendAppXInstallerPushQueuable implements Queueable,Database.AllowsCallouts{

        XC_REST_UrgentWONotification.WrapperRequest pushReq = new XC_REST_UrgentWONotification.WrapperRequest();

        public sendAppXInstallerPushQueuable(QueueableWrapper qw){
            createPushNotificationReq(qw);
        }

        public void execute(QueueableContext ctx){
            XC_REST_UrgentWONotification.WrapperResult resp = !Test.isRunningTest() ? XC_REST_UrgentWONotification.callout(this.pushReq) : new XC_REST_UrgentWONotification.WrapperResult();
        }

        private void createPushNotificationReq(QueueableWrapper qw){
            this.pushReq.TechnicianId = qw.techId;
            this.pushReq.WorkOrderNumber = qw.wo.WorkOrderNumber;
            this.pushReq.IsUrgent = false;
            this.pushReq.Title = qw.title;
            this.pushReq.Message = qw.message + ' ' + qw.wo.WorkOrderNumber;
        }

    }


    /**
    * @description retrieves configuration for push notification text based on wo legalEntity
    * @author Francesco Imperioli - fimperioli@deloitte.it | 6/4/2020 
    * @return Map<String, XC_CM_WorkOrderAppNotificationConfig__mdt> 
    **/
    private static Map<String,XC_CM_WorkOrderAppNotificationConfig__mdt> getPushNotificationSettings(){
        Map<String,XC_CM_WorkOrderAppNotificationConfig__mdt> result = new Map<String,XC_CM_WorkOrderAppNotificationConfig__mdt>();

        for(XC_CM_WorkOrderAppNotificationConfig__mdt pushConfig : 
        [SELECT Id,DeveloperName,XC_LegalEntity__c,XC_Title__c,XC_Text__c,XC_IsActive__c FROM XC_CM_WorkOrderAppNotificationConfig__mdt]){
            result.put(pushConfig.XC_LegalEntity__c,pushConfig);
        }
        return result;
    }

}