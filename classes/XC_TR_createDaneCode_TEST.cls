/**
* @author Nicola Arrigo - narrigo@deloitte.it
* @date Creation  07/02/2020 
* @description XC_TR_createDaneCode_TEST – Test class for XC_TR_ConfigurationItem_U_createDaneCode
*/
@isTest
public with sharing class XC_TR_createDaneCode_TEST {
    static testMethod void createDaneCodeInsert(){
        insert XC_DF_OneOrg.createOneOrg('Spain');
        id rtId=Schema.SObjectType.NE__OrderItem__c.getRecordTypeInfosByDeveloperName().get('Penalty').getRecordTypeId();
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(2);
        Test.startTest();
        List<id> orderId=new list<id>();
        for(NE__OrderItem__c orderItem:listOrderItem ){
            orderId.add(orderItem.NE__OrderId__c);
        }
        listOrderItem[0].XC_DaneCode__c='Dane Code Test';
        listOrderItem[1].XC_BillingModel__c = '';
        listOrderItem[1].recordtypeId=rtId; 
        insert listOrderItem;
        System.assert(true,XC_UTIL_OneOrg.isRightCountry('Spain'));
        Test.stopTest(); 
        
    }
}