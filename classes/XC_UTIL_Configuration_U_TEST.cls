/**
* @author Roberta Porrega - roberta.porrega@nttdata.com 
* @date Creation 29/05/2019
* @description XC_UTIL_Configuration_U_TEST –Test Class 
*/

@isTest
public class XC_UTIL_Configuration_U_TEST { 
    
    static testMethod void testConf1() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<NE__Order__c> orderListInserted = [SELECT Id, XC_Status__c FROM NE__Order__c];
        System.debug('@@@orderListInserted-->' +orderListInserted);
        List<NE__Order__c> orderListToUpdate = new  List<NE__Order__c>();
        for(NE__Order__c orderi : orderListInserted){
            orderi.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        	orderListToUpdate.add(orderi);
        }
        update orderListToUpdate;
        System.debug('@@@orderListToUpdate-->' +orderListToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>(); 
        wrapperList = XC_UTIL_Configuration_U.getConfigurationNextStep(orderListToUpdate[0].Id, Label.XC_CL_Configuration_OrderInProvisioning);
        System.assertEquals(wrapperList[0].success, false);
        Test.stopTest();
    }
    
        static testMethod void testConf2() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<NE__Order__c> orderListInserted = [SELECT Id, XC_Status__c FROM NE__Order__c];
        System.debug('@@@orderListInserted-->' +orderListInserted);
        List<NE__Order__c> orderListToUpdate = new  List<NE__Order__c>();
        for(NE__Order__c orderi : orderListInserted){
            //orderi.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
            orderi.RecordTypeId = Schema.SObjectType.NE__Order__c.getRecordTypeInfosByDeveloperName().get('Quote').getRecordTypeId();
        	orderListToUpdate.add(orderi);
        }
        update orderListToUpdate;
        System.debug('@@@orderListToUpdate-->' +orderListToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>(); 
        wrapperList = XC_UTIL_Configuration_U.getConfigurationNextStep(orderListToUpdate[0].Id, Label.XC_CL_Configuration_OrderInProvisioning);
        System.assertEquals(wrapperList[0].success, false);
        Test.stopTest();
    }
    
    static testMethod void testConf3() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<NE__Order__c> orderListInserted = [SELECT Id, XC_Status__c FROM NE__Order__c];
        System.debug('@@@orderListInserted-->' +orderListInserted);
        List<NE__Order__c> orderListToUpdate = new  List<NE__Order__c>();
        for(NE__Order__c orderi : orderListInserted){
            orderi.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
        	orderListToUpdate.add(orderi);
        }
        update orderListToUpdate;
        System.debug('@@@orderListToUpdate-->' +orderListToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>(); 
        wrapperList = XC_UTIL_Configuration_U.getConfigurationNextStep(orderListToUpdate[0].Id, 'In Progress');
        System.assertEquals(wrapperList[0].success, false);
        Test.stopTest();
    }
    
        static testMethod void testConf4() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<NE__Order__c> orderListInserted = [SELECT Id, XC_Status__c FROM NE__Order__c];
        System.debug('@@@orderListInserted-->' +orderListInserted);
        List<NE__Order__c> orderListToUpdate = new  List<NE__Order__c>();
        for(NE__Order__c orderi : orderListInserted){
            orderi.XC_Status__c = 'In Progress';
        	orderListToUpdate.add(orderi);
        }
        update orderListToUpdate;
        System.debug('@@@orderListToUpdate-->' +orderListToUpdate);
        List<XC_UTIL_Sobject.WrapperResult> wrapperList = new List<XC_UTIL_Sobject.WrapperResult>(); 
        wrapperList = XC_UTIL_Configuration_U.getConfigurationNextStep(orderListToUpdate[0].Id, Label.XC_CL_Configuration_OrderInProvisioning);
        System.assertEquals(wrapperList[0].success, true);
        Test.stopTest();
    }
    
     static testMethod void testConf6() {
        insert XC_DF_OneOrg.createOneOrg('Spain');
        Test.startTest(); 
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        List<NE__Order__c> orderListInserted = [SELECT Id, XC_Status__c FROM NE__Order__c];
        System.debug('@@@orderListInserted-->' +orderListInserted);
        List<NE__Order__c> orderListToUpdate = new  List<NE__Order__c>();
        for(NE__Order__c orderi : orderListInserted){
            orderi.XC_Status__c = Label.XC_CL_Configuration_OrderInProvisioning;
            orderi.XC_PracticeNumber__c = 'abcde';
        	orderListToUpdate.add(orderi);
        }
        update orderListToUpdate;
        System.debug('@@@orderListToUpdate-->' +orderListToUpdate);
        Id returnMethod = XC_UTIL_Configuration_U.getConfigurationIdFromExternalId('XC_ESP_Config_APP001_ApproveFinancial', 'abcde');
        System.assertEquals(returnMethod, orderListToUpdate[0].Id);
        Test.stopTest();
    }
    
    

}