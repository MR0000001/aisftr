/**
* @author Valentina De Blasio - valentina.de.blasio@accenture.com
* @date Creation 04/05/2022
* @description XC_TR_GenericNotificatio generic class notification cr 729 
*mapping field
requestType-->woli.XC_RequestType__c 
accountName-->woli.XC_AccountId__r.name
signatureStatus-->wo.Status
woOwnerId-->wo.OwnerId o wo.XC_AssignedResource__c
internalId-->wo.XC_InternalID__c
signatureStatus-->parametro input*/


public without sharing class XC_TR_GenericNotification {

    public static void notifyUsers(String requestType,String accountName,String signatureStatus, Set<String> Owners,String internalId,String targetId) {

        CustomNotificationType notificationType =[SELECT id,customNotifTypeName FROM CustomNotificationType  WHERE DeveloperName='FieldUpdateNotification'];

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(Label.XC_NewNotification);
        if(requestType=='Sospensione'||requestType=='Proroga'||requestType=='Ripresa'){
          notification.setBody(Label.XC_Ed_Notification+' '+requestType+' '+Label.XC_Request+' '+internalId+' '+Label.XC_Notification_For+' '+accountName+' '+Label.XC_Notification_Status+' '+signatureStatus);          
        }
        if(requestType=='Documento di ingaggio'){
          notification.setBody(Label.XC_Ed_NotificationDi+' '+requestType+' '+Label.XC_RequestDi+' '+internalId+' '+Label.XC_Notification_For+' '+accountName+' '+Label.XC_Notification_Status+' '+signatureStatus);          
        }
          notification.setSenderId(Userinfo.getUserId());          
          notification.setNotificationTypeId(notificationType.Id);
          notification.setTargetId(targetId); 
          notification.send(Owners); //owner wo popolato
        }



    }