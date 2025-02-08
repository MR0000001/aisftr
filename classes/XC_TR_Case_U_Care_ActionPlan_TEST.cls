/**
* @author Monica Cutillo - monicaa.cutillo@nttdata.com
* @date Creation  21/05/2019 
* @description XC_TR_Case_U_Care_ActionPlan_TEST – Test class for XC_TR_Case_U_Care_ActionPlan
*/ 

@isTest
public class XC_TR_Case_U_Care_ActionPlan_TEST {

    static testMethod void setActionPlan() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Case caso = XC_DF_Case.createCaseFromType('XCMOT002', 'ATCL003', null);
        ActionPlanTemplate__c apt = new ActionPlanTemplate__c();
        apt.Name = 'XC Asistencia Telefónica';
        insert apt;
        
        Test.startTest();
        try{
        	insert caso;
        	System.assert(true);
        }catch(Exception ex){
        	System.assert(false);
        }
        Test.stopTest();
    }
    
    static testMethod void withoutActionPlan() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Case> cases = XC_DF_Case.createCases(1);
        
        Test.startTest();
        try{
        	insert cases;
        	System.assert(true);
        }catch(Exception ex){
        	System.assert(false);
        }
        Test.stopTest();
    }
}