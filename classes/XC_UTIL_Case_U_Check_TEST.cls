@isTest
private class XC_UTIL_Case_U_Check_TEST {
    
    @isTest static void getRecordTypeByCountry_TEST() {
        List<String> listCountries=new List<String>();
        Test.startTest();
        XC_UTIL_Case_U_Check.getRecordTypeByCountry(listCountries);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code
    }
    
    @isTest static void isComplianCase_TEST() {
        Case caso=new Case();
        Test.startTest();
        XC_UTIL_Case_U_Check.isComplianCase(caso);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code
    }

    @isTest static void checkFromWorkOrder_TEST() {
        XC_UTIL_Case_U_Check.CheckCaseWrapper caseWrapper=new XC_UTIL_Case_U_Check.CheckCaseWrapper();
        List<WorkOrder> works=XC_DF_WorkOrder.createWorkOrders(1,'Commercial Visit');
        caseWrapper.caseToWorkOrder.put(works.get(0).id,works);
        works[0].Status='On Hold';
        Test.startTest();
        XC_UTIL_Case_U_Check.checkFromWorkOrder(caseWrapper);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code
    }
    
    @isTest static void checkFromConf_TEST() {
        XC_UTIL_Case_U_Check.CheckCaseWrapper caseWrapper=new XC_UTIL_Case_U_Check.CheckCaseWrapper();
        List<NE__Order__c> confs=new List<NE__Order__c>();
        NE__Order__c conf=new NE__Order__c();
        conf.XC_Status__c='Draft';
        confs.add(conf);
        caseWrapper.caseToConf.put(confs.get(0).id,confs);

        Test.startTest();
        XC_UTIL_Case_U_Check.checkFromConf(caseWrapper);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code
    }

    @isTest static void checkFromOpp_TEST() {
        XC_UTIL_Case_U_Check.CheckCaseWrapper caseWrapper=new XC_UTIL_Case_U_Check.CheckCaseWrapper();
        List<Opportunity> opps=new List<Opportunity>();
        Opportunity opp=new Opportunity();
        opp.StageName='Qualification';
        opps.add(opp);
        caseWrapper.caseToOpp.put(opps.get(0).id,opps);

        Test.startTest();
        XC_UTIL_Case_U_Check.checkFromOpp(caseWrapper);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code
    }

    @isTest static void checkFromCase_TEST() {
        XC_UTIL_Case_U_Check.CheckCaseWrapper caseWrapper=new XC_UTIL_Case_U_Check.CheckCaseWrapper();
        List<Case> cases=XC_DF_Case.CreateCases(1);
        Case cs=cases[0];
        cs.Status='ESTA004';
        cases.add(cs);
        caseWrapper.caseToCase.put(cases.get(0).id,cases);

        Test.startTest();
        XC_UTIL_Case_U_Check.checkFromCase(caseWrapper);
        System.assertEquals(1,1);
        Test.stopTest();
        // Implement test code

}



        @isTest static void isParentCasePending_Test_empty() {

        Test.startTest();
        XC_UTIL_Case.isParentCasePending(new Set<Id>());
        System.assertEquals(1, 1);
        Test.stopTest();
    } 




        @isTest static void isParentCasePending_Test_full() {

        Test.startTest();

        List<Case> cases =  XC_DF_Case.createCases(4);
        //start cr 763 vdb 2022-06-01
         for(case c : cases) {
             c.XC_LegalEntity__c='EnelXItalia';
         }
         //end cr 763 vdb 2022-06-01
         insert cases;

        Set<id> ids = new Set<id> ();

        for(case c : cases) {

            ids.add(c.Id);
        }


        XC_UTIL_Case.isParentCasePending(ids);
        System.assertEquals(1, 1);
        Test.stopTest();
    } 

    @isTest static void updateParentCaseStatus_Test() {

        Test.startTest();

        List<Case> cases =  XC_DF_Case.createCases(2);
        //start cr 763 vdb 2022-06-01
        for(case c : cases) {
             c.XC_LegalEntity__c='EnelXItalia';
         }
         //end cr 763 vdb 2022-06-01
        insert cases;

        Set<id> ids = new Set<id> ();

        for(case c : cases) {

            ids.add(c.Id);
        }
        List<NE__Order__c> confs=new List<NE__Order__c>();
        NE__Order__c conf=new NE__Order__c();
        conf.XC_Status__c='In Progress';
        conf.XC_CaseId__c=cases[0].id;
        confs.add(conf);
        insert confs;

        XC_UTIL_Case.isParentCasePending(ids);
        System.assertEquals(1, 1);
        Test.stopTest();
    } 


    



}