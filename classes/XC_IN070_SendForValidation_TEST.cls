/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 11/12/2020
* @description XC_IN070_SendForValidation_TEST – Test Class for XC_IN070_SendForValidation
*/  

@isTest
public class XC_IN070_SendForValidation_TEST {
      @TestSetup
      static void setup(){
          insert XC_DF_OneOrg.createOneOrg('Spain');
          List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, 'Quality Check Inspection');
          WorkType wt = XC_DF_WorkType.createWorkTypeWithName('Quality Check Inspection', 'Quality Check Inspection');
          insert wt;
          listWorkOrder[0].WorkTypeId = wt.Id;
          insert listWorkOrder;
          Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('XC_ITA_Management_Case').getRecordTypeId();
          List<Case> caseList = XC_DF_Case.createCases(1);
          case cs = caseList[0];
          cs.recordTypeId = caseRecordType;
          insert cs;
          cs.recordTypeId = caseRecordType;
          update cs;
      }

      @isTest
      static void callInvocableClassFromWO(){
            WorkOrder wo = [SELECT Id FROM WorkOrder LIMIT 1];
            List<XC_B2BG_QualityCheck__c> qualityCheckList = XC_DF_QualityCheck.createQualityChecks(1);
            XC_B2BG_QualityCheck__c qc = qualityCheckList[0];
            qc.XC_AnswerA1__c = 'NC';
            qc.XC_NotCompliance_CommentsA1__c = 'TEST';
            qc.XC_WorkOrder__c = wo.Id;
            insert qc;

            //CREATE WRAPPER
            XC_IN070_SendForValidation.InputWrapper wrapper = new XC_IN070_SendForValidation.InputWrapper();
            wrapper.qualityCheck = qc;
            Test.startTest();
            XC_IN070_SendForValidation.closeRelatedStep(new List<XC_IN070_SendForValidation.InputWrapper>{wrapper});
            Test.stopTest();
      }
    
      @isTest
      static void callInvocableClassFromCase(){
            Case cs = [SELECT Id, RecordTypeId FROM Case LIMIT 1];
            List<XC_B2BG_QualityCheck__c> qualityCheckList = XC_DF_QualityCheck.createQualityChecks(1);
            XC_B2BG_QualityCheck__c qc = qualityCheckList[0];
            qc.XC_AnswerA1__c = 'NC';
            qc.XC_NotCompliance_CommentsA1__c = 'TEST';
            qc.XC_Case__c = cs.Id;
            insert qc;

            //CREATE WRAPPER
            XC_IN070_SendForValidation.InputWrapper wrapper = new XC_IN070_SendForValidation.InputWrapper();
            wrapper.qualityCheck = qc;
            Test.startTest();
            XC_IN070_SendForValidation.closeRelatedStep(new List<XC_IN070_SendForValidation.InputWrapper>{wrapper});
            Test.stopTest();
      }
}