/**
* @author Marco Rosa - marco.rosa@nttdata.com & Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 03/04/2019 
* @date Modification 07/02/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_Lead_U_HandleIndividual_TEST – Test class for XC_TR_Lead_U_HandleIndividual
*/ 

@isTest
private class XC_TR_Lead_U_HandleIndividual_TEST {

    @isTest
    static void handleIndividual() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        insert XC_DF_Lead.createResidentialLeads(100);
        List<Lead> listInsertedLeads = [SELECT Id FROM Lead];
        System.assertEquals(100, listInsertedLeads.size());
        Test.stopTest();
    }
    
}