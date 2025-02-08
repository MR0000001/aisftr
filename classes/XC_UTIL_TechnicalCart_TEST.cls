/**
* @author dpalamides
* @date 14/10/2020
* @description: classes.XC_LCC195_AddTechnicalItems_TEST
*/

@IsTest
public class XC_UTIL_TechnicalCart_TEST {
@TestSetup
    static void setup(){
		NE__Order__c o = XC_DF_Order.createOrder('test');
        List<NE__OrderItem__c> itemList = [SELECT id from NE__OrderItem__c Limit 1];
    
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        WorkOrder wo = new WorkOrder();
        wo.XC_Configuration__c= o.Id;
        wo.XC_Configuration_Item__c = itemList[0].Id;
        
        List<Account> accList = XC_DF_Account.insertPartnerAccounts(1);
        wo.XC_PreferredPartner__c = accList[0].Id;
        insert wo;
        woli.WorkOrderId = wo.Id;
        insert woli;
       
     
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.wareHouseGroupCreation();
        Giic_UtilityClass_Test.warehouseCreation();
        Giic_UtilityClass_Test.locationCreation();
        Giic_UtilityClass_Test.contractCreation();
        Giic_UtilityClass_Test.productCreation(); 
        Giic_UtilityClass_Test.priceBookCreation();
        gii__Product2Add__c pref=new gii__Product2Add__c();
        pref=[Select Id,gii__PrimarySupplier__c from gii__Product2Add__c where gii__ProductReference__c=:giic_UtilityClass_Test.objProductTL.Id];
        pref.gii__PrimarySupplier__c=Giic_UtilityClass_Test.objAccountSupplier.Id;
        update pref;

               XC_UTIL_TechnicalCart.WrapperGetSet wr1a = new XC_UTIL_TechnicalCart.WrapperGetSet();
        wr1a.sapTypeMaterial = 'a';
        wr1a.sapTypeService = 'b';
        XC_UTIL_DEBUG.debug(true, wr1a);
    }

    
    static testMethod void test1(){
 
        
        Test.setMock(HttpCalloutMock.class, new XC_UTIL_FSLLogistic_Mock());

        List<NE__OrderItem__c> itemList = [SELECT id, NE__Parent_Order_Item__r.XC_Wbe__c, NE__Parent_Order_Item__c, NE__Qty__c, NE__CatalogItem__c, XC_Product_Subtype__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c Limit 1];
        
        Map<Id,WorkOrderLineItem> inputWoli = new Map<Id,WorkOrderLineItem>([
                    SELECT  Id
                      FROM WorkOrderLineItem
                      LIMIT 1
            ]);
        
        XC_LCC195_AddTechnicalItems.ListaParamWrapper wr1 = new XC_LCC195_AddTechnicalItems.ListaParamWrapper();
        wr1.pageSize    = '1';
		wr1.pageNumber  = '1';
		wr1.orderItemId = itemList[0].Id;
        wr1.searchMaterial=true;
        wr1.searchService=true;
        XC_UTIL_TechnicalCart.loadProductFromGlovia(wr1);
        wr1.country = 'Italy';
        XC_UTIL_TechnicalCart.loadProductFromGlovia(wr1);
        
		wr1.orderItemId = null;
        wr1.woliId = inputWoli.values()[0].Id;
        wr1.searchFilters = new List<String>{'XXX','XXX','XXX','XXX','XXX'};
        XC_UTIL_FSLLogistic.GloviaProduct glProd1 = new XC_UTIL_FSLLogistic.GloviaProduct();  
        XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper wr4 = new XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper();
        wr4 = XC_UTIL_TechnicalCart.populateProduct2Wrapper(glProd1,'Material');
        wr4.glBookEntryId    = null;
        wr4.prodPrice        = null;
        wr4.isoCode          = null;
        XC_UTIL_TechnicalCart.loadProductFromGlovia(wr1);
        XC_UTIL_TechnicalCart.setCartManualValue('10');
        
     
    }
    
