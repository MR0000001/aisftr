/**
* @author Monica Cutillo - monica.cutillo@nttdata.com
* @date Creation 09/10/2019
* @description XC_UTIL_Asset_D – Class DAO for Asset methods
*/ 
public without sharing class XC_UTIL_Asset_D {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Asset'); 

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description getAssetDisconnectionData, we have to go 
     * always on the asset root to have the Contract lookup
     * @param assetId
     * @return related zqu__Quote__c or null!
     */
    public static Asset getAssetDisconnectionData(Id assetId){
        Asset asset = getAssetData(assetId);
        if(asset.NE__Bundle_Configuration__c != null){ //String.isBlank(asset.XC_ZQuoteId__c) &&
            return getAssetData(asset.NE__Bundle_Configuration__c);
        }
        return asset;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description getZQuoteData. Return NULL if it not found data
     * @param zqId
     * @return related zqu__Quote__c
     * /
    public static zqu__Quote__c getZQuoteData(Id zqId){
        Map<Id,zqu__Quote__c> zQuoteData = new Map<Id,zqu__Quote__c>([
            SELECT Id, zqu__ZuoraSubscriptionID__c 
              FROM zqu__Quote__c 
             WHERE Id =: zqId
        ]);
        if(zQuoteData.values().isEmpty()){
            return null;
        }
        return zQuoteData.values()[0];
    }*/

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description query getSubscription From ExternalId
     * @param externalId
     * @return related Zuora__Subscription__c
     */
    public static List<Zuora__Subscription__c> getSubscriptionFromExternalId(String externalId){
        Map<Id,Zuora__Subscription__c> subscriptions = new Map<Id,Zuora__Subscription__c>([
            SELECT Id, Zuora__External_Id__c 
              FROM Zuora__Subscription__c 
             WHERE Zuora__External_Id__c =: externalId
        ]);
        return subscriptions.values();
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description query getPayedInvoiceItem From Subscription
     * @param subscription
     * @return related payed Zuora__InvoiceItem__c
     */
    public static List<Zuora__InvoiceItem__c> getPayedInvoiceItemFromSubscription(Zuora__Subscription__c subscription){
        Map<Id,Zuora__InvoiceItem__c> invoiceItems = new Map<Id,Zuora__InvoiceItem__c>([
            SELECT Id, Zuora__UnitPrice2__c, Zuora__Charge_Amount2__c, Zuora__TaxAmount2__c, Zuora__Invoice__r.Zuora__Balance2__c
              FROM Zuora__InvoiceItem__c 
             WHERE Zuora__Subscription__c =: subscription.Id
               AND Zuora__Invoice__r.Zuora__Balance2__c = 0 //Fix Anomalia 2013 [MC 2020/02/06]
        ]);// Zuora__Subscription__c , Zuora__Subscription__r.Zuora__External_Id__c
        return invoiceItems.values();
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description query getAsetZQuoteData from id
     * @param assetId
     * @return related Asset
     */
    private static Asset getAssetData(Id assetId){
        Map<Id,Asset> assets = new Map<Id,Asset>([
            SELECT Id, XC_ZQuoteId__c, NE__Bundle_Configuration__c, XC_Product_Type__c, XC_Product_Subtype__c, NE__RecurringChargeOv__c, XC_BillingModel__c,
                   XC_ContractStartDate__c, XC_Service_Last_Renewal_Date__c, XC_ContractEndDate__c, XC_Contract__r.ContractNumber, 
                   XC_Contract__r.StartDate, XC_Contract__r.EndDate, XC_ActivationDate__c, XC_LegalEntity__c, NE__ProdId__r.XC_LIC_Product_Name__c, XC_Configuration_Item__c,
                   XC_Subscription__r.Id, XC_SubscriptionId__c, XC_Segment__c
              FROM Asset
             WHERE Id =: assetId
        ]);
        return assets.values()[0];
    }

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getAssetRefundCalculationData
     * @param assetIds
     * @return Assets list
     */
    /*public static Map<Id,Id> getAllBundleRootsId(Set<Id> assetIds){
        Map<Id,Id> result = new Map<Id,Id>();
        Map<Id,Asset> data = new Map<Id,Asset>([
            SELECT id, XC_Product_Type__c, NE__Bundle_Configuration__c
            FROM Asset 
            WHERE ((XC_Product_Type__c =: Label.XC_CL_ProductTypeBundle AND XC_Product_Subtype__c <> 'Parameter' AND NE__Bundle_Configuration__c = null ) 
               OR (XC_Product_Type__c =: Label.XC_CL_ProductTypeEquipment AND NE__Bundle_Configuration__c <> null))
               AND Id IN: assetIds
        ]);

        for(Asset asset : data.values()){
            if(Label.XC_CL_ProductTypeBundle == asset.XC_Product_Type__c){
                result.put(asset.Id,asset.Id);
            }else if(Label.XC_CL_ProductTypeEquipment == asset.XC_Product_Type__c){
                result.put(asset.Id,asset.NE__Bundle_Configuration__c);
            }
        }
        return result;
    }*/

    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description retrieveAllBundleEquipmentData
     * @param bundleRootsId
     * @return Map<Id,List<Asset>>
     */
    /*public static Map<Id,List<Asset>> retrieveAllBundleEquipmentData(Set<Id> bundleRootsId){
        Map<Id,List<Asset>> dataResult = new Map<Id,List<Asset>>();
        Map<Id,Asset> data = new Map<Id,Asset>([
            SELECT id, NE__Bundle_Configuration__c, XC_Product_Subtype__c, Name, SerialNumber
            FROM Asset 
            WHERE XC_Product_Type__c =: Label.XC_CL_ProductTypeEquipment
            AND NE__Bundle_Configuration__c IN: bundleRootsId
        ]);
        for(Asset eqp : data.values()){
            if(dataResult.get(eqp.NE__Bundle_Configuration__c) == null){
                dataResult.put(eqp.NE__Bundle_Configuration__c, new List<Asset>());
            }
            dataResult.get(eqp.NE__Bundle_Configuration__c).add(eqp);
        }
        return dataResult;
    }*/

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description getAssetRefundCalculationData
     * @param assetIds
     * @return Assets list
     */
    /*public static List<Asset> getAssetRefundCalculationData(Set<Id> assetIds){
        Map<Id,Asset> data = new Map<Id,Asset>([
            SELECT id, XC_Product_Type__c, XC_Product_Subtype__c, NE__Bundle__c, NE__Bundle_Configuration__c, Status, 
                   NE__OneTimeFeeOv__c, NE__RecurringChargeOv__c, NE__Activation_Date__c, XC_ActivationDate__c, XC_BillingModel__c
            FROM Asset 
            WHERE Id IN: assetIds
        ]);
        return data.values();
    }*/

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description getAllAssetAssetBundleChildren
     * @param bundleConfigurationId
     * @return Assets list children
     */
    /*public static List<Asset> getAllAssetBundleChildren(Id bundleConfigurationId){
        Map<Id,Asset> data = new Map<Id,Asset>([
            SELECT id, XC_Product_Type__c, XC_Product_Subtype__c, NE__Bundle__c, NE__Bundle_Configuration__c, Status, 
                   NE__OneTimeFeeOv__c, NE__RecurringChargeOv__c, NE__Activation_Date__c, XC_ActivationDate__c, XC_BillingModel__c
            FROM Asset 
            WHERE NE__Bundle_Configuration__c =: bundleConfigurationId
        ]);
        return data.values();
    }*/
	

}