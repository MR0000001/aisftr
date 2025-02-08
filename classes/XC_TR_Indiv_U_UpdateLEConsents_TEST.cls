/**
* @author Domenico Del Prete domenico.delprete@nttdata@com
* @date Creation  07/02/2020 
* @description XC_TR_Indiv_U_UpdateLEConsents_TEST – Test class for XC_TR_Individual_U_UpdateLEConsents
*/ 
@isTest
public without sharing class XC_TR_Indiv_U_UpdateLEConsents_TEST {

    @TestSetup
    static void setup(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

    }

    @isTest
    static void updateConsentsTEST(){
        List<Contact> listOfContact = XC_DF_Contact.createResidentialContacts(1);
        insert listOfContact;
        Individual ind = new Individual (Contact__c = listOfContact[0].Id, 
                                         LastName = listOfContact[0].LastName , 
                                         XC_GiveDataToThirdParties__c ='No', 
                                         XC_ThirdPartyConsentVersion__c = 'Test');
        insert ind;
        XC_LegalEntityConsent__c le = new XC_LegalEntityConsent__c();
        le.XC_Individual__c = ind.Id;
        le.XC_LegalEntity__c = 'EndesaX';
        le.XC_GiveDataToNew__c = 'Yes';
        le.XC_UpdateAboutProducts__c = 'Yes';
        le.XC_ConsentToDataProcessing__c = 'Yes';
        le.XC_LeCountry__c = 'Spain';
        le.XC_MarketingConsent__c = null;
        le.XC_MarketingConsentVersion__c = 'ie';
        insert le;
        
        Map<Id, Individual> mapOld = new Map<Id, Individual>();
        mapOld.put(ind.Id,ind);
        ind.XC_GiveDataToThirdParties__c = 'Yes';
        update ind;
        Map<Id, Individual> mapNew = new Map<Id, Individual>();
        mapNew.put(ind.Id,ind);
        XC_TR_Individual_U_UpdateLEConsents.updateConsents(mapOld, mapNew);
    }

}