@isTest
public  class XC_TR_LegalEntity_U_ManageDescr_TEST {


    @testSetup
    public static void testSetup(){

        Individual i = new Individual(FirstName='Test',LastName='Test',XC_GiveDataToThirdParties__c='Yes');
        insert i;
        List<Contact> contacts = XC_DF_Contact.createResidentialContacts(1);
        Contact c = contacts[0];
        c.IndividualId = i.Id;
        insert contacts;
        XC_ConsentDescription__c descr = new XC_ConsentDescription__c(XC_LegalEntity__c='EndesaX',XC_ConsentVersion__c='2.0',XC_ConsentStatus__c = 'Active',XC_Country__c='Spain');
        insert descr;
        XC_LegalEntityConsent__c consent = new XC_LegalEntityConsent__c(XC_LeCountry__c = 'Spain' ,XC_LegalEntity__c= 'EndesaX',XC_GiveDataToNew__c = 'Yes',XC_Individual__c = i.Id,XC_ConsentDescription__c=descr.Id);
        insert consent;


    }

    @isTest
    public static void checkDescriptionOnConsent(){

        List<XC_LegalEntityConsent__c> consents = [SELECT Id,XC_LegalEntity__c,XC_ConsentDescription__c FROM XC_LegalEntityConsent__c LIMIT 1];
        Test.startTest();
        XC_TR_LegalEntity_U_ManageDescription.checkDescriptionOnConsent(consents);
        Test.stopTest();

    }


}