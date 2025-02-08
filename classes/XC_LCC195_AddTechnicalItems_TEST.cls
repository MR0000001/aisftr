/**
* @author dpalamides
* @date 14/10/2020
* @description: classes.XC_LCC195_AddTechnicalItems_TEST
*/

@IsTest
public without sharing class XC_LCC195_AddTechnicalItems_TEST {
    @TestSetup
    static void setup(){
    NE__Order__c o = XC_DF_Order.createOrder('test');
        NE__OrderItem__c orderItem = new NE__OrderItem__c(NE__OrderId__c = o.Id, NE__Qty__c = 5, XC_LegalEntity__c = 'EnelXItalia');
        insert orderItem;
    
        WorkOrder wo = new WorkOrder(XC_Configuration__c= o.Id);
        insert wo;
   //     wo.XC_Configuration_Item__c = orderItem.Id;
  //      update wo;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.Status='New';
        woli.WorkOrderId = wo.Id;
        woli.XC_Form_Type__c = 'RMA';
        insert woli;
        
          
    }

    static testMethod void testWrappers(){
		Test.startTest();
        XC_LCC195_AddTechnicalItems.ListaParamWrapper wr1 = new XC_LCC195_AddTechnicalItems.ListaParamWrapper();
        wr1.contractId = null;
        wr1.country = null;
        wr1.name = null;
        wr1.typeName = null;
        wr1.sapCode = null;
        wr1.positionName = null;
        wr1.flagApplyFilter = null;
        wr1.pageSize = null;
        wr1.pageNumber = null;
        wr1.iPricebookId = null;
        wr1.mapManualPrice = null;
        wr1.ordItem = null;
        wr1.item = null;
        wr1.productMP = null;
        wr1.woliId = null;
        wr1.workOrderId = null;
        wr1.wbeElement = null;
        wr1.costCenter = null;
        wr1.orderItemId = null;
        wr1.woliCountry = null;
        wr1.rows = null;
        wr1.contestCI = null;
        wr1.productCode = null;
        wr1.rtWoli = null;
        wr1.partnerContract = null;
        wr1.legalEntity = null;
        wr1.productCategory = null;
        wr1.segment = null;
        wr1.warehouse = null;
        wr1.searchFilters = null;
        wr1.searchMaterial = false;
        wr1.searchService = false;

        XC_LCC195_AddTechnicalItems.WrapperCallMethod wr2 = new XC_LCC195_AddTechnicalItems.WrapperCallMethod();
        wr2.ordItem = null;
        wr2.parseJsonMP = null;
        wr2.tmpCatItem = null;
        wr2.productsMap = null;
        wr2.selectedProduct = null;
        
        XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper wr3 = new XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper();
        wr3.id               = null;
        wr3.idProduct        = null;
        wr3.idGlProduct      = null;
        wr3.glBookEntryId    = null;
        wr3.workOrderId      = null;
        wr3.name             = null;
        wr3.productCode      = null;
        wr3.type             = null;
        wr3.prodPrice        = null;
        wr3.isoCode          = null;
        wr3.contractId       = null;
        wr3.country          = null;
        wr3.quantity         = null;
        wr3.rtWoli           = null;
        wr3.segment          = null;
        wr3.legalEntity      = null;
        wr3.positionName     = null;
        wr3.positionCode     = null;
    }
    
    static testMethod void test1(){
		Test.startTest();
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
        
        XC_LCC195_AddTechnicalItems.getLimitedProduct2(JSON.serialize(wr1));
        wr1.country = 'Italy';
        XC_LCC195_AddTechnicalItems.searchOnProduct2(JSON.serialize(wr1));
        
    wr1.orderItemId = null;
        wr1.woliId = inputWoli.values()[0].Id;
        
        XC_LCC195_AddTechnicalItems.getLimitedProduct2(JSON.serialize(wr1));
        XC_LCC195_AddTechnicalItems.getOrderItemFromWoli(String.valueOf(inputWoli.values()[0].Id));
     
    }
    
    @isTest
    static void generateTechnicalItemsTest(){
        Test.startTest();
        List<NE__OrderItem__c> itemList = [SELECT id, NE__Parent_Order_Item__r.XC_Wbe__c, NE__Parent_Order_Item__c, NE__Qty__c, NE__CatalogItem__c, XC_Product_Subtype__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c Limit 1];
        
        Map<Id,WorkOrderLineItem> inputWoli = new Map<Id,WorkOrderLineItem>([
                    SELECT  Id, XC_PositionCode__c
                      FROM WorkOrderLineItem
                      LIMIT 1
            ]);
        List<WorkOrder> wo = [SELECT ID FROM WorkOrder LIMIT 1];
        XC_LCC195_AddTechnicalItems.ListaParamWrapper wr1 = new XC_LCC195_AddTechnicalItems.ListaParamWrapper();
        wr1.pageSize    = '1';
    wr1.pageNumber  = '1';
    wr1.orderItemId = itemList[0].Id;
        wr1.ordItem = itemList[0];
        wr1.workOrderId = wo[0].Id;
        wr1.mapManualPrice = '[{"Quantity":"2","glBookEntryId":"a7G0D0000008vIhUAI"},{"Quantity":"3","glBookEntryId":"a7G0D0000008vIqUAI"}]';
        
        wr1.legalEntity = 'EnelXItalia';
        wr1.segment = 'B2B';
        wr1.woliId = inputWoli.values()[0].Id;
        
        wr1.rtWoli = 'XC_B2B_EnelXItalia_ReturnMaterial';
        
        XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper wr3 = new XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper();
        wr3.quantity = '50' ;
        List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> wr3List = new List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>{wr3};
        wr1.rtWoli = 'XC_B2B_EnelXItalia_Delivery';  
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.rtWoli = 'XC_B2B_EnelXItalia_PE_WOLI';
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.rtWoli = 'XC_B2B_EnelXItalia_PartnerPayment';
        inputWoli.values()[0].XC_PositionCode__c = 'Test' ;
        update inputWoli.values()[0] ;
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        inputWoli.values()[0].XC_PositionCode__c = null ;
        update inputWoli.values()[0] ;
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.contestCI = 'true';
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        
        
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Spain',
            XC_ProductSubType__c = 'Enel Spare Part'
        );
        insert p2;
        XC_UTIL_GenerateItemFromTechCart.loadMap (new List<Object>{p2.Id},p2.Id);
        XC_UTIL_GenerateItemFromTechCart.setCartManualValue ('12');
        XC_UTIL_GenerateItemFromTechCart.getListCommercialOrderItem(wr1.woliId);
        XC_UTIL_GenerateItemFromTechCart.loadWrapperClass (new List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>(),new List<Product2>{p2}, null);
        Test.stopTest();
    }
    
    @isTest
    static void generateTechnicalItems2Test(){
	Test.startTest();
        List<NE__OrderItem__c> itemList = [SELECT id, NE__Parent_Order_Item__r.XC_Wbe__c, NE__Parent_Order_Item__c, NE__Qty__c, NE__CatalogItem__c, XC_Product_Subtype__c, NE__CatalogItem__r.XC_ProductLine__c,NE__CatalogItem__r.XC_ProductServiceType__c,  NE__OrderId__r.NE__OptyId__r.XC_LegalEntity__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessModel__c , XC_Wbe__c, NE__OrderId__r.NE__OptyId__r.XC_SalesChannel__c,  NE__OrderId__c from NE__OrderItem__c Limit 1];
        
        Map<Id,WorkOrderLineItem> inputWoli = new Map<Id,WorkOrderLineItem>([
                    SELECT  Id, XC_PositionCode__c
                      FROM WorkOrderLineItem
                      LIMIT 1
            ]);
        List<WorkOrder> wo = [SELECT ID FROM WorkOrder LIMIT 1];
        XC_LCC195_AddTechnicalItems.ListaParamWrapper wr1 = new XC_LCC195_AddTechnicalItems.ListaParamWrapper();
        wr1.pageSize    = '1';
    wr1.pageNumber  = '1';
    wr1.orderItemId = itemList[0].Id;
        wr1.ordItem = itemList[0];
        wr1.workOrderId = wo[0].Id;
        wr1.mapManualPrice = '[{"Quantity":"2","glBookEntryId":"a7G0D0000008vIhUAI"},{"Quantity":"3","glBookEntryId":"a7G0D0000008vIqUAI"}]';
        
        wr1.legalEntity = 'EnelXItalia';
        wr1.segment = 'B2B';
        wr1.woliId = inputWoli.values()[0].Id;
        
        wr1.rtWoli = 'XC_B2B_EnelXItalia_ReturnMaterial';
        
        XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper wr3 = new XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper();
        wr3.quantity = '50' ;
        List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> wr3List = new List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>{wr3};
        wr1.rtWoli = 'XC_B2B_EnelXItalia_ReturnMaterial';  
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.rtWoli = 'XC_B2B_EnelXItalia_ReturnMaterial';
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.rtWoli = 'XC_B2B_EnelXItalia_ReturnMaterial';
        inputWoli.values()[0].XC_PositionCode__c = null ;
        update inputWoli.values()[0] ;
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.contestCI = 'true';
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        
        
        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Spain',
            XC_ProductSubType__c = 'Enel Spare Part'
        );
        insert p2;
        XC_UTIL_GenerateItemFromTechCart.loadMap (new List<Object>{p2.Id},p2.Id);
        XC_UTIL_GenerateItemFromTechCart.setCartManualValue ('12');
        XC_UTIL_GenerateItemFromTechCart.getListCommercialOrderItem(wr1.woliId);
        XC_UTIL_GenerateItemFromTechCart.loadWrapperClass (new List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>(),new List<Product2>{p2}, null);
        Test.stopTest();
    }
    
    static testMethod void  testGenerateTechnicalItems(){
		Test.startTest();
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
        wr1.mapManualPrice = '[{"Quantity":"2","glBookEntryId":"a7G0D0000008vIhUAI"},{"Quantity":"3","glBookEntryId":"a7G0D0000008vIqUAI"}]';
        
        wr1.legalEntity = 'EnelXItalia';
        wr1.segment = 'B2B';
        wr1.woliId = inputWoli.values()[0].Id;
        
        wr1.rtWoli = 'XC_B2B_EnelXItalia_ReturnMaterial';
        
        XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper wr3 = new XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper();
        wr3.quantity = '50' ;
        List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> wr3List = new List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>{wr3};
        wr1.rtWoli = 'XC_B2B_EnelXItalia_Delivery';  
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.rtWoli = 'XC_B2B_EnelXItalia_PE_WOLI';
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.rtWoli = 'XC_B2B_EnelXItalia_PartnerPayment';
        //inputWoli.values()[0].XC_PositionCode__c = 'Test' ;
        update inputWoli.values()[0] ;
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        //inputWoli.values()[0].XC_PositionCode__c = null ;
        update inputWoli.values()[0] ;
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.contestCI = 'true';
        XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        wr1.rtWoli = 'XC_B2B_EnelXItalia_ReturnMaterial';
		XC_LCC195_AddTechnicalItems.generateTechnicalItems(JSON.serialize(wr1),wr3List,null);
        

        Product2 p2 = new Product2(
            isActive = true,
            Name = 'Test',
            ProductCode = 'Test',
            XC_Country__c = 'Spain',
            XC_ProductSubType__c = 'Enel Spare Part'
        );
        insert p2;
        XC_UTIL_GenerateItemFromTechCart.loadMap (new List<Object>{p2.Id},p2.Id);
        XC_UTIL_GenerateItemFromTechCart.setCartManualValue ('12');
        XC_UTIL_GenerateItemFromTechCart.getListCommercialOrderItem(wr1.woliId);
        XC_UTIL_GenerateItemFromTechCart.loadWrapperClass (new List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>(),new List<Product2>{p2}, null);
        Test.stopTest();
    }
     @isTest
    static void uploadCSVFileTest(){
        Test.startTest();
        String orderId = [SELECT Id FROM NE__OrderItem__c LIMIT 1].Id;
            XC_LCC195_AddTechnicalItems.uploadCSVFile(true,orderId,orderId);
        Test.stopTest();
    }
    @isTest
    static void uploadCSVFileTest1(){
        Test.startTest();
        String workOrderId = [SELECT Id FROM WorkOrderLineItem LIMIT 1].Id;
            XC_LCC195_AddTechnicalItems.uploadCSVFile(false,workOrderId,workOrderId);
        Test.stopTest();
    }
    
    @isTest
    static void checkConfItemTest(){
        Test.startTest();
        String orderId = [SELECT Id FROM NE__OrderItem__c LIMIT 1].Id;
            XC_LCC195_AddTechnicalItems.checkConfItem(orderId);
        Test.stopTest();
    }
    @isTest
    static void checkFromCommunityTest(){
        Test.startTest();
            XC_LCC195_AddTechnicalItems.checkFromCommunity();
        Test.stopTest();
    }
    
    @isTest
    static void saveCsvFileTest(){
        Test.startTest();
        Giic_UtilityClass_Test.systemPolicyCreation();
        Giic_UtilityClass_Test.gloviaSystemSettingCreation();
        Giic_UtilityClass_Test.accountCreation();
        Giic_UtilityClass_Test.productCreation();
        gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c,giic_LegalEntity__c,giic_Available_for_Sales__c,giic_AveragePrice__c from gii__Product2Add__c where gii__ProductReference__c IN: Giic_UtilityClass_Test.lstProd Limit 1];
        objProdRef.giic_Available_for_Sales__c = TRUE ;
        objProdRef.giic_LegalEntity__c = 'EnelXItalia' ;
        objProdRef.giic_AveragePrice__c = 5.0 ;
        update objProdRef ;
        
        NE__OrderItem__c orditem = [SELECT Id, NE__OrderId__c, XC_WBE__c, NE__Account__c, NE__One_Time_Cost__c FROM NE__OrderItem__c LIMIT 1];
        String orderId = orditem.id ;
    //    gii__Product2Add__c objProdRef= [Select id,gii__ProductCode__c,giic_SAPtype__c,giic_LegalEntity__c,giic_Available_for_Sales__c from gii__Product2Add__c Limit 1];
   //     objProdRef.giic_LegalEntity__c = 'EnelXItalia' ;
   //     update objProdRef ;
        String c = [SELECT Id from Contract Limit 1].Id;
        
        List<String> ProductCodeList = new List<String>();
        ProductCodeList.add(objProdRef.gii__ProductCode__c);
        List<String> QuantityList = new List<String>();
        QuantityList.add('1');
        List<String> ServicePositionList = new List<String>();
        ServicePositionList.add('test');
        List<String> csvRowValues = new List<String>();
        for(Integer i = 0; i < ProductCodeList.size() ; i++){
        String rowStr = ProductCodeList[i] + ',' + QuantityList[i] + ',' + ServicePositionList[i] ;
        csvRowValues.add(rowStr);
    }     
        String csvColumnHeader = 'ProductCode,Quantity,Service Position\n';
        String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
        System.debug(csvFile) ;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.csv';
        cv.VersionData = Blob.valueOf(csvFile);
        cv.IsMajorVersion = true;
        Insert cv;
        
        NE__Catalog_Item__c neCat =  new NE__Catalog_Item__c() ;
        Map<String, gii__PriceBookEntry__c> PriceBookEntryMap = new Map<String, gii__PriceBookEntry__c>();
        
        //ContentVersion contentVersionObj = [ SELECT Id, VersionData FROM ContentVersion ];
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        try {
             XC_LCC195_AddTechnicalItems.saveCsvFile(conDocId,true,orderId,orderId);
             XC_LCC195_AddTechnicalItems.addTechItem(objProdRef,'1',orditem,neCat,PriceBookEntryMap,objProdRef.id);
        }
        catch(exception e){
            
        } 
        Test.stopTest();
    }

    
    @isTest
    static void getCondLikeTest(){
        Test.startTest();
            XC_LCC195_AddTechnicalItems.getCondLike('Test1','Test2','Test3');
        Test.stopTest();
    }
    
}