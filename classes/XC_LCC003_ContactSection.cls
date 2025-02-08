/**
 * @description Populate the Contact Section of the Account
 * The Class XC_LCC003_ContactSection.
 */
public class XC_LCC003_ContactSection {
    
    /**
     * The Class ContactSectionWrapper.
     * @description ContactSection Wrapper
     */
    public class ContactSectionWrapper { 
        
        /** The document types. */
        //List<String> documentTypes = new List<String>();
        List<Map<String,String>> languageTypes = new List<Map<String,String>>();
        String defaultDocumentType;
    }
     

    /**
     * Retrieve preferred language picklist.
     * @description Populate the Contact Section of the Account
     * @return the string
     */
    @AuraEnabled
    public static String retrieveLanguagePicklist() {
        ContactSectionWrapper wrapper = new ContactSectionWrapper(); 
        wrapper.languageTypes = getListLangaugeTypes();
        return JSON.serialize(wrapper); 
    }

    private static List<Map<String,String>> getListLangaugeTypes(){
        List<Map<String,String>> result = new List<Map<String,String>>();
        Map<String,String> langMap;

        List<Schema.PicklistEntry> pickValues =  XC_UTIL_Sobject.retrieveAllPicklistValues('Contact', 'XC_Preferredlanguageofcontact__c');
        for(Schema.PicklistEntry entry : pickValues){
            if(entry.isActive()){
                langMap = new Map<String,String>();
                langMap.put('label', entry.getLabel());
                langMap.put('value', entry.getValue());
                result.add(langMap);
            }
        }

        return result;

    }

     /**
     * Retrieve preferred language picklist.
     * @description Populate the Contact Section of the Account
     * @return the string
     */
    @AuraEnabled
    public static String retrieveDefaultDocumentType(String defaultDependetDocumentCountry) {
        ContactSectionWrapper wrapper = new ContactSectionWrapper(); 
        wrapper.defaultDocumentType = null;
        XC_UTIL_DependentPicklist.PicklistWrapper pl=XC_UTIL_DependentPicklist.getDependentPicklist('Contact','XC_ContactDocumentCountry__c','XC_ContactDocumentType__c');
        if(pl.pickListMap.containsKey(defaultDependetDocumentCountry)) {
            List<String> valuePicklist= pl.pickListMap.get(defaultDependetDocumentCountry);
            if(!valuePicklist.isEmpty()) {
                wrapper.defaultDocumentType = valuePicklist[0];
            }
        }

        return JSON.serialize(wrapper); 
    }
    
    /**
     * Retrieve document picklist.
     *
     * @return the string
     */
    /*@AuraEnabled
    public static String retrieveDocumentPicklist() {
        ContactSectionWrapper wrapper = new ContactSectionWrapper(); 
        wrapper.documentTypes = getListDocumentTypes();
		return JSON.serialize(wrapper); 
    }*/

    /**
     * ---------------------------------
     *         ONE ORG CONFIGURATION - START 
     *     ---------------------------------*.
     *
     * @return the list document types
     */ 

    /*public static List<String> getListDocumentTypes(){
        List<String> listDocumentTypes = new List<String>();
        if(XC_UTIL_OneOrg.isRightCountry('Spain')){
            listDocumentTypes = listDocumentTypeSpain;
        }  
        return listDocumentTypes;
    }
    
    public static List<String> listDocumentTypeSpain = new List<String>{
        'NIF',
        'NIE',
        'Passport'
    };*/

    /**---------------------------------
        ONE ORG CONFIGURATION - END 
    ---------------------------------**/ 

    
}