/**
* @author Giulio Serra
* @date Creation 26/09/2018
* @date Modification dd/mm/yyyy
* @description Update the information of the contacts from the individual
*/
public without sharing 
 /**
  * The Class XC_TR_Individual_UpdateContact.
  * @description Update the information of the contacts from the individual
  */
 class XC_TR_Individual_UpdateContact {
	
	/** The was called. */
	public static Boolean wasCalled = false;
    
    
    /**
     * Avoid recursion.
     *
     * @return the boolean
     * @description Update the information of the contacts from the individual
     */
    public static Boolean avoidRecursion() {

        if(!wasCalled){
            wasCalled = true;
            return false;
        }else{ 
            return wasCalled;
        }
    }
    
     /**
      * Update contacts from individual.
      *
      * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
      * @param individuals the individuals
      * @date Creation 04/07/19
      * @description update the information of the contacts fathers of the individuals
      */
     public static void updateContactsConsentsFromIndividualAfterInsert(List<Individual> individuals){ 
        
        List<Id> individualIds = XC_UTIL_Sobject.getIds(individuals);
        List<Contact> contactToUpdate = new List<Contact>();
        List<Individual> indList = new List<Individual>([SELECT id,
        XC_GiveDataToThirdParties__c,XC_ThirdPartyConsentVersion__c,XC_RobinsonCustomer__c, (SELECT Id,XC_PrimaryContact__c 
        FROM Contacts WHERE XC_PrimaryContact__c = true LIMIT 1) FROM Individual WHERE Id IN: individualIds]);
            System.debug('In updateContactsConsentsFromIndividualAfterInsert con '+indList);
            for(Individual ind : indList){
                if(!ind.Contacts.isEmpty()){
                    System.debug('In updateContactsConsentsFromIndividualAfterInsert con '+ind.Contacts);
                    Contact c = new Contact(id = ind.Contacts[0].id);
                    c.XC_GiveDataToThirdParties__c = ind.XC_GiveDataToThirdParties__c;
                    c.XC_ThirdPartiesConsentVersion__c = ind.XC_ThirdPartyConsentVersion__c;
                    c.XC_RobinsonCustomer__c = ind.XC_RobinsonCustomer__c;
                    contactToUpdate.add(c);
                }

            }
            XC_UTIL_Sobject.upsertListRecords(contactToUpdate);



     }
     /**
      * Update contacts from individual.
      *
      * @author Giulio Serra giserra@deloitte.it
      * @param individuals the individuals
      * @date Creation 20/02/19
      * @description update the information of the contacts fathers of the individuals
      */
    public static void updateContactsFromIndividual(List<Individual> individuals){
        
		if(wasCalled){
			return;
		}        
        
        Map<Id,Contact> contacts = XC_TR_Contact_U_HandleIndividual_D.getContactFromIndiduals(individuals);
        List<Contact> contToUpdate = new List<Contact>();
        for(Individual ind : individuals){
            Contact c = contacts.get(ind.XC_ChildContact__c);
            Boolean shouldUpdate = true;
            if(c != null){
                if(c.FirstName != ind.FirstName){
                    c.FirstName = ind.FirstName;
                    shouldUpdate = true;
                }
                if(c.LastName != ind.LastName){
                    c.LastName = ind.LastName;
                    shouldUpdate = true;
                }
              	
                 if(c.XC_GiveDataToThirdParties__c != ind.XC_GiveDataToThirdParties__c){
                   c.XC_GiveDataToThirdParties__c = ind.XC_GiveDataToThirdParties__c;
                   shouldUpdate = true;

                }
                if(c.XC_ThirdPartiesConsentVersion__c  != ind.XC_ThirdPartyConsentVersion__c){
                   c.XC_ThirdPartiesConsentVersion__c  = ind.XC_ThirdPartyConsentVersion__c;
                   shouldUpdate = true;

                }
                if(c.XC_RobinsonCustomer__c != ind.XC_RobinsonCustomer__c){
                   c.XC_RobinsonCustomer__c = ind.XC_RobinsonCustomer__c;
                   shouldUpdate = true;

                }
                
                if(shouldUpdate){
                    contToUpdate.add(c);
                }
                
            }
        }
        System.debug('@@@ cont to insert' + contToUpdate);
        List<XC_UTIL_SObject.WrapperResult> results = XC_UTIL_Sobject.updateListRecords(contToUpdate);
     	System.debug('@@@ indupdate esito' + results);
        
        wasCalled = avoidRecursion();
    }

}