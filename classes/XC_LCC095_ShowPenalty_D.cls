/**
 * @author Lorenzo Orlanducci, Federico Amici
 * @date Creation 28/02/2019
 * @date Modification dd/mm/yyyy
 * @description XC_LCC095_ShowPenalty -  DAO for the XC_LCC095_ShowPenalty class
 */

public without sharing class XC_LCC095_ShowPenalty_D {

    /** @description MatrixWrapper */
    public class MatrixWrapper {
        public String bundleName;
        public List<String> listProdNames;
        public List<String> listPaymentModels;
        public List<String> listRegions;
        public Date assetDate;
    }

	/**
	 * @description Gets the current asset
	 * @param recordId the record id
	 * @return the current asset
	 */
	public static List<Asset> getCurrentAsset(String recordId) {
        if(!Schema.sObjectType.Asset.isAccessible()) {
            return new List<Asset>();
        }
		Map<Id, Asset> mapAsset = new Map<Id, Asset>([SELECT Id, Name, Status, NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.LIC_Name__c, NE__Bundle__r.Name, XC_ActivationDate__c,
                                                             XC_Address__r.XC_PricinRegion__c, XC_BillingModel__c, XC_LegalEntity__c, NE__ProdId__r.XC_LIC_Product_Name__c,
                                                             XC_Segment__c,
                                                             XC_Configuration_Item__c,
                                                             (SELECT ID, name, NE__Value__c FROM NE__AssetItemAttributes__r 
                                                             WHERE Name LIKE 'Modalidad de contratacion%' OR
                                                                     Name = 'Modelo de Pago'
                                                             LIMIT 1) 
                                                     FROM Asset 
                                                     WHERE id =:recordId //AND Status = 'Active'
                                                     LIMIT 1]);
        return mapAsset.values();
	}

	/**
	 * @description Gets the related asset
	 * @param recordId the record id
	 * @return the related asset
	 */
	public static List<Asset> getRelatedAsset(String recordId) {
        if(!Schema.sObjectType.Asset.isAccessible()) {
            return new List<Asset>();
        }
		Map<Id, Asset> mapAsset = new Map<Id, Asset>([SELECT Id, Name, Status, NE__ProdId__c, NE__ProdId__r.Name, NE__Bundle__r.LIC_Name__c, NE__Bundle__r.Name, XC_ActivationDate__c,
                                                             XC_Address__r.XC_PricinRegion__c, XC_BillingModel__c, XC_LegalEntity__c, NE__ProdId__r.XC_LIC_Product_Name__c, 
                                                             XC_Segment__c,
                                                             XC_Configuration_Item__c,
                                                                (SELECT ID, name, NE__Value__c 
                                                                FROM NE__AssetItemAttributes__r 
                                                                WHERE Name LIKE 'Modalidad de contratacion%' OR
                                                                      Name = 'Modelo de Pago'
                                                                LIMIT 1)
                                                      FROM Asset 
                                                      WHERE NE__Bundle_Configuration__c = :recordId OR parentID = :recordId]);
        return mapAsset.values();
	}

    /**
     * @description Gets the list parameter rows
     * @param wr - MatrixWrapper
     * @return matrix - List<NE__Matrix_Parameter_Row__c>
     */
    public static List<NE__Matrix_Parameter_Row__c> getListParameterRows(MatrixWrapper wr) {
        System.debug('getListParameterRows = '+wr);
        if(!Schema.sObjectType.NE__Matrix_Parameter_Row__c.isAccessible()) {
            return new List<NE__Matrix_Parameter_Row__c>();
        }
        List<NE__Matrix_Parameter_Row__c> matrix = [SELECT Id, XC_Value1__c, XC_BundleLicName__c, Product_LIC_Name__c, XC_Payment_Model__c, 
                                                    XC_Region__c, NE__Start_Date__c, NE__End_Date__c, 
                                                    XC_Offline_Name_01__c, XC_Offline_Value_01__c, XC_Offline_Name_02__c, XC_Offline_Value_02__c,
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
                                                    WHERE XC_BundleLicName__c = :wr.bundleName AND	//XC_Value1__c	//DEFECT 2904 - MC 20200321
                                                    Product_LIC_Name__c IN :wr.listProdNames AND
                                                    XC_Payment_Model__c IN :wr.listPaymentModels AND
                                                    XC_Region__c IN :wr.listRegions AND
                                                    NE__Start_Date__c <= :wr.assetDate AND
                                                    (NE__End_Date__c >= :wr.assetDate OR NE__End_Date__c = null)
                                                    ORDER BY NE__Start_Date__c DESC
                                                    ];
        return matrix;
    }

}