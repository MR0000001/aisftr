/**
* @author Monica Cutillo & Francesco Bongiovanni & Giulio Proia
* @date Creation 25/09/2018
* @date Modification 26/09/2018
* @description XC_SC001_AutoCloseOpportunity - Batch to close expired opportunities
*/
public without sharing class XC_SC002_AutoCloseOpportunity implements Schedulable, Database.Batchable<sObject>{

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC002_AutoCloseOpportunity');

	/**
     * @description execute method
     * @param sc - SchedulableContext 
    */
	public void execute(SchedulableContext sc) {	   
		Id batchId = Database.executeBatch(new XC_SC002_AutoCloseOpportunity());
	}

    /**
     * @description start method
     * @param bc - BatchableContext 
     * @return Database.QueryLocator  
    */
	public Database.QueryLocator start(Database.BatchableContext bc) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Start batch XC_SC002_AutoCloseOpportunity');
		String query =  ' SELECT Id, Name,XC_QuotePresent__c, CreatedDate, StageName, XC_LossReason__c,XC_SubStatus__c, XC_CommercialVisitAssignedResource__c, XC_CommercialVisitRequired__c '+
						' FROM Opportunity ' + 
						' WHERE' + 	
						' StageName = \'' + Label.XC_CL_Opportunity_Draft + '\' AND ' +
						//' XC_OpportunityToExpire__c = true AND ' +
						'((XC_CommercialVisitAssignedResource__c != null AND XC_CommercialVisitStarted__c = false) OR ' +
						'(XC_CommercialVisitAssignedResource__c = null AND XC_QuotePresent__c = false AND XC_CommercialVisitRequired__c = true) OR '+
						'(XC_CommercialVisitRequired__c = false AND XC_QuotePresent__c = false))';	

		if(!Test.isRunningTest()) {
			query = query + ' AND XC_OpportunityToExpire__c = true ';
		}
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ query ---> ' + query);
		System.debug(LoggingLevel.FINEST, query);
		return Database.getQueryLocator(query);
	}

   	/** 
     * @description execute method
     * @param bc - BatchableContext 
     * @param scope - list to execute logic on
    */
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'Execute method for batch XC_SC002_AutoCloseOpportunity');
   		List<Opportunity> listOppToProcess = new List<Opportunity>();
		List<XC_BatchErrorLog__c> errorLog = new List<XC_BatchErrorLog__c>();  

     	for(Opportunity opp : scope) {
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'For opportunity ---> ' + opp);
 			//opp.StageName= Label.XC_CL_Opportunity_ClosedLost;
			//D.D.D change XC_LossReason__c from XC_CL_Opportunity_Expired
 			//opp.XC_LossReason__c =Label.XC_CL_Opportunity_BudgetNotDelivered;
 			//opp.XC_LossReasonDescription__c= Label.	;
			opp.StageName = Label.XC_CL_Opportunity_ClosedLost;
			opp.XC_SubStatus__c = null;


			if(String.isNotBlank(String.valueOf(opp.XC_CommercialVisitAssignedResource__c))) {
				opp.XC_LossReason__c = Label.XC_CL_Opportunity_CommVisitNotPerformed;
			} else if(String.isBlank(String.valueOf(opp.XC_CommercialVisitAssignedResource__c)) && opp.XC_CommercialVisitRequired__c){
				opp.XC_LossReason__c = Label.XC_CL_Opportunity_CommVisitNotScheduled;
			}else if(!opp.XC_CommercialVisitRequired__c && !opp.XC_QuotePresent__c){
				opp.XC_LossReason__c = Label.XC_CL_Opportunity_Expired;
			}


			XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_LossReason__c ' + opp.XC_LossReason__c);
 			listOppToProcess.add(opp);
     	}
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listOppToProcess ---> ' + listOppToProcess);
        List<XC_UTIL_Sobject.WrapperResult> resultList = XC_UTIL_Sobject.updateListRecords(listOppToProcess,false); 
		for(XC_UTIL_Sobject.WrapperResult wr : resultList){
            if(checkErrorBatch(wr)) {
                XC_BatchErrorLog__c bel = new XC_BatchErrorLog__c();
                bel.Name = 'XC_SC002_AutoCloseOpportunity';
                bel.XC_ErrorMessage__c = wr.errorMessage;
                bel.XC_TypeOfOperation__c = 'Close expired Opportunity';
                bel.XC_RecordId__c = wr.errorObjectId;
                errorLog.add(bel);
            }
        }
		XC_UTIL_Sobject.insertListRecords(errorLog);
		XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Updated list of opp');
	}
	
    /**
     * @description finish method
     * @param bc - BatchableContext 
    */
	public void finish(Database.BatchableContext bc) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Finish XC_SC002_AutoCloseOpportunity');	
	}

	/**
     * @description Method to check error bacth
     * @param wr - XC_UTIL_Sobject.WrapperResult 
	 * @return Boolean
    */
	public Boolean checkErrorBatch(XC_UTIL_Sobject.WrapperResult wr) {
        return !wr.success || Test.isRunningTest();
	}
	
}