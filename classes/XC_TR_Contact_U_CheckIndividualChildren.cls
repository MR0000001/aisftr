/**
* @author Giulio Serra giserra@deloitte.it, Federico Amici 
* @date Creation 26/09/2018
* @date Modification dd/mm/yyyy
* @description  XC_TR_Contact_U_CheckIndividualChildren – utility class for the handler
*/

public without sharing class XC_TR_Contact_U_CheckIndividualChildren {
     private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Contact_U_CheckIndividualChildren');
	
    /**
     * @description Check children.
     * @param listContact
     */ 
    public static void checkChildren(List<Contact> listContact){
        
        Map<ID,Contact> mapIndividual = getSetIndividualID(listContact);
        Set<ID> individualId = mapIndividual.keySet();

    		Map<Id,Individual> mapMyIndividual = XC_TR_Contact_U_CheckIndChildren_D.getMapIDToIndividual(individualId);

    		System.debug(mapIndividual);

       	for(Individual i : mapMyIndividual.values()){ 
       		if(i.contacts.size() > 0){
       			mapIndividual.get(i.ID).addError(Label.XC_CL_Contact_DuplicateIndividual);
       		}
       	}

    }

    /** 
    * @author Monica Cutillo monica.cutillo@nttdata.com
    * @date Creation 09/07/2019
    * @description Method to check available LegalEntity for Secondary Contact
    * @param listContact 
    */
    public static void checkAvailableLegalEntityOnSecContact(List<Contact> listContact){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ START checkAvailableLegalEntityOnSecContact on Contact TR');
        List<Id> contIds = XC_UTIL_Sobject.getIds(listContact);
        Map<Id,Contact> secContacts = new Map<Id,Contact>([ SELECT Id,AccountId, XC_MainLegalEntity__c, IndividualId, XC_PrimaryContact__c FROM Contact
                                                             WHERE XC_PrimaryContact__c = false AND Id IN: contIds ]);

        List<String> accId = XC_UTIL_Sobject.getListFieldValues(secContacts.values(), 'AccountId');
        //cerco tutti i primary contact
        Map<Id,Account> accMap =  new Map<Id,Account>([SELECT Id, (SELECT Id, AccountId, XC_PrimaryContact__c,IndividualId FROM Contacts 
                                                                    WHERE XC_PrimaryContact__c = true LIMIT 1) 
                                                       FROM Account WHERE Id IN: accId]);
    
        List<Contact> primaryContacts = new List<Contact>();
        for(Account acc : accMap.values()){
            if(!acc.Contacts.isEmpty()){
                primaryContacts.addAll(acc.Contacts);
            }
        }
        Map<Id,List<String>> primaryLegalListNames = XC_UTIL_LegalEntityConsents.checkAllConsentsOfPrimary(primaryContacts);
        for(Contact cont : listContact){
            //SKIP if the contact is the primary contact on its account or the segment is B2B OR B2G
            if(!(secContacts.keySet()).contains(cont.Id) || cont.XC_Segment__c == 'B2B' || cont.XC_Segment__c == 'B2G'){
                continue;
            }
            List<String> primaryLE = primaryLegalListNames.get(cont.AccountId);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ primaryLE = '+primaryLE);
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ cont.XC_MainLegalEntity__c = '+cont.XC_MainLegalEntity__c);
            if(primaryLE != null && !primaryLE.isEmpty()){
                if(!primaryLE.contains(cont.XC_MainLegalEntity__c)){
                    cont.addError(Label.XC_CL_LENotAvailable); 
                }
            }
        }

    }

    /**
     * @description  Gets the sets the individual ID.
     * @param contacts the contacts
     * @return the sets the individual ID
     */
    private static Map<ID,Contact> getSetIndividualID(list<Contact> contacts){
    	Map<ID,Contact> mapOfIndividuals = new Map<ID,Contact>();

    	for(Contact c: contacts){
    		mapOfIndividuals.put(c.individualID,c);
    	}

    	return mapOfIndividuals;
    }
}