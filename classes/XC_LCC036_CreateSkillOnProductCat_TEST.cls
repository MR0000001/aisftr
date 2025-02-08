/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC036_CreateSkillOnProductCat_TEST – Test Class of XC_LCC036_CreateSkillOnProductCategory
*/

@isTest
public class XC_LCC036_CreateSkillOnProductCat_TEST {
    static testMethod void getTableDataTest(){
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prodCat = [SELECT Id FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_ProductCategoryOfInterest.productSkillRequired(prodCat);
        Test.startTest();
        List<XC_LCC036_CreateSkillOnProductCategory.Row> rowList = XC_LCC036_CreateSkillOnProductCategory.getTableData(prodCat.Id);
        System.assertEquals(rowList[0].Level , 1);
        Test.stopTest();
    }
    
    static testMethod void saveResultsTest(){
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prodCat = [SELECT Id FROM XC_ProductCategoryOfInterest__c];
        XC_ProductSkillRequired__c prodSkill = new XC_ProductSkillRequired__c();
        Skill skill = [SELECT Id, MasterLabel, DeveloperName FROM Skill LIMIT 1];
        prodSkill.XC_Skill_Id__c = skill.Id;
        prodSkill.XC_Skill_Level__c = 1;
        prodSkill.XC_Skill_Name__c = skill.MasterLabel;
        prodSkill.XC_ProductCategoryOfInterest__c = prodCat.Id;
        Map<String,Object> mapToTest = new Map<String,Object>();
        mapToTest.put('productCategoryOfInterest',prodSkill.XC_ProductCategoryOfInterest__c);
        mapToTest.put('skillLevel',prodSkill.XC_Skill_Level__c);
        mapToTest.put('skillId',prodSkill.XC_Skill_Id__c) ;
        mapToTest.put('skillName', prodSkill.XC_Skill_Name__c);
        Test.startTest();
        Boolean success = XC_LCC036_CreateSkillOnProductCategory.saveResults(JSON.serialize(mapToTest));
        System.assertEquals(success , true);
        Test.stopTest();
    }

}