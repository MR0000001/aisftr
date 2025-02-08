/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceAppointment_U_UpdateWO_TEST – Test Class for XC_TR_ServiceAppointment_U_UpdateWO
*/ 
@isTest
public class XC_TR_ServiceResSkill_U_SkillOnUser_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }


    static testMethod void onInsert(){
        XC_DF_ServiceResource.createServiceResources(1);
        ServiceResource servRes = [SELECT Id FROM ServiceResource];
        Test.startTest();
        insert XC_DF_ServiceResource.createServiceResourcesSkill(servRes);
        ServiceResourceSkill servResInserted = [SELECT Id, ServiceResourceId FROM ServiceResourceSkill];
        System.assertEquals(servRes.Id, servResInserted.ServiceResourceId);
        Test.stopTest();
    }
    
        static testMethod void onDelete(){
        XC_DF_ServiceResource.createServiceResources(1);
        ServiceResource servRes = [SELECT Id FROM ServiceResource];
        insert XC_DF_ServiceResource.createServiceResourcesSkill(servRes);
        ServiceResourceSkill serviceResSkill = [SELECT Id, XC_CertificationEndDate__c FROM ServiceResourceSkill];
        Test.startTest();
        delete serviceResSkill;
        System.assertEquals(System.today().addYears(5), serviceResSkill.XC_CertificationEndDate__c);
        Test.stopTest();
    }
    
    static testMethod void onUpdate(){
        XC_DF_ServiceResource.createServiceResources(1);
        ServiceResource servRes = [SELECT Id FROM ServiceResource];
        insert XC_DF_ServiceResource.createServiceResourcesSkill(servRes);
        Skill skill = [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel = 'Repair' ];
        ServiceResourceSkill serviceResSkillToUpdate = new ServiceResourceSkill();
        ServiceResourceSkill serviceResSkill = [SELECT Id, XC_CertificationEndDate__c FROM ServiceResourceSkill];
        serviceResSkill.SkillId = skill.Id;
        Test.startTest();
        update serviceResSkill;
        System.assertEquals(System.today().addYears(5), serviceResSkill.XC_CertificationEndDate__c);
        Test.stopTest();
    }
}