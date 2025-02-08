/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 11/09/2019
* @date Modification:
* @description XC_LCC147_CustomerRequests_TEST - Test class for XC_LCC147_CustomerRequests_TEST
*/
@isTest
public without sharing class XC_LCC147_CustomerRequests_TEST {
    @isTest
    static void customerRequests() {
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        /*List<Account> account = XC_DF_Account.insertPartnerAccounts(1);
        List<User> listUser = new List<User>([
            SELECT Id 
            FROM User 
            WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true
        ]);
        ServiceResource serviceResourceToInsert = new ServiceResource();
        serviceResourceToInsert.Name = 'No Candidate Found';
        serviceResourceToInsert.XC_Account__c = account[0].Id;
        serviceResourceToInsert.IsActive = true;
        serviceResourceToInsert.IsCapacityBased = true;
        serviceResourceToInsert.ResourceType = 'T';
        if(!listUser.isEmpty()) {
            serviceResourceToInsert.RelatedRecordId = listUser[0].Id;
        }        
        Database.SaveResult srInsert = Database.insert(serviceResourceToInsert);*/
       	List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1,label.XC_CL_WorkType_DeliveryInstallation);
        insert listWorkOrder;
		String wo = listWorkOrder[0].id;   
        Test.startTest();
		XC_UTIL_ResultWrapper wrapper = XC_LCC147_CustomerRequestsAvailability.updateFLS(wo);
        System.assertEquals(wrapper.success, true);        
        Test.stopTest();        
    }
    
    
    @isTest
    static void customer() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> account = XC_DF_Account.insertPartnerAccounts(1);
        List<User> listUser = new List<User>([
            SELECT Id 
            FROM User 
            WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true
        ]);
        ServiceResource serviceResourceToInsert = new ServiceResource();
        serviceResourceToInsert.Name = 'No Candidate Found';
        serviceResourceToInsert.XC_Account__c = account[0].Id;
        serviceResourceToInsert.IsActive = true;
        serviceResourceToInsert.IsCapacityBased = true;
        serviceResourceToInsert.ResourceType = 'T';
        if(!listUser.isEmpty()) {
            serviceResourceToInsert.RelatedRecordId = listUser[0].Id;
        }        
        Database.SaveResult srInsert = Database.insert(serviceResourceToInsert);
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1,label.XC_CL_WorkType_PlannedMaintenance);
        insert listWorkOrder;
		String wo = listWorkOrder[0].id;   
        Test.startTest();
		XC_UTIL_ResultWrapper wrapper = XC_LCC147_CustomerRequestsAvailability.updateFLS(wo);
        System.assertEquals(wrapper.success, false);        
        Test.stopTest();        
    }
}