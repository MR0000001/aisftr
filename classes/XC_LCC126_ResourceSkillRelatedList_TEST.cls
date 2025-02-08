/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification 
* @description XC_LCC118_ServAppNumberOfCalls_TEST test class for XC_LCC118_ServAppNumberOfCalls
*/  
@isTest
public class XC_LCC126_ResourceSkillRelatedList_TEST {

    static testMethod void retrieveDataTest(){
        XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceResource> serviceResInserted = [SELECT Id FROM ServiceResource];
        insert XC_DF_ServiceResource.createServiceResourcesSkill(serviceResInserted[0]);
        List<ServiceResourceSkill> skillRes = [SELECT Id FROM ServiceResourceSkill];
        String returnData = XC_LCC126_ResourceSkillRelatedList.retrieveData(serviceResInserted[0].Id);
        System.assertEquals(skillRes.size(), 1);
    }

    static testMethod void callToUpdateTest(){
        XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceResource> serviceResInserted = [SELECT Id FROM ServiceResource];
        insert XC_DF_ServiceResource.createServiceResourcesSkill(serviceResInserted[0]);
        List<ServiceResourceSkill> skillRes = [SELECT Id FROM ServiceResourceSkill];
        List<XC_LCC126_ResourceSkillRelatedList.WrapperServiceResourceSkill> wrap = new List<XC_LCC126_ResourceSkillRelatedList.WrapperServiceResourceSkill>();
        XC_LCC126_ResourceSkillRelatedList.WrapperServiceResourceSkill wr = new XC_LCC126_ResourceSkillRelatedList.WrapperServiceResourceSkill();
        wr.certEndDate = Date.today().addDays(30);
        wr.endDate = System.now().addDays(2);
        wrap.add(wr);
        String params = JSON.serialize(wrap);
        String returnData = XC_LCC126_ResourceSkillRelatedList.callToUpdate(params);
        System.assertEquals(skillRes.size(), 1);
    }

    static testMethod void saveServiceResourceSkillTest(){
        XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceResource> serviceResInserted = [SELECT Id FROM ServiceResource];
        List<Skill> skill = [SELECT Id, MasterLabel FROM Skill];
        Map<String,Object> mapServiceResourceSkill = new Map<String,Object>();
        mapServiceResourceSkill.put('skillId', skill[0].Id);
        mapServiceResourceSkill.put('skillLevel', '1.00');
        mapServiceResourceSkill.put('recordId', serviceResInserted[0].Id);
        mapServiceResourceSkill.put('assignmentStartDate', DateTime.now());
        mapServiceResourceSkill.put('assignmentEndDate', DateTime.now().addYears(2));
        XC_UTIL_ResultWrapper resWrap = XC_LCC126_ResourceSkillRelatedList.saveServiceResourceSkill(JSON.serialize(mapServiceResourceSkill));
        System.assertEquals(serviceResInserted.size(), 1);
    }

}