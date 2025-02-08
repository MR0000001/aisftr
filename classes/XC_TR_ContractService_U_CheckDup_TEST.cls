/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 12-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public with sharing class XC_TR_ContractService_U_CheckDup_TEST {
    
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
        Id recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2G_EnelXItalia_Contract').getRecordTypeId();
        lstContracts[0].XC_LegalEntity__c = 'EnelSole';
        lstContracts[0].RecordTypeId = recordTypeId;
        insert lstContracts;
    }

    @IsTest
    static void methodTestContractServicesCreationWhenAlreadyExistDuplicates(){
        
        Test.startTest();
            Contract selectedContract = [SELECT Id FROM Contract LIMIT 1];

            XC_IN088_CreateContractServices.FlowInputs flowInputs = new XC_IN088_CreateContractServices.FlowInputs();
            flowInputs.contractId = selectedContract.Id;
            
            List<XC_IN088_CreateContractServices.FlowInputs> lstInputs = new List<XC_IN088_CreateContractServices.FlowInputs>();
            lstInputs.add(flowInputs);

            List<XC_IN088_CreateContractServices.FlowOutputs> output = XC_IN088_CreateContractServices.createContractServices(lstInputs);

            System.assertEquals('Maintenance Services were successful created', output[0].DMLResult);

            //call the method again to force check for duplication logic fired by trigger  
            List<XC_IN088_CreateContractServices.FlowOutputs> output2 = XC_IN088_CreateContractServices.createContractServices(lstInputs);
            //System.assertEquals(Label.XC_CL_ExistentContractServicesError, output2[0].DMLResult.substringAfter(' '));

        Test.stopTest();

    }
}