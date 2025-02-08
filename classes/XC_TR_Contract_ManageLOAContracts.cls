public with sharing class XC_TR_Contract_ManageLOAContracts {

    public static void updateServiceAccounts(Map<Id, Contract> mapOld, Map<Id, Contract> mapNew){
        Set<Id> loaContracts = new Set<Id>();
        Id loartid = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_LOA').getRecordTypeId();
        for(Contract cntr : mapNew.values())
        {
            if(cntr.RecordTypeId == loartid && cntr.XC_LOA_Signed__c != null && cntr.XC_LOA_Signed__c && ( mapOld == null || !mapOld.containsKey(cntr.Id) || mapOld.get(cntr.Id).XC_LOA_Signed__c != cntr.XC_LOA_Signed__c ))
            {
                loaContracts.add(cntr.Id);
            }
        }

        if(!loaContracts.isEmpty())
        {
            Map<Id, Service_Account__c> toupdate= new Map<Id, Service_Account__c>();
            for(XC_Service_Account_LOA__c  serviceAccountRelated : [SELECT XC_Service_Account__c, XC_Service_Account__r.XC_LOAContract__c, XC_Contract__c FROM XC_Service_Account_LOA__c WHERE XC_Contract__c in :loaContracts])
            {
                if(serviceAccountRelated.XC_Service_Account__r.XC_LOAContract__c != serviceAccountRelated.XC_Contract__c && !toupdate.containsKey(serviceAccountRelated.XC_Service_Account__c))
                {
                    toupdate.put(serviceAccountRelated.XC_Service_Account__c, new Service_Account__c(Id = serviceAccountRelated.XC_Service_Account__c, XC_LOAContract__c = serviceAccountRelated.XC_Contract__c));
                }
            }
            if(!toupdate.isEmpty())
            {
                List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_Sobject.updateListRecords(toupdate.values());
            }
        }
    }
 public static void updateContractLOAStatus(List<Contract> listNew){
        Id loartid = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_LOA').getRecordTypeId();
        for(Contract cntr : listNew)
        {
            if(cntr.RecordTypeId == loartid && cntr.XC_LOA_Signed__c == false)
            {
                cntr.Status = 'New';
            }
            else if(cntr.RecordTypeId == loartid && cntr.XC_LOA_Signed__c == true && cntr.XC_LOA_End_Date__c >= system.today())
            {
                cntr.Status = 'Authorized';
            }
             else if(cntr.RecordTypeId == loartid && cntr.XC_LOA_Signed__c == true && cntr.XC_LOA_End_Date__c < system.today())
            {
                cntr.Status = 'Expired';
            }
        }
 }
}