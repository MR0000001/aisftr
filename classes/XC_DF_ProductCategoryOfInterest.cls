/**
* @author Marco Rosa - marco.rosa@nttdata.com
* @date Creation 29/04/2019
* @description XC_DF_Lead – Data Factory for Product Category of Interest
*/

@isTest
public class XC_DF_ProductCategoryOfInterest {

    /**
    * @description prodCatWithVisitRecord
    * @return XC_ProductCategoryOfInterest__c
    */
    public static XC_ProductCategoryOfInterest__c prodCatWithVisitRecord(){
        String prodName = XC_UTIL_Sobject.getPicklistValues('Lead','XC_ProductCategoryOfInterest__c')[0];
        XC_ProductCategoryOfInterest__c prToInsert = new XC_ProductCategoryOfInterest__c();
        prToInsert.Name = 'eMobility Recharge Manager'; //prodName;
        prToInsert.XC_CommercialVisit__c = false;
        return prToInsert;
    } 
 
    /**
    * @description prodCatWithoutVisitRecord
    * @return XC_ProductCategoryOfInterest__c    
    */
    public static XC_ProductCategoryOfInterest__c  prodCatWithoutVisitRecord(){
        String prodName = XC_UTIL_Sobject.getPicklistValues('Lead','XC_ProductCategoryOfInterest__c')[0];
        XC_ProductCategoryOfInterest__c prToInsert = new XC_ProductCategoryOfInterest__c();
        prToInsert.Name = 'eMobility Recharge Manager'; //prodName;
        prToInsert.XC_CommercialVisit__c = false;
        return prToInsert;
    }

    /**
    * @description prodCatWithoutVisitRecord
    * @param prod
    * @return XC_ProductCategoryOfInterest__c    
    */
    public static XC_ProductSkillRequired__c productSkillRequired(XC_ProductCategoryOfInterest__c prod){
        XC_ProductSkillRequired__c prodSkill = new XC_ProductSkillRequired__c();
        Skill skill = [SELECT Id, MasterLabel, DeveloperName FROM Skill LIMIT 1];
        prodSkill.XC_Skill_Id__c = skill.Id;
        prodSkill.XC_Skill_Level__c = 1;
        prodSkill.XC_ProductCategoryOfInterest__c = prod.Id;
        return prodSkill;
    }

    /**
    * @description prodCatWithoutVisitRecord
    * @param prod
    * @param woType
    * @return XC_ProductCategoryOfInterest__c    
    */
    public static XC_ProductSkill_Association__c productSkillAssociation (XC_ProductCategoryOfInterest__c prod, WorkType woType){
        XC_ProductSkill_Association__c prodSkill = new XC_ProductSkill_Association__c();
        insert XC_DF_CatalogItem.createCatalogItem();
        NE__Catalog_Category__c catCategory = [SELECT Id FROM NE__Catalog_Category__c];
        Skill skill = [SELECT Id, MasterLabel, DeveloperName FROM Skill LIMIT 1];
        prodSkill.XC_SkillId__c = skill.Id;
        prodSkill.XC_SkillLevel__c = 1; 
        prodSkill.XC_TechnicalSkill__c = 'Boiler';
        prodSkill.XC_CoverageTechnicalSkill__c= '';
        prodSkill.XC_WorkTypeCategory__c = woType.XC_WorkTypeCategory__c;
        prodSkill.XC_WorkTypeId__c = woType.Id;
        prodSkill.XC_SkillName__c = skill.MasterLabel;
        return prodSkill;
    }


}