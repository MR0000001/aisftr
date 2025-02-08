/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 30/01/2020
* @description XC_LCC119_ServiceResourceManagement_TEST – Test class for XC_LCC119_ServiceResourceManagement_TEST
*/ 

@isTest
private class XC_LCC119_ServiceResourceManagement_TEST {

    @isTest
    private static void onCheckDocument() {
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        ServiceResourceSkill srs = XC_DF_ServiceResource.createServiceResourcesSkill(listSr[0]);
        insert srs;
        XC_ServiceResourceDocument__c srd = new XC_ServiceResourceDocument__c(
            XC_DocumentExternalId__c = 'Test',
            //XC_DocumentName__c = 'Carnet Clima',
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
            //XC_ListOfDocumentAND__c = 'Carnet Clima',
            XC_SkillName__c = listSkill[0].MasterLabel,
            XC_SkillId__c = listSkill[0].Id,
            XC_Type__c = 'Technician',
            RecordTypeId = Schema.SObjectType.XC_SkillDocumentAssociation__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_SkillDocumentAssociation_Technician').getRecordTypeId()
        );
        insert sda;
        Test.startTest();
        XC_LCC119_ServiceResourceManagement.DocumentWrapper dw = new XC_LCC119_ServiceResourceManagement.DocumentWrapper();
        XC_LCC119_ServiceResourceManagement.InputTableWrapper outputWrapper = XC_LCC119_ServiceResourceManagement.getServiceResourceByPartner(listSr[0].XC_Account__c);
        System.assertNotEquals(outputWrapper, null);
        Test.stopTest();
    }

}