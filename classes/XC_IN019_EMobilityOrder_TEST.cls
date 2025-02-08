/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Test of the invocable class that calls the Order Callback interface
*/
@isTest
public class XC_IN019_EMobilityOrder_TEST {
    
    @testSetup
    private static void setup() {

        insert new B2WZC__Bit2WinConnector__c(Name='ZuoraConnector',B2WZC__isActiveConnector__c=true);

        /* This method creates and inserts too the order */
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);

        order = [SELECT Id,  NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
        B2WExtCat__Work_Order_Item__c workOrderItem = XC_DF_RatePlan.createJunctionProductRatePlanToItem(order, order.NE__Order_Items__r[0]);
        insert workOrderItem;

        zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.zqu__EntityID__c = '8adc8f99684b618601684d4127781f61';
        billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50c4';
        billingEntity.zqu__ZuoraID__c = '2000378';
        billingEntity.zqu__EntityName__c = 'Enel Spain B2C';
        insert billingEntity;

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntity);
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteID__c, NE__ProdId__c FROM NE__OrderItem__c WHERE ID = :order.NE__Order_Items__r[0].Id];
        item.XC_ZQuoteId__c = dResp.parentId;
        
        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].Name = 'Domestic Offer';
        listProducts[0].XC_Product_Type__c = 'Service';
        listProducts[0].XC_Product_SubType__c = 'Electric';
        insert listProducts;

        List<XC_Voucher__c> listVoucher = XC_DF_Voucher.generatePromotionalVoucher(1);
        listVoucher[0].XC_CostCenter__c = 'COSTCent';
        listVoucher[0].XC_CompanyCode__c = 'COMPCode';
        insert listVoucher;

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountId__c];

        NE__OrderItem__c oldItem = XC_DF_OrderItem.createOrderItem(order);
        oldItem.XC_ZQuoteId__c = dResp.parentId;
        oldItem.NE__Activation_Date__c = DateTime.now();
        insert oldItem;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item, 'Modalidad de Contratacion', '3');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        listAsset[0].XC_Original_Creation_OrderItem__c = oldItem.Id;
        listAsset[0].XC_Original_Configuration_Item__c = oldItem.Id;
        insert listAsset;
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;
    }

    @isTest
    private static void callbackOrderTEST() {
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN019_EMobilityOrder.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        listInputWrapper[0].isChangeBP = true;


        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
         NE__Order__c order = [SELECT Id, XC_Coupon_Code__c 
                                FROM NE__Order__c 
                                LIMIT 1];
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        item.XC_ZQuoteID__c = quote.ID;
        update item;

        // Asset a = [SELECT ID From Asset LIMIT 1];
        // a.XC_Configuration_Item__c=item.Id;
        // update a;

        Test.startTest();
            XC_IN019_EMobilityOrder.callbackOrder(listInputWrapper);
        Test.stopTest();
        
        Integer numberOfQuote = [SELECT COUNT() FROM zqu__Quote__c WHERE Id =:item.XC_ZQuoteID__c];
        System.assert(numberOfQuote == 1);
    }

    @isTest
    private static void callbackOrderTEST2() {
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN019_EMobilityOrder.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        listInputWrapper[0].isChangeBP = false;


        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
         NE__Order__c order = [SELECT Id, XC_Coupon_Code__c 
                                FROM NE__Order__c 
                                LIMIT 1];
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        item.XC_ZQuoteID__c = quote.ID;
        update item;

        Test.startTest();
            XC_IN019_EMobilityOrder.callbackOrder(listInputWrapper);
        Test.stopTest();
        
        Integer numberOfQuote = [SELECT COUNT() FROM zqu__Quote__c WHERE Id =:item.XC_ZQuoteID__c];
        System.assert(numberOfQuote == 1);
    }
    
    @isTest
    private static void callbackOrderDomesticOfferTEST() {
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN019_EMobilityOrder.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c, NE__OrderId__c,
                                        NE__OrderId__r.XC_Cost_Center__c, NE__OrderId__r.XC_Company_Code__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];

        XC_Voucher__c voucher = [SELECT Id, XC_VoucherCode__c, XC_CostCenter__c, XC_CompanyCode__c
                                 FROM XC_Voucher__c 
                                 LIMIT 1];

        NE__Order__c order = [SELECT Id, XC_Coupon_Code__c 
                                FROM NE__Order__c 
                                LIMIT 1];
        order.XC_Coupon_Code__c = voucher.XC_VoucherCode__c;
        update order;

        Asset a = [SELECT Id, XC_CostCenter__c, XC_CompanyCode__c, XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];
        a.XC_CostCenter__c = voucher.XC_CostCenter__c;
        a.XC_CompanyCode__c = voucher.XC_CompanyCode__c;
        update order;

        NE__Product__c prod = [SELECT Id 
                               FROM NE__Product__c WHERE NAME ='Domestic Offer'
                               LIMIT 1];
        prod.Name = Label.XC_CL_CatItem_DomesticOffer;
        update prod;
        item.NE__ProdId__c = prod.ID;
        update item;

        Test.startTest();
            XC_IN019_EMobilityOrder.callbackOrder(listInputWrapper);
        Test.stopTest();

        Integer numberOfAsset = [SELECT COUNT() 
                                 FROM Asset
                                 WHERE XC_CompanyCode__c =:item.NE__OrderId__r.XC_Company_Code__c
                                       AND XC_CostCenter__c =:item.NE__OrderId__r.XC_Cost_Center__c];
        System.assert(numberOfAsset == 1);
    }

    @isTest
    private static void callbackParentTEST() {
        
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN019_EMobilityOrder.InputWrapper> listInputWrapper = generateInputWrapper(ps);
        listInputWrapper[0].callbackParent = true;

        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c, NE__ProdId__c,  NE__OrderId__c,
                                            NE__OrderId__r.XC_Coupon_Code__c
                                 FROM NE__OrderItem__c
                                 LIMIT 1];
        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].Name = 'ProdTEST';
        listProducts[0].XC_Product_Type__c = 'Service';
        listProducts[0].XC_Product_SubType__c = 'Electric';
        insert listProducts;         

        System.debug('@@@@ ' + item.NE__ProdName__c);

        XC_Voucher__c voucher = [SELECT Id, XC_VoucherCode__c, XC_CostCenter__c, XC_CompanyCode__c
                                 FROM XC_Voucher__c 
                                 LIMIT 1];

        NE__Order__c order = [SELECT Id, XC_Coupon_Code__c 
                                FROM NE__Order__c 
                                LIMIT 1];
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        order.XC_Coupon_Code__c = voucher.XC_VoucherCode__c;
        update order;

        Asset a = [SELECT Id, XC_CostCenter__c, XC_CompanyCode__c, XC_ZQuoteId__c
                    FROM Asset
                    LIMIT 1];
        a.XC_CostCenter__c = voucher.XC_CostCenter__c;
        a.XC_CompanyCode__c = voucher.XC_CompanyCode__c;
        a.XC_Configuration_Item__c = item.Id;

        item.XC_ZQuoteID__c = dResp.parentId;
        update item;

        update a;

        Test.startTest();+
            XC_IN019_EMobilityOrder.callbackOrder(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT COUNT() FROM zqu__Quote__c WHERE Id =:item.XC_ZQuoteID__c];
        System.assert(numberOfQuote == 1);

    }

    private static List<XC_IN019_EMobilityOrder.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN019_EMobilityOrder.InputWrapper> listWrapperInput = new List<XC_IN019_EMobilityOrder.InputWrapper>();
        XC_IN019_EMobilityOrder.InputWrapper wr = new XC_IN019_EMobilityOrder.InputWrapper();
        wr.stepId = ps.Id;
        wr.callbackParent = false;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }

}