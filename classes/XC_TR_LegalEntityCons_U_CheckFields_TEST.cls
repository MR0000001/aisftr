/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 01/04/2020
* @description XC_TR_LegalEntityCons_U_CheckFields_TEST – Test class for XC_TR_LegalEntityConsent_U_CheckFields
*/  

@isTest
private class XC_TR_LegalEntityCons_U_CheckFields_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_LegalEntityCons_U_CheckFields_TEST');

    @isTest
    static void onInsertedLegalEntityConsentWithError() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Contact cnt = XC_DF_Contact.createResidentialContacts(1)[0];
        Account acc = new Account(
            Id = cnt.AccountId,
            XC_ConfirmationByCustomer__c = true
        );

        Test.startTest();
        update acc;
        insert cnt;
        Test.stopTest();
    }

    @isTest
    static void onUpdatedLegalEntityConsentWithoutError() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Contact cnt = XC_DF_Contact.createResidentialContacts(1)[0];
        Account acc = new Account(
            Id = cnt.AccountId,
            XC_ConfirmationByCustomer__c = true,
            XC_BirthDate__c = Date.today().addYears(-100)
        );
        update acc;
        insert cnt;
        cnt = [SELECT Id, IndividualId FROM Contact WHERE Id = :cnt.Id];
        XC_LegalEntityConsent__c lec2ins = new XC_LegalEntityConsent__c(
            XC_LegalEntity__c = 'EndesaX',
            XC_LeCountry__c = 'Spain',
            XC_GiveDataTo__c = true,
            XC_GiveDataToNew__c = 'Yes',
            XC_ProfilingConsent__c = 'Yes',
            XC_MarketingConsent__c = 'Yes',
            XC_Individual__c = cnt.IndividualId
        );

        Test.startTest();
        insert lec2ins;
        lec2ins.XC_ProfilingConsent__c = 'No';
        lec2ins.XC_MarketingConsent__c = 'No';
        update lec2ins;
        lec2ins.XC_ProfilingConsent__c = 'Yes';
        lec2ins.XC_MarketingConsent__c = 'Yes'; 
        update lec2ins;
        XC_TR_LegalEntityConsent_U_CheckFields.checkAge(new List<XC_LegalEntityConsent__c>{lec2ins}, acc);
        Test.stopTest();
    }

}