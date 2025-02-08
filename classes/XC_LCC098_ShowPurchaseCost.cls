/**
 * The Class XC_LCC098_ShowPurchaseCost.
 *
 * @author Lorenzo Orlanducci, Federico Amici
 * @date Creation 13/03/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC098_ShowPurchaseCost -  The controller for the XC_LCC098_ShowPurchaseCost component computes
 *   the product cost
 */
public class XC_LCC098_ShowPurchaseCost {
    
    
    private class ListsWrapper {
        List<Asset> listAsset = new List<Asset>();
        List<String> listProdNames = new List<String>(); 
        List<String> listPaymentModels = new List<String>();
        List<String> listRegions = new List<String>();
    }

    /**
     * @description Show cost.
     *
     * @param recordId the record id
     * @return the x C UTI L result wrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper showCost(String recordId){ 

        XC_UTIL_ResultWrapper wr = new XC_UTIL_ResultWrapper();
        wr.success = false;
        /**/
        List<Asset> currentAsset = XC_LCC098_ShowPurchaseCost_D.getCurrentAsset(recordId);

        if(currentAsset.isEmpty()){
            wr.resultMessage = Label.XC_CL_Asset_NoAssetFound;
            return wr;
        }
        List<Asset> relatedAsset = XC_LCC098_ShowPurchaseCost_D.getRelatedAsset(recordId);
        List<Asset> listAsset = new List<Asset>();
        listAsset.add(currentAsset[0]);
        listAsset.addAll(relatedAsset);

        System.debug('### listAsset ### ' + listAsset);

        /******************************************************************************/

        String paymentModel = '';

        /*if(currentAsset[0].Status != 'Active'){
            wr.resultMessage = Label.XC_CL_Asset_MustBeActive;
            return wr;
        }

        if(relatedAsset.isEmpty() ){
            wr.resultMessage = Label.XC_CL_Asset_NoAssetFound;
            return wr;
        }

        if((currentAsset[0].NE__AssetItemAttributes__r).isEmpty()) {
            wr.resultMessage = Label.XC_CL_Asset_NoPaymentLinked;
            return wr;
        }*/       

        List<String> listProdNames = new List<String>();
        List<String> listPaymentModels = new List<String>();
        List<String> listRegions = new List<String>();

        ListsWrapper wrapper = new ListsWrapper();
        wrapper.listAsset = listAsset;
        wrapper.listProdNames = listProdNames;
        wrapper.listPaymentModels = listPaymentModels;
        wrapper.listRegions = listRegions;
        getListQueryParameters(wrapper);

        System.debug('listRegions ### ' + listRegions + ' bundle name ### ' + currentAsset[0].NE__Bundle__r.Name);
        System.debug('paymentModel ### ' + listPaymentModels + ' listAsset ### ' + listAsset);

        XC_LCC098_ShowPurchaseCost_D.MatrixWrapper wrMatrix = new XC_LCC098_ShowPurchaseCost_D.MatrixWrapper();
        wrMatrix.bundleName = currentAsset[0].NE__Bundle__r.Name;
        wrMatrix.listPaymentModels = listPaymentModels;
        wrMatrix.listProdNames = listProdNames;
        wrMatrix.listRegions = listRegions;

        List<NE__Matrix_Parameter_Row__c> matrix = XC_LCC098_ShowPurchaseCost_D.getListParameterRows(wrMatrix);
        System.debug('### matrix query ###' +matrix);

        Integer totalPenalty = 0;

        if(matrix.isEmpty()){
          	wr.resultMessage = Label.XC_CL_Asset_NoPurchaseFound;
            return wr;
        } else { 

          	wr.success = true;
            Date activationDate;
            Date todayDate;
            Double daysBetween;
            Double diff;

            activationDate = Date.valueOf(currentAsset[0].XC_ActivationDate__c);
            todayDate = Date.today();
            daysBetween = Double.valueOf(activationDate.daysBetween(todayDate));
            diff = daysBetween/30;
            System.debug('Entro con '+diff+' mesi');

            

            List<Map<Integer, String>> listMapEndToPenaltyValues = createListMapPenalties(matrix);
            for(Map<Integer, String> m : listMapEndToPenaltyValues) {
                if(m.values().isEmpty() || m.keySet().isEmpty()) {
                    wr.success = false;
                    wr.resultMessage = Label.XC_CL_ProductNotConfigured;
                    return wr;
                }
            }
            System.debug('### listMatrix ### ' + listMapEndToPenaltyValues);

            //Integer offset;
            for(Map<Integer, String> mapEnd : listMapEndToPenaltyValues) {
                totalPenalty += computePenalties(mapEnd, diff);
            }
            wr.resultMessage = Label.XC_CL_Asset_CostIs+' '+totalPenalty+' €';
            wr.objectInfo = String.valueOf(totalPenalty);
           
        }
                
