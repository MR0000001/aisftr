/**
 * Created by snekkanti002 on 28/09/2021.
 */

public without sharing class ContactSelector {
    public static List<Contact> getLegalEntitiesContactsByAccountIds(List<String> personAccountIds) {
        DebugService.printLimits('ContactSelector', 'getLegalEntitiesContactsByAccountIds', 'start');

        List<Contact> contacts = [
                SELECT Name, Account.Name, Role__c, MobilePhone, Email, SigeudDate__c, AccountId, Persona_Fisica__c, RoleDescription__c, Account.Partita_IVA__c, Account.Account_Fiscal_Code__c, Account.BillingStreet, Account.BillingPostalCode, Account.BillingCity, Account.BillingState, ContactKey__c
                FROM Contact
                WHERE Persona_Fisica__c IN: personAccountIds AND SigeudDate__c =: System.today() AND IsDeleted__c = FALSE
                ORDER BY Account.Name
        ];

        DebugService.printLimits('ContactSelector', 'getLegalEntitiesContactsByAccountIds', 'end');

        return contacts;
    }

    public static List<Database.UpsertResult> upsertContacts(List<Contact> contacts, Schema.SObjectField fieldName, Boolean allOrNone) {
        Database.UpsertResult[] results = new List<Database.UpsertResult>();
        try {
            results = Database.upsert(contacts, fieldName, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('ContactSelector', 'upsertContacts', e);
        }
        return results;
    }

    public static List<Database.SaveResult> updateContacts(List<Contact> contacts, Boolean allOrNone) {
        Database.SaveResult[] results = new List<Database.SaveResult>();
        try {
            results = Database.update(contacts, allOrNone);
            ErrorLogEventHandler.createErrorLogsFromFailedDML(results);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('ContactSelector', 'updateContacts', e);
        }
        return results;
    }

    public static List<Contact> getContactsToDeactivate(List<String> contactIds) {
        List<Contact> contacts = [
                SELECT IsDeleted__c
                FROM Contact
                WHERE Id IN: contactIds AND IsDeleted__c = false
        ];

        return contacts;
    }
}