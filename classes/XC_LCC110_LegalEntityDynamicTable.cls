/**
 * @author Monica Cutillo - monica.cutillo@nttdata.com
 * @date Creation 24/04/2019
 * @date Modification 26/06/2019
 * @description XC_LCC110_LegalEntityDynamicTable – Controller of XC_LCP110_LegalEntityDynamicTable and XC_LCP111_LegalEntityDynamicItem
 */
public without sharing class XC_LCC110_LegalEntityDynamicTable {
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC110_LegalEntityDynamicTable');

    
    /**
     * @description retrieve Legal Entities picklist values
     * @return list with results
     */
    public class LegalEntityDataWrapper{
        @AuraEnabled
        public String userCountry = '';
        @AuraEnabled
        public String userLE = '';
        @AuraEnabled 
        public List<Map<String,Object>> country = new List<Map<String,Object>>();
        @AuraEnabled 
        public List<Map<String,Object>> legalEntityConsents = new List<Map<String,Object>>();
        @AuraEnabled 
        public List<Map<String,String>> consentsOptions = new List<Map<String,String>>();

    }

    /**
     * @description retrieve Legal Entities data wrapper
     * @return results wrapper result
     */
    @AuraEnabled
	public static LegalEntityDataWrapper retrieveLegalEntityData(){
        LegalEntityDataWrapper leDataW = new LegalEntityDataWrapper();
        leDataW.consentsOptions = getLEConsentsOptions();

        List<User> user = retrieveCorrentUserData();
        if(user!=null && !user.isEmpty()){
            leDataW.userCountry = normalizeUserCountryValue(user[0].Country__c);
            leDataW.userLE = user[0].XC_LegalEntity__c;
        }
        
        leDataW.country = retrieveCountryValues(leDataW.userCountry);
        leDataW.legalEntityConsents = getLegalEntitiesByCountry(leDataW.userCountry); // retrieveLegalEntities();

        return leDataW;
    }

    /**
     * @description retrieve Legal Entities data wrapper
     * @param country selected country
     * @return results wrapper result
     */
    @AuraEnabled
	public static List<Map<String,String>> getLegalEntitiesByCountry(String country){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getLegalEntitiesByCountry for country '+country);
        List<Map<String,String>> results = new List<Map<String,String>>();
        Map<String,String> option = new Map<String,String>();
        XC_UTIL_DependentPicklist.PicklistWrapper picklistWrapper = XC_UTIL_DependentPicklist.getDependentPicklist('XC_LegalEntityConsent__c','XC_LeCountry__c','XC_LegalEntity__c');
        Map<String,List<String>> dependentDataMapping = picklistWrapper.pickListMap;
        if(dependentDataMapping.isEmpty()){
            return results;
        }
        List<String> dependentLEValue = (dependentDataMapping.get(country) != null) ? dependentDataMapping.get(country)
                                                                                    : new List<String>();
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ dependentData >>> '+dependentLEValue);

        List<Schema.PicklistEntry> entries = XC_UTIL_Sobject.retrieveAllPicklistValues('XC_LegalEntityConsent__c', 'XC_LegalEntity__c');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ ALL XC_LegalEntity__c entries = '+entries);
        for(Schema.PicklistEntry entry : entries){
            if(entry.isActive() && dependentLEValue.contains(entry.getValue())){
                option = new Map<String,String>();
                option.put('label', entry.label);
                option.put('value', entry.value);
                results.add(option);
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ getLegalEntitiesByCountry results = '+results);
        return results;
    }

    /**
     * @description normalize User Country value
     * @param userCountry userCountry value
     * @return normalized user Country (if mapping exists, else user Country)
     */
    private static String normalizeUserCountryValue(String userCountry){
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ normalizeUserCountryValue for userCountry = '+userCountry);
        Map<String,String> countryMapping = new Map<String,String>
        {
            'SPAIN'          => 'Spain',
            'SP'             => 'Spain',
            'ESPAÑA'         => 'Spain',
            'ES'             => 'Spain',
            'UNITED KINGDOM' => 'United Kingdom',
            'UK'             => 'United Kingdom'
        };
        String result = countryMapping.get(userCountry.toUpperCase());
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@@@@ normalizeUserCountryValue mapping = '+result);
        return (String.isNotBlank(result)) ? result : userCountry;
    }

    /**
     * @description retrieve Country picklist values
     * @param selectedValue value to pre select
     * @return list with results
     */
    private static List<Map<String,Object>> retrieveCountryValues(String selectedValue){
        List<Map<String,Object>> results = new List<Map<String,Object>>();
        Map<String,Object> option;
        List<Schema.PicklistEntry> entries = XC_UTIL_Sobject.retrieveAllPicklistValues('Account', 'XC_CountryAddress__c');
        for(Schema.PicklistEntry entry : entries){
            if(entry.isActive()){
                option = new Map<String,Object>();
                option.put('label', entry.label);
                option.put('value', entry.value); // (entry.value).toUpperCase());
                if(option.get('value') == selectedValue){
                    option.put('selected', true);
                }
                results.add(option);
            }
        }
        return results;
    }
    

    /**
     * @description retrieve Legal Entities picklist values
     * @return list with results
     */
	@AuraEnabled
	public static List<Map<String,String>> retrieveLegalEntities(){
        List<Map<String,String>> results = new List<Map<String,String>>();
        Map<String,String> option = new Map<String,String>();
        option.put('label', Label.XC_CL_CPAB_Select);
        option.put('value', '');
        option.put('selected', 'true');
        results.add(option);
        //XC_UTIL_Sobject.getPicklistValues('XC_LegalEntityConsent__c', 'XC_LegalEntity__c');
        List<Schema.PicklistEntry> entries = XC_UTIL_Sobject.retrieveAllPicklistValues('XC_LegalEntityConsent__c', 'XC_LegalEntity__c');
        for(Schema.PicklistEntry entry : entries){
            if(entry.isActive())
            {
                option = new Map<String,String>();
                option.put('label', entry.label);
                option.put('value', entry.value);
                results.add(option);
            }
        }
        return results;
    }

    /**
     * @description retrieve corrent User data
     * @return list Users
     */
    private static List<User> retrieveCorrentUserData(){
        Map<Id,User> data = new Map<Id,User> ([SELECT Id, XC_LegalEntity__c, Country__c FROM User WHERE Id =: Userinfo.getUserId()]);
        return data.values();
    }

    /**
     * @description build LE Consents Options
     * @return value
     */
    private static List<Map<String,String>> getLEConsentsOptions(){
        List<Map<String,String>>  result = new List<Map<String,String>> ();
        Map<String,String> entry = new Map<String,String>{
            'label' => Label.XC_CL_NoneText,
            'value' => '',
            'selected' => 'true'
        };
        result.add(entry);
        entry = new Map<String,String>{
            'label' => Label.XC_CL_YesText,
            'value' => 'Yes'
        };
        result.add(entry);
        entry = new Map<String,String>{
            'label' => Label.XC_CL_NoText,
            'value' => 'No'
        };
        result.add(entry);
        return result;
    }

}