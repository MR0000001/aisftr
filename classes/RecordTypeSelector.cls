public with sharing class RecordTypeSelector {
    public static List<RecordType> getRecordTypeByObjectAndDeveloperName(String objectRT,List<String> devNames) {
        List<RecordType> recTypes = [SELECT Name, DeveloperName, Description, Id FROM RecordType WHERE SobjectType =: objectRT AND DeveloperName IN: devNames ORDER BY Name];
        return recTypes;

    }
}