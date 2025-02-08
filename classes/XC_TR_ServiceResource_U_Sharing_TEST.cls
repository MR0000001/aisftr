/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 03/09/2019
* @description XC_TR_ServiceResource_U_Sharing_TEST – Test class for XC_TR_ServiceResource_U_Sharing
*/

@isTest
private without sharing class XC_TR_ServiceResource_U_Sharing_TEST {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceResource_U_Sharing_TEST');
	@TestSetup
    static void makeData(){
       User contextUser= [SELECT Id FROM User WHERE isActive = true AND  UserRoleId != null AND Profile.Name ='System Administrator' LIMIT 1];
       
        System.runAs(contextUser) {
             test.startTest();
             List<Account> accountList = XC_DF_Account.insertPartnerAccounts(1);
            List<Contact> contactP = XC_DF_Contact.createPartnerContacts(accountList);
            insert contactP;
            Test.stopTest();
            List<User> usersList = XC_DF_User.createCommunityUsers(contactP,false);
			insert usersList;
        }
       
    }
    @isTest
    static void testSharingServiceResource() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        List<Account> account = XC_DF_Account.insertPartnerAccounts(1);
        List<User> listUser = new List<User>([
            SELECT Id 
            FROM User 
            WHERE Profile.Name = 'XC_ESP_SalesAgentPartner' AND isActive = true
        ]);

        ServiceResource serviceResourceToInsert = new ServiceResource();
        serviceResourceToInsert.Name = account[0].Name;
        serviceResourceToInsert.XC_Account__c = account[0].Id;
        serviceResourceToInsert.IsActive = true;
        serviceResourceToInsert.IsCapacityBased = true;
        serviceResourceToInsert.ResourceType = 'T';
        if(!listUser.isEmpty()) {
            serviceResourceToInsert.RelatedRecordId = listUser[0].Id;
        }        
        Test.startTest();
        Database.SaveResult srInsert = Database.insert(serviceResourceToInsert);
        serviceResourceToInsert.isActive = false;
        Database.SaveResult srUpdateInactive = Database.update(serviceResourceToInsert);
        Test.stopTest();

        System.assertEquals(srInsert.isSuccess(), true);
        System.assertEquals(srUpdateInactive.isSuccess(), true);
    }

}