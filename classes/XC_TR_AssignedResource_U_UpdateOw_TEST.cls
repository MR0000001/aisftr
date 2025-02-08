/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  24/05/2019 
* @date Modification 18/06/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_TR_AssignedResource_U_UpdateOw_TEST – Test class for XC_TR_AssignedResource_U_UpdateOwner
*/

@isTest
public class XC_TR_AssignedResource_U_UpdateOw_TEST {
        @TestSetup
    static void setup(){ 
        List<ServiceResource> listServiceResource = XC_DF_ServiceResource.createServiceResources(2);
        OperatingHours opHours = XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        insert opHours;
        //OperatingHours opHours = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar' LIMIT 1];
        ServiceTerritory rootToInsert = new ServiceTerritory();
        rootToInsert.Name = 'Territory Root';
        rootToInsert.XC_AccountId__c = listServiceResource[0].XC_Account__c;
        rootToInsert.OperatingHoursId = opHours.Id;
        rootToInsert.isActive = true;
        insert rootToInsert;
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_WorkType_PlannedMaintenance);
        listServiceAppointment[0].Status = Label.XC_CL_ServiceAppointment_OnHold ; 
        listServiceAppointment[0].SchedStartTime = System.now();
        listServiceAppointment[0].SchedEndTime = System.now().addDays(1);
        listServiceAppointment[0].ServiceTerritoryId = rootToInsert.Id;
        
        insert listServiceAppointment;
   	}
        
     static testMethod void updateFieldsOnUpdateWithWorkTypePlannedMaintenance(){
        //insert XC_DF_OneOrg.createOneOrg('Spain');
        OperatingHours opHours = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar' LIMIT 1];
		List<ServiceAppointment> listServiceAppointment = [SELECT Id, ParentRecordId, ServiceTerritoryId FROM ServiceAppointment];
        ServiceTerritory rootToInsert = [SELECT Id, XC_AccountId__c FROM ServiceTerritory LIMIT 1];
		List<ServiceResource> listServiceResource =[SELECT Id, XC_Account__c FROM ServiceResource];
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            EffectiveStartDate = System.now().addDays(-1),
            ServiceTerritoryId = rootToInsert.Id, 
            ServiceResourceId = listServiceResource[0].Id, 
            OperatingHoursId = opHours.Id,
            TerritoryType = 'P'
        );
        insert stm;
        AssignedResource ar = new AssignedResource(
            ServiceAppointmentId = listServiceAppointment[0].Id,
            ServiceResourceId = listServiceResource[0].Id
        );
        // WorkOrders creati nel data factory:
        List<WorkOrder> listWorkOrder = [SELECT ID FROM WorkOrder WHERE id=:listServiceAppointment[0].ParentRecordId];
		List<Asset> listAsset= XC_DF_Asset.createAssets(1);
        insert listAsset;
        Test.startTest(); 
        listWorkOrder[0].AssetId=listAsset[0].id;
        update listWorkOrder;
        System.assertNotEquals(listServiceAppointment, null);
        insert ar;
        rootToInsert.XC_AccountId__c = listServiceResource[1].XC_Account__c;    
        update rootToInsert;
        stm.ServiceResourceId = listServiceResource[1].Id;
        update stm;
         Test.stopTest();
        List<ServiceAppointment> listServiceAppointmentCommercialVisit = XC_DF_ServiceAppointment.createServiceAppointment(1);
        listServiceAppointmentCommercialVisit[0].SchedStartTime = System.now();
        listServiceAppointmentCommercialVisit[0].SchedEndTime = System.now().addDays(1);
        listServiceAppointmentCommercialVisit[0].ServiceTerritoryId = rootToInsert.Id;
        insert listServiceAppointmentCommercialVisit;
        AssignedResource arCommercialVisit = new AssignedResource(
            ServiceAppointmentId = listServiceAppointmentCommercialVisit[0].Id,
            ServiceResourceId = listServiceResource[1].Id
        );
        insert arCommercialVisit;
        arCommercialVisit.ServiceResourceId = listServiceResource[1].Id;
        update arCommercialVisit;
        
    }
    
    static testMethod void updateFieldsOnUpdateWithWorkTypeRepair(){
       insert XC_DF_OneOrg.createOneOrg('Spain');
        List<ServiceResource> listServiceResource = [SELECT Id, XC_Account__c FROM ServiceResource]; //XC_DF_ServiceResource.createServiceResources(1);
        insert XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        OperatingHours opHours = [SELECT Id, Name FROM OperatingHours WHERE Name = 'Gold Appointment Calendar' LIMIT 1];
        ServiceTerritory rootToInsert = [SELECT Id,Name, XC_AccountId__c,OperatingHoursId,isActive FROM ServiceTerritory LIMIT 1];
        List<ServiceAppointment> listServiceAppointment = XC_DF_ServiceAppointment.createServiceAppointment(1, Label.XC_CL_WorkType_Repair);
        listServiceAppointment[0].Status = Label.XC_CL_ServiceAppointment_OnHold ; 
        listServiceAppointment[0].SchedStartTime = System.now();
        listServiceAppointment[0].SchedEndTime = System.now().addDays(1);
        listServiceAppointment[0].ServiceTerritoryId = rootToInsert.Id;
        insert listServiceAppointment;
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            EffectiveStartDate = System.now().addDays(-1),
            ServiceTerritoryId = rootToInsert.Id, 
            ServiceResourceId = listServiceResource[0].Id, 
            OperatingHoursId = opHours.Id,
            TerritoryType = 'P'
        );
        insert stm;
        Test.startTest(); 
        AssignedResource ar = new AssignedResource(
            ServiceAppointmentId = listServiceAppointment[0].Id,
            ServiceResourceId = listServiceResource[0].Id
        );
        // WorkOrders creati nel data factory:
        List<WorkOrder> listWorkOrder = [SELECT ID FROM WorkOrder WHERE id=:listServiceAppointment[0].ParentRecordId];
		List<Asset> listAsset= XC_DF_Asset.createAssets(1);
        insert listAsset;
        listWorkOrder[0].AssetId=listAsset[0].id;
        update listWorkOrder;
        System.assertNotEquals(listServiceAppointment, null);

        
        insert ar;
        Test.stopTest();
    }

}