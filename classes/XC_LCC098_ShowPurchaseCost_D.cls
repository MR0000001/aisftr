/**
 * The Class XC_LCC098_ShowPurchaseCost_D.
 * @author Lorenzo Orlanducci, Federico Amici
 * @date Creation 28/02/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC098_ShowPurchaseCost -  The controller for the XC_LCC098_ShowPurchaseCost component computes
 *   the product cost
 */

public without sharing class XC_LCC098_ShowPurchaseCost_D {

     /**
     * @description  The Class MatrixWrapper.
     */
    public class MatrixWrapper {
        public String bundleName;
        public List<String> listProdNames;
        public List<String> listPaymentModels; 
        public List<String> listRegions;
    }


	/**
	 * @description Gets the current asset.
	 * @param recordId the record id
	 * @return the current asset
	 */
	public static List<Asset> getCurrentAsset(String recordId) {

		Map<Id,Asset> listAssetMap = new Map<Id,Asset>([SELECT Id, Name, Status, NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, XC_ActivationDate__c,
                                            XC_Address__r.XC_PricinRegion__c,
                                            (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                            WHERE Name LIKE 'Modalidad de contratacion%' OR
                                                  Name = 'Modelo de Pago'
                                            LIMIT 1) 
                                    FROM Asset 
                                    WHERE id =:recordId AND Status = 'Active'
                                    limit 1]);
        List<Asset> listAsset = listAssetMap.values();

        return listAsset;
	}

	/**
	 * @description Gets the related asset.
	 * @param recordId the record id
	 * @return the related asset
	 */
	public static List<Asset> getRelatedAsset(String recordId) {

		Map<Id,Asset> listAssetMap = new Map<Id,Asset>([SELECT Id, Name, Status, NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.Name, XC_ActivationDate__c,
                                            XC_Address__r.XC_PricinRegion__c,
                                            (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                            WHERE Name LIKE 'Modalidad de contratacion%' OR
                                                  Name = 'Modelo de Pago'
                                            LIMIT 1)
                                    FROM 	Asset 
                                    WHERE 	NE__Bundle_Configuration__c = :recordId OR
                                    		parentID = :recordId]);
        List<Asset> listAsset = listAssetMap.values();

        return listAsset;
	}

    /**
     * @description Gets the list parameter rows.
     * @param wr the wr
     * @return the list parameter rows
     */
    public static List<NE__Matrix_Parameter_Row__c> getListParameterRows(MatrixWrapper wr) {
        Map<Id,NE__Matrix_Parameter_Row__c> matrixMap = new Map<Id,NE__Matrix_Parameter_Row__c>([SELECT Id, XC_Value1__c, Product_LIC_Name__c, XC_Payment_Model__c,
                                                    XC_Region__c, XC_Offline_Name_01__c, XC_Offline_Value_01__c, XC_Offline_Name_02__c, XC_Offline_Value_02__c,
                                                    XC_Offline_Name_03__c, XC_Offline_Value_03__c, XC_Offline_Name_04__c, XC_Offline_Value_04__c,
                                                    XC_Offline_Name_05__c, XC_Offline_Value_05__c, XC_Offline_Name_06__c, XC_Offline_Value_06__c,
                                                    XC_Offline_Name_07__c, XC_Offline_Value_07__c, XC_Offline_Name_08__c, XC_Offline_Value_08__c,
                                                    XC_Offline_Name_09__c, XC_Offline_Value_09__c, XC_Offline_Name_10__c, XC_Offline_Value_10__c,
                                                    XC_Offline_Name_11__c, XC_Offline_Value_11__c, XC_Offline_Name_12__c, XC_Offline_Value_12__c,
                                                    XC_Offline_Name_13__c, XC_Offline_Value_13__c, XC_Offline_Name_14__c, XC_Offline_Value_14__c,  
                                                    XC_Offline_Name_15__c, XC_Offline_Value_15__c, XC_Offline_Name_16__c, XC_Offline_Value_16__c, 
                                                    XC_Offline_Name_17__c, XC_Offline_Value_17__c, XC_Offline_Name_18__c, XC_Offline_Value_18__c, 
                                                    XC_Offline_Name_19__c, XC_Offline_Value_19__c, XC_Offline_Name_20__c, XC_Offline_Value_20__c, 
                                                    XC_Offline_Name_21__c, XC_Offline_Value_21__c, XC_Offline_Name_22__c, XC_Offline_Value_22__c, 
                                                    XC_Offline_Name_23__c, XC_Offline_Value_23__c, XC_Offline_Name_24__c, XC_Offline_Value_24__c, 
                                                    XC_Offline_Name_25__c, XC_Offline_Value_25__c, XC_Offline_Name_26__c, XC_Offline_Value_26__c, 
                                                    XC_Offline_Name_27__c, XC_Offline_Value_27__c, XC_Offline_Name_28__c, XC_Offline_Value_28__c, 
                                                    XC_Offline_Name_29__c, XC_Offline_Value_29__c, XC_Offline_Name_30__c, XC_Offline_Value_30__c
                                                    FROM NE__Matrix_Parameter_Row__c 
                                                    WHERE XC_Value1__c = :wr.bundleName AND
                                                    Product_LIC_Name__c IN :wr.listProdNames AND
                                                    XC_Payment_Model__c IN :wr.listPaymentModels AND
                                                    XC_Region__c IN :wr.listRegions]);
        List<NE__Matrix_Parameter_Row__c> matrix = matrixMap.values();
        return matrix;
    }

}