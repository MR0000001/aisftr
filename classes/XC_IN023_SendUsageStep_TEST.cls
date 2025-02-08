/**
* @author Federico Amici - federico.amici@nttdata.com
* @description Test of the invocable class that send usage
*/
@isTest
public with sharing class XC_IN023_SendUsageStep_TEST {
    
    @testSetup
    private static void setup() {

        /* This method creates and inserts too the order */
        NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);

        order = [SELECT Id,  NE__AccountID__c, (SELECT Id, NE__ProdName__c FROM NE__Order_Items__r) FROM NE__Order__c WHERE Id = :order.Id];
        B2WExtCat__Work_Order_Item__c workOrderItem = XC_DF_RatePlan.createJunctionProductRatePlanToItem(order, order.NE__Order_Items__r[0]);
        insert workOrderItem;

        NE__Order__c orderDB = [SELECT ID, XC_Cost_Center__c, XC_Company_Code__c
                                FROM NE__Order__c
                                WHERE Id =:order.Id];
        orderDB.XC_Cost_Center__c = 'COSTCent';
        orderDB.XC_Company_Code__c = 'COMPCode';
        update orderDB;

        zqu__BillingEntity__c billingEntity = new zqu__BillingEntity__c();
        billingEntity.zqu__EntityID__c = '8adc8f99684b618601684d4127781f61';
        billingEntity.zqu__ParentEntityID__c = '8adce42163001e6e0163177b4f5f50c4';
        billingEntity.zqu__ZuoraID__c = '2000378';
        billingEntity.zqu__EntityName__c = 'Enel Spain B2C';
        insert billingEntity;

        B2WZC__Bit2WinConnector__c b2wConnector = new B2WZC__Bit2WinConnector__c(Name = 'ZuoraConnector', B2WZC__isActiveConnector__c = true);
        insert b2wConnector;
        
        XC_DF_DataMap.createDataMap('Order2Zquote', billingEntity);

        NE__OrderItem__c item = [SELECT Id, XC_ZQuoteID__c, NE__ProdId__c, NE__OneTimeFeeOv__c FROM NE__OrderItem__c WHERE ID = :order.NE__Order_Items__r[0].Id];
        item.NE__OneTimeFeeOv__c     = 83.89;
        NE.DataMap.DataMapResponse dResp = b2wzc.Bit2Win_OrderConnector.createZquoteFromDatamap('Order2Zquote', orderDB.Id);
        item.XC_ZQuoteId__c = dResp.parentId;
        update item;

        List<Account> accList = [SELECT Id FROM Account WHERE Id = :order.NE__AccountId__c];

        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        listAsset[0].XC_Configuration_Item__c = item.Id;
        listAsset[0].XC_CostCenter__c = 'COSTCent';
        listAsset[0].XC_CompanyCode__c = 'COMPCode';

        insert listAsset;

        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(String.valueof(order.NE__Order_Items__r[0].Id));
        insert ps;
    }

    @isTest
    private static void stepSendUsageTEST() {
        XC_Provisioning_Step__c ps = [SELECT Id, XC_Configuration_Item__c, XC_Configuration_Item__r.NE__OrderId__c 
                                      FROM XC_Provisioning_Step__c
                                      LIMIT 1];

        List<XC_IN023_SendUsageStep.InputWrapper> listInputWrapper = generateInputWrapper(ps);

        Test.startTest();+
            XC_IN023_SendUsageStep.stepSendUsage(listInputWrapper);
        Test.stopTest();

        Integer numberOfQuote = [SELECT COUNT() FROM zqu__Quote__c LIMIT 1];
        System.assert(numberOfQuote == 1);
    }

    private static List<XC_IN023_SendUsageStep.InputWrapper> generateInputWrapper(XC_Provisioning_Step__c ps) {

        List<XC_IN023_SendUsageStep.InputWrapper> listWrapperInput = new List<XC_IN023_SendUsageStep.InputWrapper>();
        XC_IN023_SendUsageStep.InputWrapper wr = new XC_IN023_SendUsageStep.InputWrapper();
        wr.stepId = ps.Id;
        listWrapperInput.add(wr);

        return listWrapperInput;

    }
}