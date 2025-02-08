/**
* @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 28/09/2020
* @date Modification dd/mm/yyyy
* @description XC_UTIL_StartFlowEvent - Util class for StartFlowEvent methods
*/ 

public without sharing class XC_UTIL_StartFlowEvent {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_StartFlowEvent');

    /**
     * @description InputWrapper for Process Builder
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String stepToExecuteId;
        @Invocablevariable
        public String stepsToEnqueueId;
    }  

    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com
     * @description Method to be used by Process Builder to launch flows after Platform Event reception
     * @param inputWrapperList Wrapper of parameters
    */
    @InvocableMethod 
    public static void executeFlowAndEnqueueOthers(List<InputWrapper> inputWrapperList){ 
        System.debug('inputWrapperList->' + inputWrapperList);  
        List<String> allStepIdList = new List<String>();
        for(InputWrapper wr : inputWrapperList){
            System.debug('stepToExecuteId->' + wr.stepToExecuteId);
            System.debug('stepsToEnqueueId->' + wr.stepsToEnqueueId);
            allStepIdList.add(wr.stepToExecuteId); 
            if(!String.isBlank(wr.stepsToEnqueueId)){
                allStepIdList.addAll(wr.stepsToEnqueueId.split(';')); 
            } 
        }
        List<XC_Provisioning_Step__c> listQueried = XC_UTIL_SObject.selectAllFields(allStepIdList, 'XC_Provisioning_Step__c');
        Set<XC_Provisioning_Step__c> stepInProgressSet = new Set<XC_Provisioning_Step__c>();
        for(XC_Provisioning_Step__c step : listQueried ){
            if(!XC_UTIL_ProvisioningStep.isCompleted(step.XC_Status__c) && !XC_UTIL_ProvisioningStep.isFailed(step.XC_Status__c)){
                stepInProgressSet.add(step);
            }    
        } 
        
        if(!stepInProgressSet.isEmpty()){
            List<XC_Provisioning_Step__c> stepInProgressList = new List<XC_Provisioning_Step__c>();
            stepInProgressList.addAll(stepInProgressSet);
            List<XC_Provisioning_Step__c> stepsToLaunchFlow = new List<XC_Provisioning_Step__c>{stepInProgressList[0]}; 
            try{
                XC_UTIL_ProvisioningStep.executeSteps(stepsToLaunchFlow);
            }catch(Exception e){
                // 2022-01-26 - Eleni Tsiolaki - Track step KO - START
                // XC_UTIL_ExceptionLog.insertExceptionLog(e);
                XC_UTIL_ExceptionLog.insertExceptionLog(e, stepsToLaunchFlow[0].id);
                stepsToLaunchFlow[0].XC_Status__c = 'Completed KO';
                stepsToLaunchFlow[0].XC_ErrorMessage__c = e.getMessage() + ' ' + e.getStackTraceString();
                XC_UTIL_DML.updateRecords(stepsToLaunchFlow);
                // 2022-01-26 - Eleni Tsiolaki - Track step KO - END
            }
            stepInProgressList.remove(0);
            if(!stepInProgressList.isEmpty()){ 
                insertEventStartFlow(XC_UTIL_Sobject.getids(stepInProgressList)); 
            }
        } 
    } 
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com  
     * @description Given a list of Provisioning Steps Ids launchs a Platform Event with the concatenation of step Ids
     * @param stepIdList
    **/
    public static void insertEventStartFlow(List<String> stepIdList){
        if(!stepIdList.isEmpty()){
            String stepidToExecute = stepIdList[0];
            stepIdList.remove(0);
            String stepIdListString = String.join(stepIdList, ';');
            if(!String.isBlank(stepidToExecute)){ 
                XC_StartFlowEvent__e event = new XC_StartFlowEvent__e();
                event.XC_StepToExecute__c = stepidToExecute;
                event.XC_StepIdList__c = stepIdListString;
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'event->' + event);
                XC_UTIL_PlatformEvent.publishListEvent(event);
            }
        }
    }

}