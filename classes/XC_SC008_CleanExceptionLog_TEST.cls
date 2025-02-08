/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/05/2019
* @description XC_SC008_CleanExceptionLog_TEST – Test class for XC_SC008_CleanExceptionLog
*/ 

@isTest
private class XC_SC008_CleanExceptionLog_TEST {
    
    public static String CRON_EXP = '0 0 0 3 9 ? 2052';
    
    static testMethod void extecuteBatch() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        XC_ExceptionLog__c expLog = new XC_ExceptionLog__c();
        insert expLog;
        Test.setCreatedDate(expLog.Id, (Datetime) Date.today().addDays(-10));
        System.assertEquals(2, Limits.getDmlStatements());
        
        Test.startTest();
        Database.executeBatch(new XC_SC008_CleanExceptionLog(), 50);
		Test.stopTest();
    }
    
    static testMethod void extecute() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
        String jobId = System.schedule('testScheduledApex', CRON_EXP, new XC_SC008_CleanExceptionLog());
        String jobId2 = System.scheduleBatch(new XC_SC008_CleanExceptionLog(), 'testScheduledApex2', 30);
        
        System.assert(String.isNotBlank(jobId));
        System.assert(String.isNotBlank(jobId2));
		Test.stopTest();
    }
    
    static testMethod void extecute2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest();
    	Database.BatchableContext sc = null;
        XC_SC008_CleanExceptionLog clExLog = new XC_SC008_CleanExceptionLog();
        clExLog.execute(sc, new List<XC_ExceptionLog__c>());
        
        System.assert(true);
		Test.stopTest();
    }
    
}