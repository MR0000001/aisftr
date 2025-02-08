/**
 * Created by FMARCHEGIA00 on 08/06/2021.
 */

@IsTest
private class TestGetThreadId {
    @testSetup
    public static void setup() {
        TestDataFactory.createCasesWithoutCities();
        // TestDataFactory.createServiceAppointments();
    }
    
    @isTest
    public static void getCaseThreadIdByCaseIdTest() {
        List<Case> cases = [SELECT id FROM Case];
        List<GetThreadId.FlowInput> listInputForThreadId = new List<GetThreadId.FlowInput>();
        GetThreadId.FlowInput singlelistInputForThreadId = new GetThreadId.FlowInput();
        singlelistInputForThreadId.caseId = cases[0].id;
        listInputForThreadId.add(singlelistInputForThreadId);

        Test.startTest();
        List<GetThreadId.FlowOutput> outpus = GetThreadId.getCaseThreadIdByCaseId(listInputForThreadId);
        system.assert(outpus.size() > 0);
        Test.stopTest();
    }

}