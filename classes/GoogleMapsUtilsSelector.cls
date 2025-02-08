public without sharing class GoogleMapsUtilsSelector {
    public static GoogleMaps__c GoogleMapsUtilsSelector() {
        GoogleMaps__c gmaps = [SELECT Domain__c, Google_Key__c, Visualforce_Origin__c FROM  GoogleMaps__c LIMIT 1];
        return gmaps;
    }
}