        return wr;
        
    }

    /**
     * @description Compute penalties.
     *
     * @param mapEndPenalties the map end penalties
     * @param months the months
     * @return the integer
     */
    public static Integer computePenalties(Map<Integer, String> mapEndPenalties, Double months) {

        String intEndPenalty;
        Integer totalPenalty = 0;

        for(Integer i : mapEndPenalties.keySet()){
            System.debug('@@@ i @@@' + i);
            if(months <= i){
                /*
                if(String.isBlank(matrix[0].XC_Offline_Value_13__c)){
                   offset = 0;
                }else{
                   offset = Integer.valueOf(matrix[0].XC_Offline_Value_13__c);
                }
                */
                intEndPenalty = (mapEndPenalties.get(i)).replace('.', '');
                totalPenalty += Integer.valueOf(mapEndPenalties.get(i));  //+offset;
                break;
            }
            System.debug('@@@ totalPenalty @@@' + totalPenalty);
            
        }

        return totalPenalty;
    }

    /**
     * @description Creates the list map penalties.
     *
     * @param listMatRows the list mat rows
     * @return the list
     */
    public static List<Map<Integer, String>> createListMapPenalties(List<NE__Matrix_Parameter_Row__c> listMatRows) {

        List<Map<Integer, String>> listRet = new List<Map<Integer, String>>();
        Map<Integer, String> mapRet;

        String num;
        List<String> listNames;
        Map<String, String> mapNameToPenalties;

        for(NE__Matrix_Parameter_Row__c mat : listMatRows) {
            mapRet = new Map<Integer, String>();
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
            for(String field : listNames) {
                if(String.isNotBlank(field) && field.containsIgnoreCase('Otp')) {
                    num = field.substring(field.indexOf('M') + 2, field.lastIndexOf('M'));
                    mapRet.put(Integer.valueOf(num), mapNameToPenalties.get(field));
                }
            }

            /*mapRet.put(Integer.valueOf(mat.XC_Offline_Name_07__c.indexOf('M', mat.XC_Offline_Name_07__c.indexOf('M') + 1)),mat.XC_Offline_Value_07__c);
            mapRet.put(Integer.valueOf(mat.XC_Offline_Name_08__c.indexOf('M', mat.XC_Offline_Name_08__c.indexOf('M') + 1)),mat.XC_Offline_Value_08__c);
            mapRet.put(Integer.valueOf(mat.XC_Offline_Name_09__c.indexOf('M', mat.XC_Offline_Name_09__c.indexOf('M') + 1)),mat.XC_Offline_Value_09__c);
            mapRet.put(Integer.valueOf(mat.XC_Offline_Name_10__c.indexOf('M', mat.XC_Offline_Name_10__c.indexOf('M') + 1)),mat.XC_Offline_Value_10__c);
            mapRet.put(Integer.valueOf(mat.XC_Offline_Name_11__c.indexOf('M', mat.XC_Offline_Name_11__c.indexOf('M') + 1)),mat.XC_Offline_Value_11__c);
            mapRet.put(Integer.valueOf(mat.XC_Offline_Name_12__c.indexOf('M', mat.XC_Offline_Name_12__c.indexOf('M') + 1)),mat.XC_Offline_Value_12__c);
            */
            listRet.add(mapRet);
        }

        System.debug('createMapPenalties ='+listRet);

        return listRet;
    }


    /**
     * @description Creates the map penalties.
     *
     * @param mat the mat
     * @return the map
     */
    @TestVisible
    private static Map<String, String> createMapPenalties(NE__Matrix_Parameter_Row__c mat) {

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

        System.debug(mapRet);

        return mapRet;
    }

    /**
     * @description Gets the list query parameters.
     * @param wrapper
     */
    @TestVisible
    private static void getListQueryParameters(ListsWrapper wrapper) {
        List<Asset> listAsset = wrapper.listAsset;
        List<String> listProdNames = wrapper.listProdNames;
        List<String> listPaymentModels = wrapper.listPaymentModels;
        List<String> listRegions = wrapper.listRegions;
        for(Asset a : listAsset) {
            listProdNames.add(a.name);
            if(!a.NE__AssetItemAttributes__r.isEmpty()) {
                listPaymentModels.add(a.NE__AssetItemAttributes__r[0].NE__Value__c);  
            }
            listRegions.add(a.XC_Address__r.XC_PricinRegion__c);
        }
    }
}