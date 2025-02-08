/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_LegalEntity_U_UpdateLead_TEST – Test Class for XC_TR_LegalEntity_U_UpdateLead
*/ 

@isTest
public class XC_TR_LegalEntityConsent_TEST {
    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;  
        insert org;
    }

    static testMethod void onInsert(){
        List<Individual> indList = new List<Individual>();
        indList.add(new Individual(XC_GDPRThirdPartiesRelated__c = true, LastName = 'Test contact'));
        insert indList;
        List<Lead> leadList = XC_DF_Lead.createResidentialLeads(1);
        leadList[0].IndividualId = indList[0].Id;
        XC_LegalEntityConsent__c legEnt = new XC_LegalEntityConsent__c();
        legEnt.XC_Individual__c = indList[0].Id;
        legEnt.XC_GiveDataTo__c = true;
        legEnt.XC_GiveDataToNew__c = 'Yes';
        legEnt.XC_LeCountry__c = 'Spain';
        legEnt.XC_LegalEntity__c = 'EndesaX';
        Test.startTest();
        insert leadList; 
        insert legEnt;
        update legEnt;
        delete legEnt;
        System.assertEquals(leadList.size() , 1);
        Test.stopTest();
    }

}