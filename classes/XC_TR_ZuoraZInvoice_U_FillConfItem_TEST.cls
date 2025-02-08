/**
* @author De Blasio Valentina
* @date Creation 20/06/2022
* @date Modification -
* @description class XC_TR_ZuoraZInvoice_U_FillConfigItem populate configurationitem lookup of invoice
*/			   

@istest
public class XC_TR_ZuoraZInvoice_U_FillConfItem_TEST {
    
    @TestSetup
    static void setup(){
        
        Zuora__ZInvoice__c zuoraZInvoice = new Zuora__ZInvoice__c();
        zuoraZInvoice.Name ='test';
        insert zuoraZInvoice;
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        order.XC_LegalEntity__c='EnelXItalia';
        update order;
        List<NE__OrderItem__c> listOrderItem = XC_DF_OrderItem.createOrderItems(1);
        listOrderItem[0].XC_LegalEntity__c='EnelXItalia';
        listOrderItem[0].NE__OrderId__c=order.id;
        insert listOrderItem;
        
        zuoraZInvoice.XC_ConfigurationItem__c=listOrderItem[0].id;
        update zuoraZInvoice;
    }
    
    @isTest static void onInsert(){
        List<Zuora__ZInvoice__c> zinvoice=[Select id,name,XC_ConfigurationItem__c,Configuration_Item__c from Zuora__ZInvoice__c where name='test'];
        test.startTest();
        XC_TR_ZuoraZInvoice_U_FillConfigItem.PopulateInvoiceConfigItemLookup(zinvoice);
        test.stopTest();
        
    }
     
     @isTest static void onUpdate(){
        List<Zuora__ZInvoice__c> zinvoice=[Select id,name,XC_ConfigurationItem__c,Configuration_Item__c from Zuora__ZInvoice__c where name='test'];
        test.startTest();
        Map<Id, Zuora__ZInvoice__c> mapOld=new  Map<Id, Zuora__ZInvoice__c>();
        mapOld.put(zinvoice[0].id,zinvoice[0]);
        Map<Id, Zuora__ZInvoice__c> mapnew=new  Map<Id, Zuora__ZInvoice__c>();
        mapnew.put(zinvoice[0].id,zinvoice[0]);
        
        XC_TR_ZuoraZInvoice_U_FillConfigItem.fillInvoiceConfigItemLookup(mapOld,mapnew);
        test.stopTest();
        
    } 

}