/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/05/2019
* @description XC_SC001_AutoCloseLead_TEST – Test class for XC_SC001_AutoCloseLead
*/ 

@isTest
private class XC_SC001_AutoCloseLead_TEST {
    static testMethod void onExecuteBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Lead> listLead = XC_DF_Lead.createResidentialLeads(1);
        listLead[0].Status = Label.XC_CL_Lead_Assigned;
        insert listLead;
        System.assertEquals(7, Limits.getDmlStatements());
        
        Test.startTest();
        Database.executeBatch(new XC_SC001_AutoCloseLead(), 50); 
        XC_SC001_AutoCloseLead.getErrorLog('test', 'test');
        Test.stopTest();
    }
}