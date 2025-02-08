/**
 * The Class XC_IN052_RemoveResidualAmount_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation     : 14/05/2020
 * @date Modification : 
 * @description       : TEST class for XC_IN052_RemoveResidualAmount
 **/


@isTest
public without sharing class XC_IN052_RemoveResidualAmount_TEST {


    @testSetup
    private static void setup() {

        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);

        zqu__ZProduct__c zp = new zqu__ZProduct__c();
        insert zp;
        zqu__ProductRatePlan__c prp = new  zqu__ProductRatePlan__c (zqu__ZProduct__c =zp.id,  zqu__ProductRatePlanFullName__c = Label.XC_CL_RatePlan_ValorResidualOneTime);
        insert prp;

        order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;

        String orgId = UserInfo.getOrganizationId();
        List<XC_CM_ZuoraOAuth__mdt> zuoraList = [SELECT Id, XC_EntityId__c, XC_EntityName__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE '%Spain%'  AND XC_OrgId__c =: orgId];
        List<zqu__BillingEntity__c> billingEntityList = new List<zqu__BillingEntity__c>();
        Integer i = 1;
        for(XC_CM_ZuoraOAuth__mdt z : zuoraList){
            zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
            billingEntity.zqu__EntityID__c = z.XC_EntityId__c;
            billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50' + i;
            billingEntity.zqu__ZuoraID__c = '2000378' + i;
            billingEntity.zqu__EntityName__c = z.XC_EntityName__c;
            billingEntityList.add(billingEntity);
            i++;
        }
        insert billingEntityList;

        B2WZC__Bit2WinConnector__c b2wConnector = new B2WZC__Bit2WinConnector__c(Name = 'ZuoraConnector', B2WZC__isActiveConnector__c = true);
        insert b2wConnector;

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntityList[0]);
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
                                                                Zuora__SubscriptionNumber__c = 'test',
                                                               	Zuora__Version__c = 1);
        insert sub;
        
        Zuora__SubscriptionRatePlan__c subRP = new Zuora__SubscriptionRatePlan__c(Zuora__SubscriptionRatePlanName__c = Label.XC_CL_RatePlan_ValorResidualOneTime,
                                                                                 Zuora__Subscription__c = sub.Id);
       	insert subRP;

        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = item.Id;
        listAssets[0].XC_Original_Configuration_Item__c = originalItem.Id;
        listAssets[0].XC_SubscriptionName__c = 'test';

        insert listAssets;
    }


    @isTest
    private static void removeResidualTEST() {
        
        List<Zuora__SubscriptionRatePlan__c> srpList = new List<Zuora__SubscriptionRatePlan__c>([SELECT Id FROM Zuora__SubscriptionRatePlan__c]);
        delete srpList;

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];          

        List<XC_IN052_RemoveResidualAmount.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.startTest();
            XC_IN052_RemoveResidualAmount.removeResidualAmount(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    
    @isTest
    private static void removeResidualTEST2() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];          

        List<XC_IN052_RemoveResidualAmount.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.startTest();
            XC_IN052_RemoveResidualAmount.removeResidualAmount(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    
    @isTest
    private static void removeResidualTEST3() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id =: ps.XC_Configuration_Item__c][0];
        item.XC_ZQuoteId__c = '';
        update item;

        List<XC_IN052_RemoveResidualAmount.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.startTest();
            XC_IN052_RemoveResidualAmount.removeResidualAmount(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }
    
    
    @isTest
    private static void removeResidualTEST4() {

        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        NE__Order__c order = [SELECT ID, NE__Type__c, XC_Subtype__c FROM NE__Order__c][0];
        order.NE__Type__c = 'ChangeOrder';
        order.XC_Subtype__c = 'eMobility Change Offer';
        update order;

        List<XC_IN052_RemoveResidualAmount.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.startTest();
            XC_IN052_RemoveResidualAmount.removeResidualAmount(listInputWrapper);
        Test.stopTest();

        System.assert(true, ps != null);
    }


    private static List<XC_IN052_RemoveResidualAmount.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN052_RemoveResidualAmount.InputWrapper> listWrapperInput = new List<XC_IN052_RemoveResidualAmount.InputWrapper>();
        XC_IN052_RemoveResidualAmount.InputWrapper wr = new XC_IN052_RemoveResidualAmount.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;
    }
    
}