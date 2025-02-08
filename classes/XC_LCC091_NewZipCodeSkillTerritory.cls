/**
* @description XC_LCC091_NewZipCodeSkillTerritory - Class for NewZipCodeSkillTerritory component
*/

public without sharing class XC_LCC091_NewZipCodeSkillTerritory {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC091_NewZipCodeSkillTerritory');
    
    /**
     * @description  method for checkRootTerritoryForProfiles
     * @param recordId the record id
     * @return the boolean
     */
    @AuraEnabled
    public static Boolean checkRootTerritoryForProfiles (Id recordId){
        return XC_LCC091_U_NewZipCodeSkillTerritory.checkRootTerritoryForProfiles(recordId);
    }

    /**
     * Check root territory for profiles.
     * @description  method for checkRootTerritory
     * @param recordId the record id
     * @return the boolean
     */
    @AuraEnabled
    public static Boolean checkRootTerritory(Id recordId){
        Boolean isRoot = false;
         if(!Schema.sObjectType.ServiceTerritory.isAccessible()){
            isRoot = false;
        }else{
            Map<Id,ServiceTerritory> serviceTerritoryMap = new Map<Id,ServiceTerritory>([SELECT Id, XC_IsRoot__c 
                                                                                        FROM ServiceTerritory WHERE Id =: recordId]);
            ServiceTerritory serviceTerritory = serviceTerritoryMap.values();
            if(serviceTerritory.XC_IsRoot__c == true ){
                isRoot = true;
            }                    
        }
        return isRoot;
    }
    
    /**
     * Check root territory for profiles.
     * @description  method for getRootProvince
     * @param recordId the record id
     * @return the boolean
     */
    @AuraEnabled
    public static List<String> getRootProvince(Id recordId){
        List<String> province = new List<String>();
        if(!Schema.sObjectType.ServiceTerritory.isAccessible() && !Schema.sObjectType.XC_ZipCodeSkill_TerritoryAssociation__c.isAccessible() ){
            return province;
        }else{
        Map<Id,ServiceTerritory> serviceTerritoryMap = new Map<Id,ServiceTerritory>( [SELECT Id, TopLevelTerritoryId FROM ServiceTerritory WHERE Id =: recordId]);
        ServiceTerritory serviceTerritoryChild = serviceTerritoryMap.values();
        Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>(  [SELECT Id, XC_Province__c  FROM XC_ZipCodeSkill_TerritoryAssociation__c WHERE XC_ServiceTerritoryId__c =: serviceTerritoryChild.TopLevelTerritoryId]);
           
         List<XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritory = zipcodeterritoryMap.values();  
            for(XC_ZipCodeSkill_TerritoryAssociation__c zipCodTerr : zipcodeterritory ){
                if (!province.contains(zipCodTerr.XC_Province__c)){
                    province.add(zipCodTerr.XC_Province__c);
                }
            }
        }
        return province;
    }

    /**
     * Check root territory for profiles.
     * @description  method for getZipCodeFromRoot
     * @param recordId the record id
     * @param province the record id
     * @return the boolean
     */
    @AuraEnabled
    public static List<String> getZipCodeFromRoot(Id recordId, String province){
        List<String> zipCode = new List<String>(); 
         if(!Schema.sObjectType.ServiceTerritory.isAccessible() && !Schema.sObjectType.XC_ZipCodeSkill_TerritoryAssociation__c.isAccessible() ){
            return zipCode;
        }else{
        Map<Id,ServiceTerritory> serviceTerritoryMap = new Map<Id,ServiceTerritory>(  [SELECT Id, TopLevelTerritoryId FROM ServiceTerritory WHERE Id =: recordId]);
        ServiceTerritory serviceTerritoryChild = serviceTerritoryMap.values();
         Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>( [SELECT Id, XC_Province__c ,XC_ZipCode__c 
                                                                            FROM XC_ZipCodeSkill_TerritoryAssociation__c 
                                                                            WHERE XC_ServiceTerritoryId__c =: serviceTerritoryChild.TopLevelTerritoryId
                                                                            AND XC_Province__c = : province]);
        List<XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritory = zipcodeterritoryMap.values();
            for(XC_ZipCodeSkill_TerritoryAssociation__c zipCodTerr : zipcodeterritory ){
                zipCode.add(zipCodTerr.XC_ZipCode__c);
            }
        }
        return zipCode;
    }

    /**
     * Gets the country.
     * @description  method for getCountry
     * @param recordId the record id
     * @return the country
     */
    @AuraEnabled
    public static String getCountry(String recordId){
        String country = '';
       if(XC_UTIL_Sobject.getObjectType(recordId) == 'ServiceTerritory'){
            if(!Schema.sObjectType.ServiceTerritory.isAccessible()){
                return country;
            } else{ 
                Map<Id,ServiceTerritory> serviceTerritoryMap = new Map<Id,ServiceTerritory>( [SELECT Id, XC_Country__c FROM ServiceTerritory WHERE Id =: recordId]);
                ServiceTerritory serviceTerritory = serviceTerritoryMap.values();
                country = serviceTerritory.XC_Country__c;
            }
        }else if(XC_UTIL_Sobject.getObjectType(recordId) == 'XC_ZipCodeSkill_TerritoryAssociation__c') {
             if(!Schema.sObjectType.XC_ZipCodeSkill_TerritoryAssociation__c.isAccessible() ){
                  return country;
            } else{
                 Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>( [SELECT Id, XC_ServiceTerritoryId__r.XC_Country__c  FROM XC_ZipCodeSkill_TerritoryAssociation__c WHERE Id =: recordId]);
                 XC_ZipCodeSkill_TerritoryAssociation__c zipcodeterritory = zipcodeterritoryMap.values();
                country = zipcodeterritory.XC_ServiceTerritoryId__r.XC_Country__c;
            }
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'recordId -->'+recordId);
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'country-->' + country);
        return country;              
    }     
    
    /**
    * @param mapSkillTerritoryString - String
    * @description Method for save Skill Territory
    * @return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper saveSkillTerritory(String mapSkillTerritoryString){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        // Modifica Salvatore Agrillo (06/05/2019)
        if(String.isBlank(mapSkillTerritoryString)){
            rw.resultMessage = Label.XC_CL_SkillDocumentAssociation_ErrorLoadData;
            rw.success = false;
            return rw;
        } 
        Map<String,Object> mapSkillTerritory = (Map<String, Object>) JSON.deserializeUntyped(mapSkillTerritoryString);
        String recordId = (String) mapSkillTerritory.get('recordId');
        String zipCode = (String) mapSkillTerritory.get('zipCode');
        String province = (String) mapSkillTerritory.get('province');
        String skillList = (String) mapSkillTerritory.get('skillList');
        
        List<String> skillIds = new List<String>();
        String skillId;
        if(!Schema.sObjectType.Skill.isAccessible() && !Schema.sObjectType.ServiceTerritory.isAccessible() ){
            return rw;
        } else{
            if(!String.isBlank(skillList)){
                List<String> skillNames = skillList.split(';');
                List<Skill> skList = [SELECT id, MasterLabel FROM Skill where MasterLabel IN: skillNames]; 
                for(Skill s : skList ){
                    skillIds.add(s.Id);
                } 
                skillId = String.join(skillIds , ';');
                
            }
            List<String> listZipCode = zipCode.split(';');
            if(recordId!=null){
                List<ServiceTerritory> stList = [SELECT Id, Name, XC_AccountId__c FROM ServiceTerritory where id =:recordId limit 1];
                List<XC_ZipCodeSkill_TerritoryAssociation__c> listZc = new List<XC_ZipCodeSkill_TerritoryAssociation__c>();
                for(String singleZipCode : listZipCode){
                    XC_ZipCodeSkill_TerritoryAssociation__c zc = new XC_ZipCodeSkill_TerritoryAssociation__c();
                    zc.XC_ServiceTerritoryId__c = recordId;
                    zc.XC_AccountId__c = stList[0].XC_AccountId__c;
                    zc.XC_ListOfSkillNames__c = skillList;
                    zc.XC_Province__c = province;
                    zc.XC_ListOfSkills__c = skillId;
                    zc.XC_ZipCode__c = singleZipCode;
                    zc.XC_ServiceTerritoryForDuplication__c = recordId;
                    listZc.add(zc);
                }
                List<XC_UTIL_Sobject.WrapperResult> listSobjectResult = XC_UTIL_Sobject.insertListRecords(listZc);
                rw.success = true;
                
                XC_LCC091_U_NewZipCodeSkillTerritory.checkResultSuccess(listSobjectResult, rw); 
            }
        }
        return rw;
    }


    
    /**
     * @description  method for setZipCodeValues
     * @param recordId the record id
     * @return the x C zip code skill territory association c
     */
    @AuraEnabled
    public static XC_ZipCodeSkill_TerritoryAssociation__c setZipCodeValues(String recordId){
         Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zcsMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>( [SELECT id, XC_Province__c, XC_ZipCode__c,XC_ListOfSkillNames__c, XC_ListOfSkills__c, XC_ServiceTerritoryId__c FROM XC_ZipCodeSkill_TerritoryAssociation__c
                                                             WHERE id=: recordId]);
        List<XC_ZipCodeSkill_TerritoryAssociation__c> zcs = zcsMap.values();                                           
        return zcs[0]; 
    
    }

    /**Sets the zip code values.
     * @description  method for getSkillForTerritory
     * @param recordId the record id
     * @return the skill
     */
    @AuraEnabled
    public static List<String> getSkillForTerritory(String recordId){ 
        List<String> listSkill = new List<String>();
        if(!Schema.sObjectType.ServiceTerritoryMember.isAccessible() && !Schema.sObjectType.ServiceResourceSkill.isAccessible() ){
                return listSkill;
        } else{
        Map<Id,ServiceTerritoryMember> listServTerrMermbMap = new Map<Id,ServiceTerritoryMember>( [SELECT Id, ServiceTerritoryId, ServiceResourceId,ServiceResource.XC_Account__c,ServiceTerritory.XC_AccountId__c
                                                          FROM ServiceTerritoryMember 
                                                          WHERE ServiceTerritoryId =: recordId AND ServiceResource.isCapacityBased = TRUE
                                                          ]);
        List<ServiceTerritoryMember> listServTerrMermb = listServTerrMermbMap.values();
            System.debug('@@@@@@ listServTerrMermb  ' + listServTerrMermb);
        List<Id> serviceResourceId = new List<Id> ();

        for(ServiceTerritoryMember servTerrMemb : listServTerrMermb){
            if(servTerrMemb.ServiceResource.XC_Account__c == servTerrMemb.ServiceTerritory.XC_AccountId__c){
                serviceResourceId.add(servTerrMemb.ServiceResourceId);
            }
        }
        Map<Id,ServiceResourceSkill> listServiceResourceSkillMap = new Map<Id,ServiceResourceSkill>( [SELECT Id, SkillId , XC_IsSkillActive__c, Skill.MasterLabel
                                                               FROM ServiceResourceSkill 
                                                               WHERE ServiceResourceId  IN : serviceResourceId AND XC_IsSkillActive__c = true]);  
        List<ServiceResourceSkill> listServiceResourceSkill =      listServiceResourceSkillMap.values();
            System.debug('@@@@@@ listServiceResourceSkill  ' + listServiceResourceSkill);
        for(ServiceResourceSkill servResourceSkill : listServiceResourceSkill){
            listSkill.add(servResourceSkill.Skill.MasterLabel);
        }
        } 
        return listSkill; 
    }


    /**
     * @param recordId the record id
     * @param province the record i
     * @param zipCode the record id
     * @description  method for getSkillForTerritoryFromRoot
     * @return the skill
     */
    @AuraEnabled
    public static List<String> getSkillForTerritoryFromRoot(String recordId , String province, String zipCode){ 
        List<String> listZipCodes = zipCode.split(';');
        List<String> listSkill = new List<String>(); 
        Map<Id,ServiceTerritory> serviceTerritoryChildMap = new Map<Id,ServiceTerritory>([SELECT Id, TopLevelTerritoryId FROM ServiceTerritory WHERE Id =: recordId] );
        ServiceTerritory serviceTerritoryChild =serviceTerritoryChildMap.values();
        Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>( [SELECT Id, XC_Province__c ,XC_ZipCode__c,XC_ListOfSkillNames__c 
                                                                            FROM XC_ZipCodeSkill_TerritoryAssociation__c
                                                                             WHERE XC_ServiceTerritoryId__c =: serviceTerritoryChild.TopLevelTerritoryId
                                                                             AND XC_Province__c = :province  AND XC_ZipCode__c IN: listZipCodes ] );
        List<XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritory = zipcodeterritoryMap.values();
        for(XC_ZipCodeSkill_TerritoryAssociation__c zipCodTerr : zipcodeterritory ){
            List<String> skills =  zipCodTerr.XC_ListOfSkillNames__c.split(';');
            for(String skill : skills){
                if(!listSkill.contains(skill)){
               	 listSkill.add(skill);
            	} 
            }
        } 
        return listSkill;
    }
    
}