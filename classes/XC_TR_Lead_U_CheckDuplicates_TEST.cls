/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 01/07/2019
* @date Modification dd/mm/yyyy
* @description  – XC_UTIL_LeadDuplication_TEST - Class test for XC_UTIL_LeadDuplication
*/
@isTest
private class XC_TR_Lead_U_CheckDuplicates_TEST {
    @TestSetup
    static void insertRecords(){
        List<Lead> leadListToInsert = XC_DF_Lead.createResidentialLeads(1);
        Lead ld =leadListToInsert[0];
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Email = 'test@testlead.it';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTest';
        ld.LastName= 'LeadTest';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898789';
        ld.XC_DocumentType__c = 'NIF';
        ld.XC_DocumentNumber__c = '52802393M';
        insert ld;
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
    }
    
    static testMethod void leadDuplocation(){
        Lead existingLead = [SELECT Id FROM Lead LIMIT 1];
        List<Lead> leadListToInsert = XC_DF_Lead.createResidentialLeads(1);
        Lead ld =leadListToInsert[0];
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Email = 'test@testlead.it';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTest';
        ld.LastName= 'LeadTest';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898789';
        ld.XC_DocumentType__c = 'NIF';
        ld.XC_DocumentNumber__c = '52802393M';
        try{
        	insert ld;
        } catch(Exception e){
            system.debug('Exception');
        }
        
        existingLead.XC_DocumentType__c = 'Passport';
        existingLead.XC_DocumentNumber__c = '13141414';
        update existingLead;
    }
    
 	static testMethod void massiveLeadInsert(){
        List<Lead> leadListToInsert = XC_DF_Lead.createResidentialLeads(5);
        Lead ld =leadListToInsert[0];
        ld.RecordTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('XC_GLO_Lead_Residential').getRecordTypeId();
        ld.XC_DocumentCountry__c = 'Spain';
        ld.Email = 'test@testlead.it';
        ld.XC_MainLegalEntity__c = 'EndesaX';
        ld.FirstName = 'LeadTest';
        ld.LastName= 'LeadTest';
        ld.XC_PhonePrefix__c='+39';
        ld.XC_LeadPhone__c= '0817898789';
        ld.XC_DocumentType__c = 'NIF';
        ld.XC_DocumentNumber__c = '52802393M';
        try{
        	insert leadListToInsert;
        } catch(Exception e){
            system.debug('Exception');
        }
    }
}