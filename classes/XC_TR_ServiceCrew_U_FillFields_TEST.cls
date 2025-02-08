/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/01/2020
* @description XC_TR_ServiceCrew_U_FillFields_TEST – Test class for XC_TR_ServiceCrew_U_FillFields
*/ 

@isTest
private class XC_TR_ServiceCrew_U_FillFields_TEST {

    @isTest
    private static void onFillFields() {
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;

        ServiceCrew sc = new ServiceCrew(
            Name = 'TestCrew',
            XC_Country__c = 'Spain',
            CrewSize = 1
        );
        insert sc;

        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(3);
        ServiceResource serviceResCrew = new ServiceResource();
        serviceResCrew.Name = accountList[0].Name;
        serviceResCrew.XC_Account__c = accountList[0].Id;
        serviceResCrew.ResourceType = 'C';
        //serviceResCrew.IsActive = true;
        serviceResCrew.ServiceCrewId = sc.Id;
        insert serviceResCrew;
        List<User> usersList = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true];
        ServiceResource serviceRes = new ServiceResource();
        serviceRes.Name = accountList[1].Name;
        serviceRes.XC_Account__c = accountList[1].Id;
        serviceRes.ResourceType = 'T';
        serviceRes.IsActive = true;
        serviceRes.RelatedRecordId = usersList[0].Id;
        insert serviceRes;

        ServiceCrewMember scm = new ServiceCrewMember(
            ServiceCrewId = sc.Id, 
            ServiceResourceId = serviceRes.Id,
            XC_Country__c = 'Spain',
            StartDate = Datetime.now()
        );

        Test.startTest();
        insert scm;
        System.assertNotEquals(scm, null);
        Test.stopTest();
    }

}