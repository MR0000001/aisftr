/**
* @author Giuseppe Di Bonito - gdibonito@deloitte.it
* @date Creation 22/11/2019
* @date Modification 
* @description Util for XC_TR_DocumentToSign_Handler
*/

public without sharing class XC_TR_DocumentToSign_U_Notifications { 

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DocumentToSign_U_Notifications');

	/*
	 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
	 * @param listNew
	 * @date Creation 22/11/2019
	 * @description creates the customer interaction 'Order_Send_Signed_contract_Email' when the XC_Document_to_sign__c field XC_Signed__c is updated to 'true'
	 */
	public static void createCustomerInteractionDocSigned(List<XC_Document_to_sign__c> listNew, Map<Id,XC_Document_to_sign__c> mapOldS, Map<Id,XC_Document_to_sign__c> mapNewS){
		System.debug('entrato in createCustomerInteractionDocSigned for DocumentToSign');
        List<String> fieldList = new List<String>{'XC_Signed__c'};
        List<XC_Document_to_sign__c> listChanged = XC_UTIL_SObject.getListChanged(fieldList, mapOldS, mapNewS);
        if(listChanged.isEmpty()){
            return;
        } 
		List<Id> listId = XC_UTIL_Sobject.getIds(listChanged);
		for(XC_Document_to_sign__c dts : listChanged){
			if(dts.XC_Signed__c == true && String.isNotBlank(dts.XC_Doxee_ID_external__c)){
				listId.add(dts.Id);
			}
		}
			
		Map<Id, XC_Document_to_sign__c> docMap = new Map<Id, XC_Document_to_sign__c>(
			[SELECT
				Id, XC_Doxee_ID_external__c, XC_Doxee_URL__c, XC_ConfigurationID__c, XC_Case__c,  XC_Opportunity__c, XC_WorkOrder__c,
				//from Configuration
				XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__c, XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.AccountId, 
				XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.Name, XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.Email, 
				XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.XC_MainLegalEntity__c
				
				/*Maybe one day
				//from Case
				XC_Case__r.XC_Opportunity__r.XC_Contact__c, XC_Case__r.XC_Order__c, 
				XC_Case__r.XC_Opportunity__r.XC_Contact__r.AccountId, XC_Case__r.XC_Opportunity__r.XC_Contact__r.Name, 
				XC_Case__r.XC_Opportunity__r.XC_Contact__r.Email, XC_Case__r.XC_Opportunity__r.XC_Contact__r.XC_MainLegalEntity__c,
				//from Opportunity
				XC_Opportunity__r.XC_Contact__c, XC_Opportunity__r.XC_WorkOrder__r.XC_Configuration__c,
				XC_Opportunity__r.XC_Contact__r.AccountId, XC_Opportunity__r.XC_Contact__r.Name,
				XC_Opportunity__r.XC_Contact__r.Email, XC_Opportunity__r.XC_Contact__r.XC_MainLegalEntity__c,
				//from WorkOrder
				XC_WorkOrder__r.XC_Configuration__r.NE__OpportunityId__c.XC_Contact__c, XC_WorkOrder__r.XC_Configuration__c, 
				XC_WorkOrder__r.XC_Configuration__r.NE__OpportunityId__c.XC_Contact__r.AccountId, XC_WorkOrder__r.XC_Configuration__r.NE__OpportunityId__c.XC_Contact__r.Name,
				XC_WorkOrder__r.XC_Configuration__r.NE__OpportunityId__c.XC_Contact__r.Email, XC_WorkOrder__r.XC_Configuration__r.NE__OpportunityId__c.XC_Contact__r.XC_MainLegalEntity__c*/
			
			FROM XC_Document_to_sign__c 
			WHERE Id IN :listId]);
		System.debug('docMap: ' + docMap);
        if(docMap.isEmpty()){
            return;
        }
		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
		for(XC_Document_to_sign__c dts : docMap.values()){
			Map<String,Object> dtsInfo = new Map<String,Object>();
			dtsInfo.put('customerType', 'Order_Send_Signed_contract_Email');
			dtsInfo.put('docURL', dts.XC_Doxee_URL__c);
			dtsInfo.put('docID', dts.XC_Doxee_ID_external__c);
			//Order only
			dtsInfo.put('orderId', dts.XC_ConfigurationID__c);
			dtsInfo.put('accountId', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.AccountId);
			dtsInfo.put('fullName', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.Name);
			dtsInfo.put('contactId', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__c);
			dtsInfo.put('skipComunication', false);
			dtsInfo.put('sent', false);
			dtsInfo.put('legalEntity', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.XC_MainLegalEntity__c);
			dtsInfo.put('email', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.Email);
		
			if(dtsInfo != null && dtsInfo.get('legalEntity') != 'EnelXItalia' && dtsInfo.get('legalEntity') != 'EnelXMSP') {
				interactions.add(dtsInfo);	
			}
		}
		System.debug('interactions: ' + interactions);	
		if(!interactions.isEmpty()){
			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(interactions);
			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'newEmailForCustomerFromOrders globalDMLResult = ' + globalDMLResult);
		}
    }

	/*
	 * @author Giuseppe Di Bonito - gdibonito@deloitte.it
	 * @param listNew
	 * @date Creation 24/12/2019
	 * @description creates the customer interaction 'Contract_Remote_Sign' when a XC_Document_to_sign__c object is created with certain conditions
	 */
	public static void createCustomerInteractionRemoteSign(List<XC_Document_to_sign__c> listNew){
		System.debug('entrato in createCustomerInteractionRemoteSign for DocumentToSign');
		//List<XC_CM_CountryLegalEntityAssociation__mdt> listLegalEntityB2B = [select  XC_LegalEntity__c from XC_CM_CountryLegalEntityAssociation__mdt WHERE XC_Category__c = 'B2B'];

		List<String> docId = new List<String>();
		for(XC_Document_to_sign__c doc : listNew){
			if(doc.XC_Signed__c == false){
				docId.add(doc.Id);
			}
		}
		System.debug('docId: ' + docId);
		if(docId.isEmpty()){
            return;
		}

		Map<Id, XC_Document_to_sign__c> docMap = new Map<Id, XC_Document_to_sign__c>(
			[SELECT
			Id, XC_Doxee_URL__c, XC_ConfigurationID__c, CreatedById, XC_Doxee_ID_external__c,
			XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__c, XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.AccountId, 
			XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.Name, XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.Email, 
			XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.XC_MainLegalEntity__c, XC_ConfigurationID__r.XC_Segment__c
			FROM XC_Document_to_sign__c 
			WHERE Id IN :docId]);
		System.debug('docMap: ' + docMap);

		List<String> accId = new List<String>();
		List<String> conId = new List<String>();
		List<String> userId = new List<String>();
		for(XC_Document_to_sign__c doc : docMap.values()){
			accId.add(doc.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.AccountId);
			conId.add(doc.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__c);
			userId.add(doc.CreatedById);
		}
		System.debug('accId: ' + accId);
		System.debug('conId: ' + conId);
		System.debug('userId: ' + userId);

		Map<Id, XC_CTI_Interaction__c> ctiMap = new Map<Id, XC_CTI_Interaction__c>(
			[SELECT	Id, XC_InteractionStatus__c, XC_Communication_Type__c, XC_AccountId__c, XC_ContactId__c
			FROM XC_CTI_Interaction__c 
			WHERE XC_AccountId__c IN :accId OR XC_ContactId__c IN :conId]);
		System.debug('ctiMap: ' + ctiMap);

		Map<Id, User> userMap = new Map<Id, User>(
			[SELECT	Id, XC_Receiving_Channel__c
			FROM User  
			WHERE Id IN :userId]);
		System.debug('userMap: ' + userMap);	
 
		List<Map<String,Object>> interactions = new List<Map<String,Object>>();
		for(XC_Document_to_sign__c dts : docMap.values()){
			//if(XC_UTIL_Sobject.getListFieldValues(listLegalEntityB2B, 'XC_LegalEntity__c').contains(dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.XC_MainLegalEntity__c)){
			if(dts.XC_ConfigurationID__r.XC_Segment__c == 'B2B' || dts.XC_ConfigurationID__r.XC_Segment__c == 'B2G'){
				continue;
			}
			System.debug('for');
            if(!ctiMap.values().isEmpty()){
                for(XC_CTI_Interaction__c cti : ctiMap.values()){
    
                    System.debug('1. ' + dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.AccountId);
                    System.debug('2. ' + dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__c);
                    System.debug('3. ' + cti.XC_InteractionStatus__c);
                    System.debug('4. ' + cti.XC_Communication_Type__c);
                    System.debug('5. ' + userMap.get(dts.CreatedById).XC_Receiving_Channel__c);
    
                    if((dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.AccountId == cti.XC_AccountId__c || 
                    	dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__c == cti.XC_ContactId__c) &&
                        cti.XC_InteractionStatus__c == 'Open' &&
                        cti.XC_Communication_Type__c == 'Inbound Call'){
							continue;			
					} 
                }
            } else if(userMap.get(dts.CreatedById).XC_Receiving_Channel__c == 'Technical Service'){
				System.debug('else if');
				continue;
			
			} else{
				System.debug('else');
				Map<String,Object> dtsInfo = new Map<String,Object>();
				dtsInfo.put('customerType', 'Contract_Remote_Sign');
				dtsInfo.put('docURL', dts.XC_Doxee_URL__c);
				dtsInfo.put('docID', dts.XC_Doxee_ID_external__c);
				dtsInfo.put('orderId', dts.XC_ConfigurationID__c);
				dtsInfo.put('accountId', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.AccountId);
				dtsInfo.put('fullName', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.Name);
				dtsInfo.put('contactId', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__c);
				dtsInfo.put('skipComunication', false);
				dtsInfo.put('sent', false);
				dtsInfo.put('legalEntity', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.XC_MainLegalEntity__c);
				dtsInfo.put('email', dts.XC_ConfigurationID__r.NE__OptyId__r.XC_Contact__r.Email);
				
				if(dtsInfo != null) {
					interactions.add(dtsInfo);
				}
			}
		}	
								
		System.debug('interactions: ' + interactions);	
		if(!interactions.isEmpty()){
			List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_CustomerInteractionGeneration.newEmailForCustomerFromOrders(interactions);
			XC_UTIL_Sobject.WrapperResult globalDMLResult= XC_UTIL_Sobject.getGlobalDMLResults(results);
			XC_UTIL_Debug.debug(DEBUGACTIVE, 'newEmailForCustomerFromOrders globalDMLResult = ' + globalDMLResult);
		}
	}
}