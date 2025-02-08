/**
 * @author Monica Cutillo - mcutillo@deloitte.it 
 * @date Creation 12/09/2019
 * @date Modification dd/mm/yyyy
 * @description util scecific for XC_LCC075_DisconnectAssetFromCase 
 */
public class XC_UTIL_DisconnectAssetManager {
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC073_DisconnectAsset');

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Manage Init Disconnection Operations
     * @param caso the Case from starts the operation
     * @return result wrapper
     */
    public static XC_UTIL_ResultWrapper manageInitDisconnection(Case caso){
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '->->-> manageInitDisconnection');
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        if(caso.assetId==null){
            wr.resultMessage = Label.XC_CL_Asset_NoAssetFound;
            return wr;
        }

        //retrieve subtype order
        XC_UTIL_DisconnectAsset.CaseSearchFilter caseFilter = new XC_UTIL_DisconnectAsset.CaseSearchFilter(caso.Reason, caso.SubCause__c, caso.XC_Subtype__c);
        XC_OrderSubtypeByCase__mdt mtd = XC_UTIL_DisconnectAsset.getAssetSubtypeByCaseReason(caseFilter, 'Disconnect');
        //String orderSubtype = (mtd != null) ? mtd.OrderSubtype__c : '';
        String orderSubtype;
        Boolean skipOrderCreation = false;
        if(mtd != null) {
            orderSubtype = mtd.OrderSubtype__c;
            skipOrderCreation = mtd.XC_SkipOrderCreation__c;
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'orderSubtype='+orderSubtype);
        
        XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr = XC_UTIL_PenaltyRefundCalculation.getCalculationInput(caso.assetId, orderSubtype, caso.XC_Communication_Date__c);
        calcWr.caso = caso;

        XC_UTIL_ResultWrapper wrReth = checkRethinking(calcWr);
        if(!wrReth.success){
            return wrReth;
        }

