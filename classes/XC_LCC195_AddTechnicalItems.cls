/**
* @author B2Win - 
* @date XCustomer Creation 23/06/2020 [Monica Cutillo - mcutillo@deloitte.it]
* @date Creation 22/06/2019
* @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
* @date Modification 07/2020 Monica Cutillo - mcutillo@deloitte.it
* @description Controller of Component XC_LCP195_AddTechnicalItems
*/
public  without sharing class XC_LCC195_AddTechnicalItems {
    
    /**
    * @author B2Win
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description // wrapper class with @AuraEnabled and {get;set;} properties 
    */
    public class ListaParamWrapper{
        /** @description The contract id. */
       public String contractId;
       /** @description The contract id. */
       public String country;
       /** @description The contract id. */
       public String name;
       /** @description The contract id. */
       public String typeName;
       /** @description The contract id. */
       public String sapCode;
       /** @description The contract id. */
       public String positionName;
       /** @description The contract id. */
       public Boolean flagApplyFilter;
          /** @description The contract id. */
       public String pageSize;
          /** @description The contract id. */
       public String pageNumber;
          /** @description The contract id. */
       public String iPricebookId;
          /** @description The contract id. */
       public String mapManualPrice;
        /** @description The contract id. */
       public NE__OrderItem__c ordItem;
      /** @description The contract id. */
       public NE__Catalog_Item__c tmpCatItem;
      /** @description The contract id. */
       public  Product2 item;
      /** @description The contract id. */
       public List<XC_JSON2Apex> productMP;
       /** @description The contract id. */
       public string woliId;
       /** @description The contract id. */
       public String workOrderId;
       /** @description The record id. */
       public string wbeElement;
       /** @description The contract id. */
       public string costCenter;
       /** @description The contract id. */
       public string orderItemId;
       /** @description The contract id. */
       public string woliCountry;
        /** @description The contract id. */
       public String rows;
         /** @description The contract id. */
       public string contestCI;
          /** @description The contract id. */
       public String productCode;
       /** @description The contract id. */
      public String rtWoli;
      /** @description The partnerContract id */
      public String partnerContract;
      /** @description The Legal Entity */
      public String legalEntity;
      /** @description The XC_ProductCategory__c */
      public String productCategory;
      /** @description The XC_ProductCategory__c */
      public String segment;
      public String warehouse;
      public List<String> searchFilters;

      /** @description searchMaterial flag */
      public Boolean searchMaterial = false;
      /** @description searchService flag */
      public Boolean searchService = false;
  
     }
  
     /**
      * @author B2Win - 
      * @date Creation 22/06/2019
      * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
      * @description // wrapper class with @AuraEnabled and {get;set;} properties 
      */
     public class WrapperCallMethod{
        /** @description The contract id. */
       public NE__OrderItem__c ordItem;
       /** @description The contract id. */
       public NE__Catalog_Item__c tmpCatItem;
       /** @description The contract id. */
       public Map<Id,Product2> productsMap;
       /** @description The contract id. */
       public List<XC_JSON2Apex> parseJsonMP;
       /** @description selected Product data */
       public List<Product2ContactLineItemWrapper> selectedProduct;
      
     }
           
    /**
      * @author B2Win - 
      * @date Creation 22/06/2019
      * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
      * @description // wrapper class with @AuraEnabled and {get;set;} properties 
      */
      public class Product2ContactLineItemWrapper{
          /** @description The record id. */
          @AuraEnabled
          public String id{get;set;}
          /** @description The Product2 id. */
          @AuraEnabled
          public String idProduct{get;set;}
          /** @description The GloviaProduct2 id. */
          @AuraEnabled
          public String idGlProduct{get;set;}
          /** @description The record id. */
          @AuraEnabled
          public String glBookEntryId{get;set;}
          /** @description The record id. */
          @AuraEnabled
          public String workOrderId{get;set;}
            /** @description The record id. */
          @AuraEnabled
          public String name{get;set;}
            /** @description The record id. */
          @AuraEnabled
          public String productCode{get;set;}
            /** @description The record id. */
          @AuraEnabled
          public String type{get;set;}
            /** @description The record id. */
          @AuraEnabled
          public String prodPrice{get;set;}
            /** @description The record id. */
          @AuraEnabled
          public String isoCode{get;set;}
            /** @description The record id. */
          @AuraEnabled
          public String contractId{get;set;}
          /** @description The record id. */
          @AuraEnabled
          public string country{get;set;}
          /** @description The record id. */
          @AuraEnabled
          public String quantity{get;set;}
           /** @description The record id. */
          @AuraEnabled
          public String rtWoli{get;set;}
          /** @description The record id. */
          @AuraEnabled
          public String segment{get;set;}
          /** @description The record id. */
          @AuraEnabled
          public String legalEntity{get;set;}

          @AuraEnabled
          public String positionName{get;set;}
          @AuraEnabled
          public String positionCode{get;set;}
    }
    
    /**
    * @author B2Win - 
    * @date Creation 22/06/2019
    * @description getLimitedProduct2
    * @param listParam String
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
      public static XC_UTIL_ResultWrapper getLimitedProduct2(String listParam){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        System.debug('listParam-'+listParam);
        rw.success = true;
        Map<String,Object> objInfoData = new Map<String,Object>();
        objInfoData.put('product2List', new List<Product2ContactLineItemWrapper>());
        objInfoData.put('showSelectMaterial', false);
        try{     
            ListaParamWrapper tw = new ListaParamWrapper();
            tw =(ListaParamWrapper)System.JSON.deserialize(listParam, ListaParamWrapper.class);
            System.debug('searchFilters-'+tw.searchFilters);
            Integer ps = Integer.valueOf(tw.pageSize);
            Integer pn = Integer.valueOf(tw.pageNumber)-1;

            List<Product2> products = new List<Product2>();
            Map<Id,NE__OrderItem__c> orderItem = new Map<Id,NE__OrderItem__c>([
                    SELECT  Id,
                            Name,
                            NE__OrderId__r.XC_Contract__c, XC_PartnerContract__c,
                            NE__OrderId__c,
                            NE__OrderId__r.NE__Country__c,
                            NE__OrderId__r.XC_Country__c,
                            NE__OrderId__r.XC_Contract_B2Win__c,
                            NE__OrderId__r.XC_Contract__r.Pricebook2Id,
                            XC_PartnerContract__r.Pricebook2Id,
                            XC_LegalEntity__c,
                            NE__One_Time_Cost__c,
                            NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c,
                            NE__Parent_Order_Item__c,
                            NE__Parent_Order_Item__r.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c,
                            XC_Provisioning__c, XC_WBE__c, XC_CMCostCenter__c, XC_CMProfitCenter__c, NE__CatalogItem__c
                    FROM NE__OrderItem__c
                    WHERE Id =: tw.orderItemId
            ]);




            Map<Id,WorkOrderLineItem> inputWoli = new Map<Id,WorkOrderLineItem>([
                    SELECT  Id,XC_Contract__c, WorkOrder.XC_Country__c, WorkOrder.XC_LegalEntity__c,  XC_ContractId__c, XC_WarehouseId__c, XC_AccountId__c, XC_ShipToStateProvince__c
                      FROM WorkOrderLineItem
                    WHERE Id =: tw.woliId
            ]);

            //String partnerContract='';
            //tw.iPricebookId = '';  
            String country='';
            if(!orderItem.values().isEmpty()) {
                tw.country  = orderItem.values().get(0).NE__OrderId__r.XC_Country__c;  //NE__Country__c
                tw.partnerContract = !inputWoli.values().isEmpty() && inputWoli.values().get(0).XC_ContractId__c != null ? inputWoli.values().get(0).XC_ContractId__c : (!inputWoli.values().isEmpty() && !String.isBlank(inputWoli.values().get(0).XC_Contract__c)) ? inputWoli.values().get(0).XC_Contract__c : orderItem.values().get(0).XC_PartnerContract__c;
                //tw.iPricebookId = orderItem.values().get(0).XC_PartnerContract__r.Pricebook2Id;
                tw.legalEntity = orderItem.values().get(0).XC_LegalEntity__c;
                tw.productCategory = orderItem.values().get(0).NE__Parent_Order_Item__c == null ? orderItem.values().get(0).NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c : orderItem.values().get(0).NE__Parent_Order_Item__r.NE__CatalogItem__r.XC_LIC_Catalog_Item_Name__c;
                tw.searchService = (String.isNotBlank(tw.partnerContract) || (tw.rtWoli != null && (tw.rtWoli.contains('_PE_WOLI') || tw.rtWoli.contains('PartnerPayment') ))) && !(tw.rtWoli != null && tw.rtWoli.contains('_Good_Issue'))  && !(tw.rtWoli != null && tw.rtWoli.contains('_MR_WOLI'));
                if(!tw.searchService){
                    tw.searchMaterial = true; // (tw.searchMaterial || !tw.searchService);
                }
                objInfoData.put('showSelectMaterial', tw.partnerContract != null);
            }else if(!inputWoli.values().isEmpty()){
                // retrieve country from CI or from WOLI(Product Required)
                tw.country = inputWoli.values().get(0).WorkOrder.XC_Country__c;
                tw.partnerContract = inputWoli.values().get(0).XC_ContractId__c != null ? inputWoli.values().get(0).XC_ContractId__c : !String.isBlank(inputWoli.values().get(0).XC_Contract__c) ? inputWoli.values().get(0).XC_Contract__c : null;
                tw.legalEntity = inputWoli.values().get(0).WorkOrder.XC_LegalEntity__c;
                tw.productCategory = null;
                tw.searchService = (String.isNotBlank(tw.partnerContract) || (tw.rtWoli != null && tw.rtWoli.contains('_PE_WOLI') || tw.rtWoli.contains('PartnerPayment'))) && !(tw.rtWoli != null && tw.rtWoli.contains('_Good_Issue'))  && !(tw.rtWoli != null && tw.rtWoli.contains('_MR_WOLI'));
                if(!tw.searchService){
                    tw.searchMaterial = true; // (tw.searchMaterial || !tw.searchService);
                }
                objInfoData.put('showSelectMaterial', tw.partnerContract != null);
            }

            Map<Id, Id> mapWorkOrderIdWarehouseId = XC_UTIL_WOLICreateGoodIssue.getMapWorkOrderLineItemWarehouse(inputWoli.values());
            if(inputWoli != null && !inputWoli.isEmpty()){
                tw.warehouse = inputWoli.values()[0].XC_WarehouseId__c != null ? inputWoli.values()[0].XC_WarehouseId__c : mapWorkOrderIdWarehouseId.get(tw.woliId);
            }
        
            String sapTypeService ='';
            List<Product2ContactLineItemWrapper> data = XC_UTIL_TechnicalCart.loadProductFromGlovia(tw);
            objInfoData.put('product2List', data);
            objInfoData.put('country', tw.country);
            objInfoData.put('legalEntity', tw.legalEntity);
        }
        catch (Exception e){
            System.debug( '@@@@ getLimitedProduct2 - Generic Error1: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }

        rw.objectInfo = JSON.serialize(objInfoData);
        return rw;
    }
    
    /**
    * @author B2Win - 
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description // generate configuration item with technical item
    * @param listParam String
    * @param mP String
    * @return true boolean
    */
    @AuraEnabled 
     //public static Boolean generateTechnicalItems(string listParam, string mP){
    public static XC_UTIL_ResultWrapper generateTechnicalItems(string listParam, List<Product2ContactLineItemWrapper> selectedProduct, string mP){
      XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();  
      rAndM.resultMessage = '';
      rAndM.success = true;
      ListaParamWrapper tw = new ListaParamWrapper();
      try{
        tw =(listaParamWrapper)System.JSON.deserialize(listParam,listaParamWrapper.class);
        //system.debug('@@@@ generateTechnicalItems - ListaParamWrapper : '+tw.mapManualPrice);
        //system.debug('@@@@ ListaParamWrapper : '+contractId);
        WrapperCallMethod wrMeth = new WrapperCallMethod();
        //system.debug('@@@@ generateTechnicalItems - generateTechnicalItems:' + tw.mapManualPrice + ' - rows:' + tw.rows);
        Savepoint sp = Database.setSavepoint();
        List<XC_JSON2Apex> parseJsonMP = new  List<XC_JSON2Apex>();   
      
        if(tw.mapManualPrice!='"[]"') { 
            parseJsonMP = XC_JSON2Apex.parse(tw.mapManualPrice);
         } 
        //system.debug('@@@@ generateTechnicalItems - parseJsonMP:' + parseJsonMP);
          if(tw.ordItem!=null){
              tw.tmpCatItem = getGenericTechnicalCatalogItem(tw.ordItem);
          }
        //Map<String, NE__ProductFamilyProperty__c> proNameMap = getProductFamilyProperties();
       
        /*List<Object> items = (List<Object>)JSON.deserializeUntyped(tw.rows);
        String priCo ='';
        if(tw.contractId != null && tw.contractId !=''){
           priCo = [SELECT Pricebook2Id from contract where id =:tw.contractId].pricebook2Id; 
        }*/
        //system.debug('@@@@ GenerateTechnicalItem - tw.ContractId:' + tw.contractId);
        
        wrMeth.ordItem = tw.ordItem;
        wrMeth.tmpCatItem = tw.tmpCatItem;
        wrMeth.parseJsonMP = parseJsonMP;
        wrMeth.selectedProduct = selectedProduct;

          //////////
          //Map<Id,Product2> productsMap = XC_UTIL_TechnicalCart.loadMap(items, priCo);
          //wrMeth.productsMap = productsMap;
          /////////
          System.debug('tw.contestCI'+tw.contestCI);
        if(!selectedProduct.isEmpty()){ //productsMap
           if(tw.contestCI=='true'){
              system.debug('@@@@ generateTechnicalItems - GENERATE FROM CONFIGURATION ITEM');
              rAndM = XC_UTIL_GenerateItemFromTechCart.generateCIFromTechCart(wrMeth, sp); //, proNameMap
         }else {
             system.debug('@@@@ generateTechnicalItems -  inside else = '+ tw.wbeElement);
            if(String.isBlank(tw.wbeElement)){
            WorkOrderLineItem woli = [select id, XC_WBSElement__c from WorkOrderLineItem where id = :tw.woliId];
            system.debug('@@@@ generateTechnicalItems -  wbs '+ woli.XC_WBSElement__c);
            tw.wbeElement = woli.XC_WBSElement__c;
            }
              rAndM = XC_UTIL_TechnicalCart.CreateCIPRPC(wrMeth,tw);
            
            }
        }
       }catch (Exception e){
                System.debug( '@@@@ generateTechnicalItems - Errore: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
                rAndM.resultMessage = 'Item created failed!!!:' + e.getMessage();
                rAndM.success = false;
                rAndM.typeMessage ='Error';
       } 
       return  rAndM;
    }
    
    /**
    * @author B2Win + Patrizia Arcidiacono - Patrizia.Arcidiacono@nttdata.com
    * @date Creation 22/06/2019
    * @date Modification 09/07/2020 Monica Cutillo - mcutillo@deloitte.it
    * @description 
    * @param  wrParamCItem WrapperCallMethod 
    * @param  item Product2ContactLineItemWrapper 
    * @return toInsert NE__OrderItem__c
    */
      public static NE__OrderItem__c getTechnicalOrderItem(WrapperCallMethod wrParamCItem, Product2ContactLineItemWrapper item){
        NE__OrderItem__c toInsert = new NE__OrderItem__c();
        if(Schema.SObjectType.NE__OrderItem__c.RecordTypeInfosByDeveloperName.get('Technical_Item') != null){
          toInsert.RecordTypeId = Schema.SObjectType.NE__OrderItem__c.RecordTypeInfosByDeveloperName.get('Technical_Item').RecordTypeId;
        }
        toInsert.XC_Product2Id__c = item.idProduct;
        toInsert.XC_GiiPriceBookEntry_Id__c = item.glBookEntryId;
        toInsert.XC_ServicePosition__c = item.positionName;
        //TODO Add Position for services
        double unitPriceManual=0;
        double quantity =1;
        
        List<String> vSplitPI = new List<String>();
        if(!wrParamCItem.parseJsonMP.isEmpty()){
            for(XC_JSON2Apex a : wrParamCItem.parseJsonMP){
                vSplitPI= a.glBookEntryId.split('-');
                if(item.glBookEntryId == string.ValueOf(vSplitPI[0]))
                { 
                    unitPriceManual = XC_UTIL_TechnicalCart.setCartManualValue(a.prodPrice);
                    quantity = XC_UTIL_TechnicalCart.setCartManualValue(a.quantity);
                }
            }   
        }

        //toInsert.NE__Parent_Order_Item__c = wrParamCItem.ordItem.Id;
        //toInsert.XC_RelatedProduct__c = wrParamCItem.ordItem.Id;
        toInsert.XC_ParentCommercialItem__c = wrParamCItem.ordItem.Id; 
        toInsert.XC_WBE__c = wrParamCItem.ordItem.XC_WBE__c;
        //toInsert.XC_CMCostCenter__c = wrParamCItem.ordItem.XC_CMCostCenter__c;
        //toInsert.XC_CMProfitCenter__c = wrParamCItem.ordItem.XC_CMProfitCenter__c;
        //toInsert.NE__Bundle_Configuration__c = wrParamCItem.ordItem.NE__Bundle_Configuration__c;
        //toInsert.NE__Root_Order_Item__c = wrParamCItem.ordItem.Id;
        
        //DP toInsert.NE__OneTimeFeeOv__c = wrParamCItem.ordItem.NE__OneTimeFeeOv__c;
        //DP toInsert.NE__One_Time_Tax_Free__c = wrParamCItem.ordItem.NE__One_Time_Tax_Free__c; 
        //DP toInsert.NE__RecurringChargeOv__c = wrParamCItem.ordItem.NE__RecurringChargeOv__c;
        
        //toInsert.XC_EnelXMaterial__c = (item.type !='Service'); //XC_SapType__c
        toInsert.NE__One_Time_Cost__c = String.isNotBlank(item.prodPrice)? Double.valueOf(item.prodPrice) : 0;
        //toInsert.NE__One_Time_Cost__c = 0;
        /*if(!item.PricebookEntries.isEmpty()){
           toInsert.NE__One_Time_Cost__c = item.PricebookEntries.get(0).UnitPrice;
        }else if(unitPriceManual !=0 ){   
           toInsert.NE__One_Time_Cost__c = unitPriceManual; 
        }*/
        toInsert.NE__Qty__c = quantity;
        if(wrParamCItem.tmpCatItem != null){
            toInsert.NE__CatalogItem__c = wrParamCItem.tmpCatItem.Id;
            toInsert.NE__ProdId__c = wrParamCItem.tmpCatItem.NE__ProductId__c;
            toInsert.NE__Generate_Asset_Item__c = false;
            Integer randomNumber = Integer.valueof((Math.random() * 1000000000));
            toInsert.NE__Configuration_item_update_key__c = wrParamCItem.ordItem.NE__OrderId__c+'_'+randomNumber;
            toInsert.NE__Item_Code__c = String.valueOf(randomNumber);
            //START FM - FIX CR758
            toInsert.NE__Hidden_in_Cart__c = false;
            toInsert.XC_RelatedProduct__c = toInsert.NE__Item_Code__c;
            //END FM - FIX CR758
            toInsert.NE__BaseRecurringCharge__c = 0;
            toInsert.NE__RecurringChargeFrequency__c  = 'Monthly';
            //COMMENTATI MC - TODO> Check se serve qualcosa
            /*toInsert.NE__BaseOneTimeFee__c = wrParamCItem.tmpCatItem.NE__Base_OneTime_Fee__c;
            toInsert.NE__BaseRecurringCharge__c = wrParamCItem.tmpCatItem.NE__BaseRecurringCharge__c;
            toInsert.NE__PromotionId__c = wrParamCItem.tmpCatItem.NE__PromotionId__c;
            if(wrParamCItem.tmpCatItem.Id != null){
                toInsert.NE__CatalogItem__c = wrParamCItem.tmpCatItem.Id;
            }
            toInsert.NE__Commitment__c = wrParamCItem.tmpCatItem.NE__Commitment__c;
            toInsert.NE__Generate_Asset_Item__c = wrParamCItem.tmpCatItem.NE__Generate_Asset_Item__c;
            toInsert.NE__Penalty__c = wrParamCItem.tmpCatItem.NE__Penalty__c;
            toInsert.NE__ProdId__c = wrParamCItem.tmpCatItem.NE__ProductId__c;
            toInsert.NE__RecurringChargeFrequency__c = wrParamCItem.tmpCatItem.NE__Recurring_Charge_Frequency__c;
            toInsert.NE__Status__c = wrParamCItem.tmpCatItem.NE__Status__c;
            toInsert.NE__Catalog__c = wrParamCItem.tmpCatItem.NE__Catalog_Id__c;*/
        }
        //toInsert.XC_Product_code__c = item.productCode;
        //toInsert.XC_ProductSerialized__c = item.XC_SerialControlled__c;
        //toInsert.NE__Qty__c = 1;
        toInsert.NE__OrderId__c = wrParamCItem.ordItem.NE__OrderId__c;
        toInsert.NE__Account__c = wrParamCItem.ordItem.NE__Account__c;
        toInsert.NE__Billing_Account__c = wrParamCItem.ordItem.NE__Account__c;
        toInsert.NE__Service_Account__c = wrParamCItem.ordItem.NE__Account__c;
        toInsert.NE__Action__c = 'Add';

        return toInsert;
    }

    /**
    * @author B2Win - 
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description 
    * @return propNameMap Map<String, NE__ProductFamilyProperty__c> 
    */
    /*private static Map<String, NE__ProductFamilyProperty__c> getProductFamilyProperties(){
      Map<Id,NE__ProductFamilyProperty__c> prodFamProp = new Map<Id,NE__ProductFamilyProperty__c>([  
          SELECT  Id,
                  NE__FamilyPropertyCode__c,
                  NE__Source_Product_Family_Property_Id__c,
                  NE__FamilyId__c,
                  NE__PropId__c,
                  NE__FamilyId__r.Name,
                  NE__PropId__r.Name
          FROM NE__ProductFamilyProperty__c
          WHERE NE__FamilyId__r.Name = 'Generic Material'
      ]);
      Map<String, NE__ProductFamilyProperty__c> propNameMap = new Map<String, NE__ProductFamilyProperty__c>();
      if(!prodFamProp.isEmpty()){
          for(NE__ProductFamilyProperty__c item : prodFamProp.values()){
              propNameMap.put(item.NE__PropId__r.Name, item);
          }
      }
      return propNameMap;
  }*/
  
  /** 
  * @author B2Win - 
  * @date Creation 22/06/2019
  * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
  * @description // 
  * @param ordItem NE__OrderItem__c
  * @return tmpCatItem.get(0) NE__Catalog_Item__c
  */
  /*private static NE__Catalog_Item__c getCatalogItem(NE__OrderItem__c ordItem){
    Map<Id,NE__Catalog_Item__c> data = new Map<Id,NE__Catalog_Item__c>([
        SELECT Id,
               NE__Engine_Code__c,
               NE__Base_OneTime_Fee__c,
               NE__BaseRecurringCharge__c,
               NE__PromotionId__c,
               NE__Commitment__c,
               NE__Generate_Asset_Item__c,
               NE__Penalty__c,
               NE__ProductId__c,
               NE__Recurring_Charge_Frequency__c,
               NE__Status__c,
               NE__Catalog_Id__c
          FROM NE__Catalog_Item__c
          WHERE Id =: ordItem.NE__CatalogItem__c //NE__Engine_Code__c = 'a1M0D000000h6tAUAQ' //Label.XC_NE_EngineCode
          LIMIT 1
    ]);
    
    return (!data.isEmpty()) ? data.values().get(0) : null;
  }*/
  
  /** 
  * @author Monica Cutillo - mcutollo@deloitte.it
  * @date Creation 10/07/2020
  * @description retrieve the Generic Technical Product Catalog Item
  * @param ordItem NE__OrderItem__c
  * @return the 'Generic Technical Product' NE__Catalog_Item__c
  */
  private static NE__Catalog_Item__c getGenericTechnicalCatalogItem(NE__OrderItem__c ordItem){
      if(ordItem == null) {
          return null;
      }
    Map<Id,NE__Order__c> order = new Map<Id,NE__Order__c>([
        SELECT Id, NE__CatalogId__c, NE__CatalogId__r.XC_LIC_Name__c 
        FROM NE__Order__c 
        WHERE Id =: ordItem.NE__OrderId__c
          LIMIT 1
    ]);

    Map<Id,NE__Catalog_Item__c> catalogItems = new Map<Id,NE__Catalog_Item__c>([
        SELECT Id, NE__ProductId__c, NE__ProductId__r.XC_LIC_Product_Name__c
        FROM NE__Catalog_Item__c 
        WHERE NE__Catalog_Id__c =: order.values()[0].NE__CatalogId__c 
          AND NE__ProductId__r.XC_Product_Type__c = 'Technical' 
          AND NE__ProductId__r.XC_Product_Subtype__c = 'Product' 
        and NE__ProductId__r.XC_LIC_Product_Name__c = 'Generic Technical Product'
    ]);

    return (!catalogItems.isEmpty()) ? catalogItems.values().get(0) : null;
}

  


    /**
    * @author B2Win - 
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description // Search puntual product
    * @param listParam String
    * @return prod2ListWrapper List<Product2ContactLineItemWrapper>
    */
    @AuraEnabled 
    //public static List<Product2ContactLineItemWrapper> searchOnProduct2(String country, String name, string family, String typeName, String sapCode, String pageSize, String pageNumber, String contractId){
    public static List<Product2ContactLineItemWrapper> searchOnProduct2(String listParam){  
        system.debug('@@@@ searchOnProduct2 - listaParam : '+ listParam);
        listaParamWrapper tw = new listaParamWrapper();
        tw =(listaParamWrapper)System.JSON.deserialize(listParam,listaParamWrapper.class);
        //system.debug('@@@@ searchOnProduct2 - ListaParamWrapper : '+tw);
        //system.debug('@@@ searchOnProduct2 - contractId:' + tw.contractId);
        List<Product2> products = new List<Product2>();
        try{         
            if (!String.isBlank(tw.country)){
                Integer ps = Integer.valueOf(tw.pageSize); 
                Integer pn = Integer.valueOf(tw.pageNumber)-1;
                String priCo ='';
                String queryLike='';

                if(tw.contractId !=null && tw.contractId !='') {
                  priCo= [SELECT Pricebook2Id from contract where id =:tw.contractId].pricebook2Id; 
                }   
                system.debug('@@@ searchOnProduct2-  post select:' + priCo);
                string country1 = String.escapeSingleQuotes(tw.country);
                string a1 ='Material';
                string b ='Service';
                Set<String>  sPriceBookId = new Set<String>();
                Set<String>  sProductShow1 = new Set<String>();
                //sProductShow1 = XC_UTIL_TechnicalCart.getSetList(sPriceBookId, tw.country, priCo);   //COMMENTATO MONICA
      
                string query = 'SELECT Id, Name, ProductCode, XC_SapType__c,XC_Type__c, XC_Price__c,XC_Country__c, Family,  Description, CurrencyIsoCode,'+ //XC_Country__c,
                               '(SELECT Id, PriceBook2Id, UnitPrice, CurrencyIsoCode '+
                               'FROM PriceBookEntries WHERE PriceBook2Id =:priCo or Pricebook2Id in: sPriceBookId)' +
                               ' FROM Product2 '+
                               'WHERE XC_Country__c =: country1 AND (XC_SapType__c =: a1 or XC_SapType__c =:b)'; //WHERE XC_Country__c 

                query += getCondLike(tw.name, '\'%' + String.escapeSingleQuotes(tw.name) + '%\'', ' AND Name LIKE ');
                query += getCondLike(tw.sapCode, '\'%' + String.escapeSingleQuotes(tw.sapCode) + '%\'', 'AND productCode LIKE ');
                query += getCondLike(tw.typeName, '\'%' + String.escapeSingleQuotes(tw.typeName) + '%\'', ' AND XC_SapType__c LIKE ');
                query += 'AND Id in:sProductShow1 ';
                query += ' ORDER BY Name, CreatedDate DESC'; //DESC
                query += ' LIMIT '+Integer.valueOf(ps);
                query += ' OFFSET '+ (ps*pn);
                System.debug('@@@@ searchOnProduct2 - QUERY: '+ query);
                //products = Database.query(query);
                string a = String.escapeSingleQuotes(query);
                //system.debug('@@@@ searchOnProduct2 - A:' + a);
                products = Database.query(String.escapeSingleQuotes(query).replace('\\', ''));
                //system.debug('@@@@ searchOnProduct2 - products:' + products);
            }
        } 
        catch (Exception e){
            System.debug( '@@@@ searchOnProduct2 - Generic Error1: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        //return products;
        
        List<Product2ContactLineItemWrapper> prod2ListWrapper = new List<Product2ContactLineItemWrapper>();
        //prod2ListWrapper = XC_UTIL_TechnicalCart.loadWrapperClass(prod2ListWrapper, products,tw.contractId);           //COMMENTATO MONICA 
        System.debug( '@@@@ searchOnProduct2 - prod2ListWrapper:' + prod2ListWrapper.size());
        return prod2ListWrapper;
    }   

      /** 
    * @author B2Win - 
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description // 
    * @param condQuery string
    * @param condQueryLike string
    * @param fieldName string
    * @return string
    */
	@TestVisible
    private static string getCondLike(string condQuery, string condQueryLike, string fieldName){
        string queryAdd='';
         system.debug('@@@@ getCondLike - condQuery:' + condQuery);
         system.debug('@@@@ getCondLike - condQueryLike:' + condQueryLike);
         system.debug('@@@@ getCondLike - fieldName:' + fieldName);
        if(condQuery !='' && condQuery !=null){
           queryAdd = fieldName + condQueryLike ;
        }
        system.debug('@@@@ getCondLike - queryAdd:' + queryAdd);
        return queryAdd;                       
    }

    /**
   * @author dpalamides
   * @date Creation 16/07/2020
   * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
   * @description
   * @param  woliId string
   * @return string
   */
    @AuraEnabled
    public static List<Product2ContactLineItemWrapper> getOrderItemFromWoli(string woliId){
        List< Product2ContactLineItemWrapper> woliWrapperLst = new List< Product2ContactLineItemWrapper>();
        Map<Id, workOrderLineItem> infoWoli = new Map<Id, workOrderLineItem>();
        List<workOrderLineItem> woliInfoLst = new List<workOrderLineItem>();
        system.debug('@@@@ getOrderItemFromWoli - woliId : ' + woliId);
        string countryWOLI='';
        if(woliId !='' && woliId !=null){
            infoWoli = new  Map<Id, workOrderLineItem>([SELECT Id, Country,WorkOrderId, WorkOrder.XC_Segment__c,WorkOrder.XC_LegalEntity__c,
                    Recordtype.Name, recordtype.DeveloperName from
                    workOrderLineItem where id =:woliId]);

            woliInfoLst = infoWoli.values();
            for(workOrderLineItem woli : woliInfoLst){

                Product2ContactLineItemWrapper woliWrapper = new Product2ContactLineItemWrapper();
                woliWrapper.Id = woli.Id;
                woliWrapper.country= woli.country;
                woliWrapper.rtWoli = woli.recordtype.DeveloperName;
                woliWrapper.workOrderId = woli.workOrderId;
                woliWrapper.segment = woli.WorkOrder.XC_Segment__c;
                woliWrapper.legalEntity = woli.WorkOrder.XC_LegalEntity__c;
                woliWrapperLst.add(woliWrapper);

            }

        }

        return woliWrapperLst;
    }

    @AuraEnabled
    public static String checkConfItem(String recordId){
	      //START-CR725-elisa.caldini@accenture.com-09.03.2022
        String errMessage='';
        List<String> stageNames=new List<String> {'Draft','Qualified Potential Opportunity'};
        List<String> legalEntities= new  List<String>{'EnelSole','EnelXItalia'};
        //END-CR725-elisa.caldini@accenture.com-09.03.2022
        NE__OrderItem__c orditem = [select id, NE__OrderId__r.XC_ProvisioningType__c,NE__OrderId__r.Recordtype.DeveloperName,NE__OrderId__r.NE__OptyId__r.StageName,NE__OrderId__r.XC_Segment__c, NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c,NE__OrderId__r.XC_LegalEntity__c from NE__OrderItem__c where id = :recordId];//CR725-elisa.caldini@accenture.com-09.03.2022-add fields
        if(orditem.NE__OrderId__r.XC_ProvisioningType__c != 'Project'){
            return Label.XC_CL_NoAddTechnicalItem;
        }else if('Opty'.equalsIgnoreCase(orditem.NE__OrderId__r.Recordtype.DeveloperName)  &&  stageNames.contains(orditem.NE__OrderId__r.NE__OptyId__r.StageName)  &&  !'B2C'.equalsIgnoreCase(orditem.NE__OrderId__r.XC_Segment__c) && legalEntities.contains(orditem.NE__OrderId__r.XC_LegalEntity__c)  && 'eCity'.equalsIgnoreCase(orditem.NE__OrderId__r.NE__OptyId__r.XC_BusinessLine__c) ){  //START-CR725-elisa.caldini@accenture.com-09.03.2022
            return errMessage='Is not possible to add technical item for opportunity status that precede the in progress status';
		    }else{ //END-CR725-elisa.caldini@accenture.com-09.03.2022
         return null;
        }
    }

    @AuraEnabled
    public static Boolean checkFromCommunity(){
        Boolean fromCommunity = True;
        if(UserInfo.getUserType()=='Standard'){
           fromCommunity = False;
        }
        return fromCommunity;
    }
/*Start R1-2022 NR2248 vaibhav.c.anand@accenture.com*/
 @AuraEnabled
 public static String uploadCSVFile(Boolean contestCI, String recordId, String woliId){ 
     ContentVersion cv = new ContentVersion();
     cv.Title = 'csvtemplate';
     cv.PathOnClient = 'csvtemplate' + '.csv';
     cv.VersionData = Blob.valueOf('sep=,\nProduct Code,Quantity,Service Position\n');
     INSERT cv;
     
     Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

     String url = 'https://' + URL.getSalesforceBaseUrl().getHost() + '/' +'sfc/servlet.shepherd/document/download/'+ String.valueOf(contentDocumentId);
     system.debug('@@@@ url : ' + url);

     if(contestCI){
        NE__OrderItem__c orditem = [select id,  XC_PartnerContract__c, XC_Product_Type__c from NE__OrderItem__c where id =:recordId];
         if(orditem.XC_PartnerContract__c == null  && orditem.XC_Product_Type__c == 'Service'){
             return null;
         }
         else{
             return url;
         }
     }
     else{
       WorkOrderLineItem woli = [select id,  XC_ContractId__c,  XC_WOLIType__c from WorkOrderLineItem where id =:woliId];
         system.debug('@@@@ wolicontract : ' + woli.XC_ContractId__c );
         system.debug('@@@@ wolitype : ' + woli.XC_WOLIType__c );
       if(woli.XC_ContractId__c == null && woli.XC_WOLIType__c == 'Partner Engagement'){
           return null;
       }
       else{
           return url;
       }
     }
 }

@AuraEnabled
public static List<Product2ContactLineItemWrapper> saveCsvFile(Id contentDocumentId, Boolean contestCI, String recordId, String woliId ){
  ContentVersion contentVersionObj = [ SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId ];
  List < String > records = contentVersionObj.VersionData.toString().split( '\n' );
    
  List<String> ProductCodeList = new List<String>();
  List<String> QuantityList = new List<String>();
  List<String> ServicePositionList = new List<String>();
  List<String> ErrorList = new List<String>();
  List<gii__Product2Add__c> ProductsToUpload = new List<gii__Product2Add__c>();
  List<String> csvRowValues = new List<String>();
  Map<String, gii__Product2Add__c> Product2AddMap = new Map<String, gii__Product2Add__c>();
  Map<String, gii__Product2Add__c> Product2AddMap2 = new Map<String, gii__Product2Add__c>();
  Map<String, gii__Product2Add__c> Product2AddMap3 = new Map<String, gii__Product2Add__c>();
  Map<String, gii__PriceBookEntry__c> PriceBookEntryMap = new Map<String, gii__PriceBookEntry__c>();
  Map<String, gii__Product2Add__c> prodNameMap = new Map<String, gii__Product2Add__c>();
    
  for (Integer k = 0; k < records.size(); k++) {
    if(k == 0)
      continue;

    if ( records[k] != null ) {
      List < String > row = new List <String>() ;
        if(records[k].contains(','))
          row = records[k].split( ',' );
        else if(records[k].contains(';'))
          row = records[k].split( ';' );
        else
          row = records[k].split( ',' );
        ProductCodeList.add( row[0]);
        row[1] = row[1].replaceAll('\r\n','');
        row[1] = row[1].replaceAll('\r','');
        row[1] = row[1].replaceAll('\n','');
        system.debug('Row final' + row[1]);
        QuantityList.add(row[1]);
        if(row.size() > 2){
          row[2] = row[2].replaceAll('\r\n','');
          row[2] = row[2].replaceAll('\r','');
          row[2] = row[2].replaceAll('\n','');
          if(!String.isBlank(row[2])){
          	ServicePositionList.add(row[2]);
          }
        }
        ErrorList.add('ok');
    }
  }
    System.debug('ProductList '+ ProductCodeList);
    System.debug('QuantityList '+ QuantityList);
    System.debug('ServiceList '+ ServicePositionList);
  //Duplicate Product Code Check
  Set<String> s1 = new Set<String>();
  for(Integer x = 0; x < ProductCodeList.size(); x++){
    if(!s1.add(ProductCodeList[x]))
       return null ;
  }
    //Quantity check
  for (Integer j = 0; j < QuantityList.size(); j++) {
      if(String.isBlank(QuantityList[j]) || (Decimal.ValueOf(QuantityList[j]) <= 0)){
         ErrorList[j] = 'Errore. Impossibile inserire quantità uguali o minori di 0';
      }
  }
    
  String contract ;
  String legal ;
    NE__OrderItem__c orditem;
    WorkOrderLineItem woli;
  if(contestCI){
      system.debug('@@@@ inside orderitem : ');
    orditem = [select id, NE__Account__c, XC_PartnerContract__c,  XC_LegalEntity__c, XC_WBE__c, NE__One_Time_Cost__c, NE__CatalogItem__c, NE__ProdId__c, NE__OrderId__c from NE__OrderItem__c where id = :recordId];
    contract = orditem.XC_PartnerContract__c ;
    legal = orditem.XC_LegalEntity__c ;
  }
  else{
      system.debug('@@@@ inside woli : ');
    woli = [select id, RecordType.DeveloperName, XC_ContractId__c, WorkOrder.XC_LegalEntity__c, XC_WBSElement__c from WorkOrderLineItem where id = :woliId];
    contract = woli.XC_ContractId__c;
    legal = woli.WorkOrder.XC_LegalEntity__c ;
  }

  List<String> ProductCodeSecondList = new List<String>();
  List<String> ProductCodeThirdList = new List<String>();
    //First Check
    List<gii__Product2Add__c> prodtoadd =  [SELECT Id,Name,giic_SAPtype__c, gii__ProductCode__c, giic_ExternalID__c, giic_AveragePrice__c FROM gii__Product2Add__c  WHERE gii__ProductCode__c =:ProductCodeList];

    for(gii__Product2Add__c product : prodtoadd){
      prodNameMap.put(product.giic_ExternalID__c,product);
      Product2AddMap.put(product.gii__ProductCode__c , product) ;   
        if(String.isBlank(product.giic_SAPtype__c) || product.giic_SAPtype__c.equals('Service') ){
           ProductCodeSecondList.add(product.gii__ProductCode__c);
																								
						   
																   
																		   
																   
											   
												 
        }
      else
        ProductCodeThirdList.add(product.gii__ProductCode__c);
    }
    system.debug('@@@@ Product to add : ' + prodtoadd);  
    system.debug('@@@@ Product first list : ' + ProductCodeList);
    system.debug('@@@@ Product second list : ' + ProductCodeSecondList);
    system.debug('@@@@ Product third list : ' + ProductCodeThirdList);
    //Second Check
    List<gii__PriceBookEntry__c> pricebookentry = [SELECT Id, gii__ProductCode__c, gii__PriceBook__r.giic_Contract__c, gii__UnitPrice__c,giic_PositionDescriptionForService__c FROM gii__PriceBookEntry__c WHERE gii__PriceBook__r.giic_Contract__r.XC_ContractType__c  = 'Service'
                                                  AND gii__ProductCode__c =:ProductCodeSecondList AND gii__PriceBook__r.giic_Contract__c =:contract AND giic_PositionDescriptionForService__c=:ServicePositionList];

    system.debug('@@@@ Product to add before : ' + pricebookentry);
    for(gii__PriceBookEntry__c pricebook : pricebookentry){
      String service =  ServicePositionList[ProductCodeList.indexOf(pricebook.gii__ProductCode__c)] ;
        if(service.equals(pricebook.giic_PositionDescriptionForService__c)){
        PriceBookEntryMap.put(pricebook.gii__ProductCode__c , pricebook) ;
        }
    }
	 
				
																						   
																										   
																			   
																			
    system.debug('@@@@ Product to add after: ' + PriceBookEntryMap);
    
    
    //Third Check
    List<gii__Product2Add__c> prodtoadd2 = [SELECT Id, gii__ProductCode__c, giic_SAPtype__c FROM gii__Product2Add__c  WHERE gii__ProductCode__c =:ProductCodeList AND giic_LegalEntity__c =:legal];
														  

    for(gii__Product2Add__c product : prodtoadd2){
      Product2AddMap2.put(product.gii__ProductCode__c , product) ;
    }
    system.debug('@@@@ Product to add : ' + prodtoadd2);  

    //Fourth Check
    List<gii__Product2Add__c> prodtoadd3 = [SELECT id, gii__ProductCode__c, giic_SAPtype__c, giic_Available_for_Sales__c FROM gii__Product2Add__c WHERE gii__ProductCode__c =:ProductCodeThirdList AND giic_Available_for_Sales__c = TRUE];
    
    for(gii__Product2Add__c product : prodtoadd3){
      Product2AddMap3.put(product.gii__ProductCode__c , product) ;
    }
    system.debug('@@@@ Product to add : ' + prodtoadd3);   
												

    for(Integer m = 0; m < ProductCodeList.size(); m++){
       if(Product2AddMap.get(ProductCodeList[m]) == null && ErrorList[m].equals('ok'))  // add first error message //OK
            ErrorList[m] = 'Errore. Il prodotto inserito non è presente nell\'Anagrafica dei prodotti.';

        if(PriceBookEntryMap.get(ProductCodeList[m]) == null && ErrorList[m].equals('ok') && Product2AddMap.get(ProductCodeList[m]).giic_SAPtype__c=='Service'){
            if(contestCI || !woli.RecordType.DeveloperName.contains('PartnerPayment'))
              ErrorList[m] = 'Errore. I codici SAP inseriti non sono presenti nel contratto passivo in contesto.';
        }

        if(Product2AddMap2.get(ProductCodeList[m]) == null && ErrorList[m].equals('ok'))  // add third error message //OK
            ErrorList[m] = 'Errore. Il Product Code inserito non corrisponde alla Legal Entity in contesto.';

        if(Product2AddMap3.get(ProductCodeList[m]) == null && ErrorList[m].equals('ok') && Product2AddMap.get(ProductCodeList[m]).giic_SAPtype__c=='Material') 
            ErrorList[m] = 'Attenzione. Vi sono uno o più prodotti che non possono essere acquistati ex novo. Per favore, controlla la giacenza sul sistema di logistica.';
																																 
																	   
												  
        }
    
    
    for(Integer n = 0; n < ProductCodeList.size(); n++){
      if(ErrorList[n].equals('ok') || ErrorList[n].equals('Attenzione. Vi sono uno o più prodotti che non possono essere acquistati ex novo. Per favore, controlla la giacenza sul sistema di logistica.') )  // ok products
         ProductsToUpload.add(Product2AddMap.get(ProductCodeList[n]));
  }

for(Integer i = 0; i < ProductCodeList.size() ; i++){
    String rowStr ;
    if(ServicePositionList.size() == 0)
      rowStr = ProductCodeList[i] + ',' + QuantityList[i] + ',' + '' + ',' +  ErrorList[i] ;
    else
      rowStr = ProductCodeList[i] + ',' + QuantityList[i] + ',' + ServicePositionList[i] + ',' +  ErrorList[i] ;
    csvRowValues.add(rowStr);
}
    
    String csvColumnHeader = 'ProductCode,Quantity,Service Position,Result\n';
    String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
     
    system.debug('@@@@ RecordId : ' + recordId);
     Attachment att=new Attachment();
      att.Body=Blob.valueOf('\uFEFF'+csvFile);
      att.Name='Result'+'.csv';
      if(contestCI){
        att.parentId= recordId;
    }
      else{
    att.parentId = woliId;
    }
      att.ContentType = 'text/csv; charset=UTF-8';
      insert att;
    
  system.debug('@@@@ Attachment : ' + att);
  system.debug('@@@@ CSVdata : ' + ProductCodeList);

  List<Product2ContactLineItemWrapper> prod2ListWrapper = new List<Product2ContactLineItemWrapper>();
    
    List<Product2> prod2 = new List<Product2>();
    Map<String, Id> listPro2 = new Map<String, Id>();
    system.debug('@@@@ Product2AddMap: ' + Product2AddMap);
    if(!Product2AddMap.keySet().isEmpty()){
        prod2 = [SELECT id, Name, ProductCode FROM Product2 WHERE ProductCode in : prodNameMap.keySet()];
        for(Product2 p2 : prod2){
            listPro2.put(p2.ProductCode,p2.id);
        }
    }
    system.debug('@@@@ Prod2 list : ' + prod2);
   
  List<NE__OrderItem__c> ois = new List<NE__OrderItem__c>();
  NE__Catalog_Item__c neCat = getGenericTechnicalCatalogItem(orditem);
  for(gii__Product2Add__c pr : ProductsToUpload){
    Product2ContactLineItemWrapper prod2Wrapper = new Product2ContactLineItemWrapper();
    String quantity = QuantityList[ProductCodeList.indexOf(pr.gii__ProductCode__c)] ;
    prod2Wrapper.id = pr.Id;
    prod2Wrapper.glBookEntryId = pr.Id;
    prod2Wrapper.idGlProduct = pr.Id;
    prod2Wrapper.productCode = pr.gii__ProductCode__c;
    prod2Wrapper.Name = pr.Name;
    prod2Wrapper.Type = pr.giic_SAPtype__c;
    prod2Wrapper.quantity = quantity;
    prod2Wrapper.rtWoli = null;
    prod2Wrapper.segment = null;
    prod2Wrapper.legalEntity = legal;
    prod2Wrapper.country = null;
    prod2Wrapper.contractId = contract;
    prod2Wrapper.isoCode = null;
    if(pr.giic_SAPtype__c.equals('Material')){
      prod2Wrapper.prodPrice = String.ValueOf(pr.giic_AveragePrice__c) ;
    }
    if(pr.giic_SAPtype__c.equals('Service') && PriceBookEntryMap.get(pr.gii__ProductCode__c) != null){
      prod2Wrapper.prodPrice = String.ValueOf(PriceBookEntryMap.get(pr.gii__ProductCode__c).gii__UnitPrice__c) ;
      prod2Wrapper.positionCode = PriceBookEntryMap.get(pr.gii__ProductCode__c).giic_PositionDescriptionForService__c ;
      prod2Wrapper.positionName = PriceBookEntryMap.get(pr.gii__ProductCode__c).giic_PositionDescriptionForService__c ;
      prod2Wrapper.glBookEntryId = PriceBookEntryMap.get(pr.gii__ProductCode__c).Id;
    }
    if(woliId != null){
    prod2Wrapper.workOrderId = woliId ;
    }
    prod2Wrapper.idProduct = listPro2.get(pr.gii__ProductCode__c) ;
    prod2ListWrapper.add(prod2Wrapper);
    
    
    ois.add(addTechItem(pr,quantity,orditem,neCat,PriceBookEntryMap,listPro2.get(pr.gii__ProductCode__c)));
  }
  system.debug('@@@@  ProductsToUpload. : ' +  ProductsToUpload);
  system.debug('@@@@ prod2ListWrapper : ' + prod2ListWrapper);
    
    if(contestCI){
        if(!ois.isEmpty()){
            try{
                insert ois;    
            }catch(Exception e){
                System.debug( '@@@@ saveCsvFile - Generic Error1: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());                
            }
        }
    }

  return prod2ListWrapper;

}

public static NE__OrderItem__c addTechItem(gii__Product2Add__c pr2, String quantityStr, NE__OrderItem__c root, NE__Catalog_Item__c neCat, Map<String, gii__PriceBookEntry__c> pBentryMap, Id prod2){
    NE__OrderItem__c oi = new NE__OrderItem__c();
    if(Schema.SObjectType.NE__OrderItem__c.RecordTypeInfosByDeveloperName.get('Technical_Item') != null){
      oi.RecordTypeId = Schema.SObjectType.NE__OrderItem__c.RecordTypeInfosByDeveloperName.get('Technical_Item').RecordTypeId;
    }
    double quantity =1;
    oi.NE__Qty__c = XC_UTIL_TechnicalCart.setCartManualValue(quantityStr != null ? quantityStr.replace(',','.') : '');
    //START FM - FIX CR758 
    //oi.NE__Hidden_in_Cart__c = true;
    oi.NE__Hidden_in_Cart__c = false;
    //END FM - FIX CR758 
    oi.NE__Action__c = 'Add';
    oi.NE__Generate_Asset_Item__c = false;
    Integer randomNumber = Integer.valueof((Math.random() * 1000000000));
    oi.NE__Item_Code__c = String.valueOf(randomNumber);
    if(root!=null){
        oi.NE__Configuration_item_update_key__c = root.NE__OrderId__c+'_'+randomNumber;
        oi.NE__OrderId__c = root.NE__OrderId__c;
        oi.XC_WBE__c = root.XC_WBE__c;
        //START FM - FIX CR758 
        //oi.XC_RelatedProduct__c = root.Id;
        oi.XC_RelatedProduct__c = oi.NE__Item_Code__c;
        //END FM - FIX CR758 
      oi.XC_ParentCommercialItem__c = root.Id;
        oi.NE__Account__c = root.NE__Account__c;
      oi.NE__Billing_Account__c = root.NE__Account__c;
      oi.NE__Service_Account__c = root.NE__Account__c;
    }
    if(pr2.giic_AveragePrice__c != null){
      oi.NE__One_Time_Cost__c = pr2.giic_AveragePrice__c ;
      Decimal Cost = 0.0 ;      
      if(root != null){
        Cost = root.NE__One_Time_Cost__c ;
        if(Cost == null){
          Cost = 0.0 ;
        }
        root.NE__One_Time_Cost__c =  Cost + pr2.giic_AveragePrice__c*Decimal.valueOf(quantityStr) ;
        update root ;
      }
    }
    if(neCat!=null){
       oi.NE__CatalogItem__c = neCat.id;
        oi.NE__ProdId__c = neCat.NE__ProductId__c;
    }
    if(pr2.giic_SAPtype__c.equals('Service') && !pBentryMap.keySet().isEmpty()){
        system.debug('@@@@ Pricebook i OI : ' + pBentryMap.get(pr2.gii__ProductCode__c));
        oi.XC_GiiPriceBookEntry_Id__c = pBentryMap.get(pr2.gii__ProductCode__c).id;
        oi.XC_ServicePosition__c = pBentryMap.get(pr2.gii__ProductCode__c).giic_PositionDescriptionForService__c ;
        oi.NE__One_Time_Cost__c = pBentryMap.get(pr2.gii__ProductCode__c).gii__UnitPrice__c ;
        Decimal Cost = 0.0 ;
        if(root != null){
          Cost = root.NE__One_Time_Cost__c ;
          if(Cost == null){
            Cost = 0.0 ;
          }
          root.NE__One_Time_Cost__c =  Cost + pBentryMap.get(pr2.gii__ProductCode__c).gii__UnitPrice__c*Decimal.valueOf(quantityStr) ;
          update root ;
        }
    }
    if(prod2!=null){
        oi.XC_Product2Id__c = prod2;
    }
    
    /*
  toInsert.XC_Product2Id__c = item.idProduct;        
        toInsert.XC_ServicePosition__c = item.positionName;		
        toInsert.NE__One_Time_Cost__c = String.isNotBlank(item.prodPrice)? Double.valueOf(item.prodPrice) : 0;
*/

    return oi;
}
/*End R1-2022 NR2248 vaibhav.c.anand@accenture.com*/


}