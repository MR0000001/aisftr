/**
 * @author Andrea Di Cicco
 * @date Creation 11/11/2019
 * @date Modification 11/11/2019 by Andrea Di Cicco
 * @description XC_LCC005_AccountCallToCommodity – Controller for XC_LCP005_AccountCallToCommodity Component
 */
public without sharing class XC_LCC005_AccountCallToCommodity_UU {
    /**
     * @author Andrea Di Cicco
     * @description update main phone.
     * @param recordId id of the entity
     * @param accountInfo information of the account
     */
    @AuraEnabled
    public static void saveConsents(String recordId, String accountInfo){
        Map<String, String> mappingLEFields = new Map<String, String>();
        mappingLEFields.put( 'LegalEntity', 'XC_LegalEntity__c');
        mappingLEFields.put( 'GiveDataToLegalEntity', 'XC_GiveDataToNew__c' );
        mappingLEFields.put( 'GiveDataForMarketing', 'XC_MarketingConsent__c');
        mappingLEFields.put( 'GiveDataForProfiling', 'XC_ProfilingConsent__c');
        XC_ConsentDescription__c consentDescription = [SELECT Id from XC_ConsentDescription__c where (XC_LegalEntity__c = 'EndesaX' or XC_LegalEntity__c = 'EnelXMobilitySpain') and XC_Country__c = 'Spain' AND XC_ParentDescription__c = null  LIMIT 1];
        XC_LCC005_AccountCallToCommodity.ResultWrapper result = (XC_LCC005_AccountCallToCommodity.ResultWrapper) System.JSON.deserialize(accountInfo, XC_LCC005_AccountCallToCommodity.ResultWrapper.class);
        Boolean isConfirmedByCustomer = true;
        
        Account account =retrieveAccount( recordId);
        if(account.XC_ConfirmationByCustomer__c){
            return;
        }
        if(result.sections.get('LegalEntity') == null || result.sections.get('LegalEntity').objectsRecordFields== null){
            return; 
        }
        Contact primaryContact = retrieveContact( account.IdentityNumber__c);
        Individual individual = new Individual();
        individual.LastName = primaryContact.LastName;
        individual.XC_GiveDataToThirdParties__c = 'Yes';
        individual.XC_ThirdPartyConsentVersion__c = '4.0';
        XC_UTIL_Sobject.insertRecord (individual); 
        primaryContact.IndividualId = individual.Id;
        XC_UTIL_Sobject.updateRecord( primaryContact);
        List<XC_LegalEntityConsent__c> listOfLE = new List<XC_LegalEntityConsent__c>();
        for(List<XC_LCC005_AccountCallToCommodity.FieldWrapper> recordFields : result.sections.get('LegalEntity').objectsRecordFields){
            XC_LegalEntityConsent__c le = new XC_LegalEntityConsent__c();
            le.XC_Individual__c  = individual.id;
            le.XC_LeCountry__c = primaryContact.Country__c;
            for(XC_LCC005_AccountCallToCommodity.FieldWrapper record : recordFields){
                if(record.fieldKey != 'GiveDataToThirdParties'){
                    if(record.fieldValue == 'Y'){
                        record.fieldValue ='Yes';
                    }else if(record.fieldValue == 'N'){
                        record.fieldValue = 'No';
                    }
                    le.put(mappingLEFields.get(record.fieldKey), record.fieldValue);
                }
            }
            le.put('XC_CompanyConsentVersion__c', '4.0');
            le.put('XC_MarketingConsentVersion__c','4.0');
            le.put('XC_ProfilingConsentVersion__c','4.0');
            le.put('XC_LECollectedProfilingConsents__c', 'Endesa');
            le.put('XC_LECollectedMarketingConsents__c', 'Endesa');
            le.put('XC_CollectionDateMarketing__c', Date.valueOf('2018-07-26'));
            le.put('XC_CollectionDateProfiling__c',  Date.valueOf('2018-07-26'));
            le.put('XC_ConsentDescription__c' , ConsentDescription.Id);
            listOfLE.add(le);
        }
         XC_UTIL_Sobject.insertListRecords ( listOfLE);
        account.XC_ConfirmationByCustomer__c = true;
        XC_UTIL_Sobject.updateRecord( account);
    }

    private static Account retrieveAccount(String recordId){
        Account account = new Account();
        if(Schema.sObjectType.Account.isAccessible()){
            account = [SELECT XC_ConfirmationByCustomer__c, IdentityNumber__c FROM Account WHERE id =: recordId LIMIT 1];
        }
        return account;
    }

    private static Contact retrieveContact(String identityNumber){
        Contact primaryContact = new Contact();
        if(Schema.sObjectType.Contact.isAccessible()){
            primaryContact = [Select Id, LastName, IndividualId, Country__c from Contact where XC_ContactDocumentNumber__c = : identityNumber ];
        }
        return primaryContact;
    }
}