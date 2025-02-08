/**
* @author Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
* @date Creation 19/04/2019
* @date Modification 08/05/2019 Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description Handler for Case Trigger
*/ 

public without sharing class XC_TR_CustomerInteraction_Handler implements XC_I_TriggerHandler {

    public static Map<System.TriggerOperation, Boolean> mapTriggerStopped = new Map<System.TriggerOperation, Boolean>();
    public static Map<System.TriggerOperation, Map<String, Object>> mapEventRecordsToBeReProcessed = new Map<System.TriggerOperation, Map<String, Object>>();
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_CustomerInteraction_Handler');
    
    /**
     * @author  Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
     * @description Method to stop recursion of the same event method in the same transaction  
     * @return Boolean true if recursion must be stopped 
    */
    public Boolean stopRecursion() {   
        return XC_UTIL_Trigger.stopRecursion(Trigger.operationType, mapTriggerStopped, mapEventRecordsToBeReProcessed);
    }
    
    /**
     * @author  Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
     * @description Method to set to true the stop recursion variable on the current trigger event  
    */
    public void executedTrigger(){ 
        mapTriggerStopped.put(Trigger.operationType, false);//TEST FALSE
    }
    
    /**
     * @author  Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
     * @description Method to be executed on before insert
     * @param mapNewS - list of new values of records
    */
    public void onAfterInsert(Map<Id, SObject> mapNewS){
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            // et4ae5.triggerUtility.automate('XC_Customer_Interaction__c');
            List<XC_Customer_Interaction__c> listNew = mapNewS.values();
            XC_UTIL_CustomerInteractionGeneration.triggeredSendFilter(listNew);
            XC_TR_CustomerInteraction_U_SendSMS.setPhoneOnCustomerInteraction(listNew);
            XC_TR_CustomerInteraction_U_surveyURL.checkSurveyOnCustomerInteraction(listNew); //Marco Ottaviano -- Set Dinamically the URL On CI
            XC_TR_CustomerInteraction_U_SendSMS.sendSMSbyChannel(listNew);   /* Lead 2.1.1.2 - Nicola Mariniello - 26/06/2019 */
        	XC_TR_CustomerInteraction_U_Pipeline.manageStage( (Map<Id, XC_Customer_Interaction__c>)mapNewS);
    }
    
    /**
     * @author  Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
     * @description Method to be executed on before insert
     * @param listNew - list of new values of records
    */
    public void onBeforeInsert(List<SObject> listNew){
        
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType);          
        XC_UTIL_CustomerInteractionGeneration_U.populateLookupBankTransferKO(listNew);
        XC_UTIL_CustomerInteractionGeneration.setPreferredLanguageOnNewCI(listNew);
        XC_UTIL_CustomerInteractionGeneration_U.populateCIforStartTravel(listNew);
        XC_UTIL_CustomerInteractionGeneration_U.setSurveyIdForCaseClosed(listNew);  
        XC_TR_CustomerInteraction_setCC.setCCRecipient(listNew);
        XC_UTIL_CustomerInteractionGeneration_UU.setCCRecipientPartnerContact(listnew);
        XC_UTIL_CustomerInteractionGeneration_UU.generateWelcomeContractChild(listNew);
        XC_UTIL_CustomerInteractionGeneration_U.populateAccountBalance(listNew);
    }
    
    /**
     * @author  Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
     * @description Method to be executed on before insert
     * @param mapOldS - list of old values of records
     * @param mapNewS - list of new values of records
    */
    public void onBeforeUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
                    XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
        
    }
    
    /**
     * @author  Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
     * @description Method to be executed on before insert
     * @param mapOldS - list of old values of records
     * @param mapNewS - list of new values of records
    */
    public void onAfterUpdate(Map<Id, SObject> mapOldS, Map<Id, SObject> mapNewS){
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
            mapNews = XC_UTIL_Trigger.checkMapNew(Trigger.operationType, mapNewS, mapEventRecordsToBeReProcessed);  
            //et4ae5.triggerUtility.automate('XC_Customer_Interaction__c'); 
            List<XC_Customer_Interaction__c> listNew = mapNewS.values();
            //NON DEPLOYARE I METODI COMMENTATI 
            //XC_UTIL_CustomerInteractionGeneration.triggeredSendFilter(listNew);
     }
    
    
    /**
     * @author  Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
     * @description Method to be executed on before insert
     * @param mapOld
    */
    public void onAfterDelete(Map<Id, SObject> mapOld) {
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        
        
    }
        
    /**
     * @author  Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
     * @description Method to be executed on before insert
     * @param mapNew -> new value of record
    */
    public void onAfterUndelete(Map<Id, SObject> mapNew) {
        
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        
        
    }
    
    /**
     * @author  Riccardo Cossu, riccardo.cossu@nttdata.com - Federico Amici, federico.amici@nttdata.com
     * @description Method to be executed on before insert
     * @param mapOld
    */
    public void onBeforeDelete(Map<Id, SObject> mapOld) {
                
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Trigger on ' + Trigger.operationType); 
        
        
    }
    
}