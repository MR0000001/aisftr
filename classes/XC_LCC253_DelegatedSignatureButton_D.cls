/**
 * @description       : 
 * @author            : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * @group             : 
 * @last modified on  : 09-06-2021
 * @last modified by  : Eleni Tsiolaki - etsiolaki@deloitte.gr
 * Modifications Log 
 * Ver   Date         Author                                         Modification
 * 1.0   05-05-2021   Eleni Tsiolaki - etsiolaki@deloitte.gr   Initial Version
**/
public without sharing class XC_LCC253_DelegatedSignatureButton_D {

    /**
     * @description Taking the map of NE__Order__c with their Ids
     * ──────────────────────────────────────────────────────────────
     * @param ordersId Set of Ids of Orders
     * @return Map<Id,NE__Order__c>
     */
    public static Map<Id,NE__Order__c> retrieveInfoFromOrder(Set<Id> ordersId){
        Map<Id,NE__Order__c> orders = new Map<Id,NE__Order__c>([SELECT Id, NE__Type__c, XC_Segment__c, XC_Status__c, NE__AccountId__c, XC_DelegatedContact__c,
                                                                NE__OptyId__r.XC_Contact__c
                                                                FROM NE__Order__c
                                                                WHERE Id IN: ordersId
        ]);
        return orders;
    }

    /**
     * @description Retrieving the Secondary contacts from 'AccountContactRelation' in a spesific data structure 
     *              List of maps, each map has key->Id of contact and value-> Name of contact
     * ────────────────────────────────────────────────────────────────────────────
     * @param accountId 
     * @return List<Map<String,String>>
     */
    public static List<Map<String,String>> retrieveSecondaryContacts(Id accountId) {
        List<AccountContactRelation> junctionObject = [SELECT Id, ContactId, Contact.Name, XC_RelationshipType__c
                                                       FROM AccountContactRelation
                                                       WHERE AccountId =: accountId AND Contact.XC_PrimaryContact__c = FALSE];// AND Contact.AccountId =: accountId];
        
        List<Map<String,String>> secondaryContacts= new List<Map<String,String>>();
        Map<String,String> secondaryContactsRow;
        for(AccountContactRelation j: junctionObject){
            secondaryContactsRow= new Map<String,String>();
            secondaryContactsRow.put('key', j.ContactId);
            secondaryContactsRow.put('value', j.Contact.Name);
            secondaryContactsRow.put('relationshipType', j.XC_RelationshipType__c);
            secondaryContacts.add(secondaryContactsRow);
        }

        return secondaryContacts;
    }

    /**
     * @description Retrieving the Secondary contact's documents from 'XC_PersonalDocument__c' in a spesific data structure 
     *              List of maps, each map has key->Id of documents and value-> Name of documents
     * ─────────────────────────────────────────────────────────────────────────────────────────
     * @param secondaryContactId 
     * @return List<Map<String,String>>
     */
    public static List<Map<String,String>> retrieveSecondaryContactDocument(String secondaryContactId) {
        List<XC_PersonalDocument__c> personalDocumentsList = [SELECT Id, Name, XC_DocumentType__c
                                                              FROM XC_PersonalDocument__c
                                                              WHERE XC_DocumentTypeFormula__c = 'CI' AND XC_Contact__c =: secondaryContactId];
        
        List<Map<String,String>> personalDocumentsMap = new List<Map<String,String>>();
        Map<String,String> secondaryContactDocumentsRow;
        for(XC_PersonalDocument__c pers: personalDocumentsList) {
            secondaryContactDocumentsRow= new Map<String,String>();
            secondaryContactDocumentsRow.put('key', pers.Id);
            secondaryContactDocumentsRow.put('value', pers.Name);
            personalDocumentsMap.add(secondaryContactDocumentsRow);
        }
        return personalDocumentsMap;
    }
    
    /**
     * @description Retrieving Primary contact's document from 'Account' in a spesific data structure 
     *              List of maps, each map has key->Id of documents and value-> Name of documents
     * ──────────────────────────────────────────────────────────────
     * @param accountId 
     * @return List<Map<String,String>>
     */
    public static List<Map<String,String>> retrievePrimaryContactsDocument(Id accountId) {
        List<Map<String,String>> personalDocumentsMap = new List<Map<String,String>>();
        List<Contact> primaryContact = [SELECT Id,Name 
                                        FROM Contact 
                                        WHERE AccountId=: accountId AND Contact.XC_PrimaryContact__c= TRUE];
        if(primaryContact.size()>0){
            List<XC_PersonalDocument__c> personalDocumentsList = [SELECT Id, Name, XC_DocumentType__c
              												      FROM XC_PersonalDocument__c
             												      WHERE XC_DocumentTypeFormula__c = 'CI' AND XC_Contact__c =: primaryContact[0].Id];

            Map<String,String> primaryContactDocumentsRow;
            for(XC_PersonalDocument__c pers: personalDocumentsList) {
                primaryContactDocumentsRow= new Map<String,String>();
                primaryContactDocumentsRow.put('key', pers.Id);
                primaryContactDocumentsRow.put('value', pers.Name);
                personalDocumentsMap.add(primaryContactDocumentsRow);
            }
        }
        return personalDocumentsMap;
    }    
}