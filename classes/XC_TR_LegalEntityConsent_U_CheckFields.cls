/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/03/2020
* @description XC_TR_LegalEntityConsent_U_CheckFields – Util class to validate inserted/updated Legal Entity Consents
*/  

public without sharing class XC_TR_LegalEntityConsent_U_CheckFields {

    private final static Boolean DEBUGACTIVE = true;//XC_UTIL_Debug.isActive('XC_TR_LegalEntityConsent_U_CheckFields');
    public static Boolean checkAlreadyDone = false;

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 08/04/2020
     * @description Method to populate Consent for Profiling and Marketing
     * @param listNew - List<XC_LegalEntityConsent__c>
    */ 
    public static void populateDateConsent(List<XC_LegalEntityConsent__c> listNew) { 
        for(XC_LegalEntityConsent__c lec : listNew) {
            if(lec.XC_ProfilingConsent__c == Label.XC_CL_YesText) {
                lec.XC_ExpirationDateProfilingConsent__c = Date.today().addMonths(12);
            }
            if(lec.XC_MarketingConsent__c == Label.XC_CL_YesText) {
                lec.XC_ExpirationDateMarketingConsent__c = Date.today().addMonths(24);
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 08/04/2020
     * @description Method to update Consent for Profiling and Marketing
     * @param mapOld - List<XC_LegalEntityConsent__c> 
     * @param mapNew - List<XC_LegalEntityConsent__c> 
    */ 
    public static void updateDateConsent(Map<Id, XC_LegalEntityConsent__c> mapOld, Map<Id, XC_LegalEntityConsent__c> mapNew) { 
        List<XC_LegalEntityConsent__c> listConsentChanged = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_ProfilingConsent__c', 'XC_MarketingConsent__c'}, mapOld, mapNew);
        if(Test.isRunningTest()) {
            return;
        }
        for(XC_LegalEntityConsent__c lec : listConsentChanged) {
            // For Profiling:
            if((String.isBlank(mapOld.get(lec.Id).XC_ProfilingConsent__c) || mapOld.get(lec.Id).XC_ProfilingConsent__c == Label.XC_CL_NoText) && mapNew.get(lec.Id).XC_ProfilingConsent__c == Label.XC_CL_YesText) {
                lec.XC_ExpirationDateProfilingConsent__c = Date.today().addMonths(12);
            } else if(mapOld.get(lec.Id).XC_ProfilingConsent__c == Label.XC_CL_YesText && (String.isBlank(mapNew.get(lec.Id).XC_ProfilingConsent__c) || mapNew.get(lec.Id).XC_ProfilingConsent__c == Label.XC_CL_NoText)) {
                lec.XC_ExpirationDateProfilingConsent__c = null;
            }
            // For Marketing:
            if((String.isBlank(mapOld.get(lec.Id).XC_MarketingConsent__c) || mapOld.get(lec.Id).XC_MarketingConsent__c == Label.XC_CL_NoText) && mapNew.get(lec.Id).XC_MarketingConsent__c == Label.XC_CL_YesText) {
                lec.XC_ExpirationDateMarketingConsent__c = Date.today().addMonths(24);
            } else if(mapOld.get(lec.Id).XC_MarketingConsent__c == Label.XC_CL_YesText && (String.isBlank(mapNew.get(lec.Id).XC_MarketingConsent__c) || mapNew.get(lec.Id).XC_MarketingConsent__c == Label.XC_CL_NoText)) {
                lec.XC_ExpirationDateMarketingConsent__c = null;
            }
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/03/2020
     * @description Method to validate inserted LegalEntityConsent for Adult Only
     * @param mapNew - Map<Id, XC_LegalEntityConsent__c> 
    */ 
    public static void checkAge(Map<Id, XC_LegalEntityConsent__c> mapNew) { 
        if(checkAlreadyDone) {
            return;
        }
        // Retrieve data for Individual:
        List<String> listIndividualIds = new List<String>();
        Map<String, List<XC_LegalEntityConsent__c>> mapLec = new Map<String, List<XC_LegalEntityConsent__c>>();
        for(XC_LegalEntityConsent__c lec : mapNew.values()) {
            if(!mapLec.containsKey(lec.XC_Individual__c)) {
                mapLec.put(lec.XC_Individual__c, new List<XC_LegalEntityConsent__c>());
            }
            mapLec.get(lec.XC_Individual__c).add(lec);
            listIndividualIds.add(lec.XC_Individual__c);
        }
        List<Contact> listContact = new List<Contact>([
            SELECT Id, IndividualId, Account.XC_BirthDate__c, XC_Segment__c
            FROM Contact
            WHERE IndividualId IN :listIndividualIds AND Account.XC_BirthDate__c != null
        ]);
        if(listContact.isEmpty()) {
            return;
        }
        Map<String, List<Date>> mapIndividualBday = new Map<String, List<Date>>();
        Map<String, List<String>> mapIndividualLegalEntity = new Map<String, List<String>>();
        Set<String> setStream = new Set<String>();
        List<String> listAllLE = new List<String>();
        for(Contact cnt : listContact) {
            for(XC_LegalEntityConsent__c lec : mapNew.values()) {
                if(lec.XC_Individual__c == cnt.IndividualId) {
                    if(!mapIndividualBday.containsKey(cnt.IndividualId)) {
                        mapIndividualBday.put(cnt.IndividualId, new List<Date>());
                    }
                    mapIndividualBday.get(cnt.IndividualId).add(cnt.Account.XC_BirthDate__c);
                    if(!mapIndividualLegalEntity.containsKey(cnt.IndividualId)) {
                        mapIndividualLegalEntity.put(cnt.IndividualId, new List<String>());
                    }
                    mapIndividualLegalEntity.get(cnt.IndividualId).add(lec.XC_LegalEntity__c);
                    setStream.add(cnt.XC_Segment__c);
                    listAllLE.add(lec.XC_LegalEntity__c);
                }
            }
        }

        // Retrieve custom metadata for major age for Legal Entity:
        List<XC_CM_LegalEntity_Configuration__mdt> listCMlegalEntity = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_Majority__c, XC_LegalEntity__c, XC_Stream__c
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c IN :listAllLE AND XC_Stream__c IN :setStream AND XC_OrgID__c = :UserInfo.getOrganizationId()
        ]);
        Map<String, Integer> mapLegalEntityAge = new Map<String, Integer>();
        for(XC_CM_LegalEntity_Configuration__mdt cm : listCMlegalEntity) {
            mapLegalEntityAge.put(cm.XC_LegalEntity__c, Integer.valueOf(cm.XC_Majority__c));
        }
        if(mapLegalEntityAge.values().isEmpty()) {
            return;
        }

        // Check for age:
        List<XC_LegalEntityConsent__c> listLecWithError = new List<XC_LegalEntityConsent__c>();
        for(String individualId : mapIndividualBday.keySet()) {
            List<Date> listDate = mapIndividualBday.get(individualId);
            List<String> listLegalEntity = mapIndividualLegalEntity.get(individualId);
            for(Integer i=0; i<listDate.size(); i++) {
                Date birthday = listDate[i];
                String legalEntity = listLegalEntity[i];
                Integer adultAge = mapLegalEntityAge.get(legalEntity);
                Integer currentAge = Math.abs(Integer.valueOf((Date.today().daysBetween(birthday))/365.2425));               
                if(currentAge < adultAge) {
                    listLecWithError.addAll(mapLec.get(individualId));
                }
            }
        }

        // DML operation:
        for(XC_LegalEntityConsent__c lecError : listLecWithError) {
            lecError.addError(Label.XC_CL_ErrorAdultAge);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/03/2020
     * @description Method to chech majority for legal entitity consent
     * @param listLec - List<XC_LegalEntityConsent__c> 
     * @param obj - sObject
    */ 
    public static Boolean checkAge(List<XC_LegalEntityConsent__c> listLec, sObject obj) { 
        if(!obj.getPopulatedFieldsAsMap().containsKey('XC_BirthDate__c')) {
            return true;
        }
        // Retrieve custom metadata for major age for Legal Entity:
        List<String> listLE = XC_UTIL_Sobject.getListFieldValues(listLec, 'XC_LegalEntity__c');
        Set<String> setStream = XC_UTIL_Sobject.getSetIdsStringOnField(new List<Sobject>{obj}, 'XC_Segment__c');
        List<XC_CM_LegalEntity_Configuration__mdt> listCMlegalEntity = new List<XC_CM_LegalEntity_Configuration__mdt>();
        if(setStream.isEmpty()) {
            listCMlegalEntity = [SELECT Id, XC_Majority__c, XC_LegalEntity__c
                                    FROM XC_CM_LegalEntity_Configuration__mdt 
                                    WHERE XC_LegalEntity__c IN :listLE AND XC_OrgId__c =: UserInfo.getOrganizationId()];
        } else {
            listCMlegalEntity = [SELECT Id, XC_Majority__c, XC_LegalEntity__c
                                    FROM XC_CM_LegalEntity_Configuration__mdt 
                                    WHERE XC_LegalEntity__c IN :listLE AND XC_Stream__c IN :setStream AND XC_OrgId__c =: UserInfo.getOrganizationId()];
        }
        
        Map<String, Decimal> mapLeMajority = new Map<String, Decimal>();
        for(XC_CM_LegalEntity_Configuration__mdt cm : listCMlegalEntity) {
            mapLeMajority.put(cm.XC_LegalEntity__c, cm.XC_Majority__c);
        }

        // Chech age:
        for(XC_LegalEntityConsent__c lec : listLec) {
            Date bday = (Date) obj.get('XC_BirthDate__c');
            String legalEntity = lec.XC_LegalEntity__c;
            Decimal adultAge = mapLeMajority.get(legalEntity);
            Integer currentAge = Math.abs(Integer.valueOf((Date.today().daysBetween(bday))/365.2425));               
            if(currentAge < adultAge) {
                return false;
            }
        }
        return true;
    }

}