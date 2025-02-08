/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 29/04/2019
* @description XC_DF_Contact – Data Factory for Contact
*/
@isTest
public class XC_DF_Contact { 
    
      /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N Residential contact
     * @param  accList
     * @return  List<Contact>
    */
    public static List<Contact> createResidentialContacts(List<Account> accList){
        List<Contact> listContacts = new List<Contact>();
        Integer i = 0;
        for (Account acc : accList){
            Contact contactToInsert = new Contact();
            contactToInsert.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Residential').getRecordTypeId();
            contactToInsert.FirstName = 'Test contact' +  Math.random();
            contactToInsert.LastName = 'Test contact' +  Math.random();
            contactToInsert.Email = 'test_soho' + Math.random() + '@email.com';  
            contactToInsert.AccountId = acc.Id;
            contactToInsert.XC_CountryLegalEntity__c = 'SPAIN';
            contactToInsert.XC_SkipTriggerIndividual__c = true; 
            contactToInsert.XC_MainLegalEntity__c = 'EndesaX';
            contactToInsert.XC_GiveDataToNew__c = 'Yes';
            listContacts.add(contactToInsert);
            i++;
        }
        system.debug('#############listContacts '+listContacts);
        return listContacts;
    }
      /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N Residential contacts
     * @param n
     * @return  List<Contact> to insert
    */
    public static List<Contact> createResidentialContacts(Integer n){
        List<Account> accList =  XC_DF_Account.createResidentialAccounts(n);
        insert accList;
        return createResidentialContacts(accList);
    }
     
     /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com
     * @description Method to create N Condominium Contact
     * @param accList
     * @return  List<Contact> to insert
    */
    public static List<Contact> createCondominiumContacts(List<Account> accList){
        List<Contact> listContacts = new List<Contact>();
        for (Account acc : accList){
            Contact contactToInsert = new Contact();
            contactToInsert.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Condominium').getRecordTypeId();
            contactToInsert.FirstName = 'Test contact';
            contactToInsert.LastName = 'Test contact'; 
            contactToInsert.Email = 'test_condominium@email.com';  
            contactToInsert.AccountId = acc.Id;
            contactToInsert.XC_CountryLegalEntity__c = 'SPAIN';
            contactToInsert.XC_SkipTriggerIndividual__c = true; 
            contactToInsert.XC_MainLegalEntity__c = 'EndesaX';
            contactToInsert.XC_GiveDataToNew__c = 'Yes';
            listContacts.add(contactToInsert);
        }
        return listContacts;
    }
    
    /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N Condominium contacts
     * @param n
     * @return  List<Contact> to insert
    */
    public static List<Contact> createCondominiumContacts(Integer n){
        List<Account> accList =  XC_DF_Account.createCondominiumAccounts(n);
        insert accList;
        return createCondominiumContacts(accList);
    }
    
     /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N Soho contacts
     * @param accList
     * @return  List<Contact> to insert
    */
    public static List<Contact> createSohoContacts(List<Account> accList){
        List<Contact> listContacts = new List<Contact>();
        for (Account acc : accList){
            Contact contactToInsert = new Contact();
            contactToInsert.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_GLO_Contact_Soho').getRecordTypeId();
            contactToInsert.FirstName = 'Test contact';
            contactToInsert.LastName = 'Test contact';
            contactToInsert.Email = 'test_soho@email.com';  
            contactToInsert.AccountId = acc.Id;
            contactToInsert.XC_CountryLegalEntity__c = 'SPAIN';
            contactToInsert.XC_SkipTriggerIndividual__c = true; 
            contactToInsert.XC_MainLegalEntity__c = 'EndesaX';
            contactToInsert.XC_GiveDataToNew__c = 'Yes';
            listContacts.add(contactToInsert);
        }
        return listContacts;
    }
    
     /** 
     * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com 
     * @description Method to create N partner contacts
     * @param accList
     * @return  List<Contact> to insert
    */
    public static List<Contact> createPartnerContacts(List<Account> accList){
        List<Contact> listContacts = new List<Contact>();
        for (Account acc : accList){
            Contact contactToInsert = new Contact();
            contactToInsert.RecordTypeID = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('XC_Contact_Partner').getRecordTypeId();
            contactToInsert.FirstName = 'Test contact';
            contactToInsert.LastName = 'Test contact';
            contactToInsert.Email = 'test_partner@email.com';  
            contactToInsert.AccountId = acc.Id;
            contactToInsert.XC_CountryLegalEntity__c = 'SPAIN';
            contactToInsert.XC_SkipTriggerIndividual__c = true; 
            contactToInsert.XC_MainLegalEntity__c = 'EndesaX';
            contactToInsert.XC_GiveDataToNew__c = 'Yes';
            listContacts.add(contactToInsert);
        }
        return listContacts;
    }
     /** 
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to create N Soho contacts
     * @param n
     * @return  List<Contact> to insert
    */
    public static List<Contact> createSohoContacts(Integer n){
        List<Account> accList =  XC_DF_Account.createSohoAccounts(n);
        insert accList;
        return createSohoContacts(accList);
    }
}