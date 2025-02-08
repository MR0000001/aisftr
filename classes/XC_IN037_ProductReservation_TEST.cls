/**
* @author Valeria Martino - valeria.martino@nttdata.com
* *@date Creation 15/11/2019
* @description XC_IN037_ProductReservation_TEST test class for XC_IN037_ProductReservation
*/
@isTest
public with sharing  class XC_IN037_ProductReservation_TEST {
    @testSetup
    private static void setup() {
        
        OneOrg__c org = new OneOrg__c(); 
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c = true;
        insert org;
        List<ServiceResource> listServiceResource= XC_DF_ServiceResource.createServiceResources(1);
        listServiceResource[0].Name = Label.XC_CL_NoCandidateFound;
        listServiceResource[0].RelatedRecordId = [SELECT ID FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1].Id;
        update listServiceResource;

        List<NE__Order__c> listOrder = XC_DF_Order.createOrders(1, 'InOrder');
        insert listOrder;
        NE__Order__c order = listOrder[0];
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;

        List<WorkOrder> woListToInsert = new List<WorkOrder>();
        List<WorkOrder> workOrderDelivery = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_Delivery);
        workOrderDelivery[0].XC_Configuration_Item__c = ordIt.Id;
        List<WorkOrder> workOrderReturn = XC_DF_WorkOrder.createWorkOrders (1, 'Return');
        workOrderReturn[0].XC_Configuration_Item__c = ordIt.Id;
        woListToInsert.addAll(workOrderDelivery);
        woListToInsert.addAll(workOrderReturn);
        insert woListToInsert;
        //insert workOrderReturn;

        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;       
        insert provisioningStep;
    }

     @isTest
    public static void productReservation() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c, XC_Status__c
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];
        NE__OrderItem__c orderItem = [SELECT Id, (SELECT Id FROM Work_Orders__r WHERE XC_WorkTypeCategory__c =: Label.XC_CL_WorkType_Delivery) FROM NE__OrderItem__c WHERE Id = :ps.XC_Configuration_Item__c LIMIT 1];
        List<XC_IN037_ProductReservation.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        Test.startTest();
        XC_IN037_ProductReservation.callGlovia(listInputWrapper);
        Test.stopTest();
    }
    
    @isTest
    public static void productReservation1() {

        List<XC_IN037_ProductReservation.InputWrapper> listInputWrapper = new List<XC_IN037_ProductReservation.InputWrapper>();
        XC_IN037_ProductReservation.InputWrapper i = new XC_IN037_ProductReservation.InputWrapper();
        i.stepid = [SELECT Id FROM XC_Provisioning_Step__c LIMIT 1].Id;
            listInputWrapper.add(i);
        Test.startTest();
        XC_IN037_ProductReservation.skipTestMFL();
        XC_IN037_ProductReservation.callGlovia(listInputWrapper);
        Test.stopTest();
    }
    
    @isTest
    public static void productReservationDelivery() {
        /*List<NE__Order__c> listOfOrder = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(listOfOrder[0]);
        insert ordIt;
        List<NE__Order__c> listOrder = XC_DF_Order.createOrders(1, 'InOrder');
        insert listOrder;
        NE__Order__c order = listOrder[0];
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;*/
        Test.startTest();
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id FROM NE__OrderItem__c]);
        List<WorkOrder> workOrderDeliveryInstallation = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_DeliveryInstallation);
        workOrderDeliveryInstallation[0].XC_Configuration_Item__c = listOfOrderItem[0].Id;
        insert workOrderDeliveryInstallation;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = listOfOrderItem[0].Id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;       
        insert provisioningStep;
        List<XC_IN037_ProductReservation.InputWrapper> listInputWrapper = generateInputWrapper(provisioningStep);

        XC_IN037_ProductReservation.callGlovia(listInputWrapper);
        XC_IN037_ProductReservation.skipTestMFL();
        Test.stopTest();
    }

    @isTest
    public static void productReservationSubstitution() {
        /*List<NE__Order__c> listOfOrder = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(listOfOrder[0]);
        insert ordIt;
        List<NE__Order__c> listOrder = XC_DF_Order.createOrders(1, 'InOrder');
        insert listOrder;
        NE__Order__c order = listOrder[0];
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;*/
        Test.startTest();
        List<NE__OrderItem__c> listOfOrderItem = new List<NE__OrderItem__c>([SELECT Id FROM NE__OrderItem__c]);
        List<WorkOrder> workOrderSubstitution = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_Substitution);
        workOrderSubstitution[0].XC_Configuration_Item__c = listOfOrderItem[0].Id;
        List<XC_UTIL_Sobject.WrapperResult> wrapp = XC_UTIL_Sobject.insertListRecords(workOrderSubstitution);
        List<WorkOrder> workOrderDeliveryInstallation = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_DeliveryInstallation);
        workOrderDeliveryInstallation[0].ParentWorkOrderId = workOrderSubstitution[0].Id;
        insert workOrderDeliveryInstallation;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = listOfOrderItem[0].Id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;       
        insert provisioningStep;
        List<XC_IN037_ProductReservation.InputWrapper> listInputWrapper = generateInputWrapper(provisioningStep);
        XC_IN037_ProductReservation.callGlovia(listInputWrapper);
        XC_IN037_ProductReservation.skipTestMFL();
        Test.stopTest();
    }

    @isTest
    public static void provStepWithoutWo() {
        Test.startTest();
        /*List<NE__Order__c> listOfOrder = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(listOfOrder[0]);
        insert ordIt;*/
        List<NE__Order__c> listOrder = XC_DF_Order.createOrders(1, 'InOrder');
        insert listOrder;
        NE__Order__c order = listOrder[0];
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;       
        insert provisioningStep;
        List<XC_IN037_ProductReservation.InputWrapper> listInputWrapper = generateInputWrapper(provisioningStep);
        XC_IN037_ProductReservation.callGlovia(listInputWrapper);
        XC_IN037_ProductReservation.skipTestMFL();
        Test.stopTest();
    }

    private static List<XC_IN037_ProductReservation.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {
        List<XC_IN037_ProductReservation.InputWrapper> listWrapperInput = new List<XC_IN037_ProductReservation.InputWrapper>();
        XC_IN037_ProductReservation.InputWrapper wr = new XC_IN037_ProductReservation.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);
        return listWrapperInput;
    }
    
     @isTest
    public static void productReservationNotSubstitution() {
        /*List<NE__Order__c> listOfOrder = new List<NE__Order__c>([SELECT Id FROM NE__Order__c]);
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(listOfOrder[0]);
        insert ordIt;
        List<NE__Order__c> listOrder = XC_DF_Order.createOrders(1, 'InOrder');
        insert listOrder;
        NE__Order__c order = listOrder[0];
        NE__OrderItem__c ordIt = XC_DF_OrderItem.createOrderItem(order);
        insert ordIt;*/
        NE__OrderItem__c ordIt = [SELECT Id FROM NE__OrderItem__c LIMIT 1];
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE XC_WorkTypeCategory__c  =: Label.XC_CL_WorkType_Delivery LIMIT 1];
        /*List<WorkOrder> workOrderSubstitution = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_DeliveryInstallation);
        workOrderSubstitution[0].XC_Configuration_Item__c = ordIt.Id;
        List<XC_UTIL_Sobject.WrapperResult> wrapp = XC_UTIL_Sobject.insertListRecords(workOrderSubstitution);*/
        //List<WorkOrder> workOrderDeliveryInstallation = XC_DF_WorkOrder.createWorkOrders (1, Label.XC_CL_WorkType_DeliveryInstallation);
        //workOrderDeliveryInstallation[0].ParentWorkOrderId = workOrderSubstitution[0].Id;
        wo.XC_Configuration_Item__c = ordIt.Id;
        wo.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, true);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, true);
        XC_UTIL_Sobject.updateRecord(wo);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.BEFORE_UPDATE, false);
        XC_TR_WorkOrder_Handler.mapTriggerStopped.put(System.TriggerOperation.AFTER_UPDATE, false);
        XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Status__c = Label.XC_CL_Completed_OK;
        provisioningStep.XC_Step_Order__c = 1;       
        insert provisioningStep;
        List<XC_IN037_ProductReservation.InputWrapper> listInputWrapper = generateInputWrapper(provisioningStep);
        Test.startTest();
        XC_IN037_ProductReservation.callGlovia(listInputWrapper);
        XC_IN037_ProductReservation.skipTestMFL();
        Test.stopTest();
    }

    @isTest
    public static void recalculateSalesOrder() {
        NE__OrderItem__c ordIt = [SELECT Id FROM NE__OrderItem__c LIMIT 1];
		WorkOrder wo = [SELECT Id FROM WorkOrder WHERE XC_WorkTypeCategory__c  =: Label.XC_CL_WorkType_Delivery LIMIT 1];
        wo.XC_Configuration_Item__c = ordIt.Id;
        wo.XC_WorkTypeCategory__c = Label.XC_CL_WorkType_DeliveryInstallation;
        wo.XC_ReCalculateSalesOrder__c = true;
        XC_UTIL_Sobject.updateRecord(wo);
		XC_Provisioning_Step__c provisioningStep = new XC_Provisioning_Step__c();
        provisioningStep.XC_Configuration_Item__c = ordIt.id;
        provisioningStep.XC_Step_Order__c = 1;       
        insert provisioningStep;
        List<XC_IN037_ProductReservation.InputWrapper> listInputWrapper = generateInputWrapper(provisioningStep);
        Test.startTest();
        XC_IN037_ProductReservation.callGlovia(listInputWrapper);
        XC_IN037_ProductReservation.skipTestMFL();
        Test.stopTest();
    }
}