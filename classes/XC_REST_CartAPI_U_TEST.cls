/**
 * The Class XC_REST_CartAPI_TEST.
 *
 * @author            : Nicola Mariniello nmariniello@deloitte.it
 * @date Creation     : 12/06/2019
 * @date Modification : dd/mm/yyyy
 * @description       : Test Class for XC_REST_CartAPI_U
 **/
@isTest
public class XC_REST_CartAPI_U_TEST {
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

        String orgId = UserInfo.getOrganizationId();
        System.debug('orgID > ' + orgId);
        zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.zqu__EntityID__c = [Select  XC_ZuoraEntityId__c from XC_CM_LegalEntity_Configuration__mdt where XC_OrgId__c =: orgId and XC_LegalEntity__c = 'EndesaX'][0].XC_ZuoraEntityId__c;
        billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50c4';
        billingEntity.zqu__ZuoraID__c = '2000378';
        billingEntity.zqu__EntityName__c = [SELECT Id, XC_EntityId__c,XC_EntityName__c FROM XC_CM_ZuoraOAuth__mdt WHERE XC_EntityName__c LIKE '%Spain%' AND XC_OrgId__c =: orgId][0].XC_EntityName__c;
        billingEntity.zqu__ZuoraID__c = [Select  XC_ZuoraEntityId__c from XC_CM_LegalEntity_Configuration__mdt where XC_OrgId__c =: orgId and XC_LegalEntity__c = 'EndesaX'][0].XC_ZuoraEntityId__c;
        insert billingEntity;

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntity);
      
        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c, NE__CatalogItem__r.NE__Catalog_Id__r.XC_LIC_Name__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
		listBillingProfiles.get(0).NE__Payment__c  ='Bank Transfer';
        update listBillingProfiles;
        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id 
                                                        FROM XC_BillingProfileLineItem__c 
                                                        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', order.Id);
       	item.XC_PaymentMethod__c = 'Bank Transfer';
        item.XC_ZQuoteId__c = dResp.parentId;
        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        item.NE__Action__c = 'Add';
        item.NE__BaseOneTimeFee__c = 89;
        update item;

        NE__OrderItem__c originalItem = XC_DF_OrderItem.createOrderItem(order);
        originalItem.XC_PaymentMethod__c ='Bank Transfer';
        originalItem.XC_ZQuoteId__c = dResp.parentId;
        originalItem.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        originalItem.NE__Action__c = 'Remove';
        originalItem.NE__BaseOneTimeFee__c = 89;
        insert originalItem;

        B2WExtCat__Work_Order_Item__c woDB = [SELECT Id, B2WExtCat__Work_Order_Item_Code__c, B2WExtCat__Configuration_Item__c,
                                                       B2WExtCat__Work_Order__c, B2WExtCat__Action__c, RecordTypeId
                                                FROM B2WExtCat__Work_Order_Item__c LIMIT 1];
        B2WExtCat__Work_Order_Item__c workOrderOldItem = woDB.clone(false, false, false, false);
        workOrderOldItem.B2WExtCat__Configuration_Item__c = originalItem.Id;
        insert workOrderOldItem;

        List<Asset> listAssets = XC_DF_Asset.createAssets(1);
        listAssets[0].XC_Configuration_Item__c = item.Id;
        listAssets[0].XC_Original_Configuration_Item__c = originalItem.Id;
        listAssets[0].XC_Original_Creation_OrderItem__c  = originalItem.Id;
        insert listAssets;

        Case newCase    = new Case();
        newCase.Status  = 'New';
        newCase.Origin  = 'Email'; 
        insert newCase;

        List<Account> newAccount = XC_DF_Account.createResidentialAccounts(1);
    }
    
    
    
	@isTest
    static void manageUpsertItemsResponse(){
        Map<String,Object> result = new Map<String,Object>();
        
        result.put('configuration', JSON.deserializeUntyped('{"test":"test"}'));
        result.put('sessionParameters', JSON.deserializeUntyped('{"test":"test"}'));
        
        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', '');
        
        Test.startTest();
        	XC_REST_CartAPI_U.manageUpsertItemsResponse(result, infos);
        Test.stopTest();
    }

    @isTest
    static void manageUpsertItemsResponse2(){
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
        Map<String,Object> result = new Map<String,Object>();
        
        result.put('configuration', JSON.deserializeUntyped('{"test":"test"}'));
        result.put('sessionParameters', JSON.deserializeUntyped('{"test":"test"}'));
        
        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', String.valueOf(ass.Id));
        infos.put('configurationInfos', '{"test":"test"}');
        infos.put('currencyISOCode', 'IND');
        
        Test.startTest();
        	XC_REST_CartAPI_U.manageUpsertItemsResponse(result, infos);
        Test.stopTest();
    }
    
    @isTest
    static void createIntegrationLog(){
    
    	List<XC_Integration_Log__c> integrationLogsToInsert = new List<XC_Integration_Log__c>();
        XC_Integration_Log__c a = new XC_Integration_Log__c();
        integrationLogsToInsert.add(a);
    
    	Test.startTest();
        XC_REST_CartAPI_U.insertIntegrationLogs(JSON.serialize(integrationLogsToInsert), '{}');
    	Test.stopTest();
    }
    
    @isTest
    static void startProvisioning(){
        Asset ass = [SELECT Id FROM Asset LIMIT 1];
        XC_REST_MobilityOrder_W.OrderDocumentWrapper docWR = new XC_REST_MobilityOrder_W.OrderDocumentWrapper();
        docWR.ContractUrl = 'test.url.com';
        List<XC_REST_MobilityOrder_W.OrderDocumentWrapper> docList = new List<XC_REST_MobilityOrder_W.OrderDocumentWrapper>();
        docList.add(docWR);
        Map<String, String> infos = new Map<String, String>();
        infos.put('ServerURL', 'hubcqvrouqrob1er');
        infos.put('ClientId', '134719834hf143');
        infos.put('OrganizationId', 'qwvfei12u43f1w');
        infos.put('token', '31451345');
        infos.put('categoryId', '31451345');
        infos.put('catalogId', '31451345');
        infos.put('catalogItemId', '12345');
        infos.put('XC_Coupon_Code__c', '123456');
        infos.put('NE__AccountId__c', '123456');
		infos.put('complianceNeeded', 'true'); 
        infos.put('stream', 'B2B');
        infos.put('paymentMethod','Direct Debt');
        infos.put('clientSystem', 'CommodityItalyB2C');
        infos.put('ChannelCommodity', 'Gas');
        infos.put('OrderDocument', JSON.serialize(docList));
        NE__Order__c order = [Select ID from NE__Order__c LIMIT 1];
        
        Test.startTest();
        	XC_REST_CartAPI_U.startProvisioning(order.id, infos);
        Test.stopTest();
    }

     @isTest
    static void manageCheckoutTest() {
        NE__Order__c order = [Select Id from NE__Order__c LIMIT 1];
        Case c = [SELECT Id FROM Case LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Map<String, String> infos = new Map<String, String>();
        infos.put('assetId', '');
        infos.put('clientSystem', 'CommodityItalyB2C');
        infos.put('OrderSubType', 'Promocode Application');
        infos.put('XC_eMobTransactionId__c', '');
        infos.put('ChannelCommodity', '');
        infos.put('NE__AccountId__c', String.valueOf(acc.Id));
        infos.put('OrderType', 'Change Order');
        infos.put('XC_CaseId__c', String.valueOf(c.Id));
        infos.put('XC_VASContractExtID__c', '123456');
        infos.put('XC_VASContractNumber__c', '123456');
        infos.put('stream', 'B2B');

        Test.startTest();
            XC_REST_CartAPI_U.manageCheckout(String.valueOf(order.Id), 0, infos);
            XC_REST_CartAPI_U.manageCheckout(String.valueOf(order.Id), 1, infos);
            infos.put('clientSystem', 'CommodityRomaniaB2C');
            infos.put('stream', 'B2C');
            XC_REST_CartAPI_U.manageCheckout(String.valueOf(order.Id), 1, infos);
        Test.stopTest();
    }

    @isTest
    static void manageExternalDocumentTest() {
        Map<String, String> infos = new Map<String, String>();
        XC_REST_MobilityOrder_W.OrderDocumentWrapper docWR = new XC_REST_MobilityOrder_W.OrderDocumentWrapper();
        docWR.ContractUrl = 'test.url.com';
        List<XC_REST_MobilityOrder_W.OrderDocumentWrapper> docList = new List<XC_REST_MobilityOrder_W.OrderDocumentWrapper>();
        docList.add(docWR);
        infos.put('OrderDocument', JSON.serialize(docList));
        NE__Order__c order = [Select ID from NE__Order__c LIMIT 1];
        
        Test.startTest();
        	XC_REST_CartAPI_U.manageExternalDocument(order.id, infos);
        Test.stopTest();
    }

    @isTest
    static void composeChildCartAndItemsMapTest() {
        //String jsonCartItems = '[{"test":"test"}, {"test1":"test1"}]';
        String jsonCartItems = '[{"Account":{"AccountType":"Small Business","LastName":"LIBRIAMOCI","Name":"LIBRIAMOCI"}},{"Contact":{"LastName":"SPALLINO","FirstName":"ADELAIDE","PrimaryContact":true}}]';
        Test.startTest();
            try{
                XC_REST_CartAPI_U.composeChildCartAndItemsMap(jsonCartItems);
            }catch(Exception e){}
            XC_REST_CartAPI_U.skipTestMFL();
        Test.stopTest();
    }
}