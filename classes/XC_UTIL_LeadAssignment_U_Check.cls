/**
* @author Salvatore Agrillo salvatore.agrillo@nttdata.com
* @date Creation 19/04/2019
* @date Modification dd/mm/yyyy
* @description XC_UTIL_LeadAssignment_U_Check – Methods "check" for XC_UTIL_LeadAssignment
*/
public class XC_UTIL_LeadAssignment_U_Check {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_LeadAssignment');

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 08/04/2019
    * @description Check WildCardMatch with LeadAssignmentMaster (FOR CYCLOMATIC COMPLEXITY WARNING)
    * @param checkWrapper - XC_UTIL_LeadAssignment.CheckMatchWrapper
    **/
    public static void checkWildCardMatch(XC_UTIL_LeadAssignment.CheckMatchWrapper checkWrapper) {
        if(checkConditionAddressForWildCardMatch(checkWrapper) && checkConditionPreferenceForWildCardMatch(checkWrapper)) {
            checkWrapper.skipped = false; 
            XC_UTIL_LeadAssignment.populateResultWrapper(checkWrapper);
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'For Lead (' + checkWrapper.ld.Name + ') -> wild card match! checkWrapper.assignedTo -->' + checkWrapper);
        } 
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 08/04/2019
    * @description Match fields for address for WildCardMatch (FOR CYCLOMATIC COMPLEXITY WARNING)
    * @param checkWrapper - XC_UTIL_LeadAssignment.CheckMatchWrapper
    * @return Boolean
    **/
    private static Boolean checkConditionAddressForWildCardMatch(XC_UTIL_LeadAssignment.CheckMatchWrapper checkWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkConditionAddressForWildCardMatch ## WRAPPER-> ' + checkWrapper.leadWrapper + ' - ## LAM->' + checkWrapper.lam);
        if(checkOnCountryAndCity(checkWrapper)
            && (checkWrapper.leadWrapper.zipCode == checkWrapper.lam.XC_ZipCode__c || String.isBlank(checkWrapper.lam.XC_ZipCode__c))
            && (checkWrapper.leadWrapper.isAddress == checkWrapper.lam.XC_Address__c ||  String.isEmpty(checkWrapper.lam.XC_Address__c))
            && (checkWrapper.consentLE == checkWrapper.lam.XC_LegalEntity__c || String.isEmpty(checkWrapper.lam.XC_LegalEntity__c))
             && (checkWrapper.leadWrapper.stream == checkWrapper.lam.XC_Segment__c || String.isEmpty(checkWrapper.lam.XC_Segment__c))
            && (checkWrapper.leadWrapper.leCountry == checkWrapper.lam.XC_RecordTypePick__c) 
        ) {
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkConditionAddressForWildCardMatch TRUE 1 ');
            return true;
        }
        return false;
    }

    private static Boolean checkOnCountryAndCity(XC_UTIL_LeadAssignment.CheckMatchWrapper checkWrapper){
        if((checkWrapper.leadWrapper.country == checkWrapper.lam.XC_Country__c || String.isBlank(checkWrapper.lam.XC_Country__c))
            && (checkWrapper.leadWrapper.city == checkWrapper.lam.XC_City__c || String.isBlank(checkWrapper.lam.XC_City__c))){
                XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkConditionAddressForWildCardMatch TRUE 2 ');
                return true;
            }
        return false;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 08/04/2019
    * @description Match fields for preference for WildCardMatch (FOR CYCLOMATIC COMPLEXITY WARNING)
    * @param checkWrapper - XC_UTIL_LeadAssignment.CheckMatchWrapper
    * @return Boolean
    **/
    private static Boolean checkConditionPreferenceForWildCardMatch(XC_UTIL_LeadAssignment.CheckMatchWrapper checkWrapper) {
        if((checkWrapper.leadWrapper.isEmail == checkWrapper.lam.XC_Email__c || String.isEmpty(checkWrapper.lam.XC_Email__c))
            && (checkWrapper.leadWrapper.isPhone == checkWrapper.lam.XC_PrimaryPhone__c || String.isEmpty(checkWrapper.lam.XC_PrimaryPhone__c))
            && (checkWrapper.leadWrapper.receivingChannel == checkWrapper.lam.XC_Channel__c || String.isBlank(checkWrapper.lam.XC_Channel__c))
            && (checkWrapper.leadWrapper.productCategoryofInterest == checkWrapper.lam.XC_ProductCategoryOfInterest__c || String.isBlank(checkWrapper.lam.XC_ProductCategoryOfInterest__c))
            
        ) { 
            XC_UTIL_Debug.debug(DEBUGACTIVE, 'In checkConditionAddressForWildCardMatch TRUE 3 ');
            return true;
        }
        return false;
    }

    /** 
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date Creation 08/04/2019
    * @description Check Match with LeadAssignmentMaster (FOR CYCLOMATIC COMPLEXITY WARNING)
    * @param checkWrapper - CheckMatchWrapper
    **/
    public static void checkExactMatch(XC_UTIL_LeadAssignment.CheckMatchWrapper checkWrapper) {
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'For Lead (' + checkWrapper + ') ');
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@SS 1006@@ checkWrapper.leadWrapper -->' + checkWrapper.leadWrapper);
        if(checkConditionOnEmailAndPhoneAndAddress(checkWrapper)
            && checkWrapper.leadWrapper.productCategoryofInterest == checkWrapper.lam.XC_ProductCategoryOfInterest__c
            && checkWrapper.leadWrapper.country == checkWrapper.lam.XC_Country__c
            && checkWrapper.leadWrapper.city == checkWrapper.lam.XC_City__c
            && checkWrapper.leadWrapper.zipCode == checkWrapper.lam.XC_ZipCode__c
            && checkWrapper.consentLE == checkWrapper.lam.XC_LegalEntity__c
            && checkWrapper.leadWrapper.receivingChannel == checkWrapper.lam.XC_Channel__c
            && checkWrapper.leadWrapper.leCountry == checkWrapper.lam.XC_RecordTypePick__c
            && checkWrapper.leadWrapper.stream == checkWrapper.lam.XC_Segment__c 
        ){  
            XC_UTIL_Debug.debug(DEBUGACTIVE, '@@SS 1006@@ checkConditionOnEmailAndPhoneAndAddress TRUE');
            checkWrapper.skipped = false;
            XC_UTIL_LeadAssignment.populateResultWrapper(checkWrapper);
        }
    }

    private static Boolean checkConditionOnEmailAndPhoneAndAddress(XC_UTIL_LeadAssignment.CheckMatchWrapper checkWrapper){
        if(checkWrapper.leadWrapper.isEmail == checkWrapper.lam.XC_Email__c
            && checkWrapper.leadWrapper.isPhone == checkWrapper.lam.XC_PrimaryPhone__c
            && checkWrapper.leadWrapper.isAddress == checkWrapper.lam.XC_Address__c){
                return true;
        }
        return false;
    }
}