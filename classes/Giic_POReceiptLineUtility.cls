/**
  * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
  * @date Creation 22/07/2019
  * @date Modification 14/01/2022 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
  * @description giic_POReceiptLineUtility – Utility class for trigger giic_POReceiptLineTrigger
  */

public without sharing class Giic_POReceiptLineUtility  { 

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('Giic_StockGiic_POReceiptLineUtilityAvailabilityUtility');

    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 22/07/2019
    * @description giic_POReceiptLineUtility –To calculate average price and quantity on related product of PO Receipt line.
    * @param listPORLine list of purchase order receipt line
    */
    public static void calcAvgPrice(List<gii__PurchaseOrderReceiptLine__c> listPORLine){
        List<Id> poreciptLineIds = XC_UTIL_Sobject.getIds(listPORLine);
        Map<Id, gii__PurchaseOrderReceiptLine__c> porMap = new Map<Id, gii__PurchaseOrderReceiptLine__c>([
            SELECT Id, CurrencyIsoCode,gii__PurchaseOrderLine__r.gii__OpenAmount__c, gii__UnitPrice__c,gii__Product__c,gii__ReceivedQuantity__c
            FROM gii__PurchaseOrderReceiptLine__c
            WHERE Id IN :poreciptLineIds
        ]);                                                                                                     
        listPORLine = porMap.values();

        if(listPORLine != null && !listPORLine.isEmpty()){
            List<gii__Product2Add__c> pdtRefList = new List<gii__Product2Add__c>();
            Set<String> pdtIdSet = new Set<String>();
            for(gii__PurchaseOrderReceiptLine__c porLineRec : listPORLine){
                if(porLineRec.gii__Product__c != null){
                    pdtIdSet.add(porLineRec.gii__Product__c);
                }
            }        
            Map<Id,gii__Product2Add__c> mapOfPdtIdVsPdt = new Map<Id,gii__Product2Add__c>([SELECT giic_StockQuantity__c,CurrencyIsoCode,giic_AveragePrice__c FROM gii__Product2Add__c WHERE Id IN:pdtIdSet]);
            if(mapOfPdtIdVsPdt != null && !mapOfPdtIdVsPdt.values().isEmpty()){
                mapOfPdtIdVsPdt = processPORL(mapOfPdtIdVsPdt,listPORLine);
                update mapOfPdtIdVsPdt.values(); 
            }
        }
    }
    
    /**
    * @author FirstName : Rishabh Bansal - Rishabh.Bansal@in.fujitsu.com
    * @date Creation 22/07/2019
    * @description giic_POReceiptLineUtility –To calculate average price and quantity on related product of PO Receipt line.
    * @param listPORLine list of purchase order receipt line
    */
    public static void checkReasonOnPOR(List<gii__PurchaseOrderReceiptLine__c> listPORLine){
        List<Id> poreciptLineIds = XC_UTIL_Sobject.getIds(listPORLine);
        List<gii__PurchaseOrderReceiptLine__c> porList = new List<gii__PurchaseOrderReceiptLine__c>([
            SELECT Id, gii__PurchaseOrderReceipt__r.giic_ReasonOfCancellation__c,gii__PurchaseOrderReceipt__r.giic_OtherReasonOfCancellation__c
            FROM gii__PurchaseOrderReceiptLine__c
            WHERE Id IN :poreciptLineIds
        ]);
        for(gii__PurchaseOrderReceiptLine__c porNew : listPORLine){
            for(gii__PurchaseOrderReceiptLine__c porToCheck : porList){
                if(porToCheck.Id == porNew.Id && (porToCheck.gii__PurchaseOrderReceipt__r.giic_ReasonOfCancellation__c == ''|| porToCheck.gii__PurchaseOrderReceipt__r.giic_ReasonOfCancellation__c == null) ){
                    porNew.addError('Please insert Reason of cancellation');
                } else if(porToCheck.Id == porNew.Id && porToCheck.gii__PurchaseOrderReceipt__r.giic_ReasonOfCancellation__c == 'Other' &&  (porToCheck.gii__PurchaseOrderReceipt__r.giic_OtherReasonOfCancellation__c == '' || porToCheck.gii__PurchaseOrderReceipt__r.giic_OtherReasonOfCancellation__c ==null) ){
                       porNew.addError('Please insert a better explenation of cancellation Reason ');
                }
            } 
        }
    }
    
    /**
    * @date Creation 22/07/2019
    * @description Method to adj quantity for Product Inventory
    * @param listPORLine - List<gii__PurchaseOrderReceiptLine__c>
    */
    public static void adjQuantityOnPI(List<gii__PurchaseOrderReceiptLine__c> listPORLine){
        List<Id> pInventoryIds = XC_UTIL_Sobject.getListFieldValues(listPORLine, 'gii__ProductInventoryQuantityDetail__c');
        map<Id,Decimal> productInventoryIdToBackOrderNew = new map<Id,Decimal>();
        Map<Id,gii__ProductInventoryQuantityDetail__c> productInvenQDetail = new Map<Id,gii__ProductInventoryQuantityDetail__c>([
            SELECT id,Name,gii__BlockedQuantity__c,giic_Reserved__c, gii__Available__c, giic_Status__c, gii__OnHandQuantity__c,gii__ProductInventory__c,gii__Product__c,gii__Product__r.gii__SerialControlled__c, gii__Warehouse__c,gii__Location__c,gii__ProductSerial__c, gii__ProductSerial__r.name,gii__ProductLot__r.Name,gii__ProductInventory__r.giic_BackOrderNew__c
            FROM gii__ProductInventoryQuantityDetail__c 
            WHERE Id IN: pInventoryIds
        ]);

        List<gii__ProductInventoryQuantityDetail__c> piqdToUpdate = new List<gii__ProductInventoryQuantityDetail__c>();
        for(gii__ProductInventoryQuantityDetail__c piqd : productInvenQDetail.values()){
            if(piqd.gii__ProductInventory__r.giic_BackOrderNew__c==null){
                piqd.gii__ProductInventory__r.giic_BackOrderNew__c = 0;
            }
            productInventoryIdToBackOrderNew.put(piqd.gii__ProductInventory__c , piqd.gii__ProductInventory__r.giic_BackOrderNew__c);
        }
        for(gii__PurchaseOrderReceiptLine__c porNew : listPORLine) {
            gii__ProductInventoryQuantityDetail__c pi = productInvenQDetail.get(porNew.gii__ProductInventoryQuantityDetail__c);
            Decimal qntyToAddInBack = 0.0;
            if(pi.giic_Reserved__c>0 && pi.giic_Reserved__c >= porNew.gii__ReceivedQuantity__c){
                pi.gii__OnHandQuantity__c = pi.gii__OnHandQuantity__c + porNew.gii__ReceivedQuantity__c; // la riaggiungo poichè poi la scala il sistema in automatico dalle Sales
                qntyToAddInBack = qntyToAddInBack +  porNew.gii__ReceivedQuantity__c;
                pi.giic_Reserved__c = pi.giic_Reserved__c - porNew.gii__ReceivedQuantity__c;
            } else if(pi.giic_Reserved__c>0 && pi.giic_Reserved__c < porNew.gii__ReceivedQuantity__c){
                pi.gii__OnHandQuantity__c = pi.gii__OnHandQuantity__c + pi.giic_Reserved__c; 
                qntyToAddInBack = qntyToAddInBack+pi.giic_Reserved__c;
                pi.giic_Reserved__c = 0;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'nuovo available = '+pi.gii__OnHandQuantity__c);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'nuova reserved = '+pi.giic_Reserved__c);
            piqdToUpdate.add(pi);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'productInventoryIdToBackOrderNew1 = '+productInventoryIdToBackOrderNew);
            if(productInventoryIdToBackOrderNew.containsKey(pi.gii__ProductInventory__c)){
                productInventoryIdToBackOrderNew.put(pi.gii__ProductInventory__c, productInventoryIdToBackOrderNew.get(pi.gii__ProductInventory__c)+qntyToAddInBack); 
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'productInventoryIdToBackOrderNew2 = '+productInventoryIdToBackOrderNew);
        }
        update piqdToUpdate;
        List<gii__ProductInventory__c> productInventoryToUpdate = new  List<gii__ProductInventory__c>();
        for(Id piId : productInventoryIdToBackOrderNew.keySet()){
            gii__ProductInventory__c p = new gii__ProductInventory__c(Id = piId, giic_BackOrderNew__c=productInventoryIdToBackOrderNew.get(piId));
            productInventoryToUpdate.add(p);
        }
        update productInventoryToUpdate;
    }

    /**
    * @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 22/07/2019
    * @description giic_POReceiptLineUtility – For receiving non drop ship PO [PMD]
    * @param mapOfPdtIdVsPdt map of product reference
    * @param listPORLine list of purchae order receipt line
    * @return Map<Id,gii__Product2Add__c>
    */
    public static Map<Id,gii__Product2Add__c> processPORL(Map<Id,gii__Product2Add__c> mapOfPdtIdVsPdt, List<gii__PurchaseOrderReceiptLine__c> listPORLine) {
        Map<String, Double> currencyRates = new Map <String, Double>(); 
        for(CurrencyType cRates : [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE]) {
            currencyRates.put(cRates.IsoCode, cRates.ConversionRate);
        }
        
        for(gii__PurchaseOrderReceiptLine__c porLineObj : listPORLine){
            Decimal oldStockQty = 0;
            Decimal odrQty = 0;
            Decimal newQty = 0;
            Decimal stockQtyPriceVal = 0;
            Decimal pdtQtyPriceVal = 0;
            if(porLineObj.gii__Product__c!=null && mapOfPdtIdVsPdt.get(porLineObj.gii__Product__c)!= null && mapOfPdtIdVsPdt.get(porLineObj.gii__Product__c).giic_StockQuantity__c != null){
                oldStockQty = mapOfPdtIdVsPdt.get(porLineObj.gii__Product__c).giic_StockQuantity__c;
            }
            if(porLineObj.gii__ReceivedQuantity__c != null){
                odrQty = porLineObj.gii__ReceivedQuantity__c;
            }
            newQty = oldStockQty + odrQty;
            if(newQty != null && newQty != 0){
                if(mapOfPdtIdVsPdt.get(porLineObj.gii__Product__c).giic_AveragePrice__c != null){
                    stockQtyPriceVal =  (oldStockQty * mapOfPdtIdVsPdt.get(porLineObj.gii__Product__c).giic_AveragePrice__c).setScale(2);
                }
                //if(porLineObj.gii__PurchaseOrderLine__r.gii__OpenAmount__c != null){
                if(porLineObj.CurrencyIsoCode == mapOfPdtIdVsPdt.get(porLineObj.gii__Product__c).CurrencyIsoCode) {
                    pdtQtyPriceVal = (porLineObj.gii__UnitPrice__c * odrQty).setScale(2);
                } else {
                    Decimal covertValue = convertCurrency(porLineObj.CurrencyIsoCode,mapOfPdtIdVsPdt.get(porLineObj.gii__Product__c).CurrencyIsoCode,porLineObj.gii__UnitPrice__c, currencyRates);
                    pdtQtyPriceVal = (covertValue * odrQty).setScale(2);
                } 
            //}
                mapOfPdtIdVsPdt.get(porLineObj.gii__Product__c).giic_AveragePrice__c = ((stockQtyPriceVal + pdtQtyPriceVal)/newQty).setScale(2);
                mapOfPdtIdVsPdt.get(porLineObj.gii__Product__c).giic_StockQuantity__c = newQty;
            }
        }
        return mapOfPdtIdVsPdt;
    }

    /**
    * @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 22/07/2019
    * @description giic_POReceiptLineUtility – For receiving non drop ship PO [PMD]
    * @param inCurrency map of product reference
    * @param outCurrency list of purchae order receipt line
    * @param inAmount map of product reference
    * @param currencyRates list of purchae order receipt line
    * @return Map<Id,gii__Product2Add__c>
    */
    public static Decimal convertCurrency(String inCurrency, String outCurrency, Decimal inAmount,  Map<String, Double> currencyRates  ) {
        Decimal inCurrencyRate  = currencyRates.get(inCurrency);
        Decimal outCurrencyRate = currencyRates.get(outCurrency);
        Decimal amountInCorpCurr = inAmount/inCurrencyRate;
        Decimal outAmount = amountInCorpCurr *  outCurrencyRate;
        return outAmount;
    }

    /**
    * @author FirstName : Pradeep Kumar pradeep.p.kumar@in.fujitsu.com
    * @date Creation 22/07/2019
    * @description giic_POReceiptLineUtility – For receiving non drop ship PO
    * @param listPORLine list of gii__PurchaseOrderReceiptLine__c
    */
    public static void clearBackOrderQtyOnPI(List<gii__PurchaseOrderReceiptLine__c> listPORLine){
        Map<Id,gii__ProductInventory__c> mapProductInventory = new Map<Id,gii__ProductInventory__c>();
        Map<string,giic_ReservationUtility.ReservationWrapper> mapRW = new Map<string,giic_ReservationUtility.ReservationWrapper>();
        for(gii__PurchaseOrderReceiptLine__c porLineRec : [SELECT id, gii__ReceivedQuantity__c,gii__ShipTo__c,gii__ShipTo__r.gii__DefaultReceivingLocation__c, gii__Product__c,gii__ProductInventory__r.giic_BackOrderNew__c FROM  gii__PurchaseOrderReceiptLine__c WHERE  id in : listPORLine and gii__ProductInventory__r.giic_BackOrderNew__c  > 0 and gii__PurchaseOrder__r.gii__DropShip__c =false]) {
            XC_UTIL_Debug.debug(DEBUGACTIVE,'porLineRec ====================== '+porLineRec);
            if(porLineRec.gii__ShipTo__c != null && porLineRec.gii__Product__c != null){
                if(!mapProductInventory.containsKey(porLineRec.gii__ProductInventory__c)){
                    mapProductInventory.put(porLineRec.gii__ProductInventory__c,new gii__ProductInventory__c(Id=porLineRec.gii__ProductInventory__c,giic_BackOrderNew__c=porLineRec.gii__ProductInventory__r.giic_BackOrderNew__c));
                }
                
                if(mapProductInventory.get(porLineRec.gii__ProductInventory__c).giic_BackOrderNew__c > 0 ){
                    decimal reservedQty=0;
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'***porLineRec.gii__ReceivedQuantity__c***'+porLineRec.gii__ReceivedQuantity__c);
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'***mapProductInventory.get(porLineRec.gii__ProductInventory__c).giic_BackOrderNew__c***'+mapProductInventory.get(porLineRec.gii__ProductInventory__c).giic_BackOrderNew__c);
                    Boolean bool = mapProductInventory.get(porLineRec.gii__ProductInventory__c).giic_BackOrderNew__c - porLineRec.gii__ReceivedQuantity__c >= 0;
                    
                    reservedQty = bool == true ? porLineRec.gii__ReceivedQuantity__c : mapProductInventory.get(porLineRec.gii__ProductInventory__c).giic_BackOrderNew__c;
                    
                    mapProductInventory.get(porLineRec.gii__ProductInventory__c).giic_BackOrderNew__c = bool == true ? 
                        mapProductInventory.get(porLineRec.gii__ProductInventory__c).giic_BackOrderNew__c - porLineRec.gii__ReceivedQuantity__c : 0 ;
                    XC_UTIL_Debug.debug(DEBUGACTIVE,'***mapProductInventory***'+mapProductInventory);
                    //mapProductInventory.get(porLineRec.gii__ProductInventory__c).giic_BackOrderNew__c=mapProductInventory.get(porLineRec.gii__ProductInventory__c).giic_BackOrderNew__c -porLineRec.gii__OrderQuantity__c; 
                    mapRW = clearBackOrderQtyOnPIHelper(porLineRec,reservedQty,mapRW);
                }
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE,'mapRW***'+mapRW);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapRW***'+mapRW);
        if(mapRW.size()>0){
            giic_ReservationUtility.clearBackOrderQty(mapRW.values(),mapProductInventory);
        }
    }

    /**
    * @author FirstName : Rishabh Bansal Rishabh.bansal@in.fujitsu.com
    * @date Creation 30/08/2019
    * @description giic_POReceiptLineUtility – helper for clearBackOrderQtyOnPI [part of PMD correction]
    * @param porLineRec gii__PurchaseOrderReceiptLine__c
    * @param reservedQty
    * @param mapRW  map<string,giic_ReservationUtility.ReservationWrapper>
    * @return map<string,giic_ReservationUtility.ReservationWrapper>
    */
    public static map<string,giic_ReservationUtility.ReservationWrapper> clearBackOrderQtyOnPIHelper(gii__PurchaseOrderReceiptLine__c porLineRec, Decimal reservedQty, Map<string,giic_ReservationUtility.ReservationWrapper> mapRW){
        String key=porLineRec.gii__ShipTo__c + '-' +  porLineRec.gii__Product__c ; 
        if(!mapRW.containsKey(key)){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso1');
            giic_ReservationUtility.ReservationWrapper objRW = new giic_ReservationUtility.ReservationWrapper();
            objRW.warehouseId = porLineRec.gii__ShipTo__c;
            objRW.Product = porLineRec.gii__Product__c;
            objRW.location = porLineRec.gii__ShipTo__r.gii__DefaultReceivingLocation__c;  
            objRW.qty = reservedQty;
            mapRW.put(key,objRW);
        } else {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'caso2');
            mapRW.get(key).qty += porLineRec.gii__ReceivedQuantity__c;
        }
        return mapRW;
    }
    
    /**
        * @author Milko Fatiga - milko.fatiga@nttdata.com & Salvatore Agrillo - salvatore.agrillo@nttdata.com
        * @date Creation 14/01/2022
        * @description Method to update Product Required after EM
        * @param listPORLine - List<gii__PurchaseOrderReceiptLine__c>
    */
    public static void updateProductRequired(List<gii__PurchaseOrderReceiptLine__c> listPORLine){
        List<Id> poreciptLineIds = XC_UTIL_Sobject.getIds(listPORLine);
        List<gii__PurchaseOrderReceiptLine__c> porList = new List<gii__PurchaseOrderReceiptLine__c>([
            SELECT Id, Name, gii__ShipTo__r.gii__Account__c, gii__ReceivedQuantity__c, gii__PurchaseOrderLine__c, gii__PurchaseOrderLine__r.gii__OrderQuantity__c, gii__PurchaseOrderLine__r.gii__PurchaseOrder__r.giic_Status__c, gii__PurchaseOrderLine__r.gii__SalesOrderLine__r.giic_ProdRequired__c,gii__PurchaseOrderLine__r.gii__SalesOrderLine__r.giic_ProductRequiredId__c,gii__PurchaseOrderLine__r.gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrderLineItem__c, gii__PurchaseOrderReceipt__r.gii__ReceiptDate__c, gii__PurchaseOrderReceipt__r.Name, gii__PurchaseOrderLine__r.gii__PurchaseOrder__c   
            FROM  gii__PurchaseOrderReceiptLine__c 
            WHERE gii__PurchaseOrderLine__r.gii__PurchaseOrder__r.gii__SalesOrder__r.giic_WorkOrderLineItem__c != null AND Id IN :poreciptLineIds
        ]);
        
        if(porList.size() > 0) {
            // Check existing Product Required:
            List<String> prodReqId = new List<String>();
            for(gii__PurchaseOrderReceiptLine__c porln : porList) {
                if(porln.gii__PurchaseOrderLine__r.gii__SalesOrderLine__r.giic_ProductRequiredId__c != null) {
                    prodReqId.add(porln.gii__PurchaseOrderLine__r.gii__SalesOrderLine__r.giic_ProductRequiredId__c);
                }
            }

            // Update fields on Product Required found:
            if(prodReqId.size() > 0) {
                String poId = porList[0].gii__PurchaseOrderLine__r.gii__PurchaseOrder__c;
                String statusPO = porList[0].gii__PurchaseOrderLine__r.gii__PurchaseOrder__r.giic_Status__c;
                List<ProductRequired> prodReqList = new List<ProductRequired>([
                    SELECT Id, ProductRequiredNumber, Date_of_last_goods_receipt__c, Goods_Receipt_Quantity__c, Purchase_Order_Status__c 
                    FROM ProductRequired 
                    WHERE Id IN :prodReqId OR ProductRequiredNumber IN :prodReqId
                ]);
                if(prodReqList.size() > 0) {
                    for(gii__PurchaseOrderReceiptLine__c porln : porList) {
                        for(ProductRequired preq : prodReqList) {
                            Boolean productRequiredFoundByID = (porln.gii__PurchaseOrderLine__r.gii__SalesOrderLine__r.giic_ProductRequiredId__c == String.valueOf(preq.Id));
                            Boolean productRequiredFoundByNumber = (porln.gii__PurchaseOrderLine__r.gii__SalesOrderLine__r.giic_ProductRequiredId__c == preq.ProductRequiredNumber);
                            if(productRequiredFoundByID || productRequiredFoundByNumber) {
                                Decimal goodReceiptQuantity = 0;
                                if(preq.Goods_Receipt_Quantity__c != null) {
                                    goodReceiptQuantity = preq.Goods_Receipt_Quantity__c;
                                }
                                preq.Date_of_last_goods_receipt__c  = porln.gii__PurchaseOrderReceipt__r.gii__ReceiptDate__c;
                                preq.Goods_Receipt_Quantity__c      = Integer.valueOf(goodReceiptQuantity) + Integer.valueOf(porln.gii__ReceivedQuantity__c);
                                preq.Purchase_Order_Status__c       = porln.gii__PurchaseOrderLine__r.gii__PurchaseOrder__r.giic_Status__c;
                                preq.XC_LastGoodsReceiptNumber__c   = porln.gii__PurchaseOrderReceipt__r.Name; 
                                preq.XC_CompanyOrderReceipt__c      = porln.gii__ShipTo__r.gii__Account__c; 
                            }                                       
                        }                       
                    }
                    update prodReqList;
                    
                    List<gii__PurchaseOrderLine__c> polList = new List<gii__PurchaseOrderLine__c>([
                        SELECT Id, gii__SalesOrderLine__r.giic_ProductRequiredId__c   
                        FROM  gii__PurchaseOrderLine__c 
                        WHERE  gii__PurchaseOrder__c = :poId
                    ]);
                    List<String> prodReqIdNew = new List<String>();
                    for(gii__PurchaseOrderLine__c poln : polList) {
                        if(poln.gii__SalesOrderLine__r.giic_ProductRequiredId__c!=null) {
                            prodReqIdNew.add(poln.gii__SalesOrderLine__r.giic_ProductRequiredId__c);
                        }
                    }
                    if(prodReqIdNew.size() > 0) {
                        List<ProductRequired> prodReqListNew = new List<ProductRequired>([
                            SELECT Id, Purchase_Order_Status__c 
                            FROM ProductRequired 
                            WHERE Id IN: prodReqIdNew OR ProductRequiredNumber IN: prodReqIdNew
                        ]);
                        if(prodReqListNew.size() > 0) {
                            for(ProductRequired preq : prodReqListNew) {
                                preq.Purchase_Order_Status__c = statusPO;
                            }
                            update prodReqListNew;
                        }
                    }
                }               
            }           
        }
    }
    
}