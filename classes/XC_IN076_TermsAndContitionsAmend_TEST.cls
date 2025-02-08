/**
 * The Class XC_IN076_TermsAndContitionsAmend_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 27/04/2021
 * @date Modification : 
 * @description       : TEST class for XC_IN076_TermsAndContitionsAmendment
 **/


@isTest
public without sharing class XC_IN076_TermsAndContitionsAmend_TEST {

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
    private static void changeTermsAndConditionsTEST1() {

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN076_TermsAndContitionsAmendment.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraChangeOwnership_Mock_200());

        Test.startTest();
            XC_IN076_TermsAndContitionsAmendment.changeTermsOnZuora(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    
    @isTest
    private static void changeTermsAndConditionsTEST2() {
        
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

        List<XC_IN076_TermsAndContitionsAmendment.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraChangeOwnership_Mock_500());

        Test.startTest();
            XC_IN076_TermsAndContitionsAmendment.changeTermsOnZuora(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    
    @isTest
    private static void changeTermsAndConditionsTEST3() {
        
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
        
        zqu__quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        quote.XC_LastSubscriptionId__c = null;
        quote.zqu__ZuoraSubscriptionID__c = null;
        update quote;

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN076_TermsAndContitionsAmendment.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraChangeOwnership_Mock_200());

        Test.startTest();
            XC_IN076_TermsAndContitionsAmendment.changeTermsOnZuora(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    
    @isTest
    private static void changeTermsAndConditionsTEST4() {
        
        Asset a = [SELECT Id, AccountId, XC_Configuration_Item__c FROM Asset LIMIT 1];
        a.XC_Subscription__c = null;
        a.XC_Original_Configuration_Item__c = null;
        update a;
        
        NE__OrderItem__c oi = new NE__OrderItem__c();
        oi.Id = a.XC_Configuration_Item__c;
        oi.XC_zQuoteId__c = null;
        update oi;
		
        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN076_TermsAndContitionsAmendment.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraChangeOwnership_Mock_200());

        Test.startTest();
            XC_IN076_TermsAndContitionsAmendment.changeTermsOnZuora(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }


    @isTest
    private static void changeTermsAndConditionsTEST5() {
		XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_ZuoraOwnerTransfer;
        ic.XC_interfaceName__c = Label.XC_CL_ZuoraOwnerTransfer;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];
        
        NE__OrderItem__c oi = new NE__OrderItem__c();
        oi.Id = ps.XC_Configuration_Item__c;
        oi.XC_ZQuoteId__c = null;
        update oi;
        
        Asset a = [SELECT Id FROM Asset WHERE XC_Configuration_Item__c =: ps.XC_Configuration_Item__c];
        a.XC_Subscription__c = null;
        a.XC_SubscriptionName__c = 'AAA';
        update a;

        List<XC_IN076_TermsAndContitionsAmendment.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraChangeOwnership_Mock_200());

        Test.startTest();
            XC_IN076_TermsAndContitionsAmendment.changeTermsOnZuora(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }

    
    private static List<XC_IN076_TermsAndContitionsAmendment.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN076_TermsAndContitionsAmendment.InputWrapper> listWrapperInput = new List<XC_IN076_TermsAndContitionsAmendment.InputWrapper>();
        XC_IN076_TermsAndContitionsAmendment.InputWrapper wr = new XC_IN076_TermsAndContitionsAmendment.InputWrapper();
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
    
    
    public without sharing class ZuoraChangeOwnership_Mock_500 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"results":[{"SubscriptionId":"8adcd9eb6cfb231d016cfcba06da0c87","TotalDeltaTcv":0,"AmendmentIds":["8adcd9eb6cfb231d016cfcba06720c82"],"TotalDeltaMrr":0,"Success":false,"errors":[{"message":"ERROR"}]}]}');
            return response;
        }
    }

}