/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 17/12/2018
* @description XC_UTIL_Asset – Util class for Asset methods
*/ 

public without sharing class XC_UTIL_Asset {
    
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Asset'); 

    /** @description PopulateMaintenanceAssetWrapper */
    public class PopulateMaintenanceAssetWrapper {
        public String assetId;
        public List<Asset> maintenanceAssetList = new List<Asset>();
        public MaintenanceWrapper wr = new MaintenanceWrapper();
        public Map<Id, Id> mapAssetMaintenanceAsset = new Map<Id, Id>();
    }

    /** @description Wrapper for Maintenance */
    public class MaintenanceWrapper{
        public Boolean isAssetActive = false;
        public Boolean isMaintenanceAssetActive = false;
        public Integer yearFrequency = 1;
    }
  
    /** @description Wrapper for Asset Rest for REST Interface
    * @author RCossu 
    * @date: 18/12/2018
    */
    public class AssetRESTWrapper {  //Change Parameters
        public String AssetID; 
        public String LegalEntity;
        public String AssetName;
        public String Status;
        public String AddressID;
        public Decimal BaseRecurringCharge;
        public String ContactID;
        public Integer Quantity;
        public String SerialNumber;
        public String Currency_r;   //'Currency' non valido
        public String PurchaseDate;
        public String InstallDate;
        public String UsageEndDate;
        public String POSID;
        public String CompetitorAsset;
        public String WarrantyEndDate;
        public String ProdID;
        public String Brand;
        public String CatalogItemID;
        public String PaymentType;
        public String PaymentMethod;
        public String BillingProfileID;
        public Decimal BaseOneTimeFee;
        public String BundleConfiguration;
        public String Model;
        public String ProductType;
        public String ProductSubType;
        public String ParentAsset;
        public String AccountID;
        public String PODID;
        public String SubscriptionID;
        public String PenaltyAmount;
        public String ProdName;
        public String EngineCode;
        public String ZSubscriptionId;
        public String ZAccountId;
        public String CatalogName;
        public Decimal TotalRepairs;
        public String ActivationDate;
        public String ElectricalConnectionType;
        public String ElectricalConnectionDate;
        public String CatalogCategoryID;
        public String CatalogID;
        public Boolean AssociateToCustomer;
        public String SpecialOfferType;
        public String UsageCode;
        //mario.a.giordano@accenture.com 18012022 - Numero contratto
        public String ContractNumber;
        /*20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset [start]*/
        public String CommodityContractNumber;
        public String SourceProduct;
        /*20220429 LorenzoEvangelisti NR2476 Add CommodityContractNumber and SourceProduct fields in read Asset [end]*/
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to get a Map assetId -> Maintenance Asset Active
     * @param listAssetIds - List<String>
     * @return Map<Id, MaintenanceWrapper>
    **/
    public static Map<Id, MaintenanceWrapper> getMapAssetMaintenance(List<String> listAssetIds){ 
        XC_UTIL_Asset_U.AssetMaintenanceWrapper assetMaintenanceWrapper = XC_UTIL_Asset_U_PopulateWrappers.populateAssetMaintenanceWrapper(listAssetIds);
        Map<Id, Id> mapAssetMaintenanceAsset = assetMaintenanceWrapper.mapAssetMaintenanceAsset; //map that assigns to each Asset the corresponding Maintenance Asset
        Map<Id, Id> mapAssetBundleAsset = assetMaintenanceWrapper.mapAssetBundleAsset; //map that assigns to each Asset the corresponding bundle Asset
        Map<Id, MaintenanceWrapper> mapAssetMaintenanceWrapper = assetMaintenanceWrapper.mapAssetMaintenanceWrapper;
		Boolean skipCheckOnYearFrequency = assetMaintenanceWrapper.skipCheckYearFrequency;
        if(!mapAssetBundleAsset.isEmpty()){ 
            Map<Id, Asset> mapBundle = retrieveMapBundleAssetMaintenance(mapAssetBundleAsset.values()); //retrieveMapBundleAssetByChildrenType(mapAssetBundleAsset.values(), Label.XC_CL_Product_Maintenance);
            for(String assetId : mapAssetBundleAsset.keySet()){
                String bundleId = mapAssetBundleAsset.get(assetId); 
                if(mapBundle.containsKey(bundleId)){
                    List<Asset> maintenanceAssetList = mapBundle.get(bundleId).NE__Assets4__r;
                    PopulateMaintenanceAssetWrapper populateWrapper = new PopulateMaintenanceAssetWrapper();
                    populateWrapper.assetId = assetId;
                    populateWrapper.maintenanceAssetList = maintenanceAssetList;
                    populateWrapper.mapAssetMaintenanceAsset = mapAssetMaintenanceAsset;
                    XC_UTIL_Asset_U_PopulateWrappers.populateMaintenanceAsset(populateWrapper);
                    MaintenanceWrapper wr = populateWrapper.wr;
                    mapAssetMaintenanceAsset = populateWrapper.mapAssetMaintenanceAsset;
                    mapAssetMaintenanceWrapper.put(assetId, wr);
                }
            }
        }

       /*if(!mapAssetMaintenanceAsset.isEmpty()){ 
            Map<Id, Asset> mapAssetMaintenance = retrieveMapAssetByAttributeName(mapAssetMaintenanceAsset.values(), Label.XC_CL_Attribute_MaintenanceType); 
            for(String assetId : mapAssetMaintenanceAsset.keySet()){
                Id assetMaintenanceId = mapAssetMaintenanceAsset.get(assetId);
                if(mapAssetMaintenance.containsKey(assetMaintenanceId)){ 
                    List<NE__AssetItemAttribute__c > maintenanceAssetAttributes = mapAssetMaintenance.get(assetMaintenanceId).NE__AssetItemAttributes__r;
                    if(!maintenanceAssetAttributes.isEmpty()){
                        NE__AssetItemAttribute__c attr = maintenanceAssetAttributes[0];
                        Integer yearFrequency = getYearFrequency(attr.NE__Value__c);
                        if(yearFrequency > 0){
                            MaintenanceWrapper wr = mapAssetMaintenanceWrapper.get(assetId);
                            wr.yearFrequency = yearFrequency;
                        }
                    }
                }  
            }  
        }*/
    if(!mapAssetMaintenanceAsset.isEmpty()){ 
            Map<Id, String> mapAssetMaintenance = retrieveMapDocumentationCharacterist(mapAssetMaintenanceAsset.values()); 
            for(String assetId : mapAssetMaintenanceAsset.keySet()){
                Id assetMaintenanceId = mapAssetMaintenanceAsset.get(assetId);
                if(mapAssetMaintenance.containsKey(assetMaintenanceId)){ 
                    Integer yearFrequency = getYearFrequency(mapAssetMaintenance.get(assetMaintenanceId));
                    XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@yearFrequency' + yearFrequency);
                    if(!skipCheckOnYearFrequency){
                    	MaintenanceWrapper wr = XC_UTIL_Asset_U.checkYear(yearFrequency, mapAssetMaintenanceWrapper, assetId);
                    }else{
                        MaintenanceWrapper wr = mapAssetMaintenanceWrapper.get(assetId);
            			wr.yearFrequency = yearFrequency;
                    }
                }  
            } 
        }
    
        return mapAssetMaintenanceWrapper; 
    }

    /**
     * @author Roberta Porrega - roberta.porrega@nttdata.com 
     * @description Method to get a Map assetId 
     * @param listAssetIds 
     * @return Map<Id, String> 
    **/
    public static Map<Id, String> retrieveMapDocumentationCharacterist(List<String> listAssetIds){
        Map<Id, String> mapAssetFrequency = new Map<Id, String>();
        List<Asset> assetList = [SELECT Id, Status , NE__ProdId__c , XC_Product_Name_LIC__c                                                       
                                 FROM Asset 
                                 WHERE Id IN: listAssetIds];
        List<String> listProd = new List<String>();
        if(!assetList.isEmpty()){ 
            for(Asset a : assetList){
                listProd.add(a.NE__ProdId__c);
            }
        }
        if(!Schema.sObjectType.NE__DocumentationCharacterist__c.isAccessible()){
            return new Map<Id, String>();
        }
        List<NE__DocumentationCharacterist__c> documCharatList = [SELECT  Id, NE__Product__r.XC_LIC_Product_Name__c, Name, NE__Value__c 
                                                                  FROM  NE__DocumentationCharacterist__c
                                                                  WHERE Name LIKE 'Frequency%' AND NE__Product__c IN : listProd];
        for(Asset a : assetList){
            for(NE__DocumentationCharacterist__c docCharat : documCharatList ){
                if(a.XC_Product_Name_LIC__c == docCharat.NE__Product__r.XC_LIC_Product_Name__c){
                    mapAssetFrequency.put( a.Id , docCharat.NE__Value__c);
                } 
            }
        }
         XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@@mapAssetFrequency' + mapAssetFrequency);
        return mapAssetFrequency;
    }

    /**
     * @author Monica Cutillo - monica.cutillo@nttdata.com 
     * @description Method to get a Map with assetId -> NE__ProdId__c
     * @param assetIds 
     * @return Map<Id, Id> 
    **/
    public static Map<Id, Id> retrieveMappingAssetProductId(Set<Id> assetIds){
        Map<Id, Id> result = new Map<Id, Id>();
        Map<Id,Asset> assets = new Map<Id,Asset>(
            [SELECT Id, NE__ProdId__c                                                       
               FROM Asset 
              WHERE Id IN: assetIds]);
        
        for(Asset ass : assets.values()){
            result.put(ass.Id, ass.NE__ProdId__c);
        }
        return result;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to get a Map assetId -> Asset with Children Assets by Children Asset Type (example: Maintenance, Repair)
     * @param listAssetIds - List<String>
     * @return Map<Id, Asset> 
    **/
    public static Map<Id, Asset> retrieveMapAssetMaintenance(List<String> listAssetIds){
        return new Map<Id, Asset>([SELECT Id, NE__Bundle_Configuration__c, Status,XC_LegalEntity__c, XC_Product_Type__c, XC_Product_Subtype__c,
                                            (SELECT Id, CreatedDate, Status, XC_Product_Name_LIC__c
                                            FROM NE__Assets__r 
                                            WHERE (XC_Product_Name_LIC__c LIKE 'Mantenimiento%' OR XC_Product_SubType__c =: Label.XC_CL_Subtype_Maintenance) //XC_Product_Name__c =: Label.XC_CL_Asset_MaintenanceAnnual        
                                            AND Status =: Label.XC_CL_Asset_StatusActive) 
                                        FROM Asset 
                                        WHERE Id IN: listAssetIds]); 
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @description Method to get a Map Bundle assetId -> Bundle Asset with Children Assets by Children Asset Type (example: Maintenance, Repair)
     * @param listAssetIds - List<String>
     * @return Map<Id, Asset>
    **/
    public static Map<Id, Asset> retrieveMapBundleAssetMaintenance(List<String> listAssetIds){ 
        Map<Id, Asset> mapAsset = new Map<Id, Asset>([SELECT Id, Status, XC_LegalEntity__c,
                                                            (SELECT Id, CreatedDate, Status,XC_Product_Name_LIC__c, NE__Action__c
                                                            FROM NE__Assets4__r
                                                            WHERE (XC_Product_Name_LIC__c LIKE 'Mantenimiento%' OR XC_Product_SubType__c =: Label.XC_CL_Subtype_Maintenance)//XC_Product_Name__c =: Label.XC_CL_Product_Maintenance 
                                                            AND Status =: Label.XC_CL_Asset_StatusActive) 
                                                        FROM Asset 
                                                        WHERE Id IN: listAssetIds]);
        return mapAsset;
    }  

    /**
     * @description Get YearFrequency 
     * @param attrValue
     * @return Integer
    **/
    public static Integer getYearFrequency(String attrValue){
        if(!String.isBlank(attrValue)){
            if(attrValue == Label.XC_CL_Attribute_MaintenanceAnnual || attrValue == 'Annual') {
                return 1;
            } else if(attrValue == Label.XC_CL_Attribute_MaintenanceBiAnnual || attrValue == 'Biennial') {
                return 2; 
            }
        }
        return 0;
    }

    /**
     * @description getAssetBillingModel
     * @param assetId
     * @return BillingModel field value
    **/
    public static String getAssetBillingModel(Id assetId){
        Map<Id,Asset> data = new Map<Id,Asset>([SELECT Id, XC_BillingModel__c FROM Asset WHERE Id =: assetId]);
        return data.values()[0].XC_BillingModel__c;
    }


    /**
     * @author Marco Ottaviano - mottaviano@deloitte.it
     * @description getActivationMonths
     * @param billingModel
     * @params listAttributeConfItem
     * @return Number of Activation Months
     * 
     */
    public static Integer getActivationMonths(String billingModel,  List<NE__Order_Item_Attribute__c> listAttributeConfItem) {
      Integer monthsActivation=getActivationMonthsFromBillingModel(billingModel);
      if(!listAttributeConfItem.isEmpty()) {
        for(NE__Order_Item_Attribute__c attr : listAttributeConfItem) {
            if(String.isNotBlank(attr.XC_DeveloperName__c) && attr.XC_DeveloperName__c == Label.XC_CL_ConfigItemAttribute_DevDuration) {
                monthsActivation=String.isNotBlank(attr.NE__Value__c) ? Integer.valueOf(attr.NE__Value__c) : monthsActivation;
                break;
            }
        }
      }
      return monthsActivation;
    }

    
    /**
     * @author Monica Cutillo - mcutillo@deloitte.it
     * @description getActivationMonthsFromBillingModel
     * @param billingModel
     * @return Number of Activation Months
     **/
    public static Integer getActivationMonthsFromBillingModel(String billingModel){
        Map<String,String> billingModelData = new Map<String,String>{
            'Recurring'       => '1',
            '3 years renting' => '3',
            '5 years renting' => '5',
            '7 years renting' => '7'
        };
        
        if(billingModelData.get(billingModel) != null){
            return (Integer.valueOf(billingModelData.get(billingModel)))*12;
        }
        return Integer.valueOf('0');
    }

    /**
     * @author Simone Trenta - strenta@deloitte.it
     * @description getAssetsFromInvoice
     * @param invoice
     * @return assets
     **/
    public static Map<Id,Asset> getAssetsFromInvoice(String invoice){
        Map<Id,Asset> res = new Map<Id,Asset>();

        Map<Id,Zuora__ZInvoice__c> mapInv = new Map<Id,Zuora__ZInvoice__c>([
            SELECT Id, 
                (SELECT id, Zuora__Subscription__c, XC_SubscriptionNumber__c, Zuora__Subscription__r.Name
                FROM Zuora__Invoice_Items__r) 
            FROM Zuora__ZInvoice__c 
            WHERE Id =: invoice
        ]);

        if(mapInv.values().isEmpty()){
            return res;
        }

        Set<Id> subs = new Set<Id>();
        Set<String> subsNum = new Set<String>();
        Set<String> subsName = new Set<String>();
        for(Zuora__InvoiceItem__c it:mapInv.values()[0].Zuora__Invoice_Items__r){
            if(!String.isBlank(it.Zuora__Subscription__c)){
                subs.add(it.Zuora__Subscription__c);
            } else if(!String.isBlank(it.XC_SubscriptionNumber__c)){
                subsNum.add(it.XC_SubscriptionNumber__c);
            }
            if(!String.isBlank(it.Zuora__Subscription__r.Name)){
                subsName.add(it.Zuora__Subscription__r.Name);
            } 
        }

        if(!subsNum.isEmpty()){
            Map<Id,Zuora__Subscription__c> mapSubNum = new Map<Id,Zuora__Subscription__c>([
                SELECT id, Name
                FROM Zuora__Subscription__c
                WHERE Name IN: subsNum
            ]);
            subs.addAll(mapSubNum.keySet());
        }

        res = new Map<Id,Asset>([
            SELECT Id, NE__Bundle_Configuration__c, NE__Root_Order_Item__c, XC_Product_Type__c, NE__Catalog__r.Name, NE__ProdId__c, 
                    XC_Subscription__r.Zuora__External_Id__c, XC_Subscription__r.Zuora__SubscriptionNumber__c, XC_LegalEntity__c, XC_BillingModel__c
            FROM Asset
            WHERE ( XC_Subscription__c IN: subs AND XC_Subscription__c <> null)
               OR ( XC_SubscriptionName__c  IN: subsName AND XC_SubscriptionName__c <> null )
        ]);

        return res;
    }

}