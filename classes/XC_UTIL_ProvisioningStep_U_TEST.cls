/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  31/05/2019 
* @date Modification 05/08/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_UTIL_ProvisioningStep_U_TEST – Test class for XC_UTIL_ProvisioningStep_U
*/

@isTest
public with sharing class XC_UTIL_ProvisioningStep_U_TEST {

    //Test Method populateResultWrapper
    static testMethod void populateResultWrapper(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        List<XC_UTIL_ProvisioningStep.ResultWrapper> results = new  List<XC_UTIL_ProvisioningStep.ResultWrapper>();
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<NE__OrderItem__c> configurationItemList = new List<NE__OrderItem__c>();
        configurationItemList.add(confItem);
        XC_CM_Provisioning_Template_Association__mdt stepMD = new XC_CM_Provisioning_Template_Association__mdt();
        Map<Id, String> mapConfItemTemplateName = new Map<Id, String>(); 
        mapConfItemTemplateName.put(confItem.Id, stepMD.XC_CM_Template_Name__c);
        XC_UTIL_ProvisioningStep_U.populateResultWrapper (results, mapConfItemTemplateName,configurationItemList);
        System.assert(confItem!=null);
        Test.stopTest();
    }

    //Test Method populateResultWrapper2
    static testMethod void populateResultWrapper2(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        List<XC_UTIL_ProvisioningStep.ResultWrapper> results = new  List<XC_UTIL_ProvisioningStep.ResultWrapper>();
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<NE__OrderItem__c> configurationItemList = new List<NE__OrderItem__c>();
        configurationItemList.add(confItem);
        XC_CM_Provisioning_Template_Association__mdt stepMD = new XC_CM_Provisioning_Template_Association__mdt();
        stepMD.XC_CM_Template_Name__c= 'SSII Basic Provisioning';
        Map<Id, String> mapConfItemTemplateName = new Map<Id, String>(); 
        mapConfItemTemplateName.put(confItem.Id, stepMD.XC_CM_Template_Name__c);
        XC_UTIL_ProvisioningStep_U.populateResultWrapper (results, mapConfItemTemplateName,configurationItemList);
        System.assert(confItem!=null);
        Test.stopTest();
    }

    //Test Method createNewStep
    static testMethod void createNewStep(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        XC_CM_Provisioning_Template_Config__mdt stepMD = new XC_CM_Provisioning_Template_Config__mdt();
        XC_Provisioning_Step__c ps=  XC_UTIL_ProvisioningStep_U.createNewStep(stepMD);
        System.assert(stepMD!=null);
        Test.stopTest();
    }

    //Test Method getMapStepsByName
    static testMethod void getMapStepsByName(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<XC_Provisioning_Step__c> stepsToEnqueue = new List<XC_Provisioning_Step__c>();
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);    
        ps.XC_Flow_API_Name__c= 'XC_FL_eMobility_BillingProcess';
        stepsToEnqueue.add(ps); 
        Map<String, List<XC_Provisioning_Step__c>> mapStepsByName =  XC_UTIL_ProvisioningStep_U.getMapStepsByName(stepsToEnqueue);
        System.assert(ps!=null);
        Test.stopTest();
    }

    //Test Method startProvisioningStepsOnConfigurationItems
    static testMethod void startProvisioningStepsOnConfigurationItems(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        String orderId = conf.Id; 
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        XC_Provisioning_Step__c ps= XC_DF_ProvisioningStep.createProvisioningStep(confItem.Id);     
        XC_UTIL_ProvisioningStep_U.startProvisioningStepsOnConfigurationItems(orderId);
        System.assert(ps!=null);
        Test.stopTest();
    }

    //Test Method checkProvisioningStep1
    static testMethod void checkProvisioningStep1(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItem;

        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(
            XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateDeliveryInstallationWO_Flow,
            XC_Configuration_Item__c = listOrderItem[0].Id
        );
        insert step;

        Test.startTest(); 
        XC_UTIL_ProvisioningStep_U.CheckStepWrapper wr = XC_UTIL_ProvisioningStep_U.checkProvisioningStep(listOrderItem[0].NE__OrderId__c);
        System.assert(wr!=null);
        Test.stopTest();
    }

    //Test Method checkProvisioningStep2
    static testMethod void checkProvisioningStep2(){
        insert XC_DF_OneOrg.createOneOrg('Spain'); 
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItem;

        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(
            XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow,
            XC_Configuration_Item__c = listOrderItem[0].Id
        );
        insert step;

        Test.startTest(); 
        XC_UTIL_ProvisioningStep_U.CheckStepWrapper wr = XC_UTIL_ProvisioningStep_U.checkProvisioningStep(listOrderItem[0].NE__OrderId__c);
        System.assert(wr!=null);
        Test.stopTest();
    }
    
    static testMethod void testtt(){
                List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        insert listOrderItem;
        Test.startTest();
    	XC_UTIL_ProvisioningStep_U.createNewStep(new XC_CM_Provisioning_Template_Config__mdt());
        XC_Provisioning_Step__c step = new XC_Provisioning_Step__c(
            XC_Flow_API_Name__c = Label.XC_CL_ProvisioningCreateSubscription_Flow,
            XC_Configuration_Item__c = listOrderItem[0].Id
        );
        List<XC_Provisioning_Step__c> p = new List<XC_Provisioning_Step__c>();
        p.add(step);
        XC_UTIL_ProvisioningStep_U.getMapStepsByName(p);
        Test.stopTest();
    }

}