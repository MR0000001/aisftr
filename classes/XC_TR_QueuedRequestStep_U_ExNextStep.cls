/**
 * @File Name          : XC_TR_QueuedRequestStep_U_ExNextStep.cls
 * @Description        : Enqueue the execution of the new QueuedRequestStep Flow.
 * @Author             : Francesco Imperioli - fimperioli@deloitte.it
 * @Group              : 
 * @Last Modified By   : Francesco Imperioli - fimperioli@deloitte.it
 * @Last Modified On   : 3/7/2020, 12:46:22
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    27/5/2020   Francesco Imperioli - fimperioli@deloitte.it     Initial Version
**/
public without sharing class XC_TR_QueuedRequestStep_U_ExNextStep {

    public static final Set<String> STEPS_COMPLETED_STATUSES = new Set<String>{Label.XC_CL_Step_Skipped,Label.XC_CL_Completed_Ok};

    
    /**
    * @description enqueue the next step after the current step completion. Increments the sequence and search for a new step to execute.
    * @author Francesco Imperioli - fimperioli@deloitte.it | 27/5/2020 
    * @param listNew 
    * @param mapOld 
    * @return void 
    **/
    public static void executeNextStep(Map<Id,XC_QueuedRequestStep__c> mapNew,Map<Id,XC_QueuedRequestStep__c> mapOld){


        List<XC_QueuedRequestStep__c> stepsToProcess = (List<XC_QueuedRequestStep__c>) XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Status__c'},mapOld,mapNew);
        List<XC_QueuedRequestStep__c> completedOrSkippedSteps = new List<XC_QueuedRequestStep__c>();
        List<XC_QueuedRequestStep__c> goToCallbackSteps = new List<XC_QueuedRequestStep__c>();
        Set<String> queuedRequestIds = new Set<String>();

        for(XC_QueuedRequestStep__c step : stepsToProcess){
            if(STEPS_COMPLETED_STATUSES.contains(step.XC_Status__c)){
                completedOrSkippedSteps.add(step);
                queuedRequestIds.add(step.XC_QueuedRequest__c);
            }else if(step.XC_Status__c.equalsIgnoreCase(XC_UTIL_QueuedRequestStep.SKIP_TO_CALLBACK_STATUS)){
                goToCallbackSteps.add(step);
                queuedRequestIds.add(step.XC_QueuedRequest__c);
            }
        }


        if(!completedOrSkippedSteps.isEmpty()){

            Map<Id,XC_QueuedRequest__c> stepGroupedMap = new Map<Id,XC_QueuedRequest__c>(
                [SELECT Id,Name,
                    (SELECT Id,Name,XC_FlowApiName__c,XC_StepSequence__c,XC_Status__c FROM QueuedRequestSteps__r) 
                FROM XC_QueuedRequest__c WHERE Id IN :queuedRequestIds]
            );

            List<XC_QueuedRequestStep__c> newStepsToEnqueue = new List<XC_QueuedRequestStep__c>();
            for(XC_QueuedRequestStep__c step : completedOrSkippedSteps){
                Integer newSequence = Integer.valueOf(step.XC_StepSequence__c) + 1;
                List<XC_QueuedRequestStep__c> nextStepsList = stepGroupedMap.get(step.XC_QueuedRequest__c).QueuedRequestSteps__r;
                if(nextStepsList != null && !nextStepsList.isEmpty()){
                    for(XC_QueuedRequestStep__c nextStep : nextStepsList){
                        if(nextStep.XC_StepSequence__c==newSequence){
                            newStepsToEnqueue.add(nextStep);
                        }
                    }
                }
            }

            if(!newStepsToEnqueue.isEmpty()){
                XC_UTIL_QueuedRequestStep.setStepInProgressAndEmitEvent(newStepsToEnqueue);
            }

        }

        if(!goToCallbackSteps.isEmpty()){

            Map<Id,XC_QueuedRequest__c> stepGroupedMap = new Map<Id,XC_QueuedRequest__c>(
                [SELECT Id,Name,
                    (SELECT Id,Name,XC_FlowApiName__c,XC_StepSequence__c,XC_Status__c FROM QueuedRequestSteps__r WHERE  XC_StepLabel__c = :XC_UTIL_QueuedRequestStep.COMMODITY_CALLBACK_STEPLABEL) 
                FROM XC_QueuedRequest__c WHERE Id IN :queuedRequestIds ]
            );

            Set<XC_QueuedRequestStep__c> callbacksToEnqueue = new Set<XC_QueuedRequestStep__c>();

            for(XC_QueuedRequestStep__c gts : goToCallbackSteps){
                List<XC_QueuedRequestStep__c> callbacksStep = stepGroupedMap.get(gts.XC_QueuedRequest__c).QueuedRequestSteps__r;
                for(XC_QueuedRequestStep__c qrs : callbacksStep){
                    callbacksToEnqueue.add(qrs);
                }
            }

            System.Debug('CALLBACKS TO ENQUEUE:: ' + callbacksToEnqueue);


            if(!callbacksToEnqueue.isEmpty()){
                List<XC_QueuedRequestStep__c> cleanedList = new List<XC_QueuedRequestStep__c>();
                cleanedList.addAll(callbacksToEnqueue);
                XC_UTIL_QueuedRequestStep.setStepInProgressAndEmitEvent(cleanedList);
            }

        }



    }


}