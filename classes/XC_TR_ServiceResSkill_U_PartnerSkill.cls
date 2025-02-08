/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 21/01/2020
* @description XC_TR_ServiceResSkill_U_PartnerSkill – Class to manage skills for ServiceResourceSkill
*/

public without sharing class XC_TR_ServiceResSkill_U_PartnerSkill {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_ServiceResSkill_U_PartnerSkill');

    /**
     * @description Popoulate End Date from Start Date
     * @param listAllSkills the list all skills 
     */
    public static void populateEndDate(List<ServiceResourceSkill> listAllSkills){ 
        for(ServiceResourceSkill srs : listAllSkills){
            srs.EffectiveEndDate = srs.EffectiveStartDate;
        } 
    } 

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 21/01/2020
    * @description Method to copy Skill on insert
    * @param listNew - List<ServiceResourceSkill>
    */
    /*public static void copySkillsOnInsert(List<ServiceResourceSkill> listNew){ 
        Map<Id, List<ServiceResourceSkill>> mapAccountListOfSkills = getMapAccountListOfSkills(listNew);
        if(mapAccountListOfSkills.isEmpty()){
            return;
        } 

        Map<Id, List<ServiceResource>> mapAccountIdListSR = getMapAccountIdListSR(mapAccountListOfSkills.keySet());
        List<ServiceResourceSkill> listToInsert = new List<ServiceResourceSkill>();
        List<ServiceResource> listServiceResource = new List<ServiceResource>();
        for(String key : mapAccountIdListSR.keySet()) {
            for(ServiceResource sr : mapAccountIdListSR.get(key)) {
                listServiceResource.add(sr);
            }
        }
        Map<String, Boolean> mapCheckCopy = createMapForCheckCopy(listServiceResource);

        for(Id accId : mapAccountListOfSkills.keySet()) {
            if(mapAccountListOfSkills.get(accId).isEmpty()) {
                continue;
            }
            List<ServiceResource> listSR = mapAccountIdListSR.get(accId);
            for(ServiceResource sr : listSR){
                if(!mapCheckCopy.get(sr.Id)) {
                    continue;
                }
                for(ServiceResourceSkill srs : mapAccountListOfSkills.get(accId)){
                    listToInsert.add(
                        new ServiceResourceSkill(
                            ServiceResourceId = sr.Id,
                            SkillId = srs.SkillId,
                            SkillLevel = srs.SkillLevel,
                            XC_AssignmentEndDate__c = srs.XC_AssignmentEndDate__c,
                            XC_AssignmentStartDate__c = srs.XC_AssignmentStartDate__c,
                            XC_CertificationEndDate__c = srs.XC_CertificationEndDate__c,
                            XC_CertificationStartDate__c = srs.XC_CertificationStartDate__c,
                            XC_Country__c = srs.XC_Country__c,
                            EffectiveStartDate = srs.EffectiveStartDate,
                            EffectiveEndDate  = srs.EffectiveEndDate,
                            XC_InheritedByParent__c = true
                        )
                    );
                }
            } 
        }

        XC_UTIL_Sobject.insertListRecords(listToInsert);
    }*/

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 21/01/2020
    * @description Method to create a map AccountId -> list Service Resource
    * @param setAccIds - Set<Id>
    * @return Map<Id, List<ServiceResource>>
    */
    /*private static Map<Id, List<ServiceResource>> getMapAccountIdListSR(Set<Id> setAccIds){
        List<ServiceResource> listResources = new List<ServiceResource>([
            SELECT Id, XC_Account__c, XC_LegalEntity__c,
                (SELECT Id, SkillId, EffectiveEndDate, EffectiveStartDate, XC_AssignmentEndDate__c, XC_AssignmentStartDate__c, XC_CertificationEndDate__c, XC_CertificationStartDate__c
                FROM ServiceResourceSkills) 
            FROM ServiceResource 
            WHERE XC_Account__c IN: setAccIds AND XC_IsManager__c = false AND ResourceType = 'T' AND isActive = true
        ]);
        Map<Id, List<ServiceResource>> mapAccountIdListSR = new Map<Id, List<ServiceResource>>();
        for(ServiceResource sr : listResources){
            if(!mapAccountIdListSR.containsKey(sr.XC_Account__c)){
                mapAccountIdListSR.put(sr.XC_Account__c, new List<ServiceResource>());
            }
            mapAccountIdListSR.get(sr.XC_Account__c).add(sr);
        }
        return mapAccountIdListSR;
    }*/

    /**
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @date 21/01/2020
     * @description Method to create a map to check if skill must be copied (by Legal Entity)
     * @param listServiceResource - List<ServiceResource>
     * @return Map<String, Boolean>
     */
    /*public static Map<String, Boolean> createMapForCheckCopy(List<ServiceResource> listServiceResource) { 
        List<String> listLegalEntity = XC_UTIL_Sobject.getListFieldValues(listServiceResource, 'XC_LegalEntity__c');
        List<XC_CM_FSLDefaultValue__mdt> listFSLcm = new List<XC_CM_FSLDefaultValue__mdt>([
            SELECT Id, XC_LegalEntity__c, XC_SkillAutoCopy__c
            FROM XC_CM_FSLDefaultValue__mdt
            WHERE XC_LegalEntity__c IN :listLegalEntity
        ]);
        Map<String, Boolean> mapCheckCopy = new Map<String, Boolean>();
        for(ServiceResource sr : listServiceResource){
            for(XC_CM_FSLDefaultValue__mdt cm : listFSLcm) {
                if(sr.XC_LegalEntity__c == cm.XC_LegalEntity__c) {
                    mapCheckCopy.put(sr.Id, cm.XC_SkillAutoCopy__c);
                    break;
                }  
            }
        } 
        return mapCheckCopy;
    } */

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 21/01/2020
    * @description Method to copy skills of Partner on Service Resource
    * @param listNew - List<ServiceResourceSkill>
    * @param mapOld - Map<Id, ServiceResourceSkill>
    * @param mapNew - Map<Id, ServiceResourceSkill>
    */
    /*public static void copySkillsOnUpdate(List<ServiceResourceSkill> listNew, Map<Id, ServiceResourceSkill> mapOld, Map<Id, ServiceResourceSkill> mapNew){
        List<String> fieldList = new List<String>{'EffectiveEndDate', 'EffectiveStartDate', 'XC_AssignmentEndDate__c', 'XC_AssignmentStartDate__c', 'XC_CertificationEndDate__c', 'XC_CertificationStartDate__c'};
        List<ServiceResourceSkill> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(listChanged.isEmpty()){
            return;
        }
        Map<Id, List<ServiceResourceSkill>> mapAccountListOfSkills = getMapAccountListOfSkills(listChanged);
        if(mapAccountListOfSkills.isEmpty()){
            return;
        } 
        Map<Id, List<ServiceResource>> mapAccountIdListSR = getMapAccountIdListSR(mapAccountListOfSkills.keySet());
        List<ServiceResourceSkill> listSrsToUpdate = new List<ServiceResourceSkill>();
        List<ServiceResource> listServiceResource = new List<ServiceResource>();
        for(String key : mapAccountIdListSR.keySet()) {
            for(ServiceResource sr : mapAccountIdListSR.get(key)) {
                listServiceResource.add(sr);
            }
        }
        Map<String, Boolean> mapCheckCopy = createMapForCheckCopy(listServiceResource);
        
        for(Id accId : mapAccountIdListSR.keySet()) {
            for(ServiceResource sr : mapAccountIdListSR.get(accId)) {
                if(!mapCheckCopy.get(sr.Id)) {
                    continue;
                }
                Map<Id, ServiceResourceSkill> mapSkillIdServiceResourceSkill = new Map<Id, ServiceResourceSkill>();
                for(ServiceResourceSkill srs : sr.ServiceResourceSkills){
                    mapSkillIdServiceResourceSkill.put(srs.SkillId, srs);
                }
                for(ServiceResourceSkill srs : mapAccountListOfSkills.get(accId)){
                    if(srs != null){
                        ServiceResourceSkill srsToUpdate = mapSkillIdServiceResourceSkill.get(srs.SkillId);
                        if(srs.EffectiveEndDate != null){
                            srsToUpdate.EffectiveEndDate = srs.EffectiveEndDate;
                        }
                        if(srs.EffectiveStartDate != null){
                            srsToUpdate.EffectiveStartDate = srs.EffectiveStartDate; 
                        }
                        if(srs.XC_AssignmentEndDate__c != null){
                            srsToUpdate.XC_AssignmentEndDate__c = srs.XC_AssignmentEndDate__c;
                        }
                        if(srs.XC_AssignmentStartDate__c != null){
                            srsToUpdate.XC_AssignmentStartDate__c = srs.XC_AssignmentStartDate__c;
                        } 
                        if(srs.XC_CertificationEndDate__c != null){
                            srsToUpdate.XC_CertificationEndDate__c = srs.XC_CertificationEndDate__c;
                        }
                        if(srs.XC_CertificationStartDate__c != null){
                            srsToUpdate.XC_CertificationStartDate__c = srs.XC_CertificationStartDate__c;
                        } 
                        listSrsToUpdate.add(srsToUpdate);
                    }
                }
            }            
        }           

        XC_UTIL_Sobject.updateListRecords(listSrsToUpdate);
    }*/

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com
    * @date Creation 21/01/2020
    * @description Method to get map account id -> list skill
    * @param listNew - List<ServiceResourceSkill>
    */
    /*private static Map<Id, List<ServiceResourceSkill>> getMapAccountListOfSkills(List<ServiceResourceSkill> listNew){
        List<ServiceResourceSkill> listToManage = new List<ServiceResourceSkill>([
            SELECT Id, SkillLevel, SkillId, ServiceResourceId, XC_AssignmentEndDate__c, XC_AssignmentStartDate__c, EffectiveStartDate, EffectiveEndDate,
                   XC_CertificationEndDate__c, XC_CertificationStartDate__c, XC_Country__c, ServiceResource.XC_Account__c, ServiceResource.XC_IsManager__c 
            FROM ServiceResourceSkill
            WHERE Id IN :listNew
        ]);
        Map<Id, List<ServiceResourceSkill>> mapAccountListOfSkills = new Map<Id, List<ServiceResourceSkill>>();
        for(ServiceResourceSkill srs : listToManage){
            if(srs.ServiceResource.XC_IsManager__c){ 
                if(!mapAccountListOfSkills.containsKey(srs.ServiceResource.XC_Account__c)){
                    mapAccountListOfSkills.put(srs.ServiceResource.XC_Account__c, new List<ServiceResourceSkill>());
                }
                mapAccountListOfSkills.get(srs.ServiceResource.XC_Account__c).add(srs);
            }
        }
        return mapAccountListOfSkills;
    }*/

}