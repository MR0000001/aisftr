public without sharing class RTFieldMtdSelector {
    public static List<RT_Field__mdt> getCaseTypesByRTDeveloperName(String rtDeveloperName){
        List<RT_Field__mdt> fields = new List<RT_Field__mdt>();
        fields = [SELECT Label,Required__c,ColumnNumber__c,Posizione__c FROM RT_Field__mdt WHERE Record_Type__c =: rtDeveloperName ORDER BY Posizione__c ASC];
        return fields;
    }
}