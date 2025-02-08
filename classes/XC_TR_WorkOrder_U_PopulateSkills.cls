/**
* @author Marco Rosa - marco.rosa@nttdata.com 
* @date Creation 08/11/2018
* @date Modification dd/mm/yyyy
* @description XC_TR_WorkOrder_U_PopulateSkills – Util class to populate skills on Work Order
*/

public without sharing class XC_TR_WorkOrder_U_PopulateSkills {

    /** The Constant DEBUGACTIVE. */
    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_TR_WorkOrder_U_PopulateSkills');
    
    /**
     * Populate skills on update.
     *
     * @author Marco Rosa - marco.rosa@nttdata.com
     * @param listNew the list new
     * @param mapOld the map old
     * @param mapNew the map new
     * @description Method to populate skills on Work Order
     */ 
    public static void populateSkillsOnUpdate(List<WorkOrder> listNew, Map<Id,WorkOrder> mapOld, Map<Id,WorkOrder> mapNew){ 
        List<String> fieldList = new List<String>{'XC_ProductCategoryOfInterest__c','XC_CatalogCategory__c','WorkTypeId'}; 
        List<WorkOrder> listChanged = XC_UTIL_Sobject.getListChanged(fieldList, mapOld, mapNew); 
        if(!listChanged.isEmpty()){
            populateSkills(listChanged);
        } 
    }

    /**
     * Populate skills.
     * @description Populate skill from list WorkOrder 
     * @param listNew - List WorkOrder
     */
    public static void populateSkills(List<WorkOrder> listNew){ 
        List<WorkOrder> listWorkOrderToManage = new List<WorkOrder>();
        for(WorkOrder wo : listNew) {
            if( ((wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_Repair || wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_DeliveryInstallation) && wo.XC_HierarchyLevel__c > 1)
                || !wo.XC_isTree__c) {
                listWorkOrderToManage.add(wo);
            }
        }

        List<WorkOrder> listWOCommercialVisit = new List<WorkOrder>();  
        List<WorkOrder> listWONotCommercialVisit = new List<WorkOrder>();
        List<SkillRequirement> listToInsert = new List<SkillRequirement>();
        for(WorkOrder wo : listWorkOrderToManage){
            if(wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit){
                listWOCommercialVisit.add(wo);
            } else{
                listWONotCommercialVisit.add(wo);
            }
        }

        insertSkillRequirementWOCommercialVisit(listWOCommercialVisit, listToInsert);
        insertSkillRequirementWONotCommercialVisit(listWONotCommercialVisit, listToInsert);        
        XC_UTIL_Debug.debug(DEBUGACTIVE,'listToInsert Skills->' + listToInsert);
        XC_UTIL_Sobject.insertListRecords(listToInsert);
    } 

    /**
     * Populate skills.
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Insert SkillRequirement for WorkOrder CommercialVisit
     * @param listWOCommercialVisit - List WorkOrder
     * @param listToInsert - List<SkillRequirement>
     */
    private static void insertSkillRequirementWOCommercialVisit(List<WorkOrder> listWOCommercialVisit, List<SkillRequirement> listToInsert) { 
        if(!listWOCommercialVisit.isEmpty()){
            List<String> listProdCat = XC_UTIL_Sobject.getListFieldValues(listWOCommercialVisit, 'XC_ProductCategoryOfInterest__c');
            Map<String, List<XC_UTIL_Skill.SkillWrapper>> mapProdCatListSkills = XC_UTIL_Skill.getListSkillsByProductCategory(listProdCat);
            for(WorkOrder wo : listWOCommercialVisit){ 
                if(mapProdCatListSkills.containsKey(wo.XC_ProductCategoryOfInterest__c)){
                    List<XC_UTIL_Skill.SkillWrapper> listSkillsWr = mapProdCatListSkills.get(wo.XC_ProductCategoryOfInterest__c);
                    for(XC_UTIL_Skill.SkillWrapper skillWr : listSkillsWr){
                        if(String.isNotBlank(skillWr.skillId)) {
                            SkillRequirement skReq = new SkillRequirement();
                            skReq.SkillId = skillWr.skillId;
                            skReq.RelatedRecordId = wo.Id; 
                            skReq.SkillLevel = skillWr.skillLevel;
                            listToInsert.add(skReq); 
                        }
                    }
                    
                }
            }
        }
    }

    /**
     * Populate skills.
     * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
     * @description Insert SkillRequirement for WorkOrder NotCommercialVisit
     * @param listWONotCommercialVisit - List WorkOrder
     * @param listToInsert - List<SkillRequirement>
     */
    private static void insertSkillRequirementWONotCommercialVisit(List<WorkOrder> listWONotCommercialVisit, List<SkillRequirement> listToInsert) {
        if(listWONotCommercialVisit.isEmpty()){
            return;
        }  
        List<String> listTechSkill = XC_UTIL_Sobject.getListFieldValues(listWONotCommercialVisit, 'XC_TechnicalSkill__c');
        List<String> listWorkTypeCategory = XC_UTIL_Sobject.getListFieldValues(listWONotCommercialVisit, 'XC_WorkTypeCategory__c');
        List<String> listCoverageTechSkill = XC_UTIL_Sobject.getListFieldValues(listWONotCommercialVisit, 'XC_CoverageTechnicalSkill__c');
        System.debug('@@@listCoverageTechSkill->'+ listCoverageTechSkill);
        Map<String, List<XC_UTIL_Skill.SkillWrapper>> mapProdCatListSkills = XC_UTIL_Skill.getListSkillsByWorkTypeCatalogCategory(listTechSkill, listWorkTypeCategory, listCoverageTechSkill);
        for(WorkOrder wo : listWONotCommercialVisit){ 
            String key = wo.WorkTypeId +'_' + wo.XC_TechnicalSkill__c+'_'+ wo.XC_CoverageTechnicalSkill__c; 
            System.debug('@@@keywo1->'+ key);
            if (!mapProdCatListSkills.containsKey(key) && !String.isBlank(wo.XC_CoverageTechnicalSkill__c)){
                key = wo.WorkTypeId +'_' + wo.XC_TechnicalSkill__c+'_'+null;
                System.debug('@@@keywo2->'+ key); 
            }
            if(mapProdCatListSkills.containsKey(key)){
                List<XC_UTIL_Skill.SkillWrapper> listSkillsWr = mapProdCatListSkills.get(key);
                if(listSkillsWr.isEmpty()){
                    continue;
                } 
                for(XC_UTIL_Skill.SkillWrapper skillWr : listSkillsWr){
                    if(String.isNotBlank(skillWr.skillId)) {
                        SkillRequirement skReq = new SkillRequirement();
                        skReq.SkillId = skillWr.skillId;
                        skReq.RelatedRecordId = wo.Id; 
                        skReq.SkillLevel = skillWr.skillLevel;
                        listToInsert.add(skReq);  
                    }
                }
            }
        }
    }
}