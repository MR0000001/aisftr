/**
 * @author Lorenzo Orlanducci, Federico Amici
 * @date Creation 28/02/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC095_ShowPenalty -  The controller for the XC_LCP095_ShowPenalty component computes the penalty
 *                                         applied to the products
 */
public class XC_LCC095_ShowPenalty {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC095_ShowPenalty');

    /** @description B2W amount kinds */
    public enum AmountB2wKind { PENALTY, PURCHASE_OPTION, UNISTALL, INVOICE_PENALTY, PENALTY_AND_UNISTALL }

    /** @description Unistallment Costs Policy */
    @testVisible
    private enum UnistallmentCostsPolicy {ONLY_UNISTALL, WITH_UNISTALL, WITHOUT_UNISTALL}

    /** @description Wrapper used to avoid long parameter list */
    private class QueryWrapper {
        public List<Asset> listAsset;
        public List<String> listProdNames;
        public List<String> listPaymentModels;
        public List<String> listRegions;
        public Map<String,String> prodNameToBillingModelMap; 
        public Map<String,Id> prodNameToConfigItemMap;
        public Map<String,List<Id>> prodNameToConfigItemListMap; 
    }

    /** @description Wrapper with calculation results from B2W matrix */
    private class B2wAmountsCalculation {
        //public List<Map<Integer, AmountInfo>> globalPenalties;
        //public List<Map<Integer, AmountInfo>> unistallPenalties;
        //public List<Map<Integer, AmountInfo>> optionAmounts;
        public List<Map<Integer, List<AmountInfo>>> globalPenaltiesList;
        public List<Map<Integer, List<AmountInfo>>> unistallPenaltiesList;
        public List<Map<Integer, List<AmountInfo>>> optionAmountsList;

        /** @description initiatize Wrapper fields */
        public void initWrapper(){
            //this.globalPenalties = new List<Map<Integer, AmountInfo>>();
            //this.unistallPenalties = new List<Map<Integer, AmountInfo>>();
            //this.optionAmounts = new List<Map<Integer, AmountInfo>>();
            this.globalPenaltiesList = new List<Map<Integer, List<AmountInfo>>>();
            this.unistallPenaltiesList = new List<Map<Integer, List<AmountInfo>>>();
            this.optionAmountsList = new List<Map<Integer, List<AmountInfo>>>();
        }
    }

    /** @description Wrapper to contain Amount info */
    public class AmountInfo{
        public String productLicName;
        public Id configurationItemId;
        public String amountValue;
        public Integer monthLimit;
        public AmountB2wKind amountKind;
    }
    
