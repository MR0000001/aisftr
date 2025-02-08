/**
 * @File Name        XC_UTIL_Skill_U.cls
 * @description      XC_UTIL_Skill_U - Util class for Skillmethods
 * @Author           Andrea Bravaccino
 * @Last Modified By Andrea Bravaccino
 * @Last Modified On 25/7/2019, 17:27:09
 * @Modification Log 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    25/7/2019, 17:15:00      Andrea Bravaccino             Initial Version
**/
public without sharing class XC_UTIL_Skill_U {
    /**
    * @description this method get all children's skill requirements with their major skill levels
    * @author Andrea Bravaccino | 25/7/2019
    * @param woParentList List<WorkOrder>
    * @return Map<Id, Map<Id, SkillRequirement>> key woRoot - value SkillId, skill level maggiore
    */
    public static Map<Id, Map<Id, SkillRequirement>> getSkillFromChildren(List<WorkOrder> woParentList){
        List<Id> parentIds = XC_UTIL_Sobject.getIds(woParentList);
        List<WorkOrder> woList = new List<WorkOrder>([SELECT Id, ParentWorkOrderId, (SELECT Id, RelatedRecordId, SkillId, Skill.MasterLabel, SkillLevel FROM SkillRequirements) FROM WorkOrder WHERE ParentWorkOrderId IN :parentIds OR Id IN :parentIds]);
        Map<Id, Map<Id, SkillRequirement>> woParentSkillChildren = new Map<Id, Map<Id, SkillRequirement>>();
        for (WorkOrder wo : woList) {
            Boolean isParent = parentIds.contains(wo.Id);
            Id keyId = isParent ? wo.Id : wo.ParentWorkOrderId;
            Map<Id, SkillRequirement> skillMap = woParentSkillChildren.get(keyId);
            if (skillMap == null){
                skillMap = new Map<Id, SkillRequirement>();
            }
            for (SkillRequirement sr : wo.SkillRequirements) {
                SkillRequirement skill = skillMap.get(sr.SkillId);
                if(skill == null){
                    skill = new SkillRequirement();
                }
                if (isParent){
                    skill.RelatedRecordId = sr.RelatedRecordId;
                    skill.Id = sr.Id;
                }
                skill.SkillLevel = skill.SkillLevel == null || skill.SkillLevel < sr.SkillLevel ? sr.SkillLevel : skill.SkillLevel;                   
                skillMap.put(sr.SkillId, skill);
            }
            woParentSkillChildren.put(keyId, skillMap);
        }
        return woParentSkillChildren;
    }

    /**
    * @description create skill requirements to link to WorkOrder root
    * @author Andrea Bravaccino | 25/7/2019
    * @param woParentSkillChildren Map<Id, Map<Id, SkillRequirement>>
    * @return List<XC_UTIL_Sobject.WrapperResult> result of operation
    */
    public static List<XC_UTIL_Sobject.WrapperResult> insertSkillFromChildren(Map<Id, Map<Id, SkillRequirement>> woParentSkillChildren){
        List<SkillRequirement> srListToInsert = new List<SkillRequirement>();
        for (Id parentId : woParentSkillChildren.keySet()) {
            Map<Id, SkillRequirement> skillIdLevel = woParentSkillChildren.get(parentId);
            for (Id skillId : skillIdLevel.keySet()) {
                SkillRequirement sr = skillIdLevel.get(skillId);
                if (sr.RelatedRecordId == null){
                    sr.RelatedRecordId = parentId;
                }
                
                sr.SkillId = skillId;
                srListToInsert.add(sr);
            }
        }

        return XC_UTIL_Sobject.upsertListRecords(srListToInsert);
    }
}