/**
* @author Emanuela Cacace ecacace@deloitte.it
* @date Creation  11/06/2019 
* @description XC_TR_ContrLilt_U_ManageContract_TEST – Test class for XC_TR_ContractLineItem_U_ManageContract
*/ 
@isTest
public with sharing class XC_TR_ContrLilt_U_ManageContract_TEST {
        //Test method manageContractLineItemStatusOnUpdate
    static testMethod void manageContractLineItemStatusOnUpdate(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, true); 
        insert opp;
        NE__Order__c config = XC_DF_Order.createOrder('InOrder');
        config.NE__OptyId__c= opp[0].Id;
        List<Contract> contract = XC_DF_Contract.createContracts(1);
        contract[0].XC_Configurations__c= config.Id; 
        contract[0].Opportunity__c = opp[0].Id; 
        insert contract; 
        XC_ContractLineItem__c cli = new XC_ContractLineItem__c();
        cli.XC_Status__c = 'Active';
        cli.XC_Contract__c = contract[0].Id;  
        insert cli;
        cli.XC_Status__c = 'Pending';
        update cli; 

        System.assertEquals(1, contract.size());
        Test.stopTest(); 
    }

            //Test method manageContractLineItemStatusOnUpdate2
    static testMethod void manageContractLineItemStatusOnUpdate2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        List<Contract> contract = XC_DF_Contract.createContracts(1);
        insert contract; 
        XC_ContractLineItem__c cli = new XC_ContractLineItem__c();
        cli.XC_Status__c = 'Active';
        cli.XC_Contract__c = contract[0].Id;   
        insert cli;
        cli.XC_Status__c = 'Cancelled';
        update cli; 

        System.assertEquals(1, contract.size());
        Test.stopTest(); 
    }

}