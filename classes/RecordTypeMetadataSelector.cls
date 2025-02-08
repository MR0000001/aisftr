public with sharing class RecordTypeMetadataSelector {
    public static List<Record_Type__mdt> getCaseRecordTypes(){
        List<Record_Type__mdt> recordTypes = new List<Record_Type__mdt>();
        recordTypes = [SELECT DeveloperName  FROM Record_Type__mdt];
        system.debug('@@@ recordTypes '+recordTypes);
        return recordTypes;
    }
}