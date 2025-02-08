/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 08/04/2020
 * @description XC_SC029_DeactiveConsent_TEST - Test class for Batch XC_SC029_DeactiveConsent
 */

@isTest
private class XC_SC029_DeactiveConsent_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_SC029_DeactiveConsent_TEST');

    @isTest
    private static void onBatch() {
        insert new OneOrg__c(Name='OneOrg (User)', XC_Spain_Triggers__c=true);
        Contact cnt = XC_DF_Contact.createResidentialContacts(1)[0];
        Account acc = new Account(
            Id = cnt.AccountId,
            XC_ConfirmationByCustomer__c = true
        );
        update acc;
        insert cnt;
        cnt = [SELECT Id, IndividualId FROM Contact WHERE Id = :cnt.Id];
        XC_LegalEntityConsent__c lecToInsert = [SELECT Id FROM XC_LegalEntityConsent__c LIMIT 1];       
        lecToInsert.XC_LegalEntity__c = 'EndesaX';
        lecToInsert.XC_LeCountry__c = 'Spain';
        lecToInsert.XC_GiveDataTo__c = true;
        lecToInsert.XC_GiveDataToNew__c = 'Yes';
        lecToInsert.XC_ProfilingConsent__c = 'Yes';
        lecToInsert.XC_MarketingConsent__c = 'Yes';
        lecToInsert.XC_ExpirationDateProfilingConsent__c = Date.today().addYears(-10);
        lecToInsert.XC_ExpirationDateMarketingConsent__c = Date.today().addYears(-10);
        update lecToInsert;
        
        Test.startTest();
        System.schedule('Test XC_SC029_DeactiveConsent', '16 20 0 * * ?', new XC_SC029_DeactiveConsent());
        Test.stopTest();
    }

}