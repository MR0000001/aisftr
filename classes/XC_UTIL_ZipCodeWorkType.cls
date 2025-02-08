/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date 10/09/2019 
* @description XC_UTIL_ZipCodeWorkType - Util Class for ZipCode - Worktype association
*/

public without sharing class XC_UTIL_ZipCodeWorkType {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_ZipCodeWorkType');

    /** @description ZipCodeWorkTypeWrapper */
    public class ZipCodeWorkTypeWrapper {
        public String zipCode = '';
        public String workType = '';
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 10/09/2019
    * @description Method to calculate a Map (ZipCode_WorkType -> Id Association). This method insert the association if it doesn't exist.
    * @param listWrapper - List<ZipCodeWorkTypeWrapper>
    * @return Map<String, String>
    */
    public static Map<String, String> calculateAssociationZipCodeWorkType(List<ZipCodeWorkTypeWrapper> listWrapper) {
        Map<String, String> mapZipCodeWorktype = new Map<String, String>();
        List<XC_ZipCodeWorkType__c> listAssociationToInsert = new List<XC_ZipCodeWorkType__c>();
        List<String> listKeyToAdd = new List<String>();
        List<String> listKeys = new List<String>();
        for(ZipCodeWorkTypeWrapper wrapper : listWrapper) {
            listKeys.add(wrapper.zipCode+'_'+wrapper.workType);
        }
        listKeyToAdd.addAll(listKeys);

        List<XC_ZipCodeWorkType__c> listZipcodeWorkType = new List<XC_ZipCodeWorkType__c>([
            SELECT Id, XC_ZipCode__c, XC_WorkType__c, XC_ExternalId__c
            FROM XC_ZipCodeWorkType__c
            WHERE XC_ExternalId__c IN :listKeys
        ]);        

        for(XC_ZipCodeWorkType__c zcwt : listZipcodeWorkType) {
            for(String key : listKeys) {
                if(key == zcwt.XC_ExternalId__c) {
                    mapZipCodeWorktype.put(key, zcwt.Id);
                    Integer indexToDelete = listKeyToAdd.indexOf(key);
                    if(indexToDelete != -1) {
                        listKeyToAdd.remove(indexToDelete);
                    }
                    break;
                }
            }
        }

        for(String key : listKeyToAdd) {
            XC_ZipCodeWorkType__c zcwtToInsert = new XC_ZipCodeWorkType__c();
            List<String> listKey = key.split('_');
            system.debug('key work type'+' '+listKey[1]);
            zcwtToInsert.XC_ZipCode__c = listKey[0];
            zcwtToInsert.XC_WorkType__c = listKey[1];
            listAssociationToInsert.add(zcwtToInsert);
        }

        List<XC_UTIL_Sobject.WrapperResult> listWr = XC_UTIL_Sobject.insertListRecords(listAssociationToInsert);
        if(XC_UTIL_Sobject.checkDMLResults(listWr)) {
            for(XC_ZipCodeWorkType__c zcwt : listAssociationToInsert) {
                mapZipCodeWorktype.put(zcwt.XC_ZipCode__c+'_'+zcwt.XC_WorkType__c, zcwt.Id);
            }
        }
        return mapZipCodeWorktype;
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 10/09/2019
    * @description Method to calculate a list of Wrapper for ZipCode/WorkType (by ServiceAppointment)
    * @param listServiceAppointment - List<ServiceAppointment>
    * @return List<ZipCodeWorkTypeWrapper>
    */
    public static List<ZipCodeWorkTypeWrapper> calculateZipCodeWorkType(List<ServiceAppointment> listServiceAppointment) {
        List<ZipCodeWorkTypeWrapper> listWrapper = new List<ZipCodeWorkTypeWrapper>();
        for(ServiceAppointment sa : listServiceAppointment) {
            ZipCodeWorkTypeWrapper wrapper = new ZipCodeWorkTypeWrapper();
            wrapper.workType = sa.WorkTypeId;
            wrapper.zipCode = sa.XC_FSLAssignmentKey__c;
            listWrapper.add(wrapper);
        }
        return listWrapper;
    }
    
    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 10/09/2019
    * @description Method to calculate a list of Wrapper for ZipCode/WorkType (by XC_PartnerCoverage__c)
    * @param listPartnerCoverage - List<XC_PartnerCoverage__c>
    * @return List<ZipCodeWorkTypeWrapper>
    */
    public static List<ZipCodeWorkTypeWrapper> calculateZipCodeWorkType(List<XC_PartnerCoverage__c> listPartnerCoverage) {
        List<ZipCodeWorkTypeWrapper> listWrapper = new List<ZipCodeWorkTypeWrapper>();
        for(XC_PartnerCoverage__c pc : listPartnerCoverage) {
            ZipCodeWorkTypeWrapper wrapper = new ZipCodeWorkTypeWrapper();
            wrapper.workType = pc.XC_WorkType__c;
            wrapper.zipCode = pc.XC_ZipCode__c;
            listWrapper.add(wrapper);
        }
        return listWrapper;
    }

}