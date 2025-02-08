/**
 * @author Monica Cutillo - mcutillo@deloitte.it 
 * @date Creation 18/12/2019
 * @date Modification dd/mm/yyyy
 * @description util scecific for Penalty/Refund Calculation 
 */
public class XC_UTIL_PenaltyRefundCalculation {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC073_DisconnectAsset');
    
    /**
     * @description Input Wrapper to call the penalty/refund calculation
     */
    public class CalculationInputWrapper{
        public Case caso;
        public Asset asset;
        public String orderSubtype;
        public Id refAssetId;
        public XC_CM_DisconnectBillingMethod__mdt billingMethod;
        public Date dateToCalculate;
        public Map<String,XC_CM_DisconnectBillingMethod__mdt> billingMethods;
        public Date assetStartDate;
    }
    
    /**
     * @description Wrapper to search billing method on disconnect
     * billing meth metadata.
     */
    public class DisconnectBillingMethodWrapper{
        public String orderSubtype;
        public String productType;
        public String productSubtype;
    }
    
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getCalculationInput
     * @param assetId
     * @param orderSubtype
     * @param dateToCalculate
     * @return CalculationInputWrapper
     */
    public static CalculationInputWrapper getCalculationInput(String assetId, String orderSubtype, Date dateToCalculate){
        Asset refAsset = XC_UTIL_Asset_D.getAssetDisconnectionData(assetId);
        DisconnectBillingMethodWrapper billMethWr = new DisconnectBillingMethodWrapper();
        billMethWr.orderSubtype = orderSubtype;
        billMethWr.productType = refAsset.XC_Product_Type__c;
        billMethWr.productSubtype = refAsset.XC_Product_Subtype__c;
        Map<String,XC_CM_DisconnectBillingMethod__mdt> billingMetods = searchBillingMethodToApply(billMethWr);
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> billingMetods='+billingMetods);
        
        CalculationInputWrapper calcWr = new CalculationInputWrapper();
        calcWr.orderSubtype = orderSubtype;
        calcWr.asset = refAsset;
        calcWr.billingMethod = billingMetods.get('Penalty');
        calcWr.billingMethods = billingMetods;

        //SET DATA assetStartDate >> MC 08/05/2020  >> uset to read data on B2W matrix
        if(refAsset.XC_ContractStartDate__c != null){ 
            calcWr.assetStartDate = refAsset.XC_ContractStartDate__c;
        }else if(refAsset.XC_ActivationDate__c != null){
            calcWr.assetStartDate = refAsset.XC_ActivationDate__c.date();
        }else{
            calcWr.assetStartDate = Date.today();
        }
        calcWr.dateToCalculate = dateToCalculate;
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'getCalculationInputFirPenalty >'+calcWr);
        return calcWr;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description Refund calculation
     * @param calcWr the CalculationInputWrapper
     * @return result wrapper
     */
    public static XC_UTIL_ResultWrapper showPenaltyByMonths(CalculationInputWrapper calcWr){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CALL showPenaltyByMonths - calcWr='+calcWr);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        
        Integer payedInvoice = 0;
        //zqu__Quote__c zQuote = XC_UTIL_Asset_D.getZQuoteData(calcWr.asset.XC_ZQuoteId__c);
        //if(zQuote!= null && String.isNotEmpty(zQuote.zqu__ZuoraSubscriptionID__c)){
        if(calcWr.asset.XC_Subscription__r != null || calcWr.asset.XC_SubscriptionId__c != null){  //Fix recupero Subscription per Migrazione [MC - 2020/02/07]
            List<Zuora__InvoiceItem__c> zInvoiceItems = retrieveAllPayedInvoiceItem(calcWr.asset); //zQuote
            if(zInvoiceItems != null && !zInvoiceItems.isEmpty()){
                payedInvoice = zInvoiceItems.size();
            }
        }

        Integer totMonthsToPay = 12 - payedInvoice;
        //rw.objectInfo = String.valueOf(totMonthsToPay * calcWr.asset.NE__RecurringChargeOv__c);

        String totalAmount = String.valueOf(totMonthsToPay * calcWr.asset.NE__RecurringChargeOv__c);
        XC_LCC095_ShowPenalty.AmountInfo amountInfo = new XC_LCC095_ShowPenalty.AmountInfo();
        amountInfo.amountValue = totalAmount;
        amountInfo.amountKind = XC_LCC095_ShowPenalty.AmountB2wKind.INVOICE_PENALTY;
        amountInfo.configurationItemId = calcWr.asset.XC_Configuration_Item__c;
        amountInfo.productLicName = calcWr.asset.NE__ProdId__r.XC_LIC_Product_Name__c;

        Map<String,Object> objData = new Map<String,Object>();
        objData.put('TotalAmount', totalAmount);
        Map<Id,XC_LCC095_ShowPenalty.AmountInfo> amountData = new Map<Id,XC_LCC095_ShowPenalty.AmountInfo>();
        if(amountInfo.configurationItemId != null){
        	amountData.put(amountInfo.configurationItemId,amountInfo);
        }
        objData.put('AmountItems', amountData);
        //wr.objectInfo = String.valueOf(totalPenalty);
        rw.objectInfo = JSON.serialize(objData);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'showPenaltyByMonths - result='+rw);
        return rw;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description showNoPenalty
     * @return result wrapper with zero penalty value
     */
    public static XC_UTIL_ResultWrapper showNoPenalty(){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CALL showNoPenalty');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        //rw.objectInfo = '0';
        Map<String,Object> objData = new Map<String,Object>();
        objData.put('TotalAmount', String.valueOf(0));
        rw.objectInfo = JSON.serialize(objData);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'showNoPenalty - result='+rw);
        return rw;
    }
    
    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description searchBillingMethodToApply
     * @param billMethWr the DisconnectBillingMethodWrapper
     * @return the List<XC_CM_DisconnectBillingMethod__mdt> result
     */
    private static Map<String,XC_CM_DisconnectBillingMethod__mdt> searchBillingMethodToApply(DisconnectBillingMethodWrapper billMethWr){
        List<String> productTypeFilter = new List<String>{billMethWr.productType, null};
        List<String> productSubTypeFilter = new List<String>{billMethWr.productSubtype, null};
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'searchBillingMethodToApply INPUT='+billMethWr);
        Map<String,XC_CM_DisconnectBillingMethod__mdt> result = new Map<String,XC_CM_DisconnectBillingMethod__mdt>();
        Map<Id,XC_CM_DisconnectBillingMethod__mdt> data = new Map<Id,XC_CM_DisconnectBillingMethod__mdt>(
        [SELECT Id, DeveloperName, XC_Order_SubType__c, XC_Asset_ProductType__c, XC_Asset_ProductSubtype__c, XC_PaymentItem__c, XC_BillingMethod__c
  		   FROM XC_CM_DisconnectBillingMethod__mdt
		  WHERE XC_Order_SubType__c =: billMethWr.orderSubtype
  			AND XC_Asset_ProductType__c IN: productTypeFilter
  			AND XC_Asset_ProductSubtype__c IN: productSubTypeFilter
        ]);

        for(XC_CM_DisconnectBillingMethod__mdt item: data.values()){
            result.put(item.XC_PaymentItem__c,item);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'searchBillingMethodToApply OUTPUT='+result);
        return result;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description retrieveAllPayedInvoiceItem
     * @param zQuote
     * @return Zuora__InvoiceItem__c list
     * /
    private static List<Zuora__InvoiceItem__c> retrieveAllPayedInvoiceItem(zqu__Quote__c zQuote){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'retrieveAllPayedInvoiceItem - zQuote ='+zQuote);
        List<Zuora__Subscription__c> subscriptions = XC_UTIL_Asset_D.getSubscriptionFromExternalId(zQuote.zqu__ZuoraSubscriptionID__c);
        if(subscriptions.isEmpty()){
            return new List<Zuora__InvoiceItem__c>();
        }

        return XC_UTIL_Asset_D.getPayedInvoiceItemFromSubscription(subscriptions[0]);
    }*/

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description retrieveAllPayedInvoiceItem
     * @param asset
     * @return Zuora__InvoiceItem__c list
     */
    public static List<Zuora__InvoiceItem__c> retrieveAllPayedInvoiceItem(Asset asset){ //Fix recupero Subscription per Migrazione [MC - 2020/02/07]
        if(asset.XC_Subscription__r != null){
            return XC_UTIL_Asset_D.getPayedInvoiceItemFromSubscription(asset.XC_Subscription__r);
        }
        List<Zuora__Subscription__c> subscriptions = XC_UTIL_Asset_D.getSubscriptionFromExternalId(asset.XC_SubscriptionId__c);
        if(subscriptions.isEmpty()){
            return new List<Zuora__InvoiceItem__c>();
        }

        return XC_UTIL_Asset_D.getPayedInvoiceItemFromSubscription(subscriptions[0]);
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description save Calculated Data On Case for Conga Legal text
     * @param calcWr
     * @param objInfoData kyes{'orderSubtype', 'penaltyValue', 'refundValue', 'purchOptionValue'}
     * @return dml results
     */
    public static List<XC_UTIL_Sobject.WrapperResult> saveCalculatedDataOnCase(CalculationInputWrapper calcWr, Map<String,Object> objInfoData){
        if(calcWr == null || calcWr.caso == null || calcWr.caso.Id == null){
            return new List<XC_UTIL_Sobject.WrapperResult>();
        }
        Case caseToUpdate = new Case();
        caseToUpdate.Id = calcWr.caso.Id;
        if(objInfoData.get('orderSubtype') != null){
            caseToUpdate.XC_OrderSubtype__c = (String)objInfoData.get('orderSubtype');
        }else{
            caseToUpdate.XC_OrderSubtype__c = null;
        }
        if(objInfoData.get('penaltyValue') != null){
            caseToUpdate.XC_PenaltyAmount__c = Decimal.valueOf((String)objInfoData.get('penaltyValue'));
        }else{
            caseToUpdate.XC_PenaltyAmount__c = null;
        }
        if(objInfoData.get('refundValue') != null){
            caseToUpdate.XC_RefundAmount__c = Decimal.valueOf((String)objInfoData.get('refundValue'));
        }else{
            caseToUpdate.XC_RefundAmount__c = null;
        }
        if(objInfoData.get('purchOptionValue') != null){
            caseToUpdate.XC_PurchaseOptionAmount__c = Decimal.valueOf((String)objInfoData.get('purchOptionValue'));
        }else{
            caseToUpdate.XC_PurchaseOptionAmount__c = null;
        }
        return XC_UTIL_DML.updateRecords(new List<Case>{caseToUpdate});
    }
}