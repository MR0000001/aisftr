/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 18/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Skill_TEST – Test Class of XC_UTIL_Skill
*/

@isTest
public class XC_UTIL_Skill_TEST {


    static testMethod void getListSkillsByProductCategoryTest(){
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prodCat = [SELECT Id FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_ProductCategoryOfInterest.productSkillRequired(prodCat);
        List<String> prodCatName = new List<String>();
        prodCatName.add('Caldera');
        Test.startTest();
        Map<String, List<XC_UTIL_Skill.SkillWrapper>> mapRetrun = XC_UTIL_Skill.getListSkillsByProductCategory(prodCatName);
        System.assertEquals(mapRetrun.keySet().size() , 1);
        Test.stopTest();
    }

    static testMethod void getListSkillsByWorkTypeCatalogCategoryTest(){
        insert XC_DF_ProductCategoryOfInterest.prodCatWithVisitRecord();
        XC_ProductCategoryOfInterest__c prodInt = [SELECT Id FROM XC_ProductCategoryOfInterest__c];
        insert XC_DF_WorkType.createWorkType(Label.XC_CL_CommercialVisit);
        List<WorkType> workType = [SELECT Id, XC_WorkTypeCategory__c FROM WorkType]; 
        List<String> woId = new List<String>();
        woId.add(workType[0].XC_WorkTypeCategory__c);
        XC_ProductSkill_Association__c prodSkillAss = XC_DF_ProductCategoryOfInterest.productSkillAssociation(prodInt, workType[0]);
        insert prodSkillAss;
        List<NE__Catalog_Category__c> catCategory = [SELECT Id, XC_TechnicalSkill__c FROM NE__Catalog_Category__c];
        catCategory[0].XC_TechnicalSkill__c = 'Boiler';
        update catCategory[0];
        List<NE__Catalog_Category__c> catCategoryUpdated = [SELECT Id, XC_TechnicalSkill__c FROM NE__Catalog_Category__c];
        List<String> catCatId = new List<String>();
        catCatId.add(catCategoryUpdated[0].Id);
        List<String> techSkill = new List<String>{'Boiler'};
        List<String> covTechSkill = new List<String>{'Boiler'};
        Test.startTest();
        Map<String, List<XC_UTIL_Skill.SkillWrapper>> mapRetrun = XC_UTIL_Skill.getListSkillsByWorkTypeCatalogCategory(techSkill, woId, covTechSkill);
        System.assertEquals(mapRetrun.keySet().size() , 1);
        Test.stopTest();
    }   

    static testMethod void getMapWorkOrderSkillIds(){
        insert XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        insert XC_DF_WorkOrder.createWorkOrderSkillRequirement(woList);
        List<SkillRequirement> skillReqList = [SELECT Id FROM SkillRequirement WHERE RelatedRecordId =: woList[0].Id];
        List<Id> skillReqListId = XC_UTIL_Sobject.getIds(skillReqList);
        Map<Id, List<Id>> woSkillReqMapId = new Map<Id, List<Id>>();
        woSkillReqMapId.put(woList[0].Id, skillReqListId);
        Map<Id, List<SkillRequirement>> woSkillReqMap = new Map<Id, List<SkillRequirement>>();
        woSkillReqMap.put(woList[0].Id, skillReqList);
        Test.startTest();
        List<Id> listRetrun = XC_UTIL_Skill.getSkillRequestedList(woSkillReqMapId, woList[0]);
        List<SkillRequirement> listReturnSkill = XC_UTIL_Skill.getSkillRequestedList(woSkillReqMap, woList[0]);
        Map<Id,List<Id>> mapReturn = XC_UTIL_Skill.getMapWorkOrderSkillIds(woList);
        System.assertEquals(listRetrun.size() , 1);
        Test.stopTest();
    }  

    static testMethod void checkSkillsTest(){
        insert XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit);
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        insert XC_DF_WorkOrder.createWorkOrderSkillRequirement(woList);
        List<SkillRequirement> skillReqList = [SELECT Id, SkillId, SkillLevel FROM SkillRequirement WHERE RelatedRecordId =: woList[0].Id];
        XC_DF_ServiceResource.createServiceResources(1);
        ServiceResource servRes = [SELECT Id FROM ServiceResource LIMIT 1];
        insert XC_DF_ServiceResource.createServiceResourcesSkill(servRes);
        List<ServiceResourceSkill> servResSkill = [SELECT Id, SkillId, SkillLevel, EffectiveStartDate, EffectiveEndDate FROM ServiceResourceSkill];
        Test.startTest();
        Boolean checkSkill = XC_UTIL_Skill.checkSkills(skillReqList, servResSkill);
        System.assertEquals(checkSkill ,true);
        Test.stopTest();
    } 
    
    static testMethod void checkSkillsTestChildren(){
        insert XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        List<WorkOrder> woChilds = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_WorkType_Repair);
        woChilds[0].ParentWorkOrderId = woList[0].Id;
        insert woChilds;
        insert XC_DF_WorkOrder.createWorkOrderSkillRequirement(woChilds);
        List<SkillRequirement> skillReqList = [SELECT Id, SkillId, SkillLevel FROM SkillRequirement WHERE RelatedRecordId =: woList[0].Id];
        XC_DF_ServiceResource.createServiceResources(1);
        ServiceResource servRes = [SELECT Id FROM ServiceResource LIMIT 1];
        insert XC_DF_ServiceResource.createServiceResourcesSkill(servRes);
        List<ServiceResourceSkill> servResSkill = [SELECT Id, SkillId, SkillLevel, EffectiveStartDate, EffectiveEndDate FROM ServiceResourceSkill];
        Test.startTest();
        XC_UTIL_Sobject.WrapperResult resWrap = XC_UTIL_Skill.insertSkillOnParentFromChildren(woList);
        System.assertEquals(woList!= null ,true);
        Test.stopTest();
    }
    
    static testMethod void checkSkillsIdTest(){
        List<String> territorySkills = new List<String>();
        List<Skill> skillList = [SELECT Id, MasterLabel, DeveloperName FROM Skill];
        territorySkills.add('Commercial Visit');
        List<String> skillRequested = new List<String>();
        skillRequested.add('Planned Maintenance');
        Test.startTest();
        Boolean checkSkill = XC_UTIL_Skill.checkSkillIds(skillRequested, territorySkills);
        XC_UTIL_Skill.getMapSkills();  
        System.assertEquals(checkSkill ,false);
        Test.stopTest();
    }
    

}