     static testMethod void test2(){
        Test.setMock(HttpCalloutMock.class, new XC_UTIL_FSLLogistic_Mock());

        List<NE__OrderItem__c> itemList = [SELECT id, NE__Parent_Order_Item__r.XC_Wbe__c, NE__Parent_Order_Item__c, NE__Qty__c, NE__CatalogItem__c, XC_Product_Subtype__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c Limit 1];
        
        Map<Id,WorkOrderLineItem> inputWoli = new Map<Id,WorkOrderLineItem>([
                    SELECT  Id
                      FROM WorkOrderLineItem
                      LIMIT 1
            ]);
        
        XC_LCC195_AddTechnicalItems.ListaParamWrapper inputParams = new XC_LCC195_AddTechnicalItems.ListaParamWrapper();
        inputParams.pageSize    = '1';
		inputParams.pageNumber  = '1';
		inputParams.orderItemId = itemList[0].Id;
        inputParams.country = 'Italy';
        inputParams.searchMaterial=true;
        inputParams.searchService=true;
		inputParams.orderItemId = null;
        inputParams.woliId = inputWoli.values()[0].Id;
        inputParams.searchFilters = new List<String>{'XXX','XXX','XXX','XXX','XXX'};
        
        XC_UTIL_FSLLogistic.InputSelfCallout wrapper = new XC_UTIL_FSLLogistic.InputSelfCallout();
        wrapper.recordID = inputParams.partnerContract; //iPricebookId;
        wrapper.legalEntity = inputParams.legalEntity;
        wrapper.productCategory = inputParams.productCategory;
        wrapper.warehouse = inputParams.warehouse;
        wrapper.woliRT = inputParams.rtWoli;
        if(inputParams.searchMaterial){
            wrapper.sapTypeFilters.add('Material');
        }
        if(inputParams.searchService){
            wrapper.sapTypeFilters.add('Service');
        }
        if(inputParams.searchFilters!=null && !inputParams.searchFilters.isEmpty() ){
            wrapper.searchFilters = new Map<String,String>();

            wrapper.searchFilters.put('name',inputParams.searchFilters[0]);
            wrapper.searchFilters.put('typeName',inputParams.searchFilters[1]);
            wrapper.searchFilters.put('sapCode',inputParams.searchFilters[2]);
            wrapper.searchFilters.put('positionName',inputParams.searchFilters[3]);
            wrapper.searchFilters.put('flagApplyFilter',inputParams.searchFilters[4]);

        }
        wrapper.operation = 'getGloviaProductMapping';
         
         gii__Product2Add__c prod2add = [select id, giic_LegalEntity__c from gii__Product2Add__c limit 1];
         wrapper.legalEntity = prod2add.giic_LegalEntity__c;//'EnelXItalia';
        XC_UTIL_TechnicalCart.retrieveProductFromGlovia(wrapper);
     
    }
    
