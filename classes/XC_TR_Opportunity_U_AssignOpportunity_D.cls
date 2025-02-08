/**
* @author Nicolò Leonardi - nleonardi@deloitte.it & Marco Rosa - marco.rosa@nttdata.com
* @date Creation 27/09/2018 
* @date Modification dd/mm/yyyy
* @description XC_TR_Opportunity_U_AssignOpportunity_D – DAO Class for XC_TR_Opportunity_U_AssignOpportunity
*/

public without sharing class XC_TR_Opportunity_U_AssignOpportunity_D { 

	/**
	 * @description Retrieve product categories from names.
	 * @param listProdCatNames the list prod cat names
	 * @return the list
	 */
	public static List<XC_ProductCategoryOfInterest__c> retrieveProductCategoriesFromNames(List<String> listProdCatNames){
		List<XC_ProductCategoryOfInterest__c> listProdCat = new List<XC_ProductCategoryOfInterest__c>();
		if(Schema.sObjectType.XC_ProductCategoryOfInterest__c.isAccessible() && Schema.sObjectType.XC_ProductCategoryOfInterest__c.fields.Id.isAccessible() && Schema.sObjectType.XC_ProductCategoryOfInterest__c.fields.Name.isAccessible() && Schema.sObjectType.XC_ProductCategoryOfInterest__c.fields.XC_CommercialVisit__c.isAccessible()){
			listProdCat = [SELECT ID, Name, XC_CommercialVisit__c 
																						FROM XC_ProductCategoryOfInterest__c
																						WHERE Name IN: listProdCatNames];
		}
		return listProdCat;            					
	}


	/**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
     * @description Given a Map of opportunityId->UserId
    **/
	/*public static Map<Id, Id> getUserIdByOpportunityId(List<Opportunity> listOpportunity) {
		Map<Id,Id> newMapOppContact = new Map<Id,Id>();
		Map<Id,Id> newMapOppUser = new Map<Id,Id>();
		Map<Id,Id> newMapContactUser = new Map<Id,Id>();
		List<Id> listIdOpportunity = new List<Id>();
		List<Id> listAccountPartner = new List<Id>();
		List<Id> contactPrimary = new List<Id>();

	
		//Get all account partner ids related to the opportunity
		List<Opportunity> opportunityList = [SELECT id, Account.XC_PreferredPartner__r.XC_ESP_Account_PrimaryContact__c FROM Opportunity where id IN :listOpportunity ];
	    
	    for(Opportunity opp : opportunityList){
	    	newMapOppContact.put(opp.id, opp.Account.XC_PreferredPartner__r.XC_ESP_Account_PrimaryContact__c);
	    	if(opp.Account.XC_PreferredPartner__r.XC_ESP_Account_PrimaryContact__c!=null){
	    	contactPrimary.add(opp.Account.XC_PreferredPartner__r.XC_ESP_Account_PrimaryContact__c);
	    	}
	    	System.debug('contactPrimary=' +contactPrimary);
	    }

			List<User> userList = [SELECT id, ContactId from User where ContactId IN :contactPrimary];

			for(User u : userList){
					newMapContactUser.put(u.ContactId, u.id);	
			}
			System.debug('MapContact-->User:' +newMapContactUser);
		  for(Opportunity opp : opportunityList){
		  	id contactId = newMapOppContact.get(opp.id);
		  	id userId = newMapContactUser.get(contactId);
		  	if(userId!=null){
		  	newMapOppUser.put(opp.id, userId);
		    }
			}
		System.debug('Map Opp->User'+newMapOppUser);
		return newMapOppUser;
	}*/

	
}