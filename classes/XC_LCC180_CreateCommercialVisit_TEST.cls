/**
 	* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 18/03/2020
    * @description XC_LCC180_CreateCommercialVisit_TEST - Test Class for XC_LCC180_CreateCommercialVisit
 */

@isTest
private class XC_LCC180_CreateCommercialVisit_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC180_CreateCommercialVisit_TEST');

    @isTest
    private static void onCommercialVisitLead() {
        insert new OneOrg__c(Name = 'OneOrg (User)', XC_Spain_Triggers__c = true);
        Lead ld = XC_DF_Lead.createResidentialLead();
        insert ld;

        Test.startTest();
        XC_LCC180_CreateCommercialVisit.manageCommercialVisit(ld.Id);
        Test.stopTest();
    }

    @isTest
    private static void onCommercialVisitOpportunity() {
        insert new OneOrg__c(Name = 'OneOrg (User)', XC_Spain_Triggers__c = true);
        Opportunity opp = XC_DF_Opportunity.createOpportunity(1, true)[0];
        insert opp;

        Test.startTest();
        XC_LCC180_CreateCommercialVisit.manageCommercialVisit(opp.Id);
        Test.stopTest();
    }
    

    @isTest
    private static void onCommercialVisitOpty() {
        insert new OneOrg__c(Name = 'OneOrg (User)', XC_Spain_Triggers__c = true);
        
        List<Opportunity> opp = XC_DF_Opportunity.createOpportunity(1, false);
        insert opp;
        
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Opty';
        order.NE__AccountId__c = opp[0].AccountId; 
        order.NE__OptyId__c = opp[0].Id;
        insert order;

        Test.startTest();
        XC_LCC180_CreateCommercialVisit.manageCommercialVisit(order.Id);
        Test.stopTest();
    }
}