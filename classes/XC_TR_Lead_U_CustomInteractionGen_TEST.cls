/**
 * The Class XC_TR_Lead_U_CustomInteractionGen_TEST
 *
 * @author            : Emanuela Cacace ecacace@deloitte.it
 * @date Creation     : 22/05/2019
 * @date Modification : 26/06/2019 by Nicola Mariniello nmariniello@deloitte.it
 * @description       : Test class for XC_TR_Lead_U_CustomInteractionGeneration
 */


@isTest
public with sharing class XC_TR_Lead_U_CustomInteractionGen_TEST {

    // Test method for handleLeadCreation 
    static testMethod void handleLeadCreation(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Test.startTest();
        List<Lead> l = XC_DF_Lead.createResidentialLeads(1);
        l[0].Email = 'test@test.it';
        insert l; 

        System.assert(true, [SELECT Id FROM XC_Customer_Interaction__c WHERE XC_LeadId__c =: l[0].Id LIMIT 1]!=null); 
        Test.stopTest();
    }

    // Test method for handleLeadCreation
    static testMethod void handleLeadCreationPrimaryPhone(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Test.startTest();
        List<Lead> l =XC_DF_Lead.createResidentialLeads(1);
        l[0].Email = null;
        l[0].Phone = '+393924034234';
        l[0].XC_PhonePrefix__c = '+39'; 
        l[0].XC_LeadPhone__c = '3924034234';
        insert l; 

        System.assert(true, [SELECT Id FROM XC_Customer_Interaction__c WHERE XC_LeadId__c =: l[0].Id LIMIT 1]!=null); 
        Test.stopTest();
    }

    // Test method for handleLeadCreation
    static testMethod void handleLeadCreationSecondaryPhone(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Test.startTest();
        List<Lead> l =XC_DF_Lead.createResidentialLeads(1);
        l[0].Email = null;
        l[0].Phone = '+34921343245';
        l[0].XC_PhonePrefix__c = '+34'; 
        l[0].XC_LeadPhone__c = '921343245';
        l[0].MobilePhone = '+34921343245';
        l[0].XC_MobilePrefix__c = '+34'; 
        l[0].XC_LeadMobile__c = '621343245';
        insert l; 

        System.assert(true, [SELECT Id FROM XC_Customer_Interaction__c WHERE XC_LeadId__c =: l[0].Id LIMIT 1]!=null);
        Test.stopTest();
    }
    
        // Test method for handleLeadCreation
    static testMethod void handleLeadChangeStatus(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Test.startTest();
        List<Lead> l =XC_DF_Lead.createResidentialLeads(1);
        l[0].Email = null;
        l[0].Phone = '+34921343245';
        l[0].XC_PhonePrefix__c = '+34'; 
        l[0].XC_LeadPhone__c = '921343245';
        l[0].MobilePhone = '+34921343245';
        l[0].XC_MobilePrefix__c = '+34'; 
        l[0].XC_LeadMobile__c = '621343245';
        l[0].Status = 'New';
        insert l; 
        List<Lead> ldList = [SELECT Id, Status FROM Lead];
        System.debug('#### ld Status -->' + ldList[0].Status);
        Lead l1 = l[0];
        l1.Status = 'Take Charge';
        update l1;
        //XC_TR_Lead_U_CustomInteractionGeneration.createCustomerInteractionSalesCallSurvey(listNew, mapOldS, mapNewS);
        Test.stopTest();
    }

    static testMethod void handleLeadChangeStatusCustomerContacted(){
        insert XC_DF_OneOrg.createOneOrg('Spain');

        Test.startTest();
        List<Lead> l =XC_DF_Lead.createResidentialLeads(1);
        l[0].Email = null;
        l[0].Phone = '+34921343245';
        l[0].XC_PhonePrefix__c = '+34'; 
        l[0].XC_LeadPhone__c = '921343245';
        l[0].MobilePhone = '+34921343245';
        l[0].XC_MobilePrefix__c = '+34'; 
        l[0].XC_LeadMobile__c = '621343245';
        l[0].Status = 'New';
        insert l; 
        List<Lead> ldList = [SELECT Id, Status FROM Lead];
        System.debug('#### ld Status -->' + ldList[0].Status);
        Lead l1 = l[0];
        l1.Status = 'Customer Contacted';
        update l1;
        //XC_TR_Lead_U_CustomInteractionGeneration.createCustomerInteractionSalesCallSurvey(listNew, mapOldS, mapNewS);
        Test.stopTest();
    }
    
    
   
}