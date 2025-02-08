/**
* @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
* @date Creation 25/09/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_OneOrg – Util class for OneOrg methods
*/

public without sharing class XC_UTIL_OneOrg { 
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_OneOrg');
    
    /**
    * @author Marco Rosa - marco.rosa@nttdata.com & Nicolò Leonardi - nleonardi@deloitte.it
    * @description Given a single or a List of countrynames establishes if vaiue of 'XC_[countryName]_Triggers__c' in OneOrg__c custom setting is true
    **/
    
    public static List<String> countryNamesAvailable = new List<String>{
        'Spain',
        'Chile',
        'Colombia'
    };
                
                
    /**
    * @author
    * @date 
    * @date 
    * @description 
    * @param countryName
    * @return boolean
    */  
        public static Boolean isRightCountry(String countryName){ 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'countryName ' + countryName);
            OneOrg__c mc = new OneOrg__c();
            try{
                mc = OneOrg__c.getInstance(UserInfo.getProfileId()); 
            }
            catch(Exception e) {
                return false; 
            }
            if(mc != null && countryNamesAvailable.contains(countryName)){
                Boolean outcome = (Boolean) mc.get('XC_' + countryName + '_Triggers__c');
                if(null != outcome){
                    return outcome;
                }else{
                    return false;
                }
            }
            return false;
        }
    
        public static Boolean isRightCountryItaly(Map<Id,Sobject> configurationItemsMap){
            Boolean outcome = false;
            List<NE__OrderItem__c> listNew = configurationItemsMap.values();
            for(NE__OrderItem__c oi:listNew){
                if(oi.XC_Segment__c.equalsIgnoreCase('B2B') && oi.XC_Country__c.equalsIgnoreCase('Italy') ){
                    outcome = true;
                }
            }
            return outcome;
        }
    
    /**
    * @author
    * @date
    * @date 
    * @description 
    * @param countryNames
    * @return Boolean
    */  
    
    public static Boolean isRightCountry(List<String> countryNames){ 
        for(String countryName : countryNames){
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'countryName ' + countryName);
            if(isRightCountry(countryName)){
                return true;
            }
        }
        return false;
    } 
}