    static testMethod void test3(){
       Test.setMock(HttpCalloutMock.class, new XC_UTIL_FSLLogistic_Mock());
        Test.startTest();
        List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference> inputParams = new List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference>();
        XC_UTIL_FSLLogistic.ParamGetGloviaProductReference pr = new XC_UTIL_FSLLogistic.ParamGetGloviaProductReference();
        inputParams.add(pr);
        XC_UTIL_TechnicalCart.loadProductReferenceFromGlovia(inputParams);
        XC_UTIL_TechnicalCart.createSalesOrdersGlovia (new XC_UTIL_TechnicalCart.paramToGloviaSO(), new List<ProductRequired>(), new List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference>());
        XC_UTIL_TechnicalCart.setSendGlovia(new List<XC_UTIL_TechnicalCart.paramToGloviaSoli>(),new List<ProductRequired>{new ProductRequired()},new List<XC_UTIL_FSLLogistic.ParamGetGloviaProductReference>());
        
        XC_UTIL_TechnicalCart.paramToGloviaSoli soli = new XC_UTIL_TechnicalCart.paramToGloviaSoli();
        soli.quantity = '10';
        soli.unitPrice = '10';
        
        XC_UTIL_TechnicalCart.paramToGloviaSO so = new XC_UTIL_TechnicalCart.paramToGloviaSO();
    	so.AccountId = '';
        so.isDelivery = false;
        RecordType rt = [SELECT Id,name,developerName FROM RecordType WHERE sObjectType = 'Account' and name = 'Partner' LIMIT 1];
        gii__Warehouse__c wh = [select gii__Account__c from gii__Warehouse__c limit 1];
        account acc = [select id from account where id = :wh.gii__Account__c ];
        acc.RecordTypeId=rt.Id;
        update acc;
        WorkOrder wo = [select id from WorkOrder limit 1];
        wo.XC_PreferredPartner__c = wh.gii__Account__c;
        update wo;  
        Map<Id,WorkOrderLineItem> inputWoli = new Map<Id,WorkOrderLineItem>([
                    SELECT  Id
                      FROM WorkOrderLineItem
                      LIMIT 1
            ]);
        Map<Id,WorkOrder> inputWo = new Map<Id,WorkOrder>([
                    SELECT  Id,PostalCode,Country,XC_FSLAssignmentKey__c,XC_LegalEntity__c,XC_Segment__c
                      FROM WorkOrder
                      LIMIT 1
            ]);
        
        ProductRequired pr1 = new ProductRequired();
        pr1.XC_WorkOrderLineItem__r = inputWoli.values()[0];
        pr1.XC_WorkOrderLineItem__r.WorkOrder = inputWo.values()[0];
        pr1.XC_WorkOrderLineItem__r.WorkOrder.XC_Address__r = new XC_Address__c();
        pr1.XC_WorkOrderLineItem__r.WorkOrder.XC_FSLAssignmentKey__c = 'Roma';
        pr1.XC_WorkOrderLineItem__r.WorkOrder.XC_LegalEntity__c = 'EnelXItalia';
        pr1.XC_WorkOrderLineItem__r.WorkOrder.XC_Segment__c = 'B2B';
        XC_UTIL_TechnicalCart.createSOSOLIGlovia(new List<XC_UTIL_TechnicalCart.paramToGloviaSoli>{soli},new XC_UTIL_TechnicalCart.paramToGloviaSO(), new List<ProductRequired>{pr1});
    	XC_UTIL_TechnicalCart.createSOSOLIGlovia(new List<XC_UTIL_TechnicalCart.paramToGloviaSoli>{soli},so, new List<ProductRequired>{pr1});
        XC_UTIL_TechnicalCart.getVirtualWarehousesMap(new List<String>{'EnelXItalia'});
        Test.stopTest();
    }
    
    static testMethod void  testGenerateTechnicalItems(){
        Test.setMock(HttpCalloutMock.class, new XC_UTIL_FSLLogistic_Mock());

        List<NE__OrderItem__c> itemList = [SELECT id, NE__Parent_Order_Item__r.XC_Wbe__c, NE__Parent_Order_Item__c, NE__Qty__c, NE__CatalogItem__c, XC_Product_Subtype__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c Limit 1];
        
        Map<Id,WorkOrderLineItem> inputWoli = new Map<Id,WorkOrderLineItem>([
                    SELECT  Id
                      FROM WorkOrderLineItem
                      LIMIT 1
            ]);
        
        XC_LCC195_AddTechnicalItems.ListaParamWrapper wr1 = new XC_LCC195_AddTechnicalItems.ListaParamWrapper();
        wr1.pageSize    = '1';
		wr1.pageNumber  = '1';
		wr1.orderItemId = itemList[0].Id;
        wr1.ordItem = itemList[0];
        wr1.mapManualPrice = '"[]"';
        wr1.pageNumber  = '1';
        
        XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper wr3 = new XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper();
        List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> wr3List = new List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>{wr3};
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.mapManualPrice = '"[{"Quantity":"4","glBookEntryId":"a7C0D0000004eLEUAY"}]"';
        wr1.rtWoli = 'XC_B2B_EnelXItalia_PE_WOLI';
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.contestCI = 'true';
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        gii__PriceBookEntry__c gg = new gii__PriceBookEntry__c();
        XC_UTIL_TechnicalCart.populateGloviaPricebookEntry(gg);
        XC_UTIL_FSLLogistic.GloviaProduct glProd = new XC_UTIL_FSLLogistic.GloviaProduct();

        XC_UTIL_TechnicalCart.populateProduct2Wrapper(glProd,'test');
        XC_UTIL_TechnicalCart.coverage();
        XC_UTIL_TechnicalCart.checkGloivia(false);
        XC_UTIL_TechnicalCart.checkGloivia(true);
        

    }

