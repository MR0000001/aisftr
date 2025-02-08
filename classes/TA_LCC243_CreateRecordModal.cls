public without sharing class TA_LCC243_CreateRecordModal{
    public TA_LCC243_CreateRecordModal() {}

    public final static String OBJ_NAME_TECHNICAL_SHEET = 'XC_TechnicalSheet__c';
    public final static String OBJ_NAME_WORKORDERLINEITEM = 'WorkOrderLineItem';

    public class PredefinedValue {
        @AuraEnabled
        public String   apiName   {get; set;}
        @AuraEnabled
        public String   queryField   {get; set;}
        @AuraEnabled
        public String   value   {get; set;}
    }

    public class RecordWrapper {
        @AuraEnabled
        public String   id   {get; set;}
        @AuraEnabled
        public String   recordTypeName   {get; set;}

        public RecordWrapper(String id, String recordTypeName) {
            this.id = id;
            this.recordTypeName = recordTypeName;
        }
    }

    @AuraEnabled
    public static String getRecordTypesByObjectName(String objectName, String workOrderId,Boolean checkLegalEntityRT){
        if(String.isNotBlank(objectName)){
            final String B2B = 'B2B';
            final String B2C = 'B2C';
            final String B2G = 'B2G';
            List<String> legalEntityList = new List<String>();
            Schema.DescribeFieldResult fieldResult = WorkOrder.XC_LegalEntity__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                legalEntityList.add(pickListVal.getValue());
            }

            List<WorkOrder> woList = [SELECT ID, XC_LegalEntity__c, XC_Segment__c
            FROM WorkOrder
            WHERE ID =: workOrderId];

            Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
            Schema.SObjectType objSObjectType = mapGlobalDescribe.get(objectName);
            system.debug(objSObjectType.getDescribe().getRecordTypeInfos().size());
            Set<RecordTypeinfo> listRecordtype = new Set<RecordTypeinfo>();
            Boolean withoutLegalEntity = false;
            if(checkLegalEntityRT){
                for(RecordTypeInfo info: objSObjectType.getDescribe().getRecordTypeInfos()) {
                    system.debug('info: '+info);
                    Boolean containsSegment =   info.DeveloperName.containsIgnoreCase(B2G) || info.Name.containsIgnoreCase(B2G) ||
                            info.DeveloperName.containsIgnoreCase(B2B) || info.Name.containsIgnoreCase(B2B) ||
                            info.DeveloperName.containsIgnoreCase(B2C) || info.Name.containsIgnoreCase(B2C);
                    for(String legalEntity : legalEntityList){

                        if(!info.Name.containsIgnoreCase(legalEntity) && !info.DeveloperName.containsIgnoreCase(legalEntity)){
                            withoutLegalEntity = true;
                        }
                        else {
                            withoutLegalEntity = false;
                            break;
                        }
                    }
                    if(info.isAvailable() && !info.isMaster()){
                        system.debug('info.Name: '+info.Name+' info.DeveloperName: '+info.DeveloperName);
                        if(     (info.Name.containsIgnoreCase(woList[0].XC_Segment__c) || info.DeveloperName.containsIgnoreCase(woList[0].XC_Segment__c)) &&
                                (info.Name.containsIgnoreCase(woList[0].XC_LegalEntity__c) || info.DeveloperName.containsIgnoreCase(woList[0].XC_LegalEntity__c))) {
                            listRecordtype.add(info);
                        }
                        else if (withoutLegalEntity && !containsSegment)  listRecordtype.add(info);
                        else if (withoutLegalEntity && containsSegment)   listRecordtype.add(info);
                        else if (containsSegment && withoutLegalEntity)   listRecordtype.add(info);
                    }
                }
            }
            else{
                for(RecordTypeInfo info: objSObjectType.getDescribe().getRecordTypeInfos()) {
                    if(info.isAvailable() && !info.isMaster()){
                        listRecordtype.add(info);
                    }
                }
            }
            system.debug(listRecordtype);
            return JSON.serialize(listRecordtype);
        }
        return null;
        //return [SELECT Id, Name FROM RecordType WHERE SobjectType = :objectName];
    }


    @AuraEnabled
    public static List<PredefinedValue> getPredefinedValues(String serializedPredefinedValuesToQuery, String parentId, String parentObjectName){
        List<PredefinedValue> predefinedValues = (List<PredefinedValue>) JSON.deserialize(serializedPredefinedValuesToQuery, List<PredefinedValue>.class);

        try {
            if(String.isNotBlank(parentId)) {
                String selectFields = '';
                for(PredefinedValue predValue : predefinedValues) {
                    selectFields += predValue.queryField + ', ';
                }

                String queryString = 'SELECT ' + selectFields.substring(0, selectFields.length() - 2) + ' FROM '+parentObjectName+' WHERE Id =:parentId';
                List<Sobject> sObjectsList = Database.query(queryString);

                if(!sObjectsList.isEmpty()) {
                    for(PredefinedValue predValue : predefinedValues) {
                        predValue.value = String.valueOf(sObjectsList[0].get(predValue.queryField));
                    }
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC242_TA_LCC243_CreateRecordModal] getPredefinedValues - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC242_TA_LCC243_CreateRecordModal', 'getPredefinedValues', errorMessage, 0, errorMessage, null);
        }
        return predefinedValues;
    }
}