/**
* @author Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation 24/01/2019
* @date Modification 
* @description XC_TR_WorkOrder_U_CheckCommercialVisit - Class to check to an insert of a Work Order, if there are opened Commercial Visit Opened on the same opportunity/lead
				and in this case prevent the creation of the new Work Order with type Commercial Visit.
*/

public without sharing class XC_TR_WorkOrder_U_CheckCommercialVisit {

	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_CheckCommercialVisit');

	/**
	 * @description Check existing commercial visit. 
	 * @param listNew the list new
	 */
	public static void checkExistingCommercialVisit(List<WorkOrder> listNew){
		XC_UTIL_Debug.debug(DEBUGACTIVE,'Enter in class XC_TR_WorkOrder_U_CheckCommercialVisit');  
		Map<Id,WorkOrder> leadWorkOrderMap = new Map<Id,WorkOrder>();
		Map<Id,WorkOrder> opportunityWorkOrderMap = new Map<Id,WorkOrder>();
		for(WorkOrder wo : listNew){
            System.debug('wo.XC_WorkTypeCategory__c IN TRIGGER-->' + wo.XC_WorkTypeCategory__c);
			if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit && wo.XC_Opportunity__c != null){
				opportunityWorkOrderMap.put(wo.XC_Opportunity__c, wo);	
			}
			if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit && wo.XC_Lead__c != null){
				leadWorkOrderMap.put(wo.XC_Lead__c, wo);
			}
		}
 
		if(!leadWorkOrderMap.isEmpty()){
			manageLeads(leadWorkOrderMap);
		}

		if(!opportunityWorkOrderMap.isEmpty()){
			manageOpportunities(opportunityWorkOrderMap);
		}
	}

	/**
	 * @description manageLeads
	 * @param leadWorkOrderMap
	 */

	private static void manageLeads(Map<Id,WorkOrder> leadWorkOrderMap){
		Map<Id, Lead> leadMap = new Map<Id,Lead>([
			SELECT Id, 
			(SELECT Id FROM Work_Orders__r WHERE XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_CommercialVisit)
			FROM Lead 
			WHERE Id IN: leadWorkOrderMap.keyset()]);
		for(Lead ld : leadMap.values()){
			XC_UTIL_Debug.debug(DEBUGACTIVE,'WO On Lead' + ld);   
			if(!ld.Work_Orders__r.isEmpty()){
				XC_UTIL_Debug.debug(DEBUGACTIVE, 'WO On 2 - # of WO' + ld.Work_Orders__r.size());
				WorkOrder wo = leadWorkOrderMap.get(ld.Id);
				wo.addError(Label.XC_CL_WorkOrder_CommercialVisitErrorOnLead);
			}
		}	
	}

	
	/**
	 * @description manageOpportunities
	 * @param opportunityWorkOrderMap
	 */

	private static void manageOpportunities(Map<Id,WorkOrder> opportunityWorkOrderMap){
		Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([
			SELECT Id, 
			(SELECT Id FROM Work_Orders__r WHERE XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_CommercialVisit)
			FROM Opportunity 
			WHERE Id IN: opportunityWorkOrderMap.keyset()]);
		for(Opportunity opportunity : opportunityMap.values()){
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'WO On Opportunity 1' + opportunity);
			if(!opportunity.Work_Orders__r.isEmpty()){
				XC_UTIL_Debug.debug(DEBUGACTIVE, 'WO On Opportunity 2' + opportunity.Work_Orders__r.size());
				WorkOrder wo = opportunityWorkOrderMap.get(opportunity.Id);
				wo.addError(Label.XC_CL_WorkOrder_CommercialVisitErrorOnOpportunity); 
			}
		}	
	}
}