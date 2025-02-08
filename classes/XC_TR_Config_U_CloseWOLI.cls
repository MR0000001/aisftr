/*************************************************************************************************************************************************
* @author            : Nicola Mariniello nmariniello@deloitte.it
* @date Creation     : 13/02/2019
* @date Modification : dd/mm/yyyy
* @description       : XC_TR_Config_U_CloseWOLI – Util to close a WOLI under the related WorkOrder when a Quote/Order Configuration is created
*************************************************************************************************************************************************/

public without sharing class XC_TR_Config_U_CloseWOLI {

    /**
     * @description  Close WOLI 2.
     *
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new 
     */
    public static void closeWOLI2(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew) {
        List<String> fieldList = new List<String>{'RecordTypeId'};
        List<NE__Order__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            closeWOLIofRelatedWorkOrder(listChanged);
        }
    }


    /**
     * **********************************************************************************.
     *
     * @param configList the config list
     * @description : Method to close the Second WOLI of a WorkOrder
     * **********************************************************************************
     */
    public static void closeWOLIofRelatedWorkOrder(List<NE__Order__c> configList) {

        List<String> optyIds = XC_UTIL_Sobject.getListFieldValues(configList, 'NE__OptyId__c');

        Map<Id,Opportunity> oppListMap = new Map<Id,Opportunity>([SELECT Id, (SELECT Id, Status FROM Work_Orders__r WHERE
         (Status != :Label.XC_CL_WorkOrder_Cancelled OR Status != :Label.XC_CL_WorkOrder_CannotComplete 
         OR Status != :Label.XC_CL_WorkOrder_Completed)) FROM Opportunity WHERE Id IN: optyIds]);
        List<Opportunity> oppList = oppListMap.values();

        List<Id> workOrderIds = new List<Id>();
        for(Opportunity opp : oppList) {
            if(!opp.Work_Orders__r.isEmpty()) {
                workOrderIds.add(opp.Work_Orders__r.get(0).Id);
            }
        }

        Map<Id,WorkOrder> woListMap = new Map<Id,WorkOrder>([SELECT Id, XC_Opportunity__c, (SELECT Id, XC_OrderOfActivity__c,
         Status FROM WorkOrderLineItems WHERE XC_OrderOfActivity__c = 2) FROM WorkOrder WHERE Id IN :workOrderIds]);
        List<WorkOrder> woList = woListMap.values();

        Map<Id, WorkOrderLineItem> mapOppIdWOLI = new Map<Id, WorkOrderLineItem>();
        for(WorkOrder wo : woList) {
            if(!wo.WorkOrderLineItems.isEmpty()) {
                mapOppIdWOLI.put(wo.XC_Opportunity__c, wo.WorkOrderLineItems.get(0));
            }
        }
        
        List<WorkOrderLineItem> woliListToUpdate = populateWoliListToUpdate(configList, mapOppIdWOLI);
        XC_UTIL_Sobject.updateListRecords(woliListToUpdate);
    }

    private static List<WorkOrderLineItem> populateWoliListToUpdate(List<NE__Order__c> configList, Map<Id, WorkOrderLineItem> mapOppIdWOLI){
        List<WorkOrderLineItem> woliListToUpdate = new List<WorkOrderLineItem>();
        Id configOrderId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        Id configQuoteId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        for(NE__Order__c config : configList) {
            if(mapOppIdWOLI.containsKey(config.NE__OptyId__c) &&
            (config.RecordTypeId == configOrderId || config.RecordTypeId == configQuoteId)) {
                WorkOrderLineItem woli = mapOppIdWOLI.get(config.NE__OptyId__c);
                if(woli.Status != Label.XC_CL_WorkOrderLineItem_Closed) {
                    woli.Status = Label.XC_CL_WorkOrderLineItem_Closed;
                    woliListToUpdate.add(woli);
                }
            }
        }
        return woliListToUpdate;
    }

	/**
	 * @author Dario Tramontin dtramontin@deloitte.it
	 * @date Creation 04/09/2019
	 * @date Modification dd/mm/yyyy
	 * @description Closed related case of WO Disconnect
	 * @param listNew list of case

	 */
    public static void caseDisconnectClosure(List<NE__Order__c> listNew, Map<Id, NE__Order__c> mapOld, Map<Id, NE__Order__c> mapNew){
        System.debug('## caseDisconnectClosure ##');
        List<String> listId = new List<String>();
        
        listNew = XC_UTIL_SObject.getListChanged(new List<String>{'NE__OrderStatus__c'}, mapOld, mapNew);
		if(listNew.isEmpty()) {
			return;
		}
        for(NE__Order__c order : listNew ){
            if(order.XC_CaseId__c != null){
                listId.add(order.XC_CaseId__c);
            }
        }
        Map<String,Case> mapCase= new Map<String,Case>([SELECT Id, Status FROM Case WHERE Id IN : listId]);
        List<Case> caseToUpdate = new List<Case>();
        for( NE__Order__c order : listNew){
            System.debug('Status: '+ order.NE__OrderStatus__c);
            System.debug(' Type: ' + order.NE__Type__c);
            if( order.NE__OrderStatus__c == Label.XC_CL_Configuration_Item_Completed && (order.NE__Type__c == Label.XC_CL_Configuration_TypeDisconnection || order.NE__Type__c == Label.XC_CL_Configuration_TypeChangeOrder) ){
                if( order.XC_CaseId__c != null){
                    mapCase.get(order.XC_CaseId__c).Status = XC_AT_Constants.TRIGGER_STATUS_ESTA007;
                    System.debug('Update status of case: '+ order.XC_CaseId__c);
                    caseToUpdate.add(mapCase.get(order.XC_CaseId__c));
                }
            }
        }
        if(caseToUpdate != null){
            XC_UTIL_Sobject.updateListRecords(caseToUpdate);
        }
    }
}