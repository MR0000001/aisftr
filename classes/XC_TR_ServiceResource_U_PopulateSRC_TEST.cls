/**
* @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
* @date Creation  03/03/2021 
* @description XC_TR_ServiceResource_U_PopulateSRC_TEST – Test class for XC_TR_ServiceResource_U_PopulateSRC
*/

@isTest
private class XC_TR_ServiceResource_U_PopulateSRC_TEST {
    
    @isTest
    private static void populateServiceResourceCoverage() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        ServiceCrew sc = new ServiceCrew(
            Name = 'TestCrew',
            XC_Country__c = 'Spain',
            CrewSize = 1
        );
        insert sc;
        
        List<User> listUser = new List<User>([
            SELECT Id, Country__c, XC_LegalEntity__c
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ]);
        
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        
        WorkType workType = new WorkType(
            Name = 'Commercial Visit - Boiler',
            XC_LegalEntity__c = listUser[0].XC_LegalEntity__c ,
            XC_WorkTypeCategory__c = 'Commercial Visit',
            DurationType = Label.XC_CL_WorkType_Hours,
            EstimatedDuration = 1,
            XC_Segment__c = 'B2C'
        );
        insert workType;
        List<XC_PartnerCoverage__c> listPc = new List<XC_PartnerCoverage__c>();
        listPc.add(new XC_PartnerCoverage__c(
            XC_Account__c = accountList[0].Id,
            XC_ZipCode__c = '00000',
            XC_WorkType__c = workType.Id,
            XC_ExternalIdForDuplication__c = accountList[0].Id+'_00000_'+workType.Id
        ));
        insert listPc;
        System.debug(accountList[0].Id);
        System.debug(listPc[0]);
        
        ServiceResource serviceResCrew = new ServiceResource();
        serviceResCrew.Name = accountList[0].Name;
        serviceResCrew.ResourceType = 'C';
        //serviceResCrew.IsActive = true;
        serviceResCrew.ServiceCrewId = sc.Id;
        insert serviceResCrew;
        Test.startTest();
        serviceResCrew.XC_Account__c = accountList[0].Id;
        update serviceResCrew;
        Test.stopTest();
    }
}