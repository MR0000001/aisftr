/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 28/10/2019
* @description XC_IN035_ReservationSpareParts_TEST – Test class XC_IN035_ReservationSpareParts
*/ 

@isTest
public without sharing class XC_IN035_ReservationSpareParts_TEST {

    @isTest
    private static void onProductReservation() { 
        OneOrg__c org = new OneOrg__c(Name = 'OneOrg (User)', XC_Spain_Triggers__c=true);
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_Repair);
        listWorkOrder[0].XC_StatusReason__c = Label.XC_CL_PendingParts;
        insert listWorkOrder;
        NE__Order__c myOrder = XC_DF_Order.createOrder('InOrder');
        Opportunity myOpp = new Opportunity(
            Id = myOrder.NE__OptyId__c,
            XC_WorkOrder__c = listWorkOrder[0].Id
        );
        update myOpp;
        NE__OrderItem__c myOrderItem = XC_DF_OrderItem.createOrderItem(myOrder);    
        insert myOrderItem;
        XC_Provisioning_Step__c myStep = new XC_Provisioning_Step__c(
            XC_Status__c = Label.XC_CL_Configuration_NotStarted,
            XC_Step_Order__c = 1,
            XC_Country__c = 'Spain',
            XC_Configuration_Item__c = myOrderItem.Id 
        ); 
        insert myStep;
        List<XC_IN035_ReservationSpareParts.InputWrapper> wrapper = new List<XC_IN035_ReservationSpareParts.InputWrapper>{
            new XC_IN035_ReservationSpareParts.InputWrapper(myStep.Id)
        };
        System.assertNotEquals(myStep.Id, null);

        
        // Test without Resource Preference
        XC_IN035_ReservationSpareParts.throwTest = true;
        XC_IN035_ReservationSpareParts.makeReservation(wrapper);
        // Test with Resource Preference
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        List<ResourcePreference> rpList = new List<ResourcePreference>();
        for(WorkOrder wo : woList){
            ResourcePreference rp = new ResourcePreference(
                RelatedRecordId = wo.Id,
                ServiceResourceId = sr[0].Id
            );   
            rpList.add(rp);
        }
        insert rpList;
        for(WorkOrder wo : woList){
            wo.XC_AssignedResource__c = sr[0].Id;
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(woList);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        Test.startTest();
        XC_IN035_ReservationSpareParts.makeReservation(wrapper);
        Test.stopTest();
    }

    @isTest
    private static void onProductReservationthrowTest() { 
        OneOrg__c org = new OneOrg__c(Name = 'OneOrg (User)', XC_Spain_Triggers__c=true);
        List<WorkOrder> listWorkOrder = XC_DF_WorkOrder.createWorkOrders(1, Label.XC_CL_Repair);
        listWorkOrder[0].XC_StatusReason__c = Label.XC_CL_PendingParts;
        insert listWorkOrder;
        NE__Order__c myOrder = XC_DF_Order.createOrder('InOrder');
        Opportunity myOpp = new Opportunity(
            Id = myOrder.NE__OptyId__c,
            XC_WorkOrder__c = listWorkOrder[0].Id
        );
        update myOpp;
        NE__OrderItem__c myOrderItem = XC_DF_OrderItem.createOrderItem(myOrder);    
        insert myOrderItem;
        XC_Provisioning_Step__c myStep = new XC_Provisioning_Step__c(
            XC_Status__c = Label.XC_CL_Configuration_NotStarted,
            XC_Step_Order__c = 1,
            XC_Country__c = 'Spain',
            XC_Configuration_Item__c = myOrderItem.Id 
        ); 
        insert myStep;
        List<XC_IN035_ReservationSpareParts.InputWrapper> wrapper = new List<XC_IN035_ReservationSpareParts.InputWrapper>{
            new XC_IN035_ReservationSpareParts.InputWrapper(myStep.Id)
        };
        System.assertNotEquals(myStep.Id, null);
        
        // Test without Resource Preference
        XC_IN035_ReservationSpareParts.makeReservation(wrapper);
        // Test with Resource Preference
        List<ServiceResource> sr = XC_DF_ServiceResource.createServiceResources(1);
        List<WorkOrder> woList = [SELECT Id FROM WorkOrder];
        List<ResourcePreference> rpList = new List<ResourcePreference>();
        for(WorkOrder wo : woList){
            ResourcePreference rp = new ResourcePreference(
                RelatedRecordId = wo.Id,
                ServiceResourceId = sr[0].Id
            );   
            rpList.add(rp);
        }

        insert rpList;
        for(WorkOrder wo : woList){
            wo.XC_AssignedResource__c = sr[0].Id;
        }
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateListRecords(woList);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        Test.startTest();
        XC_IN035_ReservationSpareParts.makeReservation(wrapper);
        Test.stopTest();
    }

}