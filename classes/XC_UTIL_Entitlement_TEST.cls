/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com - Marco Rosa - marco.rosa@nttdata.com
* @date 11/02/2021
* @description XC_UTIL_Entitlement_TEST - Test class for XC_UTIL_Entitlement
*/

@isTest
public without sharing class XC_UTIL_Entitlement_TEST {
 

    @isTest
    static void completeMilestone(){
        List<Case> caseList = XC_DF_Case.createCases(1);
        insert caseList;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Entitlement entl = new Entitlement(Name='TestEntitlement', AccountId=acc.Id);
        caseList[0].EntitlementId = entl.Id;
        update caseList[0];
        insert entl;
        XC_UTIL_Entitlement.completeMilestone(caseList, 'test milestone', System.now());
    }
}