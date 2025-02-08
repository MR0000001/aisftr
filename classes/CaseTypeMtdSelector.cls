public without sharing class CaseTypeMtdSelector {
    public static List<Case_Type__mdt> getCaseTypesByRTDeveloperName(String rtDeveloperName){
        List<Case_Type__mdt> caseTypes = new List<Case_Type__mdt>();
        caseTypes = [SELECT Label FROM Case_Type__mdt WHERE Record_Type__r.DeveloperName =: rtDeveloperName ORDER BY Label];
        return caseTypes;
    }
}