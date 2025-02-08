/**
 * @description The Class XC_TR_WorkOrderLineItem_U_upWOS_D.
 */
public without sharing class XC_TR_WorkOrderLineItem_U_upWOS_D {

	/**
	 * @description Gets the work order from children.
	 * @param workOrderID the work order ID
	 * @return the work order from children
	 */
	public static Map<Id,WorkOrder> getWorkOrderFromChildren(Set<ID> workOrderID) {
	
		Map<Id,WorkOrder> workOrderMap = new Map<Id,WorkOrder>([
			SELECT Id,ContactId,XC_MissingQuoteReason__c,Status,XC_Opportunity__c,(SELECT Id,Status,XC_OrderOfActivity__c,XC_ActivityName__c FROM WorkOrderLineItems),
			(SELECT Id,Status, SchedStartTime FROM ServiceAppointments) 
			FROM WorkOrder WHERE Id IN :workOrderID ]); // map of the changed workorderLineItem's fathers

		return workOrderMap;
	}

	/**
	 * @description Gets the opportunity from ids.
	 * @param oppId the opp id
	 * @return the opportunity from ids
	 */
	public static Map<Id,Opportunity> getOpportunityFromIds(List<String> oppId){
		return new Map<Id,Opportunity>([SELECT Id,XC_Contact__c FROM Opportunity WHERE Id =: oppId]);
	}	


	/**
	 * @description Gets the contacts from opportunity.
	 * @param contactId the contact id
	 * @return the contacts from opportunity
	 */
	public static Map<Id,Contact> getContactsFromOpportunity(List<Id> contactId){

		return new Map<Id,Contact>([SELECT Id,Email,Name,XC_Preferredlanguageofcontact__c FROM 
			Contact WHERE Id =: contactId]);

	}

	/*public static List<WorkOrder> getWorkOrderToUpdate(Set<ID> woID) {
		List<WorkOrder> woList = [SELECT Id,Status,XC_MissingQuoteReason__c  FROM WorkOrder WHERE Id IN :woID];

		return woList;
	}*/
}