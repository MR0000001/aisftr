/**
* @author dpalamides
* @date 11/10/2019
* @description classes.XC_UTIL_GDPR 
*/
public without sharing class XC_UTIL_GDPR { 

    /**
    * @author dpalamides
    * @date 11/10/2019
    * @description Used to store information about the Consents
    */
    public Class CreateConsentsWrapper {
        public ContactFieldsWrapper personalInfo = new ContactFieldsWrapper();

        public ConsentFieldsWrapper thirdPartiesConsent = new ConsentFieldsWrapper(); 
        public ConsentFieldsWrapper marketingConsent = new ConsentFieldsWrapper();
        public ConsentFieldsWrapper profilingConsent = new ConsentFieldsWrapper(); 
        public ConsentFieldsWrapper notCustomerConsent = new ConsentFieldsWrapper();
        public ConsentFieldsWrapper thPartiesMarketingConsent = new ConsentFieldsWrapper(); 

        /**
        * @author dpalamides
        * @date 11/10/2019
        * @description sets the consent version
        * @param correctVersion XC_ConsentDescription__c
        */
        public void setConsentVersion(XC_ConsentDescription__c correctVersion) {
            if (correctVersion != null) {
                this.thirdPartiesConsent.consentVersion = correctVersion.XC_ConsentVersion__c;
                this.marketingConsent.consentVersion = correctVersion.XC_ConsentVersion__c;
                this.profilingConsent.consentVersion = correctVersion.XC_ConsentVersion__c;

                this.thirdPartiesConsent.consentDescriptionLookup = correctVersion.Id;
                this.marketingConsent.consentDescriptionLookup = correctVersion.Id;
                this.profilingConsent.consentDescriptionLookup = correctVersion.Id;
            }
        }

        /**
        * @author dpalamides
        * @date 11/10/2019
        * @description creates new Individual object
        * @return Individual
        */
        public Individual getNewIndividual() {
            Individual ind = new Individual();
            if (this.personalInfo.theContact != null) {
                ind.FirstName = this.personalInfo.theContact.FirstName;
                ind.LastName = this.personalInfo.theContact.LastName;
                ind.XC_ChildContact__c = this.personalInfo.theContact.id;
                ind.Contact__c = this.personalInfo.theContact.id;
                this.personalInfo.theContact.Individual = ind;
            } else {
                ind.FirstName = this.personalInfo.theLead.FirstName;
                ind.LastName = this.personalInfo.theLead.LastName;
                this.personalInfo.theLead.Individual = ind;
            }


            ind.XC_GiveDataToThirdParties__c = this.thirdPartiesConsent.consentValue;
            ind.XC_LECollectedThirdParties__c = this.personalInfo.currentLE;
            ind.XC_CollectionDateThirdParties__c = this.thirdPartiesConsent.collectionDate;
            ind.XC_CollectionChannelThirdParties__c = this.thirdPartiesConsent.collectionChannel;
            ind.XC_CollectionUserThirdParties__c = this.thirdPartiesConsent.collectionUser;
            ind.XC_ThirdPartyConsentVersion__c = this.thirdPartiesConsent.consentVersion;
            ind.XC_ConsentDescription__c = this.thirdPartiesConsent.consentDescriptionLookup;
            this.personalInfo.theContactIndividual = ind;
            return ind;
        }

        /**
        * @author dpalamides
        * @date 11/10/2019
        * @description update Individual object
        * @return Individual
        */
        public Individual updateExistingIndividual() {
            this.personalInfo.theContactIndividual.XC_GiveDataToThirdParties__c = this.thirdPartiesConsent.consentValue; 
            if (this.personalInfo.theContactIndividual.XC_LECollectedThirdParties__c == null) {
                this.personalInfo.theContactIndividual.XC_LECollectedThirdParties__c = this.personalInfo.currentLE;
                this.personalInfo.theContactIndividual.XC_CollectionDateThirdParties__c = this.thirdPartiesConsent.collectionDate;
                this.personalInfo.theContactIndividual.XC_CollectionChannelThirdParties__c = this.thirdPartiesConsent.collectionChannel;
                this.personalInfo.theContactIndividual.XC_CollectionUserThirdParties__c = this.thirdPartiesConsent.collectionUser;
                this.personalInfo.theContactIndividual.XC_ThirdPartyConsentVersion__c = this.thirdPartiesConsent.consentVersion;
                this.personalInfo.theContactIndividual.XC_ConsentDescription__c = this.thirdPartiesConsent.consentDescriptionLookup;
            }
            return this.personalInfo.theContactIndividual;
        }

        /**
        * @author dpalamides
        * @date 11/10/2019
        * @description creates new XC_LegalEntityConsent__c object for the given LE
        * @param le the legal entity of the consents
        * @return XC_LegalEntityConsent__c
        */
        public XC_LegalEntityConsent__c getNewLegalEntityConsent(String le) {
            XC_LegalEntityConsent__c legalEntity = new XC_LegalEntityConsent__c();
            legalEntity.XC_Individual__c = this.personalInfo.theContact != null ? this.personalInfo.theContact.individualId : this.personalInfo.theLead.individualId;
            legalEntity.XC_GiveDataToNew__c = 'Yes';//this.personalInfo.theContact.XC_GiveDataToNew__c;
            legalEntity.XC_LegalEntity__c = le;
            legalEntity.XC_LeCountry__c = this.personalInfo.countryLE;

            legalEntity.XC_CompanyConsentVersion__c = this.thirdPartiesConsent.consentVersion;

            legalEntity.XC_MarketingConsent__c = this.marketingConsent.consentValue;//this.personalInfo.theContactIndividual.XC_GiveDataToThirdParties__c == 'Yes' ? 'Yes' : this.marketingConsent.consentValue;
            legalEntity.XC_LECollectedMarketingConsents__c = this.personalInfo.currentLE;
            legalEntity.XC_CollectionDateMarketing__c = this.marketingConsent.collectionDate;
            legalEntity.XC_CollectionChannelMarketing__c = this.marketingConsent.collectionChannel;
            legalEntity.XC_CollectionUserMarketing__c = this.marketingConsent.collectionUser;
            legalEntity.XC_MarketingConsentVersion__c = this.marketingConsent.consentVersion;
            legalEntity.XC_ConsentDescription__c = this.marketingConsent.consentDescriptionLookup;

            legalEntity.XC_ProfilingConsent__c = this.profilingConsent.consentValue;
            legalEntity.XC_LECollectedProfilingConsents__c = this.personalInfo.currentLE;
            legalEntity.XC_CollectionDateProfiling__c = this.profilingConsent.collectionDate;
            legalEntity.XC_CollectionChannelProfiling__c = this.profilingConsent.collectionChannel;
            legalEntity.XC_CollectionUserProfiling__c = this.profilingConsent.collectionUser;
            legalEntity.XC_ProfilingConsentVersion__c = this.profilingConsent.consentVersion;
            legalEntity.XC_ConsentDescription__c = this.marketingConsent.consentDescriptionLookup;

            if(String.isNotBlank(this.notCustomerConsent.consentDescriptionLookup)) {
                legalEntity.XC_NotCustomerConsent__c = this.notCustomerConsent.consentValue;
                legalEntity.XC_LECollectedNotCustomerConsents__c = this.personalInfo.currentLE;
                legalEntity.XC_CollectionDateNotCustomer__c = this.notCustomerConsent.collectionDate;
                legalEntity.XC_CollectionChannelNotCustomer__c = this.notCustomerConsent.collectionChannel;
                legalEntity.XC_CollectionUserNotCustomer__c = this.notCustomerConsent.collectionUser;
                legalEntity.XC_NotCustomerConsentVersion__c = this.notCustomerConsent.consentVersion;
                legalEntity.XC_ConsentDescription__c = this.marketingConsent.consentDescriptionLookup;
            }

            if(String.isNotBlank(this.thPartiesMarketingConsent.consentDescriptionLookup)) {
                legalEntity.XC_ThirdProductsMarketingConsent__c = this.thPartiesMarketingConsent.consentValue;
                legalEntity.XC_LECollectedThirdProductsMarketingCons__c = this.personalInfo.currentLE;
                legalEntity.XC_CollectionDateThirdProductsMarketing__c = this.thPartiesMarketingConsent.collectionDate;
                legalEntity.XC_CollectionChannelThirdProdMarketing__c = this.thPartiesMarketingConsent.collectionChannel;
                legalEntity.XC_CollectionUserThirdProductsMarketing__c = this.thPartiesMarketingConsent.collectionUser;
                legalEntity.XC_ThirdProductsMarketingConsentVersion__c = this.thPartiesMarketingConsent.consentVersion;
                legalEntity.XC_ConsentDescription__c = this.marketingConsent.consentDescriptionLookup;
            }

            return legalEntity;
        }

        /**
        * @author dpalamides
        * @date 11/10/2019
        * @description updates  XC_LegalEntityConsent__c object for the given LE
        * @param legalEntity the legal entity consents
        * @return XC_LegalEntityConsent__c
        */
        public XC_LegalEntityConsent__c updateLegalEntityConsent(XC_LegalEntityConsent__c legalEntity) {
            legalEntity.XC_GiveDataToNew__c = 'Yes';

            legalEntity.XC_MarketingConsent__c = this.marketingConsent.consentValue;//this.personalInfo.theContactIndividual.XC_GiveDataToThirdParties__c == 'Yes' ? 'Yes' : this.marketingConsent.consentValue;
            legalEntity.XC_LECollectedMarketingConsents__c = this.personalInfo.currentLE;
            legalEntity.XC_CollectionDateMarketing__c = this.marketingConsent.collectionDate;
            legalEntity.XC_CollectionChannelMarketing__c = this.marketingConsent.collectionChannel;
            legalEntity.XC_CollectionUserMarketing__c = this.marketingConsent.collectionUser;
            legalEntity.XC_MarketingConsentVersion__c = this.marketingConsent.consentVersion;
            legalEntity.XC_ConsentDescription__c = this.marketingConsent.consentDescriptionLookup;

            legalEntity.XC_ProfilingConsent__c = this.profilingConsent.consentValue;
            legalEntity.XC_LECollectedProfilingConsents__c = this.personalInfo.currentLE;
            legalEntity.XC_CollectionDateProfiling__c = this.profilingConsent.collectionDate;
            legalEntity.XC_CollectionChannelProfiling__c = this.profilingConsent.collectionChannel;
            legalEntity.XC_CollectionUserProfiling__c = this.profilingConsent.collectionUser;
            legalEntity.XC_ProfilingConsentVersion__c = this.profilingConsent.consentVersion;

            if(String.isNotBlank(this.notCustomerConsent.consentDescriptionLookup)) {
                legalEntity.XC_NotCustomerConsent__c = this.notCustomerConsent.consentValue;
                legalEntity.XC_LECollectedNotCustomerConsents__c = this.personalInfo.currentLE;
                legalEntity.XC_CollectionDateNotCustomer__c = this.notCustomerConsent.collectionDate;
                legalEntity.XC_CollectionChannelNotCustomer__c = this.notCustomerConsent.collectionChannel;
                legalEntity.XC_CollectionUserNotCustomer__c = this.notCustomerConsent.collectionUser;
                legalEntity.XC_NotCustomerConsentVersion__c = this.notCustomerConsent.consentVersion;
                legalEntity.XC_ConsentDescription__c = this.marketingConsent.consentDescriptionLookup;
            }

            if(String.isNotBlank(this.thPartiesMarketingConsent.consentDescriptionLookup)) {
                legalEntity.XC_ThirdProductsMarketingConsent__c = this.thPartiesMarketingConsent.consentValue;
                legalEntity.XC_LECollectedThirdProductsMarketingCons__c = this.personalInfo.currentLE;
                legalEntity.XC_CollectionDateThirdProductsMarketing__c = this.thPartiesMarketingConsent.collectionDate;
                legalEntity.XC_CollectionChannelThirdProdMarketing__c = this.thPartiesMarketingConsent.collectionChannel;
                legalEntity.XC_CollectionUserThirdProductsMarketing__c = this.thPartiesMarketingConsent.collectionUser;
                legalEntity.XC_ThirdProductsMarketingConsentVersion__c = this.thPartiesMarketingConsent.consentVersion;
                legalEntity.XC_ConsentDescription__c = this.marketingConsent.consentDescriptionLookup;
            }

            return legalEntity;
        }
    }

    /**
    * @author dpalamides
    * @date 11/10/2019
    * @description fields regarding a single type of consent
    */
    public Class ConsentFieldsWrapper {
        public String consentValue;
        public String consentVersion;
        public String leCollectedConsent;
        public Date collectionDate;
        public String collectionChannel;
        public String collectionUser;
        public Id consentDescriptionLookup;
        
        public String VersionConsentCompany;
        public Date ConsentCompanyDate;
        public String VersionConsentMarketing;
        public Date ConsentMarketingDate;
        public String VersionConsentForProfiling;
        public Date ConsentProfilingDate;
        public String PreferredContactMethod;


    }

    /**
    * @author dpalamides
    * @date 11/10/2019
    * @description fields regarding the contact related to the consents
    */
    public Class ContactFieldsWrapper {
        public Contact theContact;
        public Lead theLead;
        public String currentLE;
        public String countryLE;
        public Individual theContactIndividual;
        public Account theContactAccount;
        public Boolean confirmationByTheCustomer;

    }

    /**
    * @author mcutillo
    * @date 31/03/20209
    * @param inputWraps List<CreateConsentsWrapper>
    * @description the method manages the creation of the consents records
    * @return String error message
    */
    public static String createConsents(List<CreateConsentsWrapper> inputWraps) {
        return checkResultDML(createConsentsResults(inputWraps));
    }

    /**
    * @author dpalamides
    * @date 11/10/2019
    * @param inputWraps List<CreateConsentsWrapper>
    * @description the method manages the creation of the consents records
    * @return WrapperResult list
    */
    public static List<XC_UTIL_Sobject.WrapperResult> createConsentsResults(List<CreateConsentsWrapper> inputWraps) {
        List<Individual> individualsToInsert = new List<Individual>(); //key: contactId
        //Map<Id, List<XC_LegalEntityConsent__c>> legalEntityConsentsToInsertMap = new Map<Id, List<XC_LegalEntityConsent__c>>(); //key: contactId
        List<XC_LegalEntityConsent__c> legalEntityConsentsToInsertList = new List<XC_LegalEntityConsent__c>();

        List<String> legalEntitiesList = getLegalEntitiesList(inputWraps);
        List<String> countryList = getCountriesList(inputWraps);
        Map<String, String> leGroupMap = getLegalEntityGroupAssociations(legalEntitiesList);
        Map<String, List<String>> siblingLE = XC_UTIL_GDPR_D.getSiblingLegalEntities(legalEntitiesList); //key:Name of the Group  /  values: list of LEs in the group
        Map<Id, Map<String, XC_LegalEntityConsent__c>> existingLE = XC_UTIL_GDPR_D.getExistingLegalEntitiesConsents(getIndividualList(inputWraps));

        Map<String, XC_ConsentDescription__c> consentDescriptionsMap = XC_UTIL_GDPR_D.getConsentDescriptions(countryList, legalEntitiesList);
        //Map<Id, Contact> contactsMap = XC_UTIL_GDPR_D.getContacts(getAccountsList(inputWraps));
        Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact>();
        Map<Id, Lead> leadsToUpdateMap = new Map<Id, Lead>();
        List<Account> accountsToUpdate = new List<Account>();
        List<Lead> leadToInsertFromDataLoader = new List<Lead>();
        Boolean hasCustomerConfirmation = true;
        for (CreateConsentsWrapper currWrap : inputWraps) {
            Boolean isAccount = currWrap.personalInfo.theContactAccount != null && currWrap.personalInfo.theContactAccount.Id != null;

            if (isAccount) {
                hasCustomerConfirmation = (currWrap.personalInfo.confirmationByTheCustomer!=null && currWrap.personalInfo.confirmationByTheCustomer==true) || currWrap.profilingConsent.collectionChannel != 'Internal User';
            }

            String countryVal = currWrap.personalInfo.countryLE;

            XC_ConsentDescription__c correctVersion = consentDescriptionsMap.get(countryVal + '§' + currWrap.personalInfo.currentLE);

            if (correctVersion != null) {
                if(currWrap.marketingConsent==null||currWrap.marketingConsent.consentVersion==null){
                    currWrap.marketingConsent.consentVersion = correctVersion.XC_ConsentVersion__c;
                    currWrap.marketingConsent.consentDescriptionLookup = correctVersion.Id;
                }

                if(currWrap.thirdPartiesConsent==null||currWrap.thirdPartiesConsent.consentVersion==null){
                    currWrap.thirdPartiesConsent.consentVersion = correctVersion.XC_ConsentVersion__c;
                    currWrap.thirdPartiesConsent.consentDescriptionLookup = correctVersion.Id;
                }

                if(currWrap.profilingConsent==null||currWrap.profilingConsent.consentVersion==null){
                    currWrap.profilingConsent.consentVersion = correctVersion.XC_ConsentVersion__c;
                    currWrap.profilingConsent.consentDescriptionLookup = correctVersion.Id;
                }

                if(currWrap.notCustomerConsent ==null||currWrap.notCustomerConsent.consentVersion==null){
                    currWrap.notCustomerConsent.consentVersion = correctVersion.XC_ConsentVersion__c;
                    currWrap.notCustomerConsent.consentDescriptionLookup = correctVersion.Id;
                }

                if(currWrap.thPartiesMarketingConsent ==null||currWrap.thPartiesMarketingConsent.consentVersion==null){
                    currWrap.thPartiesMarketingConsent.consentVersion = correctVersion.XC_ConsentVersion__c;
                    currWrap.thPartiesMarketingConsent.consentDescriptionLookup = correctVersion.Id;
                }
            }

            //currWrap.setConsentVersion(consentDescriptionsMap.get(countryVal + '§' + currWrap.personalInfo.currentLE)); 

            Individual currIndividual = currWrap.personalInfo.theContactIndividual;
            if (currIndividual == null && hasCustomerConfirmation) {
                currIndividual = currWrap.getNewIndividual();
                individualsToInsert.add(currIndividual);

                putObjectToUpdateIntoMap(contactsToUpdateMap, leadsToUpdateMap, leadToInsertFromDataLoader, currWrap);
                //contactsToUpdateMap.put(currWrap.personalInfo.theContact.Id,currWrap.personalInfo.theContact);
            } else if(currIndividual != null){
                currIndividual = currWrap.updateExistingIndividual();
                Boolean checkIfExist = false;
                for(Individual ind :individualsToInsert){
                    if(currIndividual.id == ind.id){
                        checkIfExist = true;
                        break;
                    }
                }
                if(!checkIfExist){
                       individualsToInsert.add(currIndividual);
                }
            }
        }
        //insert individualsToInsert.values();
        XC_TR_Individual_U_CaringManagement.SKIP_CASE_CREATION = true;
        List<XC_UTIL_Sobject.WrapperResult> indivUpsertRes = XC_UTIL_Sobject.upsertListRecords(individualsToInsert);
        if (checkResultDML(indivUpsertRes) != null) {
            //return upsertResult;
            return indivUpsertRes;
        }

        updateContactsAndLeads(contactsToUpdateMap.values(), leadsToUpdateMap.values(),  leadToInsertFromDataLoader);

        for (CreateConsentsWrapper currWrap : inputWraps) {
            if(currWrap.personalInfo.theContactIndividual==null){
                continue;
            }
            String le = currWrap.personalInfo.currentLE;
            Boolean isAccount = currWrap.personalInfo.theContactAccount != null && currWrap.personalInfo.theContactAccount.Id != null;
            hasCustomerConfirmation = true;
            if (isAccount) {
                accountsToUpdate.add(setAccountGiveConsentsFields(currWrap.personalInfo.theContactAccount, currWrap.personalInfo, leGroupMap));
                hasCustomerConfirmation = (currWrap.personalInfo.confirmationByTheCustomer!=null && currWrap.personalInfo.confirmationByTheCustomer==true) || currWrap.profilingConsent.collectionChannel != 'Internal User';
            }

            //***** dpalamides uncomment for loop to create a legal entity consent for each LE in the group
            //for (String le : siblingLE.get(currWrap.personalInfo.currentLE)) {
            Map<String, XC_LegalEntityConsent__c> leList = existingLE.get(currWrap.personalInfo.theContactIndividual.Id);

            XC_LegalEntityConsent__c newLegalEntityConsent = getLegalEntityConsent(currWrap, leList, le);

            //if (legalEntityConsentsToInsertMap.get(currWrap.personalInfo.theContact.Id) == null) {
            //    legalEntityConsentsToInsertMap.put(currWrap.personalInfo.theContact.Id, new List<XC_LegalEntityConsent__c>());
            //}
            //legalEntityConsentsToInsertMap.get(currWrap.personalInfo.theContact.Id).add(newLegalEntityConsent);

            if(hasCustomerConfirmation || newLegalEntityConsent.Id!=null){
                legalEntityConsentsToInsertList.add(newLegalEntityConsent);
            }

            //}
        }
        //update accountsToUpdate;
        XC_UTIL_Sobject.updateListRecords(accountsToUpdate);
        //return checkResultDML(XC_UTIL_Sobject.upsertListRecords(legalEntityConsentsToInsertList));
        return XC_UTIL_Sobject.upsertListRecords(legalEntityConsentsToInsertList);
    }

    private static Map<String, String> getLegalEntityGroupAssociations(List<String> leList) {
        Map<String, String> ret = new Map<String, String>();
        List<XC_CM_CountryLegalEntityAssociation__mdt> allMetadata = new List<XC_CM_CountryLegalEntityAssociation__mdt>();
        if (Schema.sObjectType.XC_CM_CountryLegalEntityAssociation__mdt.isAccessible()) {
            allMetadata = [
                    select Id,XC_LegalEntity__c, XC_Country__c, XC_LegalEntityGroup__c,DeveloperName
                    from XC_CM_CountryLegalEntityAssociation__mdt
                    Where XC_LegalEntity__c in :leList
            ];
        }
        for (XC_CM_CountryLegalEntityAssociation__mdt le : allMetadata) {
            ret.put(le.XC_LegalEntity__c, le.XC_LegalEntityGroup__c);
        }
        return ret;
    }

    private static XC_LegalEntityConsent__c getLegalEntityConsent(CreateConsentsWrapper currWrap, Map<String, XC_LegalEntityConsent__c> leList, String le) {
        XC_LegalEntityConsent__c newLegalEntityConsent;
        if (leList == null || !leList.containsKey(le)) {
            newLegalEntityConsent = currWrap.getNewLegalEntityConsent(le);
        } else {
            newLegalEntityConsent = currWrap.updateLegalEntityConsent(leList.get(le));
        }
        return newLegalEntityConsent;
    }

    private static String checkResultDML(List<XC_UTIL_Sobject.WrapperResult> res) {
        for (XC_UTIL_Sobject.WrapperResult currRes : res) {
            if (!currRes.success) {
                return currRes.errorMessage;
            }
        }
        return null;
    }

    private static List<String> getLegalEntitiesList(List<CreateConsentsWrapper> inputWraps) {
        List<String> ret = new List<String>();
        for (CreateConsentsWrapper currWrap : inputWraps) {
            ret.add(currWrap.personalInfo.currentLE);
        }
        return ret;
    }

    private static List<String> getCountriesList(List<CreateConsentsWrapper> inputWraps) {
        List<String> ret = new List<String>();
        for (CreateConsentsWrapper currWrap : inputWraps) {
            ret.add(currWrap.personalInfo.countryLE);
        }
        return ret;
    }

    private static List<Individual> getIndividualList(List<CreateConsentsWrapper> inputWraps) {
        List<Individual> ret = new List<Individual>();
        for (CreateConsentsWrapper currWrap : inputWraps) {
            if (currWrap.personalInfo.theContactIndividual != null) {
                ret.add(currWrap.personalInfo.theContactIndividual);
            }
        }
        return ret;
    }

    private static List<Id> getAccountsList(List<CreateConsentsWrapper> inputWraps) {
        List<String> ret = new List<String>();
        for (CreateConsentsWrapper currWrap : inputWraps) {
            ret.add(currWrap.personalInfo.theContactAccount.Id);
        }
        return ret;
    }

    private static void updateContactsAndLeads(List<Contact> contacts, List<Lead> leads, List<Lead> leadToInsertFromDataLoader) {
        for (Contact c : contacts) {
            c.IndividualId = c.Individual.Id;
        }
        XC_UTIL_Sobject.updateListRecords(contacts);

        for (Lead l : leads) {
            l.IndividualId = l.Individual.Id;
        }
        for(Lead l : leadToInsertFromDataLoader){
            l.IndividualId = l.Individual.Id;
        }

    }

    private static void putObjectToUpdateIntoMap(Map<Id, Contact> contactsToUpdateMap, Map<Id, Lead> leadsToUpdateMap, List<Lead> leadToInsertFromDataLoader, CreateConsentsWrapper currWrap) {
        if (currWrap.personalInfo.theContact != null) {
            contactsToUpdateMap.put(currWrap.personalInfo.theContact.Id, currWrap.personalInfo.theContact);
        } else if (currWrap.personalInfo.theLead != null && currWrap.personalInfo.theContactIndividual != null && currWrap.personalInfo.theContactIndividual.Id!= null ) {
            leadsToUpdateMap.put(currWrap.personalInfo.theContactIndividual.Id, currWrap.personalInfo.theLead);
        } else if(currWrap.personalInfo.theLead != null){
            leadToInsertFromDataLoader.add(currWrap.personalInfo.theLead);
        }
    }

    private static Account setAccountGiveConsentsFields(Account theAccount, ContactFieldsWrapper persInfo, Map<String, String> leGroupMap) {
        String le =persInfo.currentLE;
        if(persInfo.confirmationByTheCustomer!=null){
            theAccount.XC_ConfirmationByCustomer__c = persInfo.confirmationByTheCustomer;
        }
        theAccount.put('XC_GiveDataTo_' + le + '__c', true);
        String leGroup = leGroupMap.get(le);
        if (leGroup != null && leGroup!=le) {
            theAccount.put('XC_GiveDataTo_' + leGroup + '__c', true);
            theAccount.put('XC_GiveDataTo_' + le + '__c', false);
        }
        return theAccount;
    }

}