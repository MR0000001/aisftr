/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 13/01/2021
* @date Modification dd/mm/yyyy
* @description  – XC_IN070_SendForValidation: Class invoked by flow XC_FL_Action_QualityCheck_SendForValidation
*/ 
public without sharing class XC_IN070_SendForValidation {
      /** 
      * @description InputWrapper the input wrapper.
      */
        public class InputWrapper{ 
            @Invocablevariable
            public XC_B2BG_QualityCheck__c qualityCheck;   
            @Invocablevariable
            public String userId;   
            @Invocablevariable
            public String assignedPartner;
            @Invocablevariable
            public String contractNumber;
            @Invocablevariable
            public String createdByName;
        }
  
        /** 
         * @description Cancel previous provisioning. 
         * @param inputWrapperList the input wrapper list.
         */
        @InvocableMethod
        public static List<String> closeRelatedStep(List<InputWrapper> inputWrapperList) {
            String errorMessage = '';
            XC_B2BG_QualityCheck__c qualityCheck = inputWrapperList[0].qualityCheck;
            String workOrderId = qualityCheck.XC_WorkOrder__c;
            String caseId = qualityCheck.XC_Case__c;
            String contractManager = inputWrapperList[0].userId;
            String assignedPartner = inputWrapperList[0].assignedPartner;
            String contractNumber = inputWrapperList[0].contractNumber;
            String createdByName = inputWrapperList[0].createdByName;
            Map<Id, Case> mapCases = new Map<Id, Case>();
            Map<Id, WorkOrder> mapWorkOrders = new Map<Id, WorkOrder>();
            if(!String.isEmpty(workOrderId) || !String.isEmpty(caseId)){
                  if(!String.isEmpty(workOrderId)){
                        //Retrieve Work Order:
                        mapWorkOrders = new Map<Id, WorkOrder>([
                        SELECT Id, XC_LegalEntity__c, XC_Segment__c, ParentWorkOrderId, ParentWorkOrder.XC_LegalEntity__c, ParentWorkOrder.XC_Segment__c 
                        FROM WorkOrder
                        WHERE Id =: workOrderId
                        ]);
                  }
                  if(!String.isEmpty(caseId)){
                        //Retrieve Cases:
                        mapCases = new Map<Id, Case>([
                        SELECT Id, XC_LegalEntity__c, XC_Segment__c, XC_WorkOrder__c, XC_WorkOrder__r.XC_LegalEntity__c, XC_WorkOrder__r.XC_Segment__c 
                        FROM Case
                        WHERE Id =: caseId
                        ]);
                  }
                  // Retrieve Assignment Rule:
                  AssignmentRule assRule = new AssignmentRule();
                  assRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
                  Database.DMLOptions dmlOpts = new Database.DMLOptions();
                  dmlOpts.assignmentRuleHeader.assignmentRuleId = assRule.id;

                  // Check Case Type Settings:
                  List<Case> listCaseToInsert = new List<Case>();
                  String nameCaseTypeSetting = 'XC_NoComplianceQualityCheck';
                  XC_CM_Case_Type_Setting__mdt cts = XC_UTIL_Case.retriveCaseTypeSettings(new List<String>{nameCaseTypeSetting}).get(nameCaseTypeSetting);
                  
                  // Check existing Cases:
                  List<String> listCheckExistingCases = XC_UTIL_Sobject.getListFieldValues(mapCases.values(), 'XC_WorkOrder__c');
                  listCheckExistingCases.addAll(XC_UTIL_Sobject.getListFieldValues(mapWorkOrders.values(), 'ParentWorkOrderId'));
                  listCheckExistingCases.addAll(XC_UTIL_Sobject.getListFieldValues(mapWorkOrders.values(), 'Id'));
                  List<Case> listExistingCases = new List<Case>([
                  SELECT Id, XC_NonComplianceWorkOrder__c   
                  FROM Case
                  WHERE XC_NonComplianceWorkOrder__c IN :listCheckExistingCases AND Reason = :cts.XC_Case_Reason__c AND SubCause__c = :cts.XC_Sub_Cause__c AND XC_Subtype__c = :cts.XC_Sub_Type__c
                  ]);
                  List<String> listToSkip = XC_UTIL_Sobject.getListFieldValues(listExistingCases, 'XC_NonComplianceWorkOrder__c');
                  
                  // Create Case related to WorkOrder for NC:

                  Case newCase = XC_UTIL_Case.initCaseFromCaseSettings(cts);
                  Boolean parentFound = false;
                  if(!String.isEmpty(workOrderId) ) {
                        WorkOrder relatedWo = mapWorkOrders.get(workOrderId);
                        String notComplianceWorkOrder = String.isNotBlank(relatedWo.ParentWorkOrderId) ? relatedWo.ParentWorkOrderId : relatedWo.Id;
                        if(!listToSkip.contains(notComplianceWorkOrder)) {
                              newCase.XC_LegalEntity__c = String.isNotBlank(relatedWo.ParentWorkOrderId) ? relatedWo.ParentWorkOrder.XC_LegalEntity__c : relatedWo.XC_LegalEntity__c;
                              newCase.XC_Segment__c = String.isNotBlank(relatedWo.ParentWorkOrderId) ? relatedWo.ParentWorkOrder.XC_Segment__c : relatedWo.XC_Segment__c;
                              newCase.XC_NonComplianceWorkOrder__c = notComplianceWorkOrder;
                              newCase.XC_ContractManager__c = contractManager;
                              newCase.XC_CheckList__c = qualityCheck.Id;
                              newCase.XC_QualityCheck_AssignedPartner__c  = assignedPartner;
                              newCase.XC_QualityCheck_ContractNumber__c = contractNumber;
                              newCase.XC_QualityCheck_Name__c = qualityCheck.Name;
                              newCase.XC_QualityCheck_CheckDate__c = qualityCheck.XC_CheckDate__c;
                              newCase.XC_QualityCheck_CreatedByName__c = createdByName;
                              parentFound = true;
                        }
                  } else if(!String.isEmpty(caseId)) {
                        Case relatedCase = mapCases.get(caseId);
                        String notComplianceWorkOrder = relatedCase.XC_WorkOrder__c;
                        if(!listToSkip.contains(notComplianceWorkOrder)) {
                              newCase.XC_LegalEntity__c = relatedCase.XC_WorkOrder__r.XC_LegalEntity__c;
                              newCase.XC_Segment__c = relatedCase.XC_WorkOrder__r.XC_Segment__c;
                              newCase.XC_NonComplianceWorkOrder__c = notComplianceWorkOrder;
                              newCase.XC_ContractManager__c = contractManager;
                              newCase.XC_CheckList__c = qualityCheck.Id;
                              newCase.XC_QualityCheck_AssignedPartner__c  = assignedPartner;
                              newCase.XC_QualityCheck_ContractNumber__c = contractNumber;
                              newCase.XC_QualityCheck_Name__c = qualityCheck.Name;
                              newCase.XC_QualityCheck_CheckDate__c = qualityCheck.XC_CheckDate__c;
                              newCase.XC_QualityCheck_CreatedByName__c = createdByName;
                              parentFound = true;
                        }
                  }
                  if(parentFound) {
                        newCase.setOptions(dmlOpts);
                        listCaseToInsert.add(newCase);
                  }
                    
  
                  // DML operation:
                  List<XC_UTIL_Sobject.WrapperResult> listWrResult = XC_UTIL_Sobject.insertListRecords(listCaseToInsert);
                  if(!XC_UTIL_Sobject.checkDMLResults(listWrResult)) {
                        errorMessage = listWrResult[0].errorMessage;
                  }
            } else {
                  return new List<String>{'No case or workorder related found'};
            }
            return new List<String>{errorMessage};
      }
    
}