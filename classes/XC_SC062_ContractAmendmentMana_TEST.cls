/**
 * Created by dolombardi on 08/11/2021.
 */
@isTest
public with sharing class XC_SC062_ContractAmendmentMana_TEST {
    static testMethod void callBatch(){
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = 'ContractAmendment';
        ic.XC_interfaceName__c = 'ContractAmendment';
        insert ic;
        
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order = [SELECT Id, NE__AccountID__c, NE__OptyId__c,XC_InstallationAddress__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
        NE__OrderItem__c originalItem = XC_DF_OrderItem.createOrderItem(order);
        insert originalItem;
        XC_ContractAmendment__c contractAmendment = new XC_ContractAmendment__c(XC_Status__c = 'New');
        XC_ContractAmendment__c contractAmendmentChild = new XC_ContractAmendment__c(XC_Status__c = 'New');
        List<XC_ContractAmendment__c> listContAmend = new List<XC_ContractAmendment__c>{contractAmendment,contractAmendmentChild};
        insert listContAmend;
        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = originalItem.Id;
        listAssets[0].XC_Original_Configuration_Item__c = originalItem.Id;
        listAssets[0].XC_Original_Creation_OrderItem__c  = originalItem.Id;
        listAssets[0].XC_Contract_Amendment__c = contractAmendment.id;
        listAssets[0].XC_Particle__c = 'false';
        insert listAssets;
        contractAmendment.XC_Asset__c = listAssets[0].id;
        contractAmendmentChild.XC_Asset__c = listAssets[0].id;
        contractAmendmentChild.Contract_Amendment_Parent__c = contractAmendment.id;
        update contractAmendment;
        update contractAmendmentChild;
        Database.executeBatch(new XC_SC062_ContractAmendmentManagment(), 1);


    }

}