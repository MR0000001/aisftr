/**
* @author Anna Maria Rosanova annamaria.rosanova@nttdata.com
* @date Creation  27/07/2019 
* @description XC_TR_WorkOrder_U_StartCongaW_TEST 
*/ 
@isTest
public class XC_TR_WorkOrder_U_StartCongaW_TEST {

    @TestSetup
    static void setup(){ 
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Info about Work Order Line Items', Country__c = 'Spain');
        insert template;
        APXTConga4__Conga_Template__c templateOKGAS = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mantenimiento OKGAS', Country__c = 'Spain');
        insert templateOKGAS;
        APXTConga4__Conga_Template__c templateOKGASReduced = new APXTConga4__Conga_Template__c(APXTConga4__Name__c = 'Mantenimiento GAS Reducido', Country__c = 'Spain');
        insert templateOKGASReduced;
        APXTConga4__Conga_Merge_Query__c congaQuery1 = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'QueryOnAccountByWorkOrder');
        insert congaQuery1;
        List<WorkOrder> workOrder = XC_DF_WorkOrder.createWorkOrdersWithWorkTypeName(1, 'Planned Maintenance - Gas', 'Planned Maintenance');
        workOrder[0].Status = 'In Progress';
        workOrder[0].XC_forSATO__c = true;
        workOrder[0].XC_ToBeManuallyDigitalized__c = true;
        insert workOrder;
    }

    @IsTest
    static void populateCongaFieldOnWOLITEST() {
		Test.startTest();
        WorkOrder selectWoType = [SELECT id, XC_ToBeManuallyDigitalized__c FROM WorkOrder LIMIT 1]; 
        selectWoType.XC_ToBeManuallyDigitalized__c = true;
        selectWoType.XC_CreateReducedReport__c = true;
        update selectWoType;

        System.assert(selectWoType!= null, selectWoType );
		Test.stopTest();
    }

    @IsTest
    static void getTemplateNameInstallationTEST() {           
	    Test.startTest();

        List<WorkOrder> workOrderSICAL = XC_DF_WorkOrder.createWorkOrdersAsset(1, Label.XC_CL_WorkTypeLabel_InstallationAirConditioning, 'Installation', 'Soluciones Caldera');
        workOrderSICAL[0].XC_ToBeManuallyDigitalized__c = true;        
        workOrderSICAL[0].XC_forSATO__c = true;
        insert workOrderSICAL;
        workOrderSICAL[0].XC_CreateReducedReport__c = true;
        update workOrderSICAL;
		Test.stopTest();

        List<WorkOrder> workOrderSIAC = XC_DF_WorkOrder.createWorkOrdersAsset(1, Label.XC_CL_WorkTypeLabel_InstallationAirConditioning, 'Installation', 'Soluciones Aire Acondicionado');
        workOrderSIAC[0].XC_ToBeManuallyDigitalized__c = true;        
        workOrderSIAC[0].XC_forSATO__c = true;
        insert workOrderSIAC;
        workOrderSIAC[0].XC_ToBeManuallyDigitalized__c = true; 
        workOrderSIAC[0].XC_CreateReducedReport__c = true;
        update workOrderSIAC;
        System.assert(workOrderSIAC!= null, workOrderSIAC );
    }    


    
    @IsTest
    static void getTemplateNameRepairTEST() {           
        List<WorkOrder> workOrderOKLUZ = XC_DF_WorkOrder.createWorkOrdersAsset(1, 'Repair - Light', 'Repair', 'OK Luz');
        workOrderOKLUZ[0].XC_ToBeManuallyDigitalized__c = true;        
        workOrderOKLUZ[0].XC_forSATO__c = true;
        insert workOrderOKLUZ;
        workOrderOKLUZ[0].XC_CreateReducedReport__c = true; 
        update workOrderOKLUZ;
	    Test.startTest();
        List<WorkOrder> workOrderOKGAS = XC_DF_WorkOrder.createWorkOrdersAsset(1, 'Repair - Gas', 'Repair', 'OK Gas');
        workOrderOKGAS[0].XC_CreateReducedReport__c = true;        
        workOrderOKGAS[0].XC_forSATO__c = true;
        insert workOrderOKGAS;
        workOrderOKGAS[0].XC_ToBeManuallyDigitalized__c = true; 
        workOrderOKGAS[0].XC_CreateReducedReport__c = true; 
        update workOrderOKGAS;
		Test.stopTest();

        System.assert(workOrderOKGAS!= null, workOrderOKGAS );
    }

    @IsTest
    static void getTemplateNamePlannedMaintenanceAragonTEST() {     
	    Test.startTest();
        XC_Address__c addressToInsert = new XC_Address__c();
        addressToInsert.XC_Address__c = 'GOMEZ MIEDES';
        addressToInsert.XC_City__c = 'ALCAÑIZ';
        addressToInsert.XC_AddressCountry__c = 'Spain';
        addressToInsert.XC_PostalCode__c = '44600';
        addressToInsert.XC_AddressProvince__c = 'Teruel';
        addressToInsert.XC_StreetNumber__c = '20';
        addressToInsert.XC_StreetType__c = 'Street'; 
        addressToInsert.XC_Municipality__c   = 'ALCAÑIZ';
        addressToInsert.XC_InstallationAddress__c = TRUE;
        addressToInsert.XC_DeliveryAddress__c = TRUE;
        addressToInsert.XC_BillingAddress__c = TRUE;
        addressToInsert.XC_PickUpPoint__c = TRUE;
        addressToInsert.XC_PointOfSales__c = TRUE;
        addressToInsert.XC_WareHouse__c = TRUE;
        insert addressToInsert;


        List<Asset> assetToInsert = XC_DF_Asset.createAssets(1);  
        assetToInsert[0].Name = 'Ok Gas';
        assetToInsert[0].XC_LegalEntity__c = 'EndesaX';
        assetToInsert[0].XC_Address__c = addressToInsert.id;

        insert assetToInsert;
        System.debug ('@@@@ assetToInsert' + assetToInsert);
        
        WorkType workTypeToInsert = XC_DF_WorkType.createWorkTypeWithName('Installation', 'Installation - Gas');
        insert workTypeToInsert;
        WorkOrder workOrderToInsert = new WorkOrder();
        workOrderToInsert.XC_WorkTypeLabel__c = workTypeToInsert.Name;
        workOrderToInsert.WorkTypeId = workTypeToInsert.Id;
        workOrderToInsert.AssetId =assetToInsert[0].id;
        workOrderToInsert.XC_Address__c = addressToInsert.id;
        workOrderToInsert.XC_ToBeManuallyDigitalized__c = true;
        workOrderToInsert.XC_forSATO__c = true;
        workOrderToInsert.XC_LegalEntity__c = 'EndesaX';

        insert workOrderToInsert;
        workOrderToInsert.XC_CreateReducedReport__c = true;
        update workOrderToInsert;

		Test.stopTest();

        System.assert(assetToInsert!= null, assetToInsert );
    }
    
    @IsTest
    static void getReducedReport() {           
        List<WorkOrder> workOrderOKLUZlist = XC_DF_WorkOrder.createWorkOrdersAsset(1, 'Repair - Light', 'Repair', 'OK Luz');
        WorkOrder workOrderOKLUZ = workOrderOKLUZlist[0];
        workOrderOKLUZ.XC_CreateReducedReport__c = false;        
        workOrderOKLUZ.XC_forSATO__c = true;
        workOrderOKLUZ.XC_WorkTypeLabel__c = 'Repair - Handy Assistance';
        insert workOrderOKLUZ;
        workOrderOKLUZ.XC_CreateReducedReport__c = true;
        Test.startTest();
        update workOrderOKLUZ;
		Test.stopTest();
        System.assert(workOrderOKLUZ!= null, workOrderOKLUZ );
    }
    
    @IsTest
    static void diagnosticWOWithDictamen() {           
        List<WorkOrder> workOrderOlist = XC_DF_WorkOrder.createWorkOrdersAsset(1, 'Diagnostic - Gas', 'Diagnostic', 'OK Gas');
        WorkOrder workOrderO = workOrderOlist[0];
        workOrderO.XC_CreateReducedReport__c = false;        
        workOrderO.XC_forSATO__c = true;
        insert workOrderO;
        XC_DictamenItem__c dictamenItem = new XC_DictamenItem__c();
        dictamenItem.XC_WorkOrder__c = workOrderO.Id;
        insert dictamenItem;
        workOrderO.XC_CreateReducedReport__c = true;
        Test.startTest();
        update workOrderO;
		Test.stopTest();
        System.assert(workOrderO!= null, workOrderO );
    }
}