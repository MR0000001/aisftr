/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 05/02/2021
* @date  
* @description XC_TR_Case_U_SetQualityCheckStatus_TEST – Test class for XC_TR_Case_U_SetQualityCheckStatus
*/
@isTest
public class XC_TR_Case_U_SetQualityCheckStatus_TEST {
      @TestSetup
      static void createData(){
            insert XC_DF_OneOrg.createOneOrg('Spain');
            List<Case> csList = XC_DF_Case.createCases(1);
            insert csList;
            Case cCase = csList[0];
            XC_B2BG_QualityCheck__c qualityCheckRecord = XC_DF_QualityCheck.createQualityChecks(1)[0];
            insert qualityCheckRecord;

            cCase.XC_CheckList__c = qualityCheckRecord.Id;
            update cCase;
      } 

      @isTest
      static void setQualityCheckStatusInTest() {
            List<Case> caseList = new List<Case>([SELECT Id FROM Case]);
            //List<Case> caseListToUpdate = new List<Case>();
            for(Case cs : caseList){
                  cs.XC_UpdateNonCompliancePenalty__c = true;
            }
            update caseList;
      }
}