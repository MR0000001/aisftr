/**
* @author Marco Rosa - marco.rosa@nttdata.com & Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com
* @date Creation 08/11/2018
* @date Modification dd/mm/yyyy
* @description XC_UTIL_Skill – Util class for Skillmethods
*/
public without sharing class XC_UTIL_Skill {   

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Wrapper Skill
    **/ 
    public class SkillWrapper{
        public String skillId;
        public Decimal skillLevel; 
    }

    /**
    * @author Andrea Bravaccino andrea.bravaccino@nttdata.com & Marco Rosa - marco.rosa@nttdata.com 
    * @description this method get all children's skill requirements with their greater skill levels and insert them on parent work order level
    * @param woParentList List<WorkOrder>
    * @return XC_UTIL_Sobject.WrapperResult result of operation
    */
    public static XC_UTIL_Sobject.WrapperResult insertSkillOnParentFromChildren(List<WorkOrder> woParentList){
        XC_UTIL_Sobject.WrapperResult wrapperResult = new XC_UTIL_Sobject.WrapperResult();
        wrapperResult.success = true;
        Map<Id, Map<Id, SkillRequirement>> mapSkillRequirements = XC_UTIL_Skill_U.getSkillFromChildren(woParentList);
        if(!mapSkillRequirements.isEmpty()){
            List<XC_UTIL_Sobject.WrapperResult> results = XC_UTIL_Skill_U.insertSkillFromChildren(mapSkillRequirements);
            if (!XC_UTIL_Sobject.checkDMLResults(results)) {
                wrapperResult.success = false;
                wrapperResult.errorMessage = results.get(0).errorMessage;
                return wrapperResult;
            }
        }
        return wrapperResult;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to retrieve a map of Product Category for List skills
     * @param listProdCat - List Product Category
     * @return mapProdCatListSkills - Method to retrieve a map of Product Category -> List skills
    **/
    public static Map<String, List<SkillWrapper>> getListSkillsByProductCategory(List<String> listProdCat) {
        Map<String, List<SkillWrapper>> mapProdCatListSkills = new Map<String, List<SkillWrapper>>();
        
        if(!Schema.sObjectType.XC_ProductSkillRequired__c.isAccessible()){
            return mapProdCatListSkills;
        }
        List<XC_ProductSkillRequired__c> listSkillReq = [SELECT Id, XC_Skill_Id__c, XC_Skill_Level__c,  XC_ProductCategoryOfInterest__r.Name 
                                                        FROM XC_ProductSkillRequired__c
                                                        WHERE XC_ProductCategoryOfInterest__r.Name IN:listProdCat];
        for(XC_ProductSkillRequired__c skReq : listSkillReq){
            if(!mapProdCatListSkills.containsKey(skReq.XC_ProductCategoryOfInterest__r.Name)){
                mapProdCatListSkills.put(skReq.XC_ProductCategoryOfInterest__r.Name, new List<SkillWrapper>());
            }
            SkillWrapper wr = new SkillWrapper();
            wr.skillId = skReq.XC_Skill_Id__c;
            wr.skillLevel = skReq.XC_Skill_Level__c;
            mapProdCatListSkills.get(skReq.XC_ProductCategoryOfInterest__r.Name).add(wr);
        } 
        
        return mapProdCatListSkills;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to retrieve a map of Product Category -> List skills
     * @param listTechSkill - List Cat Category
     * @param listWorkType - List WorkType
     * @param listCoverageTechSkill
     * @return mapKeyListSkills - Map<String, List<SkillWrapper>>
    **/   
    public static Map<String, List<SkillWrapper>> getListSkillsByWorkTypeCatalogCategory(List<String> listTechSkill, List<String> listWorkTypeCategory, List<String> listCoverageTechSkill){
        Map<String, List<SkillWrapper>> mapKeyListSkills = new Map<String, List<SkillWrapper>>();
        listCoverageTechSkill.add('');
        System.debug('@@@listCoverageTechSkill->'+ listCoverageTechSkill);
        if(!Schema.sObjectType.XC_ProductSkill_Association__c.isAccessible()){
            return mapKeyListSkills;
        }
        List<XC_ProductSkill_Association__c> listSkillReq = [SELECT Id, XC_SkillId__c, XC_SkillLevel__c, XC_WorkTypeCategory__c, XC_TechnicalSkill__c, XC_CoverageTechnicalSkill__c, XC_WorkTypeId__c
                                                        FROM XC_ProductSkill_Association__c
                                                        WHERE XC_WorkTypeCategory__c IN: listWorkTypeCategory
                                                        AND XC_TechnicalSkill__c IN: listTechSkill
                                                        AND XC_CoverageTechnicalSkill__c IN: listCoverageTechSkill];
        for(XC_ProductSkill_Association__c skReq : listSkillReq){
            String key = skReq.XC_WorkTypeId__c + '_' + skReq.XC_TechnicalSkill__c+ '_'+ skReq.XC_CoverageTechnicalSkill__c ;
            if(!mapKeyListSkills.containsKey(key)){
                mapKeyListSkills.put(key, new List<SkillWrapper>());
            }
            SkillWrapper wr = new SkillWrapper();
            wr.skillId = skReq.XC_SkillId__c;
            wr.skillLevel = skReq.XC_SkillLevel__c;
            mapKeyListSkills.get(key).add(wr);
        } 
        
        return mapKeyListSkills;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to retrieve a List of Skill Requirement for a Work Order
     * @param mapSkillRequirement - Map Skill Requirement
     * @param wo - WorkOrder
     * @return skillRequestedList - List Id Skill
    **/  
    public static List<Id> getSkillRequestedList(Map<Id, List<Id>> mapSkillRequirement, WorkOrder wo) {
        List<Id> skillRequestedList = new List<Id> ();
        if (mapSkillRequirement.containsKey(wo.id)) {
            skillRequestedList = mapSkillRequirement.get(wo.Id);
        }
        return skillRequestedList;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to retrieve a List of Skill Requirement for a Work Order
     * @param mapSkillRequirement - Map Skill Requirement
     * @param wo - WorkOrder
     * @return skillRequestedList - List Skill
    **/  
    public static List<SkillRequirement> getSkillRequestedList(Map<Id, List<SkillRequirement>> mapSkillRequirement, WorkOrder wo) {
        List<SkillRequirement> skillRequestedList = new List<SkillRequirement> ();
        if (mapSkillRequirement.containsKey(wo.id)) {
            skillRequestedList = mapSkillRequirement.get(wo.Id);
        }
        return skillRequestedList;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return Map<Id, List<Id>>
    **/ 
    public static Map<Id, List<Id>> getMapWorkOrderSkillIds(List<WorkOrder> listNew) {        
        Map<Id, List<SkillRequirement>> mapWorkOrderSkills = getMapWorkOrderSkills(listNew);
        return getMapWorkOrderSkillIds(mapWorkOrderSkills);
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param mapWorkOrderSkill - Map<Id, List<SkillRequirement>>
     * @return mapWorkOrderSkillIds - Map<Id, List<Id>>
    **/ 
    public static Map<Id, List<Id>> getMapWorkOrderSkillIds(Map<Id, List<SkillRequirement>> mapWorkOrderSkill) {        
        Map<Id, List<Id>> mapWorkOrderSkillIds = new Map<Id, List<Id>> ();
        for(Id woId : mapWorkOrderSkill.keySet()){
            List<String> skillRequestedList = XC_UTIL_Sobject.getListFieldValues(mapWorkOrderSkill.get(woId), 'SkillId');
            mapWorkOrderSkillIds.put(woId, skillRequestedList);
        } 
        return mapWorkOrderSkillIds;
    }

    /**
     * @author Marco Rosa - marco.rosa@nttdata.com 
     * @description Method to retrieve a Map of Work Order -> List skills requested
     * @param listNew - List WorkOrder
     * @return mapWorkOrderSkills - Map<Id, List<SkillRequirement>>
    **/ 
    public static Map<Id, List<SkillRequirement>> getMapWorkOrderSkills(List<WorkOrder> listNew){
        Map<Id, List<SkillRequirement>> mapWorkOrderSkills = new Map<Id, List<SkillRequirement>>();
        List<Id> workOrderIds = XC_UTIL_SObject.getIds(listNew);

        if(!Schema.sObjectType.WorkOrder.isAccessible()){
            return mapWorkOrderSkills;
        }
        Map<Id, WorkOrder> mapWoWithSkills = new Map<Id, WorkOrder>([
            SELECT Id, XC_WorkTypeCategory__c, 
                (SELECT Id, SkillId, SkillLevel 
                FROM SkillRequirements) 
            FROM WorkOrder
            WHERE Id IN: workOrderIds
        ]);
        List<WorkOrder> listWoWithSkills = mapWoWithSkills.values();
        for(WorkOrder wo : listWoWithSkills){
            if(!wo.SkillRequirements.isEmpty()){
                mapWorkOrderSkills.put(wo.Id, wo.SkillRequirements);
            }
        }
        return mapWorkOrderSkills;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
    * @author Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com
    * @date 05/02/2019
    * @description Method to check if a Service Territory has skills for a Work Order. Given the list of SkillRequirement and the list 
                    of ServiceResourceTerritory Skills return true if the ServiceTerritory is eligible.
    * @param skillRequested - List Skill
    * @param territorySkills - List TerritorySkill
    * @return eligibleforThisSkill - Boolean
    */
    public static Boolean checkSkillIds(List<String> skillRequested, List<String> territorySkills) {
        Boolean eligibleforThisSkill = true;
        for (String skillrequirement: skillRequested) {
            if (!territorySkills.contains(skillrequirement)) {
                return false;
            }
        }
        return eligibleforThisSkill;
    }

    /**
    * @author Marco Rosa - marco.rosa@nttdata.com, Roberta Cossiga - rcossiga@deloitte.it, 
    * @author Roberta Porrega - roberta.porrega@nttdata.com, Sara Miozza - sara.miozza@nttdata.com
    * @date 11/02/2019
    * @description Method to check if a Service Resource has skills for a Work Order. Given the list of SkillRequirement and the list 
                    of ServiceResource Skills return true if the service resource is eligible.
    * @param skillRequested - List SkillReq
    * @param skillServiceResource - List ServiceResourceSkill
    * @return Boolean
    */ 
    public static Boolean checkSkills(List<SkillRequirement> skillRequested, List<ServiceResourceSkill> skillServiceResource){
        for(SkillRequirement skillrequirement : skillRequested){
            Boolean eligibleforThisSkill = false;
            Id skillIdReq = skillrequirement.SkillId;
            Decimal skillLevelReq = skillrequirement.SkillLevel;
            for(ServiceResourceSkill resourceSkill : skillServiceResource){ 
                if(skillIdReq == resourceSkill.SkillId){ 
                    Boolean checkSkill = checkSkillLevel(resourceSkill, skillLevelReq);
                    if(checkSkill){
                        eligibleforThisSkill = true;
                        break;
                    } else {
                        return false;
                    } 
                }
            }
            if(!eligibleforThisSkill){
                return false;
            }
        }
        return true; 
    } 

    private static Boolean checkSkillLevel(ServiceResourceSkill resourceSkill, Decimal skillLevelReq){
        if(resourceSkill.EffectiveStartDate <= System.now() && (resourceSkill.EffectiveEndDate>=System.now() || resourceSkill.EffectiveEndDate == null) ){
            if(skillLevelReq <= resourceSkill.SkillLevel){
                return true;
            } else {
                return false;
            }
        } else {  
            return false;
        }
    }

    /**
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @date 11/02/2019
    * @description Method to get a map of skill where id is skill's name, and value is skill's id
    * @return mapSkill - Map<String,Id>
    */ 
    public static Map<String,Id> getMapSkills() {
        Map<String,Id> mapSkill = new Map<String,Id>();
        List<Skill> listSkill = [SELECT Id, MasterLabel FROM Skill LIMIT 50000];
        for(Skill skill : listSkill) {
            mapSkill.put(skill.MasterLabel, skill.Id);
        }
        return mapSkill;
    }
}