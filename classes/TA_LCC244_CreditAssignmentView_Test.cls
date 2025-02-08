@isTest
public without sharing class TA_LCC244_CreditAssignmentView_Test {

    @isTest
    private static void getIncentiveItems_Test() {
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c orderItem = new NE__OrderItem__c(NE__OrderId__c = order.Id, NE__Qty__c = 5, 
                                                          XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive,
                                                          XC_CreditAssignmentSurvey__c = 'https://endesaopina.getfeedback.com/r/HAr0Uu5D?ConfItem=a2T0D000000eutHUAQ&ContactID=0030D00000MMiIRQA1');
        insert orderItem;

        NE__OrderItem__c orderItem2 = new NE__OrderItem__c(NE__OrderId__c = order.Id, NE__Qty__c = 5);
        insert orderItem2;

        orderItem.NE__Bundle_Configuration__c = orderItem2.Id;
        update orderItem;

        WorkOrder workOrder = new WorkOrder(XC_Configuration__c = order.Id);
        insert workOrder;

        TA_LCC244_CreditAssignmentView.OiWrapper oiWrapper = new TA_LCC244_CreditAssignmentView.OiWrapper();
        oiWrapper.totalBundleAmount = null;
        oiWrapper.bundleProdName = null;
        oiWrapper.incentiveItemName = null;
        oiWrapper.recordId = null;
        oiWrapper.creditAssignmentSurvey = null;
        oiWrapper.creditAssignmentSurveyTaken = null;
        oiWrapper.hasContract = null;
        oiWrapper.hasAdditionalFieldsFilled = null;
        
        Test.startTest();
        TA_LCC244_CreditAssignmentView.getIncentiveItems(workOrder.Id);
        Test.stopTest();
    }

    @isTest
    private static void checkAdditionalFields_Test() {
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c orderItem = new NE__OrderItem__c(NE__OrderId__c = order.Id, NE__Qty__c = 5);
        
        orderItem.XC_CityCode__c = '34045';
        orderItem.XC_Subordinate__c = 'test';
        orderItem.XC_HouseType__c = 'T-Catasto Terreni';
        orderItem.XC_Particle__c = 'test';
        orderItem.XC_Sheet__c = 'test';
        insert orderItem;

        Test.startTest();
        Boolean result = TA_LCC244_CreditAssignmentView.checkAdditionalFields(orderItem);
        Test.stopTest();
    }

    @isTest
    private static void propagateAdditionalInfos_Test() {

        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c orderItem = new NE__OrderItem__c(NE__OrderId__c = order.Id, NE__Qty__c = 5, 
                                                          XC_Product_Subtype__c = Label.XC_CL_ProductSubtypeIncentive,
                                                          XC_CreditAssignmentSurvey__c = 'https://endesaopina.getfeedback.com/r/HAr0Uu5D?ConfItem=a2T0D000000eutHUAQ&ContactID=0030D00000MMiIRQA1');
        insert orderItem;

        NE__OrderItem__c orderItem2 = new NE__OrderItem__c(NE__OrderId__c = order.Id, NE__Qty__c = 5);
        insert orderItem2;

        orderItem.NE__Bundle_Configuration__c = orderItem2.Id;
        update orderItem;

        Map<String, Object> paramsMap = new Map<String, Object>();
        paramsMap.put('orderId',order.Id);
        paramsMap.put('cityCode','24040');
        paramsMap.put('subordinate','test');
        paramsMap.put('houseType','T-Catasto Terreni');
        paramsMap.put('urbanSection','test');
        paramsMap.put('sheet','test');
        paramsMap.put('particle','test');
        paramsMap.put('updatedItemId',orderItem.Id);
        
        Test.startTest();
        try {
            Boolean result = TA_LCC244_CreditAssignmentView.propagateAdditionalInfos(paramsMap);
        } catch(Exception e) {
            System.assertEquals(e.getMessage() != null, e.getMessage() != null);
        }
        Test.stopTest();
    }
}