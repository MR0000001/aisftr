/**
* @author sbarbera
* @date Creation 14/09/2021
* @description XC_LCC255_CancelProductReservation_TEST - Test class for XC_LCC255_CancelProductReservation
*/

@isTest
private class XC_LCC255_CancelProductReservation_TEST {

    @TestSetup
    static void makeData(){
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        List<Account> acc = XC_DF_Account.insertPartnerAccounts(1);
		NE__Order__c o = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        WorkOrder wo = new WorkOrder();
        wo.XC_Configuration__c= o.Id;
        wo.XC_Configuration_Item__c = itemList[0].Id;
        wo.XC_PreferredPArtner__c = acc[0].Id;
        wo.State = 'Italy';
        wo.XC_AssignedPartner__c = acc[0].Id;
        insert wo;
        WorkOrderLineItem woli2 = new WorkOrderLineItem();
        woli2.Status='New';
        woli2.WorkOrderId = wo.Id;       
        woli2.XC_AccountId__c = acc[0].Id;
        woli2.XC_WOLIType__c = 'Material Supply';
        woli2.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_MR_WOLI').getRecordTypeId();
        insert woli2;
        woli.WorkOrderId = wo.Id;
        woli.XC_MaterialRequest__c = woli2.Id;
        woli.XC_AccountId__c = acc[0].Id;
        insert woli;
    }

    @isTest
    static void onCancelErrorStep1() {
        WorkOrderLineItem woli = [SELECT Id FROM WorkOrderLineItem WHERE XC_MaterialRequest__c != null LIMIT 1];
        woli.Status = Label.XC_CL_WorkOrder_Canceled;
        update woli;

        Test.startTest();
        XC_UTIL_ResultWrapper resWr = XC_LCC255_CancelProductReservation.cancelProducReservationStep1('');
        XC_LCC255_CancelProductReservation.cancelProducReservationStep1('');
        XC_LCC255_CancelProductReservation.cancelProducReservationStep1(woli.Id);
        Test.stopTest();
    }

    @isTest
    static void onCancelStep1() {
        Test.startTest();
        XC_LCC255_CancelProductReservation.cancelProducReservationStep1([SELECT Id FROM WorkOrderLineItem WHERE XC_MaterialRequest__c != null LIMIT 1].Id);
        Test.stopTest();
    }

    @isTest
    static void onCancelErrorStep2() {
        WorkOrderLineItem woli = [SELECT Id FROM WorkOrderLineItem WHERE XC_MaterialRequest__c != null LIMIT 1];
        woli.Status = Label.XC_CL_WorkOrder_Canceled;
        update woli;

        Test.startTest();
        XC_LCC255_CancelProductReservation.cancelProducReservationStep2('');
        XC_LCC255_CancelProductReservation.cancelProducReservationStep2(woli.Id);
        Test.stopTest();
    }

    @isTest
    static void onCancelStep2() {
        Test.startTest();
        XC_LCC255_CancelProductReservation.cancelProducReservationStep2([SELECT Id FROM WorkOrderLineItem WHERE XC_MaterialRequest__c != null LIMIT 1].Id);
        Test.stopTest();
    }

}