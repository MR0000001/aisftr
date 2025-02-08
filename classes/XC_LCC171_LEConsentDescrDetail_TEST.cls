/**
*@author: francesco imperioli - fimperioli@deloitte.it
*@description: TC for LCC171
*@update: 11-12-2019 creation
*/
@isTest
public  class XC_LCC171_LEConsentDescrDetail_TEST {


    @testSetup
    private static void setup(){
        Individual i = new Individual(FirstName='Test',LastName='Test',XC_GiveDataToThirdParties__c='Yes');
        insert i;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(1);
        Contact c = contacts[0];
        c.IndividualId = i.Id;
        insert contacts;
        XC_ConsentDescription__c descr = new XC_ConsentDescription__c(XC_LegalEntity__c='EndesaX',XC_ConsentVersion__c='0',XC_ConsentStatus__c = 'Active',XC_Country__c='Spain');
        insert descr;
        XC_LegalEntityConsent__c consent = new XC_LegalEntityConsent__c(XC_LeCountry__c = 'Spain' ,XC_LegalEntity__c= 'EndesaX',XC_GiveDataToNew__c = 'Yes',XC_Individual__c = i.Id,XC_ConsentDescription__c=descr.Id);
        insert consent;
    }

    @isTest
    public static void getConsentDescriptionInfo(){
        XC_LegalEntityConsent__c consent = [SELECT ID FROM XC_LegalEntityConsent__c LIMIT 1];
        Test.startTest();
            XC_LCC171_LEConsentDescriptionDetail.getConsentsDescriptionInfo(consent.Id);
        Test.stopTest();
    }

    @isTest
    public static void getConsentDescriptionInfoIndividual(){
        Test.startTest();
        XC_ConsentDescription__c descr = [SELECT Id, Name, XC_ConsentStatus__c,XC_ConsentVersion__c, XC_Country__c, XC_DescriptionGiveDataToLE__c, XC_DescriptionLanguage__c, XC_DescriptionMarketing__c, XC_DescriptionProfiling__c, XC_DescriptionThirdParties__c, XC_LegalEntity__c, XC_ParentDescription__c, XC_PrivacyConsentUrl__c, XC_DescriptionNotCustomer__c, XC_DescriptionThirdProductsMarketing__c FROM XC_ConsentDescription__c LIMIT 1];
        XC_LegalEntityConsent__c consent = [SELECT ID FROM XC_LegalEntityConsent__c LIMIT 1];
           XC_LCC171_LEConsentDescriptionDetail.getConsentDescriptionInfoIndividual(consent.Id);
        Test.stopTest();
    }



}