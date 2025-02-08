/*
@CreatedBy      - Fabrizio Fiorentini (Fabrizio.Fiorentini@webresults.it), 2020/20/06
@Description    - Class to manage and create Dynamic Table section
@TestClass      - TA_LCC214_DynamicTableLayout_Test
*/
public without sharing class TA_LCC214_DynamicTableLayout {
    public class ObjectWrapper {
        @AuraEnabled
        public String objectName {get; set;}

        @AuraEnabled
        public Boolean onlyModal {get; set;}

        @AuraEnabled
        public String whereCondition {get; set;}

        @AuraEnabled
        public Boolean show {get; set;}

        @AuraEnabled
        public Boolean overIndex {get; set;}

        @AuraEnabled
        public Integer indexShowField {get; set;}

        @AuraEnabled
        public Integer totaleCurrency {get; set;}

        @AuraEnabled
        public String typeOfTabel {get; set;}

        @AuraEnabled
        public String totalCountLabel {get; set;}

        @AuraEnabled
        public String apiFieldCount {get; set;}

        @AuraEnabled
        public String detailDescription {get; set;}

        @AuraEnabled
        public String redirectToRecord {get; set;}

        @AuraEnabled
        public List<SectionWrapper> fieldsAndSection {get; set;}

        public ObjectWrapper() {}

        public ObjectWrapper(String objectName, Boolean onlyModal, String whereCondition, String typeOfTabel, String totalCountLabel, String apiFieldCount, String detailDescription) {
            this.objectName = objectName;
            this.onlyModal = onlyModal;
            this.whereCondition = whereCondition;
            this.typeOfTabel = typeOfTabel;
            this.totalCountLabel = totalCountLabel;
            this.apiFieldCount = apiFieldCount;
            this.detailDescription = detailDescription;
        }
    }

    public class SectionWrapper {
        @AuraEnabled
        public Integer numberSection {get; set;}

        @AuraEnabled
        public List<FieldWrapper> fields {get; set;}
    }

    public class FieldWrapper {
        @AuraEnabled
        public String apiName {get; set;}

        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        @AuraEnabled
        public String type {get; set;}

        @AuraEnabled
        public String mode {get; set;}

        @AuraEnabled
        public Boolean lastField {get; set;}

        @AuraEnabled
        public Boolean showLabel {get; set;}

        @AuraEnabled
        public Boolean editEnabled {get; set;}

        @AuraEnabled
        public String redirectToRecord {get; set;}

        @AuraEnabled
        public List<Map<String, String>> options {get; set;}

        public FieldWrapper() {}

        public FieldWrapper(String apiName, String type, String label, String mode, Boolean showLabel) {
            this.apiName = apiName;
            this.type = type;
            this.label = label;
            this.mode = mode;
            this.showLabel = showLabel;
            this.options = new List<Map<String, String>>();
        }
    }

    @AuraEnabled
    public static List<ObjectWrapper> getObjWrapper(String workOrderId, String customFieldSet, String accountId, String NE_orderId) {
        try {
            List<ObjectWrapper> listObjWrapper = new List<ObjectWrapper>();
            List<Object>  deserializedJsonList = (List<Object> ) JSON.deserializeUntyped(customFieldSet);
            List<Map<String, Object>> deserializedJsonMap = new List<Map<String, Object>>();

            for(Object deserializedJson : deserializedJsonList) {
                deserializedJsonMap.add((Map<String, Object>) deserializedJson);
            }

            if(deserializedJsonMap.size() > 0) {
                for(Map<String, Object> deserializedJsonSignleMap : deserializedJsonMap) {
                    ObjectWrapper objWrapper = new ObjectWrapper();
                    List<SObject> queryResults = new List<SObject>();
                    Map<String, Object> mapDetails = (Map<String, Object>) deserializedJsonSignleMap.get('details');

                    if(mapDetails != null) {
                        objWrapper = new ObjectWrapper(String.valueOf(mapDetails.get('objectName')),
                                                    Boolean.valueOf(mapDetails.get('onlyModal')),
                                                    String.valueOf(mapDetails.get('whereCondition')),
                                                    String.valueOf(mapDetails.get('typeOfTabel')),
                                                    String.valueOf(mapDetails.get('totalCountLabel')),
                                                    String.valueOf(mapDetails.get('apiFieldCount')),
                                                    String.valueOf(mapDetails.get('detailDescription')));
                        objWrapper.redirectToRecord = 'false';
                        if(String.isNotBlank(String.valueOf(mapDetails.get('redirectToRecord')))){
                            objWrapper.redirectToRecord = String.valueOf(mapDetails.get('redirectToRecord'));
                        }
                    }

                    List<Object> fields = (List<Object>) deserializedJsonSignleMap.get('fields');
                    List<Map<String, Object>> mapFields = new List<Map<String, Object>>();

                    for(Object field : fields) {
                        mapFields.add((Map<String, Object>) field);
                    }
                    List<String> queryFields = new List<String>();

                    if(!mapFields.isEmpty()) {
                        SObjectType sObjectType;
                        Map<String, Schema.SObjectField> fieldsMap;
                        Schema.SObjectField sObjectField;

                        for(Map<String, Object> field : mapFields) {
                            queryFields.add(String.valueOf(field.get('apiName')));
                        }

                        List<FieldWrapper> listToReturn = new List<FieldWrapper>();
                        List<SectionWrapper> sectionWrappers = new List<SectionWrapper>();
                        Integer totalCountSection = 0;
                        Integer totaleCurrency = 0;

                        if(!queryFields.isEmpty()) {
                            
                            // START FIX [20211213AL]
                            List<WorkOrder> workOrders = [SELECT Id, ParentWorkOrderId FROM WorkOrder WHERE Id = :workOrderId];
                            if(!workOrders.isEmpty() && String.isNotBlank(workOrders[0].ParentWorkOrderId)) {
                                workOrderId = workOrders[0].ParentWorkOrderId;
                            }
                             // END FIX [20211213AL]

                            String queryString = 'SELECT Id, ' + String.join(queryFields,',') +
                            ' FROM ' + objWrapper.objectName +
                            ' WHERE ' + objWrapper.whereCondition;

                            if(objWrapper.objectName == 'NE__OrderItem__c') {
                                queryString += ' LIMIT 1';
                            } else {
                                queryString += ' LIMIT 10';
                            }
                            queryResults = Database.query(queryString);

                            if(!queryResults.isEmpty()) {
                                for(SObject singleObj : queryResults) {
                                    totalCountSection = totalCountSection + 1;
                                    listToReturn = new List<FieldWrapper>();
                                    SectionWrapper signleSectionWrapper = new SectionWrapper();

                                    for(Map<String, Object> field : mapFields) {
                                       
                                        // if(String.valueOf(field.get('apiName')).contains('.')) {
                                        //     if(String.valueOf(field.get('apiName')).contains('__r')) {
                                        //         sObjectType = Schema.getGlobalDescribe()
                                        //             .get(objWrapper.objectName)
                                        //             .getDescribe()
                                        //             .fields
                                        //             .getMap()
                                        //             .get(String.valueOf(field.get('apiName')).split('\\.').get(0).replace('__r','__c'))
                                        //             .getDescribe()
                                        //             .getReferenceTo()
                                        //             .get(0);
                                        //     } else {
                                        //         sObjectType = Schema.getGlobalDescribe().get(String.valueOf(field.get('apiName')).split('\\.').get(0));
                                        //     }

                                        //     fieldsMap = sObjectType.getDescribe().fields.getMap();
                                        //     sObjectField = fieldsMap.get(String.valueOf(field.get('apiName')).split('\\.').get(1));
                                        // } else {
                                        //     sObjectType = Schema.getGlobalDescribe().get(String.valueOf(mapDetails.get('objectName')));
                                        //     fieldsMap =  sObjectType.getDescribe().fields.getMap();
                                        //     sObjectField = fieldsMap.get(String.valueOf(field.get('apiName')));
                                        // }

                                        List<String> apiNameSplitted = String.valueOf(field.get('apiName')).split('\\.');                            
                                        sObjectType = Schema.getGlobalDescribe().get(String.valueOf(mapDetails.get('objectName')));
                                        for(Integer i = 0; i < apiNameSplitted.size(); i++){
                                            if(i < apiNameSplitted.size() -1){
                                                if(apiNameSplitted[i].contains('__r')) {                                  
                                                    sObjectType = sObjectType
                                                        .getDescribe()
                                                        .fields
                                                        .getMap()
                                                        .get(apiNameSplitted[i].replace('__r','__c'))
                                                        .getDescribe()
                                                        .getReferenceTo()
                                                        .get(0);
                                                }
                                                else sObjectType = Schema.getGlobalDescribe().get(apiNameSplitted[i]);
                                            }
                                            else  {
                                                fieldsMap = sObjectType.getDescribe().fields.getMap();
                                                sObjectField = fieldsMap.get(apiNameSplitted[i]);
                                            }  
                                        }

                                        FieldWrapper fieldWrap = new FieldWrapper(String.valueOf(field.get('apiName')),
                                                                                String.valueOf(sObjectField.getDescribe().getType()),
                                                                                String.valueOf(sObjectField.getDescribe().getLabel()),
                                                                                String.valueOf(field.get('mode')),
                                                                                Boolean.valueOf(field.get('showLabel')));
                                        fieldWrap.redirectToRecord = '';
                                        if(String.isNotBlank(String.valueOf(field.get('redirectToRecord')))){
                                            fieldWrap.redirectToRecord = String.valueOf(field.get('redirectToRecord'))+String.valueOf(singleObj.get('Id'));
                                        }

                                        String fieldValue = getFieldValue(String.valueOf(field.get('apiName')), singleObj);

                                        // if(fieldWrap.apiName.contains('.')) {
                                        //     fieldValue = String.valueOf(singleObj.getSObject(fieldWrap.apiName.split('\\.').get(0)).get(fieldWrap.apiName.split('\\.').get(1)));
                                        // } else {
                                        //     fieldValue = String.valueOf(singleObj.get(fieldWrap.apiName));
                                        // }

                                        fieldWrap.value = fieldValue;

                                        if(fieldWrap.mode == 'edit') fieldWrap.editEnabled = false;

                                        if(fieldWrap.type == 'picklist') {
                                            String fieldWrapApiName = fieldWrap.apiName.contains('.') ? fieldWrap.apiName.substring(fieldWrap.apiName.lastIndexOf('.')+1) : fieldWrap.apiName;
                                            for(Schema.PicklistEntry val : fieldsMap.get(fieldWrapApiName).getDescribe().getPicklistValues()) {
                                                Map<String, String> picklistValueMap = new Map<String, String>();
                                                picklistValueMap.put('label', val.getLabel());
                                                picklistValueMap.put('value', val.getValue());
                                                fieldWrap.options.add(picklistValueMap);
                                            }
                                        }

                                        if(fieldWrap.value != null) {
                                            if(fieldWrap.type == 'datetime') {
                                                //START FIX [ADC 24-09-2021]
                                                //fieldWrap.value = DateTime.valueOf(fieldWrap.value).format('dd/MM/yyyy');
                                                Datetime dt = (DateTime)JSON.deserialize('"' + fieldWrap.value + '"', DateTime.class);
                                                fieldWrap.value = DateTime.valueOf(dt).format('dd/MM/yyyy hh:mm:ss');
                                                //END FIX [ADC 24-09-2021]
                                                
                                            } else if(fieldWrap.type == 'date') {
                                                Date tmpDate = Date.valueOf(fieldWrap.value);
                                                fieldWrap.value = tmpDate.day() + '/' + tmpDate.month() + '/' + tmpDate.year();
                                            }
                                        }

                                        if(fieldWrap.apiName == objWrapper.apiFieldCount && fieldValue != '' && fieldValue != null) {
                                            totaleCurrency = Integer.valueOf(fieldValue);
                                        }

                                        queryFields.add(String.valueOf(field.get('apiName')));
                                        listToReturn.add(fieldWrap);
                                    }

                                    signleSectionWrapper.numberSection = totalCountSection;
                                    signleSectionWrapper.fields = listToReturn;
                                    sectionWrappers.add(signleSectionWrapper);
                                }
                            }
                        }
                        objWrapper.overIndex = (Integer.valueOf(mapDetails.get('indexShowField')) == queryResults.size() || Integer.valueOf(mapDetails.get('indexShowField')) > queryResults.size()) ? false : true;
                        objWrapper.indexShowField = Integer.valueOf(mapDetails.get('indexShowField'));
                        objWrapper.totaleCurrency = totaleCurrency;
                        objWrapper.fieldsAndSection = SectionWrappers;
                    }

                    listObjWrapper.add(objWrapper);
                }
            }

            return listObjWrapper;
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC214_DynamicTableLayout] getObjWrapper - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC214_DynamicTableLayout', 'getObjWrapper', errorMessage, 0, errorMessage, null);
        }
        return null;
    }

    private static String getFieldValue(String apiNameValue,Sobject queryResult){
        String fieldValue = '';
        String fieldValueTmp = JSON.serialize(queryResult);
        Map<String,Object> fieldValueTmpDeserialized = (Map<String,Object>) JSON.deserializeUntyped(fieldValueTmp);        
        List<String> apiNameSplitted = apiNameValue.split('\\.'); 
        for(Integer i = 0; i < apiNameSplitted.size(); i++){        
            if(i < apiNameSplitted.size() -1){
                if(fieldValueTmpDeserialized.get(apiNameSplitted[i]) != null){
                    fieldValueTmpDeserialized = (Map<String,Object>) fieldValueTmpDeserialized.get(apiNameSplitted[i]);
                }
                else break;
            }
            else  {
                fieldValue = String.valueOf(fieldValueTmpDeserialized.get(apiNameSplitted[i]));
            }  
            
        }        
        return fieldValue;
    }
}