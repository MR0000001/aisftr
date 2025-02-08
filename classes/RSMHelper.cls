/**
 * Created by SNEKKANTI00 on 15/01/2021.
 */

public with sharing class RSMHelper {
    public static Map<String, String> caseComuneMapper(List<Case> cases) {
        Set<String> concessionMunicipalities = new Set<String>();
        Map<String, String> cityNameCityCodeMap = new Map<String, String>();
        List<City__c> cities = new List<City__c>();

        for(Case c : cases) {
            System.debug('c.Concession_Municipality__c ' + c.Concession_Municipality__c);
            System.debug('c.id ' + c.id);
            if(c.Concession_Municipality__c != null && !c.Concession_Municipality__c.equalsIgnoreCase('')) {
                concessionMunicipalities.add(c.Concession_Municipality__c);
            }
        }

        if(!concessionMunicipalities.isEmpty()) {
            cities = CitySelector.getCitiesByNames(concessionMunicipalities);
            System.debug('cities ' + cities);

            if(!cities.isEmpty()) {
                for(City__c city : cities) cityNameCityCodeMap.put(city.Name.toUpperCase(), city.Numeric_City_Code__c);
            } else {
                throw new AuraHandledException(System.Label.RSMNoComuneConcessione);
            }
        }

        return cityNameCityCodeMap;
    }
}