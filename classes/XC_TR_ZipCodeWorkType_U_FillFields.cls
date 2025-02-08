/**
* @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone Massimiliano.avallone@nttdata.com
* @date Creation 10/09/2019
* @description XC_TR_ZipCodeWorkType_Handler - Class to fill Zip Code Work Type Fields
*/
public without sharing class XC_TR_ZipCodeWorkType_U_FillFields {
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ZipCodeWorkType_U_ExternalId');
    
    /**
    * @author Anna Maria Rosanova annamaria.rosanova@nttdata.com - Massimiliano Avallone Massimiliano.avallone@nttdata.com
    * @description Populate External Id for list of Zip Code Work Type
    * @param zipCodeWTList List<XC_ZipCodeWorkType__c>
    */
    public static void populateExternalId(List<XC_ZipCodeWorkType__c> zipCodeWTList) {
        for(XC_ZipCodeWorkType__c currentZCWT : zipCodeWTList){
            currentZCWT.XC_ExternalId__c = currentZCWT.XC_ZipCode__c + '_' + currentZCWT.XC_WorkType__c;
        }
    } 
	

}