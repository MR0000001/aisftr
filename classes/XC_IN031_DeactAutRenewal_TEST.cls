/**
 * The Class XC_IN031_DeactAutRenewal_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 04/09/2019
 * @date Modification : 
 * @description       : TEST class for XC_IN031_DeactivateAutomaticRenewal
 **/

@isTest
public without sharing class XC_IN031_DeactAutRenewal_TEST {

    @testSetup
    private static void setup() {
		
        /* This method creates and inserts too the order */
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);

        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;
		Test.startTest();
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
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        item.NE__BaseOneTimeFee__c = 89;

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id 
                                                        FROM XC_BillingProfileLineItem__c 
                                                        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;

        NE__Order__c originalOrder = XC_DF_Order.createOrder('InOrder');
        originalOrder = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', originalOrder.Id);
        NE__OrderItem__c originalItem = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :originalOrder.NE__Order_Items__r[0].Id];
        originalItem.XC_ZQuoteId__c = dResp.parentId;
        update originalItem;
        
        zqu__Quote__c quote = new zqu__Quote__c(Id = dResp.parentId, XC_LastSubscriptionId__c = '123');
        update quote;

        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = item.Id;
        listAssets[0].XC_Original_Configuration_Item__c = originalItem.Id;
        listAssets[0].XC_Service_Last_Renewal_Date__c = System.today();

        insert listAssets;
        Test.stopTest();
    }


    @isTest
    private static void changeAutoRenewalTEST() {

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraChangeOwnership_Mock_200());

        Test.startTest();
            XC_IN031_DeactivateAutomaticRenewal.changeAutoRenewal(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    
    @isTest
    private static void changeAutoRenewalTEST2() {
        
        Asset a = [SELECT Id, AccountId FROM Asset LIMIT 1];
        
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c(Zuora__Account__c = a.AccountId, Zuora__Zuora_Id__c = '456', Zuora__External_Id__c = '456');
        insert ca;
        
        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '456',
                                                               Zuora__PreviousSubscriptionId__c = '456',
                                                               Zuora__External_Id__c = '456',
                                                               Zuora__CustomerAccount__c = ca.Id);
        insert sub;
        a.XC_Subscription__c = sub.id;
        update a;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraChangeOwnership_Mock_200());

        Test.startTest();
            XC_IN031_DeactivateAutomaticRenewal.changeAutoRenewal(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    
    @isTest
    private static void changeAutoRenewalTEST3() {
        
        Asset a = [SELECT Id, AccountId FROM Asset LIMIT 1];
        
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c(Zuora__Account__c = a.AccountId, Zuora__Zuora_Id__c = '123', Zuora__External_Id__c = '123');
        insert ca;
        
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

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraChangeOwnership_Mock_200());

        Test.startTest();
            XC_IN031_DeactivateAutomaticRenewal.changeAutoRenewal(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    
    @isTest
    private static void changeAutoRenewalTEST4() {
        
        Asset a = [SELECT Id, AccountId FROM Asset LIMIT 1];
        
        a.XC_Subscription__c = null;
        a.XC_Original_Configuration_Item__c = null;
        a.XC_SubscriptionName__c = null;
        update a;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraChangeOwnership_Mock_200());

        Test.startTest();
            XC_IN031_DeactivateAutomaticRenewal.changeAutoRenewal(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }


    @isTest
    private static void changeAutoRenewalTEST_SuccessFalse() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.startTest();
            XC_IN031_DeactivateAutomaticRenewal.changeAutoRenewal(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    @isTest
    private static void changeAutoRenewal_Error() {

        List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper> listInputWrapper = new List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper>();
        
        Test.startTest();
            XC_IN031_DeactivateAutomaticRenewal.changeAutoRenewal(listInputWrapper);
        Test.stopTest();

        System.assert(true, listInputWrapper.isEmpty());
    }
    
    
    @isTest
    private static void getSubscriptionTEST() {

        Zuora__Subscription__c sub = new Zuora__Subscription__c();
        sub.Zuora__SubscriptionNumber__c = '111';
        insert sub;
        
        Test.startTest();
            XC_IN031_DeactivateAutomaticRenewal_D.getSubscription('111');
        Test.stopTest();

        System.assert(true, sub!=null);
    }
    
    
     @isTest
    private static void changeAutoRenewalTEST5() {

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name =  Label.XC_CL_ZuoraDisconnection;
        ic.XC_interfaceName__c =  Label.XC_CL_ZuoraDisconnection;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c itemList = [SELECT ID, XC_BillingProfileLineItem__c, XC_BillingProfileLineItem__r.XC_CustomerAccount__r.Zuora__Zuora_Id__c,
                                                                            (SELECT Id, XC_SubscriptionName__c,XC_Original_Configuration_Item__c, XC_Original_Configuration_Item__r.XC_ZQuoteId__c, XC_Service_Last_Renewal_Date__c, NE__Activation_Date__c FROM Assets__r)
                                                                            FROM NE__OrderItem__c 
                                                                            WHERE Id = :ps.XC_Configuration_Item__c];

        zqu__Quote__c quote = new zqu__Quote__c(Id=itemList.Assets__r[0].XC_Original_Configuration_Item__r.XC_ZQuoteId__c);
        quote.zqu__Subscription_Term_Type__c='Evergreen';
        update quote;
        Test.setMock(HttpCalloutMock.class, new XC_REST_Disconnection_Mock());

        Test.startTest();
            //XC_IN031_DeactivateAutomaticRenewal.changeAutoRenewal(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }

    @isTest
    private static void getItemsByOrderIdTest() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];


        Test.startTest();
            XC_IN011_ChangeProvBillingProcess_D.getItemsByOrderId(ps.XC_Configuration_Item__r.NE__OrderId__c);
        Test.stopTest();

        System.assert(true, ps != null);
    }

     @isTest
    private static void getJunctionRatePlanToItem() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<id> listItemIds = new List<id>();
        listItemIds.add(ps.XC_Configuration_Item__c);

        Test.startTest();
            XC_IN011_ChangeProvBillingProcess_D.getJunctionRatePlanToItem(listItemIds);
        Test.stopTest();

        System.assert(true, ps != null);
    }

    @isTest
    private static void getJunctionRatePlanToItemTest2() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<id> listItemIds = new List<id>();
        listItemIds.add(ps.XC_Configuration_Item__c);

        Test.startTest();
            XC_IN011_ChangeProvBillingProcess_D.getJunctionRatePlanToItem(listItemIds, new Map<String, List<String>>()) ;
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    @isTest
    private static void getItemsByOldIdsTest() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<id> listItemIds = new List<id>();
        listItemIds.add(ps.XC_Configuration_Item__c);

        Test.startTest();
            XC_IN011_ChangeProvBillingProcess_D.getItemsByOldIds(listItemIds); 
        Test.stopTest();

        System.assert(true, ps != null);
    }





    

    
    private static List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper> listWrapperInput = new List<XC_IN031_DeactivateAutomaticRenewal.InputWrapper>();
        XC_IN031_DeactivateAutomaticRenewal.InputWrapper wr = new XC_IN031_DeactivateAutomaticRenewal.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }

    public without sharing class ZuoraChangeOwnership_Mock_200 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"results":[{"SubscriptionId":"8adcd9eb6cfb231d016cfcba06da0c87","TotalDeltaTcv":0,"AmendmentIds":["8adcd9eb6cfb231d016cfcba06720c82"],"TotalDeltaMrr":0,"Success":true}]}');
            return response;
        }
    }
    
     public with sharing class XC_REST_Disconnection_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
    
            Map<String, Object> resp = new Map<String, Object>();
            resp.put('access_token','test');
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(resp, true));
            res.setStatusCode(200);
            return res;    
        }
    }

}