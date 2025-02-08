/**
* @author Dario Tramontin - dtramontin@deloitte.it 
* @date Creation 24/10/2019
* @date Modification dd/mm/yyyy
* @description
**/

public without sharing class XC_TR_Config_U_SetParentCaseStatus {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Config_U_SetParentCaseStatus');

    public static void setParentCaseStatusInPending(List<NE__Order__c> confList, Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Config_U_SetParentCaseStatus - setParentCaseStatusInPending');
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Status__c'}, mapOld, mapNew); 
        List<Case> caseToUpdate = new List<Case>();
        List<String> confIds = new List<String>(); 
        for (NE__Order__c conf : listChanged){ 
            if(conf.XC_CaseId__c != null){
                confIds.add(conf.Id);
            }
        }
        if(confIds.isEmpty()){
            return;
        }
        Map<Id,NE__Order__c> mapCase = new Map<Id,NE__Order__c>([SELECT Id, XC_CaseId__c, XC_CaseId__r.Status FROM NE__Order__c WHERE Id IN : confIds]); 
        for(NE__Order__c conf : listChanged){
            if (conf.XC_Status__c.equals(Label.XC_CL_Configuration_OrderInProgress) && mapCase.get(conf.Id).XC_CaseId__c != null && mapCase.get(conf.Id).XC_CaseId__r.Status == Label.XC_CL_Case_InProgress ){ 
                Case c = new Case(Id= mapCase.get(conf.Id).XC_CaseId__c);
                c.Status = Label.XC_CL_Case_Pending;
                caseToUpdate.add(c);
                System.debug('update case Pending');
            }
        }
        XC_UTIL_Sobject.updateListRecords(caseToUpdate);  
    }

    public static void manageCasePendingConf(List<NE__Order__c> listNew,Map<Id,NE__Order__c> mapOld, Map<Id,NE__Order__c> mapNew){
        XC_UTIL_Case.manageCasePendingConf(listNew,mapOld,mapNew);
    }
}