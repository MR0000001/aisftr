/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_LegalEntity_U_UpdateAccount_TEST – Test Class for XC_TR_LegalEntity_U_UpdateAccount
*/ 

@isTest
public class XC_TR_LegalEntity_U_UpdateAccount_TEST {
     @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;  
        insert org;
    }

    static testMethod void onInsert(){
        List<Individual> indList = new List<Individual>();
        indList.add(new Individual(XC_GiveDataToThirdParties__c = 'Yes', LastName = 'Test contact'));
        insert indList;
        List<Contact> contList = XC_DF_Contact.createResidentialContacts(1);
        contList[0].XC_PrimaryContact__c = true;
        contList[0].IndividualId = indList[0].Id;
        XC_LegalEntityConsent__c legEnt = new XC_LegalEntityConsent__c();
        legEnt.XC_Individual__c = indList[0].Id;
        legEnt.XC_GiveDataToNew__c = 'Yes';
        legEnt.XC_LeCountry__c = 'Spain';
        legEnt.XC_LegalEntity__c = 'EndesaX';
        Test.startTest();
        insert contList; 
        insert legEnt;
        System.assertEquals(contList.size() , 1);
        Test.stopTest();
    }
}