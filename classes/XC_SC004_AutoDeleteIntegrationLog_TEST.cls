/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 29/05/2019
* @description XC_SC004_AutoDeleteIntegrationLog_TEST – Test class for XC_SC004_AutoDeleteIntegrationLog
*/ 

@isTest
private class XC_SC004_AutoDeleteIntegrationLog_TEST {
    static testMethod void extecuteBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_Integration_Log__c integrationLog = new XC_Integration_Log__c();
        insert integrationLog;
        Test.setCreatedDate(integrationLog.Id, DateTime.newInstance(2018,12,12));
        System.assertEquals(2, Limits.getDmlStatements());
        
        Test.startTest();
        Database.executeBatch(new XC_SC004_AutoDeleteIntegrationLog(), 10);
		Test.stopTest();        
    }
}