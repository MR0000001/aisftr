/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_LCC086_NewProductSkillAss_TEST – Test Class for XC_LCC086_NewProductSkillAssociation
*/ 

@isTest
public class XC_LCC086_NewProductSkillAss_TEST {

static testMethod void saveProductSkillAssociationTest(){
         insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
         XC_ProductCategoryOfInterest__c prodInt = [SELECT Id FROM XC_ProductCategoryOfInterest__c];
         insert XC_DF_WorkType.createWorkType(Label.XC_CL_CommercialVisit);
         WorkType workType = [SELECT Id, XC_WorkTypeCategory__c, Name FROM WorkType];
         XC_ProductSkill_Association__c prodSkillAss = XC_DF_ProductCategoryOfInterest.productSkillAssociation(prodInt, workType);
         insert prodSkillAss;
         System.debug('prodSkillAss--> '+prodSkillAss);
         Map<String,Object> mapToTest = new Map<String,Object>();
         mapToTest.put('selectedTechSkill',prodSkillAss.XC_TechnicalSkill__c);
         mapToTest.put('workTypeLabel','Commercial Visit - Boiler');
         mapToTest.put('skillId',prodSkillAss.XC_SkillId__c) ;
         mapToTest.put('skillName', prodSkillAss.XC_SkillName__c);
         System.debug('MapToTest---> '+ JSON.serialize(mapToTest));
         Test.startTest();
         XC_UTIL_ResultWrapper rw = XC_LCC086_NewProductSkillAssociation.saveProductSkillAssociation(JSON.serialize(mapToTest));
         System.assertEquals(rw.success , true);
         Test.stopTest();
    }
    
     static testMethod void setFieldsValueTest(){
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prodInt = [SELECT Id FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_WorkType.createWorkType(Label.XC_CL_CommercialVisit);
        WorkType workType = [SELECT Id, XC_WorkTypeCategory__c FROM WorkType];
        insert XC_DF_ProductCategoryOfInterest.productSkillAssociation(prodInt, workType);
        XC_ProductSkill_Association__c prodSkillAss = [SELECT Id FROM XC_ProductSkill_Association__c];
 		Test.startTest();
        XC_ProductSkill_Association__c prodSkillInserted = XC_LCC086_NewProductSkillAssociation.setFieldsValues(prodSkillAss.Id);
        System.assertEquals(prodSkillInserted.Id , prodSkillAss.Id);
        Test.stopTest();
     } 
    
    static testMethod void updateProductSkillAssociationTest(){
         insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
         XC_ProductCategoryOfInterest__c prodInt = [SELECT Id FROM XC_ProductCategoryOfInterest__c];
         insert XC_DF_WorkType.createWorkType(Label.XC_CL_CommercialVisit);
         WorkType workType = [SELECT Id, XC_WorkTypeCategory__c FROM WorkType];
         insert XC_DF_ProductCategoryOfInterest.productSkillAssociation(prodInt, workType);
         XC_ProductSkill_Association__c prodSkillAss = [SELECT Id, XC_TechnicalSkill__c, XC_WorkTypeId__c, XC_WorkTypeName__c, XC_SkillId__c, XC_SkillName__c FROM XC_ProductSkill_Association__c];
         Map<String,Object> mapToTest = new Map<String,Object>();
         mapToTest.put('selectedTechSkill',prodSkillAss.XC_TechnicalSkill__c);
         mapToTest.put('workTypeLabel','Commercial Visit - Boiler');
         mapToTest.put('skillId',prodSkillAss.XC_SkillId__c) ;
         mapToTest.put('skillName', prodSkillAss.XC_SkillName__c);
         mapToTest.put('recordId', prodSkillAss.Id);
         System.debug('MapToTest---> '+mapToTest);
         Test.startTest();
         XC_UTIL_ResultWrapper rw = XC_LCC086_NewProductSkillAssociation.updateProductSkillAssociation(JSON.serialize(mapToTest));
         System.assertEquals(rw.success , true);
         Test.stopTest();
     }
    
    static testMethod void updateProductSkillAssociationTestEmpty(){
        String toTest = '';
 		Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC086_NewProductSkillAssociation.saveProductSkillAssociation(toTest);
        List<String> returnList = XC_LCC086_NewProductSkillAssociation.getPicklistTechnicalValues();
        System.assertEquals(rw.success , false);
        Test.stopTest();
     } 
   
        static testMethod void getPicklistCoverageTechSkill(){
        String toTest = '';
 		Test.startTest();
        XC_UTIL_ResultWrapper rw = XC_LCC086_NewProductSkillAssociation.saveProductSkillAssociation(toTest);
        List<String> returnList = XC_LCC086_NewProductSkillAssociation.getPicklistCoverageTechSkill();
        List<XC_LCC086_NewProductSkillAssociation.PicklistOption> returnList2 = XC_LCC086_NewProductSkillAssociation.getPicklistWorkTypeLabel();
        System.assertEquals(rw.success , false);
        Test.stopTest();
        } 
    


}