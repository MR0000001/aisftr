/**
* @author Patrizia Arcidiacono
* @date Creation 30/07/2019
* @date Modification 30/07/2019
* @description UTILS to generate ProductRequired Item or Configuration Technical Item from Technical Cart
*/
public without sharing class XC_UTIL_GenerateItemFromTechCart{
    /**
    * @author Patrizia Arcidiacono - 
    * @date Creation 22/06/2019 vvvv
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description // wrapper class with @AuraEnabled and {get;set;} properties 
    */
    public class WrapperParam{
        /** @description The contract id. */
        public Integer ps;
        /** @description The contract id. */
        public Integer pn;
        /** @description The contract id. */
        public Boolean contestCI;
        /** @description The contract id. */
        public String orderItemId;
        /** @description The contract id. */
        public String woliId;
        /** @description The contract id. */
        public String iPricebook2Id;
        /** @description The contract id. */
        public String scenarioFrom;

    }
    /**
      * @author Patrizia Arcidiacono/2019
      * @date Creation 30/07/2019
      * @description create CI technical from technical Cart
      * @param wrParamCItem XC_LCC195_AddTechnicalItems.WrapperCallMethod
      * @param sp Savepoint
      * @param proNameMap Map<String, NE__ProductFamilyProperty__c>
      * @return XC_UTIL_ResultWrapper
      */
    public static XC_UTIL_ResultWrapper generateCIFromTechCart(XC_LCC195_AddTechnicalItems.WrapperCallMethod wrParamCItem, Savepoint sp){  //,Map<String, NE__ProductFamilyProperty__c> proNameMap
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        //Boolean result = true;
        rAndM.titleMessage = Label.XC_CL_GenerateTechnicalItem;
        rAndM.resultMessage = Label.XC_CL_TechnicalOrderItemCreated;
        rAndM.success = true;
        rAndM.typeMessage ='Success';
        List<NE__OrderItem__c> itemToInsert = new List<NE__OrderItem__c>();
        /*if(wrParamCItem.ordItem.XC_WBE__c=='' || wrParamCItem.ordItem.XC_CMProfitCenter__c=='' || wrParamCItem.ordItem.XC_CMCostCenter__c==''){
              rAndM.message = 'Failed!! Missing WBE or CostCenter or Profit Center!!';
              rAndM.result = false;
              rAndM.typeMessage ='Error';
              return rAndM;
        }  */
        //for(Id key : wrParamCItem.productsMap.keySet()){
        Decimal totalTechOneTimeCost = 0;
        Map<String,XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> prodMapData = new Map<String,XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>();
        for(XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper prod : wrParamCItem.selectedProduct){
            //system.debug('@@@@ generateCIFromTechCart - wrParamCItem.productsMap.get(key):' + wrParamCItem.productsMap.get(key)) ;
            // NE__OrderItem__c techOrdItem = XC_LCC195_AddTechnicalItems.getOrderItem(wrParamCItem.ordItem, wrParamCItem.tmpCatItem, wrParamCItem.productsMap.get(key),wrParamCItem.parseJsonMP);

            //NE__OrderItem__c techOrdItem = XC_LCC195_AddTechnicalItems.getOrderItem(wrParamCItem, wrParamCItem.productsMap.get(key));
            NE__OrderItem__c techOrdItem = XC_LCC195_AddTechnicalItems.getTechnicalOrderItem(wrParamCItem, prod);
            totalTechOneTimeCost = totalTechOneTimeCost + (techOrdItem.NE__Qty__c * techOrdItem.NE__One_Time_Cost__c);
            itemToInsert.add(techOrdItem);
            prodMapData.put(prod.id,prod);
        }
        try{
            if(!itemToInsert.isEmpty()){
                //INSERT TECH ITEMS
                //insert itemToInsert;
                List<XC_UTIL_Sobject.WrapperResult> insertOrderItemRW = XC_UTIL_DML.insertRecords(itemToInsert);
                //UPDATE COMM ITEM
                NE__OrderItem__c commOrdItem = new NE__OrderItem__c();
                commOrdItem.Id = wrParamCItem.ordItem.Id;
                Decimal startCost = (Decimal)XC_UTIL_Sobject_U_Retrieve.getFieldValueObject('NE__OrderItem__c', 'NE__One_Time_Cost__c', commOrdItem.Id);
                if(startCost == null){
                    startCost = 0;
                }
                commOrdItem.NE__One_Time_Cost__c = startCost + totalTechOneTimeCost;
                List<XC_UTIL_Sobject.WrapperResult> updCommOrderItemRW = XC_UTIL_DML.updateRecords(new List<NE__OrderItem__c>{commOrdItem});

                for(NE__OrderItem__c tech : itemToInsert){
                    tech.NE__SourceLineItemId__c = tech.Id;
                }
                List<XC_UTIL_Sobject.WrapperResult> updCommOrderItemRW2 = XC_UTIL_DML.updateRecords(itemToInsert);

            }
        }
        catch (Exception e){
            System.debug( '@@@@ Generic Error: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
            Database.rollback(sp);
            rAndM.resultMessage = Label.XC_CL_TechnicalItemCreatedFailed + ': ' + e.getMessage();
            rAndM.success = false;
            rAndM.typeMessage ='Error';
        }

        /*List<NE__Order_Item_Attribute__c> orderItemAttrToInsert = new List<NE__Order_Item_Attribute__c>();
        for(NE__OrderItem__c item : itemToInsert){
            orderItemAttrToInsert = setOrderAttr(proNameMap, item, prodMapData.get(item.XC_Product2Id__c));
            //Id key = (new List<Id>(wrParamCItem.productsMap.keySet()))[0];
            //Product2 tmpProduct2 = wrParamCItem.productsMap.get(key);
            //orderItemAttrToInsert = setOrderAttr(proNameMap, tmpProduct2, item);
            //wrParamCItem.productsMap.remove(key);
        }
        try{
            if(!orderItemAttrToInsert.isEmpty() && Schema.sObjectType.NE__Order_Item_Attribute__c.isCreateable()){
              List<XC_UTIL_Sobject.WrapperResult> insertOrderItemAttrRW = XC_UTIL_DML.insertRecords(orderItemAttrToInsert);
            }
        }
        catch (Exception e){
                  System.debug( '@@@@ Generic Error: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
                  Database.rollback(sp);
                  rAndM.resultMessage =  Label.XC_CL_TechnicalItemCreatedFailed + ': ' + e.getMessage();
                  rAndM.success = false;
                  rAndM.typeMessage ='Error';
        }*/
        return rAndM;
    }

    private static Map<Id, Integer> getNumProductRequired(List<String> woliID){
        Boolean toExit = woliID==null || woliID.isEmpty() || !Schema.sObjectType.ProductRequired.isAccessible();
        if(toExit){
            return new Map<Id, Integer>();
        }
        Map<id,Integer> retMap = new Map<Id, Integer>();
        List<AggregateResult> aggregateResultList = [SELECT ParentRecordId, count(Id) numPR FROM ProductRequired WHERE ParentRecordId in :woliID group by ParentRecordId];
        for(AggregateResult aggr : aggregateResultList){
            retMap.put((id)aggr.get('ParentRecordId'),(Integer) aggr.get('numPR'));
        }

        return retMap;
    }

    private static Map<Id, ProductRequired> getExistingProductRequired(List<String> woliID){
        Boolean toExit = woliID==null || woliID.isEmpty() || !Schema.sObjectType.ProductRequired.isAccessible();
        if(toExit){
            return new Map<Id, ProductRequired>();
        }
        Map<Id, ProductRequired> retMap = new Map<Id, ProductRequired>();
        List<ProductRequired> prList = [SELECT id, Product2Id FROM ProductRequired WHERE ParentRecordId in :woliID];
        for(ProductRequired pr : prList){
            retMap.put(pr.Product2Id,pr);
        }

        return retMap;
    }

    private static Map<String, XC_RequiredPosition__c> getExistingPRequiredPosition(List<String> prodReqIds){
        Boolean toExit = prodReqIds==null || prodReqIds.isEmpty() || !Schema.sObjectType.XC_RequiredPosition__c.isAccessible();
        if(toExit){
            return new Map<String, XC_RequiredPosition__c>();
        }
        Map<String, XC_RequiredPosition__c> retMap = new Map<String, XC_RequiredPosition__c>();
        List<XC_RequiredPosition__c> prList = [SELECT id, XC_ProductRequired__c,XC_ProductRequired__r.Product2Id, XC_PricebookEntry__c,XC_Quantity__c  FROM XC_RequiredPosition__c WHERE XC_ProductRequired__c in :prodReqIds];
        for(XC_RequiredPosition__c pr : prList){
            retMap.put(pr.XC_ProductRequired__c+'§'+pr.XC_PricebookEntry__c,pr);
        }

        return retMap;
    }

    /**
       * @author Patrizia Arcidiacono/2019
       * @date Creation 01/08/2019
       * @description mapListConfItemTechnicalMaterial
       * @param wrParamCItem XC_LCC195_AddTechnicalItems.WrapperCallMethod
       * @param tw XC_LCC195_AddTechnicalItems.listaParamWrapper
       * @return the XC_UTIL_ResultWrapper

       */
    public static XC_UTIL_ResultWrapper generatePRFromTechCart(XC_LCC195_AddTechnicalItems.WrapperCallMethod wrParamCItem,XC_LCC195_AddTechnicalItems.listaParamWrapper tw){
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        //XC_LCC195_AddTechnicalItems.ResultAndMessage rAndM = new XC_LCC195_AddTechnicalItems.ResultAndMessage();
        //Boolean result = true;
        rAndM.titleMessage = 'Generate Material Order';
        rAndM.resultMessage = 'Material Order created!!';
        rAndM.success = true;
        rAndM.typeMessage ='Success';
        string rTWoli = tw.rtWoli;

        Map<Id, Integer> numPR = getNumProductRequired(new List<String>{tw.woliId});
        Map<Id, ProductRequired> existingPR = getExistingProductRequired(new List<String>{tw.woliId});
        Map<String, XC_RequiredPosition__c> existingReqPos = getExistingPRequiredPosition(XC_UTIL_Sobject.getIds(existingPR.values()));

        try{

            //rAndM = XC_SendPRToGlovia_Controller.checkAddPr(tw.woliId);	//DECOMMENTARE MC

            if (!rAndM.success){
                //system.debug('@@@@ generatePRFromTechCart - errore, PR già inviata a Glovia ');
                rAndM.resultMessage = 'Order materials already sent !!!!';
                rAndM.success = false;
                rAndM.typeMessage ='Error';
                return rAndM;
            }

            List<ProductRequired> prodRes = new List<ProductRequired>();
            List<XC_RequiredPosition__c> positionReq = new List<XC_RequiredPosition__c>();
            List<XC_RequiredPosition__c> positionReqToUpd = new List<XC_RequiredPosition__c>();
            Map<Id,ProductRequired> allProductRequired = new Map<Id,ProductRequired>();
            Double unitPrice=0;
            Double unitPriceManual=null;
            Double quantity=0;
            String productId ;
            List<String> vSplitPI = new List<String>();
            Map<Id,Product2> productsMapVar = wrParamCItem.productsMap;
            List<Id> prod2Id = new List<Id>();
            for(XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper prod : wrParamCItem.selectedProduct){
                prod2Id.add(prod.idProduct);
            }
            Map<id,Product2> prod2Map = new Map<id,Product2>([select id, (select id, CurrencyIsoCode, UnitPrice from PriceBookEntries) from Product2 where id in :prod2Id]);
            Map<String,XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> prodMapData = new Map<String,XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>();
            for(XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper prod : wrParamCItem.selectedProduct){
                System.debug('prod§§'+prod);
                System.debug('tw§§'+tw);
                System.debug('prod quant§§'+prod.quantity);
                quantity=0;
                System.debug('quantity§§'+wrParamCItem.parseJsonMP);
                /*Start R1-2022 NR2248 vaibhav.c.anand@accenture.com*/
                if(!wrParamCItem.parseJsonMP.isEmpty()) {
                     System.debug('check');
                    for(XC_JSON2Apex a : wrParamCItem.parseJsonMP){
                        if(a.quantity == null)
                           quantity = XC_UTIL_TechnicalCart.setCartManualValue(prod.quantity.replace(',','.'));
                        vSplitPI= a.glBookEntryId.split('-');
                        if(prod.glBookEntryId == string.ValueOf(vSplitPI[0]))
                        {
                            System.debug('quantity§§ before'+a.quantity);
                            unitPriceManual = XC_UTIL_TechnicalCart.setCartManualValue(a.prodPrice);
                            quantity = XC_UTIL_TechnicalCart.setCartManualValue(a.quantity.replace(',','.'));
                        }
                    }
                }
                else{
                    quantity = XC_UTIL_TechnicalCart.setCartManualValue(prod.quantity.replace(',','.'));
                    System.debug('quantity§§ after'+quantity);
                }
                /*End R1-2022 NR2248 vaibhav.c.anand@accenture.com*/

                //unitPrice = prod2Map.containsKey(prod.idProduct)  && prod2Map.get(prod.idProduct).PriceBookEntries[0]!=null ? prod2Map.get(prod.idProduct).PriceBookEntries[0].UnitPrice : null;
                Boolean isPE = tw.rtWoli != null && (tw.rtWoli.contains('_PE_WOLI'));

                ProductRequired prodRe=new ProductRequired();
                if(existingPR.containsKey(prod.idProduct) && isPE){
                    prodRe = existingPR.get(prod.idProduct);
                    allProductRequired.put(prod.idProduct,prodRe);
                }
                else if(existingPR.containsKey(prod.idProduct)){
                    continue;
                }

                if(prodRe.Id == null && !existingPR.containsKey(prod.idProduct)) {
                    String recTypeNameStr = null;
                    recTypeNameStr = isPE ? 'XC_' + tw.segment + '_' + tw.legalEntity + '_PartnerEngagement' : 'XC_' + tw.segment + '_' + tw.legalEntity + '_MaterialRequest';

                    prodRe.RecordTypeId = Schema.SObjectType.ProductRequired.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();
                    if (quantity == null || quantity == 0) {
                        quantity = 1;
                    }
                    prodRe.ParentRecordId = tw.woliId;
                    prodRe.XC_WorkOrderId__c = tw.workOrderId;
                    prodRe.XC_WorkOrderLineItem__c = tw.woliId;
                    prodRe.XC_OrderItem__c = tw.ordItem != null ? tw.ordItem.Id : null;
                    prodRe.Product2Id = prod.idProduct;//productId;
                    prodRe.XC_PriceUnits__c = unitPriceManual != null && unitPriceManual != 0 ? unitPriceManual : Double.valueOf(prod.prodPrice != null ? prod.prodPrice : '0');//unitPriceManual != null ? unitPriceManual : unitPrice;

                    if(!isPE) {
                        prodRe.XC_Quantity__c = quantity;
                        prodRe.QuantityRequired = quantity;
                        prodRe.XC_PriceUnits__c = unitPriceManual != null && unitPriceManual != 0 ? unitPriceManual : Double.valueOf(prod.prodPrice != null ? prod.prodPrice : '0');//unitPriceManual != null ? unitPriceManual : unitPrice;
                        prodRe.XC_OrderQuantity__c = quantity;
                        //POSITION CODE
                        //POSITION NAME
                        //lookup WOLI
                        //lookup PR
                    }

                    prodRe.XC_WBSElement__c = tw.wbeElement;
                    prodRe.XC_CostCenter__c = tw.costCenter;
                    if (numPR.containsKey(tw.woliId)) {
                        Integer n = numPR.get(tw.woliId);
                        prodRe.XC_PurchaseOderPositionOdA__c = String.valueOf((n + 1) * 10);
                        numPR.put(tw.woliId, n + 1);
                        System.debug('purchaseorder §§ if'+prodRe.XC_PurchaseOderPositionOdA__c);
                    } else {
                        Integer n = 0;
                        prodRe.XC_PurchaseOderPositionOdA__c = String.valueOf((n + 1) * 10);
                        numPR.put(tw.woliId, n + 1);
                        System.debug('purchaseorder §§ else'+prodRe.XC_PurchaseOderPositionOdA__c);
                    }


                    existingPR.put(prodRe.Product2Id, prodRe);
                    prodRes.add(prodRe);
                }

                if(isPE) {
                    XC_RequiredPosition__c existReqPosition = existingReqPos.get(prodRe.Id+'§'+prod.glBookEntryId);
                    if(existReqPosition!=null){
                        System.debug('quantity§§ inside isPE'+quantity);
                        existReqPosition.XC_Quantity__c = existReqPosition.XC_Quantity__c != null ? existReqPosition.XC_Quantity__c + (quantity != null ? quantity : 0) : existReqPosition.XC_Quantity__c;
                        positionReqToUpd.add(existReqPosition);
                    }else {
                        System.debug('quantity§§ inside isPE else'+quantity);
                        XC_RequiredPosition__c reqPosition = new XC_RequiredPosition__c();
                        reqPosition.XC_PositionCode__c = prod.positionName;
                        reqPosition.XC_PricebookEntry__c = prod.glBookEntryId;
                        reqPosition.XC_ProductRequired__c = prodRe.Id;
                        reqPosition.XC_ProductRequired__r = prodRe;
                        reqPosition.XC_WorkOrderLineItem__c = tw.woliId;
                        reqPosition.XC_Quantity__c = quantity;
                        reqPosition.XC_WBE__c = tw.wbeElement;
                        reqPosition.XC_CostCenter__c = tw.costCenter;
                        reqPosition.XC_UnitPrice__c = unitPriceManual != null && unitPriceManual != 0 ? unitPriceManual : Double.valueOf(prod.prodPrice != null ? prod.prodPrice : '0');//unitPriceManual != null ? unitPriceManual : unitPrice;
                        positionReq.add(reqPosition);
                    }
                }
            }
            /*for(Id key : wrParamCItem.productsMap.keySet()){
                if(!wrParamCItem.parseJsonMP.isEmpty()){
                  for(XC_JSON2Apex a : wrParamCItem.parseJsonMP){

                      vSplitPI= a.id.split('-');
                       if(key == string.ValueOf(vSplitPI[0]))  {
                        //unitPrice = double.ValueOf(a.prodPrice);
                        quantity = double.ValueOf(a.quantity.replace(',','.'));
                        productId = a.id;
                        system.debug('@@@@ generatePRFromTechCart - ciclo - unitPrice:' + unitPrice);
                        system.debug('@@@@ generatePRFromTechCart - ciclo - quantity:' + quantity);
                        break;
                      }

                  }
                  ProductRequired prodRe=new ProductRequired();
                  prodRe.ParentRecordId=tw.woliId;
                  prodRe.Product2Id=productId;

                  prodRe.XC_UnitPrice__c=unitPrice;
                  prodRe.XC_OrderQuantity__c=quantity;
                  prodRe.XC_WBE__c = tw.wbeElement;
                  prodRe.XC_CMCostCenter__c = tw.costCenter;
                  prodRes.add(prodRe);


                }
           } */
            system.debug('@@@@ generatePRFromTechCart - prodRes:' + prodRes);

            if(Schema.sObjectType.ProductRequired.isCreateable()){
                insert prodRes;
                for(ProductRequired p : prodRes) {
                    allProductRequired.put(p.Product2Id,p);
                }
            }
            if(Schema.sObjectType.XC_RequiredPosition__c.isCreateable() && !positionReq.isEmpty()){
                for(XC_RequiredPosition__c rpos : positionReq){
                    ProductRequired pr = allProductRequired.get(rpos.XC_ProductRequired__r.Product2Id);
                    rpos.XC_ProductRequired__c = pr != null ? pr.Id : null;
                }
                insert positionReq;
            }
            XC_UTIL_DML.updateRecords(positionReqToUpd);
        }catch (Exception e){
            System.debug( '@@@@ generatePRFromTechCart - Generic Error: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
            rAndM.resultMessage = 'Add order material failed!!!: ' + e.getMessage();
            rAndM.success = false;
            rAndM.typeMessage ='Error';
        }

        return rAndM;
    }

    /**
      * @author Patrizia Arcidiacono/2019
      * @description Load map with price manually inserted
      * @param items List<Object>
      * @param priCo String
      * @return Map<Id, Product2>
      */
    public static Map<Id, Product2> loadMap (List<Object> items,string priCo){
        Set<Id> product2Ids = new Set<Id>();
        for(Object item : items){
            String conv = String.valueOf(item);
            List<String> prodId = conv.split('-');
            product2Ids.add(prodId[0]);

        }

        Map<Id, Product2> productsMap = new Map<Id, Product2> (
        [SELECT Id,
                Name,
                ProductCode,
                XC_SapType__c,
                XC_Type__c,
                XC_Price__c,
                Family,
                XC_Country__c,
                Description,
        (
                SELECT Id,
                        UnitPrice
                FROM PricebookEntries
                WHERE Pricebook2Id  =: priCo
                LIMIT 1
        )
        FROM Product2
        WHERE Id =: product2Ids
        ]);

        return productsMap;

    }

    /**
      * @author Patrizia Arcidiacono/2019
      * @description Retrieve List commercial item decomposition WO
      * @param woliId String
      * @return  List<NE__OrderItem__c>
      */
    public static List<NE__OrderItem__c> getListCommercialOrderItem (string woliId){

        List<NE__OrderItem__c> listOI = new List<NE__OrderItem__c>();

        return listOI;
    }

    //

    /**
     * @author Patrizia Arcidiacono/2019 - Monica Cutillo/2020
     * @description set Order Attribute to insert
     * @param proNameMap Map<String, NE__ProductFamilyProperty__c>
     * @param item NE__OrderItem__c
     * @param prodWr Product2ContactLineItemWrapper
     * @return List<NE__Order_Item_Attribute__c>
     */
    /*private static List<NE__Order_Item_Attribute__c> setOrderAttr (Map<String, NE__ProductFamilyProperty__c> proNameMap, NE__OrderItem__c item, XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper prodWr){
        List<NE__Order_Item_Attribute__c> orderItemAttrToInsert = new List<NE__Order_Item_Attribute__c>();
        NE__Order_Item_Attribute__c tmpOrdItemAttr;
        for(NE__ProductFamilyProperty__c tmpProdFamProp : proNameMap.values()){

            tmpOrdItemAttr = new NE__Order_Item_Attribute__c();
            tmpOrdItemAttr.Name = tmpProdFamProp.NE__PropId__r.Name;
            //tmpOrdItemAttr.NE__Value__c = 'Material'.equals(tmpProdFamProp.NE__PropId__r.Name) ? tmpProduct2.Name : tmpProduct2.XC_Type__c;
            tmpOrdItemAttr.NE__Value__c = 'Material'.equals(tmpProdFamProp.NE__PropId__r.Name) ? prodWr.name : prodWr.type;
            tmpOrdItemAttr.NE__Order_Item__c = item.Id;
            tmpOrdItemAttr.NE__FamPropExtId__c = tmpProdFamProp.NE__FamilyPropertyCode__c;
            tmpOrdItemAttr.NE__FamPropId__c =  tmpProdFamProp.Id;
            orderItemAttrToInsert.add(tmpOrdItemAttr);
        }
        return orderItemAttrToInsert;
    }*/

    /**
     * @author Patrizia Arcidiacono/2019
     * @description Load map with price manually inserted
     * @param proNameMap Map<String, NE__ProductFamilyProperty__c>
     * @param tmpProduct2 Product2
     * @param item NE__OrderItem__c
     * @return List<NE__Order_Item_Attribute__c>
     */
    /*private static List<NE__Order_Item_Attribute__c> setOrderAttr (Map<String, NE__ProductFamilyProperty__c> proNameMap, Product2 tmpProduct2, NE__OrderItem__c item){
      List<NE__Order_Item_Attribute__c> orderItemAttrToInsert = new List<NE__Order_Item_Attribute__c>();
      for(String propId : proNameMap.keySet()){
                    NE__ProductFamilyProperty__c tmpProdFamProp = proNameMap.get(propId);
                    NE__Order_Item_Attribute__c tmpOrdItemAttr = new NE__Order_Item_Attribute__c();
                    tmpOrdItemAttr.Name = tmpProdFamProp.NE__PropId__r.Name;
                    tmpOrdItemAttr.NE__Value__c = 'Material'.equals(tmpProdFamProp.NE__PropId__r.Name) ? tmpProduct2.Name : tmpProduct2.XC_Type__c;
                    tmpOrdItemAttr.NE__Order_Item__c = item.Id;
                    tmpOrdItemAttr.NE__FamPropExtId__c = tmpProdFamProp.NE__FamilyPropertyCode__c;
                    tmpOrdItemAttr.NE__FamPropId__c =  tmpProdFamProp.Id;
                    orderItemAttrToInsert.add(tmpOrdItemAttr);
      }
      return orderItemAttrToInsert;
    }*/

    /**
     * @author Patrizia Arcidiacono/2019
     * @description Load map with price manually inserted
     * @param prod2ListWrapper List<.XC_LCC195_AddTechnicalItems>
     * @param products List<Product2>
     * @param contractId String
     * @return List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper>
     */
    public static List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> loadWrapperClass (List<XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper> prod2ListWrapper,List<Product2> products, string contractId){
        system.debug('@@@@ loadWrapperClass - products:' + products);
        if(!products.isEmpty()){
            for(Product2 item : products){
                XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper prod2Wrapper = new XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper();
                prod2Wrapper.Id = item.Id;
                prod2Wrapper.Name = item.Name;
                prod2Wrapper.ProductCode = item.ProductCode;
                prod2Wrapper.Type = item.XC_SapType__c;

                prod2Wrapper.prodPrice = !item.PriceBookEntries.isEmpty() ? string.valueOf(item.PriceBookEntries.get(0).UnitPrice) : null;
                prod2Wrapper.isoCode = !item.PriceBookEntries.isEmpty() ? item.PricebookEntries.get(0).CurrencyIsoCode : '';
                //prod2Wrapper.prodPrice = string.valueOf(item.Glovia_Price_Book_Entries__r.get(0).gii__UnitPrice__c);
                //prod2Wrapper.isoCode = !item.PriceBookEntries.isEmpty() ? item.Glovia_Price_Book_Entries__r.get(0).CurrencyIsoCode : '';

                prod2Wrapper.quantity = '0';
                prod2Wrapper.contractId = contractId;
                prod2ListWrapper.add(prod2Wrapper);
            }
        }
        system.debug('@@@@ loadWrapperClass - prod2ListWrapper:' + prod2ListWrapper);
        return prod2ListWrapper;

    }

    /**
   * @author B2Win -
   * @date Creation 22/06/2019
   * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
   * @description get manual value insert on technical cart
   * @param  manualValue String
   * @return double
   */
    public static double setCartManualValue(string manualValue){

        return manualValue!=null && manualValue !='' ? double.ValueOf(manualValue) : 0;
    }


    /**
    * @author B2Win -
    * @date Creation 22/06/2019
    * @date Modification 19/07/2019 Patrizia.Arcidiacono@nttdata.com
    * @description get manual value insert on technical cart
    * @param  wrParamCItem XC_LCC195_AddTechnicalItems.WrapperCallMethod
    * @param  tw XC_LCC195_AddTechnicalItems.listaParamWrapper
    * @return the XC_UTIL_ResultWrapper
    */
    public static XC_UTIL_ResultWrapper generatePCFromTechCart(XC_LCC195_AddTechnicalItems.WrapperCallMethod wrParamCItem,XC_LCC195_AddTechnicalItems.listaParamWrapper tw){
        //system.debug('@@@@ generatePCFromTechCart');
        XC_UTIL_ResultWrapper rAndM = new XC_UTIL_ResultWrapper();
        //XC_LCC195_AddTechnicalItems.ResultAndMessage rAndM = new XC_LCC195_AddTechnicalItems.ResultAndMessage();
        rAndM.titleMessage = 'Generate Material Consumed';
        rAndM.resultMessage = 'Material consumed created!!';
        rAndM.success = true;
        rAndM.typeMessage ='Success';
        string rTWoli = tw.rtWoli;
        system.debug('@@@@ generatePCFromTechCart - workorderId:' + tw.workOrderId);

        try{
            List<XC_ProductConsumed__c> prodCons = new List<XC_ProductConsumed__c>();
            List<ProductRequired> prodRes = new List<ProductRequired>();
            Double quantity=0;
            Double unitPriceManual=null;
            String productId ;
            List<String> vSplitPI = new List<String>();
            boolean toCreate = true; //[R2 CR704 09.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]

            Map<Id, Integer> numPR = getNumProductRequired(new List<String>{tw.woliId});
            Map<id,WorkOrderLineItem> goodsIssueWoli = new Map<id,WorkOrderLineItem>([select id,Status,workOrder.XC_Project_Task__r.XC_OrderItem__c,workOrder.RootWorkOrderId, XC_MaterialRequest__c, XC_PartnerEngagement__c,XC_PositionCode__c, //[R2 CR704 09.03.2022 sooraji.sajan@accenture.com/raffaele.sojka@accenture.com - Added the field XC_PositionCode__c]
			XC_Form_Type__c, Country, //[NR2357 - 28/02/2022 - DK - ET - Added the XC_Form_Type__c & Country in the query]																											  
            (select id, ProductRequiredNumber, Product2Id from Products_Required__r)
            from WorkOrderLineItem where id = :tw.woliId]);
            Map<id,WorkOrderLineItem> getMaterialSupplyByGoodsIssue = getMaterialSupplyByGoodsIssue(goodsIssueWoli.values());

            Map<String,XC_RequiredPosition__c> reqPositionByCondumed = getRequiredPositionsByConsumed(goodsIssueWoli.values());

            Map<Id,ProductRequired> prodReqByProd2 = new Map<Id,ProductRequired>();
            for(XC_LCC195_AddTechnicalItems.Product2ContactLineItemWrapper prod : wrParamCItem.selectedProduct) {
                quantity=0;
                /*Start R1-2022 NR2248 vaibhav.c.anand@accenture.com*/
                if (!wrParamCItem.parseJsonMP.isEmpty()) {
                    for (XC_JSON2Apex a : wrParamCItem.parseJsonMP) {
                        vSplitPI= a.glBookEntryId.split('-');
                        if(a.quantity == null)
                           quantity = XC_UTIL_TechnicalCart.setCartManualValue(prod.quantity.replace(',','.'));
                        if(prod.glBookEntryId == string.ValueOf(vSplitPI[0])){
                            unitPriceManual = XC_UTIL_TechnicalCart.setCartManualValue(a.prodPrice);
                            quantity = XC_UTIL_TechnicalCart.setCartManualValue(a.quantity.replace(',','.'));
                            productId = a.id;
                            system.debug('@@@@ generatePCFromTechCart - ciclo - quantity:' + quantity);
                            system.debug('@@@@ generatePCFromTechCart - ciclo - unitPriceManual:' + unitPriceManual);
                            break;
                        }

                    }
                }
                else{
                    quantity = XC_UTIL_TechnicalCart.setCartManualValue(prod.quantity.replace(',','.'));
                    System.debug('quantity§§ after'+quantity);
                }
                /*End R1-2022 NR2248 vaibhav.c.anand@accenture.com*/

                WorkOrderLineItem currentWoli = goodsIssueWoli.values()[0];
                Boolean isReturnMaterial = tw.rtWoli.contains('_ReturnMaterial');
                Boolean isPartnerPayment = tw.rtWoli.contains('PartnerPayment');
                Boolean isTransportRepair = tw.rtWoli.contains('MaterialTransportRepair');

                String recTypeNameStr = 'XC_'+tw.segment+'_'+tw.legalEntity+'_MaterialRequest';

                ProductRequired prodRe=new ProductRequired();
                prodRe.RecordTypeId = Schema.SObjectType.ProductRequired.getRecordTypeInfosByDeveloperName().get(recTypeNameStr).getRecordTypeId();
                if(quantity==null || quantity == 0){
                    quantity = 1;
                }
                //Product required are linked to material request or return material (currentWoli)
                workOrderLineItem matSupplyWOLI = isReturnMaterial || isPartnerPayment || isTransportRepair ? currentWoli : getMaterialSupplyByGoodsIssue.get(tw.woliId);
                if(matSupplyWOLI==null && !isPartnerPayment && !isTransportRepair)
                {
                    continue;
                }
                //[START R2 CR704 09.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
                if(currentWoli.XC_PositionCode__c != null){
                    if(!currentWoli.XC_PositionCode__c.equals(prod.positionName)){
                       toCreate = false;
                    }
                    if(!toCreate){
                        rAndM.Success = false;
                        rAndM.resultMessage = 'ErrorPosCode';
                        break;
                    }
                }
                //[END R2 CR704 09.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]


                ProductRequired existPR = null;

                for(ProductRequired pr : matSupplyWOLI.Products_Required__r){
                    if(pr.Product2Id == prod.idProduct){
                        existPR = pr;
                    }
                }

                if(existPR == null && !isPartnerPayment && !isTransportRepair) {
                    prodRe.ParentRecordId = matSupplyWOLI != null ? matSupplyWOLI.Id : null;//tw.woliId;
                    prodRe.XC_WorkOrderId__c = matSupplyWOLI != null ? matSupplyWOLI.workOrderId : null;//tw.workOrderId;
                    prodRe.XC_WorkOrderLineItem__c = matSupplyWOLI != null ? matSupplyWOLI.Id : null;//tw.woliId;
                    prodRe.Product2Id = prod.idProduct;//productId;

                    prodRe.XC_Quantity__c = quantity;
                    prodRe.QuantityRequired = quantity;
                    prodRe.XC_PriceUnits__c = unitPriceManual != null && unitPriceManual != 0 ? unitPriceManual : Double.valueOf(prod.prodPrice != null ? prod.prodPrice : '0');
                    prodRe.XC_OrderQuantity__c = quantity;
                    prodRe.XC_WBSElement__c = tw.wbeElement;
                    prodRe.XC_CostCenter__c = tw.costCenter;
                    if(matSupplyWOLI != null && matSupplyWOLI.Status == 'Completed') {
                        prodRe.XC_FromConsumed__c = true;
                    }
                    prodRe.XC_notplanned__c = true;
                    prodRe.XC_OrderItem__c= tw.ordItem != null ? tw.ordItem.Id : null;
                    if (numPR.containsKey(tw.woliId)) {
                        Integer n = numPR.get(tw.woliId);
                        prodRe.XC_PurchaseOderPositionOdA__c = String.valueOf((n + 1) * 10);
                        numPR.put(tw.woliId, n + 1);
                    } else {
                        Integer n = 0;
                        prodRe.XC_PurchaseOderPositionOdA__c = String.valueOf((n + 1) * 10);
                        numPR.put(tw.woliId, n + 1);
                    }

                    prodReqByProd2.put(prod.idProduct, prodRe);
                    prodRes.add(prodRe);
                }
                else{
                    prodReqByProd2.put(prod.idProduct, existPR);
                }

                //product
                //consumedQuantity
                //productConsumedID
                //*****TODO assignedSerials
                //productName
                //*****TODO pdtLotNumbers
                productId = productId == null ? prod.idProduct : productId;
                XC_ProductConsumed__c prodCo=new XC_ProductConsumed__c();
                prodCo.XC_WorkOrder__c  =tw.workOrderId;
                prodCo.XC_WorkOrderLineItem__c=tw.woliId;
                prodCo.XC_Product2Id__c =prod.idProduct;
                prodCo.XC_QuantityConsumed__c=quantity;
                prodCo.XC_WBE__c = tw.wbeElement;
                prodCo.XC_CostCenter__c = tw.costCenter;
                prodCo.XC_CategoryPosition__c = '9';
                prodCo.XC_AccountAssignmentCategory__c = 'P';
                prodCo.XC_notplanned__c = true;
                prodCo.XC_UnitPrice__c = unitPriceManual != null && unitPriceManual != 0 ? unitPriceManual : Double.valueOf(prod.prodPrice != null ? prod.prodPrice : '0');

                if(isPartnerPayment && reqPositionByCondumed.get(prod.idProduct+'§'+prod.positionName)!=null
                        && reqPositionByCondumed.get(prod.idProduct+'§'+prod.positionName).XC_POL_Position__c!= null
                        && reqPositionByCondumed.get(prod.idProduct+'§'+prod.positionName).XC_POPos__c != null){
                    prodCo.XC_POL_Position__c = Decimal.valueOf(reqPositionByCondumed.get(prod.idProduct+'§'+prod.positionName).XC_POL_Position__c);
                    prodCo.XC_POPos__c = Decimal.valueOf(reqPositionByCondumed.get(prod.idProduct+'§'+prod.positionName).XC_POPos__c);
                }

                prodCons.add(prodCo);


            }

            if(Schema.sObjectType.ProductRequired.isCreateable()){
                insert prodRes;

            }

            for(XC_ProductConsumed__c pc : prodCons){
                ProductRequired pr = prodReqByProd2.get(pc.XC_Product2Id__c);
                if(pr!=null){
                    pc.XC_ProductRequired__c = pr.Id;
                }
            }
            system.debug('@@@@ generatePRFromTechCart - prodCons:' + prodCons);

            //[START R2 CR704 END 09.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
            //if(Schema.sObjectType.XC_ProductConsumed__c.isCreateable()){
                if(Schema.sObjectType.XC_ProductConsumed__c.isCreateable() && toCreate ){
            //[END R2 CR704 END 09.03.2022 sooraji.sajan@accenture.com - raffaele.sojka@accenture.com]
	               //[Begin - NR2357 - 28/02/2022 - DK - ET - Create the FormCases records]
                //insert prodCons;
                List<XC_UTIL_Sobject.WrapperResult> insertProducts = XC_UTIL_DML.insertRecords(prodCons);
                XC_UTIL_Sobject.WrapperResult globalResProducts= XC_UTIL_Sobject.getGlobalDMLResults(insertProducts);
                rAndM.success = globalResProducts.success;
                XC_UTIL_Sobject.WrapperResult globalResForm = null;

                 if(rAndM.success && tw.rtWoli.contains('_ReturnMaterial')) {
                    String formType = goodsIssueWoli.values()[0].XC_Form_Type__c;
                    if(formType != null) {
                        List<XC_FormCase__c> formCasesToInsert = XC_UTIL_FormCase.createFormCasesFromProductsConsumed(insertProducts, goodsIssueWoli.values()[0]);
                        XC_TR_FormCase_Handler.bypassBeforeInsert = false;
                        List<XC_UTIL_Sobject.WrapperResult> insertFormCases = XC_UTIL_DML.insertRecords(formCasesToInsert);
                        globalResForm= XC_UTIL_Sobject.getGlobalDMLResults(insertFormCases);
                        rAndM.success = globalResForm.success;
                    }
                }
                    
                if(!rAndM.success) {
                    rAndM.resultMessage = globalResForm != null ? globalResForm.errorMessage : globalResProducts.errorMessage;
                    rAndM.success = false;
                    rAndM.typeMessage ='Error';
                    return rAndM;
                }
                //[End - NR2357 - 28/02/2022 - DK - ET - Create the FormCases records]


            }
        }catch (Exception e){
            System.debug( '@@@@ generatePRFromTechCart - Generic Error: '+e.getMessage()+' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
            rAndM.resultMessage = 'Add order consumed failed!!!: ' + e.getMessage();
            rAndM.success = false;
            rAndM.typeMessage ='Error';
        }

        return rAndM;
    }

    private static Map<id,WorkOrderLineItem> getMaterialSupplyByGoodsIssue(List<WorkOrderLineItem> goodsIssueWoli){
        List<String> woList = new List<String>(); //XC_UTIL_Sobject.getListFieldValues(goodsIssueWoli,'workOrderId');
        List<String> woliDirectLookupList = new List<String>();
        for(WorkOrderLineItem woli : goodsIssueWoli){
            woList.add(woli.workOrder.RootWorkOrderId);
            woliDirectLookupList.add(woli.XC_MaterialRequest__c);
        }
        Map<id,WorkOrderLineItem> retMap = new Map<id,WorkOrderLineItem>();
        Map<id,WorkOrderLineItem> matReqMap = new Map<id,WorkOrderLineItem>(
        [select id,Status,XC_Project_Task__c, XC_Project_Task__r.XC_OrderItem__c,WorkOrder.WorkOrderNumber, workOrderId,LineItemNumber,
        (select id, ProductRequiredNumber, Product2Id from Products_Required__r)
        from WorkOrderLineItem where id in :woliDirectLookupList or (workOrderId in :woList and RecordType.developername like '%_MR_WOLI')]
        );
        //workOrder.XC_Project_Task__c, workOrder.XC_Project_Task__r.XC_OrderItem__c
        for(WorkOrderLineItem gi : goodsIssueWoli){
            for(WorkOrderLineItem mr : matReqMap.values()){
                if((mr.XC_Project_Task__r.XC_OrderItem__c == null && gi.workOrder.RootWorkOrderId == mr.workOrderId) ||
                        (mr.XC_Project_Task__r.XC_OrderItem__c != null && gi.workOrder.XC_Project_Task__r.XC_OrderItem__c == mr.XC_Project_Task__r.XC_OrderItem__c)){
                    retMap.put(gi.Id,mr); //key goodsIssue - value material supply
                }
                if(gi.XC_MaterialRequest__c == mr.Id){
                    retMap.put(gi.Id,mr);
                    break;
                }
            }
        }
        return retMap;
    }

    private static Map<String,XC_RequiredPosition__c> getRequiredPositionsByConsumed(List<WorkOrderLineItem> goodsIssueWoli){

        List<String> woList = new List<String>(); //XC_UTIL_Sobject.getListFieldValues(goodsIssueWoli,'workOrderId');
        List<String> woliDirectLookupList = new List<String>();
        for(WorkOrderLineItem woli : goodsIssueWoli){
            woList.add(woli.workOrder.RootWorkOrderId);
            woliDirectLookupList.add(woli.XC_PartnerEngagement__c);
        }
        Map<String,XC_RequiredPosition__c> retMap = new Map<String,XC_RequiredPosition__c>();
        Map<id,WorkOrderLineItem> matReqMap = new Map<id,WorkOrderLineItem>(
        [select id,XC_Project_Task__c, XC_Project_Task__r.XC_OrderItem__c,WorkOrder.WorkOrderNumber, workOrderId,LineItemNumber,
        (Select id, XC_ProductRequired__r.Product2Id,XC_POL_Position__c,XC_POPos__c, XC_PositionCode__c from Required_Positions__r)
        from WorkOrderLineItem where id in :woliDirectLookupList or (workOrderId in :woList and RecordType.developername like '%_PE_WOLI')]
        );
        //workOrder.XC_Project_Task__c, workOrder.XC_Project_Task__r.XC_OrderItem__c

        for(WorkOrderLineItem mr : matReqMap.values()){
            for(XC_RequiredPosition__c rp : mr.Required_Positions__r){
                retMap.put(rp.XC_ProductRequired__r.Product2Id+'§'+rp.XC_PositionCode__c, rp);
            }
        }

        return retMap;
    }

}