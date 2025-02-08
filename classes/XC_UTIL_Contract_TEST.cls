/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @date 24/05/2019
* @description Test Class for XC_UTIL_Contract
*/
@isTest
private class XC_UTIL_Contract_TEST {
    static testMethod void UtilContractTest(){
        Test.startTest();
        List<NE__Order__c> listOrders = XC_DF_Order.createOrders(1,'InOrder');
        listOrders[0].XC_Country__c = 'SPAIN';
        insert listOrders;
        System.debug(LoggingLevel.FINE,'@orders@ : '+listOrders + 'size -> ' +listOrders.size());       
        XC_UTIL_Contract.ContractIFWrapper cW = new XC_UTIL_Contract.ContractIFWrapper();
        XC_UTIL_Contract.createContracts(listOrders);
        System.assert(!listOrders.isEmpty());       
        Test.stopTest();
    }

    static testMethod void populateFromFieldOptyTest(){
        Test.startTest();
        id rtord=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
        NE__Order__c ord = XC_DF_Order.createOrder('Opty');
        ord.XC_Country__c = 'SPAIN';
        ord.RecordTypeId=rtord;
        update ord;
        List<NE__OrderItem__c> orderItem = XC_DF_OrderItem.createOrderItems(1);
        orderItem[0].NE__OrderId__c=ord.id;
        insert orderItem;
        List<NE__Order__c> listOrders=new  List<NE__Order__c>();
        listOrders.add(ord);
        XC_UTIL_Contract.createContracts(listOrders);
        XC_TR_Contract_U_PopulateFromRootOi.populatefields(ord.NE__OptyId__c);
        System.assert(!listOrders.isEmpty());
        Test.stopTest();
    }

    static testMethod void populateFromFieldQuoteTest(){
        Test.startTest();
        id rtord=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        NE__Order__c ord = XC_DF_Order.createOrder('Quote');
        ord.XC_Country__c = 'SPAIN';
        ord.RecordTypeId=rtord;
        update ord;
     List<NE__OrderItem__c> orderItem = XC_DF_OrderItem.createOrderItems(1);
        orderItem[0].NE__OrderId__c=ord.id;
        insert orderItem;
        List<NE__Order__c> listOrders=new  List<NE__Order__c>();
        listOrders.add(ord);
        XC_UTIL_Contract.createContracts(listOrders);
        XC_TR_Contract_U_PopulateFromRootOi.populatefields(ord.NE__OptyId__c);       
        System.assert(!listOrders.isEmpty());
        
        Test.stopTest();
    }

    static testMethod void test1(){
        Test.startTest();
            id rtord=Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Opty').getRecordTypeId();
            NE__Order__c ord = XC_DF_Order.createOrder('Opty');
            ord.XC_Country__c = 'SPAIN';
            ord.RecordTypeId=rtord;
            ord.XC_Segment__c = 'B2G';
            update ord;
            List<NE__OrderItem__c> orderItem = XC_DF_OrderItem.createOrderItems(1);
            orderItem[0].NE__OrderId__c=ord.id;
            insert orderItem;
            List<NE__Order__c> listOrders=new  List<NE__Order__c>();
            listOrders.add(ord);
            XC_UTIL_Contract.createContracts(listOrders);
            XC_TR_Contract_U_PopulateFromRootOi.populatefields(ord.NE__OptyId__c);
            XC_UTIL_Contract.createContracts(listOrders);
            /*ord.XC_LegalEntity__c = 'EnelXMobilityRomania' ;
            ord.XC_Segment__c = 'B2C';
            ord.XC_Country__c= 'Romania';
            update ord;
            XC_UTIL_Contract.createContracts(listOrders);*/
            System.assert(!listOrders.isEmpty());    
        Test.stopTest();
        }
}