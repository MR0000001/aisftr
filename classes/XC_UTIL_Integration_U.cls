/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_UTIL_Integration_U - Method for XC_UTIL_Integration
*/

public class XC_UTIL_Integration_U {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Integration_U');

    /** @description CheckWrapper */
    private class CheckWrapper {
        Matcher myMatcher;
        Map<String, String> mapNew = new Map<String, String>();
        XC_UTIL_Integration.WrapperResult wR;
        Boolean finish = false;
    }

    /**
    * @description method to validateHeader
    * @return WrapperResult
    * @param mapHeader
    */
    public static XC_UTIL_Integration.WrapperResult validateHeader(Map<String, String> mapHeader) {

        Map<String, String> mapNew = new Map<String,  String>();
        for(String header : mapHeader.keySet()) {
            mapNew.put(header.toUppercase(), mapHeader.get(header));
        }

        XC_UTIL_Integration.WrapperResult wR = new XC_UTIL_Integration.WrapperResult();
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'mapHeader-->'+mapNew);

        checkForMissingMandatoryField(mapNew, wR);
        if(wr.errorFlag) {
            return wR;
        }

        // First, instantiate a new Pattern object "MyPattern"
        Pattern myPattern = Pattern.compile('(20[0-9][0-9])([0][0-9]|1[0-2])([012][0-9]|3[01])([01][0-9]|2[0-3])([0-5][0-9])([0-5][0-9])([0-9][0-9][0-9])');
        // Then instantiate a new Matcher object "MyMatcher"
        Matcher myMatcher = myPattern.matcher(mapNew.get('DATETIMEMESSAGE'));

        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ ' + mapNew.get('DATETIMEMESSAGE'));

        // You can use the system static method assert to verify the match
        CheckWrapper checkWrapper = new CheckWrapper();
        checkWrapper.MyMatcher = MyMatcher;
        checkWrapper.mapNew = mapNew;
        checkWrapper.wR = wR;
        checkForErrorAndMissingMandatoryField(checkWrapper);
        if(checkWrapper.finish) {
            return checkWrapper.wR;
        }

