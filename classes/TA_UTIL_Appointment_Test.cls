/**
 * Created by alericci on 17/12/2020.
 */

@IsTest
private class TA_UTIL_Appointment_Test {
    static testMethod void testBehavior() {
        List<ServiceAppointment> saList = XC_DF_ServiceAppointment.createServiceAppointment(2,'Delivery & Installation');
        List<ServiceResource> srList = XC_DF_ServiceResource.createServiceResources(1);
        srList.get(0).RelatedRecordId = UserInfo.getUserId();
        update srList;
        List<Account> accList = [SELECT Id, Name FROM Account WHERE Id =: srList[0].XC_Account__c];
        insert XC_DF_ServiceTerritory.createServiceTerritories(accList);
        List<ServiceTerritory> srt = [SELECT Id FROM ServiceTerritory];
        List<ServiceTerritoryMember> stmList = new List<ServiceTerritoryMember>();
        OperatingHours oh = XC_DF_OperatingHours.createOperatingHours('Gold Appointment Calendar');
        insert oh;
        //List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(1,'Delivery & Installation');
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(2,'Delivery & Installation');        
        insert woList;

        List<NE__Bundle__c> bundleList = XC_DF_Bundle.createBundleRecords(1);
        insert bundleList;
        NE__Bundle_Element__c be = new NE__Bundle_Element__c(XC_MacroCategory__c = 'Main',NE__Min_Qty__c = 1, NE__Type__c = 'Family',NE__Bundle__c = bundleList[0].id, NE__Max_quantity__c = 1, NE__Sequence__c = 3);
        insert be;
        List<Asset> assList = XC_DF_Asset.createAssets(1);
        assList[0].NE__Bundle_element__c = be.id;
        insert assList;
        woList[1].AssetId = assList[0].id;
        woList[1].ParentWorkOrderId =  woList[0].id;
        update woList;

        for (ServiceResource sr: srList) {
            ServiceTerritoryMember srtmemb = new ServiceTerritoryMember();
            srtmemb.ServiceTerritoryId = srt[0].Id;
            srtmemb.ServiceResourceId = sr.Id;
            srtmemb.EffectiveStartDate = DateTime.now();
            srtmemb.OperatingHoursId = oh.Id;
            stmList.add(srtmemb);
        }

        insert stmList;
        for(ServiceAppointment sa: saList){
            sa.SchedStartTime = system.now();
            sa.SchedEndTime = system.now()+1;
            sa.XC_AssignedResource__c = srList.get(0).id;
            sa.XC_StatusReason__c = 'To be scheduled';
            sa.ParentRecordId = woList[0].id;
        }
        insert saList;

        AssignedResource ar = new AssignedResource(ServiceResourceId = srList.get(0).id,serviceAppointmentId=saList.get(0).id);
        insert ar;

        TA_UTIL_Appointment.getInfoBag(3);
    }
}