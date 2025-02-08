/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 05/05/2021
* @description XC_SC015_SendEmailToManager_TEST – Test Class for XC_SC015_SendEmailToManager
*/

@isTest
private class XC_SC015_SendEmailToManager_TEST {

    @isTest
    static void onSendEmail() {
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(2, Label.XC_CL_WorkType_Repair);
        insert listSa;
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        ServiceResource srToUpdate = new ServiceResource(
            Id = listSr[0].Id,
            XC_IsManager__c = true
        );
        update srToUpdate;
        Account accToUpdate = new Account(
            Id = listSr[0].XC_Account__c,
            IsPartner = true,
            XC_GiveDataTo_EnelXItalia__c = true
        );
        update accToUpdate;
        List<WorkOrder> listWoToUpdate = new List<WorkOrder>();
        List<XC_Address__c> listOfAddress = XC_DF_Address.createAddress(1);
        listOfAddress[0].XC_Region__c = 'VALLE D'+'\''+'AOSTA';
        insert listOfAddress;
        for(ServiceAppointment sa : listSa) {
            listWoToUpdate.add(new WorkOrder(
                Id = sa.ParentRecordId,
                Status = Label.XC_CL_WorkOrder_Assigned,
                XC_forSato__c = true,
                XC_AssignedPartner__c = listSr[0].XC_Account__c,
                XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy,
                XC_Address__c = listOfAddress[0].Id,
                XC_Segment__c = 'B2C',
                XC_StatusReason__c = Label.XC_CL_StatusReason_ToBeScheduled
            ));
        }
        update listWoToUpdate;

        Test.startTest();
        Database.executeBatch(new XC_SC015_SendEmailToManager(), 1);
        Test.stopTest();
    }
    
    @isTest
    static void onSendEmailWithChildrenWOs() {
        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'inOrder';
        order.XC_Segment__c = 'B2C';
        order.XC_LegalEntity__c = 'EnelXItalia';
        insert order;
        NE__OrderItem__c orItem = XC_DF_OrderItem.createOrderItem(order);
        orItem.XC_Product_Type__c  = Label.XC_CL_ProductTypeEquipment;
        orItem.XC_Product_Subtype__c = Label.XC_CL_Boiler;
        insert orItem;
        List<ServiceAppointment> listSa = XC_DF_ServiceAppointment.createServiceAppointment(2, Label.XC_CL_WorkType_Repair);
        insert listSa;
        List<ServiceResource> listSr = XC_DF_ServiceResource.createServiceResources(1);
        ServiceResource srToUpdate = new ServiceResource(
            Id = listSr[0].Id,
            XC_IsManager__c = true
        );
        update srToUpdate;
        Account accToUpdate = new Account(
            Id = listSr[0].XC_Account__c,
            IsPartner = true,
            XC_GiveDataTo_EnelXItalia__c = true
        );
        update accToUpdate;
        List<WorkOrder> listWoToUpdate = new List<WorkOrder>();
        Integer i = 0;
        for(ServiceAppointment sa : listSa) {
            if(i == 0){
                listWoToUpdate.add(new WorkOrder(
                    Id = sa.ParentRecordId,
                    Status = Label.XC_CL_WorkOrder_Assigned,
                    XC_forSato__c = true,
                    XC_AssignedPartner__c = listSr[0].XC_Account__c,
                    XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy,
                    XC_Segment__c = 'B2C',
                    XC_StatusReason__c = Label.XC_CL_StatusReason_ToBeScheduled
                ));
            } else {
                    listWoToUpdate.add(new WorkOrder(
                    Id = sa.ParentRecordId,
                    Status = Label.XC_CL_WorkOrder_Assigned,
                    XC_forSato__c = true,
                    XC_AssignedPartner__c = listSr[0].XC_Account__c,
                    XC_LegalEntity__c = Label.XC_CL_LegalEntity_Italy,
                    XC_Segment__c = 'B2C',
                   	ParentWorkOrderId = listSa[0].ParentRecordId,
                    XC_Configuration_Item__c = orItem.Id,
                    XC_StatusReason__c = Label.XC_CL_StatusReason_ToBeScheduled,
                    XC_ProductSubType__c = 'Boiler'
                ));     
            }
            i++;
        }
        update listWoToUpdate;

        Test.startTest();
        Database.executeBatch(new XC_SC015_SendEmailToManager(), 1);
        Test.stopTest();
    }

}