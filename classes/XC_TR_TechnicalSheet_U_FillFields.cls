/**
* @author Nicola Mariniello - nmariniello@deloitte.it
* @date 03/05/2020
* @date Modification 
* @description XC_TR_TechnicalSheet_U_FillFields - The class manages Technical Sheet fields
*/


public without sharing class XC_TR_TechnicalSheet_U_FillFields {


    /**   
     * @param listNew - List<XC_TechnicalSheet__c>
     * @description Method to populate the workorder id on technical sheet related records
     */ 
    public static void fillFields(List<XC_TechnicalSheet__c> listNew) {

        Set<Id> woIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'XC_WorkOrder__c');
        Set<Id> caseIds = XC_UTIL_Sobject.getSetIdsOnField(listNew, 'XC_Case__c');

        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>();
        Map<Id, Case> caseIncentiveMap = new Map<Id, Case>();
        Map<Id, Case> oiIdCaseMap = new Map<Id, Case>();
        if(!woIds.isEmpty()) {
            woMap = new Map<Id, WorkOrder>([SELECT Id, XC_ConfigurationItemIncentive__c, XC_ConfigurationItemIncentive__r.XC_Particle__c, XC_ConfigurationItemIncentive__r.XC_Sheet__c FROM WorkOrder WHERE Id IN: woIds]);
            List<String> oiIncentiveFromWO = XC_UTIL_Sobject.getListFieldValues(woMap.values(), 'XC_ConfigurationItemIncentive__c');
            if(!oiIncentiveFromWO.isEmpty()) {
                caseIncentiveMap = new Map<Id, Case>([SELECT Id, XC_ConfigurationItemIncentive__c FROM Case WHERE XC_ConfigurationItemIncentive__c IN :oiIncentiveFromWO AND XC_ProvisioningStep__r.XC_StepLabel__c = 'Documental Check']);
                for(Case c : caseIncentiveMap.values()) {
                    oiIdCaseMap.put(c.XC_ConfigurationItemIncentive__c, c);
                }
            }
        }

        Map<Id, Case> caseMap = new Map<Id, Case>();
        Map<Id, WorkOrder> woIncentiveMap = new Map<Id, WorkOrder>();
        Map<Id, WorkOrder> oiIdWoMap = new Map<Id, WorkOrder>();
        if(!caseIds.isEmpty()) {
            caseMap = new Map<Id, Case>([SELECT Id, XC_ConfigurationItemIncentive__c, XC_ConfigurationItemIncentive__r.XC_Particle__c, XC_ConfigurationItemIncentive__r.XC_Sheet__c FROM Case WHERE Id IN: caseIds]);
            List<String> oiIncentiveFromCase = XC_UTIL_Sobject.getListFieldValues(caseMap.values(), 'XC_ConfigurationItemIncentive__c');
            if(!oiIncentiveFromCase.isEmpty()) {
                woIncentiveMap = new Map<Id, WorkOrder>([SELECT Id, XC_ConfigurationItemIncentive__c FROM WorkOrder WHERE XC_ConfigurationItemIncentive__c IN :oiIncentiveFromCase AND XC_WorkTypeCategory__c = 'Delivery & Installation']);
                for(WorkOrder wo : woIncentiveMap.values()) {
                    oiIdWoMap.put(wo.XC_ConfigurationItemIncentive__c, wo);
                }
            }
        }

        for(XC_TechnicalSheet__c ts : listNew) {
            if(String.isNotBlank(ts.XC_WorkOrder__c) && oiIdCaseMap.get(woMap.get(ts.XC_WorkOrder__c).XC_ConfigurationItemIncentive__c) != null) {
                ts.XC_Case__c = oiIdCaseMap.get(woMap.get(ts.XC_WorkOrder__c).XC_ConfigurationItemIncentive__c).Id;
            } else if (String.isNotBlank(ts.XC_Case__c) && oiIdWoMap.get(caseMap.get(ts.XC_Case__c).XC_ConfigurationItemIncentive__c) != null) {
                ts.XC_WorkOrder__c = oiIdWoMap.get(caseMap.get(ts.XC_Case__c).XC_ConfigurationItemIncentive__c).Id;
            }
            //Release R6 2021 - NR0880 - Incentive form Enhancement – Sheet and Particle info - ET
            if(String.isBlank(ts.XC_Particle__c)) {
                if(String.isNotBlank(ts.XC_WorkOrder__c) && String.isNotBlank(woMap.get(ts.XC_WorkOrder__c).XC_ConfigurationItemIncentive__c)) {
                    ts.XC_Particle__c = woMap.get(ts.XC_WorkOrder__c).XC_ConfigurationItemIncentive__r.XC_Particle__c;
            	} else if (String.isNotBlank(ts.XC_Case__c) && String.isNotBlank(caseMap.get(ts.XC_Case__c).XC_ConfigurationItemIncentive__c)) {
                    ts.XC_Particle__c = caseMap.get(ts.XC_Case__c).XC_ConfigurationItemIncentive__r.XC_Particle__c;
            	}
            }
            if(String.isBlank(ts.XC_Sheet__c)) {
                if(String.isNotBlank(ts.XC_WorkOrder__c) && String.isNotBlank(woMap.get(ts.XC_WorkOrder__c).XC_ConfigurationItemIncentive__c)) {
                    ts.XC_Sheet__c = woMap.get(ts.XC_WorkOrder__c).XC_ConfigurationItemIncentive__r.XC_Sheet__c;
                } else if (String.isNotBlank(ts.XC_Case__c) && String.isNotBlank(caseMap.get(ts.XC_Case__c).XC_ConfigurationItemIncentive__c)) {
                    ts.XC_Sheet__c = caseMap.get(ts.XC_Case__c).XC_ConfigurationItemIncentive__r.XC_Sheet__c;
                }
            }
            /*
            //Release R6 2021 - NR0880 - Incentive form Enhancement – Sheet and Particle info - ET
            if(String.isNotBlank(ts.XC_WorkOrder__c) && String.isNotBlank(woMap.get(ts.XC_WorkOrder__c).XC_ConfigurationItemIncentive__c)) {
                ts.XC_Particle__c = woMap.get(ts.XC_WorkOrder__c).XC_ConfigurationItemIncentive__r.XC_Particle__c;
                ts.XC_Sheet__c = woMap.get(ts.XC_WorkOrder__c).XC_ConfigurationItemIncentive__r.XC_Sheet__c;
            } else if (String.isNotBlank(ts.XC_Case__c) && String.isNotBlank(caseMap.get(ts.XC_Case__c).XC_ConfigurationItemIncentive__c)) {
                ts.XC_Particle__c = caseMap.get(ts.XC_Case__c).XC_ConfigurationItemIncentive__r.XC_Particle__c;
                ts.XC_Sheet__c = caseMap.get(ts.XC_Case__c).XC_ConfigurationItemIncentive__r.XC_Sheet__c;
            }
            */
            if(String.isBlank(ts.XC_Particle__c) || String.isBlank(ts.XC_Sheet__c)) {
				ts.addError(Label.XC_CL_TechnicalSheetRequiredFields);
            }
            //Release R6 2021 - NR0880 - Incentive form Enhancement – Sheet and Particle info - ET
        }
    }

}