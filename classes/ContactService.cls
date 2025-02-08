/**
 * Created by snekkanti002 on 28/09/2021.
 */

public without sharing class ContactService {
    public static List<Contact> getLegalEntitiesContacts(List<String> personAccountIds) {
        DebugService.printLimits('ContactService', 'getLegalEntitiesContacts', 'start');
        List<Contact> contacts = ContactSelector.getLegalEntitiesContactsByAccountIds(personAccountIds);
        DebugService.printList('ContactService', 'getLegalEntitiesContacts', 'contacts', contacts);
        DebugService.printLimits('ContactService', 'getLegalEntitiesContacts', 'end');

        return contacts;
    }

    public static void upsertContacts(List<Contact> contacts, Schema.SObjectField fieldName, Boolean allOrNone) {
        DebugService.printLimits('ContactService', 'upsertContacts', 'start');

        if(contacts != null && !contacts.isEmpty()) {
            List<Database.UpsertResult> results = ContactSelector.upsertContacts(contacts, fieldName, allOrNone);

            for(Database.UpsertResult r : results) {
                if(!r.isSuccess()) {
                    System.debug('upsertContacts errors ' + r.getErrors());
                    System.debug('upsertContacts ids ' + r.getId());
                } else {
                    System.debug('upsertContacts success ' + r.getId());
                }
            }
        }
        DebugService.printLimits('ContactService', 'upsertContacts', 'end');
    }

    public static Contact setContactFieldsSigeud(LegalEntitiesController.SigeudContact sigeudContact) {
        DebugService.printLimits('ContactService', 'setContactFieldsSigeud', 'start');

        Contact con = new Contact();

        con.FirstName = (sigeudContact.firstName.length() > 40) ? sigeudContact.firstName.substring(0, 39) : sigeudContact.firstName;
        con.LastName = (sigeudContact.lastName.length() > 80) ? sigeudContact.lastName.substring(0, 79) : sigeudContact.lastName;
        con.Role__c = sigeudContact.role;
        con.RoleDescription__c = sigeudContact.roleDescription;
        con.Start_Role_Date__c = sigeudContact.startDate;
        con.Finish_Role_Date__c = sigeudContact.endDate;
        con.Persona_Fisica__c = sigeudContact.personaFisica;
        con.SigeudDate__c = sigeudContact.sigeudDate;
        con.IsDeleted__c = sigeudContact.isDeleted;
        con.ContactKey__c = sigeudContact.contactKey;
        con.AccountId = sigeudContact.accountId;

        DebugService.printLimits('ContactService', 'setContactFieldsSigeud', 'end');

        return con;
    }

    public static List<String> deactivateContactsNotInSigeud(List<String> contactIds) {
        DebugService.printLimits('ContactService', 'deactivateContactsNotInSigeud', 'start');
        List<String> failedIds = new List<String>();

        List<Contact> contacts = ContactSelector.getContactsToDeactivate(contactIds);

        DebugService.printList('ContactService', 'deactivateContactsNotInSigeud', 'contacts', contacts);

        if(!contacts.isEmpty()) {
            for(Contact c : contacts) {
                c.IsDeleted__c = true;
            }

            List<Database.SaveResult> results = ContactSelector.updateContacts(contacts, false);

            for(Database.SaveResult r : results) {
                if(!r.isSuccess()) {
                    System.debug('upsertContacts errors ' + r.getErrors());
                    System.debug('upsertContacts errors ' + r.getId());
                    failedIds.add(r.getId());
                } else {
                    System.debug('upsertContacts success ' + r.getId());
                }
            }
        }

        DebugService.printList('ContactService', 'deactivateContactsNotInSigeud', 'failedIds', failedIds);
        DebugService.printLimits('ContactService', 'deactivateContactsNotInSigeud', 'end');

        return failedIds;
    }
}