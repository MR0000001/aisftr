/**
 * The Class XC_TR_Lead_U_CustomInteractionGeneration.
 *
 * @author Giulio Serra giserra@deloitte.it & Martina Barone - marbarone@deloitte.it
 * @date Creation 21/08/2018
 * @date Modification 11/01/2019 - Riccardo Cossu - riccardo.cossu@nttdata.com (pmd)
 * @date Modification 10/05/2019 - Monica Cutillo - monica.cutillo@nttdata.com
 * @date Modification 26/06/2019 - Nicola Mariniello - nmariniello@deloitte.it
 * @description XC_TR_Lead_U_CustomInteractionGeneration manage the creation of the costumer interaction from the lead
 */


public class XC_TR_Lead_U_CustomInteractionGeneration { 
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_CustomerInteractionGeneration');
	
	/**
	 * @description Handle lead creation.
	 * @param newLead the new lead
	 */
	public static void handleLeadCreation(List<Lead> newLead){
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_TR_Lead_U_CustomInteractionGeneration - CALL handleLeadCreation');
		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
		Map<String,Object> interactionMap;
		for(Lead ld : newLead){
			if(String.isblank(ld.XC_CampaignCode__c) && String.isblank(ld.XC_CampaignPlatform__c) && (String.isblank(ld.XC_CampaignProduct__c) || String.isNotBlank(ld.XC_AvailableSurface__c))){
				XC_UTIL_Debug.debug(DEBUGACTIVE, '@XC_CommercialVisitRequired__c@'+ld.XC_CommercialVisitRequired__c);
				interactionMap = createCustomerInteraction(ld);
				if(interactionMap != null) {
					interactions.add(interactionMap);
				}
			}
		}
		if(!interactions.isEmpty()){
			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromLead(interactions);
			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'newEmailForCustomerFromLead globalDMLResult = '+globalDMLResult);
		}
	}
	
	/**
	 * Creates the customer interaction map.
	 *
	 * @author Giulio Serra giserra@deloitte.it & Martina Barone - marbarone@deloitte.it
	 * @param l the l
	 * @return the interaction map
	 * @date Creation 21/08/2018
	 * @date Modification 26/06/2019 Nicola Mariniello nmariniello@deloitte.it - 24/09/2019 Giuseppe Di Bonito gdibonito@deloitte.it
	 * @description create a map with the informations needed to create a customer interaction
	 */
    @TestVisible
    private static Map<String,Object> createCustomerInteraction(Lead l){
    	Map<String,Object> leadInfo = new Map<String,Object>();
    	leadInfo.put('customerType', 'Lead_Welcome_Email');
    	leadInfo.put('fullName', l.FirstName + ' ' + l.LastName);
    	leadInfo.put('leadId', l.Id);
		leadInfo.put('preferredlanguage', l.XC_Preference_Language__c);
    	leadInfo.put('skipComunication', false);
    	leadInfo.put('sent', false);
		leadInfo.put('legalEntity', l.XC_MainLegalEntity__c);
		//Ottaviano Survey - Management
		//leadInfo.put('SurveyId','test01'); 

		if (l.XC_Channel__c != 'Web'){
			System.debug('Receiving Channel not equal to \'Web\'. Customer interaction not created.');
			return null;
		} else if(String.isNotBlank(l.Email)) {
			leadInfo.put('email', l.Email);
		} else if(checkPrimaryPhone(l)) {
			leadInfo.put('phone', l.Phone);
		} else if(checkSecondaryPhone(l)) { 
			leadInfo.put('phone', l.MobilePhone);
		} else {
			System.debug('IN createCustomerInteraction the lead with ID ' + l.Id + 'has not an email ad a valid phone');
			return null;
		}

    	XC_UTIL_Debug.debug(DEBUGACTIVE, 'Lead map values' + leadInfo);
		return leadInfo;
    }


	/**
	 * CheckPrimaryPhone.
	 *
	 * @author Nicola Mariniello - nmariniello@deloitte.it
	 * @date Creation 26/06/2019
	 * @param l the lead
	 * @return the result oh check
	 * @description check the format of Primary Phone
	 */
    @TestVisible
    private static Boolean checkPrimaryPhone(Lead l) {
		if(String.isNotBlank(l.Phone) && (l.XC_PhonePrefix__c != '+34' || (l.XC_PhonePrefix__c == '+34' && (String.valueOf(l.XC_LeadPhone__c).substring(0,1) == '6' || String.valueOf(l.XC_LeadPhone__c).substring(0,1) == '7')))) {
			return true;
		} else {
			return false;
		}
	}


	/**
	 * CheckSecondaryPhone.
	 *
	 * @author Nicola Mariniello - nmariniello@deloitte.it
	 * @date Creation 26/06/2019
	 * @param l the lead
	 * @return the result of check
	 * @description check the format of Secondary Phone
	 */
    @TestVisible
    private static Boolean checkSecondaryPhone(Lead l) {
		if(String.isNotBlank(l.MobilePhone) && (l.XC_MobilePrefix__c != '+34' || (l.XC_MobilePrefix__c == '+34' && (String.valueOf(l.XC_LeadMobile__c).substring(0,1) == '6' || String.valueOf(l.XC_LeadMobile__c).substring(0,1) == '7')))) {
			return true;
		} else {
			return false;
		}
	}

	/*
	 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
	 * @param listNew
	 * @date Creation 20/11/2019
	 * @description creates the customer interaction 'Sales_Call_Survey' when the lead is updated to 'Customer Contacted'
	 */
	public static void createCustomerInteractionSalesCallSurvey(List<Lead> listNew, Map<Id,Lead> mapOldS, Map<Id,Lead> mapNewS){
		XC_UTIL_Debug.debug(DEBUGACTIVE, 'entrato in createCustomerInteractionSalesCallSurvey for Lead');
        List<String> fieldList = new List<String>{'Status'};
        List<Lead> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOldS, mapNewS);
        if(listChanged.isEmpty()){
            return;
        }
		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
		for(Lead ld : listChanged){
			if(ld.Status == 'Customer Contacted'){
				Map<String,Object> leadInfo = new Map<String,Object>();
				leadInfo.put('customerType', 'Sales_Call_Survey');
				leadInfo.put('SurveyId', 'S10');
				leadInfo.put('fullName', ld.FirstName + ' ' + ld.LastName);
				leadInfo.put('leadId', ld.Id);
				leadInfo.put('skipComunication', false);
				leadInfo.put('sent', false);
				leadInfo.put('legalEntity', ld.XC_MainLegalEntity__c);
				leadInfo.put('email', ld.Email);
				if(leadInfo != null) {
					interactions.add(leadInfo);	
				}
			}
		}		
		if(!interactions.isEmpty()){
			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromLead(interactions);
			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'newEmailForCustomerFromLead globalDMLResult = '+globalDMLResult);
		}
    }
}