/**
* @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 21/10/2020
* @description XC_SC035_EnqueueProvisioningStepsFuture – Schedulable classe used to automatically relaunch provisioning steps using future methods
*/
public with sharing class XC_SC035_EnqueueProvisioningStepsFuture implements Schedulable {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC035_EnqueueProvisioningSteps');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        enqueueStepsFuture(); 
    } 

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void enqueueStepsFuture() {
        String query = 'SELECT Id FROM XC_Provisioning_Step__c WHERE XC_ToBeRelaunchedFuture__c = true AND XC_Status__c = \'In Progress\' AND XC_AlreadyRelaunched__c = false LIMIT 50';
        List<XC_Provisioning_Step__c> listSteps = Database.query(query);
        for(XC_Provisioning_Step__c step:listSteps){
            step.XC_AlreadyRelaunched__c = true;
        }
        XC_UTIL_Sobject.updateListRecords(listSteps);   
        for(XC_Provisioning_Step__c step : listSteps){
            XC_UTIL_ProvisioningStep.executeStepFuture(step.Id);
        }
    }   
}