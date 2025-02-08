/**
 * @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date Creation 21/11/2018
 * @date Modification dd/mm/yyyy
 * @description XC_TR_ProvisioningStep_U_StartProcess – Class to trigger the Provisioing Process.
 */

public without sharing class XC_TR_ProvisioningStep_U_StartProcess { 

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ProvisioningStep_U_StartProcess');

    /** @description StepsToEnqueueWrapper */
    public class StepsToEnqueueWrapper {
        public Integer newStepSeq;
        public List<XC_Provisioning_Step__c> listSteps = new List<XC_Provisioning_Step__c>();
        Set<String> completedCodes = new Set<String>();
        List<XC_Provisioning_Step__c> stepsToEnqueue = new List<XC_Provisioning_Step__c>();
    }

    /**
     * @description On after update. 
     * @param mapOld the map old
     * @param mapNew the map new
     */ 

    public static void onAfterUpdate(Map<Id,SObject> mapOld, Map<Id,SObject> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@afterUpdate');
        List<String> fieldList = new List<String>{'XC_Status__c'};
        List<XC_Provisioning_Step__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        List<XC_Provisioning_Step__c> listCompletedOKSteps = new List<XC_Provisioning_Step__c>();
        for(XC_Provisioning_Step__c step : listChanged){
            if(XC_UTIL_ProvisioningStep.isCompleted(step.XC_Status__c)){
                listCompletedOKSteps.add(step);
            } 
        }
        if(listCompletedOKSteps.isEmpty()){ 
            return;
        }
        List<String> orderItemListId = XC_UTIL_Sobject.getListFieldValues(listCompletedOKSteps, 'XC_Configuration_Item__c');
        if(orderItemListId.isEmpty()){     
            return;
        }
        Map<Id,NE__OrderItem__c> mapOli = new Map<Id,NE__OrderItem__c>([
            SELECT Id,
                (SELECT 
                    Id,XC_Step_Order__c,XC_LegalEntity__c,XC_Segment__c,XC_PlatformEventName__c, XC_Template_Name__c, XC_Configuration_Item__c,XC_Status__c,XC_Step_Code__c,XC_Mandatory_Steps__c,XC_Synchronous__c,XC_Flow_API_Name__c,
                    XC_Country__c, XC_ConfigurationId__c   
                FROM Provisioning_Steps__r)  
            FROM NE__OrderItem__c 
            WHERE Id IN:orderItemListId
        ]);   
        List<XC_Provisioning_Step__c> stepsToEnqueue = new List<XC_Provisioning_Step__c>();    
        for(XC_Provisioning_Step__c step :  listCompletedOKSteps){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'step->' + step);
            Integer newStepSeq = Integer.valueOf(step.XC_Step_Order__c) + 1;
            List<XC_Provisioning_Step__c> listSteps = mapOli.get(step.XC_Configuration_Item__c).Provisioning_Steps__r;
            Set<String> completedCodes = getCompletedStepCodes(listSteps);

            StepsToEnqueueWrapper stepsWrapper = new StepsToEnqueueWrapper();
            stepsWrapper.newStepSeq = newStepSeq;
            stepsWrapper.listSteps = listSteps;
            stepsWrapper.completedCodes = completedCodes;
            stepsWrapper.stepsToEnqueue = stepsToEnqueue;
            insertStepsToEnqueue(stepsWrapper);                    
            stepsToEnqueue = stepsWrapper.stepsToEnqueue;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'stepToEnqueue?->' + stepsToEnqueue);   
        if(!stepsToEnqueue.isEmpty()){
            XC_UTIL_ProvisioningStep.enqueueStepList(stepsToEnqueue); 
        }  
    }

    /**
     * @description Steps To Enqueue
     * @param stepsWrapper - StepsToEnqueueWrapper
     */
    private static void insertStepsToEnqueue(StepsToEnqueueWrapper stepsWrapper) {
        for(XC_Provisioning_Step__c newStep : stepsWrapper.listSteps) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'newStep->' + newStep);
            if(stepsWrapper.newStepSeq == newStep.XC_Step_Order__c && newStep.XC_Status__c == Label.XC_CL_Provisioning_Step_NotStarted){  
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'isUnlocked?->' + isUnlocked(newStep, stepsWrapper.completedCodes));    
                if(isUnlocked(newStep, stepsWrapper.completedCodes)){
                    stepsWrapper.stepsToEnqueue.add(newStep);  
                }
            }
        }
    }
    
    /**
     * Gets the completed step codes.
     *
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param listSteps the list steps
     * @return the completed step codes
     * @description Method to retrieve complete step codes
     */

    private static Set<String> getCompletedStepCodes(List<XC_Provisioning_Step__c> listSteps){
        Set<String> setCompletedSteps = new Set<String>();
        for(XC_Provisioning_Step__c step : listSteps){ 
            if(XC_UTIL_ProvisioningStep.isCompleted(step.XC_Status__c)){
                setCompletedSteps.add(step.XC_Step_Code__c);
            } 
        }
        return setCompletedSteps;
    }

    /**
     * Checks if is unlocked.
     *
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param newStep the new step
     * @param completedCodes the completed codes
     * @return the boolean
     * @description Method to check if a step can be started (all mandatory steps are completed)
     */

    private static Boolean isUnlocked(XC_Provisioning_Step__c newStep, Set<String> completedCodes){ 
        Boolean isUnlocked = true;
        List<String> codesLocking = new List<String>();
        if(!String.isBlank(newStep.XC_Mandatory_Steps__c)){
            codesLocking = newStep.XC_Mandatory_Steps__c.split('-');
        }
        for(String code : codesLocking){
            if(!completedCodes.contains(code)){
                isUnlocked = false;
                break;
            }
        }
        return isUnlocked;
    } 
    
    //20210112_DD_ERR_03 - start
    /**
     * @description On before update. 
     * @param mapOld the map old
     * @param mapNew the map new
     */ 

    public static void onBeforeUpdate(Map<Id,SObject> mapOld, Map<Id,SObject> mapNew){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@beforeUpdate');
        List<String> provStepLabelList = new List<String>();
        Set<Id> provisioningStepIds = new Set<Id>();
        XC_CS_UtilityGlobalValues__c stepLabelString = XC_CS_UtilityGlobalValues__c.getValues('XC_TR_ProvisStepLabelSentToZBilling');
        if(stepLabelString!=null && String.iSNotBlank(stepLabelString.Value__c) && stepLabelString.Value__c.contains(';')){
            provStepLabelList = stepLabelString.Value__c.split(';');
        }
        
        for(Id stepId : mapNew.keySet()){
            if((String.valueOf(mapNew.get(stepId).get('XC_Status__c')) != String.valueOf(mapOld.get(stepId).get('XC_Status__c'))) && (String.valueOf(mapNew.get(stepId).get('XC_Status__c'))).equalsIgnoreCase(Label.XC_CL_Completed_Ok)){
                if(String.isNotBlank(String.valueOf(mapNew.get(stepId).get('XC_StepLabel__c'))) && provStepLabelList.contains(String.valueOf(mapNew.get(stepId).get('XC_StepLabel__c')))){
                    provisioningStepIds.add(stepId);
                }
            }
        }
        if(!provisioningStepIds.isEmpty()){ 
            Map<Id, XC_Provisioning_Step__c> provStepMap = new Map<Id, XC_Provisioning_Step__c>([SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.XC_ZQuoteId__c 
                                                          FROM XC_Provisioning_Step__c
                                                         WHERE ID IN:provisioningStepIds]);
            if(!provStepMap.isEmpty()){
                Map<String, String> zQuoteToCheckIds = new Map<String, String>();
                for(Id stepId :provStepMap.keySet()){
                    if(String.isNotBlank(provStepMap.get(stepId).XC_Configuration_Item__c) && String.isNotBlank(provStepMap.get(stepId).XC_Configuration_Item__r.XC_ZQuoteId__c)){
                        zQuoteToCheckIds.put(String.valueOf(stepId), String.valueOf(provStepMap.get(stepId).XC_Configuration_Item__r.XC_ZQuoteId__c));
                    }
                }
                Map<Id, zqu__Quote__c> quoteMap = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__Status__c FROM zqu__Quote__c WHERE Id = :zQuoteToCheckIds.values()]);
                for(XC_Provisioning_Step__c provStep :provStepMap.values()){
                    if(!zQuoteToCheckIds.containsKey(provStep.Id) || 
                       (zQuoteToCheckIds.containsKey(provStep.Id) && !quoteMap.containsKey(zQuoteToCheckIds.get(provStep.Id))) || 
                       (zQuoteToCheckIds.containsKey(provStep.Id) && quoteMap.containsKey(zQuoteToCheckIds.get(provStep.Id)) && 
                        (String.isBlank(quoteMap.get(zQuoteToCheckIds.get(provStep.Id)).zqu__Status__c) || quoteMap.get(zQuoteToCheckIds.get(provStep.Id)).zqu__Status__c != 'Sent to Z-Billing'))){
                            if(Trigger.isExecuting) Trigger.newMap.get(provStep.Id).addError(Label.XC_CL_ProvisioningStepNotSentToZBilling);
                        }
                }
            }
        }
    }
    //20210112_DD_ERR_03 - end
    
}