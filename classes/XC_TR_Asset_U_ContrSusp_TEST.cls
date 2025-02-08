/**
 * The Class XC_TR_Asset_U_ContrSusp_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 21/06/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_TR_Asset_U_ContractSuspension
 **/


@isTest
public without sharing class XC_TR_Asset_U_ContrSusp_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
    }


    @isTest
    static void testSuspendedAsset(){
		NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = Label.XC_CL_Catalog_eHome, Name =Label.XC_CL_Catalog_eHome );
        insert catalog;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = 'Active';
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        //assetList[0].XC_Product_Subtype__c = 'Boiler';
        //assetList[0].NE__Catalog__c = catalog.Id;
        insert assetList;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        update assetList;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        woList[0].AssetId = assetList[0].Id;
        insert woList;

        List<ServiceAppointment> serAppList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        serAppList[0].Status = Label.XC_CL_ServiceAppointment_Scheduled;
        insert serAppList;

        test.startTest();
        assetList[0].Status = Label.XC_CL_Asset_StatusSuspended;
        update assetList;
        test.stopTest();

        System.assertEquals(Label.XC_CL_Asset_StatusSuspended, assetList[0].Status, 'Wrong assert equals');
    }


    @isTest
    static void testActivatedAssetFuture(){
		NE__Catalog__c catalog = new NE__Catalog__c(XC_LIC_Name__c = Label.XC_CL_Catalog_eHome, Name =Label.XC_CL_Catalog_eHome );
        insert catalog;
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = Label.XC_CL_Asset_StatusSuspended;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_Subtype__c = 'Boiler';
        //assetList[0].NE__Catalog__c = catalog.Id;
        insert assetList;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        update assetList;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        woList[0].AssetId = assetList[0].Id;
        insert woList;

        List<ServiceAppointment> serAppList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        serAppList[0].Status = Label.XC_CL_ServiceAppointment_OnHold;
        serAppList[0].XC_Reason_Cannot_Complete__c = Label.XC_CL_ServiceAppointment_Dunning;
        serAppList[0].SchedEndTime = System.Today().addMonths(1);
        serAppList[0].SchedStartTime = System.Today().addDays(-3);
        insert serAppList;

        test.startTest();
        assetList[0].Status = 'Active';
        update assetList;
        test.stopTest();

        System.assertEquals('Active', assetList[0].Status, 'Wrong assert equals');
    }


    @isTest
    static void testActivatedAssetPast(){

        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        assetList[0].Status = Label.XC_CL_Asset_StatusSuspended;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        assetList[0].XC_Product_Subtype__c = 'Boiler';
        insert assetList;
        assetList[0].XC_LegalEntity__c = 'EndesaX';
        update assetList;

        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Commercial Visit');
        woList[0].AssetId = assetList[0].Id;
        insert woList;

        List<ServiceAppointment> serAppList = XC_DF_ServiceAppointment.createServiceAppointment(woList);
        serAppList[0].Status = Label.XC_CL_ServiceAppointment_OnHold;
        serAppList[0].XC_Reason_Cannot_Complete__c = Label.XC_CL_ServiceAppointment_Dunning;
        serAppList[0].DueDate = System.Today().addMonths(-1);
        serAppList[0].EarliestStartTime = serAppList[0].DueDate.addDays(-1);
        insert serAppList;

        test.startTest();
        assetList[0].Status = 'Active';
        update assetList;
        test.stopTest();
        
        System.assertEquals('Active', assetList[0].Status, 'Wrong assert equals');
    }
}