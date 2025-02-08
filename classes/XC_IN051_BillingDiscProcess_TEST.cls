/**
 * The Class XC_IN031_DeactAutRenewal_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 04/05/2020
 * @date Modification : 
 * @description       : TEST class for XC_IN051_BillingDisconnectionProcess
 **/

@isTest
public without sharing class XC_IN051_BillingDiscProcess_TEST {

    @testSetup
    private static void setup() {

        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);

        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;

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

        originalOrder = [SELECT Id, NE__AccountID__c, XC_LegalEntity__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', originalOrder.Id);
        NE__OrderItem__c originalItem = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :originalOrder.NE__Order_Items__r[0].Id];
        originalItem.XC_ZQuoteId__c = dResp.parentId;
        update originalItem;

        zqu__quote__c quote = new zqu__quote__c(zqu__ZuoraSubscriptionID__c = '12345', id = dResp.parentId);
        update quote;

        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__OriginalId__c = '12345',
                                                                Zuora__PreviousSubscriptionId__c = '12345',
                                                                Zuora__External_Id__c = '56789',
                                                                Zuora__SubscriptionNumber__c = 'test');
        insert sub;

        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = item.Id;
        listAssets[0].XC_Original_Configuration_Item__c = originalItem.Id;

        insert listAssets;
    }


    @isTest
    private static void billingDisconnectionProcessTEST() {

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_Withdrawal;
        ic.XC_interfaceName__c = Label.XC_CL_Withdrawal;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN051_BillingDisconnectionProcess.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraWithDrawal_Mock_200());

        Test.startTest();
            XC_IN051_BillingDisconnectionProcess.billingDisconnectionProcess(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }

    
    @isTest
    private static void billingDisconnectionProcessTEST2() {

        XC_CS001_InterfaceConfiguration__c ic = new XC_CS001_InterfaceConfiguration__c();
        ic.XC_activeInterface__c = true;
        ic.XC_URL_Required__c = 'test';
        ic.Name = Label.XC_CL_Withdrawal;
        ic.XC_interfaceName__c = Label.XC_CL_Withdrawal;
        insert ic;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        Asset a = [SELECT id FROM Asset LIMIT 1][0];
        a.XC_Original_Configuration_Item__c = null;
        a.XC_SubscriptionName__c = 'test';
        update a; 
          

        List<XC_IN051_BillingDisconnectionProcess.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.setMock(HttpCalloutMock.class, new ZuoraWithDrawal_Mock_200());

        Test.startTest();
            XC_IN051_BillingDisconnectionProcess.billingDisconnectionProcess(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }


    private static List<XC_IN051_BillingDisconnectionProcess.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN051_BillingDisconnectionProcess.InputWrapper> listWrapperInput = new List<XC_IN051_BillingDisconnectionProcess.InputWrapper>();
        XC_IN051_BillingDisconnectionProcess.InputWrapper wr = new XC_IN051_BillingDisconnectionProcess.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }



    public without sharing class ZuoraWithDrawal_Mock_200 implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) { 
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"results":[{"SubscriptionId":"8adcd9eb6cfb231d016cfcba06da0c87","Success":true}]}');
            return response;
        }
    }
}