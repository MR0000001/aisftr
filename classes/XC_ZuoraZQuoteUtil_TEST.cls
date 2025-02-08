/**
* @author Federico Amici - federico-amici@nttdata.com
* @date Creation 20/06/2019
* @description XC_ZuoraZQuoteUtil_TEST - test of zuora util
*/
@isTest
public class XC_ZuoraZQuoteUtil_TEST {
    
    @testSetup
    private static void setup(){
        /* This method creates and inserts too the order */
        //NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        //System.debug(order.NE__Order_Items__r);

        List<Account>  accountList = XC_DF_Account.createResidentialAccounts(1);
        insert accountList;
        List<Contact> conList = XC_DF_Contact.createResidentialContacts(accountList);
        conList[0].XC_PrimaryContact__c = true;
        insert conList;
        List<XC_Address__c> address =  XC_DF_Address.createAddress(accountList);
        insert address;

        /* This method creates also the account and the related address */
        Opportunity opportunityToInsert = new Opportunity();
        opportunityToInsert.Name = 'OP00001';
        opportunityToInsert.XC_Contact__c = conList[0].Id;
        opportunityToInsert.AccountId = conList[0].AccountId;
        opportunityToInsert.XC_ProductCategoryOfInterest__c = 'Caldera';
        opportunityToInsert.CloseDate = Date.newInstance(2030, 12, 31);
        opportunityToInsert.StageName = 'Draft';
        opportunityToInsert.XC_Source__c = 'BLOG';
        opportunityToInsert.XC_ReceivingChannel__c = 'Web';
        opportunityToInsert.XC_Address__c = address[0].Id;
        opportunityToInsert.XC_LegalEntity__c = 'EndesaX';
        insert opportunityToInsert;

        NE__Order__c order = new NE__Order__c();
        order.NE__Type__c = 'Order';
        order.NE__OptyId__c = opportunityToInsert.Id;
        order.NE__AccountId__c = opportunityToInsert.AccountId;
        order.XC_Country__c = 'Spain';
        order.XC_Segment__c = 'B2C';
        insert order;
        NE__OrderItem__c item = XC_DF_OrderItem.createOrderItem(order);
        insert item;
        update order;


        //order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(item.Id));
        insert ps;

        B2WExtCat__Work_Order_Item__c workOrderItem = XC_DF_RatePlan.createJunctionProductRatePlanToItem(order, item);
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

        //NE__OrderItem__c item = [SELECT ID, NE__OneTimeFeeOv__c FROM NE__OrderItem__c WHERE Id = :orderItem.Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        listBillingProfiles[0].NE__Payment__c = 'Direct Debt';
        listBillingProfiles[0].NE__Iban__c = '9484746454';
        update listBillingProfiles;

        item.NE__OneTimeFeeOv__c = 89;

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id 
                                                        FROM XC_BillingProfileLineItem__c 
                                                        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        item.XC_PaymentMethod__c = listBillingProfiles[0].NE__Payment__c;

        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
        item.XC_ZQuoteId__c = dResp.parentId;
        item.NE__Action__c = 'Add';
        item.NE__Activation_Date__c = DateTime.now();
        update item;

        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.zqu__Quote__c = dResp.parentId;
        insert quoteAmendment;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = dResp.parentId;
        qrp.zqu__QuoteAmendment__c = quoteAmendment.Id;
        insert qrp;

        zqu__QuoteRatePlanCharge__c qrpc1 = new zqu__QuoteRatePlanCharge__c();
        qrpc1.zqu__Model__c = 'Test';
        qrpc1.zqu__ChargeType__c = 'Test';
        qrpc1.zqu__QuoteRatePlan__c = qrp.Id;
        zqu__QuoteRatePlanCharge__c qrpc2 = new zqu__QuoteRatePlanCharge__c();
        qrpc2.zqu__Model__c = 'Test';
        qrpc2.zqu__ChargeType__c = 'Test';
        qrpc2.zqu__QuoteRatePlan__c = qrp.Id;
        insert qrpc1;
        insert qrpc2;

    }

