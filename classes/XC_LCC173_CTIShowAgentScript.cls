/**
*@author: Francesco Imperioli - fimperioli@deloitte.it
*@description: component controller for LCP173 modal component to show CTI Scripts ti agent
*@history: 29-11-2019 created
*
 */
public without sharing class XC_LCC173_CTIShowAgentScript {


    /**
    * @description Init container component, check if show script for CTI component must be showed.
    * @author Francesco Imperioli - fimperioli@deloitte.it | 20/5/2020 
    * @param objectId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> initScriptContainerCmp(String objectId){

        System.Debug('RECORDID::: ' + objectId);

        String objectName = XC_UTIL_Sobject.getObjectType(objectId);
        Map<String,Object> result = new Map<String,Object>();
        result.put('showComponent',true);

        //check if there's an open CTI Interaction
        List<XC_CTI_Interaction__c> currentInteraction = [SELECT Id 
        FROM XC_CTI_Interaction__c 
        WHERE XC_InteractionStatus__c = 'Open' AND CreatedById = :UserInfo.getUserId() LIMIT 1];

        List<User> runningUser = [SELECT id, XC_ExternalCallCenterUser__c
        FROM User 
        WHERE id = : UserInfo.getUserId() LIMIT 1];

        if(currentInteraction.isEmpty() && !runningUser[0].XC_ExternalCallCenterUser__c ){
            result.put('showComponent',false);
            return result;
        }

        String userLE = XC_UTIL_User.getLegalEntityFromUser();
        List<XC_CM_CallRecordingConfiguration__mdt> CTIRecordingConfs = [SELECT Id,DeveloperName,XC_LegalEntity__c,XC_Enabled__c,XC_Segment__c,XC_UseCongaTrigger__c 
        FROM XC_CM_CallRecordingConfiguration__mdt WHERE XC_LegalEntity__c = :userLE AND XC_Segment__c = 'B2C' LIMIT 1];

        if(CTIRecordingConfs.isEmpty()){
            result.put('showComponent',false);
            return result;
        }

        if(objectName.equalsIgnoreCase('NE__Order__c')){
            NE__Order__c currentOrder = [SELECT Id,NE__OptyId__r.XC_CTI_Interaction__c,XC_LegalEntity__c,NE__Type__c
            FROM NE__Order__c WHERE Id= : objectId LIMIT 1];
            
            if(String.isBlank(currentOrder.NE__OptyId__r.XC_CTI_Interaction__c) && !runningUser[0].XC_ExternalCallCenterUser__c ){
                result.put('showComponent',false);
            }else if(String.isNotBlank(currentOrder.NE__OptyId__r.XC_CTI_Interaction__c) && currentOrder.NE__Type__c!='InOrder'){
                result.put('showComponent',false);
            }

            //if we have multiple scripts then we have to do some logic 
            if(Boolean.valueOf(result.get('showComponent')) == true && CTIRecordingConfs[0].XC_UseCongaTrigger__c){
                result.put('useCongaTrigger',true);
                List<Map<String,Object>> currentFiles = (List<Map<String,Object>>) retrieveCongaTriggerAttachments(currentOrder.Id).get('scripts');

                if(currentFiles.isEmpty()){
                    manageCongaTriggerUsage(objectName,CTIRecordingConfs[0].Id,objectId);
                }else{
                    result.put('scripts',currentFiles);
                }

            }

            System.Debug('ORDER CASE::  ' + currentOrder.NE__OptyId__r.XC_CTI_Interaction__c);


        }else if(objectName.equalsIgnoreCase('Case')){
           
            Case currentCase = [SELECT Id,XC_CTI_Interaction__c,XC_LegalEntity__c FROM Case WHERE Id= : objectId LIMIT 1];
            
            if(String.isBlank(currentCase.XC_CTI_Interaction__c)){
                result.put('showComponent',false);
            }

            System.Debug('CASE CASE::  ' + currentCase.XC_CTI_Interaction__c);

        }
        return result;
    }

    /**
    *@author: Francesco Imperioli - fimperioli@deloitte.it
    *@description: retrieves basic info about the script that has to be shown to the customer
    *@history: 29-11-2019 created
     */
    @AuraEnabled
    public static Map<String,Object> getDynamicScriptInfo(Map<String,Object> paramsMap){
        Map<String,Object> result= new Map<String,Object>();
        result.put('success',false);

        String recordId = String.valueOf(paramsMap.get('recordId'));
        String objectName = String.isNotBlank(String.valueOf(paramsMap.get('objectName'))) ? String.valueOf(paramsMap.get('objectName')) : XC_UTIL_Sobject.getObjectType(recordId);


        //getting configurations
        String userLE = XC_UTIL_User.getLegalEntityFromUser();
        List<XC_CM_CallRecordingConfiguration__mdt> CTIRecordingConfs = [SELECT Id,DeveloperName,XC_LegalEntity__c,XC_Enabled__c, 
            (SELECT XC_CongaQueryId__c,XC_CongaTemplateId__c,XC_MainObject__c,XC_MainObject__r.QualifiedAPIName,XC_OrgID__c 
            FROM CallRecScriptConfigurations__r
            WHERE XC_OrgId__c = :UserInfo.getOrganizationId() AND XC_MainObject__r.QualifiedAPIName = :objectName LIMIT 1
            )
        FROM XC_CM_CallRecordingConfiguration__mdt WHERE XC_LegalEntity__c = :userLE LIMIT 1];

        //check if configurations are in place for the legalEntity
        if(String.isBlank(objectName) || CTIRecordingConfs.isEmpty() || CTIRecordingConfs[0].CallRecScriptConfigurations__r.isEmpty()){
            return result;
        }


        //creating congaURL for the document
        XC_CM_CallRecScriptConfiguration__mdt scriptConf = CTIRecordingConfs[0].CallRecScriptConfigurations__r[0];
        String url1 = '/apex/APXTConga4__Conga_Composer?serverUrl=';
        String url2 = '&id='+recordId+
        '&QueryID='+scriptConf.XC_CongaQueryId__c+
        '?pv0='+recordId+
        '&TemplateID='+scriptConf.XC_CongaTemplateId__c+'&DS7=3'+'&FP0=1'+'&AC2=1'+'&LG1='+Label.XC_CL_LCP173_CongaActivitySubject+'&AC0=1';

        result.put('success',true);
        result.put('congaUrl1',url1);
        result.put('congaUrl2',url2);

        return result;

    }

    /**
    * @description intercept task creation platform event in order to check if the script has to be showed
    * @author Francesco Imperioli - fimperioli@deloitte.it | 21/5/2020 
    * @param params 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> retrieveScriptTextFromTask(Map<String,Object> params){

        String currentRecordId = String.valueOf(params.get('recordId'));
        String scriptTaskId = String.valueOf(params.get('taskId'));
        Map<String,Object> result = new Map<String,Object>();

        String callScriptText = [SELECT Description FROM Task WHERE Id = :scriptTaskId AND WhatId = :currentRecordId LIMIT 1].Description;
        result.put('success',String.isNotBlank(callScriptText));
        result.put('taskId',scriptTaskId);
        result.put('recordId',currentRecordId);
        result.put('text',callScriptText);

        return result;
    }

    /**
    * @description send a platform event to start a recording from a different place than the genesys visualforce page
    * @author Francesco Imperioli - fimperioli@deloitte.it | 21/5/2020 
    * @param params 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> sendStartStopRecordingEvent(Map<String,Object> params){
        Map<String,Object> result = new Map<String,Object>();
        String eventType = String.valueOf(params.get('eventType'));
        String recordId = String.valueOf(params.get('recordId'));

        XC_CTI_Call_Event__e recordingEvent = new XC_CTI_Call_Event__e(
        XC_EventType__c = eventType,
        XC_ContextUserId__c = UserInfo.getUserId(),
        XC_ContextRecordId__c = recordId
        );
        Database.SaveResult resultSave = EventBus.publish(recordingEvent);
        result.put('success',resultSave.isSuccess());
        return result;
    }

    /**
    * @description returns if call recording is enabled for the LE
    * @author Francesco Imperioli - fimperioli@deloitte.it | 26/5/2020 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> getIsRecodingEnabled(){

        Map<String,Object> result = new Map<String,Object>();
        String userLE = XC_UTIL_User.getLegalEntityFromUser();
        List<XC_CM_CallRecordingConfiguration__mdt> recConfs = [SELECT XC_LegalEntity__c,XC_Enabled__c 
        FROM XC_CM_CallRecordingConfiguration__mdt WHERE XC_LegalEntity__c = :userLE LIMIT 1];

        if(!recConfs.isEmpty() && recConfs[0].XC_Enabled__c){
            result.put('isEnabled',true);
        }else{
            result.put('isEnabled',false);
        }

        return result;

    }


    /**
    * @description generate documents using conga trigger an event then is fired in order to retrieve the pdf view
    * @author Francesco Imperioli - fimperioli@deloitte.it | 01-18-2021 
    * @param objectName 
    * @param callrecordingConfId 
    * @param recordId 
    **/
    private static void manageCongaTriggerUsage(String objectName,String callrecordingConfId,String recordId){

        if(objectName.equalsIgnoreCase('NE__Order__c')){
            
            Map<Id,NE__OrderItem__c> oisMap = new Map<Id,NE__OrderItem__c>([SELECT Id,Name,XC_Product_Subtype__c FROM NE__OrderItem__c WHERE NE__OrderId__c = :recordId AND NE__Bundle_Configuration__c = NULL]);
            Set<String> productSubtypes = new Set<String>(XC_UTIL_Sobject.getListFieldValues(oisMap.values(), 'XC_Product_Subtype__c'));

            List<XC_CM_CallRecScriptConfiguration__mdt> scriptsConfs = [SELECT XC_CongaQueryId__c,XC_CongaTemplateId__c,XC_ProductSubtype__c
            FROM XC_CM_CallRecScriptConfiguration__mdt 
            WHERE XC_CallRecordingConfiguration__c=:callRecordingConfId 
            AND  XC_OrgId__c = :UserInfo.getOrganizationId() 
            AND XC_MainObject__r.QualifiedAPIName = :objectName AND (XC_ProductSubtype__c IN : productSubtypes OR XC_ProductSubtype__c = NULL)];

            Map<String,XC_CM_CallRecScriptConfiguration__mdt> subtypeTemplateMap = new Map<String,XC_CM_CallRecScriptConfiguration__mdt>();

            for(XC_CM_CallRecScriptConfiguration__mdt confScript : scriptsConfs){
                if(String.isBlank(confScript.XC_ProductSubtype__c)){
                    subtypeTemplateMap.put('*',confScript);
                }else{
                    subtypeTemplateMap.put(confScript.XC_ProductSubtype__c,confScript);
                }
            }

            for(NE__OrderItem__c oiItems : oisMap.values()){
                XC_CM_CallRecScriptConfiguration__mdt confScript = subtypeTemplateMap.containsKey(oiItems.XC_Product_Subtype__c) ? subtypeTemplateMap.get(oiItems.XC_Product_Subtype__c) :
                subtypeTemplateMap.get('*');
                String fileName = 'VOCAL_SCRIPT_' + oiItems.Name + '_' + UserInfo.getUserId();
                String congaFieldString = '&Id=' + oiItems.Id + '&QueryId=' + confScript.XC_CongaQueryId__c + '&TemplateId=' + confScript.XC_CongaTemplateId__c + '&OFN='+ fileName + '&DefaultPDF=1&qmode=SalesforceFile';
                oiItems.XC_CongaScriptDynamicAPI__c = congaFieldString;
            }

            XC_UTIL_Sobject.updateListRecords(oisMap.values());

        }

        //TODO: Case part, requires another request from bsn

    }


    /**
    * @description query the files generated by conga once received the event
    * @author Francesco Imperioli - fimperioli@deloitte.it | 01-19-2021 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> retrieveCongaTriggerAttachments(String orderId){

        Map<String,Object> result = new Map<String,Object>();
        Map<Id,NE__OrderItem__c> orderItems = new Map<Id,NE__OrderItem__c>([SELECT Id,Name,NE__ProdName__c,XC_Product_Subtype__c FROM NE__OrderItem__c WHERE NE__OrderId__c = :orderId]);
        Set<Id> orderItemsId = XC_UTIL_Sobject.getSetIds(orderItems.values());

        Map<Id, ContentDocumentLink> contentDocumentMap = new Map<Id, ContentDocumentLink>([SELECT Id, Contentdocument.LatestPublishedVersion.Id, Contentdocument.LatestPublishedVersion.XC_Category__c,
                                                     Contentdocument.LatestPublishedVersion.PathOnClient, Contentdocument.LatestPublishedVersion.ContentSize,
                                                     Contentdocument.LatestPublishedVersion.Description, Contentdocument.LatestPublishedVersion.versiondata, LinkedEntityId, ContentDocument.FileExtension
                                                     FROM ContentDocumentLink
                                                     WHERE LinkedEntityId IN :orderItemsId]);

        List<ContentDocumentLink> contentDocument = contentDocumentMap.values();
        List<Map<String,Object>> scriptResultList = new List<Map<String,Object>>();

        for(ContentDocumentLink cdl : contentDocument){

            Map<String,Object> scriptWrap = new Map<String,Object>();
            scriptWrap.put('oiName',orderItems.get(cdl.LinkedEntityId).Name);
            scriptWrap.put('sectionLabel',orderItems.get(cdl.linkedEntityId).NE__ProdName__c + ' - ' + orderItems.get(cdl.linkedEntityId).Name);
            scriptWrap.put('oiSubtype',orderItems.get(cdl.LinkedEntityId).XC_Product_Subtype__c);
            scriptWrap.put('base64content',EncodingUtil.base64Encode(cdl.Contentdocument.LatestPublishedVersion.versiondata));
            scriptResultList.add(scriptWrap);
        }

        result.put('scripts',scriptResultList);

        return result;
        
    }


}