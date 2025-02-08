public without sharing class TA_LCC266_TechnicalAssetSearching {

    public class ReturnWrapper{
        @AuraEnabled
        public Boolean success {get; set;}

        @AuraEnabled
        public String errorMessage {get; set;}
    }

    public class AssetWrapper {

        @AuraEnabled
        public String id {get; set;}

        @AuraEnabled
        public String accountName {get; set;}

        @AuraEnabled
        public String serialNumber {get; set;}

        @AuraEnabled
        public String addressName {get; set;}
        
        @AuraEnabled
        public String name {get; set;}

        @AuraEnabled
        public String type {get; set;}

        @AuraEnabled
        public String subType {get; set;}

        @AuraEnabled
        public String latitude {get; set;}

        @AuraEnabled
        public String longitude {get; set;}

        @AuraEnabled
        public String accuracy {get; set;}

        @AuraEnabled
        public String assetType {get; set;}

        @AuraEnabled
        public String assetOwnership {get; set;}

        @AuraEnabled
        public String modelOrPartNumber {get; set;}

        @AuraEnabled
        public String productName {get; set;}

        public AssetWrapper(
                String id, 
                String accountName, 
                String serialNumber, 
                String addressName, 
                String name, 
                String type, 
                String subType, 
                String latitude, 
                String longitude, 
                String accuracy, 
                String assetType, 
                String assetOwnership, 
                String modelOrPartNumber, 
                String productName) {
                    
            this.id = id;
            this.accountName = accountName;
            this.serialNumber = serialNumber;
            this.addressName = addressName;
            this.name = name;
            this.type = type;
            this.subType = subType;
            this.latitude = latitude;
            this.longitude = longitude;
            this.accuracy = accuracy;
            this.assetType = assetType;
            this.assetOwnership = assetOwnership;
            this.modelOrPartNumber = modelOrPartNumber;
            this.productName = productName;
        }
    }

    @AuraEnabled
    public static String searchAsset(String city, String assetNameLike) {
        List<AssetWrapper> assetWrappers = new List<AssetWrapper>();
        
        if(String.isNotBlank(city) && String.isNotBlank(assetNameLike)) {
            
            // String whereCondition = 'NE__City__c = \'' + city + '\' AND Name LIKE \'%' + assetNameLike + '%\' LIMIT 1000';
            // String queryString = 'SELECT Id, TAM_AssetType__c, TAM_GenericAssetOwnership__c, TAM_ModelOrPartNumber__c, XC_Product_Name__c, LocationId, Name, Account.Name, SerialNumber, XC_Address__r.Name, XC_Product_Type__c, XC_Product_Subtype__c, Location.Latitude, Location.Longitude, Location.XC_Accuracy__c FROM Asset WHERE ' + whereCondition;
            
            // FD 29-07-2022 - NR2330 - START
            List<Asset> assets = [SELECT Id, 
                                         TAM_AssetType__c, 
                                         TAM_GenericAssetOwnership__c, 
                                         TAM_ModelOrPartNumber__c, 
                                         XC_Product_Name__c, 
                                         LocationId, 
                                         Name, 
                                         Account.Name, 
                                         SerialNumber, 
                                         XC_Address__r.Name, 
                                         XC_Product_Type__c, 
                                         XC_Product_Subtype__c, 
                                         Location.Latitude, 
                                         Location.Longitude, 
                                         Location.XC_Accuracy__c 
                                FROM Asset 
                                WHERE Account.Name LIKE: '%' + city + '%'
                                AND Name LIKE : '%' + assetNameLike + '%'
                                AND TAM_IsTechnical__c = true 
                                LIMIT 1000];
            // FD 29-07-2022 - NR2330 - END

            if(!assets.isEmpty()) {
                for(Asset a : assets) {
                    assetWrappers.add(new AssetWrapper(a.Id,
                                                        a.Account != null ? a.Account.Name : null, 
                                                        a.SerialNumber, 
                                                        a.XC_Address__r.Name != null ? a.XC_Address__r.Name : null, 
                                                        a.Name,
                                                        a.XC_Product_Type__c,
                                                        a.XC_Product_Subtype__c,
                                                        String.isNotBlank(a.LocationId) && a.Location.Latitude != null ? String.valueOf(a.Location.Latitude) : null,
                                                        String.isNotBlank(a.LocationId) && a.Location.Longitude != null ? String.valueOf(a.Location.Longitude) : null,
                                                        String.isNotBlank(a.LocationId) && a.Location.XC_Accuracy__c != null ? String.valueOf(a.Location.XC_Accuracy__c) : null,
                                                        a.TAM_AssetType__c,
                                                        a.TAM_GenericAssetOwnership__c,
                                                        a.TAM_ModelOrPartNumber__c,
                                                        a.XC_Product_Name__c));
                }
            }
        }
        return JSON.serialize(assetWrappers);
    }
}