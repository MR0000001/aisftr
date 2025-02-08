/**
 * @description       : utility class for XC_BA003_ContractsUpdateBatchJob
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 27-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public with sharing class XC_BA003_ContractsUpdateBatchJob_U {

    /**
    * @description method to get a map with work order Id as key and contract service as par
    * @author pedro.danielalmeida@nttdata.com | 28-04-2022 
    * @param setContractServiceIds 
    * @return Map<Id, Id> 
    **/
    public static Map<Id, Id> getContractServiceWorkOrders(Set<Id> setContractServiceIds){
        Map<Id, Id> mapContractServiceWorkOrders = new Map<Id, Id>();

        for (WorkOrder wo : [SELECT Id,XC_ProjectPhase__c,XC_ProjectPhase__r.XC_ContractService__c 
                             FROM WorkOrder 
                             WHERE XC_ProjectPhase__r.XC_ContractService__c IN :setContractServiceIds]) {
            mapContractServiceWorkOrders.put(wo.Id, wo.XC_ProjectPhase__r.XC_ContractService__c);
        }
        return mapContractServiceWorkOrders;
    }

    /**
    * @description method to get service appointment info to update contract services
    * @author pedro.danielalmeida@nttdata.com | 28-04-2022 
    * @param mapContractServiceWorkOrders  
    * @return Map<Id, ServiceAppointment> 
    **/
    public static Map<Id, ServiceAppointment> getServiceAppointmentsInfo(Map<Id, Id> mapContractServiceWorkOrders){
        Map<Id, ServiceAppointment> mapContractServiceAppointments = new Map<Id, ServiceAppointment>();

        for (ServiceAppointment serviceApp : [SELECT Id,ParentRecordType,ParentRecordId,Status,XC_Configuration_Item__c,ActualEndTime,XC_ActualEndDateTimestamp__c
                                              FROM ServiceAppointment 
                                              WHERE Status = 'Completed' 
                                              AND ParentRecordId IN :mapContractServiceWorkOrders.keySet()
                                              ORDER By ActualEndTime ASC]) {
                                                
            if (mapContractServiceWorkOrders.get(serviceApp.ParentRecordId) == null) continue;
            mapContractServiceAppointments.put(mapContractServiceWorkOrders.get(serviceApp.ParentRecordId), serviceApp);  
        }
        return mapContractServiceAppointments;
    }

    /**
    * @description update project phases with contract service lookup
    * @author pedro.danielalmeida@nttdata.com | 27-05-2022 
    * @param mapContractServiceNames 
    **/
    public static void setProjectPhasesContractServices(Map<String,XC_ContractItem__c> mapContractServiceNames){
        List<project_cloud__Project_Phase__c> lstPhasesToUpdate = new List<project_cloud__Project_Phase__c>();

        for (project_cloud__Project_Phase__c projPhase : [SELECT Id,Name,XC_ContractService__c
                                                          FROM project_cloud__Project_Phase__c
                                                          WHERE Name LIKE :mapContractServiceNames.keySet()
                                                          AND XC_ContractService__c = null]) {
            
            if (mapContractServiceNames.get('%'+projPhase.Name.substringBefore(' ')+'%') == null) continue;
            projPhase.XC_ContractService__c = mapContractServiceNames.get('%'+projPhase.Name.substringBefore(' ')+'%').Id;
            lstPhasesToUpdate.add(projPhase);
        }

        XC_UTIL_DML.updateRecords(lstPhasesToUpdate);
    }
}