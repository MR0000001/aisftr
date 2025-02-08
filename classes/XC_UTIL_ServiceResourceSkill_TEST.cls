/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 05/02/2020
* @description XC_UTIL_ServiceResourceSkill_TEST –Test Class 
*/

@isTest
private class XC_UTIL_ServiceResourceSkill_TEST {
    
    
    @isTest
    static void checkServiceResourceSkill_test(){
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        ServiceResourceSkill srs = XC_DF_ServiceResource.createServiceResourcesSkill(listSr[0]);
        insert srs;  
        Test.startTest();
        XC_UTIL_ServiceResourceSkill.checkServiceResourceSkill(new List<ServiceResourceSkill>{srs}); 
        Test.stopTest();
    }
    
    @isTest
    static void checkServiceResourceSkill2_test(){
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceResourceSkill> srsList = new List<ServiceResourceSkill>();
        List<Skill> skillList = [SELECT Id, MasterLabel, DeveloperName FROM Skill];
        srsList.add(new ServiceResourceSkill(
            SkillId = skillList[0].Id,
            ServiceResourceId = listSr[0].Id,
            SkillLevel = 1,
            XC_CertificationStartDate__c = System.today(),
            XC_CertificationEndDate__c = System.today().addYears(5),
            EffectiveEndDate = System.today().addYears(5),
            EffectiveStartDate = System.today(),
            XC_AssignmentStartDate__c = System.today(),
            XC_AssignmentEndDate__c = System.today().addYears(5)
        ));
        srsList.add(new ServiceResourceSkill(
            SkillId = skillList[1].Id,
            ServiceResourceId = listSr[0].Id,
            SkillLevel = 1,
            XC_CertificationStartDate__c = System.today(),
            XC_CertificationEndDate__c = System.today().addYears(5),
            EffectiveEndDate = System.today().addYears(5),
            EffectiveStartDate = System.today(),
            XC_AssignmentStartDate__c = System.today(),
            XC_AssignmentEndDate__c = System.today().addYears(5)
        ));
        insert srsList;
        Test.startTest();
        XC_UTIL_ServiceResourceSkill.checkServiceResourceSkill(srsList); 
        Test.stopTest();
    }
}