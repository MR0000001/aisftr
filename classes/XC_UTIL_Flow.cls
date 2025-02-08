/**
* @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 22/11/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Flow - Util class for Flow methods
*/ 

public without sharing class XC_UTIL_Flow {

    public static List<String> listStepFlowToExecuteSeparately = new List<String>{
    
    };

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
     * @description Method to launch a flow for a single step
     * @param flowName - API name of the flow
     * @param step - Step to be passed to the flow as parameter 
    */
    public static void launchFlowSingleMode(String flowName, XC_Provisioning_Step__c step){  
        Map<String,Object> inputs = new map<String,Object>{ 
            'step' => step
        };
        if(!Test.isRunningTest()){
            Flow.Interview.createInterview(flowName, inputs).start();
        }
    }

    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com
     * @description Method to launch a flow for a list of step
     * @param flowName - API name of the flow
     * @param stepList - List of Step to be passed to the flow as parameter 
    */
    
    public static void launchFlowBulkMode(String flowName, List<XC_Provisioning_Step__c> stepList){  
        Map<String,Object> inputs = new map<String,Object>{ 
            'stepList' => stepList
        };
        if(!Test.isRunningTest()){
            Flow.Interview.createInterview(flowName, inputs).start();
        }
    }   

    /**
     * @author: Marco Rosa - marco.rosa@nttdata.com
     * @description Method to be used by Process Builder to launch flows after Platform Event reception
     * @param inputWrapperList Wrapper of parameters
    */

    @InvocableMethod 
    public static void executeFlowAndEnqueueSteps(List<InputWrapper> inputWrapperList){ 
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
            Integer queryLimit = 60;
            if(Integer.valueOf(Label.XC_CL_QueryLimit) > 0 && Integer.valueOf(Label.XC_CL_QueryLimit)< 90 ){
                queryLimit = Integer.valueOf(Label.XC_CL_QueryLimit);
            }
            if(Limits.getQueries() <  queryLimit){
                List<XC_Provisioning_Step__c> stepsToLaunchFlow = new List<XC_Provisioning_Step__c>{stepInProgressList[0]};
                try{
                    String flowNameToExecute = stepInProgressList[0].XC_Flow_API_Name__c;
                    if(listStepFlowToExecuteSeparately.contains(flowNameToExecute)){
                        XC_UTIL_StartFlowEvent.insertEventStartFlow(new List<String>{stepInProgressList[0].Id});
                    } else {
                        XC_UTIL_ProvisioningStep.executeSteps(stepsToLaunchFlow);
                    }
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
                    XC_UTIL_ProvisioningStep.insertEvent(stepInProgressList);
                }
            } else {
                XC_UTIL_ProvisioningStep.insertEvent(stepInProgressList);
            }
        }
    } 
    
    /* OLD VERSION
    public static void executeFlowAndEnqueueSteps(List<InputWrapper> inputWrapperList){ 
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
        Set<String> allStepIdSet = new Set<String>();
        allStepIdSet.addAll(allStepIdList);
        List<String> allStepIdListDistinct = new List<String>();
        allStepIdListDistinct.addAll(allStepIdSet);
        
        if(!allStepIdListDistinct.isEmpty()){
            String stepToExecuteId = allStepIdListDistinct[0];
            List<XC_Provisioning_Step__c> stepsToLaunchFlow = XC_UTIL_SObject.selectAllFields(stepToExecuteId);
            try{
                XC_UTIL_ProvisioningStep.executeSteps(stepsToLaunchFlow);
            }catch(Exception e){
                XC_UTIL_ExceptionLog.insertExceptionLog(e);
            }
            allStepIdListDistinct.remove(0);
            if(!allStepIdListDistinct.isEmpty()){ 
                XC_UTIL_ProvisioningStep.insertEvent(allStepIdListDistinct);
            }
        } 
    } */

}