/**
 * @author Nicola Mariniello nmariniello@deloitte.it
 * @date Creation 28/03/2022
 * @date Last Modification
 * @description Invocable class for XC_FL_Provisioning_CreateSubscriptionNoZeroPrice
 */


public without sharing class XC_IN088_CreateSubscriptionZeroPrice {
	
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN088_CreateSubscriptionZeroPrice');


    /** 
     * @author Federico Amici - federico.amici@nttdata.com
     * @date 18/03/2019
     * @description Wrapper used by flow
     */
    public class InputWrapper{ 
        @Invocablevariable
        public String operation;
        @Invocablevariable
        public String stepId;
        @Invocablevariable
        public String configurationItemId;
    }
    
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description doActions
     * @param inputWrapperList the input wrapper list
     */
    @InvocableMethod 
    public static void doActions(List<InputWrapper> inputWrapperList) { 
    	
        String operation = '';
        String configurationItemId = '';
        String stepId = '';
        for(InputWrapper wr : inputWrapperList) {
            operation = wr.operation;
            stepId = wr.stepId;
            configurationItemId = wr.configurationItemId;
        }
        if(String.isBlank(operation) || String.isBlank(stepId)) {
            return;
        }
        
        if(operation == Label.XC_CL_CheckChildStepsOperation && String.isNotBlank(configurationItemId)) {
            checkChildSteps(configurationItemId, stepId);
        } else if (operation == Label.XC_CL_RelaunchStepOperation) {
            relaunchStep(stepId);
        }
    }
    
    
    /**
     * @author Nicola Mariniello nmariniello@deloitte.it
     * @description checkChildSteps
     * @param configurationItemFatherId
     * @param stepId
     */
    public static void checkChildSteps(String configurationItemFatherId, String stepId) { 
        
        Map<Id, XC_Provisioning_Step__c> stepMap = new Map<Id, XC_Provisioning_Step__c>([SELECT Id
                                                                                         FROM XC_Provisioning_Step__c
                                                                                         WHERE XC_Configuration_Item__r.NE__Root_Order_Item__c =: configurationItemFatherId AND XC_Flow_API_Name__c =: Label.XC_CL_Provisioning_CreateSubscriptionNoZeroPrice_Flow AND (XC_Status__c =: Label.XC_CL_Provisioning_Step_InProgress OR XC_Status__c =: Label.XC_CL_Provisioning_Step_NotStarted)]);
        if(stepMap.isEmpty()) {
            XC_IN018_CreateZQuote.InputWrapper wr = new XC_IN018_CreateZQuote.InputWrapper();
            wr.stepId = stepId;
            List<XC_IN018_CreateZQuote.InputWrapper> inputWrapperList = new List<XC_IN018_CreateZQuote.InputWrapper>();
            inputWrapperList.add(wr);
            XC_IN018_CreateZQuote.createZquote(inputWrapperList);
        }
    }
    
    
    /**
    * @author Nicola Mariniello - nmariniello@deloitte.it
    * @description stepId
    * @param 
    */
    @future(callout=true)
    public static void relaunchStep(Id stepId) {
        List<XC_Provisioning_Step__c> listSteps = XC_UTIL_Sobject.selectAllFields(stepId);
        XC_UTIL_ProvisioningStep.executeSteps(listSteps);
    }
    
}