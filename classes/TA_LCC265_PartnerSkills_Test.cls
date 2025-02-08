/**
 * @description       : Test class for TA_LCC265_PartnerSkills
 * @author            : federico.demichelis
 * @group             : WebResults
 * @last modified on  : 18-05-2022
 * @last modified by  : federico.demichelis
**/
@isTest 
public with sharing class TA_LCC265_PartnerSkills_Test {
    @isTest
    private static void getServiceResourceByPartner_test() {
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(2);        
        ServiceResourceSkill srs = XC_DF_ServiceResource.createServiceResourcesSkill(listSr[0]);
        insert srs;
        XC_ServiceResourceDocument__c srd = new XC_ServiceResourceDocument__c(
            XC_DocumentExternalId__c = 'Test',
            XC_DocumentName__c = 'Carnet Clima',
            XC_ExpirationDateOfValidity__c = Date.today().addDays(10),
            XC_ResultOfValidation__c = 'OK',
            XC_ServiceResource__c = listSr[0].Id,
            XC_StartDateOfValidity__c = Date.today(),
            XC_TypeOfDocument__c = 'TBD'            
        );
        insert srd;
        List<Skill> listSkill = new List<Skill>([
            SELECT Id, MasterLabel
            FROM Skill
            LIMIT 1
        ]);
        
        XC_SkillDocumentAssociation__c sda = new XC_SkillDocumentAssociation__c(
            XC_SkillName__c = listSkill[0].MasterLabel,
            XC_SkillId__c = listSkill[0].Id,
            XC_Type__c = 'Technician',
            XC_ListOfDocumentAND__c = 'Carnet Clima',
            XC_ListOfDocumentOR__c = 'Carnet Clima',
            RecordTypeId = Schema.SObjectType.XC_SkillDocumentAssociation__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_SkillDocumentAssociation_Technician').getRecordTypeId()
        );

        insert sda;
        Test.startTest();
        TA_LCC265_PartnerSkills.ReturnWrapper rw = new TA_LCC265_PartnerSkills.ReturnWrapper();
        TA_LCC265_PartnerSkills.DocumentWrapper dw = new TA_LCC265_PartnerSkills.DocumentWrapper();
        TA_LCC265_PartnerSkills.InputTableWrapper outputWrapper = TA_LCC265_PartnerSkills.getServiceResourceByPartner(listSr[0].XC_Account__c);
        TA_LCC265_PartnerSkills.InputTableWrapper outputWrapperNoSkill = TA_LCC265_PartnerSkills.getServiceResourceByPartner(listSr[1].XC_Account__c);
        System.assertNotEquals(outputWrapper,null);
        Test.stopTest();

    }
}