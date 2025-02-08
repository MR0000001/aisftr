/**
* @author Nicola Mariniello - nmariniello@deloitte.it , Luisana Rocco - lrocco@deloitte.it
* @date Creation 16/10/2018
* @date Modification 08/11/2018
* @description Check on insert/update of Primary Contact 
*/


public without sharing class XC_TR_Contact_U_CheckPrimaryContact {
 
 	/**
	 * On contact insert.
	 * @description check primary contact on insert
	 * @param listCon the list con
	 */
	public static void onContactInsert(List<Contact> listCon){
		CheckPrimaryContact(listCon);
	}

	/**
	 * On contact update.
	 * @description check if the field has changed
	 * @param listCon the list con
	 * @param mapOld the map old
	 * @param mapNew the map new
	 */
	public static void onContactUpdate(List<Contact> listCon, Map<Id,Contact> mapOld, Map<Id,Contact> mapNew){
		List<String> fieldList = new List<String>{'XC_PrimaryContact__c'};
		List<NE__AssetItemAttribute__c> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()) {
            CheckPrimaryContact(listCon);
		}
	}


	/**
	 * Map account id contact id.
	 * @description retrieve a map Id-->List<Contact>
	 * @param setAccount the set account
	 * @return the map
	 */
	@TestVisible
	private static Map<Id, List<Contact>> mapAccountIdContactId( Set<Id> setAccount ) {

		Map<Id,list<Contact>> mapAccountPrimaryC = new Map<Id,list<Contact>>();
		for (Account a : [SELECT Id, (SELECT Id,Name FROM Contacts WHERE XC_PrimaryContact__c = true) FROM Account WHERE Id IN :setAccount ]){
            mapAccountPrimaryC.put(a.Id, a.Contacts);
        }
		return mapAccountPrimaryC;
	}

	
	/**
	 * Check primary contact.
	 * @description check if it is a primary contact
	 * @param listCon the list con
	 */
	private static void checkPrimaryContact (list<Contact> listCon){
		// Check if the primary contact already exists

		Set<Id> accSet = new Set<Id> ();
		Map<Id,list<Contact>> mapAccountIdContact = new Map<Id,list<Contact>>();
		for (Contact c : listCon){

			if (c.XC_PrimaryContact__c){ 
				Id idAccount = c.AccountId;
				if (idAccount != null) {
					accSet.add(idAccount);
				}
			}
		}

		if (accSet.size() > 0) {
			mapAccountIdContact = mapAccountIdContactId(accSet);
		}

		addErrorOnContact(mapAccountIdContact, listCon);
	}

	/**
	 * @description add error on contact
	 * @param mapAccountIdContact
	 * @param listCon the list con
	 */
	private static void addErrorOnContact (Map<Id,list<Contact>> mapAccountIdContact, list<Contact> listCon){
		if(mapAccountIdContact.keySet().size() > 0){ 
			for (Contact c : listCon){
				if(mapAccountIdContact.containsKey(c.AccountId) && 
					mapAccountIdContact.get(c.AccountId).size()> 0 && 
					c.Id != null && 
					mapAccountIdContact.get(c.AccountId).get(0).Id == c.Id) {
						mapAccountIdContact.get(c.AccountId).remove(0);
				}
				if(c.AccountId != null && 
					mapAccountIdContact.containsKey(c.AccountId) &&
					mapAccountIdContact.get(c.AccountId).size()> 0) {
						c.addError(Label.XC_CL_PrimaryContactAlreadyExist);
				}
			}
		}
	}



	/** 
    * @description method to mangage contact fields
    * @param conList the list of contact
    */
	public static void manageContactFields(List<Contact> conList){

		Set<Id> accountIds = new Set<Id>();
		for(Contact c : conList){
			if(!String.isBlank(c.AccountId)){
				accountIds.add(c.AccountId);
			}
		}
		
		Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id, XC_isGuestUser__c,XC_Segment__c FROM Account WHERE Id IN :accountIds]);
		
		for(Contact c : conList){
			if(!String.isBlank(c.AccountId) && accMap.get(c.AccountId)!= null){
				c.XC_isGuestContact__c = (accMap.get(c.AccountId).XC_isGuestUser__c) ? 'Yes' : 'No';
				c.XC_Segment__c= (String.isNotBlank(accMap.get(c.AccountId).XC_Segment__c)) ? accMap.get(c.AccountId).XC_Segment__c : '';
			}
			
		}

	}


	/**
	* @description called in after insert, updates CTI Interaction record if present, with currentContactId and AccountId if it is a primary contact
	* @author Francesco Imperioli - fimperioli@deloitte.it | 11/5/2020 
	* @param conList 
	* @return void 
	**/
	public static void manageCreationFromCTIChannel(List<Contact> conList){

		List<Contact> consToCheck = new List<Contact>();
		for(Contact c : conList){
			if(c.XC_PrimaryContact__c && String.isNotBlank(c.AccountId)){
				consToCheck.add(c);
			}
		}

		if(!consToCheck.isEmpty()){
			List<XC_CTI_Interaction__c> interactionsToUpdate = new List<XC_CTI_Interaction__c>();

			List<XC_CTI_Interaction__c> currentCalls = [SELECT ID,CreatedById,XC_ContactId__c,XC_AccountId__c,XC_HasMultipleMatch__c FROM XC_CTI_Interaction__c 
			WHERE XC_InteractionStatus__c = 'Open' AND CreatedById = :UserInfo.getUserId() AND CreatedDate = TODAY ORDER BY CreatedDate DESC];

			Map<String,XC_CTI_Interaction__c> interactionCreatorMap = new Map<String,XC_CTI_Interaction__c>();
			for(XC_CTI_Interaction__c ci : currentCalls){
				interactionCreatorMap.put(ci.CreatedById,ci);
			}

			for(Contact c : consToCheck){
				if(interactionCreatorMap.containsKey(c.CreatedById)){
					XC_CTI_Interaction__c parentCall = interactionCreatorMap.get(c.CreatedById);
					parentCall.XC_ContactId__c = c.Id;
					parentCall.XC_AccountId__c = c.AccountId;
					parentCall.XC_HasMultipleMatch__c = false;
					interactionsToUpdate.add(parentCall);
				}
			}

			if(!interactionsToUpdate.isEmpty()){
				XC_UTIL_Sobject.updateListRecords(interactionsToUpdate);
			}

		}

	}

}