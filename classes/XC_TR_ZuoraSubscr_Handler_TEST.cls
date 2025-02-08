/**
 * @author Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation 03/10/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_ZuoraSubscr_Handler_TEST – Test Class for XC_TR_ZuoraSubscription, Handler and XC_TR_ZuoraSubscription_U_ManageZquote
 */ 

@isTest
public without sharing class XC_TR_ZuoraSubscr_Handler_TEST {

    @TestSetup
    static void insertCustomSetting (){
        OneOrg__c org = new OneOrg__c();
        org.Name = 'OneOrg (User)';
        org.XC_Spain_Triggers__c=true;
        insert org;
        
        zqu__quote__c quote = new zqu__quote__c(zqu__ZuoraSubscriptionID__c = '12345');
        insert quote;

        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        Map<Id, NE__OrderItem__c> mapItem = new Map<Id, NE__OrderItem__c>([SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c LIMIT 1]);
        mapItem.values()[0].XC_ZQuoteId__c = quote.Id; 
        update mapItem.values(); 

        List<Asset> a = XC_DF_Asset.createAssets(1);
        a[0].XC_Configuration_Item__c = mapItem.values()[0].Id;
        insert a;
    }
    
    @isTest
    static void onInsert(){
        Test.startTest();
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '12345',
                                                                        Zuora__PreviousSubscriptionId__c = '12345',
                                                                        Zuora__External_Id__c = '56789');
        insert sub;
        
        sub.Zuora__PreviousSubscriptionId__c = '56789';
        sub.Zuora__External_Id__c = '123123';
        update sub;
        delete sub;
        System.assertEquals(true, sub!=null, 'Wrong assert equals');
        Test.stopTest();
    }

    @isTest
    static void onUpdate(){
                
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '123455',
                                                                        Zuora__PreviousSubscriptionId__c = '123455',
                                                                        Zuora__External_Id__c = '567895');
        insert sub;
        List<Asset> a = XC_DF_Asset.createAssets(1);
        a[0].XC_SubscriptionName__c = sub.Name;
        a[0].XC_Subscription__c = null;
        insert a; 

        Test.startTest();
        sub.Zuora__Zuora_Id__c = '393933';
        update sub;
        System.assertEquals(true, sub!=null, 'Wrong assert equals');
        Test.stopTest();
    }
}