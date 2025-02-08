/**
 * Created by sbarbera on 04/01/22.
 */

public with sharing class XC_TR_PPM_ProjectTask_FillFields {
    public static void populateOwner_LCL_excecutor(List<project_cloud__Project_Task__c> listNew){

        for(project_cloud__Project_Task__c pt : listNew){

            if(pt.XC_TaskType__c == 'Partner Engagement') {
                if (pt.XC_PreferredPartner__c != null && pt.XC_LCLHolder__c == null && pt.XC_Executor__c == null) {
                    pt.XC_LCLHolder__c = pt.XC_PreferredPartner__c;
                    pt.XC_Executor__c = pt.XC_PreferredPartner__c;
                } else if (pt.XC_PreferredPartner__c == null && pt.XC_LCLHolder__c == null && pt.XC_Executor__c != null) {
                    pt.XC_LCLHolder__c = pt.XC_Executor__c;
                    pt.XC_PreferredPartner__c = pt.XC_Executor__c;
                }
            }else if(pt.XC_TaskType__c == 'Material Supply' || pt.XC_TaskType__c == 'Field Service Activity'){
                if(pt.XC_Executor__c != null && pt.XC_PreferredPartner__c == null){
                    pt.XC_PreferredPartner__c = pt.XC_Executor__c;
                }else if(pt.XC_Executor__c == null && pt.XC_PreferredPartner__c != null){
                    pt.XC_Executor__c = pt.XC_PreferredPartner__c;
                }
            }
        }
    }

    public static void onUpdate(Map<Id,project_cloud__Project_Task__c> mapOld, Map<Id,project_cloud__Project_Task__c> mapNew){
        List<String> fieldList = new List<String>{'XC_PreferredPartner__c','XC_LCLHolder__c','XC_Executor__c'};
        List<project_cloud__Project_Task__c> projectTaskListChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOld, mapNew);

        if(!projectTaskListChanged.isEmpty()){
            populateOwner_LCL_excecutor(projectTaskListChanged);
        }

    }
}