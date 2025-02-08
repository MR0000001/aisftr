/**
* @author Roberta Cossiga - rcossiga@deloitte.it
* @date Creation 15/05/2019
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_U_MaintPlan_TEST – Test Class for XC_TR_WorkOrder_U_MaintenancePlan
*/ 

@isTest
public class XC_TR_WorkOrder_U_MaintPlan_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        org.XC_Spain_ValidationRules__c =  true;
        insert org;
    }

     static testMethod void onInsertMaint1(){
        List<Asset> assetList = XC_DF_Asset.createAssets(1);
        List<Asset> assetToInsert = new List<Asset>(); 
        for (Asset a : assetList){
             a.XC_ActivationDate__c = System.now();
            assetToInsert.add(a);
        }
        insert assetToInsert; 
        List<Asset> assetListInserted = [SELECT Id FROM Asset]; 
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        for(WorkOrder wo : woList){
            wo.XC_PositionInMaintenancePlan__c = 1;
            wo.XC_CreateMaintenanceServiceAppointment__c = true;
            wo.AssetId = assetListInserted[0].Id;
            woListInsert.add(wo);
        }
        Test.startTest();
        insert woListInsert;
        List<WorkOrder> listWoInserted = [SELECT Id FROM WorkOrder];
        System.assertEquals(1, listWoInserted.size());
        Test.stopTest();
    }
    
    static testMethod void onInsertMaint2(){
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        List<WorkOrder> woListInsert = new List<WorkOrder>();
        for(WorkOrder wo : woList){
            wo.XC_PositionInMaintenancePlan__c = 1;
            wo.XC_CreateMaintenanceServiceAppointment__c = true;
            woListInsert.add(wo);
        }        
        insert woListInsert;
        List<WorkOrder> listWoInserted = [SELECT Id FROM WorkOrder];
        List<ServiceAppointment> saListToInsert = new List<ServiceAppointment> ();
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(listWoInserted);
        for(ServiceAppointment sa : saList){
            sa.Status = Label.XC_CL_ServiceAppointment_Completed;
            saListToInsert.add(sa);
        }
        insert saListToInsert;
        List<WorkOrder> woList2 = XC_DF_WorkOrder.createWorkOrders(1, 'Planned Maintenance');
        List<WorkOrder> woListInsert2 = new List<WorkOrder>();
        for(WorkOrder wo : woList2){
            wo.XC_PositionInMaintenancePlan__c = 2;
            wo.XC_PreviousMaintenanceWorkOrder__c = listWoInserted[0].Id;
            wo.XC_CreateMaintenanceServiceAppointment__c = true;
            woListInsert2.add(wo);
        }  
        Test.startTest();
        insert woListInsert2;
        List<WorkOrder> listWoInserted2 = [SELECT Id FROM WorkOrder];
        System.assertEquals(2, listWoInserted2.size());
        Test.stopTest();
    }


}