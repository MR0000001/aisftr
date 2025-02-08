/**
    * @author Emanuela Cacace ecacace@deloitte.it
    * @date Creation  22/05/2019 
    * @description XC_TR_ContrLiIt_U_PopulateEndDate_TEST – Test class for XC_TR_ContractLineItem_U_PopulateEndDate
    */ 
    @isTest
public with sharing class XC_TR_ContrLiIt_U_PopulateEndDate_TEST {
    // Test method for populateEndDate 
     static testMethod void populateEndDate(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            Test.startTest();
                List<Contract> contract = XC_DF_Contract.createContracts(1);
                insert contract; 
                List<Asset> asset = XC_DF_Asset.createAssets(1);
                insert asset; 
                List<XC_ContractLineItem__c> cli = new List<XC_ContractLineItem__c>();
                XC_ContractLineItem__c cli1 = new XC_ContractLineItem__c();
                cli1.XC_Contract__c = contract[0].Id ;  
                cli1.XC_StartDate__c=Date.today(); 
                cli1.XC_Asset__c = asset[0].Id; 
                cli.add(cli1); 
                insert cli;

            System.assertEquals(1, contract.size());
            Test.stopTest();
     }

}