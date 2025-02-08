/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 11/12/2020
* @description XC_TR_QualityCheck_U_CheckFields – Util trigger to check fields
*/  

public without sharing class XC_TR_QualityCheck_U_CheckFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_QualityCheck_U_CheckFields');
    
    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @date 05/02/2021
     * @modified by Salvatore Scarpato - salvatore.scarpato@nttdata.com: NR1498
     * @description Method to check answers fields
     * @param listNew - List<XC_B2BG_QualityCheck__c> 
    */ 
    public static void fillFields(List<XC_B2BG_QualityCheck__c> listNew) {   
        for(XC_B2BG_QualityCheck__c qc : listNew) {
            if(qc.XC_NullAccess__c){
                Map<String, Object> mapObjectTemp = qc.getPopulatedFieldsAsMap();
                for(String field : mapObjectTemp.keySet()) {
                    if(field.toLowerCase().contains('answer')) {
                        qc.put(field, 'NA'); 
                    }
                }
            }
        }
        //Retrieve Work Order:
        List<String> listWorkOrderIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_WorkOrder__c');
        Map<Id, WorkOrder> mapWorkOrders = new Map<Id, WorkOrder>([
            SELECT Id, ParentWorkOrderId, ParentWorkOrder.XC_AssignedPartner__c, ParentWorkOrder.Country, ParentWorkOrder.XC_Address__r.XC_Region__c, ParentWorkOrder.XC_Address__r.XC_City__c
            FROM WorkOrder
            WHERE Id IN :listWorkOrderIds
        ]);
        
        //Retrieve Cases:
        List<String> listCaseIds = XC_UTIL_Sobject.getListFieldValues(listNew, 'XC_Case__c');
        Map<Id, Case> mapCases = new Map<Id, Case>([
            SELECT Id, XC_WorkOrder__c, XC_WorkOrder__r.XC_AssignedPartner__c, XC_WorkOrder__r.Country, XC_WorkOrder__r.XC_Address__r.XC_Region__c, XC_WorkOrder__r.XC_Address__r.XC_City__c
            FROM Case
            WHERE Id IN :listCaseIds 
        ]);
        for(XC_B2BG_QualityCheck__c qc : listNew) {
            if(qc.XC_WorkOrder__c != null && mapWorkOrders.containsKey(qc.XC_WorkOrder__c)){
                WorkOrder parentWo = mapWorkOrders.get(qc.XC_WorkOrder__c);
                qc.XC_TechnicalWorkOrder__c = parentWo.ParentWorkOrderId;
                qc.XC_ContractorCompany__c = parentWo.ParentWorkOrder.XC_AssignedPartner__c;
                qc.XC_Country__c = parentWo.ParentWorkOrder.Country;
                qc.XC_Region__c = parentWo.ParentWorkOrder.XC_Address__r.XC_Region__c;
                qc.XC_City__c = parentWo.ParentWorkOrder.XC_Address__r.XC_City__c;
            } else if(qc.XC_Case__c != null && mapCases.containsKey(qc.XC_Case__c)){
                Case parentCase = mapCases.get(qc.XC_Case__c);
                qc.XC_TechnicalWorkOrder__c = parentCase.XC_WorkOrder__c;
                qc.XC_ContractorCompany__c = parentCase.XC_WorkOrder__r.XC_AssignedPartner__c;
                qc.XC_Country__c = parentCase.XC_WorkOrder__r.Country;
                qc.XC_Region__c = parentCase.XC_WorkOrder__r.XC_Address__r.XC_Region__c;
                qc.XC_City__c = parentCase.XC_WorkOrder__r.XC_Address__r.XC_City__c;
            }    
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @date 11/12/2020
     * @modified by Salvatore Scarpato - salvatore.scarpato@nttdata.com: NR1498
     * @description Method to check answers fields
     * @param listNew - List<XC_B2BG_QualityCheck__c> 
    */ 
    public static void checkAnswers(List<XC_B2BG_QualityCheck__c> listNew) {   

        for(XC_B2BG_QualityCheck__c qc : listNew) {
            Map<String, Object> mapObjectTemp = qc.getPopulatedFieldsAsMap();
            for(String field : mapObjectTemp.keySet()) {
                if(field.toLowerCase().contains('answer') && mapObjectTemp.get(field) == 'NC') {
                    String fieldDescription = field.replace('XC_Answer','XC_NotCompliance_Comments');
                    String valueDescription = (String) mapObjectTemp.get(fieldDescription);
                    if(String.isEmpty(valueDescription)){
                        qc.addError(Label.XC_CL_ErrorMessage_CommentRequiredOnQualityCheck);
                        break;
                    }
                }
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com  
     * @date 11/12/2020
     * @description Method to check answers fields on update
     * @param mapOld - Map<Id, XC_B2BG_QualityCheck__c>
     * @param mapNew - Map<Id, XC_B2BG_QualityCheck__c>
    */ 
    public static void checkAnswersOnUpdate(Map<Id, XC_B2BG_QualityCheck__c> mapOld, Map<Id, XC_B2BG_QualityCheck__c> mapNew) { 
        List<XC_B2BG_QualityCheck__c> listQualityCheckToManage = new List<XC_B2BG_QualityCheck__c>();
        for(String qcOldId : mapOld.keySet()) {
            Map<String, Object> qcOld = mapOld.get(qcOldId).getPopulatedFieldsAsMap();
            Map<String, Object> qcNew = mapNew.get(qcOldId).getPopulatedFieldsAsMap();
            for(String field : qcOld.keySet()) {
                Boolean checkAnswer = field.toLowerCase().contains('answer') && qcNew.get(field) == 'NC';
                Boolean isChanged = qcOld.get(field) != qcNew.get(field);
                if(checkAnswer && isChanged) {
                    listQualityCheckToManage.add(mapNew.get((String) qcNew.get('Id')));
                    break;
                }
            }
        }
        if(!listQualityCheckToManage.isEmpty()) {
            XC_TR_QualityCheck_U_CheckFields.checkAnswers(listQualityCheckToManage);
        }
    }
    
}