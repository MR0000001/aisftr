/** 
* @author Daniele Lico
* @date Creation 03/07/2020
* @date Modification 12/06/2020 
* @description Apex Class to assign Provider's SR to WO
*/ 

public without sharing class XC_TR_WorkOrder_U_AssignSRProv {

    /** 
    * @author Daniele Lico
    * @date Creation 03/07/2020
    * @description method insertSRtoProvider 
    * @param mapNew map <id, WorkOrder>
    */ 
  
  
    public static void insertSRtoProvider(map <id, WorkOrder> mapNew) {
  
              
        Set<id> idWo = new Set<id>();
        List<ResourcePreference> listadd = new  List<ResourcePreference>();
              
  
        idWo = populateSetId(mapNew);
          
        List<WorkOrder> liwo =retrieveWorkOrder(idWo);
        
        Set<String> idAcc = new Set<String>(XC_UTIL_Sobject.getListFieldValues(liwo, 'XC_PreferredPartner__c'));
              
  
        List<ServiceResource> serv =retrieveListServiceResource(idAcc);

        System.debug('XC_TR_WorkOrder_U_AssignSRProv serv ' + serv);

        Map<id,List<ServiceResource>> accountSRMap = new Map<id,List<ServiceResource>>();
              
        for(ServiceResource sr : serv){
            if(accountSRMap.get(sr.AccountId)==null){
                accountSRMap.put(sr.AccountId,new List<ServiceResource>());
            }
            accountSRMap.get(sr.AccountId).add(sr);
        }
  
        System.debug('XC_TR_WorkOrder_U_AssignSRProv accountSRMap ' + accountSRMap);
  
        for(WorkOrder wo : liwo){
            List<ServiceResource> woRes = accountSRMap.get(wo.XC_PreferredPartner__c);
            if(woRes!=null){
                for(ServiceResource sr : woRes){
                    if(sr.IsActive){
                        // create Preference resourse resources
                        ResourcePreference re = new ResourcePreference();
                        re.RelatedRecordId = wo.id;
                        re.PreferenceType = 'REQUIRED';
                        re.ServiceResourceId = sr.id;
                        listadd.add(re);
                    }
                }
            }
        }
        System.debug('XC_TR_WorkOrder_U_AssignSRProv listadd ' + listadd);
  
        XC_UTIL_Sobject.insertListRecords( listadd);

        //DeAv 23.03.2022 CR775 START
        Map<Id,WorkOrder> woMap=new Map<id,WorkOrder>([SELECT Id,WorkOrderNumber,XC_FaultType__c,Case.Origin,case.Reason,case.SubCause__c, case.XC_Subtype__c,case.XC_BusinessLine__c,Case.Account.Name,Case.CreatedByid,CaseId,startDate,XC_DueDate__c, Case.XC_FaultType__c, Case.Country__c,case.createdby.profile.name, //DeAv 04.04.2022 CR775 Added Case.XC_FaultType__c and Case.Country__c and Case.CreatedBy.name
                                                        (SELECT Id FROM ResourcePreferences WHERE PreferenceType='Required'),
                                                        (SELECT Id, FSL__Auto_Schedule__c, ParentRecordId, EarliestStartTime, DueDate FROM ServiceAppointments)
                                                       FROM workorder 
                                                       WHERE ( Id IN: liwo AND
                                                               xc_worktypecategory__c='Malfunctioning' AND 
                                                               (XC_Segment__c='B2B' OR XC_Segment__c ='B2G') 
                                                         )]); 
        if(!woMap.isEmpty()){
            Boolean autoScheduled;
            List<CustomNotificationType> cnt =[SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='FieldUpdateNotification'];
            List<ServiceAppointment> servAppToUpdate = new List<ServiceAppointment>();
            for(WorkOrder wo : womap.values()){
                List<ResourcePreference> resPrefList = womap.get(wo.id).ResourcePreferences;
                System.debug('@@@resPrefList'+resPrefList);
                List<ServiceAppointment> servAppList = womap.get(wo.id).ServiceAppointments;
                System.debug('@@@resPreservAppListfList'+servAppList);              
                for(ServiceAppointment sa : servAppList){
                    autoScheduled = true;
                    if(woMap.get(sa.ParentRecordId)!= Null && resPrefList.isEmpty() && wo.case.Reason=='XCMOT002' && wo.case.SubCause__c=='ATCL003'&& wo.case.XC_Subtype__c=='XC199' && wo.case.XC_BusinessLine__c=='eCity' && wo.Case.Country__c == 'Italy'){ //DeAv 04.04.2022 CR775 Added filter Country
                        //sa.FSL__Auto_Schedule__c=false; 
                        autoScheduled = false; 
                        System.debug('@@@autoScheduled'+autoScheduled);
                    }

                    if(!autoScheduled && (wo.case.createdby.profile.name=='XC_ITA_B2BG_CaringAgent'|| wo.case.createdby.profile.name=='XC_ITA_B2BG_CaringSupervisor'|| wo.case.createdby.profile.name=='XC_ITA_B2BG_MSP_CaringAgent'|| wo.case.createdby.profile.name=='XC_ITA_ProjectManager')){//VDB 05.04.2022 CR775 Added condition wo.Case.CreatedBy.name
                        Messaging.CustomNotification notification = new Messaging.CustomNotification();
                        notification.setTitle(Label.XC_CL_Title_Notification_Appoiment);
                        notification.setBody(Label.XC_CL_BodyNotification_Appoiment+' '+wo.WorkOrderNumber+' '+Label.XC_CL_BodySlaNotification+' '+ wo.Case.XC_FaultType__c +' '+ Label.XC_CL_BodyNotificationSlaOpen+' '+ wo.Case.Account.Name);
                        notification.setSenderId(Userinfo.getUserId());
                        notification.setNotificationTypeId(cnt?.get(0).Id );
                        notification.setTargetId(wo.CaseId);                     
                        notification.send(new Set<String>{wo.Case.CreatedByid});
                        System.debug('@@@notification'+notification);
                    }

                    if(woMap.get(sa.ParentRecordId)!= null && autoScheduled){
                        sa.FSL__Auto_Schedule__c=true;
                        //sa.EarliestStartTime = woMap.get(sa.ParentRecordId).startDate;
                        //sa.DueDate = woMap.get(sa.ParentRecordId).XC_DueDate__c;
                        servAppToUpdate.add(sa);
                        System.debug('Service Appointment'+ sa);
                        System.debug('Service Appointment Auto Schedule'+ sa.FSL__Auto_Schedule__c);
                    }
                } 
            }       

            if(!servAppToUpdate.isEmpty()){
                XC_UTIL_Sobject.updateListRecords(servAppToUpdate);    
            }
        }
        //DeAv 23.03.2022 CR775 END
    }
    
    /** 
    * @author Daniele Lico
    * @date Creation 03/07/2020
    * @description method updateSRtoProvider
    * @param mapNew map <id, WorkOrder>
    * @param mapOld map <id, WorkOrder>
    */ 
  
      public static void updateSRtoProvider(map <id, WorkOrder> mapNew, map <id, WorkOrder> mapOld){
  
          List<ResourcePreference> listdel = new  List<ResourcePreference>();
          Set<id> idWo = new Set<id>();
  
          for(WorkOrder w : mapNew.values()){
                  if((w.XC_PreferredPartner__c != mapOld.get(w.id).XC_PreferredPartner__c)){
                  idWo.add(w.id);
                  }
              }
          Map<id, WorkOrder> mapLiwo = new Map<id, WorkOrder>();
          if(!idWo.isEmpty()) {
               mapLiwo.putAll([
                      SELECT id, XC_PreferredPartner__c
                      FROM WorkOrder
                      WHERE id IN :idWo
              ]);
          }
          
  
          List<ResourcePreference> servPref=retrieveResourcePref(idWo);
  
          for(WorkOrder w : mapLiwo.values() ){
              if(w.XC_PreferredPartner__c != mapOld.get(w.id).XC_PreferredPartner__c){
                  for(ResourcePreference pr :  servPref){
                  
                  listdel.add(pr);
  
  
                  }
              }
          }
  
  
  
          XC_UTIL_Sobject.deleteListRecords( listdel);
          insertSRtoProvider(mapLiwo);
      } 
      /** 
      * @author Daniele Lico
      * @date Creation 03/07/2020
      * @description method updateSRtoProvider
      * @param idWo
      * @return List WorkOrder
      */    
      private static  List<WorkOrder> retrieveWorkOrder(Set<id> idWo ){
          List<WorkOrder> liwo = new List<WorkOrder>();
          if(!idWo.isEmpty() && Schema.sObjectType.WorkOrder.isAccessible()){
              liwo = [SELECT id,  XC_PreferredPartner__c
                                      FROM WorkOrder
                                      WHERE id IN : idWo
                                      AND XC_PreferredPartner__c != null];
          }
          return liwo;
      }
      /** 
      * @author Daniele Lico
      * @date Creation 03/07/2020
      * @description method retrieve Service Resources
      * @param idAcc
      * @return List ServiceResource
      */ 
      private static List<ServiceResource> retrieveListServiceResource(Set<String> idAcc){
          List<ServiceResource> serv = new List<ServiceResource>();
          if(!idAcc.isEmpty() &&  Schema.sObjectType.ServiceResource.isAccessible()){
              serv = [SELECT id, Name, AccountId, IsActive
                                              FROM ServiceResource
                                              WHERE AccountId IN : idAcc and ResourceType != 'D'];
          }
          return serv;
      }
      /** 
      * @author Daniele Lico
      * @date Creation 03/07/2020
      * @description method retrieve ResourcePreference
      * @param idWo
      * @return List ResourcePreference
      */ 
      private static List<ResourcePreference> retrieveResourcePref(Set<id> idWo){
          List<ResourcePreference> servPref = new List<ResourcePreference>();
          if(!idWo.isEmpty() && Schema.sObjectType.ResourcePreference.isAccessible()){
              servPref=[SELECT id, RelatedRecordId
                                          FROM ResourcePreference
                                              WHERE RelatedRecordId IN : idWo];
          }
      return servPref;
      }
  /*	/**
   * @author Daniele Lico
   * @date Creation 03/07/2020
   * @description method updateSRtoProvider
   * @param mapNew map <id, WorkOrder>
   * @return idWo Set<Id>
   */
      private static Set<Id> populateSetId(Map<id, WorkOrder> mapNew){
          Set<Id> idWo = new Set<Id>();
          for(WorkOrder w : mapNew.values()){
              //if(w.XC_SourceWO__c == Constants.WO_SOURCEPROJ || w.XC_ProvisioningWO__c == true){
                  idWo.add(w.id);
             //}
          }
          return idWo;
      }
  
  
  }