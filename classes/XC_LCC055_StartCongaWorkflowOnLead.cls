/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 12/12/2018  
* @date Modification dd/mm/yyyy
* @description XC_LCC055_StartCongaWorkflowOnLead – Controller for XC_LCP055_StartCongaWorkflowOnLead Component 
*/

public without sharing class XC_LCC055_StartCongaWorkflowOnLead {
    
    /**
     * @description The Class ResultWrapper.
     */
    public class ResultWrapper{
        
        /** @description The success. */
        @AuraEnabled public Boolean success {get;set;}
        
        /** @description The message. */
        @AuraEnabled public String message {get;set;}
    }

    /**
     * @description Conga workflow get started.
     *
     * @param leadId the lead id
     * @return the result wrapper
     */
    @AuraEnabled        
    public static ResultWrapper congaWorkflowGetStarted(String leadId){
        XC_UTIL_Sobject.WrapperResult updateWrapperResult = new XC_UTIL_Sobject.WrapperResult();
        ResultWrapper rw = new ResultWrapper();
        Lead myLead = new Lead(Id = leadId);
        System.debug('@@@@@myLead---->'+myLead);
        myLead.XC_StartCongaWorkflow__c = true;
        updateWrapperResult = XC_UTIL_Sobject.updateRecord(myLead);
        rw.success = updateWrapperResult.success;  
        if(updateWrapperResult.success){
            //rw.success = true;
            rw.message = 'Documents process creation started';
            myLead.XC_StartCongaWorkflow__c = false;
        } else{
            //rw.success = false;
            rw.message = updateWrapperResult.errorMessage;
            myLead.XC_StartCongaWorkflow__c = false;            
        } 
        XC_UTIL_Sobject.updateRecord(myLead);
        return rw;
    }
}