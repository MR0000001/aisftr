@isTest
private class XC_TR_ConfigurationItem_U_SC_WF_U_TEST {

    @testSetup 
    private static void testSetup() {
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(2);
        listOrderItem[0].XC_CreditAssignmentAvailable__c =  true;
        listOrderItem[0].XC_Product_Subtype__c = 'Incentive';
        listOrderItem[0].XC_CityCode__c = 'G964';
        listOrderItem[0].XC_Subordinate__c = '7';
        listOrderItem[0].XC_HouseType__c = 'U-Catasto Fabbricati';
        listOrderItem[0].XC_Sheet__c = 'A2';
        listOrderItem[0].XC_Particle__c = '739';
        listOrderItem[0].XC_PaymentMethod__c ='No Payment Required';
        listOrderItem[0].XC_StartCongaProcess__c = true;

        listOrderItem[1].XC_CreditAssignmentAvailable__c =  true;
        listOrderItem[1].XC_Product_Subtype__c = 'Incentive';
        listOrderItem[1].XC_CityCode__c = 'G964';
        listOrderItem[1].XC_Subordinate__c = '7';
        listOrderItem[1].XC_HouseType__c = 'U-Catasto Fabbricati';
        listOrderItem[1].XC_Sheet__c = 'A2';
        listOrderItem[1].XC_Particle__c = '739';
        listOrderItem[1].XC_PaymentMethod__c ='No Payment Required';
        listOrderItem[1].XC_StartCongaProcess__c = true;

        insert listOrderItem;
    }

    @isTest
    static void testMethod2(){
        Test.startTest();
        List<NE__Order__c> orders = [Select Id, XC_LegalEntity__c from NE__Order__c limit 1];
        orders[0].XC_LegalEntity__c = 'EnelXItalia';
        update orders;
        List<NE__OrderItem__c> listOrderItem = [Select Id, NE__Bundle_Configuration__c,XC_CreditAssignmentAvailable__c,XC_Product_Subtype__c,
                                                XC_CityCode__c,XC_Subordinate__c,XC_HouseType__c,XC_Sheet__c,XC_Particle__c,XC_BillingProfileLineItem__c,
                                                XC_Product_Type__c,XC_BillingModel__c,XC_LegalEntityFormula__c,XC_PaymentMethod__c,XC_BPLIStatus__c,
                                                XC_StartCongaProcess__c
                                                from NE__OrderItem__c limit 2];
        listOrderItem[0].NE__Bundle_Configuration__c =  listOrderItem[1].Id;
        update listOrderItem;
        Map<Id, NE__OrderItem__c> mapOld =  new Map<Id, NE__OrderItem__c>();
        mapOld.put(listOrderItem[0].id,listOrderItem[0]);
        Map<Id, NE__OrderItem__c> mapNew =  new Map<Id, NE__OrderItem__c>();
        mapNew.put(listOrderItem[0].id,listOrderItem[0]);
        XC_TR_ConfigurationItem_U_StartCongaWF_U.secondCheckOnInsert(listOrderItem[0]);
        XC_TR_ConfigurationItem_U_StartCongaWF_U.checkCreditAssignmentAvailable(listOrderItem[0],mapOld,mapNew);
        XC_TR_ConfigurationItem_U_StartCongaWF_U.firstCheckOnInsert(listOrderItem[0]);
        Test.stopTest();
    }

    @isTest
    static void testMethod1(){
        List<NE__Order__c> orders = [Select Id, XC_LegalEntity__c from NE__Order__c limit 1];
        orders[0].XC_LegalEntity__c = 'EnelXItalia';
        update orders;
        List<NE__OrderItem__c> listOrderItem = [Select Id, NE__Bundle_Configuration__c,XC_CreditAssignmentAvailable__c,XC_Product_Subtype__c,
                                                XC_CityCode__c,XC_Subordinate__c,XC_HouseType__c,XC_Sheet__c,XC_Particle__c,XC_BillingProfileLineItem__c,
                                                XC_Product_Type__c,XC_BillingModel__c,XC_LegalEntityFormula__c,XC_PaymentMethod__c,XC_BPLIStatus__c,
                                                XC_StartCongaProcess__c
                                                from NE__OrderItem__c limit 2];
        listOrderItem[0].NE__Bundle_Configuration__c =  listOrderItem[1].Id;
        update listOrderItem;
        Map<Id, NE__OrderItem__c> mapOld =  new Map<Id, NE__OrderItem__c>();
        mapOld.put(listOrderItem[0].id,listOrderItem[0]);
        Map<Id, NE__OrderItem__c> mapNew =  new Map<Id, NE__OrderItem__c>();
        mapNew.put(listOrderItem[0].id,listOrderItem[0]);
        mapNew.get(listOrderItem[0].id).XC_CreditAssignmentAvailable__c = false;
        Test.startTest();
        XC_TR_ConfigurationItem_U_StartCongaWF_U.checkOnBMUpdate(listOrderItem[0],mapOld,mapNew);
        XC_TR_ConfigurationItem_U_StartCongaWF_U.checkBillingProfileLineItemChange(listOrderItem[0],mapOld,mapNew);
        Test.stopTest();
    }
}