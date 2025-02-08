/**
 * @description       : 
 * @author            : pedro.danielalmeida@nttdata.com
 * @group             : 
 * @last modified on  : 05-05-2022
 * @last modified by  : pedro.danielalmeida@nttdata.com
**/
@isTest
public without sharing class XC_DF_ContractService {

    /**
    * @description create contract services data for test units purposes
    * @author pedro.danielalmeida@nttdata.com | 05-05-2022 
    * @param numContractServices 
    * @param relatedContract 
    * @return List<XC_ContractItem__c> 
    **/
    public static List<XC_ContractItem__c> createContractServices(Integer numContractServices,Contract relatedContract){
        List<XC_ContractItem__c> lstContractServices = new List<XC_ContractItem__c>();

        for (Integer i = 0; i < numContractServices; i++){
            XC_ContractItem__c newContractService = new XC_ContractItem__c();
            newContractService.XC_ProdName__c = 'Contract Service Test '+numContractServices;
            newContractService.XC_Contract__c = relatedContract.Id;
            newContractService.XC_Active__c = true;
            newContractService.XC_ConfigurationItem__c = null;
            newContractService.XC_Country__c = null;
            newContractService.XC_Family__c = null;
            newContractService.XC_ProductCode__c = null;
            newContractService.XC_Quantity__c = null;
            newContractService.XC_ServiceFirstExecution__c = null;
            newContractService.XC_ServiceFrequency__c = 1;
            newContractService.XC_Service_Status__c = 'To Plan';
            newContractService.XC_Service_Type__c = null;
            newContractService.XC_Status__c = null;
            newContractService.XC_StartDate__c = relatedContract.StartDate;
            newContractService.XC_EndDate__c = relatedContract.EndDate;
            lstContractServices.add(newContractService);
        }
        insert lstContractServices;
        return lstContractServices;
    }
}