/**
 * @author Roberta Cossiga - rcossiga@deloitte.it
 * @date Creation 18/04/2019
 * @date Modification dd/mm/yyyy
 * @description XC_TR_WorkOrder_U_PopulateWorkType � Util class to populate WorkType on Work Order
 */
public without sharing class XC_TR_WorkOrder_U_PopulateWorkType {

    /**
    * @description checkAndPopulateWorkType
    * @author Andrea Bravaccino - andrea.bravaccino@nttdata.com | 29/8/2019
    * @param triggerNew List<WorkOrder> 
    */
    public static void checkAndPopulateWorkType(List<WorkOrder> triggerNew){ 
        List<WorkOrder> populateByIdList = new List<WorkOrder>();
        List<WorkOrder> populateByLabelList = new List<WorkOrder>();
        List<WorkOrder> populateByCategoryProduct = new List<WorkOrder>();

        Set<Id> workTypeIdSet = new Set<Id>();
        Set<String> workTypeLabelSet = new Set<String>();
        Set<String> workTypeCategorySet = new Set<String>();
        Set<String> workTypeLegalEntitySet = new Set<String>();

        for (WorkOrder wo : triggerNew) {
            if(wo.WorkTypeId != null){
                populateByIdList.add(wo);
                workTypeIdSet.add(wo.WorkTypeId);
            }else if(!String.isBlank(wo.XC_WorkTypeLabel__c)){
                populateByLabelList.add(wo);
                workTypeLabelSet.add(wo.XC_WorkTypeLabel__c);
            }else if(!String.isBlank(wo.XC_WorkTypeCategory__c) /*&& !String.isBlank(wo.XC_ProductSubType__c)*/ ){
                populateByCategoryProduct.add(wo);
                workTypeCategorySet.add(wo.XC_WorkTypeCategory__c);
            }
            workTypeLegalEntitySet.add(wo.XC_LegalEntity__c);
        }

        Map<Id, WorkType> workTypeMapId = new Map<Id, WorkType>([SELECT Id, Name, XC_WorkTypeCategory__c, XC_Product_Subtype__c, XC_LegalEntity__c, EstimatedDuration, DurationType, XC_CoverageSkill__c, XC_CoverageParentSkill__c
                                                                  FROM WorkType 
                                                                  WHERE (Id IN :workTypeIdSet 
                                                                  OR Name IN :workTypeLabelSet
                                                                  OR XC_WorkTypeCategory__c IN :workTypeCategorySet)
                                                                  AND XC_LegalEntity__c IN: workTypeLegalEntitySet]);
        
        Map<String, WorkType> workTypeMapLabel = getWorkTypeMapLabel(workTypeMapId.values());
        Map<String, Worktype> workTypeMapCategory = getWorkTypeMapCategory(workTypeMapId.values());

        populateById(populateByIdList, workTypeMapId);
        populateByLabel(populateByLabelList, workTypeMapLabel);
        populateByCategory(populateByCategoryProduct, workTypeMapCategory);

    }

    private static Map<String, WorkType> getWorkTypeMapLabel(List<WorkType> wtList){
        Map<String, WorkType> workTypeMapLabel = new Map<String, WorkType>();
        for (WorkType wt : wtList) {
             String key = wt.Name + '_' + wt.XC_LegalEntity__c;
            workTypeMapLabel.put(key.toLowerCase(), wt);
        }
        return workTypeMapLabel;
    }
    
    private static Map<String, Worktype> getWorkTypeMapCategory(List<WorkType> wtList){
        Map<String, WorkType> workTypeMapCategory = new Map<String, WorkType>();
        for (WorkType wt : wtList) {
            List<String> listKeys = new List<String>();
            
            String key = wt.XC_WorkTypeCategory__c + '_' + wt.XC_LegalEntity__c;
            if(wt.XC_Product_Subtype__c != null){
                for (String subType : wt.XC_Product_Subtype__c.split(';')) { 
                    String tmpKey = key + subType;
                    if(wt.XC_CoverageSkill__c != null){
                        tmpKey += wt.XC_CoverageSkill__c;
                    } 
                    if(wt.XC_CoverageParentSkill__c != null){
                        tmpKey += wt.XC_CoverageParentSkill__c;
                    }
                    listKeys.add(tmpKey);
                }
            }else {
                listKeys.add(key);
            }

            for(String keyJ : listKeys){
                workTypeMapCategory.put(keyJ.toLowerCase(), wt);
            }
            
        }
        System.debug('@@@ workTypeMapCategory: ' + workTypeMapCategory);
        return workTypeMapCategory;
    }

    private static void populateByLabel(List<WorkOrder> populateByLabelList, Map<String, WorkType> workTypeMapLabel){
        for (WorkOrder wo : populateByLabelList) {
            String key = wo.XC_WorkTypeLabel__c + '_' + wo.XC_LegalEntity__c;
            WorkType wt = workTypeMapLabel.get(key.toLowerCase());
            populateWorkOrder(wo, wt);
        }
    }

    private static void populateById (List<WorkOrder> listWorkOrder, Map<Id,WorkType> mapWorkType){
        for (WorkOrder wo : listWorkOrder)
        {
            WorkType wt = mapWorkType.get(wo.WorkTypeId); 
            populateWorkOrder(wo,wt);
        }
    }

    private static void populateByCategory(List<WorkOrder> populateByCategoryProduct, Map<String, WorkType> workTypeMapCategory){
        for (WorkOrder wo : populateByCategoryProduct){
            String key = wo.XC_WorkTypeCategory__c + '_' + wo.XC_LegalEntity__c;
            if(wo.XC_ProductSubType__c != null && !String.isBlank(wo.XC_ProductSubType__c) ){
                key += wo.XC_ProductSubType__c;
            } 
            if(wo.XC_CoverageSkill__c != null && !String.isBlank(wo.XC_CoverageSkill__c) ){
                key += wo.XC_CoverageSkill__c;
            }
            if(wo.XC_CoverageParentSkill__c != null && !String.isBlank(wo.XC_CoverageParentSkill__c) ){
                key += wo.XC_CoverageParentSkill__c;
            }

            System.debug('@@@populateByCategory key: ' + key);
            WorkType wt = workTypeMapCategory.get(key.toLowerCase());
            if(wt == null) {
                String lowerCaseKey = (wo.XC_WorkTypeCategory__c + '_' + wo.XC_LegalEntity__c + wo.XC_ProductSubType__c).toLowerCase();
                wt = workTypeMapCategory.get(lowerCaseKey);
            }
            if(wt == null) {
                String lowerCaseKey = (wo.XC_WorkTypeCategory__c + '_' + wo.XC_LegalEntity__c).toLowerCase();
                wt = workTypeMapCategory.get(lowerCaseKey);
            }
            populateWorkOrder(wo,wt);
        }
    }
    
    private static void populateWorkOrder(WorkOrder wo, WorkType wt){
        if (wt != null){
            wo.XC_WorkTypeLabel__c = wt.name;
            wo.XC_WorkTypeCategory__c = wt.XC_WorkTypeCategory__c;
            wo.WorkTypeId = wt.id;
            wo.DurationType = wt.DurationType;
            wo.Duration = wt.EstimatedDuration;
        }
    }
}