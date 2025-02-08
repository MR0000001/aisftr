public without sharing class TA_LCC262_Geolocalization {

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

        public AssetWrapper(String id, String accountName, String serialNumber, String addressName, String name, String type, String subType, String latitude, String longitude, String accuracy) {
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
        }
    }

    @AuraEnabled
    public static Map<String, String> getAssetCoordinates(String workOrderId) {
        Map<String, String> response = new Map<String, String>();
        
        List<WorkOrder> workOrders = [SELECT AssetId FROM WorkOrder WHERE Id =: workOrderId];
        if(!workOrders.isEmpty()) {
            List<Asset> assets = [SELECT Id, Location.Longitude, Location.Latitude, Location.XC_Accuracy__c FROM Asset WHERE Id =: workOrders[0].AssetId];
            if(!assets.isEmpty() && assets[0].Location != null) {
                response.put('longitude', String.valueOf(assets[0].Location.Longitude));
                response.put('latitude', String.valueOf(assets[0].Location.Latitude));
                response.put('accuracy', String.valueOf(assets[0].Location.XC_Accuracy__c));
            }  
        }
        return response;
    }

    @AuraEnabled
    public static String updateCoordinates(String recordId, String currentLatitude, String currentLongitude, String currentAccuracy) {

        System.debug('@@>> recordId >>> ' + recordId);
        System.debug('@@>> currentLatitude >>> ' + currentLatitude);
        System.debug('@@>> currentLongitude >>> ' + currentLongitude);
        System.debug('@@>> currentAccuracy >>> ' + currentAccuracy);
        String response = '';

        try {
            if(String.isNotBlank(recordId)) {
                String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
                String assetId = '';
                
                if(objectType == 'WorkOrder') {
                    List<WorkOrder> workOrders = [SELECT AssetId FROM WorkOrder WHERE Id = :recordId];
                    if(!workOrders.isEmpty()) assetId = workOrders[0].AssetId;

                } else if(objectType == 'Asset') assetId = recordId;

                System.debug('@@>> objectType >>> ' + objectType);
                System.debug('@@>> assetId >>> ' + assetId); 
                
                List<Asset> assets = [SELECT LocationId FROM Asset WHERE Id =:assetId];
                if(!assets.isEmpty()) {
                    Schema.Location location = new Schema.Location();
                    if(String.isNotBlank(assets[0].LocationId)) {
                        location.Id = assets[0].LocationId;
                    } else {
                        location.LocationType = 'Site';
                        location.Name = 'Site_Geolocalization';
                    }

                    location.Latitude = Decimal.valueOf(currentLatitude);
                    location.Longitude = Decimal.valueOf(currentLongitude);
                    location.XC_Accuracy__c = Decimal.valueOf(currentAccuracy);
                    
                    upsert location;
                    update new Asset(Id = assetId, LocationId = location.Id, NE__Geolocalization__Latitude__s = Decimal.valueOf(currentLatitude), NE__Geolocalization__Longitude__s = Decimal.valueOf(currentLongitude));
                    response = 'Completed';
                }
            }

        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC262_Geolocalization] updateCoordinates - EXCEPTION HANDLER: ' + errorMessage);
            response = errorMessage;
        }
        return response;
    }

    @AuraEnabled
    public static String searchAsset(String searchType, String searchValue, String assetNameLike) {
        List<AssetWrapper> assetWrappers = new List<AssetWrapper>();
        
        if(String.isNotBlank(searchType) && String.isNotBlank(searchValue)) {
            String whereCondition = searchType == 'Name'
                                    ? searchType + ' = \'' + searchValue + '\' LIMIT 100'
                                    : searchType == 'NE__City__c' 
                                    ? searchType + ' = \'' + searchValue + '\' AND Name LIKE \'%' + assetNameLike + '%\' LIMIT 100'
                                    : searchType + ' LIKE \'%' + searchValue + '%\' LIMIT 100';

            String queryString = 'SELECT Id, LocationId, Name, Account.Name, SerialNumber, XC_Address__r.Name, XC_Product_Type__c, XC_Product_Subtype__c, Location.Latitude, Location.Longitude, Location.XC_Accuracy__c FROM Asset WHERE ' + whereCondition;
            
            List<Asset> assets = Database.query(queryString);
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
                                                        String.isNotBlank(a.LocationId) && a.Location.XC_Accuracy__c != null ? String.valueOf(a.Location.XC_Accuracy__c) : null));
                }
            }
        }
        return JSON.serialize(assetWrappers);
    }
}