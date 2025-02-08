/**
 * Created by snekkanti002 on 08/07/2022.
 */

@IsTest
public with sharing class TestErrorLogService {

    @IsTest
    public static void deleteErrorLogs() {
        Error_Log__c e = new Error_Log__c();
        Test.startTest();
        ErrorLogService.deleteErrorLogs(new List<Error_Log__c>{e}, false);
        Test.stopTest();
    }
}