/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 09/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_BA004_PlanningPerfKPICalc_TEST – Test Class for XC_BA004_PlanningPerfKPICalc
 */
@IsTest
private without sharing class XC_BA004_PlanningPerfKPICalc_TEST {
    
    @TestSetup
    private static void testSetup() {
        User u = [SELECT Id FROM User WHERE Country__c = 'Italy' AND XC_LegalEntity__c = 'EnelXItalia' LIMIT 1];

        List<XC_CS012_SafetyPointsWalletSettings__c> settings = new List<XC_CS012_SafetyPointsWalletSettings__c>();
        XC_CS012_SafetyPointsWalletSettings__c setting1 = new XC_CS012_SafetyPointsWalletSettings__c();
        setting1.Name = 'EnelXItalia_Italy_1';
        setting1.XC_Country__c = 'Italy';
        setting1.XC_WalletNumber__c = 1;
        setting1.XC_MinimumPoints__c = 0;
        setting1.XC_MaximumPoints__c = 50;
        settings.add(setting1);

        XC_CS012_SafetyPointsWalletSettings__c setting2 = new XC_CS012_SafetyPointsWalletSettings__c();
        setting2.Name = 'EnelXItalia_Italy_2';
        setting2.XC_Country__c = 'Italy';
        setting2.XC_WalletNumber__c = 2;
        setting2.XC_MinimumPoints__c = 0;
        setting2.XC_MaximumPoints__c = 50;
        settings.add(setting2);

        XC_CS012_SafetyPointsWalletSettings__c setting3 = new XC_CS012_SafetyPointsWalletSettings__c();
        setting3.Name = 'EnelXItalia_Italy_3';
        setting3.XC_Country__c = 'Italy';
        setting3.XC_WalletNumber__c = 3;
        setting3.XC_MinimumPoints__c = 0;
        setting3.XC_MaximumPoints__c = 50;
        settings.add(setting3);

        insert settings;

        Account account1 = new Account();
        account1.Name = 'Account Test 1';
        account1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        account1.XC_SafetyPointsLicenseEnabled__c = true;
        account1.XC_SafetyPointLicenseActivationDate__c = System.now().addDays(-30);
        account1.Country__c = 'Italy';
        insert account1;

        List<XC_SafetyPointWallet__c> wallets = new List<XC_SafetyPointWallet__c>();
        for(Integer i = 1; i <= 3; i++) {
            XC_SafetyPointWallet__c w = new XC_SafetyPointWallet__c();
            w.XC_Account__c = account1.Id;
            w.XC_SPW_Number__c = i;
            w.XC_SPW_Balance__c = 50;
            w.XC_SPW_Status__c = i == 1 ? 'Active' : 'To be Active';
            wallets.add(w);
        }
        insert wallets;

        List<WorkOrder> workOrders = new List<WorkOrder>();
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkType('Delivery & Installation');
        insert workTypeToInsert;
        
        insert XC_DF_Address.createAddress(1);
        
        XC_Address__c address = [SELECT Id, XC_Address__c FROM XC_Address__c LIMIT 1];
        for(Integer i = 0; i < 5; i++) {
            WorkOrder wo = new WorkOrder();
            wo.XC_AssignedPartner__c = account1.Id;
            wo.XC_WorkTypeLabel__c = 'Delivery & Installation - Air Conditioning';
            wo.XC_WorkTypeCategory__c = 'Delivery & Installation';
            wo.WorkTypeId = workTypeToInsert.Id;
            wo.XC_LegalEntity__c = 'EnelXItalia';
        	wo.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EnelXItalia_WorkOrder').getRecordTypeId();
            wo.XC_Address__c = address.Id;
            wo.Street = address.XC_Address__c;
            wo.XC_Digitized__c = true;
            wo.XC_ToBeManuallyDigitalized__c = true;
            wo.XC_CreatedAutomaticallyBySystem__c = true;
            wo.XC_ScheduledStart__c = System.today();
            wo.XC_ScheduleDateTimestamp__c = System.today().addDays(-2);
            workOrders.add(wo);
        }
        insert workOrders;

        XC_KPI_Planning_Performance__c request = new XC_KPI_Planning_Performance__c();
        request.XC_Request_Type__c = 'Real';
        request.XC_User__c = u.Id;
        request.XC_Legal_Entity__c = 'EnelXItalia';
        request.XC_Country__c = 'Italy';
        request.XC_Request_Start_Date__c = System.now().addDays(-15);
        request.XC_Request_End_Date__c = System.now();
        insert request;
    }

    @IsTest
    private static void executeBatchTest() {
        XC_KPI_Planning_Performance__c request = [SELECT Id FROM XC_KPI_Planning_Performance__c LIMIT 1];

        Test.startTest();
        Database.executeBatch(new XC_BA004_PlanningPerfKPICalc(request.Id, 'Italy'));
        Test.stopTest();

        List<XC_KPI_Planning_Performance_Detail__c> details = [SELECT Id, XC_Request_Details__c FROM XC_KPI_Planning_Performance_Detail__c WHERE XC_Request_Status__c = 'Completed'];
        //System.assertEquals(1, details.size(), 'There is not a detail record completed');
        XC_KPI_Planning_Performance__c requestUpdated = [SELECT Id, XC_Request_Status__c FROM XC_KPI_Planning_Performance__c WHERE Id = :request.Id LIMIT 1];
        //System.assertEquals('Completed', requestUpdated.XC_Request_Status__c, 'Request is not set to Completed status');
    }

    @IsTest
    private static void executeBatchFromAccountListTest() {
        XC_KPI_Planning_Performance__c request = [SELECT Id FROM XC_KPI_Planning_Performance__c LIMIT 1];
        Account a = [SELECT Id FROM Account LIMIT 1];
        Set<String> accountIds = new Set<String>{a.Id};

        Test.startTest();
        Database.executeBatch(new XC_BA004_PlanningPerfKPICalc(accountIds, request.Id, 'Italy', 0));
        Test.stopTest();

        List<XC_KPI_Planning_Performance_Detail__c> details = [SELECT Id, XC_Request_Details__c FROM XC_KPI_Planning_Performance_Detail__c WHERE XC_Request_Status__c = 'Completed'];
        //System.assertEquals(1, details.size(), 'There is not a detail record completed');
        XC_KPI_Planning_Performance__c requestUpdated = [SELECT Id, XC_Request_Status__c FROM XC_KPI_Planning_Performance__c WHERE Id = :request.Id LIMIT 1];
        //System.assertEquals('Completed', requestUpdated.XC_Request_Status__c, 'Request is not set to Completed status');
    }

    @IsTest
    private static void executeBatchDemoTest() {
        XC_KPI_Planning_Performance__c request = [SELECT Id FROM XC_KPI_Planning_Performance__c LIMIT 1];
        request.XC_Request_Type__c = 'Test';
        update request;

        Test.startTest();
        Database.executeBatch(new XC_BA004_PlanningPerfKPICalc(request.Id, 'Italy'));
        Test.stopTest();

        List<XC_KPI_Planning_Performance_Detail__c> details = [SELECT Id FROM XC_KPI_Planning_Performance_Detail__c WHERE XC_Request_Status__c = 'Completed'];
        System.assertEquals(1, details.size(), 'Expected 1 details record, found ' + String.valueOf(details.size()));
        XC_KPI_Planning_Performance__c requestUpdated = [SELECT Id, XC_Request_Status__c FROM XC_KPI_Planning_Performance__c WHERE Id = :request.Id LIMIT 1];
        System.assertEquals('Completed', requestUpdated.XC_Request_Status__c, 'Request is not set to Completed status');
    }

    @IsTest
    private static void executeBatchFailTest() {
        List<XC_SafetyPointWallet__c> wallets = [SELECT Id FROM XC_SafetyPointWallet__c];
        delete wallets;

        XC_KPI_Planning_Performance__c request = [SELECT Id FROM XC_KPI_Planning_Performance__c LIMIT 1];

        Test.startTest();
        Database.executeBatch(new XC_BA004_PlanningPerfKPICalc(request.Id, 'Italy'));
        Test.stopTest();

        List<XC_KPI_Planning_Performance_Detail__c> details = [SELECT Id FROM XC_KPI_Planning_Performance_Detail__c WHERE XC_Request_Status__c = 'Error'];
        System.assertEquals(1, details.size(), 'Expected error on Planning Performance Deatil due to lack of wallets');
        XC_KPI_Planning_Performance__c requestUpdated = [SELECT Id, XC_Request_Status__c, XC_Request_Details__c FROM XC_KPI_Planning_Performance__c WHERE Id = :request.Id LIMIT 1];
        System.assertEquals('Error', requestUpdated.XC_Request_Status__c, 'Request is not set to Error status');
    }
}