/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Test of the invocable class that changes the zuora account 
*/
@isTest
public class XC_IN024_ChangeBillingProfile_TEST {
 
    @testSetup
    private static void setup() {

        /* This method creates and inserts too the order */
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);

        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;

        B2WExtCat__Work_Order_Item__c workOrderItem = XC_DF_RatePlan.createJunctionProductRatePlanToItem(order, order.NE__Order_Items__r[0]);
        insert workOrderItem;

        zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.zqu__EntityID__c = '8adc8f99684b618601684d4127781f61';
        billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50c4';
        billingEntity.zqu__ZuoraID__c = '2000378';
        billingEntity.zqu__EntityName__c = 'Enel Spain B2C';
        insert billingEntity;
        
        B2WZC__Bit2WinConnector__c b2wConnector = new B2WZC__Bit2WinConnector__c(Name = 'ZuoraConnector', B2WZC__isActiveConnector__c = true);
        insert b2wConnector;

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntity);
        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(2, accList);
        listBillingProfiles[0].NE__Payment__c = 'Bank Transfer';
        listBillingProfiles[1].NE__Payment__c = 'Bank Transfer';
        update listBillingProfiles;
        item.NE__BaseOneTimeFee__c = 89;

        Zuora__CustomerAccount__c ca1 = new Zuora__CustomerAccount__c(Zuora__Account__c = accList[0].Id, Zuora__Zuora_Id__c = '123', Zuora__External_Id__c = '123');
        Zuora__CustomerAccount__c ca2 = new Zuora__CustomerAccount__c(Zuora__Account__c = accList[0].Id, Zuora__Zuora_Id__c = '456', Zuora__External_Id__c = '456');
        insert ca1;
        insert ca2;

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id FROM XC_BillingProfileLineItem__c LIMIT 2];
        listBPLI[0].XC_CustomerAccount__c = ca1.Id;
        listBPLI[1].XC_CustomerAccount__c = ca2.Id;
        update listBPLI;

        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        item.XC_PreviousBillingProfileLineItem__c = listBPLI[1].ID;
        item.XC_PaymentMethod__c = 'Bank Transfer';
        update item;

        NE__Order__c originalOrder = XC_DF_Order.createOrder('InOrder');
        originalOrder = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', originalOrder.Id);
        NE__OrderItem__c originalItem = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :originalOrder.NE__Order_Items__r[0].Id];
        originalItem.XC_ZQuoteId__c = dResp.parentId;
        update originalItem;
        
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Id = dResp.parentId;
        quote.XC_LastSubscriptionId__c = '111';
        update quote;

        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = item.Id;
        listAssets[0].XC_Original_Configuration_Item__c = originalItem.Id;

        insert listAssets;
    }
    
    
    @isTest
    private static void changeBillingProfileTEST1() {

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = new List<XC_IN024_ChangeBillingProfile.InputWrapper>();
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();

        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];

        Integer countZQuote = [SELECT COUNT() 
                                FROM zqu__Quote__c 
                                WHERE Id=:a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c];
        System.assert(countZQuote == 1);
    }
    
    
    @isTest
    private static void changeBillingProfileTEST2() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c, XC_PreviousBillingProfileLineItem__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
        item.XC_BillingProfileLineItem__c = item.XC_PreviousBillingProfileLineItem__c;
        update item;
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();
        
        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];

        Integer countZQuote = [SELECT COUNT() 
                                FROM zqu__Quote__c 
                                WHERE Id=:a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c];
        System.assert(countZQuote == 1);
    }

    
    @isTest
    private static void changeBillingProfileTEST3() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();

        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];

        Integer countZQuote = [SELECT COUNT() 
                                FROM zqu__Quote__c 
                                WHERE Id=:a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c];
        System.assert(countZQuote == 1);
    }
    
    
    @isTest
    private static void changeBillingProfileTEST4() {
        
        zqu__quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        quote.zqu__ZuoraSubscriptionID__c = null;
        quote.XC_LastSubscriptionId__c = null;
        update quote;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();

        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];

        Integer countZQuote = [SELECT COUNT() 
                                FROM zqu__Quote__c 
                                WHERE Id=:a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c];
        System.assert(countZQuote == 1);
    }

    
    @isTest
    private static void changeBillingProfileTEST5() {
        
        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];
        
        Zuora__CustomerAccount__c ca = [SELECT Id FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = '123' LIMIT 1];
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '123',
                                                               Zuora__PreviousSubscriptionId__c = '123',
                                                               Zuora__External_Id__c = '123',
                                                               Zuora__CustomerAccount__c = ca.Id);
        insert sub;
        a.XC_Subscription__c = sub.id;
        update a;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
        item.XC_PreviousBillingProfileLineItem__c = null;
        update item;
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();

        Integer countZQuote = [SELECT COUNT() 
                                FROM zqu__Quote__c 
                                WHERE Id=:a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c];
        System.assert(countZQuote == 1);
    }
    
    
    @isTest
    private static void changeBillingProfileTEST6() {
        
        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];
        
        Zuora__CustomerAccount__c ca = [SELECT Id FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = '456' LIMIT 1];
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '456',
                                                               Zuora__PreviousSubscriptionId__c = '456',
                                                               Zuora__External_Id__c = '456',
                                                               Zuora__CustomerAccount__c = ca.Id);
        insert sub;
        a.XC_Subscription__c = sub.id;
        update a;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
        item.XC_PreviousBillingProfileLineItem__c = null;
        update item;
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();

        Integer countZQuote = [SELECT COUNT() 
                                FROM zqu__Quote__c 
                                WHERE Id=:a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c];
        System.assert(countZQuote == 1);
    }
    
    
    @isTest
    private static void changeBillingProfileTEST7() {
        
        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];
        
        Zuora__CustomerAccount__c ca = [SELECT Id FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = '123' LIMIT 1];
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '123',
                                                               Zuora__PreviousSubscriptionId__c = '123',
                                                               Zuora__External_Id__c = '123',
                                                               Zuora__CustomerAccount__c = ca.Id,
                                                               Zuora__SubscriptionNumber__c = 'SubName');
        insert sub;
        a.XC_Subscription__c = null;
        a.XC_Original_Configuration_Item__c = null;
        a.XC_SubscriptionName__c = 'SubName';
        update a;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
        item.XC_PreviousBillingProfileLineItem__c = null;
        update item;
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();

        Integer countZQuote = [SELECT COUNT() 
                                FROM zqu__Quote__c 
                                WHERE Id=:a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c];
        System.assert(countZQuote == 1);
    }
    
    
    @isTest
    private static void changeBillingProfileTEST8() {
        
        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];
 
        a.XC_Subscription__c = null;
        a.XC_Original_Configuration_Item__c = null;
        a.XC_SubscriptionName__c = null;
        update a;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
        item.XC_PreviousBillingProfileLineItem__c = null;
        update item;
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();

        Integer countZQuote = [SELECT COUNT() 
                                FROM zqu__Quote__c 
                                WHERE Id=:a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c];
        System.assert(countZQuote == 1);
    }


    
    private static List<XC_IN024_ChangeBillingProfile.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listWrapperInput = new List<XC_IN024_ChangeBillingProfile.InputWrapper>();
        XC_IN024_ChangeBillingProfile.InputWrapper wr = new XC_IN024_ChangeBillingProfile.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }

    @isTest
    private static void changeBillingProfileTESTCancelledSubscription() {

        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];
        
        Zuora__CustomerAccount__c ca = [SELECT Id FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = '456' LIMIT 1];
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '456',
                                                               Zuora__PreviousSubscriptionId__c = '456',
                                                               Zuora__External_Id__c = '456',
                                                               Zuora__CustomerAccount__c = ca.Id,
                                                               Zuora__Status__c ='Cancelled');
        insert sub;
        a.XC_Subscription__c = sub.id;
        update a;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
        item.XC_PreviousBillingProfileLineItem__c = null;
        update item;
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();

        Integer countZQuote = [SELECT COUNT() 
                                FROM zqu__Quote__c 
                                WHERE Id=:a.XC_Original_Configuration_Item__r.XC_ZQuoteId__c];
        System.assert(countZQuote == 1);
        
    }

    @isTest
    private static void changeBillingProfileTESTCancelledSubscription2() {

        Asset a = [SELECT Id, XC_Original_Configuration_Item__r.XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];
        
        Zuora__CustomerAccount__c ca = [SELECT Id FROM Zuora__CustomerAccount__c WHERE Zuora__Zuora_Id__c = '456' LIMIT 1];
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '456',
                                                                Zuora__PreviousSubscriptionId__c = '456',
                                                                Zuora__External_Id__c = '456',
                                                                Zuora__CustomerAccount__c = ca.Id,
                                                                Zuora__SubscriptionNumber__c = 'SubName', 
                                                                Zuora__Status__c ='Cancelled');
        insert sub;
        a.XC_Original_Configuration_Item__c = null;
        a.XC_SubscriptionName__c = 'SubName';
        update a;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                        FROM XC_Provisioning_Step__c
                                        LIMIT 1];

        List<XC_IN024_ChangeBillingProfile.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                    FROM NE__OrderItem__c
                                    LIMIT 1];
        item.XC_PreviousBillingProfileLineItem__c = null;
        update item;
        
        Test.setMock(HttpCalloutMock.class, new XC_IN024_ChangeBillingProfile_Mock());
        
        Test.startTest();
            XC_IN024_ChangeBillingProfile.changeBillingProfile(listInputWrapper);
        Test.stopTest();
    }

}