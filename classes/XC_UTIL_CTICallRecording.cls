/**
 * @author francesco imperioli - fimperioli@deloitte.it
 * @description: manages operations for the XCUSTOMER Genesys recording Modules - invoked by gl_workspaceConnectorController
 * @testclass: XC_UTIL_CTICallRecording_TEST
 * @createddate 2020-02-18
 */

public without sharing class XC_UTIL_CTICallRecording {


    public static final Set<String> orderInProgressStatuses = new Set<String>{'Draft','In Progress'};

    /**
     * @author francesco imperioli - fimperioli@deloitte.it
     * @description generate JSON message that has to be sent to WDE Phone bar to start/stop recording recording
     * @createddate 2020-02-18
     */
    public static Map<String,Object> generateRecordingMessage(Map<String,Object> genesysParams,String mode){

        System.Debug('ENTERED UTIL CTI RECORDING generateRecordingMessage WITH PARAMS ' + genesysParams );

        String event = mode.equalsIgnoreCase('START') ? 'StartRecording' : 'StopRecording';
        //CI is the connection identifier for genesys session
        String CI = String.valueOf(genesysParams.get('CI_connectionData')).split(':')[1].replace('"','');

        //generating object structure
        Map<String,Object> result = new Map<String,Object>();
        Map<String,Object> message = new Map<String,Object>();
        Map<String,Object> userData = new Map<String,Object>();
        Map<String,Object> usrData = new Map<String,Object>();

        List<XC_CTI_Interaction__c> currentInteractionList = [SELECT ID,XC_InteractionStatus__c,XC_Connection_ID__c 
        FROM XC_CTI_Interaction__c 
        WHERE CreatedById=:UserInfo.getUserId() 
        AND XC_InteractionStatus__c = 'Open'
        AND XC_Connection_ID__c != null
        ORDER BY CreatedDate DESC LIMIT 1];

        if(currentInteractionList.isEmpty()){
            result.put('success',false);
        }else{

            XC_CTI_Interaction__c currentOpenInteraction = currentInteractionList[0];
            //populating result
            result.put('success',true);
            //populating message complex structure
            message.put('action','AttachData');
            message.put('CI',CI);

            //populating user data
            userData.put('AzioneCustom','PerformWDERequest');
            userData.put('Evento',event); 

            if(mode.equalsIgnoreCase('START')){

                userData.put('ID_RECORDING',String.valueOf(DateTime.now().getTime()));
                //populating usrData extension
                usrData.put('ConnID',currentOpenInteraction.XC_Connection_ID__c);
                userData.put('usrData',usrData);
            }

            //populating message with user data
            message.put('userData',userData);
            result.put('message',message);

        }


        return result;
    }

    /**
     * @author Francesco Imperioli - fimperioli@deloitte.it
     * @description manage completed call recording saving link as detail record of CTI Interaction Object
     * @createddate 2020-02-18
     */

     public static Map<String,Object> manageInboundRecordingMessage(Map<String,Object> genesysParams){

        Map<String,Object> result = new Map<String,Object>();

        String recordingUrl = String.valueOf(genesysParams.get('recUrl'));
        String recordingDuration = String.valueOf(genesysParams.get('recDuration'));
        String recordingId = String.valueOf(genesysParams.get('recId'));
        String connId = String.valueOf(genesysParams.get('connId'));
        String contextRecId = String.valueOf(genesysParams.get('contextRecordId'));
        String extContextRecId = String.valueOf(genesysParams.get('extContextRecordId'));


        List<XC_CTI_Interaction__c> connectedInteractions = [SELECT ID,XC_CaseId__c,XC_AccountId__c FROM XC_CTI_Interaction__c WHERE XC_Connection_ID__c = :connId AND CreatedById = :UserInfo.getUserId() LIMIT 1];

        if(connectedInteractions.isEmpty()){
            result.put('success',false);
        }else{
            XC_CTI_Interaction__c currentInteraction = connectedInteractions[0];
            //check if recording has been made during an order
            String contextSobjectType = String.isNotBlank(contextRecId) ? XC_UTIL_SObject.getObjectType(contextRecId) : '';
            //list of related objects to update

            XC_CTICallRecording__c recording = new XC_CTICallRecording__c(
                XC_CTIInteractionId__c = currentInteraction.Id,
                XC_RecordingUrl__c = recordingUrl,
                XC_RecordingID__c = recordingId
            );



            if(String.isBlank(contextSobjectType) && String.isNotBlank(extContextRecId)){
                //recording called by a external component, check sObjecType manually via ID
                String extObjectType = XC_UTIL_Sobject.getObjectType(extContextRecId);
                contextRecId = extContextRecId;
                contextSobjectType = extObjectType;
            }


            if(contextSobjectType.equalsIgnoreCase('NE__Order__c')){
                recording.XC_Order__c = contextRecId;
            }else if(contextSobjectType.equalsIgnoreCase('Lead')){
                recording.XC_Lead__c = contextRecId;
            }else if(contextSobjectType.equalsIgnoreCase('Case')){
                recording.XC_Case__c = contextRecId;
            }

            XC_UTIL_Sobject.WrapperResult insertResult = XC_UTIL_Sobject.insertRecord(recording);

            //Update related sobject look up with the cti call recording
            if(contextSobjectType.equalsIgnoreCase('Lead') || contextSobjectType.equalsIgnoreCase('Case')){
                SObject obj = Schema.getGlobalDescribe().get(contextSobjectType).newSObject();
                obj.put('Id',contextRecId);
                obj.put('XC_CTICallRecording__c',insertResult.recordId);
                XC_UTIL_Sobject.updateRecord(obj);
            }else if(contextSobjectType.equalsIgnoreCase('NE__Order__c')){
                //manage the vocal order contract signature
                manageVocalOrderSignature(contextRecId, insertResult.recordId);
            }

            //Manage complete recording sending another platform event with evt type 'Recording Completed'

            if(insertResult.success){
                Map<String,Object> evtParams = new Map<String,Object>();
                evtParams.put('eventType','RECCOMPLETED');
                evtParams.put('recId',insertResult.recordId);
                publishStartStopRecordingEventMessage(evtParams);
            }

            result.put('success',insertResult.success);
            result.put('recordId',insertResult.recordId);
        }

        return result;

     }


     /**
      *@author Francesco Imperioli - fimperioli@deloitte.it 
      *@description manages the start/stop recording event publish a platform event on SF
      *@createddate 2020-02-18
      */
      public static Map<String,Object> publishStartStopRecordingEventMessage(Map<String,Object> genesysParams){

        Map<String,Object> result = new Map<String,Object>();

        //mapping parameters incoming from CTI Library Extension
        String evtType = String.valueOf(genesysParams.get('eventType'));
        String interactionConnId = genesysParams.containsKey('connId') ? String.valueOf(genesysParams.get('connId')) : '';
        String recordingId = genesysParams.containsKey('recId') ? String.valueOf(genesysParams.get('recId')) : '';
        String contextRecId = genesysParams.containsKey('contextRecId') ? String.valueOf(genesysParams.get('contextRecId')) : '';
        Boolean showPopUpPanel = genesysParams.containsKey('popupPanel') ? Boolean.valueOf(genesysParams.get('popupPanel')) : false;
        String objectType = String.isNotBlank(contextRecId) ? XC_UTIL_SObject.getObjectType(contextRecId) : '';
          
        System.Debug('OBJECTTYPE:: ' + objectType);

        XC_CTI_Call_Event__e recordingEvent = new XC_CTI_Call_Event__e(
        XC_CTIInteractionId__c = interactionConnId,
        XC_EventType__c = evtType,
        XC_CTIRecordingId__c = recordingId,
        XC_ContextUserId__c = UserInfo.getUserId(),
        XC_ContextRecordId__c = contextRecId,
        XC_ObjectType__c = objectType,
        XC_ShowPopup__c = showPopUpPanel
        );

        Database.SaveResult resultSave = EventBus.publish(recordingEvent);

        result.put('success',resultSave.isSuccess());
        return result;

      }

      /**
       * @author Francesco Imperioli - fimperioli@deloitte.it
       * @description manages navigation events from openCTI and show/hide call controls
       * @createddate 2020/02/21
       */
      public static Map<String,Object> checkShowRecordingPanelAndSendEvent (Map<String,Object> genesysParams){

        String objectType = String.valueOf(genesysParams.get('objectType'));
        String recordId = String.valueOf(genesysParams.get('recordId'));
        Map<String,Object> result= new Map<String,Object>();
        result.put('success',true);
        result.put('showControls',false);

        String userLE = XC_UTIL_User.getLegalEntityFromUser();
        List<XC_CM_CallRecordingConfiguration__mdt> callRecordingConfs = [SELECT XC_LegalEntity__c,XC_Enabled__c FROM XC_CM_CallRecordingConfiguration__mdt WHERE XC_LegalEntity__c =:userLe];

        if(callRecordingConfs.isEmpty() || !callRecordingConfs[0].XC_Enabled__c){
            return result;
        }

        if(objectType == 'NE__Order__c'){

            NE__Order__c openedOrder = [SELECT ID,XC_Status__c,
            RecordTypeId, 
            NE__OptyId__r.XC_CTI_Interaction__c,
            NE__OptyId__r.XC_CTI_Interaction__r.CreatedById,
            NE__OptyId__r.XC_CTI_Interaction__r.XC_InteractionStatus__c,
            NE__OptyId__r.XC_CTI_Interaction__r.XC_Connection_ID__c,
            XC_CTICallRecording__c 
                FROM NE__Order__c WHERE Id=:recordId LIMIT 1
            ];

            System.Debug('CTI NAVIGATION EVENT FOUND ORDER:: ' + openedOrder);

            if(String.isNotBlank(openedOrder.NE__OptyId__r.XC_CTI_Interaction__c)){
                if(
                openedOrder.RecordTypeId == Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId()
                && orderInProgressStatuses.contains(openedOrder.XC_Status__c)
                && openedOrder.NE__OptyId__r.XC_CTI_Interaction__r.CreatedById==UserInfo.getUserId() 
                /*&& openedOrder.NE__OptyId__r.XC_CTI_Interaction__r.XC_InteractionStatus__c=='Open'*/){

                    result.put('success',true);
                    result.put('showControls',true);
                    //send event to pop-up the CTI UtilityBar
                    Map<String,Object> eventParams = new Map<String,Object>();
                    eventParams.put('eventType','CALLINIT');
                    eventParams.put('connId',openedOrder.NE__OptyId__r.XC_CTI_Interaction__r.XC_Connection_ID__c);
                    eventParams.put('popupPanel',String.isBlank(openedOrder.XC_CTICallRecording__c));
                    publishStartStopRecordingEventMessage(eventParams);

                }
            }
        // }else if(objectType == 'Case'){

        //     //check if we are in disconnect case
        //     Case openedCase = [SELECT Id,XC_CTI_Interaction__c,XC_CTI_Interaction__r.XC_Connection_ID__c,Reason,XC_Subtype__c,SubCause__c FROM Case WHERE Id = :recordId LIMIT 1];

        //     if(String.isNotBlank(openedCase.XC_CTI_Interaction__r.XC_Connection_ID__c)){
        //         List<XC_OrderSubtypeByCase__mdt> caseDisconnectConfigurations = [SELECT DeveloperName,Reason__c,SubCause__c,XC_Subtype__c FROM XC_OrderSubtypeByCase__mdt WHERE XC_Type__c = 'Disconnect'];
        //         Map<String,XC_OrderSubtypeByCase__mdt> reasonConfMap = new Map<String,XC_OrderSubtypeByCase__mdt>();
        //         Boolean isDisconnectCase = false;
    
        //         for(XC_OrderSubtypeByCase__mdt caseConf : caseDisconnectConfigurations){
        //             if(caseConf.Reason__c == openedCase.Reason && caseConf.XC_Subtype__c == openedCase.XC_Subtype__c && caseConf.SubCause__c == openedCase.SubCause__c){
        //                 isDisconnectCase = true;
        //                 break;
        //             }
        //         }

        //         if(isDisconnectCase){
        //             result.put('success',true);
        //             result.put('showControls',true);
        //                                 //send event to pop-up the CTI UtilityBar
        //             Map<String,Object> eventParams = new Map<String,Object>();
        //             eventParams.put('eventType','CALLINIT');
        //             eventParams.put('connId',openedCase.XC_CTI_Interaction__r.XC_Connection_ID__c);
        //             publishStartStopRecordingEventMessage(eventParams);
        //         }
        //     }

        }else if(objectType == 'Lead'){

            Lead openedLead = [SELECT Id,
            XC_CTI_Interaction__c,XC_CTI_Interaction__r.CreatedById,
            XC_CTI_Interaction__r.XC_InteractionStatus__c ,
            XC_CTI_Interaction__r.XC_Connection_ID__c,
            XC_CTICallRecording__c
            FROM Lead WHERE Id = :recordId LIMIT 1];

            if(String.isNotBlank(openedLead.XC_CTI_Interaction__c) 
            && openedLead.XC_CTI_Interaction__r.CreatedById==UserInfo.getUserId() 
            && openedLead.XC_CTI_Interaction__r.XC_InteractionStatus__c=='Open'){

                result.put('success',true);
                result.put('showControls',true);
                //send event to pop-up the CTI UtilityBar
                Map<String,Object> eventParams = new Map<String,Object>();
                eventParams.put('eventType','CALLINIT');
                eventParams.put('connId',openedLead.XC_CTI_Interaction__r.XC_Connection_ID__c);
                eventParams.put('popupPanel',String.isBlank(openedLead.XC_CTICallRecording__c));
                publishStartStopRecordingEventMessage(eventParams);
            }

        }else{
            result.put('success',true);
            result.put('showControls',false);
        }

        return result;


      }


      /**
      * @description manage signature for orders using CTI Call recording
      * @author Francesco Imperioli - fimperioli@deloitte.it | 3/6/2020 
      * @param orderId 
      * @param callRecId 
      * @return void 
      **/
      private static void manageVocalOrderSignature(String orderId,String callRecId){

        //getting order with items, if there's credit assignment, vocal order contract signing is skipped
        NE__Order__c orderToSign = [SELECT Id,(SELECT Id,Name,XC_CreditAssignmentAvailable__c FROM NE__Order_Items__r WHERE XC_CreditAssignmentAvailable__c = TRUE) FROM NE__Order__c WHERE ID = :orderId LIMIT 1];
        orderToSign.XC_CTICallRecording__c = callRecId;
        if(orderToSign.NE__Order_Items__r.isEmpty()){
            orderToSign.XC_SignedByExternal__c = 'VocalOrder';
        }
        XC_UTIL_Sobject.updateRecord(orderToSign);
      }


}