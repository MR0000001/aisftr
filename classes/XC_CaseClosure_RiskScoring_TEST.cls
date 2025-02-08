/**
 * The Class XC_CaseClosure_RiskScoring_TEST.
 *
 * @author            : Simone Trenta strenta@deloitte.it
 * @date Creation     : 09/07/2020
 * @date Modification : dd/mm/yyyy
 * @description       : XC_CaseClosure_RiskScoring_TEST
 **/

@isTest
public class XC_CaseClosure_RiskScoring_TEST {

    @isTest
    static void caseClosureRiskScoring(){
		list<Case> c = XC_DF_Case.createCases(2);
        insert c;
        
        
        test.startTest();
        c[0].status = 'ESTA007';
        c[0].Reason = 'XCMOT007';
        c[0].SubCause__c = 'ATCL157';
        c[0].XC_Subtype__c='XC191'; 
        c[0].XC_Resolution__c='R135';
        c[0].XC_Result__c='RS003';
        Map<id,case> n = new map<id,case>();
        n.put(c[0].id,c[0]);
        Map<id,case> o = new map<id,case>();
        o.put(c[0].id,c[1]);
        XC_CaseClosure_RiskScoring.caseClosureRiskScoring(n,o);
        test.stopTest();
        
    }
    
}