/**
* @author dpalamides
* @date 11/10/2019
* @description classes.XC_UTIL_GDPR_D
*/


public without sharing class XC_UTIL_GDPR_D {

    /**
    * @author dpalamides
    * @date 11/10/2019
    * @description getSiblingLegalEntities
    * @param leList List<String>
    * @return Map<String,List<String>>    key:Name of the Group  /  values: list of LEs in the group
    */
    public static Map<String, List<String>> getSiblingLegalEntities(List<String> leList) {
        Map<String, String> groupsLE = new Map<String, String>();
        Map<String, List<String>> retMap = new Map<String, List<String>>();
        //DP 09/12
        List<String> multipick = XC_UTIL_User.getLegalEntitiesFromUser();
        leList.addAll(multipick);
        //////////
        List<XC_CM_CountryLegalEntityAssociation__mdt> allMetadata = new List<XC_CM_CountryLegalEntityAssociation__mdt>();

        if (Schema.sObjectType.XC_CM_CountryLegalEntityAssociation__mdt.isAccessible()) {
            allMetadata = [
                    select Id,XC_LegalEntity__c, XC_Country__c, XC_LegalEntityGroup__c,DeveloperName
                    from XC_CM_CountryLegalEntityAssociation__mdt
                    limit 1000
            ];
        }

        for (XC_CM_CountryLegalEntityAssociation__mdt meta : allMetadata) {
            if (leList.contains(meta.XC_LegalEntity__c)) {
                if (groupsLE.get(meta.XC_LegalEntity__c) == null) {
                    groupsLE.put(meta.XC_LegalEntityGroup__c, meta.XC_LegalEntity__c);
                }
                if (retMap.get(meta.XC_LegalEntity__c) == null) {
                    retMap.put(meta.XC_LegalEntity__c, new List<String>());
                }
            }
        }
        for (XC_CM_CountryLegalEntityAssociation__mdt meta : allMetadata) {
           if (leList.contains(meta.XC_LegalEntity__c)) {
                retMap.get(groupsLE.get(meta.XC_LegalEntityGroup__c)).add(meta.XC_LegalEntity__c);
            }
        }

        return retMap;

    }


    /**
    * @author dpalamides
    * @date 11/10/2019
    * @description getExistingLegalEntities
    * @param individualIdList List<Id>
    * @return Map<Id,List<String>>    key:IndividualId /  values: list of LEs already present
    */
    public static Map<Id, List<String>> getExistingLegalEntities(List<Id> individualIdList) {
        Map<Id, List<String>> retMap = new Map<Id, List<String>>();

        List<XC_LegalEntityConsent__c> allLE = new List<XC_LegalEntityConsent__c>();
        if (Schema.sObjectType.XC_LegalEntityConsent__c.isAccessible()) {
            allLE = [
                    select Id,XC_LegalEntity__c, XC_Individual__c
                    from XC_LegalEntityConsent__c
                    where XC_Individual__c in :individualIdList
            ];
        }

        for (XC_LegalEntityConsent__c le : allLE) {
            if (retMap.get(le.XC_Individual__c) == null) {
                retMap.put(le.XC_Individual__c, new List<String>());
            }
            retMap.get(le.XC_Individual__c).add(le.XC_LegalEntity__c);
        }

        return retMap;

    }

    /**
    * @author dpalamides
    * @date 11/10/2019
    * @description getExistingLegalEntities
    * @param individualIdList List<Individual>
    * @return Map<Id,Map<String,XC_LegalEntityConsent__c>>    key:IndividualId /  values: map of LEs already present indexed by LE
    */
    public static Map<Id, Map<String,XC_LegalEntityConsent__c>> getExistingLegalEntitiesConsents(List<Individual> individualIdList) {
        Map<Id, Map<String,XC_LegalEntityConsent__c>> retMap = new Map<Id, Map<String,XC_LegalEntityConsent__c>>();
        if(individualIdList.isEmpty()){
            return retMap;
        }
        List<XC_LegalEntityConsent__c> allLE = new List<XC_LegalEntityConsent__c>();
        if (Schema.sObjectType.XC_LegalEntityConsent__c.isAccessible()) {
            allLE = [
                    select  Id, IsDeleted, Name, CurrencyIsoCode, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate,
                            LastModifiedById, SystemModstamp, LastActivityDate, XC_Individual__c, XC_LegalEntity__c,
                            XC_LECollectedMarketingConsents__c, XC_MarketingConsent__c, XC_CollectionDateMarketing__c,
                            XC_IndividualLegalEntity__c, XC_IndividualId__c, XC_LeCountry__c, XC_GiveDataToNew__c,
                            XC_UpdateAboutProducts__c, XC_ConsentToDataProcessing__c, XC_CompanyConsentVersion__c,
                            XC_MarketingConsentVersion__c, XC_ProfilingConsentVersion__c, XC_CollectionChannelMarketing__c,
                            XC_CollectionUserMarketing__c, XC_ProfilingConsent__c, XC_LECollectedProfilingConsents__c,
                            XC_CollectionDateProfiling__c, XC_CollectionChannelProfiling__c, XC_CollectionUserProfiling__c, XC_ConsentDescription__c,
                            XC_NotCustomerConsent__c, XC_NotCustomerConsentVersion__c, XC_LECollectedNotCustomerConsents__c, XC_CollectionDateNotCustomer__c, 
                            XC_CollectionChannelNotCustomer__c, XC_CollectionUserNotCustomer__c,  XC_ThirdProductsMarketingConsent__c, XC_ThirdProductsMarketingConsentVersion__c,
                            XC_CollectionChannelThirdProdMarketing__c, XC_CollectionUserThirdProductsMarketing__c, XC_CollectionDateThirdProductsMarketing__c, XC_LECollectedThirdProductsMarketingCons__c
                    from XC_LegalEntityConsent__c
                    where XC_Individual__c in :XC_UTIL_Sobject.getIds(individualIdList)
            ];
        }

        for (XC_LegalEntityConsent__c le : allLE) {
            if (retMap.get(le.XC_Individual__c) == null) {
                retMap.put(le.XC_Individual__c, new Map<String,XC_LegalEntityConsent__c>());
            }
            retMap.get(le.XC_Individual__c).put(le.XC_LegalEntity__c, le);
        }

        return retMap;

    }

    /**
    * @author dpalamides
    * @date 14/10/2019
    * @description getConsentDescriptions
    * @param countryList List<String>
    * @param legalEntityList List<String>
    * @return Map<String, XC_ConsentDescription__c>    key:Country§LegalEntity /  values: Consent Description
    */
    public static Map<String, XC_ConsentDescription__c> getConsentDescriptions(List<String> countryList, List<String> legalEntityList) {
        Map<String, XC_ConsentDescription__c> ret = new Map<String, XC_ConsentDescription__c>();

        List<XC_ConsentDescription__c> allDescr;
        if (Schema.sObjectType.XC_ConsentDescription__c.isAccessible()) {
            allDescr = [SELECT Id,  XC_ConsentVersion__c,XC_DescriptionGiveDataToLE__c, XC_LegalEntity__c, XC_Country__c, XC_ConsentStatus__c,XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c
                           from XC_ConsentDescription__c
                          Where XC_Country__c in :countryList and XC_LegalEntity__c in :legalEntityList and XC_ConsentStatus__c = 'Active' and XC_ParentDescription__c = null];
        }
        else{
            allDescr = new List<XC_ConsentDescription__c>();
        }

        for(XC_ConsentDescription__c descr : allDescr){
            ret.put(descr.XC_Country__c+'§'+descr.XC_LegalEntity__c,descr);
        }
        return ret;
    }


    /**
    * @author dpalamides
    * @date 14/10/2019
    * @description getConsentDescriptionsByCountry
    * @param countryList List<String>
    * @return Map<String, XC_ConsentDescription__c>    key:Country§LegalEntity /  values: Consent Description
    */
    public static Map<String, XC_ConsentDescription__c> getConsentDescriptionsByCountry(List<String> countryList) {
        Map<String, XC_ConsentDescription__c> ret = new Map<String, XC_ConsentDescription__c>();

        List<XC_ConsentDescription__c> allDescr;
        if (Schema.sObjectType.XC_ConsentDescription__c.isAccessible()) {
            allDescr = [SELECT Id,  XC_ConsentVersion__c, XC_DescriptionGiveDataToLE__c, XC_LegalEntity__c, XC_Country__c, XC_ConsentStatus__c, XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c
            from XC_ConsentDescription__c
            Where XC_Country__c in :countryList and XC_ConsentStatus__c = 'Active' and XC_ParentDescription__c = null];
        }
        else{
            allDescr = new List<XC_ConsentDescription__c>();
        }

        for(XC_ConsentDescription__c descr : allDescr){
            ret.put(descr.XC_Country__c+'§'+descr.XC_LegalEntity__c,descr);
        }
        return ret;
    }

    /**
    * @author dpalamides
    * @date 14/10/2019
    * @description getConsentDescriptionsByLegalEntity
    * @param leList List<String>
    * @return Map<String, XC_ConsentDescription__c>    key:Country§LegalEntity /  values: Consent Description
    */
    public static Map<String, XC_ConsentDescription__c> getConsentDescriptionsByLegalEntity(List<String> leList) {
        Map<String, XC_ConsentDescription__c> ret = new Map<String, XC_ConsentDescription__c>();
        Map<String,XC_ConsentDescription__c> langMap = new Map<String,XC_ConsentDescription__c>();
        String currentLanguageLabel = [SELECT LanguageLocaleKey FROM User WHERE ID = :UserInfo.getUserId() LIMIT 1][0].LanguageLocaleKey;

        List<XC_ConsentDescription__c> allDescr;
        if (Schema.sObjectType.XC_ConsentDescription__c.isAccessible()) {
            allDescr = [SELECT Id, XC_PrivacyConsentUrl__c, XC_DescriptionLanguage__c, XC_ParentDescription__c, XC_ConsentVersion__c,XC_DescriptionGiveDataToLE__c, XC_LegalEntity__c, XC_Country__c, XC_ConsentStatus__c, XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c
            from XC_ConsentDescription__c
            Where XC_LegalEntity__c in :leList and XC_ConsentStatus__c = 'Active' and XC_ParentDescription__c = null];

            List<XC_ConsentDescription__c>  langList = [SELECT Id, XC_PrivacyConsentUrl__c, XC_ParentDescription__c, XC_ConsentVersion__c,XC_DescriptionGiveDataToLE__c,
                                                               XC_DescriptionLanguage__c, XC_LegalEntity__c, XC_Country__c, XC_ConsentStatus__c, XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c
                                                            from XC_ConsentDescription__c
                                                            Where XC_ParentDescription__c in :XC_UTIL_Sobject.getListFieldValues(allDescr,'Id')];

            for(XC_ConsentDescription__c d : langList){
                langMap.put(d.XC_ParentDescription__c+d.XC_DescriptionLanguage__c,d);
            }
        }
        else{
            allDescr = new List<XC_ConsentDescription__c>();
        }

        for(XC_ConsentDescription__c descr : allDescr){
            XC_ConsentDescription__c tranlation = langMap.get(descr.Id+currentLanguageLabel);
            if(tranlation!=null) {
                descr.XC_DescriptionThirdParties__c = tranlation.XC_DescriptionThirdParties__c;
                descr.XC_DescriptionProfiling__c = tranlation.XC_DescriptionProfiling__c;
                descr.XC_DescriptionMarketing__c = tranlation.XC_DescriptionMarketing__c;
                descr.XC_DescriptionGiveDataToLE__c = tranlation.XC_DescriptionGiveDataToLE__c;
                descr.XC_DescriptionNotCustomer__c = tranlation.XC_DescriptionNotCustomer__c;
                descr.XC_DescriptionThirdProductsMarketing__c = tranlation.XC_DescriptionThirdProductsMarketing__c;
            }
            ret.put(descr.XC_Country__c+'§'+descr.XC_LegalEntity__c,descr);
        }
        return ret;
    }

    /**
    * @author dpalamides
    * @date 14/10/2019
    * @description getConsentDescriptionsByCountryAndVersion
    * @param leList List<String>
    * @return Map<String, XC_ConsentDescription__c>    key:Country§LegalEntity /  values: Consent Description
    */
    public static Map<String, XC_ConsentDescription__c> getConsentDescriptionsByCountryAndVersion(List<String> leList) {
        Map<String, XC_ConsentDescription__c> ret = new Map<String, XC_ConsentDescription__c>();
        //DP 09/12
        List<String> multipick = XC_UTIL_User.getLegalEntitiesFromUser();
        leList.addAll(multipick);
        //////////
        List<XC_ConsentDescription__c> allDescr;
        if (Schema.sObjectType.XC_ConsentDescription__c.isAccessible()) {
            List<XC_CM_CountryLegalEntityAssociation__mdt> retList4Group = [
                    SELECT Id, DeveloperName, Label, XC_LegalEntity__c, XC_Country__c,XC_LegalEntityGroup__c
                    from XC_CM_CountryLegalEntityAssociation__mdt
                    where XC_LegalEntity__c in :leList
            ];

            List<XC_CM_CountryLegalEntityAssociation__mdt> leListAll = [
                    SELECT Id, DeveloperName, Label, XC_LegalEntity__c, XC_Country__c,XC_LegalEntityGroup__c
                    from XC_CM_CountryLegalEntityAssociation__mdt
                    where XC_LegalEntityGroup__c in :XC_UTIL_Sobject.getListFieldValues(retList4Group,'XC_LegalEntityGroup__c')
            ];

            allDescr = [SELECT Id,  XC_ConsentVersion__c, XC_DescriptionGiveDataToLE__c, XC_LegalEntity__c, XC_Country__c, XC_ConsentStatus__c, XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c
            from XC_ConsentDescription__c
            Where  XC_ParentDescription__c = null and XC_LegalEntity__c in :XC_UTIL_Sobject.getListFieldValues(leListAll,'XC_LegalEntity__c')];
        }
        else{
            allDescr = new List<XC_ConsentDescription__c>();
        }

        for(XC_ConsentDescription__c descr : allDescr){
            //ret.put(descr.XC_Country__c+'§'+descr.XC_LegalEntity__c+'§'+descr.XC_ConsentVersion__c,descr);
            ret.put(descr.Id,descr);
        }
        return ret;
    }


    /**
    * @author dpalamides
    * @date 17/10/2019
    * @description getContacts
    * @param accountList List<Id>
    * @return Map<Id, Contact>
    */
    public static Map<Id, Contact> getContacts(List<Id> accountList) {
        Map<Id, Contact> ret = new Map<Id, Contact>();
        if (Schema.sObjectType.Contact.isAccessible()) {
            ret.putAll([
                    SELECT Id, IndividualId
                    from Contact
                    Where AccountId in :accountList
            ]);
        }

        return ret;
    }

}