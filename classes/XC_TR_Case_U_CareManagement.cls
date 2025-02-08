/**
  * @author Monica Cutillo - monica.cutillo@nttdata.com
  * @date Creation 12/02/2019
  * @date Modification dd/mm/yyyy
  * @description XC_TR_ServiceApp_U_CaringManagement – Manage Case creation depending on Service Appointment update
  * @LastModifiedBy Federico Amici - 13/03/2019 - Added the custom metadata retrieve
  */
  public without sharing class XC_TR_Case_U_CareManagement {
      private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Case_Handler');
      
      /** 
       * @description Manage case status on insert.
       * @param listNew the list new
       */
      /*public static void manageCaseStatusOnInsert(List<Case> listNew){
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in manageCaseStatusOnInsert for Case');
          //search case open with phader case
          List<Case> casesWithParent = new List<Case>();
          for(Case caso : listNew){
              if(caso.Status == Label.XC_CL_Case_Open && caso.ParentId != null && XC_UTIL_Sobject.getObjectType(caso.OwnerId) == 'User'){
                  casesWithParent.add(caso);
              }
          }
          if(!casesWithParent.isEmpty()){
              parentCaseStatusSetAndRemovePending(casesWithParent);
          }
      }*/
      
      /** 
       * @description Manage case status on update.
       * @param listNew the list new
       * @param mapOld the map old
       * @param mapNew the map new
       */
      public static void manageCaseStatusOnUpdate(List<Case> listNew, Map<Id,Case> mapOld, Map<Id,Case> mapNew){
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in manageCaseStatusOnUpdate for Case');
          List<String> fieldList = new List<String>{'Status','OwnerId'};
          List<Case> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
          if(!listChanged.isEmpty()){
              parentCaseStatusSetAndRemovePending(listChanged);
          }
          //ONLY Status changes
          fieldList = new List<String>{'Status'};
          listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
          if(!listChanged.isEmpty()){
              checkAndSendCloseCaseNotifications(listChanged);
              setDisalignmentWithZuoraForCaseClosed(listChanged);
          }
      }
  
      /**
       * @author Giuseppe Di Bonito - gdibonito@deloitte.it
       * @date Creation 06/11/2019
       * @description Create customer interaction case closed for case open closed on case after insert
       * @param listNew the list new
       */
      public static void createCiCaseClosedOnAfterInsertCase(List<Case> listNew){
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in createCiCaseClosedOnAfterInsertCase for Case');
          if(!listNew.isEmpty()){
              checkAndSendCloseCaseNotifications(listNew);
              setDisalignmentWithZuoraForCaseClosed(listNew);
          }
      }
      
      /**
       * @description Parent case status set and remove pending.
       * @param listNew the list new
       */
      public static void parentCaseStatusSetAndRemovePending(List<Case> listNew) {
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in parentCaseStatusSetAndRemovePending for Case');
          List<Case> caseParentToUpdate = new List<Case>();
          List<String> listParentIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'ParentId');
          
          Map<Id,Case> mapParentCases = new Map<Id,Case>([SELECT id, Status,OwnerId,XC_Segment__c FROM Case WHERE Id IN: listParentIds]);
          
          for(Case caso : listNew){
              if (caso.ParentId!=null){
                  Case c = mapParentCases.get(caso.ParentId);
                  if(c.XC_Segment__c=='B2C'){
                    if(checkCond1(caso,c) ){
                        changeStatusCaseToInProgress(c); 
                        caseParentToUpdate.add(c);
                    }else if(checkCond2(caso,c))   {
                        changeStatusCaseFromInProgress(c);
                        caseParentToUpdate.add(c); 
                    } 
                }
            } 
          }
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'caseParentToUpdate=' + caseParentToUpdate);
          List<XC_UTIL_Sobject.WrapperResult> dmlResult = XC_UTIL_Sobject.updateListRecords(caseParentToUpdate);
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'dmlResult=' + dmlResult);
      }
  
      /**
       * @description changeStatusCaseFromInProgress
       * @param c
       */
      private static void changeStatusCaseFromInProgress(Case c){
          if(c.Status.equals(Label.XC_CL_Case_InProgress)){
              c.Status = Label.XC_CL_Case_Pending; //XC_AT_Constants.TRIGGER_STATUS_ESTA002
              //c.XC_WithCaseChildren__c = true;
          }
      }
  
      /**
       * @description changeStatusCaseToInProgress
       * @param c
       */
      private static void changeStatusCaseToInProgress(Case c){
          if(c.Status.equals(Label.XC_CL_Case_Pending)){ //XC_AT_Constants.TRIGGER_STATUS_ESTA002
              c.Status = Label.XC_CL_Case_InProgress;
          }
      }
  
      /**
       * @description Check this condition.
       * @param caso the New Case
       * @param c the Parent Case
       * @return
       */
       public static boolean checkCond1(Case caso, Case c){
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Case_U_CareManagement - checkCond1');
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso.Status =' + caso.Status);
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso.OwnerId =' + caso.OwnerId);
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'Parent: c.OwnerId =' + c.OwnerId);
          if(caso.Status!=null && caso.OwnerId!=c.OwnerId && (caso.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA007) || caso.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA008) )){
              return true;
          }
          return false;
      }
  
  
      /**
       * @description Check this condition.
       * @param caso the New Case
       * @param c the Parent Case
       * @return
       */
       public static boolean checkCond2(Case caso, Case c){
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Case_U_CareManagement - checkCond2');
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso.Status =' + caso.Status);
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso.OwnerId =' + caso.OwnerId);
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'Parent: c.OwnerId =' + c.OwnerId);
          if(caso.Status!=null && caso.OwnerId!=c.OwnerId && !caso.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA007) && !caso.Status.equals(XC_AT_Constants.TRIGGER_STATUS_ESTA008) ){
              return true;
          }
          return false;
          }
      
      /**
       * Manage activity on owner changing.
       *
       * @author Monica Cutillo - monica.cutillo@nttdata.com
       * @param listNew the list new
       * @param mapOld the map old
       * @param mapNew the map new
       * @date 11/02/2019
       * @description When a Case in status 'Open' is assigned from a queue to an user,
       * is status have to change to 'In Progress'
       */
      public static void manageActivityOnOwnerChanging(List<Case> listNew, Map<Id,Case> mapOld, Map<Id,Case> mapNew){
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Case_U_CareManagement - manageActivityOnOwnerChanging');
          List<String> fieldList = new List<String>{'OwnerId'};
              List<Case> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);
          if(listChanged.isEmpty()){
              return;
          }
          
          sendNotificationForOwnerAssignment(listNew,mapOld,mapNew);
      }
      
      /**  
       * @author Monica Cutillo - monica.cutillo@nttdata.com
       * @param listNew the list new
       * @param mapOld the map old
       * @param mapNew the map new
       * @date 11/02/2019
       * @description When a Case in status 'Open' is assigned from a queue to an user,
       * is status have to change to 'In Progress'
       */
      /*public static void makeInProgressWhenAssigned(List<Case> listNew, Map<Id,Case> mapOld, Map<Id,Case> mapNew){
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Case_U_CareManagement - makeInProgressWhenAssigned');
          List<Case> casesToUpdate = new List<Case>();
          Case caseToUpdate = new Case();
  
          for(Case newCase : listNew){
              if(newCase.Status != Label.XC_CL_Case_Open){
                  continue; //return ??? MC 02/09/2019
              }
              
              Case oldCase = mapOld.get(newCase.Id);
              XC_UTIL_Debug.debug(DEBUGACTIVE, 'newCase.OwnerId=' + newCase.OwnerId);
              if(XC_UTIL_Sobject.getObjectType(newCase.OwnerId) == 'User'){ // && XC_UTIL_Sobject.getObjectType(oldCase.OwnerId) != 'User'){
                  XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ Change Owner from Group to User > change status from open to In Progress on caseId = ' + newCase.Id);
                  caseToUpdate.Id = newCase.Id;
                  caseToUpdate.Status = Label.XC_CL_Case_InProgress;
                  casesToUpdate.add(caseToUpdate);
              }
          }
          if(!casesToUpdate.isEmpty()){
              XC_UTIL_Sobject.updateListRecords(casesToUpdate);
          }
      }*/
      
      /**
       * @author Monica Cutillo - monica.cutillo@nttdata.com
       * @param listNew the list new
       * @date 26/07/2019
       * @description Chack and Send notification Close_Case
       */
      public static void checkAndSendCloseCaseNotifications(List<Case> listNew){
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Case_U_CareManagement - checkAndSendCloseCaseNotifications');
          //Map<String, XC_CM_Case_Type_Setting__mdt> caseSettings = getContractCancellationAfterDunningTypes();
          //send notification only if the new Status is Close or Canceled and Origin is 'CAN001' (No for eMobility)
          Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{Label.XC_CL_SuperBonus110});
          List<Case> casesClosedToNotify = new List<Case>();
          List<String> casesClosedIds = new List<String>();
          List<Case> casesFinancialToNotify = new List<Case>();
          List<String> casesFinancialIds = new List<String>();
          List<Case> closureSuperbonus110ToNotify = new List<Case>();
          Set<Id> ids = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'ContactId');
          Map<Id,Contact> contacts = retriveContactsNotificationInfo(ids);
          List<Map<String,Object>> notifies = new List<Map<String,Object>>();
  
        for(Case newCase : listNew){
            Set<String> legalEntityToExclude = new Set<String>{'EnelXItalia', 'EnelXMobility', 'YouSaveSpA', 'ESCoComuniSrl', 'Cogenio', 'EnelXMSP', 'EnelSole'};
            Boolean checkITAB2B = ((newCase.XC_Segment__c == 'B2B' || newCase.XC_Segment__c == 'B2G') && (legalEntityToExclude.contains(newCase.XC_LegalEntity__c)));
            if(checkITAB2B){
                continue;
            }
            if(newCase.Status == Label.XC_CL_Case_Status007 && newCase.XC_Resolution__c == 'R002' && newCase.XC_Result__c == 'RS004' &&
               !caseSettingsMap.isEmpty() && XC_UTIL_Case.matchSettings(newCase, caseSettingsMap.get(Label.XC_CL_SuperBonus110))){
                closureSuperbonus110ToNotify.add(newCase);
            }
            else if ((newCase.Origin == Label.XC_CL_Case_InsistenciaOrigin && newCase.XC_OriginChannel__c != 'App eMobility' &&
                 (newCase.Status == Label.XC_CL_Case_Status007 || newCase.Status == Label.XC_CL_Case_Status008)) /*|| 
                 (checkCaseSettingsDunningCancellation(newCase, caseSettings) &&
                 (newCase.Status == Label.XC_CL_Case_Status007))*/){
                  casesClosedToNotify.add(newCase);
                  casesClosedIds.add(newCase.Id);
            }
            else if (newCase.Status == Label.XC_CL_Case_Status007 &&
                 newCase.Reason == Label.XC_CL_CaseReason_XCMOT007 &&
                 newCase.SubCause__c == 'ATCL045' &&
                 !String.isblank(newCase.XC_Order__c)){
                  casesFinancialToNotify.add(newCase);
                  casesFinancialIds.add(newCase.Id);
            }
        }
          //Case_Closed and Survey_Post_Repair
          if(!casesClosedToNotify.isEmpty()){
              for(Case newCase : casesClosedToNotify){
                  notifies.add(createValueMap(newCase,contacts.get(newCase.ContactId), 'Case_Closed'));
              }
              List<Map<String,Object>> notifiesCiPostRepair = XC_UTIL_CustomerInteractionGeneration_UU.generateCustIntSurveyPostRepair(casesClosedIds);
              notifies.addAll(notifiesCiPostRepair);
          }
          //ExternalFinancing_Result
          if(!casesFinancialToNotify.isEmpty()){
              Map<Id,Case> mapCaseDetail = new Map<Id,Case>([SELECT id, XC_Order__r.XC_FinancialPracticeStatus__c FROM Case WHERE Id IN: casesFinancialIds]);
              for(Case newCase :casesFinancialToNotify){
                  if(mapCaseDetail.get(newCase.Id).XC_Order__r.XC_FinancialPracticeStatus__c == 'OK' ||
                     mapCaseDetail.get(newCase.Id).XC_Order__r.XC_FinancialPracticeStatus__c == 'KO'){
                      notifies.add(createCiExternalFinancingResult(newCase, contacts.get(newCase.ContactId)));
                  }
              }
          }
          //Superbonus 110 notify
          if(!closureSuperbonus110ToNotify.isEmpty()){
            for(Case newCase : closureSuperbonus110ToNotify){
                Map<String,Object> notifyData = createValueMap(newCase, contacts.get(newCase.ContactId), 'Superbonus_KO');
                if(!notifyData.isEmpty()){
                    notifies.add(notifyData);
                }
            }
          }
          
          if(notifies.isEmpty()){
              return;
          }
  
          List<XC_UTIL_Sobject.WrapperResult> res = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases(notifies);
          for(XC_UTIL_Sobject.WrapperResult r : res){
              if(!r.success){
                  System.debug('@@check wrapper: ');
                  System.debug(r.errorMessage);
              } else {
                  System.debug('@@else');
              }
          }
      }
      
      /**
       * Send notification for owner assignment.
       *
       * @author Monica Cutillo - monica.cutillo@nttdata.com
       * @param listNew the list new
       * @param mapOld the map old
       * @param mapNew the map new
       * @date 12/02/2019
       * @description On Owner changing, it insert specific CustomerIntegration
       */
      public static void sendNotificationForOwnerAssignment(List<Case> listNew, Map<Id,Case> mapOld, Map<Id,Case> mapNew){
          XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Case_U_CareManagement - sendNotificationForOwnerAssignment');
          //send notification only if the new owner isn't a Group
          List<Case> casesToNotify = new List<Case>();
          for(Case newCase : listNew){
              if(XC_UTIL_Sobject.getObjectType(newCase.OwnerId) == 'User'){
                  casesToNotify.add(newCase);
              }
          }
          if(casesToNotify.isEmpty()){
              return;
          }
          
          Set<Id> usersId = XC_UTIL_Sobject.getSetIdsOnField(casesToNotify, 'OwnerId');
          Map<Id,User> users = retriveUsersNotificationInfo(usersId);
          List<Map<String,Object>> notifies = new List<Map<String,Object>>();
          
          for(Case newCase : casesToNotify){
              notifies.add(createValueMap(newCase,users.get(newCase.OwnerId)));
          }
          XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromCases(notifies);
      }
      
      /**
       * Creates the value map.
       *
       * @author Monica Cutillo - monica.cutillo@nttdata.com
       * @param caseObj the case obj
       * @param user the user
       * @return the map
       * @date 12/02/2019
       * @description Prepare the map for CustomerIntegration creation
       */
      private static Map<String,Object> createValueMap(Case caseObj, User user){
          Map<String,Object> data = new Map<String,Object>();
          data.put('customerType', 'Case_Created_SR_Email');
          data.put('skipComunication', false);
          data.put('caseId', caseObj.Id);
          data.put('fullName', user.Name);
          data.put('email', user.Email);
          data.put('legalEntity', caseObj.XC_LegalEntity__c);
          if(caseObj.ContactId != null){
              data.put('contactId', caseObj.ContactId);
          }
          if(caseObj.AccountId != null){
              data.put('accountId', caseObj.AccountId);
          }
          return data;
      }
      
      /**
       * @author Monica Cutillo - monica.cutillo@nttdata.com
       * @param caseObj the case obj
       * @param contact the contact obj
       * @param communicationType the contact obj
       * @return the map
       * @date 26/07/2019
       * @description Prepare the map for CustomerIntegration creation
       */
      private static Map<String,Object> createValueMap(Case caseObj, Contact contact, String communicationType){
            if(communicationType == 'Superbonus_KO' && String.isBlank(contact.Email)){
                new Map<String,Object>();
            }
            Map<String,Object> data = new Map<String,Object>();
            data.put('customerType', communicationType);
            data.put('skipComunication', false);
            data.put('caseId', caseObj.Id);
            data.put('fullName', contact.Name);
            data.put('email', contact.Email);
            data.put('preferredlanguage', contact.XC_Preferredlanguageofcontact__c);
            data.put('contactId', caseObj.ContactId);
            data.put('legalEntity', caseObj.XC_LegalEntity__c);
            data.put('accountId', caseObj.AccountId);
            data.put('segment', contact.XC_Segment__c);
            return data;
      }
  
      /**
       * @author Giuseppe Di Bonito - gdibonito@deloitte.it
       * @param caseObj the case obj
       * @param contact the contact obj
       * @return the map
       * @date 18/08/2020
       * @description Prepare the map for the creation of the Customer Interaction 'ExternalFinancing_Result'
       */
      @TestVisible
      private static Map<String,Object> createCiExternalFinancingResult(Case caseObj, Contact contact){
          Map<String,Object> data = new Map<String,Object>();
          data.put('customerType', 'ExternalFinancing_Result');
          data.put('skipComunication', false);
          data.put('caseId', caseObj.Id);
          data.put('fullName', contact.Name);
          data.put('email', contact.Email);
          data.put('contactId', caseObj.ContactId);
          data.put('legalEntity', caseObj.XC_LegalEntity__c);
          data.put('accountId', caseObj.AccountId);
          data.put('segment', caseObj.XC_Segment__c);
          data.put('orderId', caseObj.XC_Order__c);
          return data;
      }
      
      /**
       * Retrive users notification info.
       *
       * @author Monica Cutillo - monica.cutillo@nttdata.com
       * @param usersId the users id
       * @return the map
       * @date 13/02/2019
       * @description Retrive User info from the Ids in input and return a map with Id and User Obj populated
       */
      private static Map<Id,User> retriveUsersNotificationInfo(Set<Id> usersId){
          Map<Id,User> result = new Map<Id,User>();
          Map<Id,User> usersMap = new  Map<Id,User>([SELECT Id, Name, Email FROM User WHERE Id IN: usersId]);
          List<User> users = usersMap.values();
          for(User  user: users){
              result.put(user.Id, user);
          }
          return result;
      }
      
      /**
       * @author Monica Cutillo - monica.cutillo@nttdata.com
       * @param ids the contacts id
       * @return the data map
       * @date 26/07/2019
       * @description Retrive Contacts info from the Ids in input and return a map with Id and Contact Obj populated
       */
      private static Map<Id,Contact> retriveContactsNotificationInfo(Set<Id> ids){
          return new Map<Id,Contact>([SELECT Id, Name, Email, XC_Preferredlanguageofcontact__c,XC_Segment__c FROM Contact WHERE Id IN: ids]);
      }
  
  
      /**
       * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
       * @param caseList the case list
       * @date 11/10/2019
       * @description 
       */
      private static void setDisalignmentWithZuoraForCaseClosed(List<Case> caseList) {
          
          Map<String, XC_CM_Case_Type_Setting__mdt> caseTypeSettings = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{'XC_DisalignmentZuoraContact'});
          List<Contact> contactsToUpdate = new List<Contact>();
          for(Case c : caseList) {
              if(c.Status == XC_AT_Constants.TRIGGER_STATUS_ESTA007 && XC_TR_Contact_U_CaringManagementCond.checkCond4(c.ContactId, c, caseTypeSettings.get('XC_DisalignmentZuoraContact'))) {
                  contactsToUpdate.add(new Contact(Id = c.ContactId, XC_Dealignment_with_Zuora__c = false));
              }
          }
  
          XC_UTIL_SObject.updateListRecords(contactsToUpdate);
      }
      private static Map<String, XC_CM_Case_Type_Setting__mdt> getContractCancellationAfterDunningTypes (){
          List<String> caseSettingNames = new List<String>{Label.XC_CL_AssetSuspension_SSII, Label.XC_CL_eMobility_DisconnectZuoraDunning, Label.XC_CL_CMD_AssetSuspension};
          Map<String, XC_CM_Case_Type_Setting__mdt> caseSettingsMap = XC_UTIL_Case.retriveCaseTypeSettings(caseSettingNames);
          if(caseSettingsMap.isEmpty() || caseSettingsMap.get(Label.XC_CL_AssetSuspension_SSII)==null || caseSettingsMap.get(Label.XC_CL_eMobility_DisconnectZuoraDunning)==null || caseSettingsMap.get(Label.XC_CL_CMD_AssetSuspension)==null){
              XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@ No Match on XC_CM_Case_Type_Setting__mdt with settingName= getContractCancellationAfterDunningTypes');
          }
  
          return caseSettingsMap;
      }
  
      private static Boolean checkCaseSettingsDunningCancellation (Case newCase, Map<String, XC_CM_Case_Type_Setting__mdt> caseSettings){
          for(XC_CM_Case_Type_Setting__mdt mdt : caseSettings.values()){
              if(XC_UTIL_Case.matchSettings(newCase, mdt)){
                  return true;
              }
          }
          return false;
      }
  }