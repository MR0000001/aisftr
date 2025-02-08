/**
 * The Class XC_LCC181_CIECannotProceed_TEST.
 *
 * @author Domenico Del Prete domenico.delprete@nttadata.com
 * @date Creation 01/04/2020 
 * @description XC_LCC181_CIECannotProceed_TEST – Test class for XC_LCP181_CIECannotProceed Component
 */
@isTest
public without sharing class XC_LCC181_CIECannotProceed_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }

    @isTest
    static void successTest(){
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Site Inspection - CIE', 'Site Inspection');
        WorkOrder wo = listOfWo[0];
        wo.XC_Configuration__c = ord.Id;
        wo.XC_Opportunity__c  = ord.NE__OptyId__c;
        insert wo;
        XC_LCC181_CIECannotProceed.ResultWrapper rw = XC_LCC181_CIECannotProceed.cannotProceedCIE(wo.Id);
        //System.assert(rw.success);
    }

    @isTest
    static void wrongWorkType(){
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Diagnostic', 'Diagnostic');
        WorkOrder wo = listOfWo[0];
        insert wo;
        XC_LCC181_CIECannotProceed.ResultWrapper rw = XC_LCC181_CIECannotProceed.cannotProceedCIE(wo.Id);
        //System.assert(!rw.success);
    }

    @isTest
    static void woFinalStatus(){
        NE__Order__c ord = XC_DF_Order.createOrder('InOrder');
        List<WorkOrder> listOfWo = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Site Inspection - CIE', 'Site Inspection');
        WorkOrder wo = listOfWo[0];
        wo.XC_Configuration__c = ord.Id;
        wo.XC_Opportunity__c  = ord.NE__OptyId__c;
        insert wo;
        wo.XC_ForSATO__c = true;
        wo.Status = 'Completed';
        update wo;
        XC_LCC181_CIECannotProceed.ResultWrapper rw = XC_LCC181_CIECannotProceed.cannotProceedCIE(wo.Id);
        //System.assert(!rw.success);
    }
}