/**
 * @author Alessandro Catto - alessandro11.catto@nttdata.com
 * @date Creation 09/05/2022
 * @date Modification  dd/mm/yyyy
 * @description XC_BA004_PlanningPerfKPICalc_U_TEST – Test Class for XC_BA004_PlanningPerfKPICalc_U
 */
@IsTest
private without sharing class XC_BA004_PlanningPerfKPICalc_U_TEST {
    
    @TestSetup
    private static void testSetup() {
        User u = [SELECT Id FROM User WHERE Country__c = 'Italy' AND XC_LegalEntity__c = 'EnelXItalia' LIMIT 1];

        List<XC_CS013_PlanningPerformanceWorkTypes__c> ppWorkTypes = new List<XC_CS013_PlanningPerformanceWorkTypes__c>();
        XC_CS013_PlanningPerformanceWorkTypes__c ppWorkType1 = new XC_CS013_PlanningPerformanceWorkTypes__c();
        ppWorkType1.Name = 'PP Work Type Italy 1';
        ppWorkType1.XC_LegalEntity__c = 'EnelXItalia';
        ppWorkType1.XC_Country__c = 'Italy';
        ppWorkType1.XC_WorkTypeName__c = 'Delivery & Installation - Air Conditioning';
        ppWorkTypes.add(ppWorkType1);

        XC_CS013_PlanningPerformanceWorkTypes__c ppWorkType2 = new XC_CS013_PlanningPerformanceWorkTypes__c();
        ppWorkType2.Name = 'PP Work Type Italy 2';
        ppWorkType2.XC_LegalEntity__c = 'EnelXItalia';
        ppWorkType2.XC_Country__c = 'Italy';
        ppWorkType2.XC_WorkTypeName__c = 'Delivery & Installation - Boiler';
        ppWorkTypes.add(ppWorkType2);

        insert ppWorkTypes;

        List<XC_CS015_SafetyPoint_KPI__c> spKPIs = new List<XC_CS015_SafetyPoint_KPI__c>();
        XC_CS015_SafetyPoint_KPI__c spKPI1 = new XC_CS015_SafetyPoint_KPI__c();
        spKPI1.Name = 'Planning Performance Threshold 1';
        spKPI1.XC_LegalEntity__c = 'EnelXItalia';
        spKPI1.XC_Country__c = 'Italy';
        spKPI1.XC_KPI_Type__c = 'Planning Performance';
        spKPI1.XC_Min__c = 50;
        spKPI1.XC_Max__c = 75;
        spKPI1.XC_Points__c = 0;
        spKPIs.add(spKPI1);

        XC_CS015_SafetyPoint_KPI__c spKPI2 = new XC_CS015_SafetyPoint_KPI__c();
        spKPI2.Name = 'Planning Performance Threshold 2';
        spKPI2.XC_LegalEntity__c = 'EnelXItalia';
        spKPI2.XC_Country__c = 'Italy';
        spKPI2.XC_KPI_Type__c = 'Planning Performance';
        spKPI2.XC_Min__c = 75;
        spKPI2.XC_Max__c = 100;
        spKPI2.XC_Points__c = 2;
        spKPIs.add(spKPI2);

        insert spKPIs;

        Account account1 = new Account();
        account1.Name = 'Account Test 1';
        account1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('XC_Account_Partner').getRecordTypeId();
        account1.XC_SafetyPointsLicenseEnabled__c = true;
        account1.Country__c = 'Italy';
        insert account1;

        List<XC_SafetyPointWallet__c> wallets = new List<XC_SafetyPointWallet__c>();
        for(Integer i = 1; i < 4; i++) {
            XC_SafetyPointWallet__c w = new XC_SafetyPointWallet__c();
            w.XC_Account__c = account1.Id;
            w.XC_SPW_Number__c = i;
            w.XC_SPW_Balance__c = 50;
            w.XC_SPW_Status__c = i == 0 ? 'Active' : 'To be Active';
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
            wo.Status = 'Completed';
            wo.XC_LegalEntity__c = 'EnelXItalia';
        	wo.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_B2C_EnelXItalia_WorkOrder').getRecordTypeId();
            wo.XC_Address__c = address.Id;
            wo.Street = address.XC_Address__c;
            wo.XC_Digitized__c = true;
            wo.XC_ToBeManuallyDigitalized__c = true;
            wo.XC_CreatedAutomaticallyBySystem__c = true;
            wo.XC_ScheduledStart__c = System.today();
            wo.XC_ScheduleDateTimestamp__c = System.today().addDays(-2);
            wo.XC_ActualEndDate__c = System.today();
            wo.StartDate = System.today().addDays(-20);
            wo.EndDate = System.today();
            workOrders.add(wo);
        }
        insert workOrders;

        XC_KPI_Planning_Performance__c request = new XC_KPI_Planning_Performance__c();
        request.XC_Request_Type__c = 'Real';
        request.XC_User__c = u.Id;
        request.XC_Legal_Entity__c = 'EnelXItalia';
        request.XC_Country__c = 'Italy';
        request.XC_Request_Start_Date__c = System.now().addDays(-30);
        request.XC_Request_End_Date__c = System.now();
        insert request;
    }

    @IsTest
    private static void computeNumTest() {
        List<WorkOrder> workOrders = [SELECT Id, XC_ScheduledStart__c, XC_ScheduleDateTimestamp__c, XC_Overall_EndDate__c FROM WorkOrder];

        Test.startTest();
        Decimal num = XC_BA004_PlanningPerfKPICalc_U.computeNum(workOrders);
        Test.stopTest();

        System.assertEquals(5, num, 'Expected 5, found ' + String.valueOf(num));
    }

    @IsTest
    private static void computeDenomTest() {
        List<WorkOrder> workOrders = [SELECT Id, XC_ScheduledStart__c, XC_ScheduleDateTimestamp__c, XC_Overall_EndDate__c FROM WorkOrder];

        Test.startTest();
        Decimal denom = XC_BA004_PlanningPerfKPICalc_U.computeDenom(workOrders);
        Test.stopTest();

        System.assertEquals(5, denom, 'Expected 5, found ' + String.valueOf(denom));
    }

    @IsTest
    private static void createKPIDetailTest() {
        XC_KPI_Planning_Performance__c r = [SELECT Id, XC_Legal_Entity__c, XC_Country__c FROM XC_KPI_Planning_Performance__c LIMIT 1];
        Account a = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        XC_KPI_Planning_Performance_Detail__c detail = XC_BA004_PlanningPerfKPICalc_U.createKPIDetail(r.Id, a.Id, r.XC_Country__c);
        Test.stopTest();

        System.assertEquals('Completed', detail.XC_Request_Status__c, 'There is no Completed Planning Performance Detail record');
    }

    @IsTest
    private static void createKPIDetailErrorTest() {
        XC_KPI_Planning_Performance__c r = [SELECT Id, XC_Legal_Entity__c, XC_Country__c FROM XC_KPI_Planning_Performance__c LIMIT 1];
        Account a = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        XC_KPI_Planning_Performance_Detail__c detail = XC_BA004_PlanningPerfKPICalc_U.createKPIDetailError(r.Id, a.Id, r.XC_Country__c, 'Messaggio di errore');
        Test.stopTest();

        System.assertEquals('Error', detail.XC_Request_Status__c, 'There is no Error Planning Performance Detail record');
        System.assertEquals('Messaggio di errore', detail.XC_Request_Details__c, 'Error message has not been set');
    }
}