    /* @description AmountResult Wrapper */
    public class AmountResult {
        public Integer totalAmount;
        public AmountInfo amountVoice;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description Show penalty.
     * @param calculationInput the CalculationInputWrapper
     * @return the result wrapper
     */
    public static XC_UTIL_ResultWrapper showPenalty(XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calculationInput){
        XC_UTIL_ResultWrapper showAmountsRW = showAmounts(calculationInput);
        if(String.isNotBlank(showAmountsRW.objectInfo)){
            Map<String,Object> objInfoData = (Map<String,Object>)JSON.deserializeUntyped(showAmountsRW.objectInfo);
            showAmountsRW.objectInfo = (String)objInfoData.get('TotalAmount');
        }
        return showAmountsRW;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description Show penalty.
     * @param calculationInput the CalculationInputWrapper
     * @param withItemsDetail true to have on result the Amount Items detail
     * @return the result wrapper
     */
    public static XC_UTIL_ResultWrapper showAmounts(XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calculationInput){ 
        
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;

        if(calculationInput.billingMethod != null && Label.XC_CL_DiscBillMethod_PayRestOfTheYear == calculationInput.billingMethod.XC_BillingMethod__c){
            return XC_UTIL_PenaltyRefundCalculation.showPenaltyByMonths(calculationInput);
        }
        if(calculationInput.billingMethod != null && Label.XC_CL_DiscBillMethod_NoPenalty == calculationInput.billingMethod.XC_BillingMethod__c){
            return XC_UTIL_PenaltyRefundCalculation.showNoPenalty();
        }
        if(calculationInput.billingMethod != null && Label.XC_CL_DiscBillMethod_PurchaseOption == calculationInput.billingMethod.XC_BillingMethod__c){
            return showOptionByMatrix(calculationInput); //(calculationInput.asset.Id, calculationInput.dateToCalculate);
        }
        if(calculationInput.billingMethod != null && Label.XC_CL_DiscBillMethod_B2WMatrixWithoutUnist == calculationInput.billingMethod.XC_BillingMethod__c){
            return showPenaltyByMatrix(calculationInput, UnistallmentCostsPolicy.WITHOUT_UNISTALL);
        }
        if(calculationInput.billingMethod != null && Label.XC_CL_DiscBillMethod_OnlyUnistall == calculationInput.billingMethod.XC_BillingMethod__c){
            return showPenaltyByMatrix(calculationInput, UnistallmentCostsPolicy.ONLY_UNISTALL);
        }
        // else the default method is always the B2W matrix
        return showPenaltyByMatrix(calculationInput, UnistallmentCostsPolicy.WITH_UNISTALL); //(calculationInput.asset.Id, calculationInput.dateToCalculate); //calculationInput.refAssetId
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @description calculateDataFromB2WMatrix
     * @param currentAsset
     * @param listAsset
     * @param assetDate
     * @return the B2wAmountsCalculation
     */
    private static B2wAmountsCalculation calculateDataFromB2WMatrix(Asset currentAsset, List<Asset> listAsset, Date assetDate){

        QueryWrapper queryWr = new QueryWrapper();
        queryWr.listAsset = listAsset;
        queryWr.listProdNames = new List<String>(); // listProdNames;
        queryWr.listPaymentModels = new List<String>(); // listPaymentModels;
        queryWr.listRegions = new List<String>(); // listRegions;
        queryWr.prodNameToBillingModelMap = new Map<String,String>(); //prodNameToBillingModelMap;
        queryWr.prodNameToConfigItemMap = new Map<String,Id>();
        queryWr.prodNameToConfigItemListMap = new Map<String,List<Id>>();
        getListQueryParameters(queryWr);

        XC_LCC095_ShowPenalty_D.MatrixWrapper wrMatrix = new XC_LCC095_ShowPenalty_D.MatrixWrapper();
        wrMatrix.bundleName = currentAsset.NE__Bundle__r.LIC_Name__c; // currentAsset.NE__Bundle__r.Name; //currentAsset[0]     //DEFECT 2904 - MC 20200321
        wrMatrix.listPaymentModels = queryWr.listPaymentModels;
        wrMatrix.listProdNames = queryWr.listProdNames;
        wrMatrix.listRegions = queryWr.listRegions;
        wrMatrix.assetDate = (assetDate != null) ? assetDate : Date.today();
        List<NE__Matrix_Parameter_Row__c> matrix = XC_LCC095_ShowPenalty_D.getListParameterRows(wrMatrix);

        if(matrix.isEmpty()){
            return new B2wAmountsCalculation(); // Map<String,List<Map<Integer, String>>>();
        }

        //calcolo delle penaly
        return createListMapPenalties(matrix, queryWr.prodNameToBillingModelMap, queryWr.prodNameToConfigItemListMap);
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @description Show penalty By B2W Matrix
     * @param calculationInput CalculationInputWrapper input wrapper with data
     * @param unistallPolicy from UnistallmentCostsPolicy
     * @return the x C UTI L result wrapper
     */
    private static XC_UTIL_ResultWrapper showPenaltyByMatrix(XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calculationInput, UnistallmentCostsPolicy unistallPolicy){ //(String recordId, Date dateToCalculate){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        
        List<Asset> currentAsset = XC_LCC095_ShowPenalty_D.getCurrentAsset(calculationInput.asset.Id); //recordId
        if(currentAsset.isEmpty()){
            wr.resultMessage = Label.XC_CL_Asset_NoAssetFound;
            return wr;
        }

        List<Asset> relatedAsset = XC_LCC095_ShowPenalty_D.getRelatedAsset(calculationInput.asset.Id); //recordId
        List<Asset> listAsset = new List<Asset>();
        listAsset.add(currentAsset[0]);
        listAsset.addAll(relatedAsset);

        XC_UTIL_Debug.debug(DEBUGACTIVE, '### listAsset ### ' + listAsset);

        //Map<String,List<Map<Integer, String>>> penaltyData = calculateDataFromB2WMatrix(currentAsset[0], listAsset);
        B2wAmountsCalculation b2wAmountData = calculateDataFromB2WMatrix(currentAsset[0], listAsset, calculationInput.assetStartDate);
        if(b2wAmountData == null || b2wAmountData.globalPenaltiesList == null || b2wAmountData.globalPenaltiesList.isEmpty()){
            wr.resultMessage = Label.XC_CL_Asset_NoPenaltyFound;
            //wr.objectInfo = String.valueOf(0);
            Map<String,Object> objData = new Map<String,Object>();
            objData.put('TotalAmount', String.valueOf(0));
            wr.objectInfo = JSON.serialize(objData);
            wr.success = true;
            return wr;
        } //else { 
            
        wr.success = true;
        Double daysBetweenAttivation;
        Boolean notActivated = true;
        //calcolo delle penaly
        if(currentAsset[0].XC_ActivationDate__c != null){
            notActivated = false;
            Date activationDate = Date.valueOf(currentAsset[0].XC_ActivationDate__c);
            daysBetweenAttivation = Double.valueOf(activationDate.daysBetween(calculationInput.dateToCalculate)); //todayDate > MC 20191028 - ESCEP-2212 //dateToCalculate
        }
        
        // Check if Rethinking Disconnection
        String days = XC_Util_Rethinking.getRethinkingDays(currentAsset[0]);
        if( Label.XC_CL_OrdersubTypeValue_Rethinking == calculationInput.orderSubtype && 
            (notActivated || daysBetweenAttivation <= Double.valueOf(days)) ) { //15.0
            if(currentAsset[0].Status == Label.XC_CL_Asset_StatusActive || currentAsset[0].Status == Label.XC_CL_Asset_StatusInstalled){
                List<Map<Integer, List<AmountInfo>>> listMapEndToPenaltyValues = b2wAmountData.unistallPenaltiesList; // penaltyData.get('UnistallPenalty');
                //wr = calculatePenaltyResult(listMapEndToPenaltyValues, diff, true);
                wr = calculateB2WAmounts(listMapEndToPenaltyValues, null, UnistallmentCostsPolicy.ONLY_UNISTALL); //true //diff
            }else{
                wr.resultMessage = Label.XC_CL_NoPenality;
                //wr.objectInfo = String.valueOf(0);
                Map<String,Object> objData = new Map<String,Object>();
                objData.put('TotalAmount', String.valueOf(0));
                wr.objectInfo = JSON.serialize(objData);
                wr.success = true;
            }
            return wr;
        }
        List<Map<Integer, List<AmountInfo>>> listMapEndToPenaltyValues = b2wAmountData.globalPenaltiesList; // penaltyData.get('GlobalPenalty'); // createListMapPenalties(matrix);
        
        Double daysBetween = Double.valueOf((calculationInput.assetStartDate).daysBetween(calculationInput.dateToCalculate));
        Double diffMonths = daysBetween/30;
        wr = calculateB2WAmounts(listMapEndToPenaltyValues, diffMonths, unistallPolicy); //false

        //}
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'showPenaltyWithUnistallDetail result = ' + wr);
        return wr;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description Show Purchase Option By B2W Matrix
     * @param calculationInput CalculationInputWrapper input wrapper with data
     * @return the x C UTI L result wrapper
     */
    private static XC_UTIL_ResultWrapper showOptionByMatrix(XC_UTIL_PenaltyRefundCalculation.CalculationInputWrapper calculationInput){ //(String recordId, Date dateToCalculate){
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        
        List<Asset> currentAsset = XC_LCC095_ShowPenalty_D.getCurrentAsset(calculationInput.asset.Id); //recordId

        if(currentAsset.isEmpty()){
            wr.resultMessage = Label.XC_CL_Asset_NoAssetFound;
            return wr;
        }

        List<Asset> relatedAsset = XC_LCC095_ShowPenalty_D.getRelatedAsset(calculationInput.asset.Id); //recordId

        List<Asset> listAsset = new List<Asset>();
        listAsset.add(currentAsset[0]);
        listAsset.addAll(relatedAsset);

        
        //Map<String,List<Map<Integer, String>>> penaltyData = calculateDataFromB2WMatrix(currentAsset[0], listAsset);
        B2wAmountsCalculation b2wAmountData = calculateDataFromB2WMatrix(currentAsset[0], listAsset, calculationInput.assetStartDate);
        //if(penaltyData.isEmpty()){
        if(b2wAmountData == null || b2wAmountData.globalPenaltiesList == null || b2wAmountData.globalPenaltiesList.isEmpty()){
            wr.resultMessage = Label.XC_CL_Asset_NoPenaltyFound;
            //wr.objectInfo = String.valueOf(0);
            Map<String,Object> objData = new Map<String,Object>();
            objData.put('TotalAmount', String.valueOf(0));
            wr.objectInfo = JSON.serialize(objData);
            wr.success = true;
            return wr;
        }
        
        /*Date activationDate;
        Double daysBetween;
        Double diff;
        if(currentAsset[0].XC_ActivationDate__c != null){
            activationDate = Date.valueOf(currentAsset[0].XC_ActivationDate__c);
            daysBetween = Double.valueOf(activationDate.daysBetween(calculationInput.dateToCalculate)); //dateToCalculate
            diff = daysBetween/30;
        }*/
        
        List<Map<Integer, List<AmountInfo>>> optionsValues = b2wAmountData.optionAmountsList; // penaltyData.get('OptionPenalty');
        //wr = calculatePenaltyResult(optionsValues,diff, false);
        Double daysBetween = Double.valueOf((calculationInput.assetStartDate).daysBetween(calculationInput.dateToCalculate));
        Double diff = daysBetween/30;
        wr = calculateB2WAmounts(optionsValues,diff, UnistallmentCostsPolicy.WITH_UNISTALL); //false
        wr.isValid = true;
        return wr;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description calculate Penalty Result
     * @param amountValues penalty data values to use on calculating
     * @param months number of months passed from activation date
     * @param unistallPolicy from UnistallmentCostsPolicy
     * @return the result wrapper
     */
    //private static XC_UTIL_ResultWrapper calculateB2WAmounts(List<Map<Integer, AmountInfo>> amountValues, Double months, Boolean onlyUnistall){
    private static XC_UTIL_ResultWrapper calculateB2WAmounts(List<Map<Integer, List<AmountInfo>>> amountValues, Double months, UnistallmentCostsPolicy unistallPolicy){
        Integer totalPenalty = 0;
        Map<String,Object> objDataEmpty = new Map<String,Object>();
        objDataEmpty.put('TotalAmount', String.valueOf(totalPenalty));
        objDataEmpty.put('AmountItems', new Map<Id,AmountInfo>());
        
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        wr.resultMessage = Label.XC_CL_ProductNotConfigured;
        //wr.objectInfo = String.valueOf(totalPenalty);
        wr.objectInfo = JSON.serialize(objDataEmpty);
        
        XC_UTIL_ResultWrapper wrU = new XC_UTIL_ResultWrapper();
        wrU.success = true;
        wrU.resultMessage = Label.XC_CL_NoPenality;
        //wrU.objectInfo = String.valueOf(totalPenalty);
        wrU.objectInfo = JSON.serialize(objDataEmpty);

        if(amountValues == null || amountValues.isEmpty()){
            if(unistallPolicy == UnistallmentCostsPolicy.ONLY_UNISTALL){ //onlyUnistall
                return wrU;
            }
            return wr;
        }
        for(Map<Integer, List<AmountInfo>> dataMap : amountValues) {
            if(dataMap.isEmpty() && amountValues.size()==1){
                if(unistallPolicy == UnistallmentCostsPolicy.ONLY_UNISTALL){ //onlyUnistall
                    return wrU;
                }
            return wr;
            }
        }

        //calcolo amounts
        Map<Id,AmountInfo> selectedAmountItems = new Map<Id,AmountInfo>();
        List<AmountResult> amResList = new List<AmountResult>();
        AmountInfo penalAndUnistAmount;
        Integer penalAndUnistValue = 0;
        for(Map<Integer, List<AmountInfo>> mapEnd : amountValues) {
            //totalPenalty += computeAmounts(mapEnd, months);
            amResList = computeAmounts(mapEnd, months, unistallPolicy);
            for(AmountResult amRes : amResList) {
                totalPenalty += amRes.totalAmount;
                if(amRes.amountVoice != null && String.isNotBlank(amRes.amountVoice.amountValue) && amRes.amountVoice.configurationItemId != null){
                    selectedAmountItems.put(amRes.amountVoice.configurationItemId,amRes.amountVoice);
                }
            }
        }
        String currencyStr = (String.isNotBlank(UserInfo.getDefaultCurrency())) ? UserInfo.getDefaultCurrency() : '';
        wr.success = true;
        wr.resultMessage = Label.XC_CL_Asset_PenaltyIs+' '+totalPenalty+' '+currencyStr;

        Map<String,Object> objData = new Map<String,Object>();
        objData.put('TotalAmount', String.valueOf(totalPenalty));
        objData.put('AmountItems', selectedAmountItems);
        //wr.objectInfo = String.valueOf(totalPenalty);
        wr.objectInfo = JSON.serialize(objData);
        return wr;
    }

    /**
     * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @description Compute Amounts.
     * @param mapEndAmounts the map end Amounts
     * @param months the diff of months
     * @param unistallPolicy
     * @return AmountResult (totalAmount + AmountInfo selected)
     */
    public static List<AmountResult> computeAmounts(Map<Integer, List<AmountInfo>> mapEndAmounts, Double months, UnistallmentCostsPolicy unistallPolicy) {
        List<AmountResult> amResList = new List<AmountResult>();
        AmountInfo amountPen;
        AmountInfo amountUn;
        Integer totalAmount = 0;
        String intEndAmount;
        
        //ADD Penalty/Option
        /*if(unistallPolicy != UnistallmentCostsPolicy.ONLY_UNISTALL){
            for(Integer i : mapEndAmounts.keySet()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ i @@@' + i);
                if(months <= i && (mapEndAmounts.get(i))[0].amountKind != AmountB2wKind.UNISTALL){
                    amountPen = new AmountInfo();
                    //tratto le migliaia
                    intEndAmount = ((mapEndAmounts.get(i))[0].amountValue).replace('.', '');
                    //tratto i decimali
                    intEndAmount = (intEndAmount).replace(',', '.');
                    totalAmount += ((Decimal.valueOf(intEndAmount)).round()).intValue();
                    amountPen = mapEndAmounts.get(i)[0];
                    break;
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ totalAmount @@@' + totalAmount);
            }
        }
        //ADD Unistall
        if(unistallPolicy != UnistallmentCostsPolicy.WITHOUT_UNISTALL){
            for(Integer i : mapEndAmounts.keySet()){
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ i @@@' + i);
                if((mapEndAmounts.get(i))[0].amountKind == AmountB2wKind.UNISTALL){
                    amountUn = new AmountInfo();
                    //tratto le migliaia
                    intEndAmount = ((mapEndAmounts.get(i))[0].amountValue).replace('.', '');
                    //tratto i decimali
                    intEndAmount = (intEndAmount).replace(',', '.');
                    totalAmount += ((Decimal.valueOf(intEndAmount)).round()).intValue();
                    amountUn = mapEndAmounts.get(i)[0];
                    break;
                }
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ totalAmount UNISTALL@@@' + totalAmount);
            }
        }

        amRes.amountVoice = getTotalAmountInfo(amountPen, amountUn);
        amRes.totalAmount = totalAmount;
        return amRes;*/


        for(Integer i : mapEndAmounts.keySet()) {
            if(unistallPolicy != UnistallmentCostsPolicy.ONLY_UNISTALL) {    //ADD Penalty/Option
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ i @@@' + i);
                if(months <= i && (mapEndAmounts.get(i))[0].amountKind != AmountB2wKind.UNISTALL){
                    //tratto le migliaia
                    intEndAmount = ((mapEndAmounts.get(i))[0].amountValue).replace('.', '');
                    //tratto i decimali
                    intEndAmount = (intEndAmount).replace(',', '.');
                    totalAmount += ((Decimal.valueOf(intEndAmount)).round()).intValue();
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ totalAmount @@@' + totalAmount);

                    for(AmountInfo ai : mapEndAmounts.get(i)) {
                        AmountResult amRes = new AmountResult();
                        amountPen = new AmountInfo();
                        amountPen = ai;
                        amRes.amountVoice = getTotalAmountInfo(amountPen, amountUn);
                        amRes.totalAmount = totalAmount;
                        amResList.add(amRes);
                    }
                    
                    break;
                }

            } else if(unistallPolicy != UnistallmentCostsPolicy.WITHOUT_UNISTALL) { //ADD Unistall
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ i @@@' + i);
                if((mapEndAmounts.get(i))[0].amountKind == AmountB2wKind.UNISTALL){
                    //tratto le migliaia
                    intEndAmount = ((mapEndAmounts.get(i))[0].amountValue).replace('.', '');
                    //tratto i decimali
                    intEndAmount = (intEndAmount).replace(',', '.');
                    totalAmount += ((Decimal.valueOf(intEndAmount)).round()).intValue();
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ totalAmount UNISTALL@@@' + totalAmount);

                    for(AmountInfo ai : mapEndAmounts.get(i)) {
                        AmountResult amRes = new AmountResult();
                        amountUn = new AmountInfo();
                        amountUn = ai;
                        amRes.amountVoice = getTotalAmountInfo(amountPen, amountUn);
                        amRes.totalAmount = totalAmount;
                        amResList.add(amRes);
                    }
                    
                    break;
                }
            }
        }

        return amResList;
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description get Total AmountInfo > penalty + unistall
     * @param amountPen
     * @param amountUn
     * @return the total AmountInfo
     */
    private static AmountInfo getTotalAmountInfo(AmountInfo amountPen, AmountInfo amountUn){
        if(amountPen== null && amountUn==null){
            return new AmountInfo();
        }
        if(amountPen!= null && amountUn==null){
            return amountPen;
        }
        if(amountPen== null && amountUn!=null){
            return amountUn;
        }
        
        amountPen.amountKind = AmountB2wKind.PENALTY_AND_UNISTALL;
        Integer penalAndUnistValue = Integer.valueOf(amountPen.amountValue) + Integer.valueOf(amountUn.amountValue);
        amountPen.amountValue = String.valueOf(penalAndUnistValue);
        return amountPen;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description calculate Penalty Result
     * @param penaltyValues penalty data values to use on calculating
     * @param months number of months passed from activation date
     * @param onlyUnistall true to consider only unistall, false otherwise
     * @return the result wrapper
     */
    /*private static XC_UTIL_ResultWrapper calculatePenaltyResult(List<Map<Integer, String>> penaltyValues, Double months, Boolean onlyUnistall){
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'CALL calculatePenaltyResult result - onlyUnistall=' + onlyUnistall + ' - penaltyValues='+ penaltyValues);
        Integer totalPenalty = 0;
        //Double diff;
        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        wr.resultMessage = Label.XC_CL_ProductNotConfigured;
        wr.objectInfo = String.valueOf(totalPenalty);
        
        XC_UTIL_ResultWrapper wrU = new XC_UTIL_ResultWrapper();
        wrU.success = true;
        wrU.resultMessage = Label.XC_CL_NoPenality;
        wrU.objectInfo = String.valueOf(totalPenalty);

        if(penaltyValues == null || penaltyValues.isEmpty()){
            if(onlyUnistall){
                return wrU;
            }
            return wr;
        }
        for(Map<Integer, String> dataMap : penaltyValues) {
            if(dataMap.isEmpty() && penaltyValues.size()==1){
            //if(m.values().isEmpty() || m.keySet().isEmpty()) {
            if(onlyUnistall){
                return wrU;
            }
            return wr;
            }
        }
        //calcolo penalty
        for(Map<Integer, String> mapEnd : penaltyValues) {
            totalPenalty += computePenalties(mapEnd, months); //diff
        }
        wr.success = true;
        wr.resultMessage = Label.XC_CL_Asset_PenaltyIs+' '+totalPenalty+' €';
        wr.objectInfo = String.valueOf(totalPenalty);
        return wr;
    }*/

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Compute penalties.
     * @param mapEndPenalties the map end penalties
     * @param months the diff of months
     * @return the integer
     */
    /*public static Integer computePenalties(Map<Integer, String> mapEndPenalties, Double months) {

        Integer totalPenalty = 0;
        String intEndPenalty;

        for(Integer i : mapEndPenalties.keySet()){
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ i @@@' + i);
            if(months <= i || months == null){
                /*
                if(String.isBlank(matrix[0].XC_Offline_Value_13__c)){
                   offset = 0;
                }else{
                   offset = Integer.valueOf(matrix[0].XC_Offline_Value_13__c);
                }
                * /
                //tratto le migliaia
                intEndPenalty = (mapEndPenalties.get(i)).replace('.', '');
                //tratto i decimali
                intEndPenalty = (intEndPenalty).replace(',', '.');
                //totalPenalty += Integer.valueOf(intEndPenalty);  //+offset;
                totalPenalty += ((Decimal.valueOf(intEndPenalty)).round()).intValue();
                break;
            }
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ totalPenalty @@@' + totalPenalty);
            /* else {
                if(String.isNotBlank(desintalacion)){
                wr.objectInfo = Integer.valueOf(desintalacion);
                wr.resultMessage = Label.XC_CL_Asset_PenaltyIs+' '+desintalacion+' €';
            }* /
        }

        return totalPenalty;
    }*/

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @description Creates the list map penalties.
     * @param listMatRows the list mat rows
     * @param prodNameToBillingModelMap
     * @param prodNameToConfigItemMap
     * @return the MAP with Lista data > 'GlobalPenalty', 'UnistallPenalty' and 'OptionPenalty'
     */
    /*private static B2wAmountsCalculation createListMapPenalties(List<NE__Matrix_Parameter_Row__c> listMatRows, Map<String,String> prodNameToBillingModelMap, Map<String,Id> prodNameToConfigItemMap) {
        B2wAmountsCalculation resultWr = new B2wAmountsCalculation();
        resultWr.initWrapper();

        Map<String,List<Map<Integer, String>>> result = new Map<String,List<Map<Integer, String>>>();
        Map<Integer, AmountInfo> mapRet;
        Map<Integer, AmountInfo> mapRetUnistall;
        Map<Integer, AmountInfo> mapOption;

        String num;
        Integer unistallCounter = 0;
        List<String> listNames;
        Map<String, String> mapNameToPenalties;
        AmountInfo amountInfo;
        for(NE__Matrix_Parameter_Row__c mat : listMatRows) {

            if(prodNameToBillingModelMap.get(mat.Product_LIC_Name__c) == mat.XC_Payment_Model__c){
                mapRet = new Map<Integer, AmountInfo>();
                mapRetUnistall = new Map<Integer, AmountInfo>();
                mapOption = new Map<Integer, AmountInfo>();
                mapNameToPenalties = createMapPenalties(mat);
                listNames = new List<String>{mat.XC_Offline_Name_01__c, mat.XC_Offline_Name_02__c, mat.XC_Offline_Name_03__c,
                                            mat.XC_Offline_Name_04__c, mat.XC_Offline_Name_05__c, mat.XC_Offline_Name_06__c,
                                            mat.XC_Offline_Name_07__c, mat.XC_Offline_Name_08__c, mat.XC_Offline_Name_09__c,
                                            mat.XC_Offline_Name_10__c, mat.XC_Offline_Name_11__c, mat.XC_Offline_Name_12__c,
                                            mat.XC_Offline_Name_13__c, mat.XC_Offline_Name_14__c, mat.XC_Offline_Name_15__c,
                                            mat.XC_Offline_Name_16__c, mat.XC_Offline_Name_17__c, mat.XC_Offline_Name_18__c,
                                            mat.XC_Offline_Name_19__c, mat.XC_Offline_Name_20__c, mat.XC_Offline_Name_21__c,
                                            mat.XC_Offline_Name_22__c, mat.XC_Offline_Name_23__c, mat.XC_Offline_Name_24__c,
                                            mat.XC_Offline_Name_25__c, mat.XC_Offline_Name_26__c, mat.XC_Offline_Name_27__c,
                                            mat.XC_Offline_Name_28__c, mat.XC_Offline_Name_29__c, mat.XC_Offline_Name_30__c};
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ createListMapPenalties - listNames=' + listNames);
                for(String field : listNames) {
                    if(String.isNotBlank(field) && field.containsIgnoreCase('pen')){
                        if(field.indexOf('M')>=0){
                            amountInfo = new AmountInfo();
                            num = field.substring(field.indexOf('M') + 2, field.lastIndexOf('M'));
                            if(String.isNotBlank(num)){
                                //resultWr.penaltyAmountForConfigItem.put(prodNameToConfigItemMap.get(mat.Product_LIC_Name__c), mapNameToPenalties.get(field));
                                amountInfo.productLicName = mat.Product_LIC_Name__c;
                                amountInfo.configurationItemId = prodNameToConfigItemMap.get(mat.Product_LIC_Name__c);
                                amountInfo.amountValue = mapNameToPenalties.get(field);
                                amountInfo.monthLimit = Integer.valueOf(num);
                                amountInfo.amountKind = AmountB2wKind.PENALTY;
                                mapRet.put(Integer.valueOf(num), amountInfo); // mapNameToPenalties.get(field)
                                //resultWr.globalPenalties.put(num, amountInfo);
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Pen key=' + num);
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Pen amountInfo=' + amountInfo);
                            }
                        }
                        //if(field.containsIgnoreCase('pen') && !field.containsIgnoreCase('Pen_Unistall')){
                        if(field.containsIgnoreCase('Pen_Unistall')){
                            amountInfo = new AmountInfo();
                            amountInfo.productLicName = mat.Product_LIC_Name__c;
                            amountInfo.configurationItemId = prodNameToConfigItemMap.get(mat.Product_LIC_Name__c);
                            amountInfo.amountValue = mapNameToPenalties.get(field);
                            //amountInfo.monthLimit = Integer.valueOf(num);
                            amountInfo.amountKind = AmountB2wKind.UNISTALL;
                            //resultWr.unistallPenalties.put(unistallCounter, amountInfo);
                            mapRetUnistall.put(unistallCounter, amountInfo); // mapNameToPenalties.get(field)
                            //add always to the main list
                            //resultWr.globalPenalties.put(unistallCounter, amountInfo);
                            mapRet.put(unistallCounter, amountInfo); // mapNameToPenalties.get(field)
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Pen_Unistall key=' + unistallCounter);
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Pen_Unistall amountInfo=' + amountInfo);
                            unistallCounter = unistallCounter + 1;
                        }
                        //}
                    }
                    else if(String.isNotBlank(field) && field.containsIgnoreCase('otp')){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ field opt=' + field);
                        if(field.indexOf('M')>=0){
                            amountInfo = new AmountInfo();
                            num = field.substring(field.indexOf('M') + 2, field.lastIndexOf('M'));
                            amountInfo.productLicName = mat.Product_LIC_Name__c;
                            amountInfo.configurationItemId = prodNameToConfigItemMap.get(mat.Product_LIC_Name__c);
                            amountInfo.amountValue = mapNameToPenalties.get(field);
                            amountInfo.monthLimit = Integer.valueOf(num);
                            amountInfo.amountKind = AmountB2wKind.PENALTY;
                            //resultWr.optionAmounts.put(num, amountInfo);
                            mapOption.put(Integer.valueOf(num), amountInfo); // mapNameToPenalties.get(field)
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Otp key=' + num);
                            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Otp amountInfo=' + amountInfo);
                            //mapOption.put(Integer.valueOf(num), mapNameToPenalties.get(field));
                            //resultWr.optionAmountForConfigItem.put(prodNameToConfigItemMap.get(mat.Product_LIC_Name__c), mapNameToPenalties.get(field));
                        }
                    }
                }

                if(!mapRet.isEmpty()){
                    //listRet.add(mapRet);
                    resultWr.globalPenalties.add(mapRet);
                }
                if(!mapRetUnistall.isEmpty()){
                    //listUnistallRet.add(mapRetUnistall);
                    resultWr.unistallPenalties.add(mapRetUnistall);
                }
                if(!mapOption.isEmpty()){
                    //listOptionRet.add(mapOption);
                    resultWr.optionAmounts.add(mapOption);
                }
            }
            
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createMapPenalties ='+resultWr.globalPenalties);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createMapPenalties UNISTALL ='+resultWr.unistallPenalties);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createMapPenalties OPTION ='+resultWr.optionAmounts);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'penaltyAmountForConfigItem ='+resultWr.penaltyAmountForConfigItem);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'optionAmountForConfigItem ='+resultWr.optionAmountForConfigItem);
        /*result.put('GlobalPenalty',listRet);
        result.put('UnistallPenalty',listUnistallRet);
        result.put('OptionPenalty',listOptionRet);*/
        /*return resultWr;
    }*/


    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com && Monica Cutillo - mcutillo@deloitte.it
     * @description Creates the list map penalties.
     * @param listMatRows the list mat rows
     * @param prodNameToBillingModelMap
     * @param prodNameToConfigItemListMap
     * @return the MAP with Lista data > 'GlobalPenalty', 'UnistallPenalty' and 'OptionPenalty'
     */
    private static B2wAmountsCalculation createListMapPenalties(List<NE__Matrix_Parameter_Row__c> listMatRows, Map<String,String> prodNameToBillingModelMap, Map<String,List<Id>> prodNameToConfigItemListMap) {
        B2wAmountsCalculation resultWr = new B2wAmountsCalculation();
        resultWr.initWrapper();

        Map<String,List<Map<Integer, String>>> result = new Map<String,List<Map<Integer, String>>>();
        Map<Integer, List<AmountInfo>> mapRet;
        Map<Integer, List<AmountInfo>> mapRetUnistall;
        Map<Integer, List<AmountInfo>> mapOption;

        String num;
        Integer unistallCounter = 0;
        List<String> listNames;
        Map<String, String> mapNameToPenalties;
        AmountInfo amountInfo;
        for(NE__Matrix_Parameter_Row__c mat : listMatRows) {

            if(prodNameToBillingModelMap.get(mat.Product_LIC_Name__c) == mat.XC_Payment_Model__c){
                mapRet = new Map<Integer, List<AmountInfo>>();
                mapRetUnistall = new Map<Integer, List<AmountInfo>>();
                mapOption = new Map<Integer, List<AmountInfo>>();
                mapNameToPenalties = createMapPenalties(mat);
                listNames = new List<String>{mat.XC_Offline_Name_01__c, mat.XC_Offline_Name_02__c, mat.XC_Offline_Name_03__c,
                                            mat.XC_Offline_Name_04__c, mat.XC_Offline_Name_05__c, mat.XC_Offline_Name_06__c,
                                            mat.XC_Offline_Name_07__c, mat.XC_Offline_Name_08__c, mat.XC_Offline_Name_09__c,
                                            mat.XC_Offline_Name_10__c, mat.XC_Offline_Name_11__c, mat.XC_Offline_Name_12__c,
                                            mat.XC_Offline_Name_13__c, mat.XC_Offline_Name_14__c, mat.XC_Offline_Name_15__c,
                                            mat.XC_Offline_Name_16__c, mat.XC_Offline_Name_17__c, mat.XC_Offline_Name_18__c,
                                            mat.XC_Offline_Name_19__c, mat.XC_Offline_Name_20__c, mat.XC_Offline_Name_21__c,
                                            mat.XC_Offline_Name_22__c, mat.XC_Offline_Name_23__c, mat.XC_Offline_Name_24__c,
                                            mat.XC_Offline_Name_25__c, mat.XC_Offline_Name_26__c, mat.XC_Offline_Name_27__c,
                                            mat.XC_Offline_Name_28__c, mat.XC_Offline_Name_29__c, mat.XC_Offline_Name_30__c};
                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ createListMapPenalties - listNames=' + listNames);
                for(String field : listNames) {
                    if(String.isNotBlank(field) && field.containsIgnoreCase('pen')){
                        if(field.indexOf('M')>=0){
                            amountInfo = new AmountInfo();
                            num = field.substring(field.indexOf('M') + 2, field.lastIndexOf('M'));
                            if(String.isNotBlank(num)) {
                                for(Id confItemId : prodNameToConfigItemListMap.get(mat.Product_LIC_Name__c)) {
                                    amountInfo.productLicName = mat.Product_LIC_Name__c;
                                    amountInfo.configurationItemId = confItemId;
                                    amountInfo.amountValue = mapNameToPenalties.get(field);
                                    amountInfo.monthLimit = Integer.valueOf(num);
                                    amountInfo.amountKind = AmountB2wKind.PENALTY;
                                    if(mapRet.containsKey(Integer.valueOf(num))) {
                                        mapRet.get(Integer.valueOf(num)).add(amountInfo);
                                    } else {
                                        mapRet.put(Integer.valueOf(num), new List<AmountInfo>{amountInfo});
                                    }
                                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Pen key=' + num);
                                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Pen amountInfo=' + amountInfo);
                                }
                            }
                        }
                        //if(field.containsIgnoreCase('pen') && !field.containsIgnoreCase('Pen_Unistall')){
                        if(field.containsIgnoreCase('Pen_Unistall')){
                            for(Id confItemId : prodNameToConfigItemListMap.get(mat.Product_LIC_Name__c)) {
                                amountInfo = new AmountInfo();
                                amountInfo.productLicName = mat.Product_LIC_Name__c;
                                amountInfo.configurationItemId = confItemId;
                                amountInfo.amountValue = mapNameToPenalties.get(field);
                                amountInfo.amountKind = AmountB2wKind.UNISTALL;
                                if(mapRetUnistall.containsKey(unistallCounter)) {
                                    mapRetUnistall.get(unistallCounter).add(amountInfo);
                                } else {
                                    mapRetUnistall.put(unistallCounter, new List<AmountInfo>{amountInfo});
                                }
                                if(mapRet.containsKey(unistallCounter)) {
                                    mapRet.get(unistallCounter).add(amountInfo);
                                } else {
                                    mapRet.put(unistallCounter, new List<AmountInfo>{amountInfo}); // mapNameToPenalties.get(field)
                                }
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Pen_Unistall key=' + unistallCounter);
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Pen_Unistall amountInfo=' + amountInfo);
                            }
                            unistallCounter = unistallCounter + 1;
                        }
                        //}
                    }
                    else if(String.isNotBlank(field) && field.containsIgnoreCase('otp')){
                        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ field opt=' + field);
                        if(field.indexOf('M')>=0){
                            for(Id confItemId : prodNameToConfigItemListMap.get(mat.Product_LIC_Name__c)) {
                                amountInfo = new AmountInfo();
                                num = field.substring(field.indexOf('M') + 2, field.lastIndexOf('M'));
                                amountInfo.productLicName = mat.Product_LIC_Name__c;
                                amountInfo.configurationItemId = confItemId;
                                amountInfo.amountValue = mapNameToPenalties.get(field);
                                amountInfo.monthLimit = Integer.valueOf(num);
                                amountInfo.amountKind = AmountB2wKind.PENALTY;
                                if(mapOption.containsKey(Integer.valueOf(num))) {
                                    mapOption.get(Integer.valueOf(num)).add(amountInfo);
                                } else {
                                    mapOption.put(Integer.valueOf(num), new List<AmountInfo>{amountInfo});
                                }
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Otp key=' + num);
                                XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ Otp amountInfo=' + amountInfo);
                            }
                        }
                    }
                }

                if(!mapRet.isEmpty()){
                    //listRet.add(mapRet);
                    resultWr.globalPenaltiesList.add(mapRet);
                }
                if(!mapRetUnistall.isEmpty()){
                    //listUnistallRet.add(mapRetUnistall);
                    resultWr.unistallPenaltiesList.add(mapRetUnistall);
                }
                if(!mapOption.isEmpty()){
                    //listOptionRet.add(mapOption);
                    resultWr.optionAmountsList.add(mapOption);
                }
            }
            
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createMapPenalties ='+resultWr.globalPenaltiesList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createMapPenalties UNISTALL ='+resultWr.unistallPenaltiesList);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'createMapPenalties OPTION ='+resultWr.optionAmountsList);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'penaltyAmountForConfigItem ='+resultWr.penaltyAmountForConfigItem);
        //XC_UTIL_Debug.debug(DEBUGACTIVE, 'optionAmountForConfigItem ='+resultWr.optionAmountForConfigItem);
        /*result.put('GlobalPenalty',listRet);
        result.put('UnistallPenalty',listUnistallRet);
        result.put('OptionPenalty',listOptionRet);*/
        return resultWr;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Creates the map penalties.
     * @param mat the mat
     * @return the map
     */
    
    public static Map<String, String> createMapPenalties(NE__Matrix_Parameter_Row__c mat) {

        Map<String, String> mapRet = new Map<String, String>();
        String fieldName;
        String fieldValue;
        Integer i = 1;

        while(i<=30) {

            if(i < 10) {
                fieldName = 'XC_Offline_Name_0' + i + '__c';
                fieldValue = 'XC_Offline_Value_0' + i + '__c';
            } else {
                fieldName = 'XC_Offline_Name_' + i + '__c';
                fieldValue = 'XC_Offline_Value_' + i + '__c';
            }
            if(String.isNotBlank((String)mat.get(fieldName)) && 
                String.isNotBlank((String)mat.get(fieldValue))) {
                mapRet.put((String)mat.get(fieldName), (String)mat.get(fieldValue));
            }

            i = i+1;
        }

        XC_UTIL_Debug.debug(DEBUGACTIVE, mapRet);

        return mapRet;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
     * @description Gets the list query parameters.
     * @param queryWr 
     */
    private static void getListQueryParameters(QueryWrapper queryWr) {
        Set<String> billMod =  new Set<String>();
        for(Asset a : queryWr.listAsset) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'Asset='+a);
            queryWr.listProdNames.add(a.NE__ProdId__r.XC_LIC_Product_Name__c);
            /*if(!a.NE__AssetItemAttributes__r.isEmpty()) {
                queryWr.listPaymentModels.add(a.NE__AssetItemAttributes__r[0].NE__Value__c);  
            }*/
            if(String.isNotBlank(a.XC_BillingModel__c)) {
                //queryWr.listPaymentModels.add(a.XC_BillingModel__c);
                billMod.add(a.XC_BillingModel__c);
                queryWr.prodNameToBillingModelMap.put(a.NE__ProdId__r.XC_LIC_Product_Name__c, a.XC_BillingModel__c);
                queryWr.prodNameToConfigItemMap.put(a.NE__ProdId__r.XC_LIC_Product_Name__c, a.XC_Configuration_Item__c);
                if(queryWr.prodNameToConfigItemListMap.containsKey(a.NE__ProdId__r.XC_LIC_Product_Name__c)) {
                    queryWr.prodNameToConfigItemListMap.get(a.NE__ProdId__r.XC_LIC_Product_Name__c).add(a.XC_Configuration_Item__c);
                } else {
                    queryWr.prodNameToConfigItemListMap.put(a.NE__ProdId__r.XC_LIC_Product_Name__c, new List<Id>{a.XC_Configuration_Item__c});
                }
            }
            queryWr.listRegions.add(a.XC_Address__r.XC_PricinRegion__c);
            
        }
        queryWr.listPaymentModels.addAll(billMod);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'queryWr.listRegions='+queryWr.listRegions);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'queryWr.listPaymentModels='+queryWr.listPaymentModels);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'queryWr.prodNameToBillingModelMap='+queryWr.prodNameToBillingModelMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'queryWr.prodNameToConfigItemMap='+queryWr.prodNameToConfigItemMap);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'queryWr.prodNameToConfigItemListMap='+queryWr.prodNameToConfigItemListMap);
    }

}