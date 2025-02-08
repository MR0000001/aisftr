/**
* @author Riccardo Cossu - riccardo.cossu@nttdata.com
* @description Test Class for XC_UTIL_Flow
*/ 

@isTest
private class XC_UTIL_Flow_TEST {
    @testSetup
    private static void setup() {
        insert new B2WZC__Bit2WinConnector__c(Name='ZuoraConnector',B2WZC__isActiveConnector__c=true);
        
        /* This method creates and inserts too the order */
       /* NE__Order__c order = XC_DF_Order.createOrder('InOrder');
        System.debug(order.NE__Order_Items__r);*/
        List<NE__OrderItem__c> orderItemList = XC_DF_OrderItem.createOrderItems(3);
        insert orderItemList;
        
		List<NE__OrderItem__c> itemList = [SELECT Id, XC_ZQuoteID__c, NE__ProdId__c FROM NE__OrderItem__c LIMIT 1];
        List<NE__Product__c> listProducts = XC_DF_Product.createProducts(1);
        listProducts[0].Name = 'Domestic Offer';
        listProducts[0].XC_Product_Type__c = 'Service';
        listProducts[0].XC_Product_SubType__c = 'Electric';
        insert listProducts;
        
        List<XC_Voucher__c> listVoucher = XC_DF_Voucher.generatePromotionalVoucher(1);
        listVoucher[0].XC_CostCenter__c = 'COSTCent';
        listVoucher[0].XC_CompanyCode__c = 'COMPCode';
        insert listVoucher;
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        
        List<Asset> listAsset = XC_DF_Asset.createAssets(accList);
        insert listAsset;
        String orderItemId = itemList[0].Id;
        XC_Provisioning_Step__c ps = XC_DF_ProvisioningStep.createProvisioningStep(orderItemId);
        insert ps;
    }
    
    
    static testMethod void flowTest(){
        Test.startTest();   
        XC_Provisioning_Step__c ps = [SELECT ID FROM XC_Provisioning_Step__c];
        XC_UTIL_flow.InputWrapper iW = new XC_UTIL_Flow.InputWrapper();
        iW.stepsToEnqueueId = ps.Id;
        iW.stepToExecuteId = String.valueOf(ps.Id);
        List<XC_UTIL_flow.InputWrapper> iWL = new List<XC_UTIL_flow.InputWrapper>();
        iWL.add(iW);
        List<XC_Provisioning_Step__c> psList = [SELECT ID FROM XC_Provisioning_Step__c];
        
        XC_UTIL_Flow.launchFlowBulkMode('flowName', psList);
        XC_UTIL_Flow.launchFlowSingleMode('flowName', ps);
        XC_UTIL_Flow.executeFlowAndEnqueueSteps(iWL);
        
        System.assert(!psList.isEmpty());
        System.assert(ps != null);
        System.assert(!iWl.isEmpty());
        
        Test.stopTest();
    }
}