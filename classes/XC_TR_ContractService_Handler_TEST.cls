/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 05-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_TR_ContractService_Handler_TEST {
    @TestSetup
    static void makeData(){
        List<Account> lstAcc = XC_DF_Account.insertPartnerAccounts(1);
        List<Contract> lstContracts = XC_DF_Contract.createCondominiumContract(lstAcc);
        Id recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_Contract').getRecordTypeId();
        lstContracts[0].XC_LegalEntity__c = 'EnelSole';
        lstContracts[0].XC_Segment__c = 'B2G';
        lstContracts[0].XC_LastSupplyDeclared__c = null;
        lstContracts[0].RecordTypeId = recordTypeId;
        lstContracts[0].StartDate = System.today();
        lstContracts[0].EndDate = System.today().addDays(40); 
        insert lstContracts;

        
    }

    @IsTest
    static void methodTestInsert(){
        List<Contract> lstContracts = [SELECT Id,StartDate,EndDate FROM Contract LIMIT 1];
        Test.startTest();
        List<XC_ContractItem__c> lstContractServices = XC_DF_ContractService.createContractServices(2,lstContracts[0]);
        Test.stopTest();
        
    }

    @IsTest
    static void methodTestUpdate(){
        List<Contract> lstContracts = [SELECT Id,StartDate,EndDate FROM Contract LIMIT 1];
        List<XC_ContractItem__c> lstContractServices = XC_DF_ContractService.createContractServices(2,lstContracts[0]);

        Test.startTest();
        update lstContractServices;
        Test.stopTest();
        
    }

    @IsTest
    static void methodTestDelete(){
        List<Contract> lstContracts = [SELECT Id, StartDate,EndDate FROM Contract LIMIT 1];
        List<XC_ContractItem__c> lstContractServices = XC_DF_ContractService.createContractServices(2,lstContracts[0]);

        Test.startTest();
        delete lstContractServices;
        Test.stopTest();
        
    }
}