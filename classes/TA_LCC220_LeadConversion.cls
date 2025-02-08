public with sharing class TA_LCC220_LeadConversion {
    public TA_LCC220_LeadConversion() {}

    public class InfoBag {
        @AuraEnabled
        public String                       objectName          {get;set;}
        @AuraEnabled
        public List<FieldStructure>         fieldStructureList  {get;set;}
        @AuraEnabled
        public List<FieldStructure>         addressFieldStructureList  {get;set;}
        @AuraEnabled
        public ModalParams                  modalParams         {get;set;}
        @AuraEnabled
        public String                       error               {get;set;}
        @AuraEnabled
        public String                       lookupId            {get;set;}
        @AuraEnabled
        public String                       lookupObjectName    {get;set;}
        @AuraEnabled
        public String                       lookupObjectRecordTypeDeveloperName   {get;set;}
        @AuraEnabled
        public XC_Address__c                relatedAddress      {get;set;}
        @AuraEnabled
        public Boolean                      newAddress          {get;set;}
    }

    public class FieldStructure {
        @AuraEnabled
        public String                       label               {get;set;}
        @AuraEnabled
        public String                       apiName             {get;set;}
        @AuraEnabled
        public String                       value               {get;set;}
        @AuraEnabled
        public List<Map<String, String>>    availableValues     {get;set;}
        @AuraEnabled
        public String                       type                {get;set;}
        @AuraEnabled
        public Boolean                      required            {get;set;}
        @AuraEnabled
        public Boolean                      readOnly            {get;set;}
        @AuraEnabled
        public Boolean                      isDisplayed         {get;set;}
    }

    public class ModalParams{
        @AuraEnabled
        public String                       title               {get;set;}
        @AuraEnabled
        public String                       description         {get;set;}
        @AuraEnabled
        public String                       imgPath             {get;set;}      

        public ModalParams(){}
    }

    @AuraEnabled
    public static String initialize(String inputParameter, String objectId) {
        TA_UTIL_LogManagement.createLog('TA_LCC220_LeadConversion', 'initialize', inputParameter, 0, inputParameter, null);
        InfoBag infoBag = new InfoBag();
        System.debug('inputParameter: ' + inputParameter);
        System.debug('objectId: ' + objectId);
        try {
            infoBag = initializeModal(infoBag, objectId);
            infoBag.fieldStructureList = new List<FieldStructure>();
            infoBag.addressFieldStructureList = new List<FieldStructure>();

            Map<String, Object> mapParameter;
            List<Object> paramsList = (List<Object>) JSON.deserializeUntyped(inputParameter);
            for(Object configurationObject : paramsList){
                Map<String, Object> currentMapParameter = (Map<String, Object>) configurationObject;
                if(currentMapParameter.containsKey('object') && String.valueOf(currentMapParameter.get('object')) == infoBag.lookupObjectName){
                    mapParameter = currentMapParameter;
                    break;
                }
            }

            System.debug('mapParameter: ' + mapParameter);
            if(mapParameter.containsKey('object')) {
                    String objectName = String.valueOf(mapParameter.get('object'));
                    infoBag.objectName = objectName;
                    SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
                    Map<String, Schema.SObjectField> mapObjectFields = objectType.getDescribe().fields.getMap();

                if(mapParameter.containsKey('fields') && mapParameter.containsKey('addressFields')) {

                    List<Object> objectFieldList = (List<Object>) mapParameter.get('fields');
                    List<Object> objectAddressFieldList = (List<Object>) mapParameter.get('addressFields');

                    String query = 'SELECT ';

                    for(Object objectField : objectFieldList) {
                        Map<String, Object> objectFieldMap = (Map<String, Object>) objectField;
                        query += String.valueOf(objectFieldMap.get('apiName')) + ',';
                    }
                    
                    for(Object objectAddressField : objectAddressFieldList) {
                        Map<String, Object> objectAddressFieldMap = (Map<String, Object>) objectAddressField;
                        query += String.valueOf(objectAddressFieldMap.get('apiName')) + ',';
                    }

                    //query = query.removeEnd(',');
                    query += 'RecordTypeId FROM ' + infoBag.objectName + ' WHERE Id = \'' + infoBag.lookupId + '\'';
                    system.debug('QUERY>>>>>>>>> ' + query);
                    SObject myObjectFromDB = Database.query(query);
                    system.debug('myObjectFromDB>>>>>>>>> ' + myObjectFromDB);
                    String recordTypeId = String.valueOf(myObjectFromDB.get('RecordTypeId'));
                    String recordTypeDeveloperName = [SELECT DeveloperName FROM RecordType WHERE Id =: recordTypeId].DeveloperName;

                    infoBag.newAddress = true;
                    
                    List<XC_Address__c> relatedAddressList = [SELECT Id, XC_AddressCountry__c, XC_City__c, XC_StreetTypeText__c, 
                                                              XC_StreetNumber__c, XC_Floor__c, XC_Door__c, XC_Stair__c, XC_GasCUPS__c, 
                                                              XC_Note__c, XC_Category__c, XC_AddressProvince__c, XC_Address__c, XC_PostalCode__c, 
                                                              XC_Municipality__c, XC_ClarificatorType__c, XC_ClarificatorValue__c, 
                                                              XC_ElectricCUPS__c, XC_Account__c, XC_Lead__c, XC_Region__c
                                                              FROM XC_Address__c 
                                                              WHERE XC_Account__c =: infoBag.lookupId
                                                              OR XC_Lead__c =: infoBag.lookupId];
                    
                    if(!relatedAddressList.isEmpty()){
                        infoBag.relatedAddress = relatedAddressList[0];
                        infoBag.newAddress = false;
                    }

                    for(Object objectField : objectFieldList) {
                        Map<String, Object> objectFieldMap = (Map<String, Object>) objectField;
                        String apiNameField = String.valueOf(objectFieldMap.get('apiName'));
                        if(mapObjectFields.containsKey(apiNameField)) {
                            Schema.SObjectField field = mapObjectFields.get(apiNameField);
                            FieldStructure fieldStructure = new FieldStructure();
                            fieldStructure.label = String.valueOf(field.getDescribe().getLabel());
                            fieldStructure.apiName = apiNameField;
                            fieldStructure.value = (String) myObjectFromDB.get(String.valueOf(apiNameField));
                            fieldStructure.type = String.valueOf(field.getDescribe().getType());
                            fieldStructure.required = Boolean.valueOf(field.getDescribe().isNillable());
                            fieldStructure.readOnly = Boolean.valueOf(field.getDescribe().isUpdateable());
                            if(fieldStructure.type == 'PICKLIST') {
                                List<Schema.PicklistEntry> picklistValueList = field.getDescribe().getPicklistValues();
                                fieldStructure.availableValues = new List<Map<String, String>>();
                                fieldStructure.availableValues.add(new Map<String, String> {
                                    'value' => '',
                                    'label' => 'None'
                                });
                                for(Schema.PicklistEntry picklistValue : picklistValueList) {
                                    fieldStructure.availableValues.add(new Map<String, String> {
                                        'value' => picklistValue.getValue(),
                                        'label' => picklistValue.getLabel()
                                    });
                                }
                            }
                            fieldStructure.isDisplayed = Boolean.valueOf(objectFieldMap.get('isDisplayed'));
                            infoBag.fieldStructureList.add(fieldStructure);
                            infoBag.lookupObjectRecordTypeDeveloperName = recordTypeDeveloperName;
                        }
                    }
                    
                    for(Object objectField : objectAddressFieldList) {
                        Map<String, Object> objectFieldMap = (Map<String, Object>) objectField;
                        String apiNameField = String.valueOf(objectFieldMap.get('apiName'));
                        if(mapObjectFields.containsKey(apiNameField)) {
                            Schema.SObjectField field = mapObjectFields.get(apiNameField);
                            FieldStructure addressFieldStructure = new FieldStructure();
                            addressFieldStructure.label = String.valueOf(field.getDescribe().getLabel());
                            addressFieldStructure.apiName = apiNameField;
                            addressFieldStructure.value = (String) myObjectFromDB.get(String.valueOf(apiNameField));
                            addressFieldStructure.type = String.valueOf(field.getDescribe().getType());
                            addressFieldStructure.required = Boolean.valueOf(field.getDescribe().isNillable());
                            addressFieldStructure.readOnly = Boolean.valueOf(field.getDescribe().isUpdateable());
                            if(addressFieldStructure.type == 'PICKLIST') {
                                List<Schema.PicklistEntry> picklistValueList = field.getDescribe().getPicklistValues();
                                addressFieldStructure.availableValues = new List<Map<String, String>>();
                                addressFieldStructure.availableValues.add(new Map<String, String> {
                                    'value' => '',
                                    'label' => 'None'
                                });
                                for(Schema.PicklistEntry picklistValue : picklistValueList) {
                                    addressFieldStructure.availableValues.add(new Map<String, String> {
                                        'value' => picklistValue.getValue(),
                                        'label' => picklistValue.getLabel()
                                    });
                                }
                            }
                            addressFieldStructure.isDisplayed = Boolean.valueOf(objectFieldMap.get('isDisplayed'));
                            infoBag.addressFieldStructureList.add(addressFieldStructure);
                        }
                    }
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC220_LeadConversion] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC220_LeadConversion', 'initialize', errorMessage, 0, errorMessage, null);
            infoBag.error = errorMessage;
        }
        System.debug('JSON.serialize(infoBag): ' + JSON.serialize(infoBag));
        return JSON.serialize(infoBag);
    }

    private static InfoBag initializeModal(InfoBag infoBag, String workOrderId){

        System.debug('workOrderId initializeModal: ' + workOrderId);
        
        ModalParams modalParamsToReturn = new ModalParams();

        if(String.isNotBlank(workOrderId)){

            WorkOrder currentWorkOrder;
            List<WorkOrder> currentWorkOrderList = [SELECT AccountId, XC_Lead__c, TA_Phase__c FROM WorkOrder WHERE Id =: workOrderId];
            System.debug('currentWorkOrderList initializeModal: ' + currentWorkOrderList);

            if(!currentWorkOrderList.isEmpty()){

                for(WorkOrder workOrder : currentWorkOrderList){
                    currentWorkOrder = workOrder;
                }

                modalParamsToReturn.title = System.Label.TA_Check_Your_Data;
                modalParamsToReturn.imgPath = '/imgs/start-service.svg';

                if(String.isBlank(currentWorkOrder.AccountId)){
                    infoBag.lookupObjectName = 'Lead';
                    modalParamsToReturn.description = System.Label.TA_You_Are_A_Lead;
                    infoBag.lookupId = currentWorkOrder.XC_Lead__c;
                    
                } else {
                    infoBag.lookupObjectName = 'Account';
                    modalParamsToReturn.description = System.Label.TA_You_Are_An_Account;
                    infoBag.lookupId = currentWorkOrder.AccountId;
                }

                System.debug('modalParamsToReturn initializeModal: ' + modalParamsToReturn);
                infoBag.modalParams = modalParamsToReturn;
                return infoBag;
            }  
        } 
        infoBag.modalParams = modalParamsToReturn;
        return infoBag;
    }

    /*@AuraEnabled
    public static void manageConfirm(String serializedInfoBag, Boolean hasChanged){

        system.debug('@@>> serializedInfoBag >>> ' + serializedInfoBag);
        InfoBag infoBag = (InfoBag) JSON.deserialize(serializedInfoBag, InfoBag.class);

        try{

            sObject dynamicObjectToSubmit = Schema.getGlobalDescribe().get(infoBag.lookupObjectName).newSObject();
            
            dynamicObjectToSubmit.Id = infoBag.lookupId;

            for(FieldStructure fieldWrapper : infoBag.fieldStructureList) {
                dynamicObjectToSubmit.put(fieldWrapper.apiName, fieldWrapper.value);
            }

            if(hasChanged){    
                update dynamicObjectToSubmit;
            }

            if(infoBag.lookupObjectName == 'Lead'){

                Map<String, String> params = new Map<String,String>{
                    'LeadID' => infoBag.lookupId
                };

                Map<String,String> header = new Map<String,String>{
                    'ClientSystem' => 'XInstaller'
                };

                XC_REST_Lead_W.WrapperLeadResponse responseWrapper = XC_REST_Lead_S.getLeadWrapper(params, header); 
                XC_UTIL_Lead.LeadRESTWrapper leadWrapperForLeadConversion = responseWrapper.Lead;

                //Chiamata alla Lead Conversion
                XC_REST_Lead_T.manageConvertLead(leadWrapperForLeadConversion, responseWrapper);

            }            
            
        } catch(Exception e){
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC220_LeadConversion] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC220_LeadConversion', 'manageConfirm', errorMessage, 0, errorMessage, null);
            infoBag.error = errorMessage;
        }
        
    }*/
    
}