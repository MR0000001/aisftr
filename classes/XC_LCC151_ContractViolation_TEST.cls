/**
* @author Massimiliano Avallone - massimiliano.avallone@nttdata.com
* @date Creation: 09/09/2019
* @date Modification:
* @description XC_LCC151_ContractViolation_TEST - Test class for XC_LCC151_ContractViolation
*/
@isTest
public without sharing class XC_LCC151_ContractViolation_TEST {
    @isTest
    static  void contractViolation() {
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
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1,label.XC_CL_WorkType_Repair);
        insert listServiceAppointment;
		String saId = listServiceAppointment[0].id;   
        List<WorkOrder> woList = new List<WorkOrder>([    
		SELECT Id
        FROM WorkOrder
        WHERE Id =: listServiceAppointment[0].ParentRecordId
        ]);
		String woId = woList[0].id; 
        Test.startTest();
        XC_UTIL_ResultWrapper wrapper= XC_LCC151_ContractViolation.updateFLS(woId);
        //System.assertEquals(wrapper.success, true);
        Test.stopTest();        
    }
    
     @isTest
     static  void contrcact() {
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
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1,label.XC_CL_WorkType_CommercialVisit);
        insert listServiceAppointment;
		String saId = listServiceAppointment[0].id;   
        List<WorkOrder> woList = new List<WorkOrder>([    
		SELECT Id
        FROM WorkOrder
        WHERE Id =: listServiceAppointment[0].ParentRecordId
        ]);
		String woId = woList[0].id; 
        Test.startTest();
        XC_UTIL_ResultWrapper wrapper= XC_LCC151_ContractViolation.updateFLS(woId);
        System.assertEquals(wrapper.success, false);
        Test.stopTest();        
    }
}