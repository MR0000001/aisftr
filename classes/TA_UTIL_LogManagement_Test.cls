/**
 * Created by alericci on 17/12/2020.
 */

@IsTest
private class TA_UTIL_LogManagement_Test {
    static testMethod void testBehavior() {
        TA_UTIL_LogManagement.createLog('','','',2,'','');
        NE__Log__c log = [select id,NE__LogNumber__c from NE__Log__c LIMIT 1];
        TA_UTIL_LogManagement.updateLog(log.id, new NE__Log__c(NE__Class_Method__c='test',
                NE__Class_name__c='test',
                NE__LogNumber__c = 2,
                NE__LogText__c = 'test',
                NE__Source__c = 'test'));
    }
}