/**
* @author Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 20/11/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_ProvisioningStep– Util class for ProvisioningStep methods
*/

public without sharing class XC_UTIL_ProvisioningStep {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ProvisioningStep');
    public static List<String> listStepCompletedStatus = new List<String>{
        Label.XC_CL_Completed_OK,
        Label.XC_CL_Step_Skipped,
        Label.XC_CL_Step_CompletedWarning
    };
    
    public static List<String> listStepFailedStatus = new List<String>{
        Label.XC_CL_Step_CompletedKO
    };
     
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Configuration Items this method inserts the Provisioning Steps
    **/
    public class ResultWrapper{
        public Boolean success = false;
        public String errorMessage = '';
        public NE__Order__c order = new NE__Order__c();

        /** @description Costurctor */
        public ResultWrapper(){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Empty constructor');
        }

        /** @description Costurctor with params
        * @param success - Boolean
        * @param errorMessage - String
        */
        public ResultWrapper(Boolean success, String errorMessage){
            this.success = success;
            this.errorMessage = errorMessage;
        } 
    }

    /**
     *@author Marco Rosa - marco.rosa@nttdata.com  
     *@description Method to start initial steps
     *@param listSteps the list of steps
    **/
    public static void startInitialSteps(List<XC_Provisioning_Step__c> listSteps){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'USED QUERIES->' + Limits.getQueries() + '/' + Limits.getLimitQueries());        
        List<XC_Provisioning_Step__c> stepsToEnqueue = new List<XC_Provisioning_Step__c>();      
        for(XC_Provisioning_Step__c step :  listSteps){
            if(step.XC_Step_Order__c == 1 && step.XC_Status__c == Label.XC_CL_Provisioning_Step_NotStarted){   
                stepsToEnqueue.add(step);
            }
        }  
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'stepsToEnqueue->' + stepsToEnqueue); 
        if(!stepsToEnqueue.isEmpty()){
            enqueueStepList(stepsToEnqueue); 
        }  
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Provisioning Steps launchs the flows synchronously or asynchronously 
     * @param stepsToEnqueue
    **/
    public static void enqueueStepList(List<XC_Provisioning_Step__c> stepsToEnqueue){
        Set<XC_Provisioning_Step__c> stepsToEnqueueSynch = new Set<XC_Provisioning_Step__c>();  
        Set<XC_Provisioning_Step__c> stepsToEnqueueAsynch = new Set<XC_Provisioning_Step__c>();      
        for(XC_Provisioning_Step__c step :  stepsToEnqueue){
            if(step.XC_Synchronous__c){
                stepsToEnqueueSynch.add(step); 
            } else {
                stepsToEnqueueAsynch.add(step);
            }
        } 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'stepsToEnqueueSynch->' + stepsToEnqueueSynch);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'stepsToEnqueueAsynch->' + stepsToEnqueueAsynch); 
        if(!stepsToEnqueueSynch.isEmpty()){
            launchStepListSynch(stepsToEnqueueSynch); 
        } 
        if(!stepsToEnqueueAsynch.isEmpty()){
            launchStepListASynch(stepsToEnqueueAsynch); 
        }       
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Provisioning Steps launchs the flows synchronously
     * @param stepsToEnqueueSynch
    **/
    public static void launchStepListSynch(Set<XC_Provisioning_Step__c> stepsToEnqueueSynch){
        List<XC_Provisioning_Step__c> stepsToEnqueueSynchList = new List<XC_Provisioning_Step__c>(stepsToEnqueueSynch); 
        setInProgressStatus(stepsToEnqueueSynchList);
        executeSteps(stepsToEnqueueSynchList);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Provisioning Steps launchs the flows asynchronously
     * @param stepsToEnqueueAsynch
    **/
    public static void launchStepListASynch(Set<XC_Provisioning_Step__c> stepsToEnqueueAsynch){
        List<XC_Provisioning_Step__c> stepsToEnqueueASynchList = new List<XC_Provisioning_Step__c>(stepsToEnqueueAsynch);
        setInProgressStatus(stepsToEnqueueASynchList); 
        insertEvent(stepsToEnqueueASynchList);
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Provisioning Steps set the status in "in progress"
     * @param listStep
    **/
    public static void setInProgressStatus(List<XC_Provisioning_Step__c> listStep){ 
        /*List<Id> listIdToUpdate = XC_UTIL_Sobject.getIds(listStep);
        
        Map<Id,XC_Provisioning_Step__c> mapToUpdate = new Map<Id,XC_Provisioning_Step__c>([
            SELECT Id FROM XC_Provisioning_Step__c WHERE Id IN:listIdToUpdate
        ]);
        List<XC_Provisioning_Step__c> listToUpdate = mapToUpdate.values();*/
        
        List<XC_Provisioning_Step__c> listToUpdate = new List<XC_Provisioning_Step__c>();
        for(XC_Provisioning_Step__c step : listStep){ 
            XC_Provisioning_Step__c newStep = new XC_Provisioning_Step__c();
            newStep.Id = step.Id;
            newStep.XC_Status__c = Label.XC_CL_Provisioning_Step_InProgress;
            listToUpdate.add(newStep);
        }
        XC_TR_ProvisioningStep_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_ProvisioningStep_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(listToUpdate);
        XC_TR_ProvisioningStep_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_ProvisioningStep_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false); 
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Provisioning Steps Ids launchs a Platform Event with the concatenation of step Ids
     * @param stepIdList
    **/
    public static void insertEvent(List<String> stepIdList){
        if(!stepIdList.isEmpty()){
            String stepidToExecute = stepIdList[0];
            stepIdList.remove(0);
            String stepIdListString = String.join(stepIdList, ';');
            if(!String.isBlank(stepidToExecute)){ 
                XC_Provisioning_Step_Enqueued_Event__e event = new XC_Provisioning_Step_Enqueued_Event__e();
                event.XC_StepToExecute__c = stepidToExecute;
                event.XC_StepIdList__c = stepIdListString;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'event->' + event);
                XC_UTIL_PlatformEvent.publishListEvent(event);
            }
        }
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Provisioning Steps launchs a Platform Event with the concatenation of step Ids
     * @param stepIdList
    **/
    public static void insertEvent(List<XC_Provisioning_Step__c> stepList){
        if(!stepList.isEmpty()){
            String stepidToExecute = stepList[0].Id;
            String stepLegalEntity = stepList[0].XC_LegalEntity__c;
            String stepSegment = stepList[0].XC_Segment__c;
            XC_Provisioning_Step__c stepToLaunch = stepList[0];
            stepList.remove(0);
            List<Id> stepIdList = XC_UTIL_Sobject.getIds(stepList);
            String stepIdListString = String.join(stepIdList, ';');
            if(!String.isBlank(stepidToExecute)){ 
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@LegalEntity->' + stepLegalEntity );
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@Segment->' + stepSegment );
                
                String eventName = 'XC_Provisioning_Step_Enqueued_Event__e'; 
                if(!String.isBlank(stepToLaunch.XC_PlatformEventName__c)){
                    eventName = stepToLaunch.XC_PlatformEventName__c;
                } else { 
                    List<XC_CM_LegalEntity_Configuration__mdt> listCM = new List<XC_CM_LegalEntity_Configuration__mdt>([
                        SELECT Id, XC_Stream__c, XC_LegalEntity__c, XC_ProvisioningEventName__c
                        FROM XC_CM_LegalEntity_Configuration__mdt
                        WHERE XC_Stream__c = :stepSegment  AND XC_LegalEntity__c = :stepLegalEntity 
                        AND XC_ProvisioningEventName__c != null
                    ]); 
                    if(!listCM.isEmpty() && !String.isBlank(listCM[0].XC_ProvisioningEventName__c)){
                        eventName = listCM[0].XC_ProvisioningEventName__c;
                    }
                }
                SObject eventObj = (SObject)Type.forName(eventName).newInstance();
                eventObj.put('XC_StepToExecute__c', stepidToExecute);
                eventObj.put('XC_StepIdList__c', stepIdListString);
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'event->' + eventObj);
                XC_UTIL_PlatformEvent.publishListEvent(eventObj); 
            }
        }
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a map FlowName -> list of steps this method executes the Provisioning Steps
     * @param stepsToEnqueue
    **/
    public static void executeSteps(List<XC_Provisioning_Step__c> stepsToEnqueue){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'USED QUERIES->' + Limits.getQueries() + '/' + Limits.getLimitQueries()); 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@stepsToEnqueue->' + stepsToEnqueue); 
        if(stepsToEnqueue.size() == 1){
            XC_UTIL_Flow.launchFlowSingleMode(stepsToEnqueue[0].XC_Flow_API_Name__c, stepsToEnqueue[0]);
        } else {
            Map<String, List<XC_Provisioning_Step__c>> mapStepsByName = XC_UTIL_ProvisioningStep_U.getMapStepsByName(stepsToEnqueue);
            if(!mapStepsByName.isEmpty()){ 
                for(String flowName : mapStepsByName.keySet()){ 
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'flowName->' + flowName);
                    List<XC_Provisioning_Step__c> stepsToLaunch = mapStepsByName.get(flowName);
                    //XC_UTIL_Flow.launchFlowBulkMode(flowName, stepsToLaunch); 
                    for(XC_Provisioning_Step__c step : stepsToLaunch){
                        XC_UTIL_Flow.launchFlowSingleMode(flowName, step);
                    }
                }
            }
        } 
    }
 
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Configuration this method inserts the Provisioning Steps related to its children Configuration Items
     * @param configurationId
     * @return configurationId
    **/
    public static ResultWrapper insertSteps(String configurationId){
        List<ResultWrapper> listResult = insertSteps(new List<String>{configurationId});
        if(!listResult.isEmpty()){
            return listResult[0];
        }
        //risultato senza step cmq positivo
        return new ResultWrapper(true,''); 
    }

    /**
     * @description Insert Steps
     * @param listConfigurationIds
     * @return List<ResultWrapper>
    **/
    public static List<ResultWrapper> insertSteps(List<String> listConfigurationIds){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@listConfigurationIds->' + listConfigurationIds); 
        List<ResultWrapper> resultWrapperList = new List<ResultWrapper>();
        if(!listConfigurationIds.isEmpty() && Schema.sObjectType.NE__OrderItem__c.isAccessible()){
            Map<Id, NE__OrderItem__c> orderItemsMap = new Map<Id, NE__OrderItem__c>([
                SELECT Id,
                    (SELECT Id FROM Provisioning_Steps__r)
                FROM NE__OrderItem__c 
                WHERE NE__OrderId__c IN: listConfigurationIds AND XC_IsAProduct__c = true AND NE__Qty__c >0]);
 
            List<NE__OrderItem__c> orderItemsList = orderItemsMap.values();         
            List<NE__OrderItem__c> listOrderItemToInsertSteps = new List<NE__OrderItem__c>();
            for(NE__OrderItem__c oi : orderItemsList){
                if(oi.Provisioning_Steps__r ==  null || oi.Provisioning_Steps__r.isEmpty()){
                    listOrderItemToInsertSteps.add(oi);
                } 
            }
            if(!listOrderItemToInsertSteps.isEmpty()){
                resultWrapperList = XC_UTIL_ProvisioningStep.insertSteps(listOrderItemToInsertSteps); 
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@resultWrapperList->' + resultWrapperList);       
        return resultWrapperList;
    } 

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Configuration Items this method inserts the Provisioning Steps.
                    In the first part there is a call to XC_UTIL_ProvisioningTemplateAssociation.getTemplate that checks some fields of the Order Item
                    and retrieves a map with the configuration item Id and the template name of the associated template custom metadata.
                    Then with the second call to XC_UTIL_ProvisioningTemplateConfig.getTemplateSteps takes all data necessary to the population
                    of the provisioning steps records. These records have also a lookup to the connected Configuration Item.
    * @param configurationItem
    * @return ResultWrapper
    **/
    public static ResultWrapper insertSteps(NE__OrderItem__c configurationItem){
        List<ResultWrapper> listResult = insertSteps(new List<NE__OrderItem__c>{configurationItem});
        if(!listResult.isEmpty()){
            return listResult[0];
        }
        return new ResultWrapper(); 
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com  
    * @description Insert steps
    * @param configurationItemList
    * @return List<ResultWrapper>
    **/
    public static List<ResultWrapper> insertSteps(List<NE__OrderItem__c> configurationItemList){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@ configurationItemList' + configurationItemList); 
        List<ResultWrapper> results = new List<ResultWrapper>(); 
        if(!configurationItemList.isEmpty()){  
            Map<Id, String> mapConfItemTemplateName = XC_UTIL_ProvisioningTemplateAssociation.getTemplate(configurationItemList);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'map--------->' + mapConfItemTemplateName );
            for(NE__OrderItem__c confItem : configurationItemList){
                if(!mapConfItemTemplateName.containsKey(confItem.Id)) {
                    results.add(new ResultWrapper(false, Label.XC_CL_NoProvisioningConfiguration)); 
                }
            }
            XC_UTIL_ProvisioningStep_U.populateResultWrapper(results, mapConfItemTemplateName, configurationItemList);
        }
        return results;
    }  

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttadata.com
     * @description Given a Provisioning Step Status return true if it is Completed
     * @param stepStatus
     * @return Boolean
    **/
    public static Boolean isCompleted(String stepStatus){
        return listStepCompletedStatus.contains(stepStatus);
        //return stepStatus == Label.XC_CL_Completed_OK || stepStatus == Label.XC_CL_Step_Skipped);
    }
    
    /**
     * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com
     * @description Given a Provisioning Step Status return true if it is Failed
     * @param stepStatus
     * @return Boolean
    **/
    public static Boolean isFailed(String stepStatus){
        return listStepFailedStatus.contains(stepStatus);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a stepId executes the flow related to the step
     * @param stepId 
    **/
    @future
    public static void executeStepFuture(String stepId){
        List<XC_Provisioning_Step__c> listSteps = XC_UTIL_Sobject.selectAllFields(stepId);
        executeSteps(listSteps);
    }

}