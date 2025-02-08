@isTest
public class XC_TR_Contract_UpdateSubscriptions_TEST {
    
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

        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntityList[0]);

        NE__OrderItem__c item = [SELECT ID, NE__BaseOneTimeFee__c FROM NE__OrderItem__c WHERE Id = :order.NE__Order_Items__r[0].Id];

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountID__c];
        List<NE__Billing_Profile__c> listBillingProfiles = XC_DF_BillingProfile.createBillingProfile(1, accList);
        item.NE__BaseOneTimeFee__c = 89;

        List<XC_BillingProfileLineItem__c> listBPLI = [SELECT Id
        FROM XC_BillingProfileLineItem__c
        WHERE XC_BillingProfile__c =:listBillingProfiles[0].Id];
        if( listBillingProfiles[0].NE__Payment__c == null || listBillingProfiles[0].NE__Payment__c == ''){
            listBillingProfiles[0].NE__Payment__c = 'Credit Card';
            item.XC_BillingModel__c = 'One Shot';
            item.XC_PaymentMethod__c = 'Credit Card';
            update listBillingProfiles[0];
        }
        if( item.XC_PaymentMethod__c == null || item.XC_PaymentMethod__c == ''){
            item.XC_BillingModel__c = 'One Shot';
            item.XC_PaymentMethod__c = 'Credit Card';
        }

        item.XC_BillingProfileLineItem__c = listBPLI[0].ID;
        update item;

        NE__Order_Item_Attribute__c attr = XC_DF_OrderItemAttribute.createOrderItemAttribute(item,
                Label.XC_CL_ConfigurationItemAttribute_DevPaymentModel,
                'Payment');
        insert attr;

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        insert listAsset;

    }
    
	@isTest
    public static void testUpdate1(){
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c
        FROM XC_Provisioning_Step__c
        LIMIT 1];

        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteId__c, NE__ProdName__c
        FROM NE__OrderItem__c
        LIMIT 1];
        List<XC_IN018_CreateZQuote.ExternalWrapper> listWrapperExternal = new List<XC_IN018_CreateZQuote.ExternalWrapper>();
        XC_IN018_CreateZQuote.ExternalWrapper wr = new XC_IN018_CreateZQuote.ExternalWrapper();
        wr.stepId = ps.Id;
        wr.generateInvoice = true;
        wr.separateInvoice = false;
        wr.configurationItemId = item.Id;
        listWrapperExternal.add(wr);

        XC_IN018_CreateZQuote.createZquote(listWrapperExternal);
        
        Test.startTest(); 
        	Account acc = [select id from Account limit 1][0];
        	NE__Order__c order = [SELECT Id, NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c limit 1];
        	List<Contract> contractList = XC_DF_Contract.createContracts(1);
        	contractList[0].XC_Segment__c = 'B2B';
        	contractList[0].XC_LegalEntity__c = 'EnelXItalia';
        	contractList[0].RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('XC_B2B_EnelXItalia_Contract').getRecordTypeId();
        	contractList[0].AccountId = acc.Id;
        	contractList[0].XC_Configurations__c = order.Id;
        	insert contractList;
        	zqu__Quote__c q = [select id from zqu__quote__c limit 1][0];
        	q.CRMConfiguration__c = order.Id;
        	update q;
        	contractList[0].XC_CIG__c = '123';
        	update contractList;
        Test.stopTest();
    }
    
}