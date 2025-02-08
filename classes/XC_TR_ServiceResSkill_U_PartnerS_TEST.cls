/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 22/01/2020
* @date Modification dd/mm/yyyy
* @description XC_TR_ServiceResSkill_U_PartnerS_TEST – Test Class for XC_TR_ServiceResSkill_U_PartnerS_TEST
*/ 
@isTest
public class XC_TR_ServiceResSkill_U_PartnerS_TEST{

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
}