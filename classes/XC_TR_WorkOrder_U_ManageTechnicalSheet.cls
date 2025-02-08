/**
* @author Nicola Mariniello - nmariniello@deloitte.it
* @date 03/05/2020
* @date Modification 
* @description XC_TR_WorkOrder_U_ManageTechnicalSheet - The class manages Technical Sheet records
*/


public without sharing class XC_TR_WorkOrder_U_ManageTechnicalSheet {


    /**   
     * @param listNew - List<WorkOrder>
     * @description Method to populate the workorder id on technical sheet related records
     */ 
    public static void fillWOOnTechnicalSheets(List<WorkOrder> listNew) {

        Set<Id> incentiveItemIds = new Set<Id>();
        List<WorkOrder> woToProcess = new List<WorkOrder>();
        for(WorkOrder wo : listNew) {
            if(wo.XC_WorkTypeCategory__c == 'Delivery & Installation' && String.isNotBlank(wo.XC_ConfigurationItemIncentive__c)) {
                incentiveItemIds.add(wo.XC_ConfigurationItemIncentive__c);
                woToProcess.add(wo);
            }
        }
        if(incentiveItemIds.isEmpty()){
            return;
        }

        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, XC_ConfigurationItemIncentive__c, (SELECT Id, XC_WorkOrder__c FROM Technical_Sheet__r)
                                                    FROM Case
                                                    WHERE XC_ConfigurationItemIncentive__c IN :incentiveItemIds AND XC_ProvisioningStep__r.XC_StepLabel__c = 'Documental Check']);
        if(caseMap.isEmpty()) {
            return;
        }

        Map<Id, List<XC_TechnicalSheet__c>> incentiveIdTecSheetMap = new Map<Id, List<XC_TechnicalSheet__c>>();
        for(Case c : caseMap.values()) {
            if(incentiveIdTecSheetMap.containsKey(c.XC_ConfigurationItemIncentive__c)) {
                incentiveIdTecSheetMap.get(c.XC_ConfigurationItemIncentive__c).addAll(c.Technical_Sheet__r);
            } else {
                incentiveIdTecSheetMap.put(c.XC_ConfigurationItemIncentive__c, c.Technical_Sheet__r);
            }
        }

        List<XC_TechnicalSheet__c> tecSheetsToUpdate = new List<XC_TechnicalSheet__c>();
        for(WorkOrder wo : woToProcess) {
            List<XC_TechnicalSheet__c> tsList = incentiveIdTecSheetMap.get(wo.XC_ConfigurationItemIncentive__c);
            for(XC_TechnicalSheet__c ts : tsList) {
                if(ts.XC_WorkOrder__c != wo.Id) {
                    ts.XC_WorkOrder__c = wo.Id;
                    tecSheetsToUpdate.add(ts);
                }
            }
        }

        if(!tecSheetsToUpdate.isEmpty()) {
            XC_UTIL_SObject.updateListRecords(tecSheetsToUpdate);
        }
    }


    /**   
     * @param listNew - List<WorkOrder>
     * @description Method to populate the workorder id on technical sheet related records
     */ 
    public static void searchTechnicalSheetForClosure(Map<Id, WorkOrder> mapOld, Map<Id, WorkOrder> mapNew) {

        List<WorkOrder> listChanged = XC_UTIL_SObject.getListChanged(new List<String>{'Status'}, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }

        Set<Id> woIds = new Set<Id>();
        for(WorkOrder wo : listChanged) {
            if(String.isNotBlank(wo.XC_ProductSubType__c) && wo.XC_ProductSubType__c.equals(Label.XC_CL_ProductSubtypeWallbox)) { //NR1084 - New products JuiceBox if Product SubType = 'WallBox' doesn't check for Techincal Sheet records
                continue;
            }
            if(wo.Status == Label.XC_CL_WorkOrder_Completed && String.isNotBlank(wo.XC_ConfigurationItemIncentive__c)) {
                woIds.add(wo.Id);
            }
        }
        if(woIds.isEmpty()) {
            return;
        }

        Map<Id, XC_TechnicalSheet__c> tsMap = new Map<Id, XC_TechnicalSheet__c>([SELECT Id, XC_WorkOrder__c FROM XC_TechnicalSheet__c WHERE XC_WorkOrder__c IN :woIds]);
        for(Id woId : woIds) {
            Boolean check = true;
            for(XC_TechnicalSheet__c ts : tsMap.values()) {
                if(ts.XC_WorkOrder__c == woId) {
                    check = false;
                }
            }
            if(check) {
                mapNew.get(woId).addError(Label.XC_CL_Workorder_TechnicalSheetRelated);
            }
        }

    }
}