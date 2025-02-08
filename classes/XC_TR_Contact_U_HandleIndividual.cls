/**
* @author Federico Amici - federico.amici@nttdata.com
* @date Creation 03/09/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_Contact_U_HandleIndividual – Handle Individual record linked to Contact
*/
public without sharing class XC_TR_Contact_U_HandleIndividual {


    /**
     * @description Handle individual.
     *
     * @param listContact the list contact
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void handleIndividual(List<Contact> listContact, Map<Id, Contact> mapOld, Map<Id, Contact> mapNew) {

        Contact contactOld = new Contact();

        System.debug('@@@newIndi ' + listContact.get(0).IndividualId);

        for (Contact contactNew : listContact) {
            contactOld = mapOld.get(contactNew.Id);

            System.debug('@@@oldIndi ' + contactOld.IndividualId);
            System.debug('@@@newIndi ' + contactNew.IndividualId);

            if (contactNew.IndividualId != contactOld.IndividualId && contactOld.IndividualId != NULL) {
                contactNew.addError(Label.XC_CL_Contact_CantEditIndividual);
            }
        }

        System.debug('@@@oldIndi ' + contactOld.IndividualId);
    }

    /**
     * Update individuals from contact.
     *
     * @author Giulio Serra giserra@deloitte.it
     * @param contacts the contacts
     * @date Creation 20/02/19
     * @description update the information of the individual children of the contacts
     */
    public static void updateIndividualsFromContact(List<Contact> contacts) {

        List<Individual> indToUpdate = new List<Individual>();
        Map<Id, Individual> individuals = XC_TR_Contact_U_HandleIndividual_D.getIndividualFromContacts(contacts);

        for (Contact c : contacts) {
            Boolean shouldUpdate = false;
            Individual ind = individuals.get(c.IndividualId);
            if (ind != null) {
                if (ind.FirstName != c.FirstName) {
                    ind.FirstName = c.FirstName;
                    shouldUpdate = true;
                }

                if (ind.LastName != c.LastName) {
                    ind.LastName = c.LastName;
                    shouldUpdate = true;
                }
                /*if (ind.XC_GiveDataToThirdParties__c != c.XC_GiveDataToThirdParties__c) {
                    ind.XC_GiveDataToThirdParties__c = c.XC_GiveDataToThirdParties__c;
                    shouldUpdate = true;

                }
                if (ind.XC_ThirdPartyConsentVersion__c != c.XC_ThirdPartiesConsentVersion__c) {
                    ind.XC_ThirdPartyConsentVersion__c = c.XC_ThirdPartiesConsentVersion__c;
                    shouldUpdate = true;

                }*/
                if (ind.XC_RobinsonCustomer__c != c.XC_RobinsonCustomer__c) {
                    ind.XC_RobinsonCustomer__c = c.XC_RobinsonCustomer__c;
                    shouldUpdate = true;

                }


                if (shouldUpdate) {
                    indToUpdate.add(ind);
                }

            }
        }
        System.debug('@@@ ind to insert' + indToUpdate);
        List<XC_UTIL_SObject.WrapperResult> results = XC_UTIL_Sobject.updateListRecords(indToUpdate);
        System.debug('@@@ indupdate esito' + results);
    }
    
    /**
     * Creates the individual.
     *
     * @author Giulio Serra - giserra@deloitte.it
     * @param listContact the contacts
     * @date Creation 20/02/19
     * @description create the individual with the informations of the contact
     */
    /* -----------------------------DEPRECATED DDP - 04-02-2020-----------------------------------------
    public static void createIndividual(List<Contact> listContact) {
        List<Contact> contacts = new List<Contact>();
        for (Contact contact : listContact) {
            if (!contact.XC_SkipInd__c) {
                contacts.add(contact);
            }
        }

        List<Contact> queried = XC_TR_Contact_U_HandleIndividual_D.getEditableContacts(contacts);
        System.debug('@@@@ input list' + contacts.size() + ' ' + queried.size());

        Map<Contact, List<Individual>> indMap = new Map<Contact, List<Individual>>();

        List<Individual> individuals = new List<Individual>();

        for (Contact c : queried) {
            Individual ind = new Individual();
            ind.FirstName = c.FirstName;
            ind.LastName = c.LastName;
            ind.XC_GiveDataToThirdParties__c = c.XC_GiveDataToThirdParties__c;
            ind.XC_ChildContact__c = c.id;

            if (indMap.containsKey(c)) {
                List<Individual> indList = indMap.get(c);
                indList.add(ind);
            } else {
                List<Individual> indList = new List<Individual>();
                indList.add(ind);
                indMap.put(c, indList);
            }

            individuals.add(ind);
        }

        XC_UTIL_Sobject.insertListRecords(individuals);
        List<Contact> toUpdate = new List<Contact>();
        Map<String, List<Individual>> contact2Individual = new Map<String, List<Individual>>();

        for (Individual ind : individuals) {
            if (contact2individual.containsKey(ind.XC_ChildContact__c)) {
                contact2Individual.get(ind.XC_ChildContact__c).add(ind);
            } else {
                List<Individual> indList = new List<Individual>();
                indList.add(ind);
                contact2individual.put(ind.XC_ChildContact__c, indList);
            }
        }

        System.debug('@@@map contactId2Ind ' + contact2Individual);

        for (Contact c : queried) {
            c.IndividualId = contact2individual.get(c.id)[0].id;
            toUpdate.add(c);
        }

        System.debug('@@@@final contact list to update' + toUpdate);

        List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_Sobject.updateListRecords(toUpdate);

        List<Contact> contactsToAddLE = new List<Contact>();
        for (Contact c : toUpdate) {
            if (!c.XC_SkipTriggerIndividual__c) {
                contactsToAddLE.add(c);
            }
        }
        List<XC_UTIL_Sobject.WrapperResult> leRes = insertLegalEntity(contactsToAddLE);
        System.debug('@@@@ LE DML results = ' + leRes);
        System.debug('@@@@insert contact result' + results);
    }*/

    /**
     * Creates the Legal Entity.
     *
     * @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
     * @param toUpdate
     * @return List<WrapperResult> dml results
     * @date Creation 23/04/19
     * @description create the legal entities
     */
    /* -----------------------------DEPRECATED DDP - 04-02-2020-----------------------------------------
    private static List<XC_UTIL_Sobject.WrapperResult> insertLegalEntity(List<Contact> toUpdate) {
        if (toUpdate == null || toUpdate.isEmpty()) {
            XC_UTIL_Sobject.WrapperResult wr = new XC_UTIL_Sobject.WrapperResult();
            wr.success = true;
            return new List<XC_UTIL_Sobject.WrapperResult>{
                    wr
            };
        }

        List<id> contactIds = XC_UTIL_SObject.getIds(toUpdate);
        Map<Id, Contact> contacts = new Map<Id, Contact> ([
                SELECT ID, IndividualId, XC_MainLegalEntity__c, XC_GiveDataToNew__c,XC_PrimaryContact__c, AccountId
                FROM Contact
                WHERE Id IN :contactIds
        ]);
        String legalEntityToCheck = (String) contacts.values()[0].get('XC_MainLegalEntity__c');
        List<XC_CM_CountryLegalEntityAssociation__mdt> listCM = new List<XC_CM_CountryLegalEntityAssociation__mdt>([
                SELECT XC_Country__c
                FROM XC_CM_CountryLegalEntityAssociation__mdt
                WHERE XC_LegalEntity__c = :legalEntityToCheck
        ]);
        List<XC_LegalEntityConsent__c> legalEntityList = new List<XC_LegalEntityConsent__c>();
        for (Contact con : contacts.values()) {
            XC_LegalEntityConsent__c legalEntity = new XC_LegalEntityConsent__c();
            legalEntity.XC_Individual__c = con.individualId;
            legalEntity.XC_GiveDataToNew__c = con.XC_GiveDataToNew__c;
            legalEntity.XC_LegalEntity__c = con.XC_MainLegalEntity__c;
            legalEntity.XC_LeCountry__c = listCM[0].XC_Country__c.toUpperCase();
            legalEntityList.add(legalEntity);
        }
        return XC_UTIL_Sobject.insertListRecords(legalEntityList);
    }*/

    /**
    * Creates the Legal Entity.
    *
    * @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
    * @param contact
    * @date Creation 23/04/19
    * @description update account consents
    */
    public static void updateAccountConsents(List<Contact> contact) {
        List<id> contactIds = XC_UTIL_SObject.getIds(contact);
        Map<Id, Contact> contacts = new Map<Id, Contact> ([
                SELECT ID,XC_GiveDataToThirdParties__c, XC_PrimaryContact__c, AccountId, Account.XC_GDPRThirdPartiesRelated__c
                FROM Contact
                WHERE Id IN :contactIds
        ]);
        List<Account> accToUpdate = new List<Account>();
        for (Contact con : contacts.values()) {
            if (con.XC_PrimaryContact__c) {

                System.debug('@@@@ con.Account = ' + con.Account);
                /*
                  if(con.XC_GiveDataToThirdParties__c != null && con.XC_GiveDataToThirdParties__c != con.Account.XC_GDPRThirdPartiesRelated__c){
                      con.Account.XC_GDPRThirdPartiesRelated__c = con.XC_GiveDataToThirdParties__c;
                      accToUpdate.add(con.Account);
                  }*/
            }
        }
        XC_UTIL_Sobject.updateListRecords(accToUpdate);
    }


    /**
     * Creates the individual.
     *
     * @author dpalamides
     * @param listContact the contacts
     * @date Creation 20/02/19
     * @description create the individual with the informations of the contact
     */
    public static void createIndividualGDPR(List<Contact> listContact) {
        List<Contact> contacts = new List<Contact>();
        for (Contact contact : listContact) {
            if (!contact.XC_SkipInd__c) {
                contacts.add(contact);
            }
        }

        List<Contact> queried = XC_TR_Contact_U_HandleIndividual_D.getEditableContacts(contacts);

        Map<Contact, List<Individual>> indMap = new Map<Contact, List<Individual>>();

        List<Individual> individuals = new List<Individual>();
        List<String> countries = new List<String>();
        for (Contact c : queried) {
            countries.add(c.Account.XC_Country__c);
        }
        Map<String, XC_ConsentDescription__c> consentDescriptionsMap = XC_UTIL_GDPR_D.getConsentDescriptionsByCountry(countries);

        List<XC_UTIL_GDPR.CreateConsentsWrapper> inputWraps = new List<XC_UTIL_GDPR.CreateConsentsWrapper>();

        for (Contact c : queried) {
            if(!c.Account.XC_ConfirmationByCustomer__c){
                continue;
            }
            String consentVersion = consentDescriptionsMap.get(c.Account.XC_Country__c + '§' + c.XC_MainLegalEntity__c) != null ? consentDescriptionsMap.get(c.Account.XC_Country__c + '§' + c.XC_MainLegalEntity__c).XC_ConsentVersion__c : c.XC_ThirdPartiesConsentVersion__c;
            XC_UTIL_GDPR.CreateConsentsWrapper currWrap = new XC_UTIL_GDPR.CreateConsentsWrapper();
            currWrap.personalInfo.theContactAccount = c.Account;
            currWrap.personalInfo.theContact = c;
            currWrap.personalInfo.theContactIndividual = null;
            currWrap.personalInfo.currentLE = c.XC_MainLegalEntity__c;
            currWrap.personalInfo.countryLE = c.Account.XC_Country__c;
            currWrap.personalInfo.confirmationByTheCustomer = c.Account.XC_ConfirmationByCustomer__c;
            currWrap.marketingConsent.consentValue = null;
            currWrap.marketingConsent.consentVersion = consentVersion;
            currWrap.marketingConsent.leCollectedConsent = c.XC_MainLegalEntity__c;
            currWrap.marketingConsent.collectionDate = Date.today();
            currWrap.marketingConsent.collectionChannel = 'Internal User';
            currWrap.marketingConsent.collectionUser = UserInfo.getUserId();

            currWrap.profilingConsent.consentValue = null;
            currWrap.profilingConsent.consentVersion = consentVersion;
            currWrap.profilingConsent.leCollectedConsent = c.XC_MainLegalEntity__c;
            currWrap.profilingConsent.collectionDate = Date.today();
            currWrap.profilingConsent.collectionChannel = 'Internal User';
            currWrap.profilingConsent.collectionUser = UserInfo.getUserId();

            currWrap.thirdPartiesConsent.consentValue = c.XC_GiveDataToThirdParties__c;
            currWrap.thirdPartiesConsent.consentVersion = consentVersion;
            currWrap.thirdPartiesConsent.leCollectedConsent = c.XC_MainLegalEntity__c;
            currWrap.thirdPartiesConsent.collectionDate = Date.today();
            currWrap.thirdPartiesConsent.collectionChannel = 'Internal User';
            currWrap.thirdPartiesConsent.collectionUser = UserInfo.getUserId();

            inputWraps.add(currWrap);

        }

        XC_UTIL_GDPR.createConsents(inputWraps);

    }


}