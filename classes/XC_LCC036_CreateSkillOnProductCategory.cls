/**
 * @author: Marco Rosa - marco.rosa@nttdata.com, Salvatore Scarpato - salvatore.scarpato@nttdata.com
 * @date  : 09/11/2018
 * @description XC_LCC036_CreateSkillOnProductCategory - Controller for XC_LCP036_CreateSkillOnProductCategory
**/

public with sharing class XC_LCC036_CreateSkillOnProductCategory {

    public final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC036_CreateSkillOnProductCategory');

    /** @description The Class Row */
    public class Row {
        /** @description name */
        @AuraEnabled
        public String name {get; set;}
        /** @description level */
        @AuraEnabled        
        public Integer level {get; set;}
        /** @description id */
        @AuraEnabled        
        public String id {get; set;}
        /** @description parentId */
        @AuraEnabled        
        public String parentId {get; set;} 
    }
                
    /**
    * @description Gets the table data
    * @param recordId the record id
    * @return the table data
    */
    @AuraEnabled
    public static List<Row> getTableData(Id recordId){ 
        List<Row> listForTable = new List<Row>();   
        Map<Id, XC_ProductSkillRequired__c> mapData = new Map<Id, XC_ProductSkillRequired__c>([
            SELECT Id, Name, XC_Skill_Name__c, XC_Skill_Id__c, XC_ProductCategoryOfInterest__c, XC_Skill_Level__c
            FROM XC_ProductSkillRequired__c
            WHERE XC_ProductCategoryOfInterest__c =: recordId
        ]); 
        for(sObject s : mapData.values()){ 
            listForTable.add(
                createRow(s)
            );
        }
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'listForTable->' + listForTable);
        return listForTable;
    }
    
    /**
    * @description Delete record
    * @param recordToDeleteId the record to delete id
    */
    @AuraEnabled
    public static void deleteRecord(Id recordToDeleteId){ 
        XC_UTIL_Debug.debug(DEBUGACTIVE, 'deleteRecord->' + recordToDeleteId); 
        XC_ProductSkillRequired__c recordToDelete = new XC_ProductSkillRequired__c();
        recordToDelete.Id = recordToDeleteId;
        XC_UTIL_Sobject.deleteRecord(recordToDelete);
    }
    
    /**
    * @description Creates the row
    * @param s the s
    * @return the row
    */
    @TestVisible 
    private static Row createRow(sObject s){
        Row r = new Row();
        r.Name = (String) s.get('XC_Skill_Name__c');
        r.Level = Integer.valueOf(s.get('XC_Skill_Level__c')); 
        r.Id = (String) s.get('Id');
        r.ParentId = (String) s.get('XC_Skill_Id__c');
        return r;
    }

    /**
    * @description - Save result
    * @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
    * @param mapSkillString - String
    * @return Boolean
    */
    @AuraEnabled 
    public static Boolean saveResults(String mapSkillString) {
        Map<String, Object> mapSkill = (Map<String, Object>) JSON.deserializeUntyped(mapSkillString);
        XC_ProductSkillRequired__c productSkillReq = new XC_ProductSkillRequired__c(
            XC_ProductCategoryOfInterest__c = (String) mapSkill.get('productCategoryOfInterest'),
            XC_Skill_Level__c = Integer.valueOf(mapSkill.get('skillLevel')),
            XC_Skill_Name__c = (String) mapSkill.get('skillName'),
            XC_Skill_Id__c = (String) mapSkill.get('skillId')
        );
        XC_UTIL_Debug.debug(DEBUGACTIVE, '@@@ productSkillReq ---> ' + productSkillReq);
        XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.insertRecord(productSkillReq);
        return result.success;
    }
     
}