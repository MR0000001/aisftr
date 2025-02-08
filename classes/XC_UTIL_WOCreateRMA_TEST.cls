/**
* @author Domenico Del Prete domenico.delprete@nttdata.com
* @date Creation  12/06/2020
* @description XC_UTIL_WOCreateGoodIssue_TEST – Test class for XC_UTIL_WOCreateGoodIssue 
*/ 
@isTest
public without sharing class XC_UTIL_WOCreateRMA_TEST {

    @isTest
    private static void onInsert() {

        // NOTA BENE: Il metodo verrà chiamato esplicitamente anziché triggerarlo

        insert XC_DF_OneOrg.createOneOrg('Spain');
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_WorkType_DeliveryInstallation);
        listSa[0].ActualStartTime = Datetime.now();
        listSa[0].ActualEndTime = Datetime.now().addDays(6);
        listSa[0].ArrivalWindowStartTime = Datetime.now();
        listSa[0].ArrivalWindowEndTime = Datetime.now().addDays(6);
        listSa[0].EarliestStartTime = Datetime.now().addDays(-10);
        listSa[0].SchedStartTime = Datetime.now();
        listSa[0].SchedEndTime = Datetime.now().addDays(6);
        listSa[0].XC_StartService__c = Datetime.now();
        insert listSa;
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);//new List<Account>([SELECT Id, Name FROM Account LIMIT1]);
        List<ServiceTerritory> listSt = XC_DF_ServiceTerritory.createServiceTerritories(accList);
        insert listSt;
        OperatingHours oh = XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        insert oh;
        ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
        srtmemb.ServiceTerritoryId = listSt[0].Id;
        srtmemb.ServiceResourceId = listSr[0].Id;
        srtmemb.EffectiveStartDate = DateTime.now().addDays(-100);
        srtmemb.OperatingHoursId = oh.Id;        
        insert srtmemb;

        AssignedResource ar = new AssignedResource(
            ServiceAppointmentId = listSa[0].Id,
            ServiceResourceId = listSr[0].Id
        );
        gii__Warehouse__c wh = new gii__Warehouse__c(
            gii__Account__c = listSr[0].XC_Account__c,
            gii__WareHouseCountry__c = 'Spain',
            gii__WareHouseStateProvince__c = 'Madrid',
            gii__WareHouseStreet__c = 'Test',
            gii__WareHouseZipPostalCode__c = '28050',
            gii__WareHouseCity__c = 'Madrid',
            giic_WarehouseCode__c = 'Test',
            giic_LegalEntity__c = 'EndesaX'
        );
        insert wh;
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Spain'
        );
        insert p2;
        List<gii__Product2Add__c> pAdd = new List<gii__Product2Add__c>([
            SELECT Id
            FROM gii__Product2Add__c
            LIMIT 1
        ]);
        pAdd[0].giic_ProcurementType__c = 'Transfer';
        update pAdd;
        ProductRequired pr = new ProductRequired(
            ParentRecordId = listSa[0].ParentRecordId,
            Product2Id = p2.Id,
            XC_ProcurementType__c = 'Transfer',
            QuantityRequired = 1,
            XC_Mode__c = 'Remove'
        );
        insert pr;
        insert ar;

        Test.startTest();
        WorkOrder wo = new WorkOrder (Id = listSa[0].ParentRecordId);
        wo.XC_AssignedPartner__c = listSr[0].XC_Account__c;
        wo.State = 'Madrid';
        wo.XC_LegalEntity__c = 'EndesaX';
        wo.State = '28050';
        update wo;
        XC_UTIL_WOCreateRMA.createRMA(new List<WorkOrder>{wo});
        System.assertNotEquals(null, listSa[0].ParentRecordId);
        Test.stopTest();
    }
}