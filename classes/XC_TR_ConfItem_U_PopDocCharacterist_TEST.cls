/**
* @author : Domenico Del Prete - domenico.delprete@nttdata.com
* @date Creation 13/03/2020
* @date Modification dd/mm/yyyy
* @description – XC_TR_ConfItem_U_PopulateDocCharacterist
*/
@isTest
public without sharing class XC_TR_ConfItem_U_PopDocCharacterist_TEST {

    @TestSetup
    static void setup(){
        OneOrg__c org = new OneOrg__c();
        org.Name='OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;        
    }

    @isTest
    static void populateDocCharacterist(){
        NE__Product__c prod = new NE__Product__c();
        prod.Name = 'TestAir';
        insert prod;
        List<NE__DocumentationCharacterist__c> listOfDoc = new List<NE__DocumentationCharacterist__c>();
        NE__DocumentationCharacterist__c docCharSplit = new NE__DocumentationCharacterist__c();
        docCharSplit.Name = 'Subtipo de Producto';
        docCharSplit.NE__Product__c = prod.Id;
        docCharSplit.NE__Value__c = 'Split';
        listOfDoc.add(docCharSplit);
        NE__DocumentationCharacterist__c docCharCasset = new NE__DocumentationCharacterist__c();
        docCharCasset.Name = 'Subtipo de Producto';
        docCharCasset.NE__Product__c = prod.Id;
        docCharCasset.NE__Value__c = 'Casset';
        listOfDoc.add(docCharCasset);
        NE__DocumentationCharacterist__c docCharConductos = new NE__DocumentationCharacterist__c();
        docCharConductos.Name = 'Subtipo de Producto';
        docCharConductos.NE__Product__c = prod.Id;
        docCharConductos.NE__Value__c = 'Conductos';
        listOfDoc.add(docCharConductos);
        NE__DocumentationCharacterist__c docCharMultiSplit = new NE__DocumentationCharacterist__c();
        docCharMultiSplit.Name = 'Subtipo de Producto';
        docCharMultiSplit.NE__Product__c = prod.Id;
        docCharMultiSplit.NE__Value__c = 'MultiSplit';
        listOfDoc.add(docCharMultiSplit);
        insert listOfDoc;
        List<NE__Order__c> listOfOrder = XC_DF_Order.createOrders(1, 'In Order');
        listOfOrder[0].XC_LegalEntity__c = 'EndesaX';
        insert listOfOrder;
        List<NE__OrderItem__c> listOfOi = new List<NE__OrderItem__c>();
        NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(listOfOrder[0]);
        orderItem.XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        orderItem.XC_Product_Subtype__c = Label.XC_CL_AirConditioning;
        orderItem.NE__ProdId__c = prod.Id;
        listOfOi.add(orderItem);
        NE__OrderItem__c orderItemBundle = XC_DF_OrderItem.createOrderItem(listOfOrder[0]);
        listOfOi.add(orderItemBundle);
        insert listOfOi;
        orderItem.NE__Bundle_Configuration__c = orderItemBundle.Id;
        update orderItem;
    }

    @isTest
    static void populateDocCharacteristListEmpty(){
        NE__Product__c prod = new NE__Product__c();
        prod.Name = 'TestAir';
        insert prod;
        List<NE__Order__c> listOfOrder = XC_DF_Order.createOrders(1, 'In Order');
        listOfOrder[0].XC_LegalEntity__c = 'EndesaX';
        insert listOfOrder;
        NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(listOfOrder[0]);
        orderItem.XC_Product_Type__c = Label.XC_CL_ProductTypeEquipment;
        orderItem.XC_Product_Subtype__c = Label.XC_CL_AirConditioning;
        orderItem.NE__ProdId__c = prod.Id;
        insert orderItem;
        NE__OrderItem__c orderItemBundle = XC_DF_OrderItem.createOrderItem(listOfOrder[0]);
        insert orderItemBundle;
        orderItem.NE__Bundle_Configuration__c = orderItemBundle.Id;
        update orderItem;
    }

}