    static testMethod void updateProductRequired(){
        //create product required
        Test.startTest();
        product2 product=new product2(Name = 'New Tube updateProductRequired',ProductCode = 'updateProductRequired', CurrencyIsoCode='EUR',XC_CompanyCode__c='ES21',giic_LegalEntity__c='EndesaX'); 
        insert product;
        List<product2> lstProduct = [select id from product2];
        List<WorkOrder> woList = XC_DF_WorkOrder.createWorkOrders(5, 'Commercial Visit');      
        insert woList;

        List<ProductRequired> productsRequired = new List<ProductRequired>();
        for (Integer i = 0; i < 5; i++){
            ProductRequired pr = new ProductRequired();
            pr.ParentRecordId= woList[i].Id;
            pr.Product2Id = lstProduct[0].Id;
            productsRequired.add(pr);
        }       
        insert productsRequired;

        WorkOrder wo = [SELECT Id, XC_Address__c, XC_Address__r.XC_Account__c FROM WorkOrder WHERE Id =: woList.get(0).Id LIMIT 1];
        //Create product wrapper
        productsRequired  = [ SELECT Id, Reserved_Quantity__c, Purchased_Quantity__c, Purchase_Order_Status__c FROM ProductRequired];
        List<Giic_CommonWrapper.ProductWrapper> productsWrapper = new List<Giic_CommonWrapper.ProductWrapper>();
        for(ProductRequired pr: productsRequired){
            Giic_CommonWrapper.ProductWrapper pw = new Giic_CommonWrapper.ProductWrapper();
            pw.productId = pr.Id;
            pw.reservedQty = Integer.valueof((Math.random() * 10));
            pw.purchasedQty = Integer.valueof((Math.random() * 10));
            pw.purchaseOrderStatus = 'Start';
            pw.purchaseOrderNumber = '';
            pw.warehouseAccountId = wo.XC_Address__r.XC_Account__c;//'';
            productsWrapper.add(pw);
        }

        XC_UTIL_TechnicalCart.updateProductRequired(productsWrapper);

        Map<Id,ProductRequired> productsRequiredUpdated = new Map<Id,ProductRequired>([ SELECT Id, Reserved_Quantity__c, Purchased_Quantity__c, Purchase_Order_Status__c,XC_PurchaseOrderNumber__c,XC_LastGoodsReceiptNumber__c,XC_CompanyOrderReceipt__c,XC_WarehouseAccountId__c FROM ProductRequired]);
        Test.stopTest();
        
        For(Giic_CommonWrapper.ProductWrapper pw : productsWrapper){
            ProductRequired pr = productsRequiredUpdated.get(pw.productId);
            System.assertEquals(pw.reservedQty,pr.Reserved_Quantity__c,'Wrong reserved quantity');
            System.assertEquals(pw.purchasedQty,pr.Purchased_Quantity__c, 'Wrong purchased quantity');
            System.assertEquals(pw.purchaseOrderStatus, pr.Purchase_Order_Status__c, 'Wrong purchase order status');
        }
    }
}