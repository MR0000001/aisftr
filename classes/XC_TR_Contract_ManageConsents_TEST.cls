/**
 * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
 * @date 14/04/2020
 * @description XC_TR_Contract_ManageConsents_TEST - Test class for XC_TR_Contract_ManageConsents
 */

@isTest
private class XC_TR_Contract_ManageConsents_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Contract_ManageConsents_TEST');

    @isTest
    static void onUpdateLegalEntityConsent() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Contact cnt = XC_DF_Contact.createResidentialContacts(1)[0];
        Account acc = new Account(
            Id = cnt.AccountId,
            XC_ConfirmationByCustomer__c = true
        );
        update acc;
        insert cnt;
        /*cnt = [SELECT Id, IndividualId FROM Contact WHERE Id = :cnt.Id];
        XC_LegalEntityConsent__c lec = [SELECT Id FROM XC_LegalEntityConsent__c LIMIT 1];
        lec.XC_LegalEntity__c = 'EndesaX';
        lec.XC_LeCountry__c = 'Spain';
        lec.XC_GiveDataTo__c = true;
        lec.XC_GiveDataToNew__c = 'Yes';
        lec.XC_ExpirationDateMarketingConsent__c = Date.today();
        lec.XC_ExpirationDateProfilingConsent__c = Date.today();
        update lec;*/
        Contract cntr = XC_DF_Contract.createCondominiumContract(new List<Account>{acc})[0];
        cntr.EndDate = Date.today().addDays(10);

        Test.startTest();
        insert cntr;
        Test.stopTest();
    }

}