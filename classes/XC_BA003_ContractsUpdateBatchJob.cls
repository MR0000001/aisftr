/**
 * @description       : batch to update Last Supply declared field on contract object
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 27-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
public with sharing class XC_BA003_ContractsUpdateBatchJob implements Schedulable,Database.Batchable<SObject>,Database.Stateful {
    
    private String query;

    public XC_BA003_ContractsUpdateBatchJob() {
        this.query = getBatchQuery();
    }

    private String getBatchQuery(){
        String query = 'SELECT Id,Name,XC_Contract__c,XC_LastSupplyDeclared__c '+
                       'FROM XC_ContractItem__c '+
                       'WHERE XC_LastSupplyDeclared__c = null '+
                       'AND XC_Contract__r.XC_LegalEntity__c = \'EnelSole\' '+
                       'AND (XC_Contract__r.XC_Segment__c = \'B2B\' OR XC_Contract__r.XC_Segment__c =\'B2G\' )';
        return query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope){
        List<XC_ContractItem__c> lstContractServices = (List<XC_ContractItem__c>) scope;

        Set<Id> setContractServiceIds = new Set<Id>();
        Map<String,XC_ContractItem__c> mapContractServiceNames = new Map<String,XC_ContractItem__c>();
        for (XC_ContractItem__c cont : lstContractServices) {
            setContractServiceIds.add(cont.Id);
            mapContractServiceNames.put('%'+cont.Name.substringBefore(' ')+'%', cont);
        }


        //update lookup on project phase (needed to be done first to get the right work orders)
        XC_BA003_ContractsUpdateBatchJob_U.setProjectPhasesContractServices(mapContractServiceNames);

        //get work orders
        Map<Id, Id> mapContractServiceWorkOrders = XC_BA003_ContractsUpdateBatchJob_U.getContractServiceWorkOrders(setContractServiceIds);
    
        //search for completed service appointments from work orders
        Map<Id, ServiceAppointment> mapContractServiceAppointments = XC_BA003_ContractsUpdateBatchJob_U.getServiceAppointmentsInfo(mapContractServiceWorkOrders);

        //update field on XC_LastSupplyDeclared__c on contract services
        List<XC_ContractItem__c> lstContractServicesToUpdate = new List<XC_ContractItem__c>();
        for (XC_ContractItem__c cont : lstContractServices) {
            if (mapContractServiceAppointments.get(cont.Id) == null) continue;

            cont.XC_LastSupplyDeclared__c = mapContractServiceAppointments.get(cont.Id).ActualEndTime != null ? mapContractServiceAppointments.get(cont.Id).ActualEndTime : mapContractServiceAppointments.get(cont.Id).XC_ActualEndDateTimestamp__c; 
            lstContractServicesToUpdate.add(cont);
        }

        System.debug('lstContractServicesToUpdate = '+lstContractServicesToUpdate);
        XC_UTIL_DML.updateRecords(lstContractServicesToUpdate);
        
    }

    public void execute(SchedulableContext sc){
        XC_BA003_ContractsUpdateBatchJob contractBatch = new XC_BA003_ContractsUpdateBatchJob();
        Database.executeBatch(contractBatch, 200);
    }

    public void finish(Database.BatchableContext bc){

    }
}