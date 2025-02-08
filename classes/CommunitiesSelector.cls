/**
 * Created by SNEKKANTI00 on 12/01/2021.
 */

public with sharing class CommunitiesSelector {
    public static String getCommunityCodeByProvinceAndCity(String birthProvince, String birthCity) {
        String comunity = [
                SELECT Code__c
                FROM Communities__c
                WHERE (province_short__c =: birthProvince OR province_long__c =: birthProvince) AND Name =: birthCity
        ].Code__c;

        return comunity;
    }

    public static String getCommunityCodeByCountry(String birthCountry) {
        String comunity = [
                SELECT Code__c
                FROM Communities__c
                WHERE Name =: birthCountry
        ].Code__c;

        return comunity;
    }

}