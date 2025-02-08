/**
* @author dpalamides
* @date 22/10/2019
* @description classes.XC_LCC163_CreateConsents_U
*/
public with sharing class XC_LCC163_CreateConsents_U {

    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description getExistingConsentVersion
    * @param theIndividual Individual
    * @param defVersion String
    * @return String
    */
    public static String getExistingConsentVersion(Individual theIndividual, String defVersion) {
        String consentVersion = theIndividual.XC_ThirdPartyConsentVersion__c;
        if (consentVersion == null) {
            return defVersion;
        } else {
            return consentVersion;
        }
    }

    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description getCurrUser
    * @return User
    */
    public static User getCurrUser(){
        try{
            return [select id,XC_LegalEntity__c from User where Id = :UserInfo.getUserId()];
        }catch(Exception e){
            return null;
        }
    }

    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description getAccount
    * @param recordId String
    * @param objectType String
    * @param sObjectData String
    * @return Account
    */
    public static Account getAccount(String recordId, String objectType, String sObjectData) {
        if (!Schema.sObjectType.Account.isAccessible() || !Schema.sObjectType.Contact.isAccessible()) {
            return null;
        }
        Account theAccount = null;
        if (recordId != null) {

            try {
                if (XC_UTIL_Sobject.getObjectType(recordId) == 'Account') {
                    theAccount = [select Id, name, XC_ConfirmationByCustomer__c, XC_Country__c from Account where Id = :recordId];
                } else {
                    theAccount = [select Id, name, XC_ConfirmationByCustomer__c, XC_Country__c from Account where Id in (select AccountId from Contact where id = :recordId) limit 1];
                }
            } catch (Exception e) {
                return null;

            }
        } else if (objectType == 'Account' && !String.isBlank(sObjectData)) {
            theAccount = (Account) JSON.deserialize(sObjectData, Account.class);
        }

        return theAccount;
    }

    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description getLead
    * @param recordId String
    * @param objectType String
    * @param sObjectData String
    * @return Lead
    */
    public static Lead getLead(String recordId, String objectType, String sObjectData) {
        if (objectType == 'Lead' && !String.isBlank(sObjectData)) {
            return (Lead) JSON.deserialize(sObjectData, Lead.class);
        }

        return null;
    }


    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description getPrimaryContact
    * @param recordId String
    * @param objectType String
    * @param sObjectData String
    * @return Contact
    */
    public static Contact getPrimaryContact(String recordId, String objectType, String sObjectData) {
        if (!Schema.sObjectType.Contact.isAccessible()) {
            return null;
        }
        Contact theContact = null;
        if (recordId != null) {

            try {
                if (XC_UTIL_Sobject.getObjectType(recordId) == 'Account') {
                    theContact = [select Id, name,FirstName,LastName, IndividualId from Contact where AccountId = :recordId and XC_PrimaryContact__c = true];
                } else {
                    theContact = [select Id, name,FirstName,LastName, IndividualId from Contact where Id = :recordId];
                }
            } catch (Exception e) {
                theContact = null;

            }
        } else if (objectType == 'Contact' && !String.isBlank(sObjectData)) {
            theContact = (Contact) JSON.deserialize(sObjectData, Contact.class);
        }
        return theContact;
    }

    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description getContactIndividual
    * @param theContact Contact
    * @return Individual
    */
    public static Individual getContactIndividual(Contact theContact) {
        Individual theIndividual = null;
        if (Schema.sObjectType.Individual.isAccessible()) {
            try {
                theIndividual = [
                        select Id, name, XC_ThirdPartyConsentVersion__c, XC_CollectionChannelThirdParties__c, XC_CollectionDateThirdParties__c, XC_CollectionUserThirdParties__c, XC_GiveDataToThirdParties__c, XC_LECollectedThirdParties__c
                        from Individual
                        where Id = :theContact.IndividualId
                ];
            } catch (Exception e) {
                theIndividual = null;
            }
        }
        return theIndividual;
    }


    /**
    * @author Palamides Damiano
    * @date Creation 15/10/2019
    * @description getLegalEntityConfigurations
    * @param u User
    * @return List<XC_CM_CountryLegalEntityAssociation__mdt> message
    */
    public static List<XC_CM_CountryLegalEntityAssociation__mdt> getLegalEntityConfigurations(User u, String recordTypeId ) {
        List<XC_CM_CountryLegalEntityAssociation__mdt> retList = new List<XC_CM_CountryLegalEntityAssociation__mdt>();
        Set<String> leSet = new Set<String>();
        //DP 09/12
        List<String> multipick = XC_UTIL_User.getLegalEntitiesFromUser();
        //////////
        String recordTypeName = '';
        String stream = '';
        if(recordTypeId != null && recordTypeId != ''){
            /*if(XC_UTIL_Sobject.getObjectType(recordId)=='Account'){
                recordTypeName =  Schema.SObjectType.Account.getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
            }else if(XC_UTIL_Sobject.getObjectType(recordId)=='Lead'){
                recordTypeName =  Schema.SObjectType.Lead.getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
            }else if(XC_UTIL_Sobject.getObjectType(recordId)=='Contact'){
                recordTypeName =  Schema.SObjectType.Contact.getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
            }*/
            recordTypeName = XC_UTIL_SObject.retrieveRecordTypNameFromId(recordTypeId);
        }
        if(recordTypeName.contains('B2B')){
            stream = 'B2B';
        }else if(recordTypeName.contains('B2G')){
            stream = 'B2G';
        }else{
            stream = 'B2C';
        }
        if (Schema.sObjectType.XC_CM_CountryLegalEntityAssociation__mdt.isAccessible()) {
            try {
                List<XC_CM_CountryLegalEntityAssociation__mdt> retList4Group = [
                        SELECT Id, DeveloperName, Label, XC_LegalEntity__c, XC_Country__c,XC_LegalEntityGroup__c
                        from XC_CM_CountryLegalEntityAssociation__mdt
                        where XC_LegalEntity__c in :multipick //:u.XC_LegalEntity__c 
                        AND XC_Stream__c =: stream
                ];

                retList = [
                        SELECT Id, DeveloperName, Label, XC_LegalEntity__c, XC_Country__c,XC_LegalEntityGroup__c
                        from XC_CM_CountryLegalEntityAssociation__mdt
                        where XC_LegalEntityGroup__c in :XC_UTIL_Sobject.getListFieldValues(retList4Group,'XC_LegalEntityGroup__c')
                        AND XC_Stream__c =: stream
                        //order by XC_Country__c desc
                ];
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }

        return retList;
    }


}