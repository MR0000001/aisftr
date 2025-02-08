/**
 * @description The Class XC_REST_Asset_U.
 * @author Riccardo Cossu - riccardo.cossu@nttdata.com - Simone Trenta - strenta@deloitte.it
 * @date Creation 18/12/2018
 * @description REST Utility Class for Asset Interface
 */ 

public without sharing class XC_REST_Asset_U { 
    
    /**
     * @description The Class WrapperAssetRequest.
     */
    public class WrapperAssetRequest {
        
        /** @description The Asset. */
        public XC_UTIL_Asset.AssetRESTWrapper Asset; 
        
        /** @description The Account. */
        public XC_UTIL_Account.AccountIFWrapper Account;

        /**
         * @description Instantiates a new wrapper asset request.
         */
        public WrapperAssetRequest() {
            Asset = new XC_UTIL_Asset.AssetRESTWrapper();  
            Account = new XC_UTIL_Account.AccountIFWrapper(); 
        }
    }   

    /**
     * @description The Class WrapperAssetResponse.
     */
    public class WrapperAssetResponse {
        
        /** @description The Result. */
        public XC_UTIL_Integration.Result Result;
        
        /** @description The Asset. */
        public XC_UTIL_Asset.AssetRESTWrapper Asset;
        
        /**
         * @description Instantiates a new wrapper asset response.
         */
        public WrapperAssetResponse(){
            result = new XC_UTIL_Integration.Result();
            // Asset = new XC_UTIL_Asset.AssetRESTWrapper();
        }
    }

    /**
     * @description The Class WrapperAssetPUTResponse.
     */
    public class WrapperAssetPUTResponse {
        
        /** @description The Result. */
        public XC_UTIL_Integration.Result Result;
        
        /** @description The Asset. */
        public XC_UTIL_Asset.AssetRESTWrapper[] Asset;
        
        /**
         * @description Instantiates a new wrapper asset PUT response.
         */
        public WrapperAssetPUTResponse(){
            result = new XC_UTIL_Integration.Result();
            // Asset = new XC_UTIL_Asset.AssetRESTWrapper();
        }
    }

    /**
     * @description The Class WrapperListAssetResponse.
     */
    public class WrapperListAssetResponse {
        
        /** @description The Result. */
        public XC_UTIL_Integration.Result Result;
        
        /** @description The Asset. */
        public list<XC_UTIL_Asset.AssetRESTWrapper> Asset;
        
        /**
         * @description Instantiates a new wrapper list asset response.
         */
        public WrapperListAssetResponse(){
            result = new XC_UTIL_Integration.Result();
            //Asset = new XC_UTIL_Asset.AssetRESTWrapper(); 
        }
    }

   
    /**
     * @description Creates the wrapper asset.
     * @param listAss the list ass
     * @return the list
     */
    public static list<XC_UTIL_Asset.AssetRESTWrapper> createWrapperAsset(list<asset> listAss) {
        /*20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset*/
        return createWrapperAsset(listAss, null);
    }


    /**
     * @description Creates the wrapper asset filtered by Client System.
     * @author Lorenzo Evangelisti - lorenzo.evangelisti@webresults.it
     * @date Creation 03/05/2022
     * @param listAss the list ass
     * @return the list
     */
    public static list<XC_UTIL_Asset.AssetRESTWrapper> createWrapperAsset(list<asset> listAss, String clientSystem) {

        /*20220505 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset [start]*/
        String customSettingName = 'GETAsset' + clientSystem;
        XC_CS012_ApiAdditionalInfo__c infos = XC_CS012_ApiAdditionalInfo__c.getValues(customSettingName);
        List<String> fieldList = infos?.XC_AdditionalFields__c?.split(';');
        if(fieldList == null){
            fieldList = new List<String>();
        }
        /*20220505 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset [end]*/
        
        /*20220531 NicoloFodera DateFormat management for commoditySpain [start]*/
        List<String> fieldListDateTimeToDate = infos?.XC_DatetimeToDateFields__c?.split(';');  
        if(fieldListDateTimeToDate == null){fieldListDateTimeToDate = new List<String>();} 
        /*20220531 NicoloFodera DateFormat management for commoditySpain [end]*/

        list<XC_UTIL_Asset.AssetRESTWrapper> assetWrapper = new list<XC_UTIL_Asset.AssetRESTWrapper>();

        for (asset a : listAss) {
            XC_UTIL_Asset.AssetRESTWrapper aw = new XC_UTIL_Asset.AssetRESTWrapper();
            aw.AssetID = a.id;
            aw.AssetName = a.name;
            aw.Status = a.status;
            aw.AccountID = a.accountid;
            aw.AddressID = a.XC_Address__c;
            aw.BaseRecurringCharge = a.NE__BaseRecurringCharge__c;
            aw.ContactID = a.ContactID; 
            aw.Quantity = Integer.valueOf(a.Quantity);
            aw.SerialNumber = a.SerialNumber;
            aw.Currency_r = a.CurrencyIsoCode; //'Currency' non valido
            aw.PurchaseDate = String.valueOf(a.PurchaseDate);
            aw.InstallDate = String.valueOf(a.InstallDate);
            aw.UsageEndDate = String.valueOf(a.UsageEndDate);
            //aw.podId = a.PointofDelivery__c;
            aw.CompetitorAsset = (a.IsCompetitorProduct) ? 'Y' : 'N';
            aw.WarrantyEndDate = String.valueOf(a.XC_Warranty_End_Date__c);
            aw.PenaltyAmount = String.valueOf(a.NE__Penalty_Fee__c);
            aw.ProdName = a.XC_Product_Name__c;
            aw.EngineCode = a.NE__CatalogItem__r.NE__Engine_Code__c;
            aw.ZSubscriptionId = a.XC_Subscription__r.Zuora__External_Id__c;
            aw.ZAccountId = a.XC_Subscription__r.Zuora__CustomerAccount__r.Zuora__External_Id__c;
            aw.CatalogName = a.NE__Catalog__r.Name;
            aw.TotalRepairs = a.XC_NumberOfRepairs__c;
            aw.ActivationDate = String.valueOf(a.NE__Activation_Date__c);
            /*20220531 NicoloFodera DateFormat management for commoditySpain [start]*/
            if(fieldListDateTimeToDate.contains('ActivationDate') && !String.isBlank(aw.ActivationDate)){aw.ActivationDate = aw.ActivationDate.substring(0,10);} 
            /*20220531 NicoloFodera DateFormat management for commoditySpain [end]*/
            aw.ProdID = a.NE__ProdId__c;
            aw.Brand = a.NE__CatalogItem__r.XC_Brand__c;
            aw.CatalogItemID = a.NE__CatalogItem__c;
            aw.PaymentType = a.XC_BillingModel__c;
            aw.PaymentMethod = a.XC_PaymentMethod__c;
            aw.BillingProfileID = a.XC_BillingProfileLineItem__c;
            aw.BaseOneTimeFee = a.NE__BaseOneTimeFee__c;
            aw.BundleConfiguration = a.NE__Bundle_Configuration__c;
            aw.Model = a.XC_Model__c;
            aw.ProductType = a.XC_Product_Type__c;
            aw.ProductSubType = a.XC_Product_Subtype__c;
            aw.ParentAsset = a.ParentId;
            aw.ElectricalConnectionType = a.XC_ElectricalConnectionType__c;
            aw.ElectricalConnectionDate = String.valueOf(a.XC_ElectricalConnectionDate__c);
            aw.AssociateToCustomer = a.XC_AssociateToCustomer__c;
            aw.SpecialOfferType = a.XC_SpecialOfferType__c;
            aw.UsageCode = String.isNotBlank(a.NE__UsageCode__c) ? a.NE__UsageCode__c : a.NE__CatalogItem__r?.NE__UsageCode__c; /*NicoloFodera 20220718 Added NE__CatalogItem__r.NE__UsageCode__c*/
            //mario.a.giordano@accenture.com 18012022 - Numero Contratto
            aw.ContractNumber = a.XC_Contract__r.ContractNumber ;
            /*20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset [start]*/
            if(fieldList.contains('CommodityContractNumber')){
                aw.CommodityContractNumber = a?.XC_BillingProfileLineItem__r?.XC_BillingProfile__r?.XC_CommodityContractID__c;
            }
            if(fieldList.contains('SourceProduct')){
                aw.SourceProduct = a?.NE__ProdId__r?.NE__Source_Product_Id__c;
            }
            /*20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset [end]*/
            assetWrapper.add(aw);
        }

        return assetWrapper;
    }

    /**
     * @description Check read params.
     * @param mapParams the map params
     * @param mapHeader the map of the headers
     * @return the x C UTI L integration. wrapper result
     */
    public static XC_UTIL_Integration.WrapperResult checkReadParams(Map<string,string> mapParams, Map<String, String> mapHeader){
        
        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        XC_UTIL_Integration.WrapperResult resultWrapper = XC_UTIL_Integration.validateHeader(mapHeader);
        if(resultWrapper.ErrorFlag) {
            result.errorMessage = resultWrapper.errorMessage; 
            result.errorFlag = true;
            return result;
        }

        integer fieldsinserted = 0;

        if( XC_REST_Asset_UU.addressFilled(mapParams) ){
            fieldsinserted++;
        }

        if( String.isNotBlank(mapParams.get('AccountID')) || String.isNotBlank(mapParams.get('PrimaryEmail')) || String.isNotBlank(mapParams.get('IdentityNumber')) || String.isNotBlank(mapParams.get('UniqueID'))){
            fieldsinserted++;
        }

        if( string.isNotBlank(mapParams.get('SubscriptionID')) ){
            fieldsinserted++;
        }

        if( string.isNotBlank(mapParams.get('AssetID')) ){
            fieldsinserted++;
        }

        if( fieldsinserted==0 ){
            result.errorMessage = Label.XC_CL_MissingField+' Account, Address, Subscription, AssetID';
            result.errorFlag = true;
            return result;
        }
        
        if( fieldsinserted>1 ){
            result.errorMessage = Label.XC_CL_MandatoryField_One+' Account, Address, Subscription, AssetID';
            result.errorFlag = true;
            return result;
        }
       
        return result;
    }

    /**
    * @description checkUpdateParams
    * @param params the asset wrapper
    * @param mapHeader the mapHeader
    * @return the wrapper result
    */
    public static XC_UTIL_Integration.WrapperResult checkUpdateParams(XC_REST_Asset_U.WrapperAssetRequest params, Map<String, String> mapHeader){ 

        XC_UTIL_Integration.WrapperResult result = new XC_UTIL_Integration.WrapperResult();

        XC_UTIL_Integration.WrapperResult resultWrapper = XC_UTIL_Integration.validateHeader(mapHeader);
        if(resultWrapper.ErrorFlag) {
            result.errorMessage = resultWrapper.errorMessage;
            result.errorFlag = true;
            return result;
        }

        if(params.asset == null) {
            result.errorMessage = Label.XC_CL_MandatoryField+' Asset';
            result.errorFlag = true;
            return result;
        } 

        if(string.isBlank(params.asset.AssetID) && String.isBlank(params.asset.SubscriptionID)) {
            result.errorMessage = 'ERROR. ' + Label.XC_CL_MissingField+' Asset.AssetID or Asset.SubscriptionID';
            result.errorFlag = true;
            return result;
        }

        if(!String.isBlank(params.asset.SubscriptionID) && String.isBlank(params.asset.Status)){
            result.errorMessage = Label.XC_CL_MandatoryField+' Asset.Status';
            result.errorFlag = true;
            return result;
        }
        
        if(String.isNotBlank(params.Asset.POSID) && [SELECT Id from XC_pointofservice__c where id =: params.Asset.POSID].isEmpty()){
            result.errorMessage = 'ERROR. POS '+Label.XC_CL_NotFount;
            result.errorFlag = true;
            return result;
        }

        return result;
    }
    
    /**
     * @description Read.
     *
     * @param mapParams the map params
     * @return the list
     */
    public static List<Asset> readAsset(Map<string,string> mapParams){
        list<Asset> res = new list<Asset>();

        mapParams.put('Method', 'GET'); 

        if(String.isNotBlank(mapParams.get('AccountID')) || String.isNotBlank(mapParams.get('PrimaryEmail')) || String.isNotBlank(mapParams.get('IdentityNumber')) || String.isNotBlank(mapParams.get('UniqueID'))) { 
            res = XC_REST_Asset_U_D.getAssetByAccount(mapParams);      //se ci sono i campi per l'account, cerca per account

        } else if(!String.isBlank(mapParams.get('POSID'))) {
            res = XC_REST_Asset_U_D.getAssetByPOD(mapParams);

        } else if(XC_REST_Asset_UU.addressFilled(mapParams)) {
            res = XC_REST_Asset_U_D.getAssetByAddress(mapParams); //altrimenti, se ci sono i campi per l'address, cerca per address

        } else if(!String.isBlank(mapParams.get('SubscriptionID'))) {
            res = XC_REST_Asset_U_D.getAssetBySusbscription(mapParams.get('SubscriptionID'),'');

        } else if(!String.isBlank(mapParams.get('AssetID'))) {
            res = XC_REST_Asset_U_D.getAssetByAssetID(mapParams.get('AssetID'),'');
        }

        return res;
    }

    /**
     * @description Creates the.
     * @param params the params
     * @param accountId the account id
     * @return the asset
     */
    public static Asset createAsset(XC_REST_Asset_U.WrapperAssetRequest params, String accountId){
        params.Asset.AccountID = accountId;
        return XC_REST_Asset_UU.setAssetFields(new Asset(), params); 
    }

    /**
     * @description Update asset.
     * @param params the params
     * @return the asset
     */
    public static List<Asset> updateAsset(XC_REST_Asset_U.WrapperAssetRequest params){

        List<Asset> res = new List<Asset>();

        if(String.isNotBlank(params.asset.AssetID)){
            Asset a = XC_REST_Asset_U_D.getAssetByID(params.asset.AssetID);

            if(a != null) {
                res.add(XC_REST_Asset_UU.setAssetFields(a, params));
            }

        } else {
            res = XC_REST_Asset_UU.updateAssetBySubscription(params);

        }

        return res;
    }

}