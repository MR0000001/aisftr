/**
 * The Class XC_TR_ServiceResourceSkill_U_SkillOnUser.
 *
 * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com & Marco Rosa - marco.rosa@nttdata.com
 * @date Creation 21/01/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_ServiceResourceSkill_U_SkillOnUser
 */

public without sharing class XC_TR_ServiceResourceSkill_U_SkillOnUser {

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param userIds the user ids
     * @description Given a set of User Ids populates the field XC_ListOfServiceResourceSkills__c with the concatenation of Skills of the corresponding Service Resources
     */
    
    public static void manageSkill(Set<Id> userIds){
        if(!userIds.isEmpty() && Schema.sObjectType.ServiceResourceSkill.isAccessible() && Schema.sObjectType.ServiceResourceSkill.fields.Id.isAccessible() && Schema.sObjectType.ServiceResourceSkill.fields.SkillId.isAccessible() && Schema.sObjectType.ServiceResourceSkill.fields.ServiceResourceId.isAccessible()){    
            List<ServiceResourceSkill> listAllSkills = [
                SELECT Id, Skill.MasterLabel, ServiceResource.RelatedRecordId,ServiceResource.RelatedRecord.XC_ListOfServiceResourceSkills__c
                FROM ServiceResourceSkill 
                WHERE ServiceResource.RelatedRecordId IN: userIds
                AND (Skill.MasterLabel LIKE 'Venta%' OR Skill.MasterLabel LIKE 'Commercial%' OR Skill.MasterLabel LIKE 'Visita%')
            ];    
            Map<Id, Set<String>> mapUserSetSkills = getMapUserSetSkills(listAllSkills);
            Map<Id, String> mapUserOldSkills = getMapUserOldSkills(listAllSkills);
            List<User> listToUpdate = returnListToUpdate(userIds,mapUserSetSkills,mapUserOldSkills );
            XC_UTIL_SObject.updateListRecords(listToUpdate);
        }
    }
    
    /**
     * @author Marco Rosa - marco.rosa@nttdata.com & Salvatore Scarpato - salvatore.scarpato@nttdata.com
     * @param listAllSkills the list all skills
     * @return the map user set skills
     * @description Returns a Map UserId -> List of Skills of the corresponding Service Resource
     */
             
    public static Map<Id, Set<String>> getMapUserSetSkills(List<ServiceResourceSkill> listAllSkills){
        Map<Id, Set<String>> mapUserSetSkills = new Map<Id, Set<String>>();
        for(ServiceResourceSkill sRSkill : listAllSkills){
            if(!mapUserSetSkills.containsKey(sRSkill.ServiceResource.RelatedRecordId)){
                mapUserSetSkills.put(sRSkill.ServiceResource.RelatedRecordId, new Set<String>());
            }
            mapUserSetSkills.get(sRSkill.ServiceResource.RelatedRecordId).add(sRSkill.Skill.MasterLabel);
        } 
        return mapUserSetSkills;
    } 
    
    /**
     * @description Gets the map user old skills.
     * @param listAllSkills the list all skills
     * @return the map user old skills
     */
    public static Map<Id, String> getMapUserOldSkills(List<ServiceResourceSkill> listAllSkills){ 
        Map<Id, String> mapid = new Map<Id, String>();
        for(ServiceResourceSkill srs : listAllSkills){
            mapid.put(srs.ServiceResource.RelatedRecordId, srs.ServiceResource.RelatedRecord.XC_ListOfServiceResourceSkills__c);
        }     
        return mapid;
    }    
    
    
    /**
     * @description Skill on user on insert.
     * @param listNew the list new
     */
    public static void skillOnUserOnInsert(List<ServiceResourceSkill> listNew){
        Set<Id> users = new Set<Id>();
        List<String> getServiceResourceSkillId = XC_UTIL_Sobject.getIds(listNew);
        List<ServiceResourceSkill> serviceResourceSkillList = [
            SELECT Id, ServiceResource.RelatedRecordId 
            FROM ServiceResourceSkill 
            WHERE Id IN: getServiceResourceSkillId
        ];       
        for(ServiceResourceSkill srs : serviceResourceSkillList){
            users.add(srs.ServiceResource.RelatedRecordId);
        }     
        manageSkill(users);      
    }
    
    /**
     * @description Skill on user on update.
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     */
    public static void skillOnUserOnUpdate(List<ServiceResourceSkill> listNew, Map<Id,ServiceResourceSkill> mapOld, Map<Id,ServiceResourceSkill> mapNew){    
        List<String> fieldList = new List<String>{'SkillId'};
        List<AssignedResource> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew);
        if(!listChanged.isEmpty()){
            Set<Id> users = new Set<Id>();
            List<String> getServiceResourceSkillId = XC_UTIL_Sobject.getIds(listChanged);
            List<ServiceResourceSkill> serviceResourceSkillList = [
                SELECT Id, ServiceResource.RelatedRecordId 
                FROM ServiceResourceSkill 
                WHERE Id IN: getServiceResourceSkillId
            ];       
            for(ServiceResourceSkill srs : serviceResourceSkillList){
                users.add(srs.ServiceResource.RelatedRecordId);
            }     
            manageSkill(users);  
        }     
    }
    
    /**
     * @description Skill on user on delete.
     * @param listOld the list old
     */
    public static void skillOnUserOnDelete(List<ServiceResourceSkill> listOld){
        List<String> getServiceResourceId = XC_UTIL_SObject.getListFieldValues(listOld, 'ServiceResourceId');
        List<ServiceResource> serviceResourceList = new List<ServiceResource>();
        if(Schema.sObjectType.ServiceResource.isAccessible() && Schema.sObjectType.ServiceResource.fields.Id.isAccessible() && Schema.sObjectType.ServiceResource.fields.RelatedRecordId.isAccessible()){
            serviceResourceList = [
                SELECT Id,RelatedRecordId  
                FROM ServiceResource 
                WHERE Id IN: getServiceResourceId
            ];
        }
        Set<Id> userIdSet = new Set<Id>();
        for(ServiceResource sr : serviceResourceList){
            userIdSet.add(sr.RelatedRecordId);
        }
        manageSkill(userIdSet); 
    }

    /**
     * @description return the list of user to update
     * @param userIds ids of users
     * @param mapUserSetSkills
     * @param mapUserOldSkills
     * @return listToUpdate
     */
    public static List<User> returnListToUpdate(Set<Id> userIds, Map<Id, Set<String>> mapUserSetSkills, Map<Id, String> mapUserOldSkills){
        List<User> listToUpdate = new List<User>();
        for(Id userId : userIds){
            if(mapUserSetSkills.containsKey(userId)){
                Set<String> setSkills = mapUserSetSkills.get(userId);
                String listSkillsNew = String.join(new List<String>(setSkills), ';');
                if(listSkillsNew.length()>255) {
                    listSkillsNew = listSkillsNew.substring(0,255);
                }
                if(!mapUserOldSkills.isEmpty() && listSkillsNew != mapUserOldSkills.get(userId)){
                    User u = new User();
                    u.Id = userId;
                    u.XC_ListOfServiceResourceSkills__c = listSkillsNew;
                    listToUpdate.add(u);
                }
            } else {
                User u = new User();
                u.Id = userId;
                u.XC_ListOfServiceResourceSkills__c = '';
                listToUpdate.add(u);
            } 
        }
        return listToUpdate;
    }
}