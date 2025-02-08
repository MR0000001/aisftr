/*
@CreatedBy      - Fabrizio FIorentini (Fabrizio.FIorentini@webresults.it), 2020/10/06
@Description    - Class to manage and create Dynamic Layout section with multi Query
@TestClass      - TA_LCC215_DynamicMultyQueryLayout_Test
*/
public without sharing class TA_LCC215_DynamicMultyQueryLayout {

    public class ObjectWrapper {
        @AuraEnabled
        public String objectName {get; set;}

        @AuraEnabled
        public Boolean byPassClassicInformation {get; set;}

        @AuraEnabled
        public String whereCondition {get; set;}

        @AuraEnabled
        public Boolean show {get; set;}

        @AuraEnabled
        public String afterObjectLookup {get; set;}

        @AuraEnabled
        public List<FieldWrapper> fields {get; set;}

        @AuraEnabled
        public Map<String, String> mapFieldObject {get; set;}

        public ObjectWrapper() {}

        public ObjectWrapper(String objectName, String afterObjectLookup, Boolean byPassClassicInformation, String whereCondition, Boolean show) {
            this.objectName = objectName;
            this.afterObjectLookup = afterObjectLookup;
            this.byPassClassicInformation = byPassClassicInformation;
            this.whereCondition = whereCondition;
            this.show = show;
        }
    }

    public class FieldWrapper {
        @AuraEnabled
        public String objectName {get; set;}

        @AuraEnabled
        public String apiName {get; set;}

        @AuraEnabled
        public Boolean required {get; set;}

        @AuraEnabled
        public String mode  {get; set;}

        @AuraEnabled
        public String type  {get; set;}

        @AuraEnabled
        public String image {get; set;}

        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        @AuraEnabled
        public String originalValue {get; set;}

        @AuraEnabled
        public Boolean editableField {get; set;}

        @AuraEnabled
        public List<Map<String, String>> options {get; set;}

        public FieldWrapper() {}

        public FieldWrapper(String apiName, Boolean required, String mode, Boolean editableField, String type, String label) {
            this.apiName = apiName;
            this.required = required;
            this.mode = mode;
            this.editableField = editableField;
            this.type = type;
            this.label = label;
            this.options = new List<Map<String, String>>();
        }
    }

    @AuraEnabled
    public static ObjectWrapper getObjWrapper(String workOrderId, String customFieldSet, String AssetId) {
        try {
            List<FieldWrapper> listToReturn = new List<FieldWrapper>();
            Map<String, String> mapFieldObject = new Map<String, String>();
            Id conditionId;
            List<Object> deserializedJsonList = (List<Object>) JSON.deserializeUntyped(customFieldSet);
            List<Map<String, Object>> deserializedJsonMap = new List<Map<String, Object>>();

            for(Object deserializedJson : deserializedJsonList) {
                deserializedJsonMap.add((Map<String, Object>) deserializedJson);
            }

            ObjectWrapper objWrapper = new ObjectWrapper();
            if(deserializedJsonMap.size() > 0) {
                for(Map<String, Object> deserializedJsonSignleMap : deserializedJsonMap) {
                    Map<String, Object> mapDetails = (Map<String, Object>) deserializedJsonSignleMap.get('details');

                    if(mapDetails != null) {
                        objWrapper = new ObjectWrapper(String.valueOf(mapDetails.get('objectName')),
                                                    String.valueOf(mapDetails.get('afterObjectLookup')),
                                                    Boolean.valueOf(mapDetails.get('byPassClassicInformation')),
                                                    String.valueOf(mapDetails.get('whereCondition')),
                                                    Boolean.valueOf(mapDetails.get('show')));

                        objWrapper.mapFieldObject = new Map<String, String>();
                    }

                    List<Object> fields = (List<Object>) deserializedJsonSignleMap.get('fields');
                    List<Map<String, Object>> mapFields = new List<Map<String, Object>>();

                    for(Object field : fields) {
                        mapFields.add((Map<String, Object>) field);
                    }

                    List<FieldWrapper> fieldWraps = new List<FieldWrapper>();
                    List<String> queryFields = new List<String>();

                    if(!mapFields.isEmpty()) {
                        SObjectType sObjectType;
                        Map<String, Schema.SObjectField> fieldsMap;
                        Schema.SObjectField sObjectField;

                        for(Map<String, Object> field : mapFields) {
                            if(!objWrapper.byPassClassicInformation) {
                                if(String.valueOf(field.get('apiName')).contains('.')) {
                                    if(String.valueOf(field.get('apiName')).contains('__r')) {
                                        sObjectType = Schema.getGlobalDescribe()
                                            .get(objWrapper.objectName)
                                            .getDescribe()
                                            .fields
                                            .getMap()
                                            .get(String.valueOf(field.get('apiName')).split('\\.').get(0).replace('__r','__c'))
                                            .getDescribe()
                                            .getReferenceTo()
                                            .get(0);
                                    } else {
                                        sObjectType = Schema.getGlobalDescribe().get(String.valueOf(field.get('apiName')).split('\\.').get(0));
                                    }

                                    fieldsMap = sObjectType.getDescribe().fields.getMap();
                                    sObjectField = fieldsMap.get(String.valueOf(field.get('apiName')).split('\\.').get(1));
                                } else {
                                    sObjectType = Schema.getGlobalDescribe().get(String.valueOf(mapDetails.get('objectName')));
                                    fieldsMap =  sObjectType.getDescribe().fields.getMap();
                                    sObjectField = fieldsMap.get(String.valueOf(field.get('apiName')));
                                }

                                FieldWrapper fieldWrap = new FieldWrapper(String.valueOf(field.get('apiName')),
                                                                        Boolean.valueOf(field.get('required')),
                                                                        String.valueOf(field.get('mode')),
                                                                        Boolean.valueOf(field.get('editableField')),
                                                                        String.valueOf(sObjectField.getDescribe().getType()),
                                                                        String.valueOf(sObjectField.getDescribe().getLabel()));

                                mapFieldObject.put(fieldWrap.apiName, objWrapper.objectName);

                                if(String.isNotBlank(String.valueOf(field.get('image')))) {
                                    fieldWrap.image = String.valueOf(field.get('image'));
                                }

                                fieldWraps.add(fieldWrap);
                            }

                            queryFields.add(String.valueOf(field.get('apiName')));
                        }

                        if(!queryFields.isEmpty()) {
                            String queryString = 'SELECT Id, ' + String.join(queryFields,',') +
                            ' FROM ' + objWrapper.objectName +
                            ' WHERE ' + objWrapper.whereCondition;

                            List<SObject> queryResults = Database.query(queryString);
                            if(!queryResults.isEmpty()) {
                                if(objWrapper.byPassClassicInformation) {
                                    for(SObject singleObj : queryResults) {
                                        String fieldLabel = '';
                                        String fieldValue = '';

                                        for(Map<String, Object> field : mapFields) {
                                            String takeValue = '';
                                            String nameField = String.valueOf(field.get('apiName'));
                                            if(nameField.contains('.')) {
                                                takeValue = String.valueOf(singleObj.getSObject(nameField.split('\\.').get(0)).get(nameField.split('\\.').get(1)));
                                            } else {
                                                takeValue = String.valueOf(singleObj.get(nameField));
                                            }

                                            if(field.get('usedFor') == 'label') {
                                                fieldLabel = takeValue;
                                            } else {
                                                fieldValue = takeValue;
                                            }
                                        }

                                        FieldWrapper fieldWrap = new FieldWrapper(fieldLabel,
                                                                                    false,
                                                                                    'view',
                                                                                    false,
                                                                                    'String',
                                                                                    fieldLabel);

                                        mapFieldObject.put(fieldWrap.apiName, objWrapper.objectName);
                                        fieldWrap.value = fieldValue;
                                        fieldWrap.objectName = objWrapper.objectName;
                                        listToReturn.add(fieldWrap);
                                    }
                                } else {
                                    for(FieldWrapper fieldWrap : fieldWraps) {
                                        String fieldValue = '';
                                        String conditionIdSearchValue;

                                        //TODO CODE-REVIEW
                                        if(objWrapper.afterObjectLookup != null && objWrapper.afterObjectLookup != '') {
                                            if(objWrapper.afterObjectLookup.contains('.')) {
                                                conditionIdSearchValue = String.valueOf(queryResults.get(0).getSObject(objWrapper.afterObjectLookup.split('\\.').get(0)).get(objWrapper.afterObjectLookup.split('\\.').get(1)));
                                            }else {
                                                conditionIdSearchValue = String.valueOf(queryResults.get(0).get(objWrapper.afterObjectLookup));
                                            }
                                        }
                                        String apiName = fieldWrap.apiName;
                                        if(fieldWrap.apiName.contains('.')) {
                                            apiName = fieldWrap.apiName.split('\\.').get(1);
                                            fieldValue = String.valueOf(queryResults.get(0).getSObject(fieldWrap.apiName.split('\\.').get(0)).get(fieldWrap.apiName.split('\\.').get(1)));
                                        } else {
                                            fieldValue = String.valueOf(queryResults.get(0).get(fieldWrap.apiName));
                                        }

                                        conditionId = conditionIdSearchValue;
                                        fieldWrap.value = fieldValue;
                                        fieldWrap.originalValue = fieldValue;
                                        fieldWrap.objectName = objWrapper.objectName;
                                        system.debug('fieldsMap.values(): '+fieldsMap.toString());
                                        system.debug('apiName: '+apiName);
                                        system.debug('fieldsMap.get(fieldWrap.apiName): '+fieldsMap.get(apiName));


                                        if(fieldWrap.type == 'picklist') {
                                            for(Schema.PicklistEntry val : fieldsMap.get(apiName).getDescribe().getPicklistValues()) {
                                                Map<String, String> picklistValueMap = new Map<String, String>();
                                                picklistValueMap.put('label', val.getLabel());
                                                picklistValueMap.put('value', val.getValue());
                                                fieldWrap.options.add(picklistValueMap);
                                            }
                                        } else if((fieldWrap.type == 'datetime' || fieldWrap.type == 'date') && fieldWrap.value != null) {
                                            fieldWrap.value = DateTime.valueOf(fieldWrap.value).format('dd/MM/yyyy');
                                        }

                                        listToReturn.add(fieldWrap);
                                    }
                                }
                            }
                        }
                    }
                }
                objWrapper.fields = listToReturn;
            }

            return objWrapper;
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC215_DynamicMultyQueryLayout] getObjWrapper - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC215_DynamicMultyQueryLayout', 'getObjWrapper', errorMessage, 0, errorMessage, null);
        }
        return null;
    }
}