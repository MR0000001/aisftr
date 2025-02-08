/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 19/03/2020
* @description XC_LCC084_AssignToBackOffice_TEST – Test Class for XC_LCC084_AssignToBackOffice
*/ 

@isTest
private class XC_LCC084_AssignToBackOffice_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC084_AssignToBackOffice_TEST');

    @isTest
    static void checkRelatedExcludedPreferenciesTest(){
        insert new OneOrg__c(Name='OneOrg (User)', XC_Spain_Triggers__c=true, XC_Spain_ValidationRules__c=true);
        ServiceResource servRes = XC_DF_ServiceResource.createServiceResources(1)[0];
        WorkOrder wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit)[0];
        insert wo;
        ResourcePreference resPref = new ResourcePreference(
            PreferenceType = 'Required',
            RelatedRecordId = wo.Id,
            ServiceResourceId = servRes.Id
        );
        insert resPref;

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        acc[0].XC_ReceivingChannel__c= 'DPO';
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        insert XC_DF_User.createCommunityUser(cont[0]);

        List<User> userCommunityList = new List<User>([
            SELECT Id 
            FROM User 
            WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true
        ]);

        System.runAs(userCommunityList[0]) {
            Test.startTest();
            XC_UTIL_Sobject.WrapperResult result = XC_LCC084_AssignToBackOffice.checkRelatedExcludedPreferencies(wo.Id);
            System.assertEquals(result.success , true);
            Test.stopTest();
        }
    }
    
    @isTest
    static void assignationToBackOffice(){
        ServiceResource servRes = XC_DF_ServiceResource.createServiceResources(1)[0];
        Contact cnt = XC_DF_Contact.createResidentialContacts(1)[0];
        insert cnt;
        WorkOrder wo = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_CommercialVisit)[0];
        wo.AccountId = cnt.AccountId;
        wo.ContactId = cnt.Id;
        insert wo;
        ResourcePreference resPref = new ResourcePreference(
            PreferenceType = 'Required',
            RelatedRecordId = wo.Id,
            ServiceResourceId = servRes.Id
        );
        insert resPref;

        List<Account> acc = XC_DF_Account.createResidentialAccounts(1);
        acc[0].XC_ReceivingChannel__c= 'DPO';
        insert acc;
        List<Contact> cont = XC_DF_Contact.createResidentialContacts(acc);
        insert cont;
        insert XC_DF_User.createCommunityUser(cont[0]);

        List<User> userCommunityList = new List<User>([
            SELECT Id 
            FROM User 
            WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true
        ]);

        System.runAs(userCommunityList[0]){
            Test.startTest();
            XC_LCC084_AssignToBackOffice.ResultWrapper result = XC_LCC084_AssignToBackOffice.assignationToBackOffice(wo.Id);
            //System.assertEquals(result.success, true);
            Test.stopTest();
        }
    }

}