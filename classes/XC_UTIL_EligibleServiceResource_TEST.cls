/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 17/01/2020
* @description XC_UTIL_EligibleServiceResource_TEST – Test class for XC_UTIL_EligibleServiceResource
*/

@isTest
private class XC_UTIL_EligibleServiceResource_TEST {

    @TestSetup 
    static void createRecords() { 
        // Create Service Resource:
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        Account acc = accountList[0];
        List<ServiceResource> serResourceList = XC_DF_ServiceResource.createServiceResourcesFromAccount(accountList);
        ServiceResource sr = serResourceList[0];
        String zipCode = '28080';
        WorkType wtCV = XC_DF_WorkType.createWorkType('Commercial Visit');
        insert wtCV;
		XC_PartnerCoverage__c cov = new XC_PartnerCoverage__c(
            XC_Account__c = accountList[0].Id, 
            XC_ExternalId__c = zipCode +'_'+wtCV.Id
        );
        insert cov;
    }
    
    @isTest
    private static void getPartnerCoveragesTest() {
        WorkType wt = [
            SELECT Id, XC_WorkTypeCategory__c 
            FROM WorkType 
            LIMIT 1
        ];
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, wt.XC_WorkTypeCategory__c);
        insert woList;

        List<ServiceResource> listSR = new List<ServiceResource>([SELECT Id, XC_Account__c FROM ServiceResource]);
        ResourcePreference rp = new ResourcePreference(RelatedRecordId = woList[0].Id, ServiceResourceId = listSR[0].Id);
        insert rp;
        XC_PartnerCoverage__c pc = new XC_PartnerCoverage__c(XC_ExternalId__c = '28080'+wt.Id, XC_Account__c = listSR[0].XC_Account__c);
        List<String> accList = new List<String>();
        accList.add((String)listSR[0].XC_Account__c);

        Test.startTest();
        XC_UTIL_EligibleServiceResource.EligibleWrapper wrap = XC_UTIL_EligibleServiceResource.checkAvailability(woList[0].Id, '28080', wt.Id, '', true);
        XC_UTIL_EligibleServiceResource.checkAvailability(woList[0].Id, '28080', wt.Id, '', true);
        XC_UTIL_EligibleServiceResource.checkAvailabilityOnAutoSchedule(woList[0].Id, '28080', wt.Id, accList ,true);
        XC_UTIL_EligibleServiceResource.getDateAvailabilityInsertPreferences(woList[0].Id, '28080', wt.Id, '', true);
        XC_UTIL_EligibleServiceResource.isForTest = true;
        XC_UTIL_EligibleServiceResource.checkAvailability(woList[0].Id, '28080', wt.Id);
        XC_UTIL_EligibleServiceResource.checkAvailabilityOnAutoSchedule(woList[0].Id, '28080', wt.Id, accList ,true);
        Test.stopTest();
        System.assertNotEquals(wrap, null);
    }
    /*
    @isTest
    static void test_checkAvailability2() {
        List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
        WorkType wt = [
            SELECT Id, XC_WorkTypeCategory__c 
            FROM WorkType 
            LIMIT 1
        ];
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, wt.XC_WorkTypeCategory__c);
        insert woList;
         Test.startTest();
        	XC_UTIL_EligibleServiceResource.EligibleWrapper wrap = XC_UTIL_EligibleServiceResource.checkAvailability(woList[0].Id, '28080', wt.Id,accountList[0].Id);
        Test.stopTest();
    }
    */

}