        return wR;
    }

    /**
    * @description Check for Missing Mandatory Field
    * @param mapNew - Map<String, String> 
    * @param wR - XC_UTIL_Integration.WrapperResult
    */
    private static void checkForMissingMandatoryField(Map<String, String> mapNew, XC_UTIL_Integration.WrapperResult wR) {
        if(String.isBlank(mapNew.get('TRANSACTIONID'))) {
            wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.TransactionID';
            wR.errorFlag = true;
        }

        if(String.isBlank(mapNew.get('DATETIMEMESSAGE'))) {
            System.debug('IN missing DATETIMEMESSAGE');
            wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.DateTimeMessage';
            wR.errorFlag = true;
        }
    }

    /**
    * @description Check for Error and Missing Mandatory Field
    * @param checkWrapper
    */
    private static void checkForErrorAndMissingMandatoryField(CheckWrapper checkWrapper) {
        if (!checkWrapper.MyMatcher.matches()) {
            checkWrapper.wR.errorMessage = 'ERROR. ' + Label.XC_CL_DateFormat_Error.removeEnd('.') + ': Header.DateTimeMessage - yyyyMMddHHmmssSSS';
            checkWrapper.wR.errorFlag = true;
            checkWrapper.finish = true;
            //return wR;
        }

        if (String.isBlank(checkWrapper.mapNew.get('OPERATION'))) {
            checkWrapper.wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.Operation';
            checkWrapper.wR.errorFlag = true;
            checkWrapper.finish = true;
            //return wR;
        }

        if (String.isBlank(checkWrapper.mapNew.get('FUNCTIONALITY'))) {
            checkWrapper.wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.Functionality';
            checkWrapper.wR.errorFlag = true;
            checkWrapper.finish = true;
            //return wR;
        }    
            
        if (String.isBlank(checkWrapper.mapNew.get('CLIENTSYSTEM'))) {
            checkWrapper.wR.errorMessage = Label.XC_CL_MandatoryField +' Header.ClientSystem';
            checkWrapper.wR.errorFlag = true;
            checkWrapper.finish = true;
            //return wR;
        }

        if (String.isBlank(checkWrapper.mapNew.get('SERVERSYSTEM'))) {
            checkWrapper.wR.errorMessage = Label.XC_CL_MandatoryField + ' Header.ServerSystem';
            checkWrapper.wR.errorFlag = true;
            checkWrapper.finish = true;
            //return wR;
        } 
    }

    /**
    * @description method to convertFromStringToPicklist
    * @return String
    * @param str - String
    */
    public static String convertFromStringToPicklist (String str){
        if (str == 'Y'){
            return 'Yes';
        } else if (str == 'N'){
            return 'No';
        }
        return null;
    }

    /**
    * @description method to convertFromPicklistToString
    * @return String
    * @param str - String
    */
    public static String convertFromPicklistToString (String str){
        if (str == 'Yes'){
            return 'Y';
        } else if (str == 'No') {
            return 'N';
        }
        return null;
    }

    /**
    * @description method to getCountryFromLegalEntity
    * @return String
    * @param legalEntity - String
    */
    public static String getCountryFromLegalEntity (String legalEntity){

        XC_UTIL_DependentPicklist.PicklistWrapper mapWrapper = XC_UTIL_DependentPicklist.getDependentPicklist('XC_LegalEntityConsent__c', 'XC_LeCountry__c', 'XC_LegalEntity__c');
        for(String countryMap : mapWrapper.pickListMap.keySet()) {
            for(String legEnMap : mapWrapper.pickListMap.get(countryMap)) {
                if(legEnMap == legalEntity) {
                    return countryMap;
                }
            }
        }

        return null;
    }


    /**
    * @description method to get ZuoraEntityName by LegalEntity
    * @return String
    * @param legalEntity - String
    */
    public static String getEntityName(String legalEntity){

        if(String.isBlank(legalEntity)) {
            return null;
        }

        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEnMap = new Map<Id,XC_CM_LegalEntity_Configuration__mdt> ([SELECT XC_ZuoraEntityName__c, XC_OrgName__c 
                                                                                                                      FROM XC_CM_LegalEntity_Configuration__mdt  
                                                                                                                      WHERE XC_LegalEntity__c =: legalEntity AND XC_OrgId__c =: orgId]);
        
        if(!(legalEnMap.values()).isEmpty()){
            System.debug(LoggingLevel.FINEST, '[XC_UTIL_Integration_U.getEntityName] OrgName: ' + legalEnMap.values()[0].XC_OrgName__c + ' - ZuoraEntityName: '+ legalEnMap.values()[0].XC_ZuoraEntityName__c + ' - LegalEntity: ' + legalEntity);                                                                                                             
            return legalEnMap.values()[0].XC_ZuoraEntityName__c;
        }
        
        return null;
    }


    /**
    * @description method to get ZuoraEntityName by LegalEntity
    * @return String
    * @param legalEntity - String
    * @param stream - String
    */
    public static String getEntityNameWithStream(String legalEntity, String stream){

        if(String.isBlank(legalEntity) || String.isBlank(stream)) {
            return null;
        }

        String orgId = UserInfo.getOrganizationId();
        Map<Id, XC_CM_LegalEntity_Configuration__mdt> legalEnMap = new Map<Id,XC_CM_LegalEntity_Configuration__mdt> ([SELECT XC_ZuoraEntityName__c, XC_OrgName__c 
                                                                                                                      FROM XC_CM_LegalEntity_Configuration__mdt  
                                                                                                                      WHERE XC_OrgId__c =: orgId AND XC_LegalEntity__c =: legalEntity AND XC_Stream__c =: stream]);
        
        if(!(legalEnMap.values()).isEmpty()){
            System.debug(LoggingLevel.FINEST, '[XC_UTIL_Integration_U.getEntityNameWithStream] OrgName: ' + legalEnMap.values()[0].XC_OrgName__c + ' - ZuoraEntityName: '+ legalEnMap.values()[0].XC_ZuoraEntityName__c + ' - LegalEntity: ' + legalEntity + ' - Stream: ' + stream);                                                                                                             
            return legalEnMap.values()[0].XC_ZuoraEntityName__c;
        }
        
        return null;
    }
        

}