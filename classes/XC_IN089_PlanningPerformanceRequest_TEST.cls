/**
 * @author            :  Alessandro Catto alessandro11.catto@nttdata.com
 * @date Creation     :  09/05/2022
 * @date Modification :  dd/mm/yyyy
 * @description       :  XC_IN089_PlanningPerformanceRequest_TEST - Test class for XC_IN089_PlanningPerformanceRequest class
*/
@IsTest
private without sharing class XC_IN089_PlanningPerformanceRequest_TEST {
    
    @TestSetup
    private static void testSetup() {
        List<XC_KPI_Planning_Performance__c> requests = new List<XC_KPI_Planning_Performance__c>();
        XC_KPI_Planning_Performance__c request1 = new XC_KPI_Planning_Performance__c();
        request1.XC_Country__c = 'Italy';
        request1.XC_Legal_Entity__c = 'EnelXItalia';
        request1.XC_Request_Status__c = 'In Progress';
        requests.add(request1);

        XC_KPI_Planning_Performance__c request2 = new XC_KPI_Planning_Performance__c();
        requests.add(request2);

        insert requests;
    }

    @IsTest
    private static void computePlanningPerformancesTest() {
        XC_KPI_Planning_Performance__c request = [SELECT Id FROM XC_KPI_Planning_Performance__c WHERE XC_Country__c != '' AND XC_Legal_Entity__c != '' LIMIT 1];
        List<XC_IN089_PlanningPerformanceRequest.InputWrapper> inputs = new List<XC_IN089_PlanningPerformanceRequest.InputWrapper>();
        XC_IN089_PlanningPerformanceRequest.InputWrapper input = new XC_IN089_PlanningPerformanceRequest.InputWrapper();
        input.requestId = request.Id;
        inputs.add(input);

        Test.startTest();
        XC_IN089_PlanningPerformanceRequest.computePlanningPerformances(inputs);
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'XC_BA004_PlanningPerfKPICalc'];
        System.assertEquals(1, jobs.size(), 'The batch has not been launched correctly');
    }

    @IsTest
    private static void computePlanningPerformancesErrorTest() {
        XC_KPI_Planning_Performance__c request = [SELECT Id FROM XC_KPI_Planning_Performance__c WHERE XC_Country__c != '' AND XC_Legal_Entity__c != '' LIMIT 1];
        request.XC_Request_Status__c = 'Error';
        update request;
        XC_KPI_Planning_Performance_Detail__c detail = new XC_KPI_Planning_Performance_Detail__c();
        detail.XC_KPI_Planning_Performance__c = request.Id;
        detail.XC_Request_Status__c = 'Error';
        detail.XC_RetryNumber__c = 1;
        insert detail;
        List<XC_IN089_PlanningPerformanceRequest.InputWrapper> inputs = new List<XC_IN089_PlanningPerformanceRequest.InputWrapper>();
        XC_IN089_PlanningPerformanceRequest.InputWrapper input = new XC_IN089_PlanningPerformanceRequest.InputWrapper();
        input.requestId = request.Id;
        inputs.add(input);

        Test.startTest();
        XC_IN089_PlanningPerformanceRequest.computePlanningPerformances(inputs);
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'XC_BA004_PlanningPerfKPICalc'];
        System.assertEquals(1, jobs.size(), 'The batch has not been launched correctly');
    }

    @IsTest
    private static void computePlanningPerformancesMissingFieldsTest() {
        XC_KPI_Planning_Performance__c request = [SELECT Id FROM XC_KPI_Planning_Performance__c WHERE XC_Country__c = '' AND XC_Legal_Entity__c = '' LIMIT 1];
        List<XC_IN089_PlanningPerformanceRequest.InputWrapper> inputs = new List<XC_IN089_PlanningPerformanceRequest.InputWrapper>();
        XC_IN089_PlanningPerformanceRequest.InputWrapper input = new XC_IN089_PlanningPerformanceRequest.InputWrapper();
        input.requestId = request.Id;
        inputs.add(input);

        Test.startTest();
        XC_IN089_PlanningPerformanceRequest.computePlanningPerformances(inputs);
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex' AND ApexClass.Name = 'XC_BA004_PlanningPerfKPICalc'];
        System.assertEquals(0, jobs.size(), 'The batch has been launched wrongly due to missing request fields');
    }
}