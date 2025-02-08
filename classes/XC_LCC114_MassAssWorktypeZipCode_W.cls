/**
* @author Salvatore Agrillo - salvatore.agrillo@nttdata.com
* @date Creation 13/09/2019
* @description XC_LCC114_MassAssWorktypeZipCode_W – Util class for Wrapper for XC_LCC114_MassWorktypeZipcode 
*/

public without sharing class XC_LCC114_MassAssWorktypeZipCode_W {

    /** @description ResultByPartnerWrapper */ 
    public class ResultByPartnerWrapper {
        @AuraEnabled
        public List<WorkType> listWorkType = new List<WorkType>();
        @AuraEnabled
        public List<XC_PartnerCoverage__c> listZipCodeWorkType = new List<XC_PartnerCoverage__c>();
        @AuraEnabled
        public String country = '';
    }

    /** @description OutputWrapper */
    public class OutputWrapper { 
        @AuraEnabled
        public Boolean success = false;
        @AuraEnabled
        public String resultMessage = '';
    }

}