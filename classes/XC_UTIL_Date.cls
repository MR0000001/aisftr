/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com - Marco Rosa - marco.rosa@nttdata.com
* @date 05/03/2020
* @description XC_UTIL_Date - Util class for Date variables
*/ 

public without sharing class XC_UTIL_Date {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_UTIL_Date');

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com - Marco Rosa - marco.rosa@nttdata.com
    * @date 05/03/2020
    * @description Add days to Date input for only working date
    * @param dateToManage - Datetime
    * @param numberHourToAdd - Integer
    */ 
    public static Datetime addWorkingDays(Datetime dateToManage, Integer numberHourToAdd) {
        Integer notWorkingHours = 0;
        for(Integer i=1; i<=numberHourToAdd; i++) {     
            DateTime dateTemp = dateToManage.addHours(i);       
            String dayOfWeek = dateTemp.format('u');
            if(dayOfWeek == '6' || dayOfWeek == '7') {
                notWorkingHours++;
            } 
        }
        DateTime finalDate = dateToManage.addHours(numberHourToAdd + notWorkingHours);
        String dayOfWeekFinalDate = finalDate.format('u');
        if(dayOfWeekFinalDate == '6') {
            finalDate = finalDate.addDays(2);
        } 
        else if(dayOfWeekFinalDate == '7') {
            finalDate = finalDate.addDays(1);
        } 
        return finalDate;
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/03/2020
     * @description Method to validate age of current client
     * @param mapNew - Map<Id, sObject> 
     * @param mapSobjectLegalEntity - Map<String, List<String>>
     * @param mapSobjectBirthday - Map<String, Date>
     * @return List<sObject> - sObjects with minor age
    */ 
    public static List<sObject> checkAdultAge(Map<Id, sObject> mapNew, Map<String, List<String>> mapSobjectLegalEntity, Map<String, Date> mapSobjectBirthday) { 
        List<sObject> sObjectNotInserted = new List<sObject>();
        List<String> listAllLE = new List<String>();
        for(String key : mapSobjectLegalEntity.keySet()) {
            listAllLE.addAll(mapSobjectLegalEntity.get(key));
        }
        Set<String> setStream = XC_UTIL_SObject.getSetIdsStringOnField(mapNew.values(), 'XC_Segment__c');
        // Retrieve custom metadata for major age for Legal Entity:
        List<XC_CM_LegalEntity_Configuration__mdt> listCMlegalEntity = new List<XC_CM_LegalEntity_Configuration__mdt>([
            SELECT Id, XC_Majority__c, XC_LegalEntity__c
            FROM XC_CM_LegalEntity_Configuration__mdt 
            WHERE XC_LegalEntity__c IN :listAllLE AND XC_Stream__c IN :setStream AND XC_OrgId__c =: UserInfo.getOrganizationId()
        ]);
        Map<String, Integer> mapLegalEntityAge = new Map<String, Integer>();
        for(XC_CM_LegalEntity_Configuration__mdt cm : listCMlegalEntity) {
            mapLegalEntityAge.put(cm.XC_LegalEntity__c, Integer.valueOf(cm.XC_Majority__c));
        }
        if(mapLegalEntityAge.values().isEmpty()) {
            return sObjectNotInserted;
        }

        // Check major age for client:
        for(String key : mapSobjectBirthday.keySet()) {
            if(!sObjectNotInserted.contains(mapNew.get(key))) {
                List<String> listLE = mapSobjectLegalEntity.get(key);
                for(String legalEntity : listLE) {
                    Date birthday = mapSobjectBirthday.get(key);
                    Integer adultAge = mapLegalEntityAge.get(legalEntity);
                    Integer currentAge = Math.abs(Integer.valueOf((Date.today().daysBetween(birthday))/365.2425));               
                    if(currentAge < adultAge) {
                        sObjectNotInserted.add(mapNew.get(key));
                    }
                }
            }
        }

        return sObjectNotInserted;
    }

}