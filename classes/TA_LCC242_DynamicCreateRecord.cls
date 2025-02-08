public without sharing class TA_LCC242_DynamicCreateRecord {
    public TA_LCC242_DynamicCreateRecord() {}

    public final static String OBJ_NAME_TECHNICAL_SHEET = 'XC_TechnicalSheet__c';
    public final static String OBJ_NAME_PERSONAL_DOCUMENT = 'XC_PersonalDocument__c';

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
        public String   name   {get; set;}
        @AuraEnabled
        public String   recordTypeName   {get; set;}
        @AuraEnabled
        public String   recordTypeId   {get; set;}
        @AuraEnabled
        public String   fieldToDisplay   {get; set;}
        @AuraEnabled
        public Map<String, String>  fieldsToCheck  {get; set;}

        public RecordWrapper(String id, String name, String recordTypeName, String recordTypeId, Map<String, String> fieldsToCheck) {
            this.id = id;
            this.name = name;
            this.recordTypeName = recordTypeName;
            this.recordTypeId = recordTypeId;
            this.fieldsToCheck = fieldsToCheck;
        }

        public RecordWrapper(String id, String name, String recordTypeName, String recordTypeId, String fieldToDisplay, Map<String, String> fieldsToCheck) {
            this.id = id;
            this.name = name;
            this.recordTypeName = recordTypeName;
            this.recordTypeId = recordTypeId;
            this.fieldToDisplay = fieldToDisplay;
            this.fieldsToCheck = fieldsToCheck;
        }
    }

    @AuraEnabled
    public static String getRecordTypesByObjectName(String objectName){
        Map<String, Schema.SObjectType> mapGlobalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType objSObjectType = mapGlobalDescribe.get(objectName);       
        List<RecordTypeInfo> recordTypes = new List<RecordTypeInfo>();

        for(RecordTypeInfo info: objSObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable() && !info.isMaster()) {               
                recordTypes.add(info);
            }
        }
        return JSON.serialize(recordTypes);
    }

    @AuraEnabled
    public static Boolean deleteRecord(String recordId, String objectName){
        try {
            if(String.isNotBlank(recordId) && String.isNotBlank(objectName)) {
                String queryString = 'SELECT Id FROM '+ objectName + ' WHERE Id =:recordId';
                List<SObject> queryResults = Database.query(queryString);
                
                if(!queryResults.isEmpty()) {
                    delete queryResults[0];
                    return true;
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC242_DynamicCreateRecord] deleteRecord - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC242_DynamicCreateRecord', 'deleteRecord', errorMessage, 0, errorMessage, null);
        }
        return false;
    }

    @AuraEnabled
    public static Boolean isComponentVisible(String workOrderId, String objectName) {
        if(String.isNotBlank(workOrderId)) {
            if(objectName == OBJ_NAME_TECHNICAL_SHEET) {
                List<WorkOrder> workOrders = [SELECT Id, AssetId, Asset.NE__Bundle_element__c, Asset.NE__Bundle_element__r.XC_MacroCategory__c, XC_Configuration__c, ParentWorkOrderId, ParentWorkOrder.XC_Configuration__c FROM WorkOrder WHERE Id =:workOrderId];
                if(!workOrders.isEmpty()) {
                    String orderId = '';
                    if(String.isNotBlank(workOrders[0].XC_Configuration__c)) {
                        orderId = workOrders[0].XC_Configuration__c;
                    } else if(String.isNotBlank(workOrders[0].ParentWorkOrderId)) {
                        orderId = workOrders[0].ParentWorkOrder.XC_Configuration__c;
                    } else {
                        orderId = null;
                    }

                    List<NE__OrderItem__c> orderItems = [SELECT Id 
                                                            FROM NE__OrderItem__c 
                                                            WHERE NE__OrderId__c = :orderId
                                                            AND XC_Product_Type__c = 'Billing'
                                                            AND XC_Product_Subtype__c = 'Incentive'];

                    if(!orderItems.isEmpty() && 
                        String.isNotBlank(workOrders[0].AssetId) && 
                        String.isNotBlank(workOrders[0].Asset.NE__Bundle_element__c) && 
                        workOrders[0].Asset.NE__Bundle_element__r.XC_MacroCategory__c == 'Main') {
                        return true;
                    }
                }
            } else if(objectName == OBJ_NAME_PERSONAL_DOCUMENT) {
                return true;
            } 
        }
        return false;
    }

    @AuraEnabled
    public static List<RecordWrapper> getCurrentRecords(String workOrderId, String objectName, Boolean isMultiRecords, String fieldToDisplay, List<String> fieldsToCheck) {
        System.debug('>_> workOrderId : ' + workOrderId);
        System.debug('>_> objectName : ' + objectName);
        System.debug('>_> isMultiRecords : ' + isMultiRecords);
        System.debug('>_> fieldToDisplay : ' + fieldToDisplay);
        System.debug('>_> fieldsToCheck : ' + fieldsToCheck);
        if(String.isNotBlank(workOrderId)) {
            //if(objectName == OBJ_NAME_TECHNICAL_SHEET) {
                List<SObject> objectList = new List<SObject>();
                String queryString = 'SELECT Id, Name, RecordType.Name, RecordTypeId ';
                Boolean toQuery = false;

                if(String.isNotBlank(fieldToDisplay) && !queryString.contains(fieldToDisplay)) queryString += ', ' + fieldToDisplay;
                if(!fieldsToCheck.isEmpty()) queryString += ', ' + String.join(fieldsToCheck,',');
                queryString += ' FROM ' + objectName;

                if(objectName == OBJ_NAME_TECHNICAL_SHEET) {
                    queryString += ' WHERE XC_WorkOrder__c =:workOrderId';
                    toQuery = true;
                } else if(objectName == OBJ_NAME_PERSONAL_DOCUMENT) {
                    List<WorkOrder> workOrders = [SELECT Id, ContactId FROM WorkOrder WHERE Id =:workOrderId];
                    if(!workOrders.isEmpty()) {
                        String contactId = workOrders[0].ContactId;
                        queryString += ' WHERE XC_ContactId__c =:contactId';
                        toQuery = true;
                    }
                }

                if(toQuery) objectList = Database.query(queryString);   
                
                if(!objectList.isEmpty()) {
                    if(isMultiRecords) {
                        List<RecordWrapper> recordWrappers = new List<RecordWrapper>();
                        for(SObject obj : objectList) {
                            Map<String, String> fieldsMap = new Map<String, String>();
                            for(String field : fieldsToCheck) {
                                fieldsMap.put(field, String.valueOf(obj.get(field)));
                            }
                            recordWrappers.add(new RecordWrapper(String.valueOf(obj.get('Id')), 
                                                                 String.valueOf(obj.get('Name')), 
                                                                 String.isNotBlank(String.valueOf(obj.getSObject('RecordType'))) ? String.valueOf(obj.getSObject('RecordType').get('Name')) : null, 
                                                                 String.valueOf(obj.get('RecordTypeId')),
                                                                 String.valueOf(obj.get(fieldToDisplay)),
                                                                 fieldsMap
                                                                 ));
                        }
                        return recordWrappers; 
                    } else {
                        Map<String, String> fieldsMap = new Map<String, String>();
                        for(String field : fieldsToCheck) {
                            fieldsMap.put(field, String.valueOf(objectList[0].get(field)));
                        }
                        List<RecordWrapper> recordWraps = new List<RecordWrapper>();
                        RecordWrapper recordWrp = new RecordWrapper(String.valueOf(objectList[0].get('Id')), 
                                                                    String.valueOf(objectList[0].get('Name')), 
                                                                    String.isNotBlank(String.valueOf(objectList[0].getSObject('RecordType'))) ? String.valueOf(objectList[0].getSObject('RecordType').get('Name')) : null, 
                                                                    String.valueOf(objectList[0].get('RecordTypeId')),
                                                                    fieldsMap
                                                                    );
                        if(String.isNotBlank(fieldToDisplay)) recordWrp.fieldToDisplay = String.valueOf(objectList[0].get(fieldToDisplay));
                        recordWraps.add(recordWrp);
                        return recordWraps;
                    }  
                }
            //}
        }
        return new List<RecordWrapper>();
    }

    @AuraEnabled
    public static List<PredefinedValue> getPredefinedValues(String serializedPredefinedValuesToQuery, String workOrderId){
        List<PredefinedValue> predefinedValues = (List<PredefinedValue>) JSON.deserialize(serializedPredefinedValuesToQuery, List<PredefinedValue>.class);
        //TO ADAPT IN CASE OF OTHER OBJECT/FIELD RULES
        try {
            if(String.isNotBlank(workOrderId)) {
                String selectFields = '';
                for(PredefinedValue predValue : predefinedValues) {
                    selectFields += predValue.queryField + ', ';
                }

                String queryString = 'SELECT ' + selectFields.substring(0, selectFields.length() - 2) + ' FROM WorkOrder WHERE Id =:workOrderId';  
                List<WorkOrder> workOrders = Database.query(queryString);

                if(!workOrders.isEmpty()) {
                    for(PredefinedValue predValue : predefinedValues) {
                        predValue.value = String.valueOf(workOrders[0].get(predValue.queryField));
                    }
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC242_DynamicCreateRecord] getPredefinedValues - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC242_DynamicCreateRecord', 'getPredefinedValues', errorMessage, 0, errorMessage, null);
        }
        return predefinedValues;
    }
}