/**
* @author Simone Trenta - strenta@deloitte.it
* @date Creation 21/10/2019
* @date Modification 
* @description XC_LCC165_NewAddressLoader - Address validator wrapper component controller
*/
public class XC_LCC165_NewAddressLoader {

    class ResultWrap{
        public String componentName;
        public Boolean isAutocomplete;
        public Boolean forceAllAddresses;
    }

    /**
    * @author Palamides Damiano
    * @date Creation 19/03/2019
    * @description Method to get Component Name
    * @param country String
    * @return JSON.serialize(res)
    * @return null
    */
    @AuraEnabled
    public static String getComponentName(String country){
        
        if (!Schema.sObjectType.XC_CM010_AddressComponentSetup__mdt.isAccessible()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
            return null;
        }

        XC_CM010_AddressComponentSetup__mdt setup = null;
        try{
            setup = [select id, XC_ComponentName__c, XC_Autocomplete__c, XC_ForceAllAddresses__c from XC_CM010_AddressComponentSetup__mdt where XC_country__c = :country];

        } catch(Exception e){
            XC_UTIL_Debug.debug(true, 'Error in getComponentName'+ e.getStackTraceString());
        }

        if(setup!=null){
            ResultWrap res = new ResultWrap();
            res.componentName = setup.XC_ComponentName__c;
            res.isAutocomplete = setup.XC_Autocomplete__c;
            res.forceAllAddresses = setup.XC_ForceAllAddresses__c;
            return JSON.serialize(res);

        } else{
            ResultWrap res = new ResultWrap();
            res.componentName = 'XC_LCP167_NewAddressGlobal';
            res.isAutocomplete = false;
            res.forceAllAddresses = true;
            return JSON.serialize(res);
        }
    }

    /**
    * @date Creation 19/03/2019
    * @description Method to get country by user
    * @return country
    */
    @AuraEnabled
    public static String getCountryByUser(){
        return XC_LCC011_NewAddress.getCountryByUser();
    }


}