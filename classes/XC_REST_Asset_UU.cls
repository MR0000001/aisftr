/**
 * @description The Class XC_REST_Asset_UU.
 * @author Federico Amici - federico.amici@nttdata.com
 * @date Creation 06/05/2019
 * @description REST Utility Class for XC_REST_Asset_U class
 */ 
public with sharing class XC_REST_Asset_UU {

    /**
    * @description sets the date fields on the asset
    * @param res the asset
    * @param params the asset wrapper
    * @return the asset with the populated fields
    */
    public static Asset setAssetFields(Asset res, XC_REST_Asset_U.WrapperAssetRequest params){

        Map<String, Object> mapField = new Map<String, Object>{'XC_LegalEntity__c' => params.Asset.LegalEntity,
                                                                'Name' => params.Asset.AssetName, 
                                                                'Status' => params.Asset.Status, 
                                                                'AccountId' => params.Asset.AccountID,
                                                                'NE__BaseRecurringCharge__c' => params.Asset.BaseRecurringCharge,
                                                                'ContactId' => params.Asset.ContactID, 
                                                                'Quantity' => params.Asset.Quantity, 
                                                                'SerialNumber' => params.Asset.SerialNumber,
                                                                'CurrencyIsoCode' => params.Asset.currency_r,
                                                                'XC_Address__c' => (string.isBlank(params.Asset.POSID)) ? null : [Select id, XC_Address__c from XC_PointOfService__c where id =: params.Asset.POSID][0].XC_Address__c, 
                                                                'XC_Address__c' => params.Asset.AddressID, 
                                                                'IsCompetitorProduct' => (String.isNotBlank(params.asset.competitorAsset)) ? (params.asset.competitorAsset=='Y') : null, // Y => true, F => false
                                                                'NE__ProdId__c' => params.Asset.ProdID,
                                                                // 'Brand' => ,
                                                                'NE__CatalogItem__c' => params.Asset.CatalogItemID,
                                                                'XC_BillingModel__c' => params.Asset.PaymentType,
                                                                'XC_PaymentMethod__c' => params.Asset.PaymentMethod,
                                                                'XC_BillingProfileLineItem__c' => params.Asset.BillingProfileID,
                                                                'NE__BaseOneTimeFee__c' => params.Asset.BaseOneTimeFee,
                                                                'NE__Bundle_Configuration__c' => params.Asset.BundleConfiguration,
                                                                'XC_Model__c' => params.Asset.Model,
                                                                'XC_Product_Type__c' => params.Asset.ProductType,
                                                                'XC_Product_Subtype__c' => params.Asset.ProductSubtype,
                                                                'ParentId' => params.Asset.ParentAsset,
                                                                'XC_ElectricalConnectionType__c' => params.Asset.ElectricalConnectionType,
                                                                'XC_AssociateToCustomer__c' => params.Asset.AssociateToCustomer,
                                                                'XC_SpecialOfferType__c' => params.Asset.SpecialOfferType
                                                            };

        for (String field : mapField.keySet()) {
            if ( mapField.get(field)!=null && mapField.get(field)+'' != '') {
                res.put(field, mapField.get(field));
            }    
        }
 
        if (string.isBlank(params.Asset.POSID) && string.isNotBlank(params.Asset.AddressID)) {
            res.XC_Address__c = params.Asset.AddressID;
        } 

        res = setAssetDateFields(res, params);
        
        return res;
    }

    private static Asset setAssetDateFields(Asset res, XC_REST_Asset_U.WrapperAssetRequest params){ 

        Map<String, String> mapDateField = new Map<String, String>{'PurchaseDate' => params.Asset.PurchaseDate, 
                                                                    'InstallDate' => params.Asset.InstallDate, 
                                                                    'UsageEndDate' => params.Asset.UsageEndDate,
                                                                    'XC_Warranty_End_Date__c' => params.Asset.warrantyEndDate
                                                                    };

        for (String field : mapDateField.keySet()) {
            if ( String.isNotBlank(mapDateField.get(field)) ) {
                res.put(field, Date.valueOf(mapDateField.get(field)));
            }    
        }

        return res;
    }


    /**
     * @description Update Asset's children
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 07/06/2019
     * @param status - String
     * @param listAsset - List<Asset>
     */
    private static void updateChildrenAsset(String status, List<Asset> listAsset) {
        //  Propagate Status field in Asset's children
        List<Asset> listChildAsset = new List<Asset>();
        for(Asset asset : listAsset) {
            listChildAsset.addAll(asset.NE__Assets4__r);
            listChildAsset.addAll(asset.ChildAssets);
        } 
        for(Asset asset : listChildAsset) {
            asset.Status = status;
        }
        XC_UTIL_Sobject.updateListrecords(listChildAsset);
    }
    
    /**
     * @description Update asset by subscription
     * @param params - WrapperAssetRequest
     * @return the List<Asset>
     */
    public static List<Asset> updateAssetBySubscription(XC_REST_Asset_U.WrapperAssetRequest params){
        String assetStatus; 
        List<Asset> res = new List<Asset>();
        if(params.asset.Status == Label.XC_CL_Asset_StatusSuspended){
            assetStatus = Label.XC_CL_Asset_StatusActive;
        } else if(params.asset.Status == Label.XC_CL_Asset_StatusActive){
            assetStatus = Label.XC_CL_Asset_StatusSuspended;
        }
        res = XC_REST_Asset_U_D.getAssetBySusbscription(params.asset.SubscriptionID, assetStatus);
        if(res.isEmpty()) {
            return new List<Asset>();
        }
        for(Asset asset: res){
            asset = XC_REST_Asset_UU.setAssetFields(asset, params);
        }

        updateChildrenAsset(params.Asset.Status, res);

        return res;
    }

    /**
     * @description Address filled.
     * @param mapParams the map params
     * @return true, if successful
     */
    public static boolean addressFilled(Map<string,string> mapParams){
        boolean addressId = String.isNotBlank(mapParams.get('AddressID'));
        boolean otherAddFields = true;
        boolean pos = String.isNotBlank(mapParams.get('POSID'));

        List<String> requiredFields = new List<String>{  
                'StreetType',   
                'Address', 
                'StreetNumber', 
                'ZipCode', 
                'City', 
                'Country',
                'Category',
                'Door',
                'Stair',
                'Province'
                };

        for(String field : requiredFields) {
            if(string.isBlank(mapParams.get(field))) {
                otherAddFields = false;
            }
        }

        return (addressId||otherAddFields||pos);
    }

    /**
    * @description checkCreateDateParams
    * @param params the asset wrapper
    * @return the wrapper result
    */
    public static XC_UTIL_Integration.WrapperResult checkCreateDateParams(XC_REST_Asset_U.WrapperAssetRequest params){

        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        if(String.isNotBlank(params.Asset.PurchaseDate) && !XC_UTIL_RESTInbound.checkDate(params.Asset.PurchaseDate)){
            result.errorMessage = Label.XC_CL_DateFormat_Error+' Asset.PurchaseDate';
            result.errorFlag = true;
            return result;
        }
        if(String.isNotBlank(params.Asset.InstallDate) && !XC_UTIL_RESTInbound.checkDate(params.Asset.InstallDate)){
            result.errorMessage = Label.XC_CL_DateFormat_Error+' Asset.InstallDate';
            result.errorFlag = true;
            return result;
        }
        if(String.isNotBlank(params.Asset.UsageEndDate) && !XC_UTIL_RESTInbound.checkDate(params.Asset.UsageEndDate)){
            result.errorMessage = Label.XC_CL_DateFormat_Error+' Asset.UsageEndDate';
            result.errorFlag = true;
            return result;
        }
        if(String.isNotBlank(params.Asset.WarrantyEndDate) && !XC_UTIL_RESTInbound.checkDate(params.Asset.WarrantyEndDate)){
            result.errorMessage = Label.XC_CL_DateFormat_Error+' Asset.WarrantyEndDate';
            result.errorFlag = true;
            return result;
        }

        return result;
    }

    /**
     * @description Check create params.
     * @param params the params
     * @param mapHeader map header
     * @return the x C UTI L integration. wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult checkCreateParams(XC_REST_Asset_U.WrapperAssetRequest params, Map<String, String> mapHeader){

        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        XC_UTIL_Integration.WrapperResult resultWrapper = XC_UTIL_Integration.validateHeader(mapHeader);
        if(resultWrapper.ErrorFlag) {                                                                       
            result.errorMessage = resultWrapper.errorMessage;
            result.errorFlag = true;
            return result;   
        }

        if(params.Account == null) {                                                                       
            result.errorMessage = Label.XC_CL_MandatoryField + ' Account';
            result.errorFlag = true;
            return result;   
        }

        if(String.isBlank(params.account.AccountID) && String.isBlank(params.account.PrimaryEmail) && String.isBlank(params.account.IdentityNumber)){
            result.errorMessage = 'ERROR. ' + Label.XC_CL_MissingField + ' Account.AccountID, Account.PrimaryEmail or Account.IdentityNumber';
            result.errorFlag = true;
            return result;
        }

        if(params.Asset == null) {                                                                       
            result.errorMessage = Label.XC_CL_MandatoryField + ' Asset';
            result.errorFlag = true;
            return result;   
        }

        Map<String, String> fields = new Map<String, String>{'LegalEntity' => params.Asset.LegalEntity,
                                                                'AssetName' => params.Asset.AssetName, 
                                                                'ContactID' => params.Asset.ContactID, 
                                                                'Currency' => params.Asset.currency_r};

        for(String field : fields.KeySet()) {
            if( String.isBlank(fields.get(field)) ) { 
                result.errorMessage = Label.XC_CL_MandatoryField + ' Asset.' + field;
                result.errorFlag = true;
                return result;
            }
        }

        if(String.isNotBlank(params.Asset.POSID) && [SELECT Id from XC_pointofservice__c where id =: params.Asset.POSID].isEmpty()){
            result.errorMessage = 'POS '+Label.XC_CL_NotFount;
            result.errorFlag = true;
            return result;
        }

        result = XC_REST_Asset_UU.checkCreateDateParams(params);  

        return result;   
    }
    

}