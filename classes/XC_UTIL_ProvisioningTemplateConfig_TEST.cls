/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  31/05/2019 
* @description XC_UTIL_ProvisioningTemplateConfig_TEST – Test class for XC_UTIL_ProvisioningTemplateConfig
*/
@isTest
public with sharing class XC_UTIL_ProvisioningTemplateConfig_TEST {
     //Test Method getTemplateSteps
    static testMethod void getTemplateSteps(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        List<NE__OrderItem__c> configurationItemList = new List<NE__OrderItem__c>();
        configurationItemList.add(confItem);
        XC_CM_Provisioning_Template_Association__mdt stepMD = new XC_CM_Provisioning_Template_Association__mdt();
        stepMD.XC_CM_Template_Name__c= 'SSII Basic Provisioning';
        Map<Id, String> mapConfItemTemplateName = new Map<Id, String>(); 
        mapConfItemTemplateName.put(confItem.Id, stepMD.XC_CM_Template_Name__c);
        Map<Id, List<XC_CM_Provisioning_Template_Config__mdt>> result = XC_UTIL_ProvisioningTemplateConfig.getTemplateSteps (mapConfItemTemplateName);
        System.assert(confItem!=null);
        Test.stopTest();
    }

         //Test Method getProvisioningTemplateConfList
    static testMethod void getProvisioningTemplateConfList(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        XC_CM_Provisioning_Template_Association__mdt stepMD = new XC_CM_Provisioning_Template_Association__mdt();
        stepMD.XC_CM_Template_Name__c= 'SSII Basic Provisioning';
        List<String> mapConfItemTemplateValues = new List<String>();
        mapConfItemTemplateValues.add(stepMD.XC_CM_Template_Name__c);
        List<XC_CM_Provisioning_Template_Config__mdt> result = XC_UTIL_ProvisioningTemplateConfig.getProvisioningTemplateConfList (mapConfItemTemplateValues);
        System.assert(!mapConfItemTemplateValues.isEmpty());
        Test.stopTest();
    }

}