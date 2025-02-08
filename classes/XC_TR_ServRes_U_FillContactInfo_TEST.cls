/**
* @author Roberta Porrega - roberta.porrega@nttdata.com  
* @date Creation  29/04/2019 
* @description XC_TR_ServRes_U_FillContactInfo_TEST 
*/
@isTest
private class XC_TR_ServRes_U_FillContactInfo_TEST {
    //    TEST INSERT 
    static testMethod void checkInsertServiceAppointment() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        OperatingHours opH = XC_DF_OperatingHours.createOperatingHours('TEST');
        insert opH;
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        
        ServiceTerritory servTerr = new ServiceTerritory();
        servTerr.XC_AccountId__c = accList[0].Id; 
        servTerr.Name = 'TEST';
        servTerr.OperatingHoursId = opH.id;
        insert servTerr;
        Test.startTest();
        List<ServiceResource> servList =  XC_DF_ServiceResource.createServiceResourcesFromAccount(accList);
        System.debug(servList);
        System.assertEquals(true, servList[0].IsActive);
        Test.stopTest();
    }
}