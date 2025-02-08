/**
* @author Donato Lombardi - dolombardi@deloitte.it
* @date Creation 15/10/2019
* @date Modification dd/mm/yyyy
* @description Update the information of the Legal Entity Consents from the individual
**/
public with sharing class XC_TR_Individual_U_UpdateLEConsents {
    
    
    /**
    * @author Donato Lombardi
    * @date Creation 07/10/2019
    * @description method onAfterInsert
    * @param oldIndiMap Map<ID, Individual>
    * @param newIndiMap Map<ID, Individual>
    */
    public static void updateConsents(Map<ID, Individual> oldIndiMap, Map<ID, Individual> newIndiMap){
        Map<Id,Individual> newMapIndividual = new Map<Id,Individual>();
        List<XC_LegalEntityConsent__c> listLegalEntityConsents = new List<XC_LegalEntityConsent__c>();
        List<XC_LegalEntityConsent__c> listToUpdate = new List<XC_LegalEntityConsent__c>();
        newMapIndividual = checkValueIsChange(oldIndiMap,newIndiMap);
        if(!newMapIndividual.isEmpty()) {
            listLegalEntityConsents = retriveLegalConsensts(newMapIndividual);
            listToUpdate = changeField(newMapIndividual, listLegalEntityConsents);
            updateRecord(listToUpdate);
        }   
    }
    

    private static Map<Id,Individual> checkValueIsChange(Map<ID, Individual> oldIndiMap, Map<ID, Individual> newIndiMap){
        Map<Id,Individual> newMapIndividual = new Map<Id,Individual>();
        for(Individual newI : newIndiMap.values()){
            for(Individual oldI : oldIndiMap.values()){
                //if(newI.XC_GiveDataToThirdParties__c == 'Yes' && oldI.XC_GiveDataToThirdParties__c != 'Yes'){
                if(newI.XC_GiveDataToThirdParties__c != oldI.XC_GiveDataToThirdParties__c && newI.XC_GiveDataToThirdParties__c != null){
                    newMapIndividual.put(newI.id,newI);
                }
            } 
        }
        return newMapIndividual;
    }
    
    private static List<XC_LegalEntityConsent__c> retriveLegalConsensts(Map<ID, Individual> newMapIndividual){
        List<XC_LegalEntityConsent__c> listLegalConsents = new List<XC_LegalEntityConsent__c>();
        if(Schema.sObjectType.XC_LegalEntityConsent__c.isAccessible()){
            listLegalConsents = [select id, XC_MarketingConsent__c, XC_MarketingConsentVersion__c, XC_ProfilingConsent__c, XC_Individual__c from XC_LegalEntityConsent__c WHERE
                                 XC_Individual__c IN :newMapIndividual.keySet()];
        }
        return listLegalConsents;     
    }
    
    private static List<XC_LegalEntityConsent__c> changeField(Map<ID, Individual> newMapIndividual, List<XC_LegalEntityConsent__c> listLegalConsents){
        List<XC_LegalEntityConsent__c> listToUpdate = new List<XC_LegalEntityConsent__c>();
        for(Individual i :newMapIndividual.values()){
            for(XC_LegalEntityConsent__c le : listLegalConsents){
                if(i.id == le.XC_Individual__c && String.isBlank(le.XC_MarketingConsent__c)){
                    le.XC_MarketingConsent__c = i.XC_GiveDataToThirdParties__c != null ? i.XC_GiveDataToThirdParties__c : null;
                    le.XC_LECollectedMarketingConsents__c = i.XC_LECollectedThirdParties__c != null ? i.XC_LECollectedThirdParties__c : null ;
                    le.XC_CollectionDateMarketing__c = i.XC_CollectionDateThirdParties__c != null ? i.XC_CollectionDateThirdParties__c : null;
                    le.XC_CollectionChannelMarketing__c = i.XC_CollectionChannelThirdParties__c != null ? i.XC_CollectionChannelThirdParties__c  : null ;
                    le.XC_CollectionUserMarketing__c = i.XC_CollectionUserThirdParties__c != null ? i.XC_CollectionUserThirdParties__c : null;
                    le.XC_MarketingConsentVersion__c = checkNullString(i.XC_ThirdPartyConsentVersion__c); //i.XC_ThirdPartyConsentVersion__c != null ? i.XC_ThirdPartyConsentVersion__c : null;
                   
                    listToUpdate.add(le);
                }
            }
        }
        return listToUpdate;
        
    }
    
    private static void updateRecord(List<XC_LegalEntityConsent__c> listToUpdate){
        if(Schema.sObjectType.XC_LegalEntityConsent__c.isUpdateable() && !listToUpdate.isEmpty()){
            update listToUpdate;
        }
    }
    
    private static String checkNullString(String thirdParty){
        String consentVersion = '';
        if(thirdParty != Null){
            consentVersion = thirdParty;
        }
        return consentVersion;
    }
    
}