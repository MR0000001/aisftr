/**
* @author Salvatore Scarpato -  salvatore.scarpato@nttdata.com 
* @date Creation 05/02/2021
* @description XC_DF_QualityCheck – Data Factory for XC_B2BG_QualityCheck__c
*/
@isTest
public class XC_DF_QualityCheck {
      /**
       * @author Salvatore Scarpato -  salvatore.scarpato@nttdata.com
       * @description Method to create N Quality Check Records
       * @param  n Integer
       * @return List<XC_B2BG_QualityCheck__c> to insert 
       */ 
      public static List<XC_B2BG_QualityCheck__c> createQualityChecks(Integer n) {
            List<XC_B2BG_QualityCheck__c> qualityCheckList = new List<XC_B2BG_QualityCheck__c>();
            for(Integer i = 0; i < n ; i++){
                  XC_B2BG_QualityCheck__c qualityCheck = new XC_B2BG_QualityCheck__c();
                  qualityCheck.XC_Status__c = 'Draft';
                  qualityCheck.XC_CheckDate__c = Date.Today();
                  qualityCheck.XC_Country__c = 'Italy';
                  qualityCheck.XC_ReportDiSopralluogoRedattoIl__c = Date.Today();
                  qualityCheckList.add(qualityCheck);
            }
            return qualityCheckList;
      }
}