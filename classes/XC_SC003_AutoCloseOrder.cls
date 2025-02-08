/**
* @author Monica Cutillo & Francesco Bongiovanni & Giulio Proia
* @date Creation 26/09/2018
* @date Modification 08/10/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_SC003_AutoCloseOrder - Batch to close expired orders
*/

public class XC_SC003_AutoCloseOrder implements Schedulable, Database.Batchable<sObject> {

	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC003_AutoCloseOrder');

	/**
     * @description execute method
     * @param sc - SchedulableContext 
    */
	public void execute(SchedulableContext sc) {	   
		Id batchId = Database.executeBatch(new XC_SC003_AutoCloseOrder());
	}
	
	/**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator
    */
	public Database.QueryLocator start(Database.BatchableContext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC003_AutoCloseOrder');
		String query = 'SELECT Id, Name, NE__OptyId__c, NE__OptyId__r.StageName, NE__OptyId__r.XC_LossReason__c, XC_Status__c ' +
						' FROM NE__Order__c ';
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ query ---> ' + query);						
		if(!Test.isRunningTest()) {
			query = query + ' WHERE XC_Status__c IN (\'' + Label.XC_CL_Configuration_Draft + '\', \'' + Label.XC_CL_Configuratione_QuoteNotifiedToClient + '\') ' +
					' AND RecordType.DeveloperName = \'' + Label.XC_CL_Order_RecordTypeQuote + '\' AND XC_OrderToExpire__c = true';
		}
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Final query ---> ' + query);
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'End start method');
		return Database.getQueryLocator(query);
	}

	/** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
   	public void execute(Database.BatchableContext bc, List<NE__Order__c> scope) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Execute method for batch XC_SC003_AutoCloseOrder');
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ scope ---> ' + scope);
		List<NE__Order__c> listOrderToProcessToUpdate = new List<NE__Order__c>();
		List<Opportunity> listOpportunityToUpdate = new List<Opportunity>();
		
     	for(NE__Order__c order : scope) {
			XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ For order ---> ' + order);
			Opportunity opp = new Opportunity(Id = order.NE__OptyId__c);
			opp.StageName = Label.XC_CL_Opportunity_ClosedLost;
				order.XC_Status__c = Label.XC_CL_Configuration_QuoteRejected;

			if(order.XC_Status__c != Label.XC_CL_Configuratione_QuoteNotifiedToClient) {
				order.XC_LossReason__c = Label.XC_CL_Configuration_QuoteNotSentReason;
				opp.XC_LossReason__c = Label.XC_CL_Opportunity_QuoteNotSentReason;
			}else{
				order.XC_LossReason__c = Label.XC_CL_Configuration_QuoteNotAcceptedReason;
				opp.XC_LossReason__c = Label.XC_CL_Opportunity_QuoteNotAccepted;
			}
 			listOrderToProcessToUpdate.add(order);
			listOpportunityToUpdate.add(opp);
     	}

		// Update Order and check for BatchErrorLog
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listOrderToProcessToUpdate ---> ' + listOrderToProcessToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(listOrderToProcessToUpdate,false);
		system.debug('result'+' '+resultList);
		List<XC_BatchErrorLog__c> errorLogForOrder = new List<XC_BatchErrorLog__c>();  
		for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC003_AutoCloseOrder';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Close expired Order';
                bel.XC_RecordId__c = wr.errorObjectId;
                errorLogForOrder.add(bel);
            }
        }
		
		// Update Opportunity and check for BatchErrorLog
		List<XC_UTIL_Sobject.WrapperResult> oppUpdateList = XC_UTIL_Sobject.updateListRecords(listOpportunityToUpdate,false);
		List<XC_BatchErrorLog__c> errorLogForOpportunity = new List<XC_BatchErrorLog__c>();  
		system.debug('result Opp'+' '+oppUpdateList);
		for(XC_UTIL_Sobject.WrapperResult wr : oppUpdateList){
            if(!wr.success){
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC003_AutoCloseOrder';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Update Opportunity Close Reason';
                bel.XC_RecordId__c = wr.errorObjectId;
                errorLogForOpportunity.add(bel);
            }
        }

		XC_UTIL_Sobject.insertListRecords(errorLogForOrder);
		XC_UTIL_Sobject.insertListRecords(errorLogForOpportunity);
		updateWorkOrder(XC_UTIL_Sobject.getIds(listOpportunityToUpdate));
	}
	 
	/**
     * @description finish method
     * @param bc - BatchableContext 
    */
	public void finish(Database.BatchableContext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ FINISH batch XC_SC003_AutoCloseOrder');
	}

	/**
	 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
	 * @date 08/10/2019
	 * @description Method to update Work Order status when an Order is rejected
	 * @param listIdOpportunity - List<Id>
    */
	private void updateWorkOrder(List<Id> listIdOpportunity) {
		List<WorkOrder> listWorkOrder = new List<WorkOrder>([
			SELECT Id,
				(SELECT Id FROM ServiceAppointments)
			FROM WorkOrder
			WHERE XC_Opportunity__c IN :listIdOpportunity
		]);

		List<WorkOrder> listWoToUpdate = new List<WorkOrder>();
		List<ServiceAppointment> listSaToUpdate = new List<ServiceAppointment>(); 
		for(WorkOrder wo : listWorkOrder) {
			wo.XC_StatusReason__c = Label.XC_CL_QuoteExpired;
			listWoToUpdate.add(wo);
			for(ServiceAppointment sa : wo.ServiceAppointments) {
				sa.XC_StatusReason__c = Label.XC_CL_PendingAcceptanceQuote;
				listSaToUpdate.add(sa);
			}
		}

		List<XC_UTIL_Sobject.WrapperResult> saWr = XC_UTIL_Sobject.updateListRecords(listSaToUpdate);
		if(!XC_UTIL_Sobject.checkDMLResults(saWr)) {
			XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
			bel.Name = 'XC_SC003_AutoCloseOrder';
			bel.XC_ErrorMessage__c = saWr[0].errorMessage;
			bel.XC_TypeOfOperation__c = 'Close expired Order';
			XC_UTIL_Sobject.insertRecord(bel);
			return;
		}
		XC_UTIL_Sobject.updateListRecords(listWoToUpdate);
	}
	
}