        wr = XC_LCC073_DisconnectAsset.checkOrderSubtypeBeaforeOperation(caso, orderSubtype, 'Disconnect');
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '-> checkOrderSubtypeBeaforeOperation wr='+wr);

        Map<String,Object> objInfoData = new Map<String,Object>();
        if(orderSubtype == Label.XC_CL_OrdersubTypeValue_RequestedByTheClient){
            if(!wr.success){
                //RequestByTheClient KO for ScheduledDeactivation > needs Change Order 
                objInfoData.put('penaltyErrorMessage', wr.resultMessage);
                return wr;
            }else{
                //RequestByTheClient OK > take specific order subtype
                objInfoData.put('orderSubtype', wr.objectInfo);
            }
        }else{
            objInfoData.put('orderSubtype', orderSubtype);
        }
        if(orderSubtype == Label.XC_CL_OrdersubTypeValue_Complaint){
            objInfoData.put('complaintType', wr.resultMessage);
        }
        objInfoData.put('skipOrderCreation', skipOrderCreation);
        objInfoData.put('assetId', calcWr.asset.Id);

        /* LEGAL TEXT CONFIG */
        if(caso.XC_LegalEntity__c == 'EndesaX' || caso.XC_LegalEntity__c == 'EnelXMobilitySpain'){
            objInfoData.put('showLegalText', true);
            objInfoData.put('legalText', Label.XC_CL_BaseLegalText);
        }else{
            objInfoData.put('showLegalText', false);
        }
        
        /*if(caso.assetId==null){
            objInfoData.put('penaltyErrorMessage', Label.XC_CL_Asset_NoAssetFound);
            return wr;
        }*/

        //retrieve penalty
        XC_UTIL_ResultWrapper penaltyRW = XC_LCC073_DisconnectAsset.checkPenalityBeforeDisconnectCase(calcWr); //(String)caso.Id,  //penalityCalculation(caso.Id); //
        XC_UTIL_Debug.debug(DEBUGACTIVE, '-> Penalty RW='+penaltyRW);
        if(penaltyRW.success){
            objInfoData.put('penaltyMessage', penaltyRW.resultMessage);
        }else{
            objInfoData.put('penaltyErrorMessage', penaltyRW.resultMessage);
        }
        objInfoData.put('penaltyValue', penaltyRW.objectInfo);
		
        //retrieve refund
        XC_UTIL_ResultWrapper refundRW = checkRefundBeforeDisconnectCase(calcWr);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '-> Refund RW='+refundRW);
        Map<String,String> rfData = (Map<String,String>)JSON.deserialize(refundRW.objectInfo, Map<String,String>.class);
        objInfoData.put('refundValue', rfData.get('refundValue'));
        objInfoData.put('contractNumber', rfData.get('contractNumber'));
        objInfoData.put('contrStartD', rfData.get('contrStartD'));
        objInfoData.put('contrEndD', rfData.get('contrEndD'));

        
        if(orderSubtype == Label.XC_CL_OrdersubTypeValue_Complaint){
            Map<String,String> calculatedData = new Map<String,String>();
            calculatedData.put('Penalty',(String)objInfoData.get('penaltyValue'));
            calculatedData.put('Refund',(String)objInfoData.get('refundValue'));
            objInfoData.put('complaintCalculatedData', JSON.serialize(calculatedData));
        }
        
        wr.objectInfo = JSON.serialize(objInfoData);
        //save data on Case for Conga Legal text - MC 24/04/2020
        List<XC_UTIL_Sobject.WrapperResult> caseUpdRes = XC_UTIL_PenaltyRefundCalculation.saveCalculatedDataOnCase(calcWr, objInfoData);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, '-> manageInitDisconnection RW='+wr);
        return wr;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description check Rethinking
     * @param calcWr the CalculationInputWrapper
     * @return the XC_UTIL_ResultWrapper
     */ 
    @TestVisible private static XC_UTIL_ResultWrapper checkRethinking(XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calcWr){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        if(calcWr.orderSubtype == 'Rethinking'){
            if(calcWr.caso.XC_Channel_Attribute__c=='CA003' && calcWr.caso.XC_Communication_Date__c==null){
                wr.resultMessage = Label.XC_CL_CommunicationDateNotFilled;
                return wr;
            }
            else{
                String days = XC_Util_Rethinking.getRethinkingDays(calcWr.asset);
                Boolean check15 = checkDaysBetween(calcWr.asset.XC_ActivationDate__c, calcWr.caso.XC_Communication_Date__c, Double.valueOf(days)); //15
                XC_UTIL_Debug.debug(DEBUGACTIVE, '-> check15 = '+check15);
                if(check15){
                    wr.resultMessage = String.format(Label.XC_CL_RethinkingNotPossible, new List<String>{days});
                    return wr;
                }
            }
        }
        wr.success = true;
        return wr;
    }
    
    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @description Check days between.
     * @param targetDate the target date
     * @param caseDate the case date
     * @param threshold the threshold
     * @return the boolean
     */ 
    private static Boolean checkDaysBetween(Datetime targetDate, Date caseDate, Double threshold) {
        System.debug('CALL checkDaysBetween: targetDate='+targetDate+' - caseDate='+caseDate+' - threshold='+threshold);
        if(targetDate == null){
            return false;
        }
        Date parsedDate = Date.valueOf(targetDate);
        Double daysBetween = Double.valueOf(parsedDate.daysBetween(caseDate));
        System.debug('DaysBetween = '+daysBetween);
        return (daysBetween > threshold);

        /*if(targetDate!=null){
            Date parsedDate = Date.valueOf(targetDate);
            Double daysBetween = Double.valueOf(parsedDate.daysBetween(caseDate));
            System.debug('DaysBetween = '+daysBetween);
            if(daysBetween <= threshold) {
                return false;
            }
        }
        return true;*/
    }
    
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description checkRefundBeforeDisconnectCase
     * @param refundWr the CalculationInputWrapper
     * @return result wrapper
     */
    public static XC_UTIL_ResultWrapper checkRefundBeforeDisconnectCase(XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper refundWr){
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'checkRefundBeforeDisconnectCase INPUT='+refundWr);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        Map<String,String> objData = new Map<String,String>();
        objData.put('refundValue', String.valueOf(0));
        rw.objectInfo = JSON.serialize(objData);
        //rw.objectInfo = '0';
        if(refundWr == null || String.isBlank(refundWr.orderSubtype) || preChecksToRefund(refundWr)){
            return rw;
        }
        
        /*if(refundWr.caso != null){
            refundWr.refAssetId = refundWr.caso.assetId;
        }*/
        return showRefund(refundWr);
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description preChecksToRefund
     * @param refundWr the CalculationInputWrapper
     * @return checks result
     */
    @TestVisible private static Boolean preChecksToRefund(XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper refundWr){
        if((refundWr.orderSubtype == 'Requested by technician')){
            //XC_UTIL_Debug.debug(DEBUGACTIVE, '->preChecksToRefund for Requested by technician');
            if(refundWr != null && refundWr.asset != null && refundWr.asset.XC_ContractStartDate__c != null){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'XC_ContractStartDate__c='+refundWr.asset.XC_ContractStartDate__c);
                Integer activationDays = refundWr.asset.XC_ContractStartDate__c.daysBetween(Date.today());
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'activationDays='+activationDays);
                return activationDays > 365;
            }
        }
        return false;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description Refund calculation
     * @param refundWr the CalculationInputWrapper
     * @return result wrapper
     */
    public static XC_UTIL_ResultWrapper showRefund(XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper refundWr){
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'showRefund start>'+refundWr);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        Map<String,String> objData = new Map<String,String>();
        //rw.objectInfo = '0';
        Decimal calculatedRefund = 0;
        objData.put('refundValue', String.valueOf(calculatedRefund));
        
        /*if(refundWr == null){ // || refundWr.refAssetId == null
            rw.objectInfo = JSON.serialize(objData);
            return rw;
        }*/

        /*Asset assetData = refundWr.asset;
        if(assetData == null){
            assetData = XC_UTIL_Asset_D.getAssetDisconnectionData(refundWr.refAssetId);
        }*/
        objData.put('contractNumber', refundWr.asset.XC_Contract__r.ContractNumber);
        Date startDate = refundWr.asset.XC_ContractStartDate__c; //XC_Contract__r.StartDate;
        if(startDate!=null){
            objData.put('contrStartD', startDate.format());
        }
        Date endDate = refundWr.asset.XC_ContractEndDate__c; //XC_Contract__r.EndDate;
        if(endDate!=null){
            objData.put('contrEndD', endDate.format());
        }

        XC_CM_DisconnectBillingMethod__mdt refBillMethod = refundWr.billingMethods.get('Refund');
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'refBillMethod='+refBillMethod);
        //se non ho trovato XC_CM_DisconnectBillingMethod__mdt associato a Refund, il valore è 0
        if(refBillMethod == null){
            rw.objectInfo = JSON.serialize(objData);
            return rw;
        }
        
        //diversamemente da questi casi il valore di Refund è 0
        /*if(refundWr.orderSubType != 'Rethinking' && refundWr.orderSubType != 'Complaint' && refundWr.orderSubType != 'Bad referral'){
            rw.objectInfo = JSON.serialize(objData);
            return rw;
        }*/
        
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'Refund calc on ZQuoteId='+refundWr.asset.XC_ZQuoteId__c);
        /*if(String.isBlank(refundWr.asset.XC_ZQuoteId__c)){
            rw.objectInfo = JSON.serialize(objData);
            return rw;
        }*/
        //zqu__Quote__c zQuote = XC_UTIL_Asset_D.getZQuoteData(refundWr.asset.XC_ZQuoteId__c);
        //if(zQuote!= null && String.isNotEmpty(zQuote.zqu__ZuoraSubscriptionID__c)){
        if(refundWr.asset.XC_Subscription__r != null || refundWr.asset.XC_SubscriptionId__c != null){ //Fix recupero Subscription per Migrazione [MC - 2020/02/07]
            List<Zuora__InvoiceItem__c> zInvoiceItems = XC_UTIL_PenaltyRefundCalculation.retrieveAllPayedInvoiceItem(refundWr.asset); //zQuote
            if(!(zInvoiceItems.isEmpty())){
                for(Zuora__InvoiceItem__c ziitem : zInvoiceItems){
                    calculatedRefund = calculatedRefund + ziitem.Zuora__Charge_Amount2__c + ziitem.Zuora__TaxAmount2__c; //calculatedRefund + ziitem.Zuora__UnitPrice2__c
                }
            }
        }
        objData.put('refundValue', String.valueOf(calculatedRefund));

        //TODO Dinamic set of Legal Text
        //objData.put('contractNumber', Label.DisconnectLegalTextValue);

        rw.objectInfo = JSON.serialize(objData);
        //rw.objectInfo = String.valueOf(calculatedRefund);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'showRefund res>'+rw);
        return rw;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description retrieveAllPayedInvoiceItem
     * @param asset
     * @return Zuora__InvoiceItem__c list
     * /
    private static List<Zuora__InvoiceItem__c> retrieveAllPayedInvoiceItem(Asset asset){ //Fix recupero Subscription per Migrazione [MC - 2020/02/07]
        //asset.XC_Subscription__r != null || asset.XC_SubscriptionId__c != null
        if(asset.XC_Subscription__r != null){
            return XC_UTIL_Asset_D.getPayedInvoiceItemFromSubscription(asset.XC_Subscription__r);
        }
        List<Zuora__Subscription__c> subscriptions = XC_UTIL_Asset_D.getSubscriptionFromExternalId(asset.XC_SubscriptionId__c);
        if(subscriptions.isEmpty()){
            return new List<Zuora__InvoiceItem__c>();
        }

        return XC_UTIL_Asset_D.getPayedInvoiceItemFromSubscription(subscriptions[0]);
    }*/

}