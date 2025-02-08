/** 
 * The Class XC_LCC042_EmailQuotes.
 *
 * @author Giulio Serra giserra@deloitte.it & Martina Barone - marbarone@deloitte.it
 * @date Creation 21/08/2018
 * @date Modification dd/mm/yyyy
 * @description manage the notification of the owner of the opportunity if
 * 		 some of his configuration are in a draft status
 */

public without sharing class XC_LCC042_EmailQuotes {
	public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC042_EmailQuotes');
	/**
	* @description The Class resultWrapper.
	*/
	public class resultWrapper {
		@AuraEnabled
		public Boolean success;
		@AuraEnabled
		public String result; 
	}
	

	/**
	* Gets the configuration notification result.
	*
	* @author Giulio Serra giserra@deloitte.it & Martina Barone - marbarone@deloitte.it
	* @param recordId the record id
	* @return the configuration notification result
	* @date Creation 21/08/2018
	* @date Modification dd/mm/yyyy
	* @description get the opportunity with his children and check if there are some in 'Draft'
	* 	    and changes the status of the opportunity
	*/

	@AuraEnabled
	public static resultWrapper getConfigurationNotificationResult(Id recordId){
		resultWrapper result = new resultWrapper();
		result.success = true;
		if(!Schema.SObjectType.Opportunity.isAccessible()) {
			return new resultWrapper();
		}
		Map<Id,Opportunity> queriedOrderMap = new Map<Id,Opportunity>([SELECT Id, XC_SendingQuote__c, XC_LegalEntity__c, XC_Contact__c, AccountId, StageName, (SELECT Id, Name, XC_Status__c,NE__Parent_Order__c,RecordType.DeveloperName FROM NE__Orders__r) 
									FROM Opportunity WHERE Id =: recordId LIMIT 1]);
		List<Opportunity> queriedOrder = queriedOrderMap.values();
		if(queriedOrder[0].StageName == Label.XC_CL_Opportunity_ClosedWon){
			result.result = Label.XC_CL_Opportunity_QuoteError_Won;
			result.success = false;
			return result;
		}
		if(queriedOrder[0].StageName == Label.XC_CL_Opportunity_ClosedLost){
			result.result = Label.XC_CL_Opportunity_QuoteError_Lost;
			result.success = false;
			return result;
		}
		if(queriedOrder[0].NE__Orders__r.size() == 0){
			result.result = Label.XC_CL_Opportunity_QuoteError_NC;
			result.success = false;
			return result;
		}
		List<NE__Order__c> children = getDraftConfigurations(queriedOrder[0]);
		if(children.size() == 0){
			result.result = Label.XC_CL_Opportunity_QuoteError_ND;
			result.success = false;
			return result;
		}
		String serialized = createCustomInteraction(queriedOrder[0]);
		XC_UTIL_ResultWrapper rw = XC_LCC039_CustomerInteraction.newEmailForCustomer(serialized);
		if(!rw.success){
			System.debug('ERRORE' + rw.resultMessage);
			result.result = 'Failed to send the email to the costumer:' + rw.resultMessage;
			result.success = false;
			return result;
		}
		result = changeConfigurationStatus(children);
		/*if(!rw.success){
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'update configuration children error' + rw.resultMessage);
		}*/
		result = changeOpportunityStatus(queriedOrder[0]);
		/*if(!rw.success){
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'update opportunity error' + rw.resultMessage);
		}*/
		return result;
	}


	/**
	* Gets the draft configurations.
	*
	* @author Giulio Serra giserra@deloitte.it & Martina Barone - marbarone@deloitte.it
	* @param opp the opp
	* @return the draft configurations
	* @date Creation 21/08/2018
	* @date Modification dd/mm/yyyy
	* @description get all the configurations of an opportunity in 'Draft'
	*/
	@TestVisible
	private static List<NE__Order__c> getDraftConfigurations(Opportunity opp){

		List<NE__Order__c> configuration = new List<NE__Order__c>();

		for(NE__Order__c conf : opp.NE__Orders__r){
			if(conf.XC_Status__c == Label.XC_CL_Configuration_Draft && conf.RecordType.DeveloperName == Label.XC_CL_Configuration_RtQuote ){
				configuration.add(conf);
			}

		}

		return configuration;
	}


	/**
		* Change opportunity status.
		*
		* @author Giulio Serra giserra@deloitte.it & Martina Barone - marbarone@deloitte.it
		* @param opp the opp
		* @return the result wrapper
		* @date Creation 21/08/2018
		* @date Modification dd/mm/yyyy
		* @description change the opportunity sending quote to 'Sent'
		*/ 
	@TestVisible
	private static resultWrapper changeOpportunityStatus(Opportunity opp){

		resultWrapper rw = new resultWrapper();
		rw.success = true;
		
		opp.XC_SendingQuote__c = Label.XC_CL_Order_StatusSent;
		XC_UTIL_Sobject.WrapperResult wr = XC_UTIL_Sobject.updateRecord(opp);

		rw.success = wr.success;
		rw.result = wr.errorMessage;

		return rw;	

	}


	/**
		* Change configuration status.
		*
		* @author Giulio Serra giserra@deloitte.it & Martina Barone - marbarone@deloitte.it
		* @param configuration the configuration
		* @return the result wrapper
		* @date Creation 21/08/2018
		* @date Modification dd/mm/yyyy
		* @description change all the 'Draft' configurations to 'Notifiy to client'
		*/
	@TestVisible
	private static resultWrapper changeConfigurationStatus(List<NE__Order__c> configuration){

		List<NE__Order__c> toUpdate =  new List<NE__Order__c>();

		resultWrapper rw = new resultWrapper();
		rw.success = true;

		for(NE__Order__c conf : configuration){
			conf.XC_Status__c = Label.XC_CL_Configuratione_QuoteNotifiedToClient;
			toUpdate.add(conf);
		}	

		List<XC_UTIL_Sobject.WrapperResult> updates = XC_UTIL_Sobject.updateListRecords(toUpdate);
		getUpdateResult(rw,updates);

		return rw;	

	}


		/**
		* Gets the update result.
		*
		* @author Giulio Serra giserra@deloitte.it & Martina Barone - marbarone@deloitte.it
		* @param rw the rw
		* @param results the results
		* @date Creation 21/08/2018
		* @date Modification dd/mm/yyyy
		* @description create a custom interaction for an opportunity
		*/
	@TestVisible
	private static void getUpdateResult(resultWrapper rw, List<XC_UTIL_Sobject.WrapperResult> results){

		for(XC_UTIL_Sobject.WrapperResult rswpr : results ){
			if(!rswpr.success){
				rw.success = false;
				rw.result = rswpr.errorMessage;
			}	
		}
	}


		/**
		* Creates the custom interaction.
		*
		* @author Giulio Serra giserra@deloitte.it & Martina Barone - marbarone@deloitte.it
		* @param opp the opp
		* @return the string
		* @date Creation 21/08/2018
		* @date Modification dd/mm/yyyy
		* @description create a custom interaction for an opportunity
		*/
	@TestVisible
	private static String createCustomInteraction(Opportunity opp){

		Map<String,Object> valueMap = new Map<String,Object>();

		valueMap.put('customerType', 'Opportunity_QuoteCreated');
		valueMap.put('opportunityId', opp.Id);
		valueMap.put('skipComunication', false);
		valueMap.put('accountId', opp.AccountId);
		valueMap.put('isAccountRequired', true);
		valueMap.put('legalEntity', opp.XC_LegalEntity__c);

		System.debug('valueMap' + valueMap);
		
		return JSON.serialize(valueMap);
	}	 
}