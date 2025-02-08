/**
* @author Salvatore Scarpato salvatore.scarpato@nttdata.com
* @date Creation 09/03/2021
* @date Modification 
* @description XC_TR_DocumentType_U_CreateSRSkills –  XC_TR_DocumentType_U_CreateSRSkills Create service resource skills from documents
*/  

public without sharing class XC_TR_DocumentType_U_CreateSRSkills {

      public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_DocumentType_U_CreateSRSkills');


      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/03/2021 
      * @param listNew 
      **/
      public static void onInsert(List<XC_DocumentType__c> listNew) {
            List<XC_DocumentType__c> listToManage = checkDocumentTypes(listNew);
            if(listToManage.isEmpty()){
                  return;
            }
            List<String> contactOnDocTypeList = XC_UTIL_Sobject.getListFieldValues(listToManage, 'XC_Contact__c');
            List<String> categoryList = XC_UTIL_Sobject.getListFieldValues(listToManage, 'Category__c');
            Map<String, String> skillMap = getDocumentSkillAssociation(categoryList); 
            if(skillMap.isEmpty()){
                  return;
            }

            Map<String, String> contactIdServiceResourceIdMap = getServiceResource(contactOnDocTypeList);
            if(contactIdServiceResourceIdMap.isEmpty()){
                  return;
            }
            List<ServiceResourceSkill> srsListToInsert = new List<ServiceResourceSkill>();
            for(XC_DocumentType__c docType : listToManage){
                  ServiceResourceSkill srSkill = new ServiceResourceSkill();
                  if(contactIdServiceResourceIdMap.containsKey(docType.XC_Contact__c)){
                        srSkill.ServiceResourceId = contactIdServiceResourceIdMap.get(docType.XC_Contact__c);
                        String category = docType.Category__c;
                        srSkill.SkillId = skillMap.get(category);
                        srSkill.SkillLevel = 1;
                        srSkill.EffectiveStartDate = System.Today();
                        srSkill.EffectiveEndDate = docType.XC_ExpirationDate__c;
                        srsListToInsert.add(srSkill);  
                  }
            }
            XC_UTIL_Sobject.insertListRecords(srsListToInsert);
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/03/2021  
      * @param mapOld 
      * @param mapNew 
      **/
      public static void onUpdate(Map<Id, SObject> mapOld, Map<Id, SObject> mapNew) {
            List<XC_DocumentType__c> listDocumentTypeChanged = XC_UTIL_SObject.getListChanged(new List<String>{'XC_ExpirationDate__c'}, mapOld, mapNew);
            if(listDocumentTypeChanged.isEmpty()){
                return;
            }
            List<XC_DocumentType__c> listToManage = checkDocumentTypes(listDocumentTypeChanged);
            if(listToManage.isEmpty()){
                  return;
            }
            List<String> contactOnDocTypeList = XC_UTIL_Sobject.getListFieldValues(listToManage, 'XC_Contact__c');
            List<String> categoryList = XC_UTIL_Sobject.getListFieldValues(listToManage, 'Category__c');
            Map<String, String> contactIdServiceResourceIdMap = getServiceResource(contactOnDocTypeList);
            Map<String, List<String>> skillCategoryMap = getSkillCategoryMap(categoryList);
            Map<String, String> skillMap = getDocumentSkillAssociation(categoryList); 
            Map<String, List<ServiceResourceSkill>> mapServiceResourceIdSRS = getExistingServiceResourceSkills(contactIdServiceResourceIdMap.values(), skillCategoryMap.keySet());
            List<ServiceResourceSkill> srsListToUpdate = new List<ServiceResourceSkill>();
            for(XC_DocumentType__c docType : listToManage){
                  if(contactIdServiceResourceIdMap.containsKey(docType.XC_Contact__c)){
                        String serviceResourceId = contactIdServiceResourceIdMap.get(docType.XC_Contact__c);
                        if(mapServiceResourceIdSRS.containsKey(serviceResourceId)){
                              List<ServiceResourceSkill> srsList = mapServiceResourceIdSRS.get(serviceResourceId);
                              for(ServiceResourceSkill srs : srsList){
                                    if(skillMap.containsKey(docType.Category__c)){
                                          if(skillMap.get(docType.Category__c) == srs.SkillId){
                                                srs.EffectiveEndDate = docType.XC_ExpirationDate__c;
                                                srsListToUpdate.add(srs);
                                          }
                                    }
                              }
                        }
                  }
            }
            XC_UTIL_Sobject.updateListRecords(srsListToUpdate);
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/03/2021 
      * @param listToCheck 
      * @return List<XC_DocumentType__c> 
      **/
      private static List<XC_DocumentType__c> checkDocumentTypes(List<XC_DocumentType__c> listToCheck) {
            List<XC_DocumentType__c> listToManage = new List<XC_DocumentType__c>();
            for(XC_DocumentType__c docType : listToCheck){
                  if(!String.isEmpty(docType.XC_Contact__c) && !String.isEmpty(docType.Category__c)){
                        listToManage.add(docType);
                  }
            }
            return listToManage;
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/03/2021
      * @param categoryList 
      * @return Map<String, String> 
      **/
      private static Map<String, String> getDocumentSkillAssociation(List<String> categoryList) {
            Map<String, String> skillMap = new Map<String, String>(); 
            Map<String, List<String>> skillCategoryMap = getSkillCategoryMap(categoryList);
            List<Skill> skillList = new List<Skill>([SELECT Id, MasterLabel
                                                      FROM Skill
                                                      WHERE MasterLabel IN: skillCategoryMap.keySet()]);

            for(Skill sk : skillList){
                  if(skillCategoryMap.containsKey(sk.MasterLabel)){
                        for(String document : skillCategoryMap.get(sk.MasterLabel)){
                              if(!String.isEmpty(document)){
                                    skillMap.put(document, sk.Id);
                              }
                        }
                  }
            }
            return skillMap;
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/03/2021
      * @param contactIdList 
      * @return Map<String, String> 
      **/
      private static Map<String, String> getServiceResource(List<String> contactIdList){
            Map<String, String> contactIdServiceResourceIdMap = new Map<String, String>();
            List<ServiceResource> srList = new List<ServiceResource>([SELECT Id, IsActive, XC_Contact__c 
                                                                        FROM ServiceResource
                                                                        WHERE XC_Contact__c IN: contactIdList
                                                                        AND IsActive =: true]);
            for(ServiceResource sr: srList){
                  contactIdServiceResourceIdMap.put(sr.XC_Contact__c, sr.Id);
            }
            return contactIdServiceResourceIdMap;
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/03/2021 
      * @param serviceResourcesIdList 
      * @param skillIdList 
      * @return Map<String, List<ServiceResourceSkill>> 
      **/
      private static Map<String, List<ServiceResourceSkill>> getExistingServiceResourceSkills(List<String> serviceResourcesIdList,Set<String> skillNameList ){
            Map<String, List<ServiceResourceSkill>> mapServiceResourceIdSrs = new Map<String, List<ServiceResourceSkill>>();
            List<ServiceResourceSkill> serviceResSkillList = new List<ServiceResourceSkill>([SELECT Id, SkillId, Skill.MasterLabel, ServiceResourceId, ServiceResource.XC_Contact__c, EffectiveEndDate
                                                                                                FROM ServiceResourceSkill
                                                                                                WHERE ServiceResourceId IN: serviceResourcesIdList
                                                                                                AND Skill.MasterLabel IN: skillNameList]);
            for(ServiceResourceSkill srs : serviceResSkillList){
                  if(!mapServiceResourceIdSrs.containsKey(srs.ServiceResourceId)){
                        mapServiceResourceIdSrs.put(srs.ServiceResourceId, new List<ServiceResourceSkill>());
                  }
                  mapServiceResourceIdSrs.get(srs.ServiceResourceId).add(srs);
            }
            return mapServiceResourceIdSrs;
      }

      /**
      * @description 
      * @author Salvatore Scarpato - salvatore.scarpato@nttdata.com | 09/03/2021
      * @param categoryList 
      * @return Map<String, List<String>> 
      **/
      private static Map<String, List<String>> getSkillCategoryMap(List<String> categoryList){
            Map<String, List<String>> skillCategoryMap = new Map<String, List<String>>(); 
            List<XC_CM_DocumentSkillAssociation__mdt> docSkillAssociationList = new List<XC_CM_DocumentSkillAssociation__mdt>([SELECT id, XC_Document__c, XC_Skill__c 
                                                                                                                              FROM XC_CM_DocumentSkillAssociation__mdt
                                                                                                                              WHERE XC_Document__c IN: categoryList]);
            
            for( XC_CM_DocumentSkillAssociation__mdt docSkillAssociation : docSkillAssociationList){
                  if(!skillCategoryMap.containsKey(docSkillAssociation.XC_Skill__c)){
                        skillCategoryMap.put(docSkillAssociation.XC_Skill__c, new List<String>());
                  }
                  skillCategoryMap.get(docSkillAssociation.XC_Skill__c).add(docSkillAssociation.XC_Document__c);
            }
            return skillCategoryMap;
      }
}