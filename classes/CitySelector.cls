/**
 * Created by SNEKKANTI00 on 14/01/2021.
 */

public with sharing class CitySelector {
    private static List<City__c> cities;

    public static List<City__c> getCitiesByNames(Set<String> concessionMunicipalities) {
        cities = [
                SELECT id, Name, Alphanumeric_City_Code__c,Numeric_City_Code__c
                FROM City__c
                WHERE Name IN: concessionMunicipalities
        ];

        return cities;
    }
}