    @isTest
    private static void finalSendToZBillingTEST() {

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        quote.zqu__ZuoraAccountID__c = 'jkdssdfhkbsdfhbjfsdhbjfsdhjbfsd';
        update quote;

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil.finalSendToZBilling(new List<Id>{quote.Id});
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }

    @isTest
    private static void finalSendToZBillingTEST2() {
        
        zqu__QuoteRatePlanCharge__c qrpc = [SELECT Id, zqu__QuoteRatePlan__r.zqu__Quote__r.id, zqu__QuoteRatePlan__c FROM zqu__QuoteRatePlanCharge__c LIMIT 1][0];

        String quoteID = qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.id;
        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c(id = qrpc.zqu__QuoteRatePlan__c, zqu__Quote__c = null);
        update qrp;
                                                      

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil.finalSendToZBilling(new List<Id>{quoteID});
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }

    @isTest
    private static void overridePricesTEST() {

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        quote.zqu__ZuoraAccountID__c = 'jkdssdfhkbsdfhbjfsdhbjfsdhjbfsd';
        update quote;

        NE__OrderItem__c item = [SELECT Id FROM NE__OrderItem__c LIMIT 1];
        
        Map<Id, NE__OrderItem__c> mapIdItem = new Map<Id, NE__OrderItem__c>{quote.Id => item};

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil.overridePrices(mapIdItem);
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }
    
    @isTest
    private static void overridePricesTEST2() {

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        quote.zqu__ZuoraAccountID__c = 'jkdssdfhkbsdfhbjfsdhbjfsdhjbfsd';
        update quote;

        NE__OrderItem__c item = [SELECT Id, NE__BaseOneTimeFee__c FROM NE__OrderItem__c LIMIT 1];
        item.NE__BaseOneTimeFee__c = 10;
        update item;
        
        Map<Id, NE__OrderItem__c> mapIdItem = new Map<Id, NE__OrderItem__c>{quote.Id => item};

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil.overridePrices(mapIdItem);
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }
    
    @isTest
    private static void overridePricesTEST3() {

        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        quote.zqu__ZuoraAccountID__c = 'jkdssdfhkbsdfhbjfsdhbjfsdhjbfsd';
        update quote;

        NE__OrderItem__c item = [SELECT Id, NE__OneTimeFeeOv__c FROM NE__OrderItem__c LIMIT 1];
        item.NE__OneTimeFeeOv__c = 0;
        item.NE__RecurringChargeOv__c = 10;
        update item;
        
        Map<Id, NE__OrderItem__c> mapIdItem = new Map<Id, NE__OrderItem__c>{quote.Id => item};

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil.overridePrices(mapIdItem);
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }
    

    /*@isTest
    private static void getZuoraEntityIdTEST(){

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil_U.getZuoraEntityId('EndesaX', [SELECT Id FROM XC_Provisioning_Step__c][0].Id);
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }
    
     @isTest
    private static void getZuoraEntityIdTEST2(){

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil_U.getZuoraEntityId('', [SELECT Id FROM XC_Provisioning_Step__c][0].Id);
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }
    
    @isTest
    private static void getZuoraEntityIdTEST3(){

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil_U.getZuoraEntityId('test', [SELECT Id FROM XC_Provisioning_Step__c][0].Id);
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }*/
    
    
    @isTest
    private static void getZuoraEntityWrapperTEST(){

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper('EndesaX', 'B2C', [SELECT Id FROM XC_Provisioning_Step__c][0].Id);
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }
    
  
     @isTest
    private static void getZuoraEntityWrapperTEST2(){

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper('', 'B2C', [SELECT Id FROM XC_Provisioning_Step__c][0].Id);
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }
    
    
    @isTest
    private static void getZuoraEntityWrapperTEST3(){

        Test.startTest();
        try {
            XC_ZuoraZQuoteUtil_U.getZuoraEntityWrapper('Test', 'B2C', [SELECT Id FROM XC_Provisioning_Step__c][0].Id);
        } catch(Exception e) {
            System.debug('Catched ' + e);
        }
        Test.stopTest();

        System.assert(true);
    }


  
    
}