/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 16/05/2019
* @description XC_UTIL_WBE_TEST – Test class for XC_UTIL_WBE 
*/ 

@isTest
private class XC_UTIL_WBE_TEST {

    @isTest
    private static void onInsert() {
        //insert XC_DF_OneOrg.createOneOrg('Spain');

        NE__Order__c myOrder = XC_DF_Order.createOrder('InOrder');
        Opportunity myOpp = XC_DF_Opportunity.createOpportunity(1, false)[0];
        //insert myOpp;
        myOrder.NE__OptyId__c = myOpp.Id;
        update myOrder;
        NE__Catalog_Item__c catalogItem = XC_DF_CatalogItem.createCatalogItem();
        NE__OrderItem__c orderItem = XC_DF_OrderItem.createOrderItem(myOrder);
        List<XC_Address__c> listAddr = XC_DF_Address.createAddress(1);
        //insert listAddr;
        orderItem.NE__Account__c = listAddr[0].XC_Account__c;
        orderItem.XC_Installation_Address__c = listAddr[0].Id;
        //insert orderItem;

        Test.startTest();

        XC_UTIL_WBE.WBEWrapper wbeWrapper = new XC_UTIL_WBE.WBEWrapper();
        wbeWrapper.digitFree = XC_UTIL_WBE.getDigitFree();
        wbeWrapper.capOpEx = XC_UTIL_WBE.getCAPExOpEx();
        wbeWrapper.projectScope = XC_UTIL_WBE.getProjectScope();
        wbeWrapper.ctaCts = XC_UTIL_WBE.getCtaCts(true, false)[0];
        wbeWrapper.ctaCts = XC_UTIL_WBE.getCtaCts(false, true)[0];
        wbeWrapper.ctaCts = XC_UTIL_WBE.getCtaCts(false, false)[0];
        wbeWrapper.companyCode = 'ES21';
        wbeWrapper.productLine = '0000';
        wbeWrapper.productServiceType = '000';
        wbeWrapper.businessModel = '0';
        wbeWrapper.channel = '0';

        List<NE__OrderItem__c> orderItems = XC_DF_OrderItem.createOrderItems(1);
        orderItems[0].NE__OrderId__c = myOrder.Id;
        orderItems[0].NE__Item_Code__c = 'AaAaAa';
        orderItems[0].NE__Account__c = listAddr[0].XC_Account__c;
        orderItems[0].XC_Installation_Address__c = listAddr[0].Id;
        
        //insert orderItems;

        XC_UTIL_WBE_U.getCodeFromCatalogItem(catalogItem.Id);
        XC_UTIL_WBE_U.getMapCompanyCode();
        XC_UTIL_WBE_U.getMapBusinessModel();
        XC_UTIL_WBE_U.getMapChannel();
        XC_UTIL_WBE.createWBE(wbeWrapper);

        XC_UTIL_WBE_U.recalculationWBE(wbeWrapper, orderItem, orderItems);

        String tempCtaCts = wbeWrapper.ctaCts;
        wbeWrapper.ctaCts = tempCtaCts + '1111111111111111111111111111111';

        XC_UTIL_WBE_U.recalculationWBE(wbeWrapper, orderItem, orderItems);

        wbeWrapper.ctaCts = tempCtaCts;

        orderItem.XC_WBE__c = XC_UTIL_WBE_U.recalculationWBE(wbeWrapper, orderItem, orderItems);

        XC_UTIL_WBE_U.getMapCompanyCode(orderItems, new Map<Id, NE__Order__c>{myOrder.Id => myOrder});
        XC_UTIL_WBE_U.getMapBusinessModel(orderItems, new Map<Id, NE__Order__c>{myOrder.Id => myOrder});
        XC_UTIL_WBE_U.getMapChannel(orderItems, new Map<Id, NE__Order__c>{myOrder.Id => myOrder});
        NE__Product__c myProd = new 	NE__Product__c(Name = 'Subvencion');

        //insert myProd;

        orderItem.NE__ProdId__c = myProd.Id;
        orderItem.XC_Product_Type__c = 'Billing';
        orderItem.XC_Product_Subtype__c = 'Promotion';
        orderItem.XC_RelatedProduct__c = 'AaAaAa';

        //update orderItem;

        XC_UTIL_WBE_U.recalculationWBE(wbeWrapper, orderItem, orderItems);

        String wbe = XC_UTIL_WBE.getWBE(wbeWrapper);
        Map<String, String> mapOrderItemLegalEntity = new Map<String, String>();
        Map<String, String> mapOrderItemWbe = new Map<String, String>();
        mapOrderItemLegalEntity.put(orderItem.Id, Label.XC_CL_EndesaX);
        mapOrderItemWbe.put(orderItem.Id, wbe);

        System.assertNotEquals(wbe, null);
		Test.stopTest();        
    }
    
}