/**  
 * @author Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 14/12/2020
 * @description XC_TR_Case_U_QualityCheck_TEST – Test class for XC_TR_Case_U_QualityCheck
 */
@isTest
public class XC_TR_Case_U_QualityCheck_TEST {
    
    @isTest
    static void updateWorkOrderTest(){
        Case c = XC_DF_Case.createCaseFromType('XCMOT007', 'ATCL107', 'XC347');
        insert c;
        
        Test.startTest();
        c.XC_UpdateNonCompliancePenalty__c = true;
        update c;
        Test.stopTest();
    }


}