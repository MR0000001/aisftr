/**
* @author Marco Rosa - marco.rosa@nttdata.com, Salvatore Agrillo - salvatore.agrillo@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 21/10/2020
* @description XC_SC035_EnqueueProvisioningSteps – Schedulable classe used to automatically relaunch provisioning steps 
*/
public with sharing class XC_SC035_EnqueueProvisioningSteps implements Schedulable {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC035_EnqueueProvisioningSteps');

    /**
     * @description execute method
     * @param sc - SchedulableContext 
    */
    public void execute(SchedulableContext sc) { 
        enqueueSteps(); 
    } 

    /** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void enqueueSteps() {
        String query = 'SELECT Id FROM XC_Provisioning_Step__c WHERE XC_ToBeRelaunched__c = true AND XC_Status__c = \'In Progress\' AND XC_AlreadyRelaunched__c = false LIMIT 400';
        List<XC_Provisioning_Step__c> listSteps = Database.query(query);
        for(XC_Provisioning_Step__c step:listSteps){
            step.XC_AlreadyRelaunched__c = true;
        }
        XC_UTIL_Sobject.updateListRecords(listSteps);
        List<String> stepIdList = XC_UTIL_Sobject.getIds(listSteps);
        if(!stepIdList.isEmpty()){
            String stepidToExecute = stepIdList[0];
            stepIdList.remove(0);
            String stepIdListString = String.join(stepIdList, ';');
            if(!String.isBlank(stepidToExecute)){ 
                XC_StartFlowEvent__e event = new XC_StartFlowEvent__e();
                event.XC_StepToExecute__c = stepidToExecute;
                event.XC_StepIdList__c = stepIdListString; 
                XC_UTIL_PlatformEvent.publishListEvent(event);
            } 
            /*List<XC_Provisioning_Step__c> listPS = (List<XC_Provisioning_Step__c>) XC_UTIL_Sobject.selectAllFields(stepIdList, 'XC_Provisioning_Step__c'); 
            XC_UTIL_ProvisioningStep.insertEvent(listPS);*/
        }
    }   
}