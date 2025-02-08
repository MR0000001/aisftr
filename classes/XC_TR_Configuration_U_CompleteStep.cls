/**
 * @author Nicola Mariniello nmarriniello@deloitte.it
 * @date Creation 29/03/2021
 * @date Modification dd/mm/yyyy
 * @description XC_TR_Configuration_U_CompleteStep – Class to Complete the Provisioning Step
 */


public without sharing class XC_TR_Configuration_U_CompleteStep {


    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Configuration_U_CompleteStep');


    /**
     * @description on status update. 
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void onStatusUpdate(List<NE__Order__c> listNew, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew) {

        List<String> fieldList = new List<String> {'XC_Status__c'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }

        Set<String> stepIds = new Set<String>();
        for(NE__Order__c conf : listChanged) {
            if(conf.XC_Status__c == Label.XC_CL_Configuration_Closed && String.isNotBlank(conf.XC_ProvisioningStepToComplete__c)) {
                stepIds.add(conf.XC_ProvisioningStepToComplete__c);
            }
        }
        if(stepIds.isEmpty()) {
            return;
        }

        Map<Id, XC_Provisioning_Step__c> stepsMap = new Map<Id, XC_Provisioning_Step__c>([SELECT Id, XC_Status__c
                                                                                            FROM XC_Provisioning_Step__c
                                                                                            WHERE Id IN :stepIds AND XC_Status__c = :Label.XC_CL_Provisioning_Step_InProgress]);
        for(XC_Provisioning_Step__c step : stepsMap.values()) {
            step.XC_Status__c = Label.XC_CL_Completed_OK;
        }

        if(!stepsMap.isEmpty()) {
            XC_UTIL_SObject.updateListRecords(stepsMap.values());
        }
    }

}