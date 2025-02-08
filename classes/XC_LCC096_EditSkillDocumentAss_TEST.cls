/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC096_EditSkillDocumentAss_TEST – Test Class for XC_LCC096_EditSkillDocumentAssociation
*/ 

@isTest 
public class XC_LCC096_EditSkillDocumentAss_TEST {
    static testMethod void setFieldsValuesTest(){
        XC_SkillDocumentAssociation__c skillDoc = new XC_SkillDocumentAssociation__c();
        Skill skill = [SELECT Id, MasterLabel, DeveloperName FROM Skill LIMIT 1];
        skillDoc.XC_SkillId__c = skill.Id;
        skillDoc.XC_SkillName__c = skill.MasterLabel;
        skillDoc.XC_ListOfDocumentAND__c = 'Carnet Clima';
        skillDoc.XC_ListOfDocumentOR__c = 'Certificado RITE';
        String recordType = Schema.SObjectType.XC_SkillDocumentAssociation__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_SkillDocumentAssociation_Freelance').getRecordTypeId();
        skillDoc.RecordTypeId = recordType;
        insert skillDoc; 
        XC_SkillDocumentAssociation__c skillDocInserted = [SELECT Id FROM XC_SkillDocumentAssociation__c];
        Test.startTest(); 
        XC_SkillDocumentAssociation__c skillDocAss = XC_LCC096_EditSkillDocumentAssociation.setFieldsValues(skillDocInserted.Id);
        System.assertEquals(skillDocAss.Id , skillDocInserted.Id);
        Test.stopTest();
    }

    static testMethod void saveSkillDocumentAssociationTest(){
        XC_SkillDocumentAssociation__c skillDoc = new XC_SkillDocumentAssociation__c();
        Skill skill = [SELECT Id, MasterLabel, DeveloperName FROM Skill LIMIT 1];
        skillDoc.XC_SkillId__c = skill.Id;
        skillDoc.XC_SkillName__c = skill.MasterLabel;
        skillDoc.XC_ListOfDocumentAND__c = 'Carnet Clima';
        skillDoc.XC_ListOfDocumentOR__c = 'Certificado RITE';
        String recordType = Schema.SObjectType.XC_SkillDocumentAssociation__c.getRecordTypeInfosByDeveloperName().get('XC_ESP_SkillDocumentAssociation_Freelance').getRecordTypeId();
        skillDoc.RecordTypeId = recordType;
        insert skillDoc;
        XC_SkillDocumentAssociation__c skillDocInserted = [SELECT Id, XC_ListOfDocumentAND__c, XC_ListOfDocumentOR__c, XC_SkillId__c, XC_SkillName__c   FROM XC_SkillDocumentAssociation__c];
        Map<String,Object> mapToTest = new Map<String,Object>();
        mapToTest.put('recordId', skillDocInserted.Id);
        mapToTest.put('listOfDocumentAND',skillDocInserted.XC_ListOfDocumentAND__c);
        mapToTest.put('listOfDocumentOR',skillDocInserted.XC_ListOfDocumentOR__c);
        mapToTest.put('skillId',skillDocInserted.XC_SkillId__c) ;
        mapToTest.put('skillName', skillDocInserted.XC_SkillName__c);
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC096_EditSkillDocumentAssociation.saveSkillDocumentAssociation(JSON.serialize(mapToTest));
        System.assertEquals(rw.success , true);
        Test.stopTest();
    }
    
    static testMethod void saveSkillDocumentAssociationTest2(){
        
        String mapToTest = '';
        Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC096_EditSkillDocumentAssociation.saveSkillDocumentAssociation(mapToTest);
        System.assertEquals(rw.success , false);
        Test.stopTest();
        
    }
}