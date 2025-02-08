/*
@CreatedBy      - Andrea Liverani (andrea.liverani@webresults.it), 2020/09/25
@Description    - Class to manage and create Dynamic Layout section
@TestClass      - TA_LCC202_DynamicLayout_Test
*/
public without sharing class TA_LCC202_DynamicLayout {
    public TA_LCC202_DynamicLayout() {}

    public class ObjectWrapper {
        @AuraEnabled
        public String objectName {get; set;}

        @AuraEnabled
        public String objectLookup {get; set;}

        @AuraEnabled
        public String whereCondition {get; set;}

        @AuraEnabled
        public Boolean show {get; set;}

        @AuraEnabled
        public Boolean massEdit {get; set;}

        @AuraEnabled
        public List<FieldWrapper> fields {get; set;}

        @AuraEnabled
        public Boolean isQueryEmpty {get; set;}

        @AuraEnabled
        public Boolean isModeEdit {get; set;}

        @AuraEnabled
        public Boolean isVisible {get; set;}

        public ObjectWrapper() {}

        public ObjectWrapper(String objectName, String objectLookup, String whereCondition, Boolean show) {
            this.objectName = objectName;
            this.objectLookup = objectLookup;
            this.whereCondition = whereCondition;
            this.show = show;
            this.isQueryEmpty = true;
        }
    }

    public class FieldWrapper {
        @AuraEnabled
        public String apiName {get; set;}

        @AuraEnabled
        public String queryApiName {get; set;}

        @AuraEnabled
        public Boolean required {get; set;}

        @AuraEnabled
        public String mode {get; set;}

        @AuraEnabled
        public String type {get; set;}

        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        @AuraEnabled
        public String image {get; set;}

        @AuraEnabled
        public String objectName {get; set;}

        @AuraEnabled
        public Boolean editEnabled {get; set;}

        @AuraEnabled
        public String redirectTo {get; set;}

        @AuraEnabled
        public String displayValueApiName {get; set;}

        @AuraEnabled
        public List<Map<String, String>> options {get; set;}

        @AuraEnabled
        public Boolean addLogic {get; set;}

        public FieldWrapper() {}

        public FieldWrapper(String apiName, Boolean required, String mode, String type, String label) {
            this.apiName = apiName;
            this.required = required;
            this.mode = mode;
            this.type = type;
            this.label = label;
            this.options = new List<Map<String, String>>();
        }
    }

    @AuraEnabled
    public static ObjectWrapper getObjWrapper(String workOrderId, String customFieldSet) {
        String recordId = workOrderId;
        ObjectWrapper objWrapper = new ObjectWrapper();
        try {
            Map<String, Object> deserializedJson = (Map<String,Object>) JSON.deserializeUntyped(customFieldSet);

            if(deserializedJson != null) {
                Map<String, Object> mapDetails = (Map<String, Object>) deserializedJson.get('details');

                if(mapDetails != null) {
                    objWrapper = new ObjectWrapper(String.valueOf(mapDetails.get('objectName')),
                            String.valueOf(mapDetails.get('objectLookup')),
                            String.valueOf(mapDetails.get('whereCondition')),
                            Boolean.valueOf(mapDetails.get('show')));

                    objWrapper.massEdit = mapDetails.get('massEdit') != null ? Boolean.valueOf(mapDetails.get('massEdit')) : false;
                    if(mapDetails.get('isVisibleMethod') != null) objWrapper.isVisible = manageVisibility(String.valueOf(mapDetails.get('isVisibleMethod')), workOrderId);
                }

                List<Object> fields = (List<Object>) deserializedJson.get('fields');
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

                    //start fix [ADC] 10/05/2021
                    objWrapper.isModeEdit = false;
                    //end fix [ADC] 10/05/2021

                    //START FIX [ADC 20/05/2021] TASK ENXCRM-92                
                    String userPermissionSetName = TA_LCC209_BaseWizardCnt.getUserPermissionSetName();
                    Boolean isB2G = userPermissionSetName != null && userPermissionSetName.contains('B2G') ? true : false;
                    Boolean createFieldWrapperForAssetSupport = false;
                    Integer indexOfFieldWrapperToRemove;
                    String assetId;
                    //END FIX [ADC 20/05/2021] TASK ENXCRM-92

                    for(Map<String, Object> field : mapFields) {

                        //START FIX [SR15/07/2021]
                        /*if(String.valueOf(field.get('apiName')).contains('.')) {                       
                            
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
                        }*/

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
                        //END FIX [SR15/07/2021]
                        System.debug('@@@ fieldsMap: ' + fieldsMap);
                        System.debug('@@@ sObjectField: ' + sObjectField);

                        FieldWrapper fieldWrap = new FieldWrapper(String.valueOf(field.get('apiName')),
                                Boolean.valueOf(field.get('required')),
                                String.valueOf(field.get('mode')),
                                String.valueOf(sObjectField.getDescribe().getType()),
                                String.valueOf(sObjectField.getDescribe().getLabel()));

                        //START FIX [SR15/07/2021]
                        if(fieldWrap.type == 'picklist') {
                            String fieldWrapApiName = fieldWrap.apiName.contains('.') ? fieldWrap.apiName.substring(fieldWrap.apiName.lastIndexOf('.')+1) : fieldWrap.apiName;
                            for(Schema.PicklistEntry val : fieldsMap.get(fieldWrapApiName).getDescribe().getPicklistValues()) {
                                Map<String, String> picklistValueMap = new Map<String, String>();
                                picklistValueMap.put('label', val.getLabel());
                                picklistValueMap.put('value', val.getValue());
                                fieldWrap.options.add(picklistValueMap);
                            }
                        }
                        //END FIX [SR15/07/2021]

                        if(String.isNotBlank(String.valueOf(field.get('image')))) {
                            fieldWrap.image = String.valueOf(field.get('image'));
                        }

                        if(String.isNotBlank(String.valueOf(field.get('redirectTo')))) {
                            fieldWrap.redirectTo = String.valueOf(field.get('redirectTo'));
                        }
                        if(String.isNotBlank(String.valueOf(field.get('displayValueApiName')))) {
                            fieldWrap.displayValueApiName = String.valueOf(field.get('displayValueApiName'));
                        }

                        if(String.isNotBlank(String.valueOf(field.get('addLogic')))) {
                            fieldWrap.addLogic = Boolean.valueOf(field.get('addLogic'));
                        }

                        if(fieldWrap.mode == 'edit') fieldWrap.editEnabled = false;

                        //start fix [ADC] 10/05/2021                        
                        if(fieldWrap.mode == 'edit' || fieldWrap.mode == 'defaultEdit'){                            
                            objWrapper.isModeEdit = true;
                        }
                        //end fix [ADC] 10/05/2021

                        fieldWraps.add(fieldWrap);
                        String apinameField = String.valueOf(field.get('apiName'));
                        system.debug('@@@@@apinameField: '+fieldWrap);
                        if(fieldWrap.type == 'picklist'){
                            system.debug('@@@@@dentro if: '+fieldWrap.type);
                            apinameField = 'toLabel('+apinameField+')';
                        }
                        system.debug('@@@@@apinameField: '+apinameField);                        
                        queryFields.add(apinameField);
                        if(fieldWrap.displayValueApiName!=null && !queryFields.contains(fieldWrap.displayValueApiName)){
                            queryFields.add(fieldWrap.displayValueApiName);
                        }

                    }

                    if(!queryFields.isEmpty()) {
                        if(objWrapper.objectName!= 'WorkOrder' || (mapDetails.get('isQualityCheck') != null && Boolean.valueOf(mapDetails.get('isQualityCheck')) )){
                            String queryStringRecordId = 'SELECT ' +objWrapper.objectLookup+
                                    ' FROM WorkOrder ' +
                                    ' WHERE id = :workOrderId';
                            List<SObject> queryRecordIdResults = Database.query(queryStringRecordId);
                            if(!queryRecordIdResults.isEmpty()){
                                recordId =(String)queryRecordIdResults.get(0).get(objWrapper.objectLookup);
                            }

                        }
                        String queryString = 'SELECT Id, ' + String.join(queryFields,',') +
                                ' FROM ' + objWrapper.objectName +
                                ' WHERE ';

                        if(String.isNotBlank(objWrapper.whereCondition)) {
                            objWrapper.whereCondition = 'Id = \'' + recordId + '\' AND ' + objWrapper.whereCondition;
                        } else {
                            objWrapper.whereCondition = 'Id = \'' + recordId + '\'';
                        }
                        queryString += objWrapper.whereCondition;

                        List<SObject> queryResults = Database.query(queryString);                       
                        //start fix [ADC] 10/05/2021
                        //objWrapper.isQueryEmpty = queryResults.isEmpty();
                        objWrapper.isQueryEmpty = objWrapper.isModeEdit ? false : queryResults.isEmpty();                        
                        //end fix [ADC] 10/05/2021

                        if(!queryResults.isEmpty()) {
                            for(FieldWrapper fieldWrap : fieldWraps) {

                                String apiNameValue=fieldWrap.displayValueApiName!=null ? fieldWrap.displayValueApiName : fieldWrap.apiName;
                                /*//TODO CODE-REVIEW
                                String fieldValue = '';
                                if(apiNameValue.contains('.')){
                                    Schema.SObjectType sObjectTypeTmp;
                                    if(apiNameValue.contains('__r')) {
                                        sObjectTypeTmp = Schema.getGlobalDescribe()
                                                .get(objWrapper.objectName)
                                                .getDescribe()
                                                .fields
                                                .getMap()
                                                .get(apiNameValue.split('\\.').get(0).replace('__r','__c'))
                                                .getDescribe()
                                                .getReferenceTo()
                                                .get(0);
                                    } else {
                                        sObjectTypeTmp = Schema.getGlobalDescribe().get(apiNameValue.split('\\.').get(0));
                                        if(sObjectTypeTmp==null){
                                            sObjectTypeTmp = Schema.getGlobalDescribe()
                                                    .get(objWrapper.objectName)
                                                    .getDescribe()
                                                    .fields
                                                    .getMap()
                                                    .get(apiNameValue.split('\\.').get(0)+'Id')
                                                    .getDescribe()
                                                    .getReferenceTo()
                                                    .get(0);
                                        }
                                    }
                                    //fieldsMap = sObjectTypeTmp.getDescribe().fields.getMap();

                                    if(queryResults.get(0).getSObject(apiNameValue.split('\\.').get(0)) != null){
                                        fieldValue = String.valueOf(queryResults.get(0).getSObject(apiNameValue.split('\\.').get(0)).get(apiNameValue.split('\\.').get(1)));
                                    }
                                    else fieldValue = null;

                                } else {
                                    fieldValue = String.valueOf(queryResults.get(0).get(apiNameValue));
                                    Schema.SObjectType sObjectTypeTmp = Schema.getGlobalDescribe().get(String.valueOf(mapDetails.get('objectName')));
                                    //fieldsMap =  sObjectTypeTmp.getDescribe().fields.getMap();
                                }*/
                                //START FIX [SR15/07/2021]
                                //fieldsMap = getsObjectTypeTmp(apiNameValue,objWrapper,mapDetails).getDescribe().fields.getMap();
                                //END FIX [SR15/07/2021]
                                fieldWrap.value = getFieldValue(apiNameValue,queryResults);

                                //START FIX [ADC 20/05/2021] TASK ENXCRM-92
                                if(isB2G && fieldWrap.value == 'Support' && fieldWrap.apiName == 'TAM_AssetType__c' && objWrapper.objectName == 'Asset'){  
                                    createFieldWrapperForAssetSupport = true;
                                    indexOfFieldWrapperToRemove = fieldWraps.indexOf(fieldWrap); 
                                    assetId = recordId;                               
                                }
                                //END FIX [ADC 20/05/2021] TASK ENXCRM-92

                                if(fieldWrap.redirectTo!= null){
                                    fieldWrap.redirectTo += getFieldValue(fieldWrap.apiName,queryResults);
                                }
                                //START FIX [SR15/07/2021]
                                /*if(fieldWrap.type == 'picklist') {
                                    String fieldWrapApiName = fieldWrap.apiName.contains('.') ? fieldWrap.apiName.split('\\.').get(1) : fieldWrap.apiName;
                                    for(Schema.PicklistEntry val : fieldsMap.get(fieldWrapApiName).getDescribe().getPicklistValues()) {
                                        Map<String, String> picklistValueMap = new Map<String, String>();
                                        picklistValueMap.put('label', val.getLabel());
                                        picklistValueMap.put('value', val.getValue());
                                        fieldWrap.options.add(picklistValueMap);
                                    }
                                } else if((fieldWrap.type == 'datetime' || fieldWrap.type == 'date') && fieldWrap.value != null) {
                                    fieldWrap.value = DateTime.valueOf(fieldWrap.value).format('dd/MM/yyyy');
                                }*/

                                //START FIX [20210803AL]
                                /*if((fieldWrap.type == 'datetime' || fieldWrap.type == 'date') && fieldWrap.value != null) {
                                    fieldWrap.value = DateTime.valueOf(fieldWrap.value).format('dd/MM/yyyy');
                                }*/
                                if(fieldWrap.value != null) {
                                    if(fieldWrap.type == 'datetime') {
                                        //START FIX [ADC 24-09-2021]
                                        //fieldWrap.value = DateTime.valueOf(fieldWrap.value).format('dd/MM/yyyy');
                                        Datetime dt = (DateTime)JSON.deserialize('"' + fieldWrap.value + '"', DateTime.class);
                                        fieldWrap.value = DateTime.valueOf(dt).format('dd/MM/yyyy');
                                        //END FIX [ADC 24-09-2021]
                                    } else if(fieldWrap.type == 'date') {
                                        Date tmpDate = Date.valueOf(fieldWrap.value);
                                        fieldWrap.value = tmpDate.day() + '/' + tmpDate.month() + '/' + tmpDate.year();
                                    }
                                }
                                //END FIX [20210803AL]
                                
                                //END FIX [SR15/07/2021]
                            }
                            //START FIX [ADC 20/05/2021] TASK ENXCRM-92                  
                            if(createFieldWrapperForAssetSupport || Test.isRunningTest() ){
                                FieldWrapper fieldWrapRelatedAssetName = new FieldWrapper(null,false,'view',null,Asset.Name.getDescribe().getLabel());
                                List<AssetRelationship> assRelationList = [SELECT RelatedAsset.Name 
                                                                            FROM AssetRelationship 
                                                                            WHERE AssetId =:assetId
                                                                            AND RelatedAsset.RecordType.Name = 'SwitchBoard'];
                                if(!assRelationList.isEmpty()) fieldWrapRelatedAssetName.value = assRelationList[0].RelatedAsset.Name;                                 
                                                                                                                            
                                FieldWrapper fieldWrapRatedPower = new FieldWrapper(null,false,'view',null,Asset.TAM_RatedPower__c.getDescribe().getLabel());
                                FieldWrapper fieldWrapLightTec = new FieldWrapper(null,false,'view',null,Asset.TAM_LightingTechnology__c.getDescribe().getLabel());
                                
                                List<Asset> parentAssetList = [SELECT TAM_RatedPower__c, TAM_LightingTechnology__c
                                                                FROM Asset 
                                                                WHERE ParentId =: assetId];
                                Decimal fieldWrapRatedPowerValue;
                                String fieldWrapLightTecValue = '';

                                if(!parentAssetList.isEmpty()) {
                                    fieldWrapRatedPowerValue = parentAssetList[0].TAM_RatedPower__c; 
                                    fieldWrapLightTecValue = parentAssetList[0].TAM_LightingTechnology__c; 
                                }                   
                               
                                fieldWrapRatedPower.value = String.valueOf(fieldWrapRatedPowerValue);
                                fieldWrapLightTec.value = fieldWrapLightTecValue;
                                
                                fieldWraps.add(fieldWrapRelatedAssetName);      
                                fieldWraps.add(fieldWrapRatedPower); 
                                fieldWraps.add(fieldWrapLightTec); 
                                fieldWraps.remove(indexOfFieldWrapperToRemove);        
                            }
                            //END FIX [ADC 20/05/2021] TASK ENXCRM-92
                        }
                    }
                    objWrapper.fields = fieldWraps;
                }
            } else {
                System.debug('[TA_LCC202_DynamicLayout] getObjWrapper - deserializedJson is null.');
            }

        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC202_DynamicLayout] getObjWrapper - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC202_DynamicLayout', 'getObjWrapper', errorMessage, 0, errorMessage, null);
        }
        return objWrapper;
    }

    //START FIX [SR15/07/2021]
    /*private static Schema.SObjectType getsObjectTypeTmp(String apiNameValue,ObjectWrapper objWrapper,Map<String, Object> mapDetails){
        Schema.SObjectType sObjectTypeTmp;
        if(apiNameValue.contains('.')){
            if(apiNameValue.contains('__r')) {
                sObjectTypeTmp = Schema.getGlobalDescribe()
                        .get(objWrapper.objectName)
                        .getDescribe()
                        .fields
                        .getMap()
                        .get(apiNameValue.split('\\.').get(0).replace('__r','__c'))
                        .getDescribe()
                        .getReferenceTo()
                        .get(0);
            } else {
                sObjectTypeTmp = Schema.getGlobalDescribe().get(apiNameValue.split('\\.').get(0));
                if(sObjectTypeTmp==null){
                    sObjectTypeTmp = Schema.getGlobalDescribe()
                            .get(objWrapper.objectName)
                            .getDescribe()
                            .fields
                            .getMap()
                            .get(apiNameValue.split('\\.').get(0)+'Id')
                            .getDescribe()
                            .getReferenceTo()
                            .get(0);
                }
            }

        } else {
            sObjectTypeTmp = Schema.getGlobalDescribe().get(String.valueOf(mapDetails.get('objectName')));
        }
        return sObjectTypeTmp;
    }*/
    //END FIX [SR15/07/2021]

    public static Boolean manageVisibility(String methodName, String workOrderId) {
        switch on methodName {
            when 'checkJuiceHome' {
                return checkJuiceHome(workOrderId);
            }
            //START [20220517AL] - NR2551
            when 'checkPermittingForm' {
                return checkPermittingForm(workOrderId);
            }
            //END [20220517AL] - NR2551
            when else {
                return true;
            }
        }
    }

    public static Boolean checkJuiceHome(String workOrderId) {
        List<WorkOrder> workOrders = [SELECT AssetId, Asset.NE__ProdId__c, Asset.NE__ProdId__r.XC_Product_Subtype__c FROM WorkOrder WHERE Id =:workOrderId];
        if(!workOrders.isEmpty() && 
           String.isNotBlank(workOrders[0].AssetId) && 
           String.isNotBlank(workOrders[0].Asset.NE__ProdId__c) &&
           (workOrders[0].Asset.NE__ProdId__r.XC_Product_Subtype__c == 'Home Check')) return true;
        return false;
    }

    //START [20220517AL] - NR2551
    public static Boolean checkPermittingForm(String workOrderId) {
        WorkOrder wo = [SELECT Id, XC_WorkTypeCategory__c, XC_ProductSubType__c FROM Workorder WHERE Id =: workorderId];
        if(wo != null && wo.XC_WorkTypeCategory__c == 'Site Inspection' && (wo.XC_ProductSubType__c == 'Solar Thermal' || wo.XC_ProductSubType__c == 'Photovoltaic')) return true;
        else return false;
    }
    //END [20220517AL] - NR2551

    private static String getFieldValue(String apiNameValue,List<Sobject> queryResults){
        //TODO CODE-REVIEW
        
        //START FIX [SR15/07/2021]
        /*String fieldValue = '';
        if(apiNameValue.contains('.')){
            if(queryResults.get(0).getSObject(apiNameValue.split('\\.').get(0)) != null){
                fieldValue = String.valueOf(queryResults.get(0).getSObject(apiNameValue.split('\\.').get(0)).get(apiNameValue.split('\\.').get(1)));
            }
            else fieldValue = null;

        } else {
            fieldValue = String.valueOf(queryResults.get(0).get(apiNameValue));
        }*/
        
        String fieldValue = '';
        String fieldValueTmp = JSON.serialize(queryResults.get(0));
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
        //END FIX [SR15/07/2021]
        return fieldValue;
    }
}