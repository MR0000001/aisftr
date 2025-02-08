/**
* @author Eleni Tsiolaki - etsiolaki@deloitte.gr 
* @Creation 01/11/2021
* @Modification
* @description Test Class for XC_LCC267_ContractAmendmentRetry
*/
@isTest
private class XC_LCC267_ContractAmendmentRetry_TEST {
    @TestSetup
    static void insertRecords() {

        XC_ContractAmendment__c contrAmendement = new XC_ContractAmendment__c();
        contrAmendement.XC_Status__c = 'Error';
        insert contrAmendement;
    }

    @isTest
    static void initComponentTest(){
        List<XC_ContractAmendment__c> contr = [SELECT Id FROM XC_ContractAmendment__c LIMIT 1];
        Test.startTest();
        XC_UTIL_ResultWrapper resultOK = XC_LCC267_ContractAmendmentRetry.changeStatus(contr[0].Id);
        Test.stopTest();
        List<XC_ContractAmendment__c> contrUpdated = [SELECT Id, XC_Status__c FROM XC_ContractAmendment__c LIMIT 1];
        System.assertEquals('New',contrUpdated[0].XC_Status__c);
    }
}