/**
 * @Modify Salvatore Agrillo - 07/05/2019
 * @description XC_LCC092_EditZipCodeSkillTerritory - Controller for component XC_LCP092_EditZipCodeSkillTerritory
 */

 public without sharing class XC_LCC092_EditZipCodeSkillTerritory {

    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC092_EditZipCodeSkillTerritory');

    /**
    * @description Check root territory for profiles
    * @param recordId the record id
    * @return the boolean
    */
    @AuraEnabled
    public static Boolean checkRootTerritoryForProfilesInEdit(Id recordId){
        return XC_LCC091_U_NewZipCodeSkillTerritory.checkRootTerritoryForProfilesInEdit(recordId);
    }

    /**
     * @description Retrieve Territory From Zip Code Association
     * @param recordId the record id
     * @return ServiceTerritory
     */
    @AuraEnabled
    public static ServiceTerritory retrieveTerritoryFromZipAssociation (Id recordId){
        ServiceTerritory serviceTerritoryFromZipAssociation = new ServiceTerritory();
        if(!Schema.sObjectType.ServiceTerritory.isAccessible()){
            return serviceTerritoryFromZipAssociation;
        }else{
            XC_ZipCodeSkill_TerritoryAssociation__c zipCodeAssociation = setZipCodeValues(recordId);
            Map<Id,ServiceTerritory> serviceTerritoryFromZipAssociationMap = new Map<Id,ServiceTerritory>( [SELECT Id, XC_IsRoot__c, TopLevelTerritoryId FROM ServiceTerritory WHERE Id =: zipCodeAssociation.XC_ServiceTerritoryId__c]);                   
            serviceTerritoryFromZipAssociation = serviceTerritoryFromZipAssociationMap.values();
        }
        return serviceTerritoryFromZipAssociation;
    }

    /**
     * @description Check root territory for profiles
     * @param recordId the record id
     * @return the boolean
     */
    @AuraEnabled
    public static Boolean checkRootTerritoryInEdit(Id recordId){
        Boolean isRoot = false;
         if(!Schema.sObjectType.ServiceTerritory.isAccessible()){
            isRoot = false;
        } else{
            ServiceTerritory serviceTerritory = retrieveTerritoryFromZipAssociation(recordId);
            if(serviceTerritory.XC_IsRoot__c == true ){
                isRoot = true;
            }                    
        }
        return isRoot;
    }

    /**
     * @description Gets the country
     * @param recordId the record id
     * @return the country
     */
    @AuraEnabled
    public static String getCountry(String recordId){
        return XC_LCC091_U_NewZipCodeSkillTerritory.getCountry(recordId);       
    } 

    /**
     * @description Sets the zip code values
     * @param recordId the record id
     * @return the x C zip code skill territory association c
     */
    @AuraEnabled
    public static XC_ZipCodeSkill_TerritoryAssociation__c setZipCodeValues(String recordId){
         Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>( [SELECT id, XC_Province__c, XC_ZipCode__c,XC_ListOfSkillNames__c, XC_ListOfSkills__c, XC_ServiceTerritoryId__c FROM XC_ZipCodeSkill_TerritoryAssociation__c
                                                             WHERE id=: recordId]);
        List<XC_ZipCodeSkill_TerritoryAssociation__c> zcs =zipcodeterritoryMap.values();
        return zcs[0]; 
    }

    /**
     * @description Update skill territory
     * @param mapZipCodeSkillTerritoryString - String
     * @return the x C UTI L result wrapper
     */ 
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateSkillTerritory(String mapZipCodeSkillTerritoryString) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        // Modifica Salvatore Agrillo (07/05/2019)
        if(String.isBlank(mapZipCodeSkillTerritoryString)){
            rw.resultMessage = Label.XC_CL_SkillDocumentAssociation_ErrorLoadData;
            rw.success = false; 
            return rw;
        } 
        Map<String,Object> mapZipCodeSkillTerritory = (Map<String, Object>) JSON.deserializeUntyped(mapZipCodeSkillTerritoryString);
        String recordId = (String) mapZipCodeSkillTerritory.get('recordId');
        String zipCode = (String) mapZipCodeSkillTerritory.get('zipCode');
        String province = (String) mapZipCodeSkillTerritory.get('province');
        String skillList = (String) mapZipCodeSkillTerritory.get('skillList');

        List<String> skillIds = new List<String>();
        String skillId;
        String skillListCleaned;
        List<String> skillNamesCleaned = new List<String>();
        if(!String.isBlank(skillList) && Schema.sObjectType.Skill.isAccessible()){ 
            List<String> skillNames = skillList.split(';');
             Map<Id,Skill> skListMap = new Map<Id,Skill>( [SELECT id, MasterLabel FROM Skill WHERE MasterLabel IN: skillNames]); 
            List<Skill> skList = skListMap.values();
            for(Skill s : skList ){
                if(!skillIds.contains(s.Id)){
                skillIds.add(s.id);
                }
                if(!skillNamesCleaned.contains(s.MasterLabel)){
                skillNamesCleaned.add(s.MasterLabel);
                } 
            }
            skillId = String.join(skillIds , ';'); 
            skillListCleaned =  String.join(skillNamesCleaned , ';'); 
            System.debug('@@@skillId-->' +skillId);
            System.debug('@@@skillListCleaned-->' +skillListCleaned);
        }
        
        XC_LCC092_EditZipCodeSkillTerritory_U.ZipCodeSkillTerrWrapper populateWrapper = new XC_LCC092_EditZipCodeSkillTerritory_U.ZipCodeSkillTerrWrapper();
        populateWrapper.recordId = recordId;
        populateWrapper.skillList = skillListCleaned;
        populateWrapper.skillId = skillId;
        populateWrapper.zipCode = zipCode;
        populateWrapper.province = province;
        populateWrapper.rw = rw;
        return XC_LCC092_EditZipCodeSkillTerritory_U.populateResultWrapper(populateWrapper);
    }  

     /**
     * @description Sets the zip code values
     * @param recordId the record id
     * @return the skill
     */
    @AuraEnabled
    public static List<String> getSkillForTerritoryInEdit(String recordId){ 
        List<String> listSkill = new List<String>();
        if(!Schema.sObjectType.ServiceTerritoryMember.isAccessible() && !Schema.sObjectType.ServiceResourceSkill.isAccessible() ){
                return listSkill;
        } else{
            XC_ZipCodeSkill_TerritoryAssociation__c zipCodeAssociation = setZipCodeValues(recordId);
             Map<Id,ServiceTerritoryMember> listServTerrMermbMap = new Map<Id,ServiceTerritoryMember>( [SELECT Id, ServiceTerritoryId, ServiceResourceId,ServiceResource.XC_Account__c,ServiceTerritory.XC_AccountId__c
                                                              FROM ServiceTerritoryMember 
                                                              WHERE ServiceTerritoryId =: zipCodeAssociation.XC_ServiceTerritoryId__c AND ServiceResource.isCapacityBased = TRUE
                                                              ]);
            List<ServiceTerritoryMember> listServTerrMermb = listServTerrMermbMap.values();
            List<Id> serviceResourceId = new List<Id> ();

            for(ServiceTerritoryMember servTerrMemb : listServTerrMermb){
                if(servTerrMemb.ServiceResource.XC_Account__c == servTerrMemb.ServiceTerritory.XC_AccountId__c){
                    serviceResourceId.add(servTerrMemb.ServiceResourceId);
                }
            }
             Map<Id,ServiceResourceSkill> listServiceResourceSkillMap = new Map<Id,ServiceResourceSkill>([SELECT Id, SkillId  , Skill.MasterLabel, XC_IsSkillActive__c
                                                                   FROM ServiceResourceSkill 
                                                                   WHERE ServiceResourceId  IN : serviceResourceId
                                                                   AND XC_IsSkillActive__c = true]);      
            List<ServiceResourceSkill> listServiceResourceSkill =  listServiceResourceSkillMap.values();
            for(ServiceResourceSkill servResourceSkill : listServiceResourceSkill){
                listSkill.add(servResourceSkill.Skill.MasterLabel);
            }
        } 
        return listSkill; 
    }

    /**
     * @description Check root territory for profiles
     * @param recordId the record id
     * @return the boolean
     */
    @AuraEnabled
    public static List<String> getRootProvinceInEdit(Id recordId){
        List<String> province = new List<String>();
        if(!Schema.sObjectType.ServiceTerritory.isAccessible() && !Schema.sObjectType.XC_ZipCodeSkill_TerritoryAssociation__c.isAccessible() ){
            return province;
        }else{
	        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeAssociation = setZipCodeValues(recordId);	
             Map<Id,ServiceTerritory> serviceTerritoryMap = new Map<Id,ServiceTerritory>( [SELECT Id, TopLevelTerritoryId FROM ServiceTerritory WHERE Id =: zipCodeAssociation.XC_ServiceTerritoryId__c]);
	        ServiceTerritory serviceTerritoryChild = serviceTerritoryMap.values();
             Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>( [SELECT Id, XC_Province__c  FROM XC_ZipCodeSkill_TerritoryAssociation__c WHERE XC_ServiceTerritoryId__c =: serviceTerritoryChild.TopLevelTerritoryId]);
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
     * @description Check root territory for profiles
     * @param recordId the record id
     * @param province the record id
     * @return the boolean
     */
    @AuraEnabled
    public static List<String> getZipCodeFromRootInEdit(Id recordId, String province){
        List<String> zipCode = new List<String>(); 
         if(!Schema.sObjectType.ServiceTerritory.isAccessible() && !Schema.sObjectType.XC_ZipCodeSkill_TerritoryAssociation__c.isAccessible() ){
            return zipCode;
        }else{
        ServiceTerritory serviceTerritoryChild = retrieveTerritoryFromZipAssociation(recordId);
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
     * @description Sets the zip code values
     * @param recordId the record id
     * @param province the record i
     * @param zipCode the record id
      * @return the skill
     */
    @AuraEnabled
    public static List<String> getSkillForTerritoryFromRootInEdit(String recordId , String province, String zipCode){ 
        List<String> listZipCodes = zipCode.split(';');
        List<String> listSkill = new List<String>(); 
        XC_ZipCodeSkill_TerritoryAssociation__c zipCodeAssociation = setZipCodeValues(recordId);
         Map<Id,ServiceTerritory> serviceTerritoryMap = new Map<Id,ServiceTerritory>(  [SELECT Id, TopLevelTerritoryId FROM ServiceTerritory WHERE Id =: zipCodeAssociation.XC_ServiceTerritoryId__c]);
        ServiceTerritory serviceTerritoryChild = serviceTerritoryMap.values();
         Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritoryMap = new Map<Id,XC_ZipCodeSkill_TerritoryAssociation__c>( [SELECT Id, XC_Province__c ,XC_ZipCode__c,XC_ListOfSkillNames__c 
                                                                            FROM XC_ZipCodeSkill_TerritoryAssociation__c
                                                                             WHERE XC_ServiceTerritoryId__c =: serviceTerritoryChild.TopLevelTerritoryId
                                                                             AND XC_Province__c = :province  AND XC_ZipCode__c IN: listZipCodes ]);
         List<XC_ZipCodeSkill_TerritoryAssociation__c> zipcodeterritory = zipcodeterritoryMap.values();
        for(XC_ZipCodeSkill_TerritoryAssociation__c zipCodTerr : zipcodeterritory ){
            List<String> skills =  zipCodTerr.XC_ListOfSkillNames__c.split(';');
            listSkill.addAll(skills);
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'Anydatatype_msg' +listSkill );
        return listSkill;
    }

    /**
     * @description Sets the zip code values
     * @param oldSkill the record id
     * @param newSkill the record i
     * @return List<String> 
     */
    public static List<String> checkSkillChanged(String oldSkill, String newSkill ){
        List<String> skillChanged = new List<String>();
        List<String> skillNamesOld = oldSkill.split(';');
        List<String> skillNamesNew = newSkill.split(';');
        for(String skillName : skillNamesOld ){
            if(!skillNamesNew.contains(skillName)){
                skillChanged.add(skillName);
            }
        }
		return skillChanged;       
    }

}