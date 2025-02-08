/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 04-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public without sharing class XC_IN088_CreateContractServices_TEST {
    @TestSetup
    static void makeData(){
        XC_MaintenanceContractServices__c contractServiceSetup = new XC_MaintenanceContractServices__c();
        contractServiceSetup.XC_ContractServicesAvailable__c = 'ricambio lampade a programma\r\n'+
                                                                'pulizia apparecchi\r\n'+
                                                                'ispezione quadri\r\n'+
                                                                'verniciatura sostegni\r\n'+
                                                                'verifica sostegni\r\n'+
                                                                'prova di resistenza\r\n'+
                                                                'prova di isolamento\r\n'+
                                                                'ispezioni notturne\r\n'+
                                                                'censimento\r\n';
        insert contractServiceSetup;
        List<Account> lstAcc = XC_DF_Account.insertPartnerAccounts(1);
        List<Contract> lstContracts = XC_DF_Contract.createCondominiumContract(lstAcc);
        insert lstContracts;
    }

    @IsTest
    static void methodTestContractServicesCreation(){
        
        Test.startTest();
            Contract selectedContract = [SELECT Id FROM Contract LIMIT 1];

            XC_IN088_CreateContractServices.FlowInputs flowInputs = new XC_IN088_CreateContractServices.FlowInputs();
            flowInputs.contractId = selectedContract.Id;

            List<XC_IN088_CreateContractServices.FlowInputs> lstInputs = new List<XC_IN088_CreateContractServices.FlowInputs>();
            lstInputs.add(flowInputs);

            List<XC_IN088_CreateContractServices.FlowOutputs> output = XC_IN088_CreateContractServices.createContractServices(lstInputs);

            System.assertEquals('Maintenance Services were successful created', output[0].DMLResult);
        Test.stopTest();

    }
}