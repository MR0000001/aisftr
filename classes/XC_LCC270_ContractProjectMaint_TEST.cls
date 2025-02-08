/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 05-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_LCC270_ContractProjectMaint_TEST {
    @TestSetup
    static void makeData(){
        List<Account> lstAcc = XC_DF_Account.insertPartnerAccounts(1);
        List<Contract> lstContracts = XC_DF_Contract.createCondominiumContract(lstAcc);

        project_cloud__Project__c p = new project_cloud__Project__c();
        p.name ='ProgettoTestTemplate'; 
        p.project_cloud__Type__c = 'Maintenance Plan';
        p.project_cloud__IsTemplate__c = true;
        p.XC_LegalEntity__c = 'EnelSole';
        p.project_cloud__Units__c ='Duration';
        p.XC_Country__c = 'Italy';
	    insert p;   

        Id recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_Contract').getRecordTypeId();
        lstContracts[0].XC_LegalEntity__c = 'EnelSole';
        lstContracts[0].XC_Segment__c = 'B2G';
        lstContracts[0].XC_LastSupplyDeclared__c = null;
        lstContracts[0].RecordTypeId = recordTypeId;
        lstContracts[0].StartDate = System.today();
        lstContracts[0].EndDate = System.today().addDays(40); 
        lstContracts[0].XC_Project__c = p.Id;
        insert lstContracts;

        List<XC_ContractItem__c> lstContractServices = XC_DF_ContractService.createContractServices(2,lstContracts[0]);
    }

    @IsTest
    static void methodTestcreateProjectTasks(){
        Contract selectedContract = [SELECT Id FROM Contract LIMIT 1];
        Test.startTest();
        String results = XC_LCC270_ContractProjectMaintenance.createProjectTasks(selectedContract.Id);
        Test.stopTest();

        System.assertEquals('Project Tasks created', results);
        
    }

    @IsTest
    static void methodTestserviceFrequencyGreaterThanServiceDuration(){
        Contract selectedContract = [SELECT Id,EndDate FROM Contract LIMIT 1];
        selectedContract.EndDate = System.today().addDays(1);
        update selectedContract;

        List<XC_ContractItem__c> lstContractServices = [SELECT Id,XC_ServiceFrequency__c FROM XC_ContractItem__c LIMIT 5];
        lstContractServices[0].XC_ServiceFrequency__c = 45;
        update lstContractServices;

        Test.startTest();
        String results = XC_LCC270_ContractProjectMaintenance.createProjectTasks(selectedContract.Id);
        Test.stopTest();

        System.assertEquals('Project Tasks created', results);
        
    }
}