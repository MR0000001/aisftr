/**
* @author  Roberta Cossiga r.cossiga@deloitte.it && Roberta Porrega roberta.porrega@nttdata.com
* @date Creation 22/02/2019
* @date Modification 07/05/2019 - Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @description XC_LCC086_NewProductSkillAssociation - Component for create a new Product Skill Association
*/

public without sharing class XC_LCC086_NewProductSkillAssociation {

    private final static Boolean DEBUGACTIVE = true;//XC_UTIL_Debug.isActive('XC_LCC086_NewProductSkillAssociation');
	
    /**
     * @description Save product skill association  
     * @param mapSkillAssString - String  
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper saveProductSkillAssociation(String mapSkillAssString){
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        // Modifica Salvatore Agrillo (06/05/2019)
        if(String.isBlank(mapSkillAssString)){
            rw.resultMessage = Label.XC_CL_SkillDocumentAssociation_ErrorLoadData;
            rw.success = false; 
            return rw;
        } 
        Map<String,Object> mapSkillAss = (Map<String, Object>) JSON.deserializeUntyped(mapSkillAssString);
        String techSKill = (String) mapSkillAss.get('selectedTechSkill');
        String covTechSKill = (String) mapSkillAss.get('selectedCovTechSkill');
        String workTypeLabel = (String) mapSkillAss.get('workTypeLabel');
        String skillId = (String) mapSkillAss.get('skillId');
        String skillName = (String) mapSkillAss.get('skillName');

        List<WorkType> listOfWorkType = new List<WorkType>([SELECT Id, XC_WorkTypeCategory__c FROM Worktype WHERE Name =: workTypeLabel]);
        if(listOfWorkType.isEmpty()){
            rw.resultMessage = Label.XC_CL_SkillDocumentAssociation_MustFillWorkType;
            rw.success = false; 
            return rw;
        }
        XC_ProductSkill_Association__c productSkillAssociation = new XC_ProductSkill_Association__c();
        	productSkillAssociation.XC_SkillId__c = skillId;
            productSkillAssociation.XC_WorkTypeCategory__c = listOfWorkType[0].XC_WorkTypeCategory__c;
            productSkillAssociation.XC_WorkTypeId__c = listOfWorkType[0].Id;
            productSkillAssociation.XC_TechnicalSkill__c = techSKill;
            productSkillAssociation.XC_CoverageTechnicalSkill__c = covTechSKill;
       		productSkillAssociation.XC_SkillName__c = skillName;
        XC_UTIL_Sobject.WrapperResult sobjectResult =  XC_UTIL_Sobject.insertRecord(productSkillAssociation);
        if(sobjectResult.success == true){ 
            rw.success = true;
            rw.resultMessage = 'Success';
            rw.recordId = sobjectResult.recordId;
        }else{  
            rw.resultMessage = sobjectResult.errorMessage;   
            rw.success = false;  
        }
        return rw;
    }

    /**
     * @description Sets the fields values
     * @param recordId the record id
     * @return the x C product skill association c
     */
    @AuraEnabled
    public static XC_ProductSkill_Association__c setFieldsValues (Id recordId){
        Map<Id,XC_ProductSkill_Association__c> psaMap = new Map<Id,XC_ProductSkill_Association__c>([
            SELECT Id, XC_SkillId__c, XC_WorkTypeCategory__c, XC_TechnicalSkill__c, XC_CoverageTechnicalSkill__c, XC_WorkTypeName__c 
            FROM XC_ProductSkill_Association__c
            WHERE Id=: recordId]);
        List<XC_ProductSkill_Association__c> psa = psaMap.values();
        return psa[0]; 
    }
    
    /**
     * @description Update product skill association     
     * @param mapSkillAssString
     * @return XC_UTIL_ResultWrapper
     */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updateProductSkillAssociation(String mapSkillAssString) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        // Modifica Salvatore Agrillo (06/05/2019)
        if(String.isBlank(mapSkillAssString)){
            rw.resultMessage = Label.XC_CL_SkillDocumentAssociation_ErrorLoadData;
            rw.success = false; 
            return rw;
        } 
        Map<String,Object> mapSkillAss = (Map<String, Object>) JSON.deserializeUntyped(mapSkillAssString);
        String selectedTechSkill = (String) mapSkillAss.get('selectedTechSkill');
        String covTechSKill = (String) mapSkillAss.get('selectedCovTechSkill');
        String workTypeLabel = (String) mapSkillAss.get('workTypeLabel');
        String skillId = (String) mapSkillAss.get('skillId');
        String skillName = (String) mapSkillAss.get('skillName');
        String recordId = (String) mapSkillAss.get('recordId');

        XC_UTIL_Debug.debug(DEBUGACTIVE, 'workTypeLabel->' + workTypeLabel);
        List<WorkType> listOfWorkType = new List<WorkType>([
            SELECT Id, XC_WorkTypeCategory__c FROM Worktype WHERE Name =: workTypeLabel]);
        if(listOfWorkType.isEmpty()){
            rw.resultMessage = Label.XC_CL_SkillDocumentAssociation_MustFillWorkType;
            rw.success = false; 
            return rw;
        }
        XC_ProductSkill_Association__c productSkillAssociation = new XC_ProductSkill_Association__c();
        	productSkillAssociation.Id = recordId;
        	productSkillAssociation.XC_SkillId__c = skillId;
            productSkillAssociation.XC_WorkTypeCategory__c = listOfWorkType[0].XC_WorkTypeCategory__c;
            productSkillAssociation.XC_WorkTypeId__c = listOfWorkType[0].Id;
            productSkillAssociation.XC_TechnicalSkill__c = selectedTechSkill;
            productSkillAssociation.XC_CoverageTechnicalSkill__c = covTechSKill;
       		productSkillAssociation.XC_SkillName__c = skillName;
        XC_UTIL_Sobject.WrapperResult sobjectResult =  XC_UTIL_Sobject.updateRecord(productSkillAssociation);
        if(sobjectResult.success == true){
            rw.success = true;
            rw.resultMessage = 'Success';
            rw.recordId = sobjectResult.recordId;
        }else{
            rw.resultMessage = sobjectResult.errorMessage;
            rw.success = false;  
        }
        return rw;
    }

    /**
     * @description getPicklistTechnicalValues
     * @return List<String>
     */
 
    @AuraEnabled
    public static List<String> getPicklistTechnicalValues(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = XC_ProductSkill_Association__c.XC_TechnicalSkill__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

        /**
     * @description getPicklistCoverageTechSkill
     * @return List<String>
     */
 
    @AuraEnabled
    public static List<String> getPicklistCoverageTechSkill(){
       List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = XC_ProductSkill_Association__c.XC_CoverageTechnicalSkill__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

            /**
     * @description getPicklistCoverageTechSkill
     * @return List<String>
     */
 
    @AuraEnabled
    public static List<PicklistOption> getPicklistWorkTypeLabel(){
       List<PicklistOption> pickListValuesList= new List<PicklistOption>();
		Schema.DescribeFieldResult fieldResult = WorkOrder.XC_WorkTypeLabel__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            PicklistOption option = new PicklistOption();
            option.label = pickListVal.getLabel();
            option.value = pickListVal.getValue();
			pickListValuesList.add(option);
		}     
		return pickListValuesList;
    }
      
    public class PicklistOption{
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }
      

}