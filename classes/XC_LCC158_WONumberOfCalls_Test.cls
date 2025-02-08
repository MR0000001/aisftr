/**
 * The Class XC_LCC158_WONumberOfCalls_Test.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 01/10/2019 
 * @date Modification dd/mm/yyyy
 * @description XC_LCC158_WONumberOfCalls_Test – Test class for XC_LCP158_WONumberOfCalls Component
 */
 @isTest
public with sharing class XC_LCC158_WONumberOfCalls_Test {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c(); 
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    @isTest
    static void succededTest(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        listOfWo[0].XC_NumberOfAttemps__c = 3;
        insert listOfWo;
        Test.startTest();
        XC_LCC158_WONumberOfCalls.ResultWrapper rw = XC_LCC158_WONumberOfCalls.numberOfCalls(listOfWo[0].id);
        Test.stopTest();
        System.assertEquals(rw.success, true);
    }
    @isTest
    static void numberOfAttempsNull(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrders(1, 'Repair');
        listOfWo[0].XC_NumberOfAttemps__c = null;
        insert listOfWo;
        Test.startTest();
        XC_LCC158_WONumberOfCalls.ResultWrapper rw = XC_LCC158_WONumberOfCalls.numberOfCalls(listOfWo[0].id);
        Test.stopTest();
        System.assertEquals(rw.success, false);
    }
}