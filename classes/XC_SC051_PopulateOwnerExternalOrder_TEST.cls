/**
* @author Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 23/04/2021
* @description XC_SC051_PopulateOwnerExternalOrder_TEST – Test class for XC_SC051_PopulateOwnerExternalOrder
*/
@isTest
public without sharing class XC_SC051_PopulateOwnerExternalOrder_TEST {

    @isTest
    static void executeBatch() {
        List<NE__Order__c> listOfOrder = XC_DF_Order.createOrders(1, 'Order');
        listOfOrder[0].XC_UserSubchannelCode__c = 'Test';
        listOfOrder[0].XC_LegalEntity__c = 'EndesaX';
        insert listOfOrder;
        User usTest = XC_DF_User.createUserAdmin();
        usTest.XC_SubChannel__c = 'Test';
        usTest.XC_LegalEntity__c = 'EndesaX';
        insert usTest;
        List<NE__Order__c> listOfOrderQuery = [SELECT Id, Name, Createddate, OwnerId, XC_SalesChannel__c, XC_SalesSubChannel__c, XC_UserChannelCode__c, XC_UserSubchannelCode__c, XC_CampaignPlatform__c, XC_LegalEntity__c  FROM NE__Order__c];
        System.debug('###MyQuery-->'+listOfOrderQuery);
        String query = 'SELECT Id, Name, Createddate, XC_SalesChannel__c, XC_SalesSubChannel__c, XC_UserChannelCode__c, XC_UserSubchannelCode__c, XC_CampaignPlatform__c, XC_LegalEntity__c  FROM NE__Order__c WHERE XC_UserSubchannelCode__c != null AND RecordType.name  = \''+'Order'+'\' AND  OwnerId NOT IN (SELECT Id FROM User WHERE XC_SubChannel__c != null) ORDER BY CreatedDate';
        System.debug('###Databasequery-->'+Database.query(query));
        Test.startTest();
        XC_SC051_PopulateOwnerExternalOrder myClass = new XC_SC051_PopulateOwnerExternalOrder(); 
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();

    }
}