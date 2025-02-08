/**
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 29/08/2018
 * @date Modification 07/02/2020 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @description XC_TR_Lead_HandleIndividual – Create Individual record linked to Lead
 */

public without sharing class XC_TR_Lead_U_HandleIndividual { 
	
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Lead_U_HandleIndividual');

    /**
     * @author dpalamides
     * @date Creation 23/04/19
     * @param listLead - List<Lead>
     * @description Method to create Individual
     */
    public static void handleIndividualGDPR(List<Lead> listLead) {
        List<Individual> listIndividual = new List<Individual>();
        List<String> listEmail = new List<String>();
        Map<Id, Individual> mapLeadIdIndividual = new Map<Id, Individual>();
        List<String> countries = new List<String>();
        Map<String, XC_ConsentDescription__c> consentDescriptionsMap = XC_UTIL_GDPR_D.getConsentDescriptionsByLegalEntity(countries);
        List<XC_UTIL_GDPR.CreateConsentsWrapper> inputWraps = new List<XC_UTIL_GDPR.CreateConsentsWrapper>();

        for(Lead c : listLead) {
            String consentVersion = consentDescriptionsMap.get(c.XC_Country__c+ '§' + c.XC_MainLegalEntity__c) != null ? consentDescriptionsMap.get(c.XC_Country__c + '§' + c.XC_MainLegalEntity__c).XC_ConsentVersion__c : null;
            XC_UTIL_GDPR.CreateConsentsWrapper currWrap = new XC_UTIL_GDPR.CreateConsentsWrapper();
            currWrap.personalInfo.theContactAccount = null;
            currWrap.personalInfo.theContact = null;
            currWrap.personalInfo.theContactIndividual = null;
            currWrap.personalInfo.theLead = c;
            currWrap.personalInfo.currentLE = c.XC_MainLegalEntity__c;

            currWrap.personalInfo.countryLE = String.isNotBlank(c.XC_Country__c) ? c.XC_Country__c : c.Country__c;

            currWrap.marketingConsent.consentValue = c.XC_GiveDataToMarketing__c;
            currWrap.marketingConsent.consentVersion = consentVersion;
            currWrap.marketingConsent.leCollectedConsent = c.XC_MainLegalEntity__c;
            currWrap.marketingConsent.collectionDate = Date.today();
            currWrap.marketingConsent.collectionChannel = 'Internal User';
            currWrap.marketingConsent.collectionUser = UserInfo.getUserId();
            currWrap.profilingConsent.consentValue = c.XC_GiveDataToProfiling__c;
            currWrap.profilingConsent.consentVersion = consentVersion;
            currWrap.profilingConsent.leCollectedConsent = c.XC_MainLegalEntity__c;
            currWrap.profilingConsent.collectionDate = Date.today();
            currWrap.profilingConsent.collectionChannel = 'Internal User';
            currWrap.profilingConsent.collectionUser = UserInfo.getUserId();

            currWrap.notCustomerConsent.consentValue = c.XC_GiveDataToNotCustomer__c;
            currWrap.notCustomerConsent.consentVersion = consentVersion;
            currWrap.notCustomerConsent.leCollectedConsent = c.XC_MainLegalEntity__c;
            currWrap.notCustomerConsent.collectionDate = Date.today();
            currWrap.notCustomerConsent.collectionChannel = 'Internal User';
            currWrap.notCustomerConsent.collectionUser = UserInfo.getUserId();
            currWrap.thPartiesMarketingConsent.consentValue = c.XC_GiveDataToThirdProductsMarketing__c;
            currWrap.thPartiesMarketingConsent.consentVersion = consentVersion;
            currWrap.thPartiesMarketingConsent.leCollectedConsent = c.XC_MainLegalEntity__c;
            currWrap.thPartiesMarketingConsent.collectionDate = Date.today();
            currWrap.thPartiesMarketingConsent.collectionChannel = 'Internal User';
            currWrap.thPartiesMarketingConsent.collectionUser = UserInfo.getUserId();

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

    /**
     * @author Salvatore Agrillo
     * @date Creation 27/02/2020
     * @param listLead - List<Lead>
     * @param mapOld - Map<Id, Lead>
     * @param mapNew - Map<Id, Lead>
     * @description Method to update Individual fields
     */
    public static void updateIndividual(List<Lead> listLead, Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) {
        List<Lead> listChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'FirstName', 'LastName'}, mapOld, mapNew);
        if(listChanged.isEmpty()) {
            return;
        }
        List<Individual> listIndividualToUpdate = new List<Individual>();
        for(Lead ld : listChanged) {
            listIndividualToUpdate.add(new Individual(
                Id = ld.IndividualId,
                FirstName = mapNew.get(ld.Id).FirstName,
                LastName = mapNew.get(ld.Id).LastName
            ));
        }
        List<XC_UTIL_Sobject.WrapperResult> listWrResult = XC_UTIL_Sobject.updateListRecords(listIndividualToUpdate);
        if(!XC_UTIL_Sobject.checkDMLResults(listWrResult)) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Error to update Individual from Lead -> ' + listWrResult[0].errorMessage);
        }
    }

    /** 
     * @author Sara Miozza - sara.miozza@nttdata.com & Roberta Porrega - roberta.porrega@nttdata.com
     * @param listLead individuals the individuals
     * @date Creation 23/04/19
     * @description create the legal entities
     */
    /*public static void insertLegalEntity(List<Lead> listLead){
        List<id> listLeadId = XC_UTIL_SObject.getIds(listLead);
        Map<Id, Lead> leads = new Map<Id, Lead> ([
            SELECT ID, IndividualId, XC_MainLegalEntity__c
            FROM Lead 
            WHERE Id IN :listLeadId
        ]);
                                                          
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### insert legal for ### ' + leads);
        List<XC_LegalEntityConsent__c> legalEntityList = new List<XC_LegalEntityConsent__c>();
        for(Lead ld : leads.values()){
            if(ld.XC_MainLegalEntity__c==null || ld.XC_MainLegalEntity__c==''){
                continue;
            }
            XC_LegalEntityConsent__c legalEntity = new XC_LegalEntityConsent__c();
            legalEntity.XC_Individual__c = ld.individualId;
            legalEntity.XC_GiveDataToNew__c = 'Yes';
            legalEntity.XC_LegalEntity__c = ld.XC_MainLegalEntity__c;
            legalEntityList.add(legalEntity);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '### insert legal for ### ' + legalEntityList); 
        XC_UTIL_Sobject.insertListRecords(legalEntityList);
    }*/

    /**
     * @description Handle individual
     * @param listLead the list lead
     */
    /*public static void handleIndividual (List<Lead> listLead) {
        List<Individual> listIndividual = new List<Individual>();
        List<String> listEmail = new List<String>();
        Map<Id, Individual> mapLeadIdIndividual = new Map<Id, Individual>();
        for(Lead l : listLead) {
            Individual i = new Individual();
            i.BirthDate = l.XC_Birthdate__c;
            i.FirstName = l.FirstName;
            i.LastName = l.LastName;
            listIndividual.add(i);
            mapLeadIdIndividual.put(l.Id, i);
        }
        XC_UTIL_sObject.insertListRecords(listIndividual);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ listIndividual -> ' + listIndividual);
        for(Lead ld : listLead) {
            ld.IndividualId = mapLeadIdIndividual.get(ld.Id).Id;
        }
        Integer ind = 0;
        for(Individual i : listIndividual) {
            listLead.get(ind).IndividualID = i.ID;
            ind++;
        } 
    }*/

    public static void setLeadOnIndividual(List<Lead> listLead){
        List<Lead> leadToUpdate = new List<Lead>();
        List<Individual> individualToUpdate = new List<Individual>();

        for(Lead l : listLead){
            if((l.XC_Segment__c == 'B2B' || l.XC_Segment__c == 'B2G') && l.XC_MainLegalEntity__c != 'EnelX' && l.XC_MainLegalEntity__c != 'EnelDistribution' && l.XC_MainLegalEntity__c != 'Codensa' && l.IndividualId != null){
                leadToUpdate.add(l);
            }
        }
        if(leadToUpdate.isEmpty()){
            return;
        }
        for(Lead l : leadToUpdate){
            Individual ind = new Individual();
            ind.id = l.IndividualId;
            ind.XC_Lead__c = l.id;
            individualToUpdate.add(ind);
        }
        XC_UTIL_Sobject.updateListRecords(individualToUpdate);


    }

}