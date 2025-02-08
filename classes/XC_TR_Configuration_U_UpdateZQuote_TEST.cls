/** 
 * @author      Federico Amici - federico.amici@nttdata.com
 * @date        25/06/2019
 * @description Handles the action related to the update and send of the zQuote
 */
@isTest
public class XC_TR_Configuration_U_UpdateZQuote_TEST {

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

        B2WZC__Bit2WinConnector__c b2wConnector = new B2WZC__Bit2WinConnector__c(Name = 'ZuoraConnector', B2WZC__isActiveConnector__c = true);
        insert b2wConnector;

        zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.zqu__EntityID__c = '8adc8f99684b618601684d4127781f61';
        billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50c4';
        billingEntity.zqu__ZuoraID__c = '2000378';
        billingEntity.zqu__EntityName__c = 'Enel Spain B2C';
        insert billingEntity;

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntity);

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        item.NE__BaseOneTimeFee__c = 89;

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id 
                                                        FROM XC_BillingProfileLineItem__c 
                                                        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;

        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        item.XC_ZQuoteId__c = dResp.parentId;
        item.NE__Activation_Date__c = DateTime.now();
        update item;

        NE__OrderItem__c oldItem = XC_DF_OrderItem.createOrderItem(order);
        oldItem.XC_ZQuoteId__c = dResp.parentId;
        oldItem.NE__Activation_Date__c = DateTime.now();
        insert oldItem;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item, 'Modalidad de Contratacion', '3');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        listAsset[0].XC_Original_Creation_OrderItem__c = oldItem.Id;
        insert listAsset;
        
        b2wzc.Bit2Win_OrderConnector.AddQuoteRatePlanFromRatePlan(dResp.parentId, new List<String>{workOrderItem.B2WExtCat__Work_Order_Item_Code__c});
        
        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc1 = new zqu__QuoteRatePlanCharge__c();
        qrpc1.zqu__QuoteRatePlan__c = qrp.Id;
        zqu__QuoteRatePlanCharge__c qrpc2 = new zqu__QuoteRatePlanCharge__c();
        qrpc2.zqu__QuoteRatePlan__c = qrp.Id;
        insert qrpc1;
        insert qrpc2;
    }
	
    @isTest
    private static void queueableTEST() {
        
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        XC_TR_ConfigurationItem_U_UpdateZQuote.Params param = new XC_TR_ConfigurationItem_U_UpdateZQuote.Params();
        param.price = '783';
        param.quantity = '83';
        Map<String, XC_TR_ConfigurationItem_U_UpdateZQuote.Params> mapZQuotePrice = new Map<String, XC_TR_ConfigurationItem_U_UpdateZQuote.Params>{quote.Id => param};
                
        Test.startTest();
        	System.enqueueJob(new XC_TR_ConfigurationItem_U_UpdateZQuote.ManageDMLQueuable(quote.Id, mapZQuotePrice));
        Test.stopTest();
        
        System.assert([SELECT Count() FROM zqu__Quote__c] == 1);
        
    }
    
    @isTest
    private static void queueableTEST2() {
        
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
                
        Test.startTest();
        	System.enqueueJob(new XC_TR_ConfigurationItem_U_UpdateZQuote.SendFutureQueuable(new List<Id>{quote.Id}));
        Test.stopTest();
        
        System.assert([SELECT Count() FROM zqu__Quote__c] == 1);
        
    }
    
}