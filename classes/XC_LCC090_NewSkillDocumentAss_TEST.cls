/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC090_NewSkillDocumentAss_TEST – Test Class for XC_LCC090_NewSkillDocumentAssociation
*/ 

@isTest
public class XC_LCC090_NewSkillDocumentAss_TEST {
    static testMethod void saveSkillDocumentAssociationTest(){
        XC_SkillDocumentAssociation__c skillDoc = new XC_SkillDocumentAssociation__c();
        Skill skill = [SELECT Id, MasterLabel, DeveloperName FROM Skill LIMIT 1];
        skillDoc.XC_SkillId__c = skill.Id;
        skillDoc.XC_SkillName__c = skill.MasterLabel;
        skillDoc.XC_ListOfDocumentAND__c = 'Carnet Clima';
        skillDoc.XC_ListOfDocumentOR__c = 'Certificado RITE';
        String recordType = Schema.SObjectType.XC_SkillDocumentAssociation__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_SkillDocumentAssociation_Freelance').getRecordTypeId();
        Map<String,Object> mapToTest = new Map<String,Object>();
        mapToTest.put('listOfDocumentAND',skillDoc.XC_ListOfDocumentAND__c);
        mapToTest.put('listOfDocumentOR',skillDoc.XC_ListOfDocumentOR__c);
        mapToTest.put('skillId',skillDoc.XC_SkillId__c) ;
        mapToTest.put('skillName', skillDoc.XC_SkillName__c);
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC090_NewSkillDocumentAssociation.saveSkillDocumentAssociation(JSON.serialize(mapToTest), recordType);
        System.assertEquals(rw.success , true);
        Test.stopTest();
    }

}