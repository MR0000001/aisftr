/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/05/2019
* @description XC_SC002_AutoCloseOpportunity_TEST – Test class for XC_SC002_AutoCloseOpportunity
*/ 

@isTest
private class XC_SC002_AutoCloseOpportunity_TEST {
    static testMethod void onExecuteBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Opportunity> listOpp = XC_DF_Opportunity.createOpportunity(1, false);
        insert listOpp;
        System.assertEquals(9, Limits.getDmlStatements());
        
        Test.startTest();
        Database.executeBatch(new XC_SC002_AutoCloseOpportunity(), 50); 
        Test.stopTest();
    }
}