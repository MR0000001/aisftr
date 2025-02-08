/**
* @author Emanuela Cacace - ecacace@deloitte.it
* @date Creation  31/05/2019 
* @description XC_UTIL_ProvisioningTempAssoci_U_TEST – Test class for XC_UTIL_ProvisioningTempAssociation_U
*/
@isTest
public with sharing class XC_UTIL_ProvisioningTempAssoci_U_TEST {
        //Test Method checkExactMatch
    static testMethod void checkExactMatch(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper =new XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper();
        wrapper.orderType='InOrder';
        wrapper.country= 'SPAIN';
        wrapper.bit2winBundle = false;
        wrapper.billingMethod ='One shot';
        wrapper.paymentMethod='Barcode';
        wrapper.orderSubType= 'Upgrade (Renting 3 to Renting 5)';
        wrapper.orderItemAction = 'Change';
        wrapper.catalogItem ='Pay Per Use Guest User';
        wrapper.productServiceCategory='Boiler';
        Map<Id, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper> mapConfItemIdWrapper = new  Map<Id, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper>();                                                         
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        mapConfItemIdWrapper.put(confItem.Id, wrapper);
        
        XC_UTIL_ProvisioningTempAssociation_U.MatchWrapper exactMatchWrapper =  new XC_UTIL_ProvisioningTempAssociation_U.MatchWrapper();
        exactMatchWrapper.mapConfItemIdWrapper = mapConfItemIdWrapper;
        exactMatchWrapper.listSteps = new List<XC_CM_Provisioning_Template_Association__mdt>();
        
        XC_CM_Provisioning_Template_Association__mdt stepMD = new XC_CM_Provisioning_Template_Association__mdt();
        stepMD.XC_CM_Order_Type__c= 'InOrder';
        stepMD.XC_CM_Country__c= 'SPAIN';
        stepMD.XC_BundleBit2Win__c  = false;
        stepMD.XC_CM_Billing_Method__c  ='One shot';
        stepMD.XC_CM_PaymentMethod__c  ='Barcode';
        stepMD.XC_CM_OrderSubtype__c= 'Upgrade (Renting 3 to Renting 5)';
        stepMD.XC_CM_Action__c  = 'Change';
        stepMD.XC_CM_Catalog_Item__c  ='Pay Per Use Guest User';
        stepMD.XC_CM_Product_Service_Category__c   ='Boiler';
        
        
        exactMatchWrapper.listSteps.add(stepMD);

        XC_UTIL_ProvisioningTempAssociation_U.checkExactMatch(confItem.Id, exactMatchWrapper);

        System.assert(confItem!=null);
        Test.stopTest(); 
    }

    
    //Test Method checkWildCardMatch
    static testMethod void checkWildCardMatch(){
        insert XC_DF_OneOrg.createOneOrg('Spain');         
        Test.startTest(); 
        XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper wrapper =new XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper();
        wrapper.orderType='InOrder';
        wrapper.country= 'SPAIN';
        wrapper.bit2winBundle = false;
        wrapper.billingMethod ='One shot';
        wrapper.paymentMethod='Barcode';
        wrapper.orderSubType= 'Upgrade (Renting 3 to Renting 5)';
        wrapper.orderItemAction = 'Change';
        wrapper.catalogItem ='Pay Per Use Guest User';
        wrapper.productServiceCategory='Boiler';
        
        Map<Id, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper> mapConfItemIdWrapper = new  Map<Id, XC_UTIL_ProvisioningTemplateAssociation.ConfigurationItemWrapper>();                                                         
        NE__Order__c conf = XC_DF_Order.createOrder('InOrder');
        NE__OrderItem__c confItem = XC_DF_OrderItem.createOrderItem(conf);
        mapConfItemIdWrapper.put(confItem.Id, wrapper);
        
        XC_UTIL_ProvisioningTempAssociation_U.MatchWrapper exactMatchWrapper =  new XC_UTIL_ProvisioningTempAssociation_U.MatchWrapper();
        exactMatchWrapper.mapConfItemIdWrapper = mapConfItemIdWrapper;
        
        exactMatchWrapper.listSteps = new List<XC_CM_Provisioning_Template_Association__mdt>();
        
        XC_CM_Provisioning_Template_Association__mdt stepMD = new XC_CM_Provisioning_Template_Association__mdt();
        stepMD.XC_CM_Order_Type__c= 'InOrder';
        stepMD.XC_CM_Country__c= 'SPAIN';
        stepMD.XC_BundleBit2Win__c  = false;
        stepMD.XC_CM_Billing_Method__c  ='One shot';
        stepMD.XC_CM_PaymentMethod__c  ='Barcode';
        stepMD.XC_CM_OrderSubtype__c= 'Upgrade (Renting 3 to Renting 5)';
        stepMD.XC_CM_Action__c  = 'Change';
        stepMD.XC_CM_Catalog_Item__c  ='Pay Per Use Guest User';
        stepMD.XC_CM_Product_Service_Category__c   ='Boiler';
        
        
        exactMatchWrapper.listSteps.add(stepMD);

        XC_UTIL_ProvisioningTempAssociation_U.checkWildCardMatch(confItem.Id, exactMatchWrapper);

        System.assert(confItem!=null);
        Test.stopTest(); 
    }

}