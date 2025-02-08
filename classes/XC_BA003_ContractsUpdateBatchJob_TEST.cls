/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 27-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_BA003_ContractsUpdateBatchJob_TEST {
    @TestSetup
    static void makeData(){
        //FSL.GlobalAPIS.addStatusTransition('None', 'Completed');
        List<Account> lstAcc = XC_DF_Account.insertPartnerAccounts(1);
                       
        List<Contract> lstContracts = XC_DF_Contract.createCondominiumContract(lstAcc);

        project_cloud__Project__c newProject = new project_cloud__Project__c();     
        newProject.name = 'Maintenance Service Project Contract:'+' '+lstContracts[0].ContractNumber;
        newProject.project_cloud__Type__c = 'Maintenance Plan';
        newProject.ccpe_ocp__Account__c = lstContracts[0].AccountId;
        newProject.xc_country__c = lstContracts[0].Account.XC_Country__c;
        newProject.project_cloud__Units__c = 'Duration';
        newProject.XC_LegalEntity__c = lstContracts[0].XC_LegalEntity__c; 
        newProject.XC_Segment__c = lstContracts[0].XC_Segment__c;
        insert newProject;

        Id recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_Contract').getRecordTypeId();
        lstContracts[0].XC_LegalEntity__c = 'EnelSole';
        lstContracts[0].XC_Segment__c = 'B2G';
        lstContracts[0].XC_LastSupplyDeclared__c = null;
        lstContracts[0].RecordTypeId = recordTypeId;
        lstContracts[0].StartDate = System.today();
        lstContracts[0].EndDate = System.today().addDays(40); 
        lstContracts[0].XC_Project__c = newProject.Id;
        insert lstContracts;

        List<XC_ContractItem__c> lstContractServices = XC_DF_ContractService.createContractServices(2,lstContracts[0]);
        List<XC_ContractItem__c> lstContractServicesInfo = [SELECT Id, Name,XC_ProdName__c FROM XC_ContractItem__c WHERE Id IN :lstContractServices];

        List<project_cloud__Project_Phase__c> lstProjectPhases = new List<project_cloud__Project_Phase__c>();
        
            project_cloud__Project_Phase__c phase1 = new project_cloud__Project_Phase__c(
                name = lstContractServicesInfo[0].Name+' '+lstContractServicesInfo[0].XC_ProdName__c+' - '+'Phase Reminder',
                project_cloud__Project__c = lstContracts[0].XC_Project__c,
                XC_ContractService__c = null
            );
            lstProjectPhases.add(phase1);
            project_cloud__Project_Phase__c phase2 = new project_cloud__Project_Phase__c(
                name = lstContractServicesInfo[1].Name+' '+lstContractServicesInfo[1].XC_ProdName__c+' - '+'Phase Reminder',
                project_cloud__Project__c = lstContracts[0].XC_Project__c,
                XC_ContractService__c = lstContractServicesInfo[1].Id
            );
            lstProjectPhases.add(phase2);
        
        insert lstProjectPhases;
        
        List<WorkOrder> lstWO = XC_DF_WorkOrder.createWorkOrders(2,'Malfunctioning');
        lstWO[0].Contract__c = lstContracts[0].Id;
        lstWO[0].XC_LegalEntity__c = 'EnelSole';
        lstWO[0].recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        lstWo[0].XC_ProjectPhase__c = lstProjectPhases[0].Id;
        
        lstWO[1].Contract__c = lstContracts[0].Id;
        lstWO[1].XC_LegalEntity__c = 'EnelSole';
        lstWO[1].recordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_WorkOrder').getRecordTypeId();
        lstWo[1].XC_ProjectPhase__c = lstProjectPhases[1].Id;
        insert lstWO;

        List<ServiceAppointment> lstSA = XC_DF_ServiceAppointment.createServiceAppointment(lstWO);
        lstSA[0].SchedStartTime=  (System.now()).addHours(2);
        lstSA[0].SchedEndTime = (System.now()).addHours(4);
        lstSA[0].ArrivalWindowEndTime =(System.now()).addHours(4);
        lstSA[0].ArrivalWindowStartTime = (System.now()).addHours(4);
        lstSA[0].ActualEndTime = (System.now()).addHours(4);
        lstSA[0].XC_ActualEndDateTimestamp__c = (System.now()).addHours(4);
        insert lstSA;

        lstWO[0].Status = 'In Progress';
        update lstWO;

        lstWO[0].status = 'Completed';
        update lstWO;

        
        /* lstSA[0].Status = 'Scheduled';
        update lstSA; 

        lstSA[0].Status = 'Dispatched';
        update lstSA;

        lstSA[0].Status = 'In Progress';
        update lstSA;

        lstSA[0].Status = 'Completed';
        lstSA[0].ActualEndTime = System.now().addHours(6);
        update lstSA; */
    }

    @IsTest
    static void methodTestBatch(){
        
        Test.startTest();
        XC_BA003_ContractsUpdateBatchJob batch = new XC_BA003_ContractsUpdateBatchJob();
        Database.executeBatch(batch,200);
        Test.stopTest();
        
    }

    @IsTest
    static void methodTestSchedule(){
        
        Test.startTest();
        XC_BA003_ContractsUpdateBatchJob batch = new XC_BA003_ContractsUpdateBatchJob();
        String cron = '0 0 * * * ?';
        String jobId = System.schedule('Test Batch Schedule',cron,batch);
        Test.stopTest();
        
        CronTrigger ct = [SELECT TimesTriggered, NextFireTime,CronExpression
                          FROM CronTrigger 
                          WHERE Id = :jobID];
        System.assertEquals(cron, ct.CronExpression, 'Should schedule!');
    }
}