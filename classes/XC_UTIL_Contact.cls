/**
* @author Giulio Serra giserra@deloitte.it
* @date Creation 06/11/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Contact utility for contacts
*/
public without sharing class XC_UTIL_Contact {
    
    /**
    *@description ResultWrapper
    **/
    public class ResultWrapper {
        public String ContactID = '';
        public String LastName = '';
        public String FirstName = '';
        public String Salutation = '';
        public String Email = ''; 
        public String MobilePhone = '';
        public String Phone = '';
        public String IdentityType = '';
        public String IdentityNumber = '';
        public Date Birthdate = null;
        public String GiveDataToEndesa = '';
        public String GiveDataToEndesaAndThirdParties = '';
        public String KeepMeUpToDateAboutProducts = '';
        
		public String PrimaryEmail;
        public String PreferenceLanguage;
        public String RobinsonContact;
        public String ConsentLegalEntity;
        public String ConsentCampaign;
        public String ConsentGroup;
        
    }
	
     /**
	* @author Giulio Serra giserra@deloitte.it
	* @description get all the primary contact from a list of contacts
    * @param contacts
    * @return primaryContacts
	*/
    public static List<Contact> getPrimaryContacts(List<Contact> contacts){
        List<Contact> primaryContacts = new List<Contact>();
        for(Contact contact : contacts){
            if(contact.XC_PrimaryContact__c) {
                primaryContacts.add(contact);
            }
        }

        return primaryContacts;
    } 

    /**
	* @author Giulio Serra giserra@deloitte.it
	* @description 
    * @param accountid
    * @param contacts
    * @return childContact
	**/
    public static List<Contact> getContactsFromaAccountId(String accountid,List<Contact> contacts){

        List<Contact> childContact = new List<Contact>();

        for(Contact contact : contacts){
            if(contact.Accountid == accountid) {
                childContact.add(contact);
            }
        }

        return childContact;
    }

    /**
    * @author Monica Cutillo - monica.cutillo@nttdata.com
    * @description from a Set of Individual Ids, retrive the associated Contacts 
    * @param individualIds
    * @return a Map with key the Individual Id and value the associated Contact
    **/
    public static Map<Id,Contact> getContactsFromaIndividuals(Set<Id> individualIds){
        Map<Id,Contact> result = new Map<Id,Contact>();
        List<Contact> contacts = new List<Contact>();
        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.AccountId.isAccessible() && Schema.sObjectType.Contact.fields.IndividualId.isAccessible()){
            contacts = [ SELECT Id, AccountId, IndividualId FROM Contact WHERE IndividualId IN: individualIds ];
        }
        for(Contact contact : contacts){
            result.put(contact.IndividualId, contact);
        }
        return result;
    }
    /**
    * @author Andrea Di Cicco
    * @description retrieve the contact legal entities based on the user legal entities 
    * @param individualIds
    * @return a Map with key the Individual Id and value the associated Contact
    **/
    public static List<Map<String, String>> getContactLegalEntities(String contactId){
        Contact contactIndividual = new Contact();
        List<XC_LegalEntityConsent__c> contactLegalEntities = new List<XC_LegalEntityConsent__c>();
        String userId = UserInfo.getUserId();
        User sessionUser = new User();
        List<String> userLegalEntities = new List<String>();
        Map<String, String> legalEntitiesLabels =  getLegalEntitiesLabels();
        List<Map<String,String>> picklistLegalEntity = new  List<Map<String,String>>();
        if(Schema.sObjectType.Individual.isAccessible()){
            contactIndividual = [SELECT IndividualId FROM Contact WHERE id = : ContactId LIMIT 1];
        }
        if(contactIndividual != null && Schema.sObjectType.XC_LegalEntityConsent__c.isAccessible() ){
            contactLegalEntities = [SELECT XC_LegalEntity__c FROM XC_LegalEntityConsent__c WHERE XC_Individual__c  =: contactIndividual.IndividualId];
        }
        if( Schema.sObjectType.User.isAccessible()){
            sessionUser = [SELECT XC_LegalEntities__c FROM User WHERE Id =: userId ];
        }

        if(contactLegalEntities.isEmpty() || sessionUser.XC_LegalEntities__c == null ){
            return picklistLegalEntity;
        }
        userLegalEntities = sessionUser.XC_LegalEntities__c.split(';');

        for(XC_LegalEntityConsent__c leConsents : contactLegalEntities){
            if(userLegalEntities.contains(leConsents.XC_LegalEntity__c)){
                Map<String,String> row = new Map<String,String>();
                row.put('key', leConsents.XC_LegalEntity__c);
                row.put('value', legalEntitiesLabels.get(leConsents.XC_LegalEntity__c));
                picklistLegalEntity.add(row);
            }
        }
        return picklistLegalEntity;
    }

    public static Map<String, String> getLegalEntitiesLabels(){
        Schema.DescribeFieldResult languages = XC_LegalEntityConsent__c.XC_LegalEntity__c.getDescribe();
        List<Map<String,String>> results = new List<Map<String,String>>();
        List<Schema.PicklistEntry> languagesValues = languages.getPicklistValues();
        Map <String, String> picklistMap = new Map <String, String> ();
        for(Schema.PicklistEntry pe: languagesValues){
            picklistMap.put(pe.getvalue(), pe.getlabel());
        }
        return picklistMap;
    }
}