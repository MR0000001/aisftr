/**
 * Created by snekkanti002 on 28/09/2021.
 */

public without sharing class LegalEntitiesController {
    private static List<String> contactKeys = new List<String>();
    private static List<SigeudContactWrapper> sigeudContactWrappers = new List<SigeudContactWrapper>();
    private static List<LegalEntitySorter> legalEntitySorters = new List<LegalEntitySorter>();

    public class LegalEntitiesWrapper {
        @AuraEnabled public List<LegalEntity> legalEntities {get;set;}
        @AuraEnabled public String errorMessage {get;set;}
        @AuraEnabled public String personAccountId {get;set;}
    }

    public class LegalEntity {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String contactKey {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String role {get;set;}
        @AuraEnabled public String roleDescription {get;set;}
        @AuraEnabled public String mobile {get;set;}
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public String company {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String personaFisicaId {get;set;}
        @AuraEnabled public String piva {get;set;}
        @AuraEnabled public String cf {get;set;}
        @AuraEnabled public String via {get;set;}
        @AuraEnabled public Boolean disableAssociate {get;set;}
    }

    public class LegalEntitySorter implements Comparable {
        public LegalEntity legalEntity;

        public LegalEntitySorter(LegalEntity legalEntity) {
            this.legalEntity = legalEntity;
        }

        public Integer compareTo(Object compareTo) {
            LegalEntitySorter comapareToLegalEntitySorter = (LegalEntitySorter)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (this.legalEntity.company > comapareToLegalEntitySorter.legalEntity.company) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (this.legalEntity.company < comapareToLegalEntitySorter.legalEntity.company) {
                // Set return value to a negative value.
                returnValue = -1;
            } else if ((this.legalEntity.company == null) && (comapareToLegalEntitySorter.legalEntity.company != null)){
                // nulls-first implementation
                returnValue = -1;
            } else if ((this.legalEntity.company != null) && (comapareToLegalEntitySorter.legalEntity.company == null)){
                // nulls-first implementation
                returnValue = 1;
            }
            return returnValue;
        }
    }

    public class SigeudWrapper {
        @AuraEnabled public List<SigeudContact> sigeudContacts {get;set;}
        @AuraEnabled public String errorMessage {get;set;}
    }

    public class SigeudAccount {
        @AuraEnabled public Account account {get;set;}
        @AuraEnabled public Boolean alreadyExists {get;set;}
    }

    public class SigeudContact {
        @AuraEnabled public String contactKey {get;set;}
        @AuraEnabled public String firstName {get;set;}
        @AuraEnabled public String piva {get;set;}
        @AuraEnabled public String cf {get;set;}
        @AuraEnabled public String role {get;set;}
        @AuraEnabled public String roleDescription {get;set;}
        @AuraEnabled public String lastName {get;set;}
        @AuraEnabled public Date startDate {get;set;}
        @AuraEnabled public Date endDate {get;set;}
        @AuraEnabled public String personaFisica {get;set;}
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public Date sigeudDate {get;set;}
        @AuraEnabled public String via {get;set;}
        @AuraEnabled public Boolean isDeleted {get;set;}
        @AuraEnabled public SigeudAccount sigeudAccount {get;set;}
    }

    public class SigeudContactWrapper implements Comparable {
        public SigeudContact sigeudContact;

        public SigeudContactWrapper(SigeudContact sigeudContact) {
            this.sigeudContact = sigeudContact;
        }

        public Integer compareTo(Object compareTo) {
            SigeudContactWrapper compareToSigeudContact = (SigeudContactWrapper)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (this.sigeudContact.firstName > compareToSigeudContact.sigeudContact.firstName) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (this.sigeudContact.firstName < compareToSigeudContact.sigeudContact.firstName) {
                // Set return value to a negative value.
                returnValue = -1;
            } else if ((this.sigeudContact.firstName == null) && (compareToSigeudContact.sigeudContact.firstName != null)){
                // nulls-first implementation
                returnValue = -1;
            } else if ((this.sigeudContact.firstName != null) && (compareToSigeudContact.sigeudContact.firstName == null)){
                // nulls-first implementation
                returnValue = 1;
            }
            return returnValue;
        }
    }

    @AuraEnabled
    public static LegalEntitiesWrapper getLegalEntities(String fiscalCodePersonAccount) {
        DebugService.printLimits('LegalEntitiesController', 'getLegalEntities', 'start');
        System.debug('fiscalCodePersonAccount ' + fiscalCodePersonAccount);

        List<String> personAccountIds = new List<String>();
        LegalEntitiesWrapper legalEntitiesWrapper = new LegalEntitiesWrapper();

        try {
            if(String.isNotBlank(fiscalCodePersonAccount)) {
                personAccountIds = AccountService.getAccountIdsFromFiscalCode(fiscalCodePersonAccount);
            }

            DebugService.printList('LegalEntitiesController', 'getLegalEntities', 'personAccountIds', personAccountIds);

            if(!personAccountIds.isEmpty()) {
                List<Contact> contacts = ContactService.getLegalEntitiesContacts(personAccountIds);

                DebugService.printList('LegalEntitiesController', 'getLegalEntities', 'contacts', contacts);

                if(!contacts.isEmpty()) {
                    for(Contact con : contacts) {
                        LegalEntity legalEntity = new LegalEntity();

                        legalEntity.id = con.Id;
                        legalEntity.contactKey = con.ContactKey__c;
                        legalEntity.company = con.Account.Name;
                        legalEntity.name = con.Name;
                        legalEntity.email = con.Email;
                        legalEntity.mobile = con.MobilePhone;
                        legalEntity.role = con.Role__c;
                        legalEntity.roleDescription = con.RoleDescription__c;
                        legalEntity.accountId = con.AccountId;
                        legalEntity.personaFisicaId = con.Persona_Fisica__c;
                        legalEntity.piva = con.Account.Partita_IVA__c;
                        legalEntity.cf = con.Account.Account_Fiscal_Code__c;
                        legalEntity.disableAssociate = false;
                        legalEntity.via = String.isNotBlank(con.Account.BillingStreet) ? con.Account.BillingStreet + ' ' : '';
                        legalEntity.via += String.isNotBlank(con.Account.BillingPostalCode) ? con.Account.BillingPostalCode : '';
                        legalEntity.via = legalEntity.via.trim();

                        legalEntitySorters.add(new LegalEntitySorter(legalEntity));

                        System.debug('legalEntity ' + legalEntity);
                    }

                    legalEntitiesWrapper.legalEntities = getSortedLegalEntities();
                    legalEntitiesWrapper.personAccountId = personAccountIds[0];
                    DebugService.printList('LegalEntitiesController', 'getLegalEntities', 'legalEntitiesWrapper.legalEntities', legalEntitiesWrapper.legalEntities);
                } else {
                    legalEntitiesWrapper.errorMessage = Label.LegalEntities_NoContactsFound;
                    legalEntitiesWrapper.personAccountId = personAccountIds[0];

                    System.debug('No contacts legalEntitiesWrapper ' + legalEntitiesWrapper);
                }
            } else {
                legalEntitiesWrapper.errorMessage = Label.LegalEntities_NoPersonAccountsFound;

                System.debug('No accounts legalEntitiesWrapper ' + legalEntitiesWrapper);
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('LegalEntitiesController', 'getLegalEntities', e);
        }
        DebugService.printLimits('LegalEntitiesController', 'getLegalEntities', 'end');
        System.debug('legalEntitiesWrapper ' + legalEntitiesWrapper);
        return legalEntitiesWrapper;
    }

    @AuraEnabled
    public static SigeudWrapper sigeudCallout(String fiscalCodePersonAccount, String personAccountId) {
        DebugService.printLimits('LegalEntitiesController', 'sigeudCallout', 'start');
        SigeudWrapper sigeudWrapper = new SigeudWrapper();

        ResponseSigeud responseSigeud = SigeudCallout.sigeudCallout(fiscalCodePersonAccount);

        System.debug('responseSigeud ' + responseSigeud);

        try {
            if(String.isNotBlank(responseSigeud.codice_fiscale) && responseSigeud.rappresentate != null && !responseSigeud.rappresentate.isEmpty()) {
                List<ResponseSigeud.Rappresentate> representatives = responseSigeud.rappresentate;
                DebugService.printList('LegalEntitiesController', 'sigeudCallout', 'representatives', representatives);

                List<SigeudContact> sigeudContacts = getSigeudContacts(responseSigeud.codice_fiscale, representatives, personAccountId);
                DebugService.printList('LegalEntitiesController', 'sigeudCallout', 'sigeudContacts', sigeudContacts);

                if(!sigeudContacts.isEmpty()) {
                    sigeudWrapper.sigeudContacts = getSortedSigeudContacts();
                    DebugService.printList('LegalEntitiesController', 'sigeudCallout', 'sigeudWrapper.sigeudContacts', sigeudWrapper.sigeudContacts);
                } else {
                    System.debug('rappresentate not empty but no legal entities with this cf');
                    sigeudWrapper.errorMessage = Label.LegalEntities_Sigeud_NoLegalEntitiesFound;
                }
            } else if(String.isNotBlank(responseSigeud.codice_fiscale) && (responseSigeud.rappresentate == null || responseSigeud.rappresentate.isEmpty())) {
                System.debug('rappresentate empty and no legal entities with this cf');
                sigeudWrapper.errorMessage = Label.LegalEntities_Sigeud_NoLegalEntitiesFound;
            } else {
                System.debug('integration error');
                sigeudWrapper.errorMessage = Label.LegalEntities_Sigeud_IntegrationError;
            }
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('LegalEntitiesController', 'sigeudCallout', e);
            sigeudWrapper.errorMessage = Label.Generic_SomethingWrong;
        }
        System.debug('sigeudWrapper ' + sigeudWrapper);
        DebugService.printLimits('LegalEntitiesController', 'sigeudCallout', 'end');

        return sigeudWrapper;
    }

    public static List<SigeudContact> getSigeudContacts(String fiscalCodePersonAccount, List<ResponseSigeud.Rappresentate> representatives, String personAccountId) {
        DebugService.printLimits('LegalEntitiesController', 'getSigeudContacts', 'start');

        List<String> accExtKeys = new List<String>();
        Map<String, Account> businessAccountKeyMap = new Map<String, Account>();
        List<SigeudContact> sigeudContacts = new List<SigeudContact>();

        String businessAccountRecordId = AccountSelector.getBussinessAccountId();
        System.debug('businessAccountRecordId ' + businessAccountRecordId);

        for(ResponseSigeud.Rappresentate singleAccount : representatives) {
            accExtKeys.add(getBusinessAccountKey(singleAccount));
        }

        DebugService.printList('LegalEntitiesController', 'getSigeudContacts', 'accExtKeys', accExtKeys);

        if(!accExtKeys.isEmpty()) {
            businessAccountKeyMap = AccountService.getBusinessAccountKeyMap(accExtKeys);
        }

        DebugService.printMap('LegalEntitiesController', 'getSigeudContacts', 'businessAccountKeyMap', new List<String>(businessAccountKeyMap.keySet()), businessAccountKeyMap.values(), true);

        for(ResponseSigeud.Rappresentate singleRepresentative : representatives) {
            System.debug('singleRepresentative ' + singleRepresentative);
            Account acc = new Account();
            SigeudAccount sigeudAccount = new SigeudAccount();

            String businessAccountKey = getBusinessAccountKey(singleRepresentative);
            System.debug('businessAccountKey ' + businessAccountKey);

            if(!businessAccountKeyMap.containsKey(businessAccountKey)) {
                System.debug('Entered businessAccountKeyMap not contains');
                acc.Type_Sigeud__c = singleRepresentative.cat_giuridica.codice;
                acc.Description_Sigeud__c = singleRepresentative.cat_giuridica.descrizione;
                acc.Partita_IVA__c = singleRepresentative.partita_iva;
                acc.Account_Fiscal_Code__c = singleRepresentative.codice_fiscale;
                acc.Name = singleRepresentative.ragione_sociale;
                acc.Pec__c = singleRepresentative.indirizzo_pec;
                acc.Email_Account__c = singleRepresentative.indirizzo_mail;
                String address = (singleRepresentative.indirizzo?.via != null) ? singleRepresentative.indirizzo?.via : '';
                String numberAddress = (singleRepresentative.indirizzo?.civico != null) ? ' ' + singleRepresentative.indirizzo?.civico : '';
                acc.BillingStreet = address + numberAddress;
                acc.BillingPostalCode = singleRepresentative.indirizzo?.cap;
                acc.BillingCity = singleRepresentative.indirizzo?.comune?.descrizione;
                acc.BillingState = singleRepresentative.indirizzo?.comune?.sigla_provincia;
                acc.RecordTypeId = businessAccountRecordId;
                acc.BusinessAccountKey__c = businessAccountKey;
                sigeudAccount.alreadyExists = false;
            } else {
                System.debug('Entered businessAccountKeyMap contains');
                acc = businessAccountKeyMap.get(businessAccountKey);
                sigeudAccount.alreadyExists = true;
            }
            sigeudAccount.account = acc;
            sigeudContacts.addAll(createSigeudContacts(fiscalCodePersonAccount, singleRepresentative, sigeudAccount, personAccountId, businessAccountKey));
        }

        DebugService.printList('LegalEntitiesController', 'getSigeudContacts', 'sigeudContacts', sigeudContacts);
        DebugService.printList('LegalEntitiesController', 'getSigeudContacts', 'contactKeys', contactKeys);

        //System.enqueueJob(new DeleteContactsSigeudQueueable(fiscalCodePersonAccount, contactKeys));

        DebugService.printLimits('LegalEntitiesController', 'getSigeudContacts', 'end');

        return sigeudContacts;
    }

    public static List<SigeudContact> createSigeudContacts(String fiscalCodePersonAccount, ResponseSigeud.Rappresentate singleRepresentative, SigeudAccount sigeudAccount, String personAccountId, String businessAccountKey) {
        DebugService.printLimits('LegalEntitiesController', 'createSigeudContacts', 'start');
        List<ResponseSigeud.Cariche> contactsSigeud = singleRepresentative.cariche;
        List<SigeudContact> sigeudContacts = new List<SigeudContact>();

        System.debug('contactsSigeud -> '+ contactsSigeud);
        if(contactsSigeud != null) {
            for(ResponseSigeud.Cariche singleContact : contactsSigeud) {
                SigeudContact sigeudContact = new SigeudContact();

                sigeudContact.contactKey = fiscalCodePersonAccount;
                sigeudContact.via = getBusinessAccountAddress(singleRepresentative);
                sigeudContact.firstName = singleRepresentative.ragione_sociale;
                if(String.isBlank(singleContact.codice) && String.isBlank(singleContact.descrizione)) {
                    sigeudContact.role = sigeudAccount.account.Type_Sigeud__c;
                    sigeudContact.roleDescription = sigeudAccount.account.Description_Sigeud__c;
                } else {
                    sigeudContact.role = singleContact.codice;
                    sigeudContact.roleDescription = singleContact.descrizione;
                }
                sigeudContact.lastName = String.isNotBlank(singleContact.descrizione) ? singleContact.descrizione : sigeudAccount.account.Description_Sigeud__c;
                sigeudContact.startDate = String.isNotBlank(singleContact.data_inizio) ? Date.parse(singleContact.data_inizio) : null;
                sigeudContact.endDate = String.isNotBlank(singleContact.data_fine) ? Date.parse(singleContact.data_fine) : null;
                sigeudContact.personaFisica = personAccountId;
                sigeudContact.sigeudDate = Date.today();
                sigeudContact.isDeleted = false;

                if(sigeudAccount.alreadyExists) {
                    sigeudContact.accountId = sigeudAccount.account.Id;
                }

                if(String.isNotBlank(singleRepresentative.partita_iva)) {
                    System.debug('Entered partita_iva if');
                    sigeudContact.piva = singleRepresentative.partita_iva;
                }
                System.debug('sigeudContact.piva ' + sigeudContact.piva);
                if(String.isNotBlank(singleRepresentative.codice_fiscale)) {
                    System.debug('Entered codice_fiscale if');
                    sigeudContact.cf = singleRepresentative.codice_fiscale;
                }
                System.debug('sigeudContact.cf ' + sigeudContact.cf);

                sigeudContact.contactKey += businessAccountKey;
                sigeudContact.contactKey += String.isNotBlank(sigeudContact.role) ? removeSpecialCharacterForUrl(sigeudContact.role) : '';
                sigeudContact.contactKey = sigeudContact.contactKey.deleteWhitespace().toUpperCase();
                contactKeys.add(sigeudContact.contactKey);
                sigeudContact.sigeudAccount = sigeudAccount;

                sigeudContacts.add(sigeudContact);
                System.debug('sigeudContact.ContactKey__c ' + sigeudContact.contactKey);
                System.debug('sigeudContact ' + sigeudContact);

                sigeudContactWrappers.add(new SigeudContactWrapper(sigeudContact));
            }
        }

        DebugService.printList('LegalEntitiesController', 'createSigeudContacts', 'sigeudContacts', sigeudContacts);
        DebugService.printLimits('LegalEntitiesController', 'createSigeudContacts', 'end');

        return sigeudContacts;
    }

    @AuraEnabled
    public static Integer saveSigeudRecords(List<SigeudContact> sigeudContacts) {
        DebugService.printLimits('LegalEntitiesController', 'saveSigeudRecords', 'start');
        DebugService.printList('LegalEntitiesController', 'saveSigeudRecords', 'sigeudContacts', sigeudContacts);

        Integer successCountContacts = 0;
        List<Contact> upsertContacts = new List<Contact>();
        Map<String, List<Contact>> accountBusinessKeyContactsMap = new Map<String, List<Contact>>();
        List<Account> insertAccounts = new List<Account>();

        try {
            for(SigeudContact c : sigeudContacts) {
                Contact con = ContactService.setContactFieldsSigeud(c);
                System.debug('con ' + con);

                if(!c.sigeudAccount.alreadyExists) {
                    System.debug('Accounts not exist ');
                    insertAccounts.add(c.sigeudAccount.account);

                    if(!accountBusinessKeyContactsMap.containsKey(c.sigeudAccount.account.BusinessAccountKey__c)) {
                        accountBusinessKeyContactsMap.put(c.sigeudAccount.account.BusinessAccountKey__c, new List<Contact>{con});
                        System.debug('Entered if ' + accountBusinessKeyContactsMap);
                    } else {
                        List<Contact> contacts = accountBusinessKeyContactsMap.get(c.sigeudAccount.account.BusinessAccountKey__c);
                        contacts.add(con);
                        accountBusinessKeyContactsMap.put(c.sigeudAccount.account.BusinessAccountKey__c, contacts);

                        System.debug('Entered else ' + accountBusinessKeyContactsMap);
                    }
                } else {
                    System.debug('Accounts exist');
                    upsertContacts.add(con);
                }
            }

            System.debug('after loop accountBusinessKeyContactsMap ' + accountBusinessKeyContactsMap);

            DebugService.printList('LegalEntitiesController', 'saveSigeudRecords', 'insertAccounts', insertAccounts);

            AccountService.insertAccounts(insertAccounts, false);

            for(Account acc : insertAccounts) {
                System.debug(acc.Id);
                if(acc.Id != null) {
                    System.debug('Acc id not empty');
                    for(Contact con : accountBusinessKeyContactsMap.get(acc.BusinessAccountKey__c)) {
                        if(!upsertContacts.contains(con)) {
                            System.debug('not contains ' + con);
                            upsertContacts.add(con);
                        }
                        con.AccountId = acc.Id;
                    }
                }
            }

            DebugService.printList('LegalEntitiesController', 'saveSigeudRecords', 'upsertContacts', upsertContacts);

            ContactService.upsertContacts(upsertContacts, Contact.Field.ContactKey__c, false);

            if(!upsertContacts.isEmpty()) {
                for(Contact c : upsertContacts) {
                    if(c.Id != null) {
                        successCountContacts++;
                    }
                }
            } else {
                successCountContacts = 0;
            }

            System.debug('successCountContacts ' + successCountContacts);
        } catch(Exception e) {
            ErrorLogEventHandler.standardExceptionLog('LegalEntitiesController', 'saveSigeudRecords', e);
        }

        DebugService.printLimits('LegalEntitiesController', 'saveSigeudRecords', 'end');

        return successCountContacts;
    }

    public static String getBusinessAccountKey(ResponseSigeud.Rappresentate singleRepresentative) {
        DebugService.printLimits('LegalEntitiesController', 'getBusinessAccountKey', 'start');

        String businessAccountKey = '';

        businessAccountKey += String.isNotBlank(singleRepresentative.partita_iva) ? removeSpecialCharacterForUrl(singleRepresentative.partita_iva) : '';
        businessAccountKey += String.isNotBlank(singleRepresentative.codice_fiscale) ? removeSpecialCharacterForUrl(singleRepresentative.codice_fiscale) : '';

        if(singleRepresentative.indirizzo != null) {
            businessAccountKey += String.isNotBlank(singleRepresentative.indirizzo.via) ? removeSpecialCharacterForUrl(singleRepresentative.indirizzo.via) : '';
            businessAccountKey += String.isNotBlank(singleRepresentative.indirizzo.civico) ? removeSpecialCharacterForUrl(singleRepresentative.indirizzo.civico) : '';
            businessAccountKey += String.isNotBlank(singleRepresentative.indirizzo.cap) ? removeSpecialCharacterForUrl(singleRepresentative.indirizzo.cap) : '';
        }

        businessAccountKey = businessAccountKey.deleteWhitespace().toUpperCase();

        if(businessAccountKey.length() > Integer.valueOf(Label.LegalEntities_AccountBussinessKeyLength)) {
            System.debug('Greater than ' + Label.LegalEntities_AccountBussinessKeyLength);
            businessAccountKey = businessAccountKey.substring(0, Integer.valueOf(Label.LegalEntities_AccountBussinessKeyLength));
        }

        System.debug('businessAccountKey ' + businessAccountKey);
        DebugService.printLimits('LegalEntitiesController', 'getBusinessAccountKey', 'end');

        return businessAccountKey;
    }

    public static String getBusinessAccountAddress(ResponseSigeud.Rappresentate singleRepresentative) {
        DebugService.printLimits('LegalEntitiesController', 'getBusinessAccountAddress', 'start');

        String via = '';

        if(singleRepresentative.indirizzo != null) {
            via += String.isNotBlank(singleRepresentative.indirizzo.via) ? singleRepresentative.indirizzo.via + ' ' : '';
            via += String.isNotBlank(singleRepresentative.indirizzo.civico) ? singleRepresentative.indirizzo.civico + ' ' : '';
            via += String.isNotBlank(singleRepresentative.indirizzo.cap) ? singleRepresentative.indirizzo.cap : '';
        }

        System.debug('via w/o trim ' + via);
        DebugService.printLimits('LegalEntitiesController', 'getBusinessAccountAddress', 'end');

        return via.trim();
    }

    public static List<SigeudContact> getSortedSigeudContacts() {
        DebugService.printLimits('LegalEntitiesController', 'getSortedSigeudContacts', 'start');

        List<SigeudContact> sigeudContacts = new List<SigeudContact>();

        if(!sigeudContactWrappers.isEmpty()) {
            System.debug('sigeudContactWrappers is not empty');

            sigeudContactWrappers.sort();

            for(SigeudContactWrapper sigeudContactWrapper : sigeudContactWrappers) {
                sigeudContacts.add(sigeudContactWrapper.sigeudContact);
            }

            DebugService.printList('LegalEntitiesController', 'getSortedSigeudContacts', 'sigeudContacts', sigeudContacts);
            DebugService.printLimits('LegalEntitiesController', 'getSortedSigeudContacts', 'end');
        }

        return sigeudContacts;
    }

    public static List<LegalEntity> getSortedLegalEntities() {
        DebugService.printLimits('LegalEntitiesController', 'getSortedLegalEntities', 'start');

        List<LegalEntity> legalEntities = new List<LegalEntity>();

        if(!legalEntitySorters.isEmpty()) {
            System.debug('legalEntitySorters is not empty');

            legalEntitySorters.sort();

            for(LegalEntitySorter legalEntitySorter : legalEntitySorters) {
                legalEntities.add(legalEntitySorter.legalEntity);
            }

            DebugService.printList('LegalEntitiesController', 'getSortedLegalEntities', 'legalEntities', legalEntities);
            DebugService.printLimits('LegalEntitiesController', 'getSortedLegalEntities', 'end');
        }

        return legalEntities;
    }

    @AuraEnabled
    public static List<String> deactivateContactsNotInSigeud(List<String> contactIds) {
        DebugService.printLimits('LegalEntitiesController', 'deactivateContactsNotInSigeud', 'start');
        DebugService.printList('LegalEntitiesController', 'deactivateContactsNotInSigeud', 'contactIds', contactIds);
        List<String> failedIds = ContactService.deactivateContactsNotInSigeud(contactIds);
        DebugService.printLimits('LegalEntitiesController', 'deactivateContactsNotInSigeud', 'end');

        return failedIds;
    }

    public static String removeSpecialCharacterForUrl(String originalString) {
        String finalString = originalString;
        finalString = originalString.replaceAll('[\\/\\?\\:\\@\\-\\.\\_\\~\\!\\$\\&\\\'\\(\\)\\*\\+\\,\\;\\=]', '');

        return finalString;
    }
}