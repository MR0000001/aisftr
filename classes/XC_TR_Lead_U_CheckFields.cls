/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 31/03/2020
* @description XC_TR_Lead_U_CheckFields – Util class to validate inserted/updated leads
*/  

public without sharing class XC_TR_Lead_U_CheckFields {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_Lead_U_CheckFields');

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/03/2020
     * @description Method to validate inserted leads
     * @param mapNew - Map<Id, Lead> 
    */ 
    public static void checkOnInsert(Map<Id, Lead> mapNew) { 
        // Check for major age:  
        Map<String, Date> mapLeadBirthday = new Map<String, Date>();
        Map<String, List<String>> mapLeadLegalEntity = new Map<String, List<String>>();
        for(Lead ld : mapNew.values()) {
            if(String.isNotBlank(String.valueOf(ld.XC_Birthdate__c))) {
                mapLeadLegalEntity.put(ld.Id, new List<String>{ld.XC_MainLegalEntity__c});
                mapLeadBirthday.put(ld.Id, ld.XC_Birthdate__c);
            }
        }
        if(mapLeadBirthday.values().isEmpty()) {
            return;
        }

        List<sObject> listSobjectWithError = XC_UTIL_Date.checkAdultAge(mapNew, mapLeadLegalEntity, mapLeadBirthday);
        for(sObject obj : listSobjectWithError) {
            obj.addError(Label.XC_CL_ErrorAdultAge);
        }
    }

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 31/03/2020
     * @description Method to validate updated Lead
     * @param mapNew - Map<Id, Lead> 
     * @param mapOld - Map<Id, Lead> 
    */ 
    public static void checkOnUpdate(Map<Id, Lead> mapOld, Map<Id, Lead> mapNew) { 
        List<Lead> listLeadToManageBday = XC_UTIL_Sobject.getListChanged(new List<String>{'XC_Birthdate__c'}, mapOld, mapNew);
        // Check for Major age: 
        if(!listLeadToManageBday.isEmpty()) {
            Map<Id, Lead> mapLead = new Map<Id, Lead>();
            for(Lead ld : listLeadToManageBday) {
                mapLead.put(ld.Id, ld);
            }
            checkOnInsert(mapLead);
        }
    }

}