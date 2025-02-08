/**
 *
 * @author :              Nicola Mariniello nmariniello@deloitte.it - Luisana Rocco lrocco@deloitte.it
 * @date Creation :       26/04/2019
 * @date Modification :   dd/mm/yyyy
 * @description :         XC_REST_Order_V – Util for Rest Resourse to  Create/Update/Read an Order/Order Item/Order Item Attribute
 * 
 */

public without sharing  class XC_REST_Order_V {

    /**
    * @param toInsert - List<NE__Order__c>
    * @param wr - WrapperRes
    * @description manage OrderInsert and populate the response
    */
    public static void insertOrderAndPopulateResponse(List<NE__Order__c> toInsert, XC_REST_Order_U.WrapperRes wr){
        if(!toInsert.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> insertedOrders = XC_UTIL_SObject.insertListRecords(toInsert);
            for(XC_UTIL_Sobject.WrapperResult insertResult : insertedOrders){
                if(!insertResult.success){
                    wr.Result.ErrorCode = '500';
                    wr.Result.Message = 'INTERNAL ERROR';
                    wr.Result.logError = 'INTERNAL ERROR ' + insertResult.errorMessage;
                    return;
                }
            }
            wr.Order = new XC_UTIL_Order.OrderIFWrapper();
        }
    }


    /**
    * @param mapUtil - Map<String,Object>
    * @description manage Order Item
    */
    public static void manageOrderItem(Map<String,Object> mapUtil){

        List<NE__OrderItem__c> parentOrderItemtoInsert = (List<NE__OrderItem__c>) mapUtil.get('parentOrderItemtoInsert');
        Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c> mapOIWrOI = (Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c>) mapUtil.get('mapOIWrOI');
        Map<List<XC_UTIL_Order.WrapperAttribute>, NE__OrderItem__c> mapOIAOrdItem = (Map<List<XC_UTIL_Order.WrapperAttribute>, NE__OrderItem__c>) mapUtil.get('mapOIAOrdItem');
        XC_UTIL_Order.OrderIFWrapper orderReq = (XC_UTIL_Order.OrderIFWrapper) mapUtil.get('orderReq');
        System.debug('@@@@Order REquest : '+orderReq);
        String orderId = (String) mapUtil.get('orderId');
        Map<Id,NE__Billing_Profile__c> bpMap = (Map<Id,NE__Billing_Profile__c>)mapUtil.get('bpMap');
        List<NE__OrderItem__c> ordItemToInsertList = new List<NE__OrderItem__c>();
        Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c> mapOIWrOIChild = new Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c> ();

        Map<String,String> prodFromCommodity = new Map<String,String>{
            'OKGAS'=>'OKGas',
            'OKBAS'=>'OKGas Basic',
            'OKCLT'=>'OKGas Calentador',
            'OKLBS'=>'OKLuz Assist',
            'OKLBA'=>'OKLuz Basic',
            'OKLCO'=>'OKLuz Confort',
            'OKNG2'=>'OKLuz Negocios 2019',
            'OKNA2'=>'OKLuz Negocios Aire 2019',
            'OKNGB'=>'OKLuz Negocios Basic',
            'SPPW3'=>'SPPW3-SEGURO PROTECCIÓN PAGOS',
            'AAON2'=>'AAON2-PRIMA SEGURO PROTECCIÓN PAGOS'
        };

        Map<String,NE__Catalog_Item__c> prodInfo = getProdInfoForCommodity(prodFromCommodity, orderReq);
        Map<String,NE__Catalog_Item__c> prodInfoByEngineCode = getProdInfoByEngineCode(orderReq);
        Map<Id,NE__Catalog_Item__c> prodInfoByCatalog = getProdInfoByCatalog(orderReq);
        Map<Id,BillingItemCreationWrapper> bpCreationMap = new Map<Id,BillingItemCreationWrapper>();

        for(XC_UTIL_Order.OrderItemWrapper orderItem : orderReq.OrderItem){ 
            NE__OrderItem__c ordItemToInsert = XC_UTIL_Order.createOrderItemFromOrder(orderReq.AccountID, orderId, orderItem);

            if(orderItem.OrderItemDiscount != null) {
                Decimal sequenceOneTime = 0;
                Decimal sequenceRecurring = 0;          
                for(XC_UTIL_Order.WrapperDiscount d : orderItem.OrderItemDiscount) {
                    /*
                    //if(d.Status != null && d.Status.equalsIgnoreCase('Active') && d.StartDate != null && d.StartDate <= Date.Today() && (d.EndDate == null || (d.EndDate != null && d.EndDate >= Date.Today()))) {
                    if(d.Status != null && d.Status.equalsIgnoreCase('Active') && d.StartDate != null && d.StartDate <= DateTime.Now().dateGMT() && (d.EndDate == null || (d.EndDate != null && d.EndDate >= DateTime.Now().dateGMT()))) {
                        if(d.OneTimeValue > 0 && d.Sequence > sequenceOneTime){
                            ordItemToInsert.NE__OneTimeFeeOv__c = d.OneTimePrice;
                            sequenceOneTime = d.Sequence;
                            continue;
                        }
                        if(d.RecurringValue > 0 && d.Sequence > sequenceRecurring){
                            ordItemToInsert.NE__RecurringChargeOv__c = d.RecurringPrice;
                            sequenceRecurring = d.Sequence;
                        }     
                    }*/

                    if(d.Status != null && d.Status.equalsIgnoreCase('Active')){ 
                        if(d.OneTimeValue > 0 && d.Sequence > sequenceOneTime){
                            ordItemToInsert.NE__OneTimeFeeOv__c = d.OneTimePrice;
                            sequenceOneTime = d.Sequence;
                            continue;
                        }
                        if(d.RecurringValue > 0 && d.StartDate != null && d.StartDate <= DateTime.Now().dateGMT() && (d.EndDate == null || (d.EndDate != null && d.EndDate >= DateTime.Now().dateGMT()))){
                            if(d.Sequence > sequenceRecurring){
                                ordItemToInsert.NE__RecurringChargeOv__c = d.RecurringPrice;
                                sequenceRecurring = d.Sequence;
                            }  
                        }
                    }
                    
                }
            }

            if(prodInfo.get(orderItem.ProdID)!=null){
                ordItemToInsert.NE__ProdId__c = prodInfo.get(orderItem.ProdID).NE__ProductId__c;
                ordItemToInsert.NE__CatalogItem__c = prodInfo.get(orderItem.ProdID).Id; 
                ordItemToInsert.NE__Catalog__c = prodInfo.get(orderItem.ProdID).NE__Catalog_Id__c; 
            }

            if(prodInfoByEngineCode.get(orderItem.ProdID)!=null){
                ordItemToInsert.NE__ProdId__c = prodInfoByEngineCode.get(orderItem.ProdID).NE__ProductId__c;
                ordItemToInsert.NE__CatalogItem__c = prodInfoByEngineCode.get(orderItem.ProdID).Id;
                ordItemToInsert.NE__Catalog__c = prodInfoByEngineCode.get(orderItem.ProdID).NE__Catalog_Id__c;
            }

            if(String.isBlank(ordItemToInsert.XC_Product_Type__c)||String.isBlank(ordItemToInsert.XC_Product_Subtype__c)){
                ordItemToInsert.XC_Product_Type__c = prodInfoByCatalog.get(ordItemToInsert.NE__CatalogItem__c).NE__ProductId__r.XC_Product_Type__c;
                ordItemToInsert.XC_Product_Subtype__c = prodInfoByCatalog.get(ordItemToInsert.NE__CatalogItem__c).NE__ProductId__r.XC_Product_Subtype__c;
                ordItemToInsert.NE__Catalog__c = prodInfoByCatalog.get(ordItemToInsert.NE__CatalogItem__c).NE__Catalog_Id__c;
            }

            ordItemToInsert.NE__Billing_Account__c = orderReq.AccountID;
            ordItemToInsert.NE__Service_Account__c = orderReq.AccountID;

            if(!String.isblank(orderItem.BillingProfileID) &&bpMap.get(orderItem.BillingProfileID)!=null){
                ordItemToInsert.NE__BillingProfId__c = orderItem.BillingProfileID;
                ordItemToInsert.XC_PaymentMethod__c = bpMap.get(orderItem.BillingProfileID).NE__Payment__c;
                ordItemToInsert.XC_CongaDynamicAPI__c = 'Yes'; // for congaWF
                boolean founbbpli = false;

                for(XC_BillingProfileLineItem__c bpli:bpMap.get(orderItem.BillingProfileID).Billing_Profile_Line_Items__r){
                    if(!String.isBlank(orderReq.BillingAddress)&&!String.isBlank(orderReq.InstallationAddress)&&bpli.XC_BillToAddress__c==orderReq.BillingAddress&&bpli.XC_SoldToAddress__c==orderReq.InstallationAddress){
                        ordItemToInsert.XC_BillingProfileLineItem__c = bpli.id;
                        system.debug('bpli.id: '+bpli.id);
                        founbbpli = true;
                        break;

                    } else if(!String.isBlank(orderReq.BillingAddress)&&!String.isBlank(orderReq.InstallationAddress)){
                        continue;

                    } else {
                        ordItemToInsert.XC_BillingProfileLineItem__c = bpMap.get(orderItem.BillingProfileID).Billing_Profile_Line_Items__r[0].Id;
                        system.debug('ordItemToInsert.XC_BillingProfileLineItem__c: '+ordItemToInsert.XC_BillingProfileLineItem__c);
                        founbbpli = true;
                        break;
                    }
                }

                if(!founbbpli){
                    BillingItemCreationWrapper bw = new BillingItemCreationWrapper();
                    bw.billingProfile = bpMap.get(orderItem.BillingProfileID);
                    bw.billingAddress = orderReq.BillingAddress;
                    bw.soldToAddress = orderReq.InstallationAddress;
                    bw.legalEntity = orderReq.legalEntity;
                    bw.recipientCode = bpMap.get(orderItem.BillingProfileID).Billing_Profile_Line_Items__r[0].XC_RecipientCode__c;
                    bw.pec = bpMap.get(orderItem.BillingProfileID).Billing_Profile_Line_Items__r[0].XC_PEC__c;
                    bw.invoicePreferredLanguage = bpMap.get(orderItem.BillingProfileID).XC_InvoicePreferredLanguage__c;
                    bw.invoiceDeliveryPref = (!String.isBlank(bpMap.get(orderItem.BillingProfileID).XC_InvoiceDeliveryPref__c) && bpMap.get(orderItem.BillingProfileID).XC_InvoiceDeliveryPref__c.containsIgnoreCase('Smart')) ? Label.XC_CL_BpliInvoiceDeliveryPref : bpMap.get(orderItem.BillingProfileID).XC_InvoiceDeliveryPref__c;
                    bpCreationMap.put(orderItem.BillingProfileID, bw);
                    system.debug('bw: '+bw);
                }                  

            }
            //[START, gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187] -->
            if(!string.isBlank(orderItem.InstallmentsNumber))
            {
                ordItemToInsert.XC_InstallmentsNumber__c=orderItem.InstallmentsNumber;
            }
            if(!string.isBlank(orderItem.InstallmentPlanType))
            {
                ordItemToInsert.XC_InstallmentPlanType__c=orderItem.InstallmentPlanType;
            }
            if(!string.isBlank(orderItem.InstallmentFrequency))
            {
                ordItemToInsert.XC_InstallmentFrequency__c=orderItem.InstallmentFrequency;
            }
            //[END, gaurav.tejpal@accenture.com, 04/05/2022,Enel X - NR2187] -->
            ordItemToInsert.NE__Item_Code__c = orderItem.ItemCode;
            ordItemToInsert.XC_RelatedProduct__c = orderItem.RelatedProduct;
            ordItemToInsert.NE__Action__c = 'Add';
            ordItemToInsert.CurrencyIsoCode = (String) mapUtil.get('currencyValue');
            ordItemToInsertList.add(ordItemToInsert);
            MapOIWrOI.put(orderItem, ordItemToInsert); 
            String parentOrderItem = XC_REST_Order_V.checkParentOrderItem(orderItem, parentOrderItemtoInsert, ordItemToInsert);
            if(!String.isBlank(parentOrderItem)){
                mapOIWrOIChild.put(orderItem, ordItemToInsert);
            }
            
            if(orderItem.Attribute != null){
                mapOIAOrdItem.put(orderItem.Attribute, ordItemToInsert); 
            }
        }

        mapUtil.put('mapOIWrOIChild', mapOIWrOIChild);


        if(!bpCreationMap.values().isEmpty()){
            Map<Id,XC_BillingProfileLineItem__c> bpliMap = createBPLI(bpCreationMap); 
            Map<Id,Account> accMap = getAccountInfo(bpMap.values());
            Set<Id> bpliToSend = new Set<Id>();

            for(NE__OrderItem__c orderItem : ordItemToInsertList){ 
                if(bpCreationMap.get(orderItem.NE__BillingProfId__c)!=null&&String.isBlank(orderItem.XC_BillingProfileLineItem__c)){
                    orderItem.XC_BillingProfileLineItem__c = bpliMap.get(orderItem.NE__BillingProfId__c).id;
                    bpliToSend.add(orderItem.NE__BillingProfId__c);
                }
            }
            for(Id bp : bpliToSend){
                sendBPLI(bpMap.get(bp),accMap.get(bp),bpliMap.get(bp));
            }
        }

        XC_TR_ConfigurationItem_U_BillingModel.populateDefaultBillingModel(ordItemToInsertList);
        
    }


    /**
    * @param orderItem - XC_UTIL_Order.OrderItemWrapper
    * @param parentOrderItemtoInsert - List<NE__OrderItem__c>
    * @param ordItemToInsert - NE__OrderItem__c 
    * @return parentOrderItem - String
    * @description  check the parent orderItem
    */
    public static String checkParentOrderItem(XC_UTIL_Order.OrderItemWrapper orderItem, List<NE__OrderItem__c> parentOrderItemtoInsert, NE__OrderItem__c ordItemToInsert){
        
        String parentOrderItem;
        if(!String.isBlank(orderItem.ParentOrderItem)){
            parentOrderItem = orderItem.ParentOrderItem;
        }else if(!String.isBlank(orderItem.BundleConfiguration)){
            parentOrderItem = orderItem.BundleConfiguration;
        }else{
            parentOrderItemtoInsert.add(ordItemToInsert);
        }
        return parentOrderItem; 
    }


    /**
    * @param orderItemAttrList the order item attr list
    * @return the map  
    * @description  populate Map with OrderItemAttribute Id as key and OrderItemAttribute as value
    */
    public static Map<String, NE__Order_Item_Attribute__c> populateMapIdOrdItemAttr(List<NE__Order_Item_Attribute__c> orderItemAttrList){

        Map<String, NE__Order_Item_Attribute__c> mapIdordItemAttr = new Map<String, NE__Order_Item_Attribute__c>();
        if(!orderItemAttrList.isEmpty()){
            for(NE__Order_Item_Attribute__c oiAttr: orderItemAttrList){
                mapIdordItemAttr.put(OIAttr.Id, OIAttr);
            }
        }
        return mapIdordItemAttr;
    }

 
    /**
    * @description Populate map id ord item
    * @param orderItemList the order item  list
    * @return the map with order item id as key and order item as value
    */
    public static Map<String, NE__OrderItem__c> populateMapIdOrdItem(List<NE__OrderItem__c> orderItemList){

        Map<String, NE__OrderItem__c> mapIdordItem = new Map<String, NE__OrderItem__c>();
        if(!orderItemList.isEmpty()){
            for(NE__OrderItem__c ordItem: orderItemList){
                mapIdordItem.put(ordItem.id, ordItem);
            }
        }
        return mapIdordItem;
    }

 
    /**
    * @param utilMap - Map<String, Object>
    * @description manage ParentOrderItem
    * @return the map with order item as key and order item cloned as value 
    */
    public static void manageParentOrderItem(Map<String, Object> utilMap){

        Map<String, NE__OrderItem__c>  mapIdordItem = (Map<String, NE__OrderItem__c> ) utilMap.get('mapIdordItem');
        List<NE__OrderItem__c>  parentOrderItemtoInsert = (List<NE__OrderItem__c>) utilMap.get('parentOrderItemtoInsert');
        NE__Order__c order = (NE__Order__c) utilMap.get('order');
        XC_REST_Order_U.WrapperRes wr = (XC_REST_Order_U.WrapperRes) utilMap.get('wr');
        Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c> mapOIWrOIChild = (Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c>)utilMap.get('mapOIWrOIChild');

        List<NE__OrderItem__c> allItemToIsert = new List<NE__OrderItem__c>();
        allItemToIsert.addall(parentOrderItemtoInsert);
        if(mapOIWrOIChild != null && !mapOIWrOIChild.isEmpty()){
            allItemToIsert.addall(mapOIWrOIChild.values());
        }

        if(!allItemToIsert.isEmpty()){
            //insertedOrderItems.addall(XC_UTIL_SObject.insertListRecords(parentOrderItemtoInsert));
            List<XC_UTIL_Sobject.WrapperResult> insertedOrderItems = XC_UTIL_SObject.insertListRecords(allItemToIsert);
            for(XC_UTIL_Sobject.WrapperResult insertResult : insertedOrderItems){
                if(!insertResult.success){
                    wr.Result.ErrorCode = '500';
                    wr.Result.Message = 'INTERNAL ERROR';
                    wr.Result.logError = 'INTERNAL ERROR ' + insertResult.errorMessage;
                    return;
                }
            }

            mapIdordItem.putAll(XC_REST_Order_V.populateMapIdOrdItem(allItemToIsert));
           
        }
    }


    /**
    * @param ordItemToInsert - List<NE__OrderItem__c>
    * @param mapIdordItem - Map<String, NE__OrderItem__c>
    * @param wr - XC_REST_Order_U.WrapperRes
    * @description update orderItem
    */
    public static void updateOrderItem(List<NE__OrderItem__c> ordItemToUpdate,  Map<String, NE__OrderItem__c> mapIdordItem, XC_REST_Order_U.WrapperRes wr){
        if(!ordItemToUpdate.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> updatedOrderItems = XC_UTIL_SObject.updateListRecords(ordItemToUpdate);
            for(XC_UTIL_Sobject.WrapperResult updateResult : updatedOrderItems){
                if(!updateResult.success){
                    wr.Result.ErrorCode = '500';
                    wr.Result.Message = 'INTERNAL ERROR';
                    wr.Result.logError = 'INTERNAL ERROR ' + updateResult.errorMessage;
                    return;
                }
            }
            for(NE__OrderItem__c ordItem: ordItemToUpdate){
                mapIdordItem.put(ordItem.id, ordItem);
            }
        }
    }
    

    /**
    * @description Gets the order item children.
    * @param utilMap - Map<String,Object>
    * @return the map
    */
    public static void getOrderItemChild(Map<String,Object> utilMap){
        
        Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c> mapOIWrOIChild = (Map<XC_UTIL_Order.OrderItemWrapper, NE__OrderItem__c>) utilMap.get('mapOIWrOIChild');
        List<NE__OrderItem__c>  ordItemToInsert =  (List<NE__OrderItem__c>) utilMap.get('ordItemToInsert');
        List<NE__OrderItem__c>  parentOrderItemtoInsert = (List<NE__OrderItem__c>) utilMap.get('parentOrderItemtoInsert');

        
        Map<String, id> itemCodeParentId = new Map<String, id>();
        for(NE__OrderItem__c ordItemFather : parentOrderItemtoInsert){
            itemCodeParentId.put(ordItemFather.NE__Item_Code__c, ordItemFather.Id);
        }
        

        if(!itemCodeParentId.isEmpty()){
            for(XC_UTIL_Order.OrderItemWrapper ordItem : mapOIWrOIChild.keySet()){
                if(!String.isBlank(ordItem.ParentOrderItem)){
                    mapOIWrOIChild.get(ordItem).NE__Root_Order_Item__c = itemCodeParentId.get(ordItem.ParentOrderItem);
                    mapOIWrOIChild.get(ordItem).NE__Parent_Order_Item__c =  itemCodeParentId.get(ordItem.ParentOrderItem);
                    ordItemToInsert.add(mapOIWrOIChild.get(ordItem));
                } 
                if(!String.isBlank(ordItem.BundleConfiguration)){
                    mapOIWrOIChild.get(ordItem).NE__Bundle_Configuration__c =  itemCodeParentId.get(ordItem.BundleConfiguration);
                    ordItemToInsert.add(mapOIWrOIChild.get(ordItem));
                }
            }        
        }


        //Set<String> parentOrderItemCode = (Set<String>) utilMap.get('parentOrderItem');
        /*List<String> keys = ParentOrderItem.split('-');
        String prodId = keys.get(0);
        String catalogItemId = keys.get(1);
        String quantity = keys.get(2);

        utilMap.put('prodId', prodId);
        utilMap.put('catalogItemId', catalogItemId);
        utilMap.put('quantity', quantity);
        
    
        String ordid;  
        for(XC_UTIL_Order.OrderItemWrapper ordItem : MapOIWrOI.keySet()){
            if(ordItem.ProdId == prodId && ordItem.CatalogItemID == catalogItemId && String.valueOf(ordItem.Quantity) == quantity){
                ordid = MapOIWrOI.get(ordItem).Id; 
                break;
            }
        }

        if(!String.isBlank(ordid)){
            for(XC_UTIL_Order.OrderItemWrapper ordItem : MapOIWrOI.keySet()){
                if(!String.isBlank(ordItem.ParentOrderItem)){
                    MapOIWrOI.get(ordItem).NE__Root_Order_Item__c = ordid;
                    MapOIWrOI.get(ordItem).NE__Parent_Order_Item__c = ordid;
                    ordItemToInsert.add(MapOIWrOI.get(ordItem));
                } 
                if(!String.isBlank(ordItem.BundleConfiguration)){
                    MapOIWrOI.get(ordItem).NE__Bundle_Configuration__c = ordid;
                    ordItemToInsert.add(MapOIWrOI.get(ordItem));
                }
            }        
        }
        
        */
    }


    private static Map<String,NE__Catalog_Item__c> getProdInfoForCommodity(Map<String,String> prodFromCommodity, XC_UTIL_Order.OrderIFWrapper req){
        Map<String,NE__Catalog_Item__c> result = new Map<String,NE__Catalog_Item__c>();

        list<String> prodToQuery = new list<String>();
        for(XC_UTIL_Order.OrderItemWrapper oi : req.OrderItem){
            if(prodFromCommodity.get(oi.ProdID)!=null){
                prodToQuery.add(prodFromCommodity.get(oi.ProdID));
            }
        }

        if(prodToQuery.isEmpty()){
            return result;
        }

        Map<Id,NE__Catalog_Item__c> mapRes = new Map<Id,NE__Catalog_Item__c>([
            SELECT NE__Product_Name__c, NE__Type__c, NE__ProductId__c, NE__Catalog_Id__c FROM NE__Catalog_Item__c WHERE NE__Catalog_Id__r.XC_LIC_Name__c='eHome - ES' AND NE__Type__c='Product' AND NE__Product_Name__c in: prodToQuery
        ]);

        for(NE__Catalog_Item__c ci : mapRes.values()){
            for(String s : prodFromCommodity.keySet()){
                if(prodFromCommodity.get(s)==ci.NE__Product_Name__c){
                    result.put(s, ci);
                }
            } 
        }

        return result;
    }


    private static Map<String,NE__Catalog_Item__c> getProdInfoByEngineCode(XC_UTIL_Order.OrderIFWrapper req){
        Map<String,NE__Catalog_Item__c> result = new Map<String,NE__Catalog_Item__c>();

        list<String> prodToQuery = new list<String>();
        for(XC_UTIL_Order.OrderItemWrapper oi : req.OrderItem){
            if(((Id)oi.ProdID).getSObjectType().getDescribe().getName()!='NE__Product__c'){
                prodToQuery.add(oi.ProdID);
            }
        }

        if(prodToQuery.isEmpty()){
            return result;
        }

        Map<Id,NE__Catalog_Item__c> mapRes = new Map<Id,NE__Catalog_Item__c>([
            SELECT NE__Product_Name__c, NE__Engine_Code__c, NE__Type__c, NE__ProductId__c, NE__Catalog_Id__c FROM NE__Catalog_Item__c WHERE NE__Engine_Code__c in: prodToQuery
        ]);

        for(NE__Catalog_Item__c ci : mapRes.values()){
            result.put(ci.NE__Engine_Code__c, ci);
        }
        
        return result;
    }     

    private static Map<Id,NE__Catalog_Item__c> getProdInfoByCatalog(XC_UTIL_Order.OrderIFWrapper req){
        Map<Id,NE__Catalog_Item__c> catmap = new Map<Id,NE__Catalog_Item__c>();

        List<String> cat = new List<String>();
        for(XC_UTIL_Order.OrderItemWrapper oiwr:req.OrderItem){
            if(String.isBlank(oiwr.OrderItemType)||String.isBlank(oiwr.OrderItemSubType)){
                cat.add(oiwr.CatalogItemID);
            }
        }

        if(cat.isEmpty()){
            return catmap;
        }

        catmap = new Map<Id,NE__Catalog_Item__c>([
            SELECT NE__Product_Name__c, NE__Engine_Code__c, NE__Type__c, NE__ProductId__r.XC_Product_Type__c, NE__ProductId__r.XC_Product_Subtype__c, NE__Catalog_Id__c
            FROM NE__Catalog_Item__c WHERE id in: cat
        ]);

        return catmap;
    }

    /**
    * @description getAccountInfo
    * @param billingProfiles - billingProfiles
    * @return the account
    * @author Simone Trenta - strenta@deloitte.it 
    */
    public static Map<Id,Account> getAccountInfo(List<NE__Billing_Profile__c> billingProfiles){
        Map<Id,Account> res = new Map<Id,Account>();

        List<String> bpId = new List<String>();
        List<String> accId = new List<String>();
        for(NE__Billing_Profile__c bp:billingProfiles){
            bpId.add(bp.id);
            accId.add(bp.NE__Account__c);
        }

        Map<Id, Account> mapAcc = new Map<Id,Account>([
            SELECT Id, XC_isGuestUser__c, PrimaryEmail__c, XC_AccountType__c , XC_DocumentCountry__c, XC_NIE_expedition_date__c, XC_NIE_expiration_date__c, XC_Segment__c, XC_GIRO__c, XC_VatGroupType__c, XC_CompanyFiscalCode__c,
            IdentityNumber__c, IdentityType__c, Country__c,  XC_RecordTypePick__c, XC_FirstName__c, XC_LastName__c, Name, XC_SplitPayment__c, XC_RecordTypeDeveloperName__c, XC_Country__c,
            (SELECT Id, XC_ExpirationDate__c, XC_DocumentType__c, XC_DocumentNumber__c, XC_ReleaseDate__c, XC_Country__c  FROM Personal_Documents__r  ORDER BY CreatedDate desc),  
            (SELECT Id, XC_InvoiceDeliveryPref__c, NE__Payment__c, XC_Token__c, NE__Card_Number__c, NE__Card_Type__c, NE__Expiration__c, NE__Expiration_Year__c, 
            NE__Iban__c, XC_InvoicePreferredLanguage__c, XC_SepaMandateDate__c, XC_SepaMandate__c
            FROM NE__Billing_Profiles__r WHERE Id in: bpId) 
            FROM Account WHERE Id =: accId 
        ]);

        for(NE__Billing_Profile__c bp:billingProfiles){
            res.put(bp.id,mapAcc.get(bp.NE__Account__c));
        }

        return res;
    }

    /**
    * @description BillingItemCreationWrapper
    * @author Simone Trenta - strenta@deloitte.it 
    */
    public class BillingItemCreationWrapper{
        public NE__Billing_Profile__c billingProfile;
        public String billingAddress;
        public String soldToAddress;
        public String legalEntity;
        public String pec;
        public String recipientCode; 
        public String invoiceDeliveryPref;
        public String invoicePreferredLanguage; 
    }

    /**
    * @description createBPLI
    * @param wrInput - wrInput
    * @return the bpli
    * @author Simone Trenta - strenta@deloitte.it 
    */
    public static Map<Id,XC_BillingProfileLineItem__c> createBPLI(Map<Id,BillingItemCreationWrapper> wrInput){
        Map<Id,XC_BillingProfileLineItem__c> res = new Map<Id,XC_BillingProfileLineItem__c>();

        for(BillingItemCreationWrapper bw:wrInput.values()){
            XC_BillingProfileLineItem__c billingProfLi = bw.billingProfile.Billing_Profile_Line_Items__r[0];

            XC_BillingProfileLineItem__c billingProfileLineItemToInsert = new XC_BillingProfileLineItem__c ( 
                XC_BillingProfile__c = bw.billingProfile.Id, 
                XC_BillToAddress__c = bw.billingAddress, 
                XC_SoldToAddress__c = bw.soldToAddress, 
                XC_BillToContactId__c = billingProfLi.XC_BillToContactId__c, 
                XC_SoldToContactId__c = billingProfLi.XC_SoldToContactId__c,
                XC_BillingProfileName__c = billingProfLi.XC_BillingProfileName__c, 
                XC_Status__c = 'Draft',
                XC_LegalEntity__c = bw.legalEntity, 
                XC_ExternalKey__c = billingProfLi.XC_ExternalKey__c,
                XC_PEC__c = bw.pec, 
                XC_RecipientCode__c = bw.recipientCode,
                XC_InvoiceDeliveryPreference__c = bw.invoiceDeliveryPref,
                XC_InvoicePreferredLanguage__c = bw.invoicePreferredLanguage
            );

            if(!String.isBlank(billingProfileLineItemToInsert.XC_InvoiceDeliveryPreference__c) && (billingProfileLineItemToInsert.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase(Label.XC_CL_BpliInvoiceDeliveryPref)
                || billingProfileLineItemToInsert.XC_InvoiceDeliveryPreference__c.equalsIgnoreCase('Email')) &&  String.isBlank(billingProfLi.XC_BillToContactId__r.Email)){
                
                billingProfileLineItemToInsert.XC_InvoiceDeliveryPreference__c = 'Print';
            }

            res.put(bw.billingProfile.Id,billingProfileLineItemToInsert);
        }

        XC_UTIL_Sobject.insertListRecords(res.values()); 

        return res;
    }

    /**
    * @description sendBPLI
    * @param billingProfile - billingProfile
    * @param accInfo - accInfo
    * @param bpliInfo - bpliInfo
    * @author Simone Trenta - strenta@deloitte.it 
    */
    public static void sendBPLI(NE__Billing_Profile__c billingProfile, Account accInfo, XC_BillingProfileLineItem__c bpliInfo){
        Account bpAccount = accInfo;
        Map<String, Object> mapAccountDocument = new Map<String,Object>{'legalEntity' => bpliInfo.XC_LegalEntity__c,'bpAccount' => bpAccount};
        XC_REST_MobilityOrder_B.manageDocument(mapAccountDocument);

        String docNif = (String) mapAccountDocument.get('docNif');
        String docNumber = (String) mapAccountDocument.get('docNumber');
        String expedition = (String) mapAccountDocument.get('expedition');
        String expiration = (String) mapAccountDocument.get('expiration');
        String docCountry = (String) mapAccountDocument.get('docCountry');
        String countryCode  = (String) mapAccountDocument.get('countryCode');

        Map<String,Object> paymentMethod = XC_REST_MobilityOrder_B.manageBpForZuora(billingProfile);

        mapAccountDocument.put('billingProfile', billingProfile);
        XC_REST_Account_B.wrapperOption wrOptions =  XC_REST_MobilityOrder_B.manageWrapperOption(mapAccountDocument);

        Map<String,Object>  zuoraPayment = new Map<String,Object>{
            'bpId' => bpliInfo.Id,
            'fromBillingProfile' => false,
            'docNif' => (String.isBlank(docNif)) ? '': docNif,
            'docNumber' => (String.isBlank(docNumber)) ?  '': docNumber,
            'countryCode' => (String.isBlank(countryCode)) ?  '': countryCode,
            'expedition' => (String.isBlank(expedition)) ? '': expedition,
            'expiration' => (String.isBlank(expiration)) ? '': expiration,
            'personTypeCode' => (!String.isBlank(bpAccount.XC_RecordTypeDeveloperName__c) && bpAccount.XC_RecordTypeDeveloperName__c.containsIgnoreCase('Residential')) ? 'F' : 'J',
            'sequenceSetId' => wrOptions.SimplifiedInvoiceReplace,  // GUEST Sequence Set
            'zuoraSequenceSetId' => wrOptions.zuoraSequenceSetId,   // DEFAULT Sequence Set
            'invoicePreferredLanguage' => billingProfile.XC_InvoicePreferredLanguage__c,
            'contractId' => !String.isBlank(billingProfile.XC_CommodityContractID__c) ? billingProfile.XC_CommodityContractID__c : '',
            'legalE' => bpliInfo.XC_LegalEntity__c
        };
        
        wrOptions.zuoraSequenceSetId = null;
        Map<String,String>  zuoraMap = new Map<String,String>{
            'account' =>  JSON.Serialize(bpAccount, true),
            /*'billingContact' => contactBillSerialized,
            'soldContact' => contactSoldSerialized,*/
            'legalEntity' => bpliInfo.XC_LegalEntity__c,
            'options' => (JSON.Serialize(wrOptions, true)).replace('Replace', '__c'),
            'billingProfLineItemId' => bpliInfo.Id,
            'zuoraPayment' => JSON.serialize(zuoraPayment, true),
            'mapPayment' => JSON.serialize(paymentMethod, true),
            'billingProfId' => billingProfile.Id,
            'bpli' => JSON.serialize(bpliInfo, true), 
            'country' => bpAccount.Country__c
        };    
        
        XC_REST_Account_B.callZuora(zuoraMap);

        return;
    }

}