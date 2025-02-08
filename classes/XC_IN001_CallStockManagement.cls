/**
* @author Marco Rosa - marco.rosa@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 26/11/2018
* @date Modification dd/mm/yyyy
* @description XC_IN001_CallStockManagement – public class with invocable method. It is invoked by a Flow to call Stock Management
*/

public without sharing class XC_IN001_CallStockManagement {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_IN001_CallStockManagement');

    /** 
     * @author Marco Rosa - marco.rosa@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Input Wrapper for integration with flow
     */
    public class InputWrapper{
        @Invocablevariable
        public String stepId;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com - Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Call stock management. 
     * @param inputWrapperList - the parameters passed by flow
     */ 
    @InvocableMethod
    public static void callStockManagement(List<InputWrapper> inputWrapperList) {        
        if(inputWrapperList.isEmpty()){
            return;
        }         
        List<String> stepIdList = new List<String>();
        for(InputWrapper inputWr : inputWrapperList){
            stepIdList.add(inputWr.stepId);
        }
        XC_Provisioning_Step__c step = getProvisioningStep(stepIdList);
        manageOKs(step);
    } 

    /**
     * @description manageOKs
     * @param step
     */ 

    private static void manageOKs (XC_Provisioning_Step__c step){
        step.XC_Status__c = Label.XC_CL_Completed_Ok;
        XC_UTIL_Sobject.updateRecord(step);
    }

    /**
     * @description getProvisioningStep description
     * @param stepIdList stepIdList description
     * @return List<XC_Provisioning_Step__c>
    */ 

    private static XC_Provisioning_Step__c getProvisioningStep(List<String> stepIdList){
        if(!Schema.sObjectType.XC_Provisioning_Step__c.isAccessible()){
            return null;
        }
        return  [SELECT Id, XC_Configuration_Item__c 
                    FROM XC_Provisioning_Step__c 
                    WHERE Id IN: stepIdList LIMIT 1];  
    }
}