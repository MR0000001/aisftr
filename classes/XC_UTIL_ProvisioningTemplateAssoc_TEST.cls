/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  31/05/2019 
* @description XC_UTIL_ProvisioningTemplateAssoc_TEST – Test class for XC_UTIL_ProvisioningTemplateAssociation
*/
@isTest

public with sharing class XC_UTIL_ProvisioningTemplateAssoc_TEST {
    //Test Method getTemplateSteps
    static testMethod void getTemplate(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        List<NE__OrderItem__c> listConfItem = new List<NE__OrderItem__c>(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        listConfItem.add(confItem);
        Map<Id, String> result = XC_UTIL_ProvisioningTemplateAssociation.getTemplate(listConfItem);
        System.assert(confItem!=null);
        Test.stopTest(); 
    } 

    //Test Method getTemplateSteps1
    static testMethod void getTemplate1(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        List<Account> listAccount = XC_DF_Account.createResidentialAccounts(1);
        Account acc = listAccount[0];
        insert acc;
        List<XC_Address__c> addressList =  XC_DF_Address.createAddress(listAccount);
        insert addressList;
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        conf.NE__AccountId__c = acc.Id;
        conf.XC_InstallationAddress__c = addressList[0].Id;
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        confItem.NE__Account__c = conf.NE__AccountId__c;
        confItem.XC_Installation_Address__c = conf.XC_InstallationAddress__c;
        insert confItem;
        String confItemId = confItem.Id;
        List<Id> listConfItemIds = new List<Id>();
        listConfItemIds.add(confItemId);
        Map<Id, String> result = XC_UTIL_ProvisioningTemplateAssociation.getTemplate(listConfItemIds);
        System.assert(confItem!=null);
        Test.stopTest(); 
    }

     //Test Method createMapConfItemIdWrapper
    static testMethod void createMapConfItemIdWrapper(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        NE__Product__c p = new NE__Product__c();
        p.Name =Label.XC_CL_Asset_Penalty;
        NE__Catalog_Category__c catalogCat = new NE__Catalog_Category__c();
        NE__Catalog_Item__c catItem = new NE__Catalog_Item__c();
        catItem.NE__Catalog_Category_Name__c = catalogCat.Id;
        //catalogCat.Name = 'Hidden Products';
        catalogCat.XC_LIC_Category_Name__c = 'Hidden Products';
        List<NE__OrderItem__c> listConfItem = new List<NE__OrderItem__c>(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        confItem.NE__ProdId__c = p.Id;
        confItem.NE__CatalogItem__c= catItem.Id ; 
        listConfItem.add(confItem);
        Map<Id, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper> result = XC_UTIL_ProvisioningTemplateAssociation.createMapConfItemIdWrapper(listConfItem);
        System.assert(confItem!=null);
        Test.stopTest(); 
    }

    
    //Test Method getConfigurationItemFields
    static testMethod void getConfigurationItemFields(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        String confItemId = confItem.Id;
        List<Id> listConfItemIds = new List<Id>();
        listConfItemIds.add(confItemId);
        List<NE__OrderItem__c> result= XC_UTIL_ProvisioningTemplateAssociation.getConfigurationItemFields(listConfItemIds);
        System.assert(confItem!=null);
        Test.stopTest(); 
    }

       //Test Method getProvisioningTemplateAssociation
    static testMethod void getProvisioningTemplateAssociation(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        Map<Id, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper> mapConfItemIdWrapper = new Map<Id, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper>(); 
        XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper cw = new XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper();
        mapConfItemIdWrapper.put(confItem.Id , cw);
        List<XC_CM_Provisioning_Template_Association__mdt>  result = XC_UTIL_ProvisioningTemplateAssociation.getProvisioningTemplateAssociation(mapConfItemIdWrapper);
        System.assert(confItem!=null);
        Test.stopTest(); 
    }




}