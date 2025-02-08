public without sharing class TA_LCC199_ButtonSection {

    public class InfoBag {
        @AuraEnabled
        public WorkOrder workOrder {get;set;}
        @AuraEnabled
        public List<ButtonWrapper> listButton {get;set;}
        @AuraEnabled
        public Integer numberOfButtonsPerPage {get;set;}
        @AuraEnabled
        public List<Map<String, String>> closeReasons {get; set;}
    }

    //JS COORDINATE START
    
    public class ParamWrapper {
        @AuraEnabled
        public XC_REST_WorkOrder_W.Wrapper WorkOrder {get;set;}
        @AuraEnabled
        public CoordinatesWrapper Coordinates {get;set;}
    }

    public class CoordinatesField {
        @AuraEnabled
        public String apiName {get;set;}
        @AuraEnabled
        public Decimal value {get;set;}
    }

    public class CoordinatesWrapper {
        @AuraEnabled
        public CoordinatesField Latitude {get;set;}
        @AuraEnabled
        public CoordinatesField Longitude {get;set;}
        @AuraEnabled
        public CoordinatesField Accuracy {get;set;}
    }
    //JS COORDINATE END

    public class ButtonWrapper {
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String developerName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Integer index {get;set;}
        @AuraEnabled
        public String action {get;set;}
        @AuraEnabled
        public String nextPhase {get;set;}
        @AuraEnabled
        public Boolean updateNextPhase {get;set;}
        @AuraEnabled
        public Boolean updateFields {get; set;}
        @AuraEnabled
        public Boolean validation {get; set;}
        @AuraEnabled
        public List<ButtonWrapper> dependencyButtons {get;set;}

        public ButtonWrapper() {}
    }

    public class ApexActionWrapper {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Object parameters {get;set;}
        @AuraEnabled
        public Boolean runCallBack {get;set;}
        @AuraEnabled
        public String callBack {get;set;}
        @AuraEnabled
        public List<Object> callBackParams {get;set;}
        @AuraEnabled
        public String error {get;set;}

        public ApexActionWrapper() {}
    }

    @AuraEnabled
    public static String setButton(Id workOrderId, Integer screenWidth) {
        InfoBag infoBag = new InfoBag();
        try {
            infoBag.listButton = new List<ButtonWrapper>();
            List<TA_ScreenConfiguration__mdt> screenConfigurationList = [SELECT TA_NumberButtonsPerPage__c
                                                                        FROM TA_ScreenConfiguration__mdt
                                                                        WHERE TA_MinWidthScreen__c <= :screenWidth
                                                                            AND TA_MaxWidthScreen__c >= :screenWidth];

            infoBag.numberOfButtonsPerPage = 0;
            if(screenConfigurationList.size() > 0) 
            {
                infoBag.numberOfButtonsPerPage = Integer.valueOf(screenConfigurationList[0].TA_NumberButtonsPerPage__c);
            }

            Schema.DescribeFieldResult saReasonCannotComplete = ServiceAppointment.XC_Reason_Cannot_Complete__c.getDescribe();
            List<Schema.PicklistEntry> picklistReasonCannotComplete = saReasonCannotComplete.getPicklistValues();
            List<Map<String, String>> closeReasons = new List<Map<String, String>>(); 

            for(Schema.PicklistEntry reasonCannotComplete : picklistReasonCannotComplete) {
                Map<String, String> tmpMap = new Map<String, String>();
                tmpMap.put('label', reasonCannotComplete.getLabel());
                tmpMap.put('value', reasonCannotComplete.getValue());
                closeReasons.add(tmpMap);
            }
            infoBag.closeReasons = closeReasons;

            String currentUserPermissionSetName = 'dummy';
            Id currentUserProfileId = UserInfo.getUserId();
            List<PermissionSetAssignment> currentUserPermissionSetList = [SELECT PermissionSet.Name
                                                                            FROM PermissionSetAssignment
                                                                            WHERE AssigneeId =: currentUserProfileId
                                                                                AND PermissionSet.Description = 'TA_Configuration_Language'];

            if(!currentUserPermissionSetList.isEmpty()) {
                for(PermissionSetAssignment currentPermissionSet : currentUserPermissionSetList) {
                    currentUserPermissionSetName = currentPermissionSet.PermissionSet.Name;
                }
            }

            List<WorkOrder> workOrderList = [SELECT Id, TA_Phase__c, XC_WorkTypeCategory__c
                                                FROM WorkOrder
                                                WHERE Id =: workOrderId];
            
            if(workOrderList.size() > 0) {
                infoBag.workOrder = workOrderList[0];

                System.debug('currentUserPermissionSetName >>> ' + currentUserPermissionSetName); 
                System.debug('infoBag.workOrder.XC_WorkTypeCategory__c >>> ' + infoBag.workOrder.XC_WorkTypeCategory__c); 
                System.debug('infoBag.workOrder.TA_Phase__c >>> ' + infoBag.workOrder.TA_Phase__c); 
                System.debug('layoutMatrixConfigList >>> ' + [SELECT Id, TA_ConfigurationSet__c, TA_WorkTypeCategory__c, TA_Phase__r.TA_DeveloperName__c FROM TA_Layout_Matrix_Configuration__c]);

                List<TA_Layout_Matrix_Configuration__c> layoutMatrixConfigList = [SELECT Id,
                                                                                        TA_Phase__c,
                                                                                        TA_Phase__r.Name,
                                                                                        TA_Phase__r.TA_DeveloperName__c,
                                                                                        TA_Action__c,
                                                                                        TA_Action__r.Name,
                                                                                        TA_Action__r.TA_DeveloperName__c,
                                                                                        TA_Action__r.TA_Type__c,
                                                                                        TA_Update_Fields__c,
                                                                                        TA_Validation__c,
                                                                                        TA_IndexAction__c,
                                                                                        TA_Methods__c,
                                                                                        TA_NextPhase__c,
                                                                                        TA_UpdateNextPhase__c,
                                                                                        TA_ParentMatrixConfiguration__c
                                                                                    FROM TA_Layout_Matrix_Configuration__c
                                                                                    WHERE TA_Active__c = true
                                                                                        AND TA_Action__c != null
                                                                                        AND TA_ConfigurationSet__c = :currentUserPermissionSetName
                                                                                        AND TA_WorkTypeCategory__c = :infoBag.workOrder.XC_WorkTypeCategory__c
                                                                                        AND TA_Phase__r.TA_DeveloperName__c = :infoBag.workOrder.TA_Phase__c
                                                                                    ORDER BY TA_IndexAction__c];
                //START FIX - [#20210226AL] - CustomMetadata Labels Management
                List<String> customLabels = new List<String>();
                for(TA_Layout_Matrix_Configuration__c layoutMatrixConfig : layoutMatrixConfigList) {
                    customLabels.add(layoutMatrixConfig.TA_Action__r.Name);
                }

                Map<String, String> masterLabelToLabelMap = new Map<String, String>();
                List<TA_CustomLabel__mdt> allCustomLabels = [SELECT Id,
                                                                 TA_Label__c,
                                                                 MasterLabel,
                                                                 TA_Language__c
                                                          FROM TA_CustomLabel__mdt
                                                          WHERE (TA_Language__c = :UserInfo.getLanguage() OR TA_Language__c = 'en_US')
                                                          AND MasterLabel IN :customLabels];
  
                for(TA_CustomLabel__mdt customLabel : allCustomLabels) {
                    if(customLabel.TA_Language__c == UserInfo.getLanguage() ||
                    (customLabel.TA_Language__c == 'en_US' && !masterLabelToLabelMap.containsKey(customLabel.MasterLabel))) {
                        masterLabelToLabelMap.put(customLabel.MasterLabel, customLabel.TA_Label__c);
                    }
                }
                //END FIX - [#20210226AL] - CustomMetadata Labels Management

                List<ButtonWrapper> listButtonWrapper = new List<ButtonWrapper>();
                Map<Id, List<ButtonWrapper>> mapDependencyButton = new Map<Id, List<ButtonWrapper>>();

                for(TA_Layout_Matrix_Configuration__c layoutMatrixConfig : layoutMatrixConfigList) {
                    ButtonWrapper buttonWrapper = new ButtonWrapper();
                    buttonWrapper.id = layoutMatrixConfig.Id;
                    
                    //START FIX - [#20210226AL] - CustomMetadata Labels Management  
                    //buttonWrapper.name = layoutMatrixConfig.TA_Action__r.Name;
                    buttonWrapper.name = masterLabelToLabelMap.get(layoutMatrixConfig.TA_Action__r.Name);
                    //END FIX - [#20210226AL] - CustomMetadata Labels Management

                    buttonWrapper.developerName = layoutMatrixConfig.TA_Action__r.TA_DeveloperName__c;
                    buttonWrapper.type = layoutMatrixConfig.TA_Action__r.TA_Type__c;
                    buttonWrapper.index = Integer.valueOf(layoutMatrixConfig.TA_IndexAction__c);
                    buttonWrapper.action = layoutMatrixConfig.TA_Methods__c;
                    buttonWrapper.nextPhase = layoutMatrixConfig.TA_NextPhase__c;
                    buttonWrapper.updateNextPhase = layoutMatrixConfig.TA_UpdateNextPhase__c;
                    buttonWrapper.updateFields = layoutMatrixConfig.TA_Update_Fields__c;
                    buttonWrapper.validation = layoutMatrixConfig.TA_Validation__c;
                    if(layoutMatrixConfig.TA_ParentMatrixConfiguration__c == null) {
                        listButtonWrapper.add(buttonWrapper);
                    } else {
                        List<ButtonWrapper> listDepBtn = new List<ButtonWrapper>();
                        if(mapDependencyButton.containsKey(layoutMatrixConfig.TA_ParentMatrixConfiguration__c)) {
                            listDepBtn = mapDependencyButton.get(layoutMatrixConfig.TA_ParentMatrixConfiguration__c);
                        }
                        listDepBtn.add(buttonWrapper);
                        mapDependencyButton.put(layoutMatrixConfig.TA_ParentMatrixConfiguration__c, listDepBtn);
                    }
                }

                for(ButtonWrapper buttonWrapper : listButtonWrapper) {
                    if(mapDependencyButton.containsKey(buttonWrapper.id)) {
                        buttonWrapper.dependencyButtons = mapDependencyButton.get(buttonWrapper.id);
                    }

                    infoBag.listButton.add(buttonWrapper);
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'setButton', errorMessage, 0, errorMessage, null);
        }
        System.debug('infoBag >> ' + infoBag);
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static List<ApexActionWrapper> manageApexAction(Id workOrderId, String apexActionSerialized, String nextPhase, Boolean updateNextPhase) {
        List<ApexActionWrapper> apexActionWrapperList = new List<ApexActionWrapper>();
        try {
            WorkOrder currentWorkOrder = new WorkOrder(Id = workOrderId);
            Boolean updateWorkOrder = true;

            if(apexActionSerialized != null) {
                List<Object> mapApexActions = (List<Object>) JSON.deserializeUntyped(apexActionSerialized);

                for(Object mapApexAction : mapApexActions) {
                    Map<String, Object> tmpMap = (Map<String, Object>) mapApexAction;
                    ApexActionWrapper apexActionWrap = new ApexActionWrapper();

                    apexActionWrap.name = (String) tmpMap.get('name');
                    apexActionWrap.parameters = tmpMap.get('parameters');
                    apexActionWrap.runCallBack = (Boolean) tmpMap.get('runCallBack');
                    apexActionWrap.callBack = (String) tmpMap.get('callBack');
                    apexActionWrap.callBackParams = (List<Object>) tmpMap.get('callBackParams');
                    apexActionWrap.error = (String) tmpMap.get('error');

                    apexActionWrapperList.add(apexActionWrap);
                }
            }

            for(ApexActionWrapper apexActionWrapper : apexActionWrapperList) {
                switch on apexActionWrapper.name {
                    /* when 'redirectToFLS' {
                        apexActionWrapper = redirectToFLS(workOrderId, apexActionWrapper);
                        apexActionWrapper.runCallBack = true;
                        apexActionWrapper.callBack = 'redirectToFLSCallback';
                    } */
                    when 'completeWorkOrder' {
                        apexActionWrapper = completeAllWoli(apexActionWrapper, workOrderId);
                        apexActionWrapper = updateWorkOrder(apexActionWrapper);
                        apexActionWrapper.runCallBack = true;
                        apexActionWrapper.callBack = 'completeWorkOrderCallback';
                    }
                    //START FIX [20220308AL] - NR70
                    /*when 'completeWorkOrderGPS' {
                        apexActionWrapper = completeAllWoli(apexActionWrapper, workOrderId);
                        apexActionWrapper = updateWorkOrder_GPS(apexActionWrapper);
                        apexActionWrapper.runCallBack = true;
                        apexActionWrapper.callBack = 'completeWorkOrderCallback';
                    }*/
                    //END FIX [20220308AL] - NR70
                    when 'updateFields' {
                        apexActionWrapper = updateFields(workOrderId, apexActionWrapper);
                        apexActionWrapper.runCallBack = true;
                        apexActionWrapper.callBack = 'updateFieldsCallback';
                    }
                    when 'leadConversion' {
                        apexActionWrapper = leadConversion(apexActionWrapper);
                        apexActionWrapper.runCallBack = false;
                    }
                    when 'customerInteraction' {
                        apexActionWrapper = customerInteraction(apexActionWrapper);
                        apexActionWrapper.runCallBack = false;
                    }
                    when 'updateWorkOrder' {
                        apexActionWrapper = updateWorkOrder(apexActionWrapper);
                        apexActionWrapper.runCallBack = false;
                    }
                    when 'manageProvisioning' {
                        apexActionWrapper = manageProvisioning(apexActionWrapper);
                        apexActionWrapper.runCallBack = false;
                    }
                    when 'createNewOppty' {
                        apexActionWrapper = createNewOppty(apexActionWrapper);
                        apexActionWrapper.runCallBack = true;
                        apexActionWrapper.callBack = 'createNewOpptyCallback';
                    }
                    when 'updateWorkOrderTAParameters' {
                        apexActionWrapper = updateWorkOrderTAParameters(apexActionWrapper);
                        apexActionWrapper.runCallBack = false;
                    }
                    when 'fillAddressOnOrder' {
                        apexActionWrapper = fillAddressOnOrder(workOrderId, apexActionWrapper);
                        apexActionWrapper.runCallBack = false;
                    }
                    when 'updateWorkOrder_GPS' {
                        apexActionWrapper = updateWorkOrder_GPS(apexActionWrapper);
                        apexActionWrapper.runCallBack = false;
                    }
                    //START ENCXRM-151 HSEQ BGO
                    // when 'validateQualityCheckStatus' {
                    //     apexActionWrapper.runCallBack = true;
                    //     apexActionWrapper.callBack = 'redirectToHomepageCallback';
                    //     apexActionWrapper = validateQualityCheckStatus(workOrderId, apexActionWrapper);
                    //     if(apexActionWrapper.error == null){
                    //         apexActionWrapper.runCallBack = true;
                    //         apexActionWrapper.callBack = 'redirectToHomepageCallback';
                    //     } else {
                    //         apexActionWrapper.runCallBack = false;
                    //     }
                    // }
                    //END ENCXRM-151 HSEQ BGO
                    when else {

                    }
                }

                //START - [20220609AL] - NR2331 - Check validation rule on suspension
                if(String.isNotBlank(apexActionWrapper.error) && apexActionWrapper.error.contains('Partner Community')) { 
                    apexActionWrapper.error = null;
                }
                //END - [20220609AL] - NR2331 - Check validation rule on suspension
                
                if(String.isNotBlank(apexActionWrapper.error)) {
                    updateWorkOrder = false;
                }
            }

            if(updateNextPhase) {
                currentWorkOrder.TA_Phase__c = nextPhase;
            }

            if(updateWorkOrder) {
                update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = true);
                update currentWorkOrder;
                update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = false);
            }

        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'manageApexAction', errorMessage, 0, errorMessage, null);
        }
        System.debug('apexActionWrapperList >> ' + apexActionWrapperList);
        return apexActionWrapperList;
    }

    /* private static ApexActionWrapper redirectToFLS(Id workOrderId, ApexActionWrapper apexActionWrapper) {
        String linkRedirect;
        apexActionWrapper.callBackParams = new List<Object>();
        try {
            linkRedirect = 'com.salesforce.fieldservice://v1/sObject/'+ workOrderId;
            apexActionWrapper.callBackParams.add(linkRedirect);
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'redirectToFLS', errorMessage, 0, errorMessage, null);
            apexActionWrapper.error = errorMessage;
        }
        return apexActionWrapper;
    } */

    private static ApexActionWrapper updateFields(Id workOrderId, ApexActionWrapper apexActionWrapper) {
        try {
            if(String.isNotBlank(workOrderId) && apexActionWrapper != null) {
                List<Object> objects = (List<Object>) apexActionWrapper.parameters;
                List<SObject> sObjList = new List<SObject>();

                for(Object tmpObj : objects) {
                    Map<String, Object> tmpMap = (Map<String, Object>) tmpObj;
                    String objectName = (String) tmpMap.get('objectName');
                    List<Object> fields = (List<Object>) tmpMap.get('fields');
                    List<TA_LCC202_DynamicLayout.FieldWrapper> fieldWraps = new List<TA_LCC202_DynamicLayout.FieldWrapper>();
                    
                    for(Object field : fields) {
                        Map<String, Object> mapField = (Map<String, Object>) field;
                        TA_LCC202_DynamicLayout.FieldWrapper fieldWrap = new TA_LCC202_DynamicLayout.FieldWrapper();

                        fieldWrap.queryApiName = (String) mapField.get('apiName');
                        fieldWrap.value = mapField.get('value') instanceof Boolean ? JSON.serialize(mapField.get('value')) : (String) mapField.get('value');
                        fieldWrap.type = (String) mapField.get('type');
                                           
                        if(fieldWrap.queryApiName.contains('.')) {
                            fieldWrap.objectName = fieldWrap.queryApiName.left(fieldWrap.queryApiName.lastIndexOf('.'));
                            fieldWrap.apiName = fieldWrap.queryApiName.substring(fieldWrap.queryApiName.lastIndexOf('.')+1); 
                        } else {
                            fieldWrap.objectName = objectName;
                            fieldWrap.apiName = fieldWrap.queryApiName;
                        }

                        Boolean fieldAlreadyExist = false;
                        for(TA_LCC202_DynamicLayout.FieldWrapper fieldLoop : fieldWraps) {
                            if(fieldWrap.apiName == fieldLoop.apiName && fieldWrap.objectName == fieldLoop.objectName) fieldAlreadyExist = true;
                        }
                        if(!fieldAlreadyExist) fieldWraps.add(fieldWrap);
                    }

                    if(String.isNotBlank(objectName) && !fieldWraps.isEmpty()) {
                        List<String> apiNameFields = new List<String>();
                        Set<String> apiNameObjects = new Set<String>();

                        for(TA_LCC202_DynamicLayout.FieldWrapper field : fieldWraps) {
                            apiNameFields.add(field.queryApiName);
                            apiNameObjects.add(field.objectName);
                        }

                        String whereCondition = '';
                        if(objectName == 'WorkOrder') {
                            whereCondition = 'Id =: workOrderId';
                        } else {
                            String whereConditionMap = (String) tmpMap.get('whereCondition');
                            if(String.isBlank(whereConditionMap)) {
                                String objectLookup = (String) tmpMap.get('objectLookup');
                                String queryStringRecordId = 'SELECT ' + objectLookup + ' FROM WorkOrder WHERE Id = :workOrderId';
                                List<SObject> queryRecordIdResults = Database.query(queryStringRecordId);
                                if(!queryRecordIdResults.isEmpty()) whereCondition = 'Id = \'' + (String)queryRecordIdResults.get(0).get(objectLookup) + '\'';
                            } else whereCondition = whereConditionMap;
                        }

                        String queryString = 'SELECT ' + String.join(apiNameFields, ',') +
                                             ' FROM ' + objectName +
                                             ' WHERE ' + whereCondition +
                                             ' LIMIT 1';

                        System.debug('queryString: ' + queryString);
                        SObject sObj = Database.query(queryString);

                        if(sObj != null) {
                            for(String apiNameObject : apiNameObjects) {

                                SObject sObjLoop = sObj;
                                List<String> apiNameObjectSplitted = apiNameObject.split('\\.');
                                for(String apiNameObj : apiNameObjectSplitted){
                                    if(apiNameObj != objectName) {
                                        sObjLoop = sObjLoop.getSObject(apiNameObj);
                                    } 
                                }

                                for(TA_LCC202_DynamicLayout.FieldWrapper field : fieldWraps) {
                                    if(field.objectName == apiNameObject) {
                                        if(field.type == 'BOOLEAN') {
                                            sObjLoop.put(field.apiName, Boolean.valueOf(field.value));
                                        } else if(field.type == 'date'){                                            
                                            sObjLoop.put(field.apiName, Date.valueOf(field.value));
                                        } else if(field.type == 'currency' || field.type == 'double'){                                            
                                            sObjLoop.put(field.apiName, field.value == ''? null : Decimal.valueOf(field.value));
                                        } else if(field.type == 'datetime'){
                                            sObjLoop.put(field.apiName, field.value == ''? null : DateTime.valueOfGmt(field.value.replace('T', ' ')));
                                        } else {
                                            sObjLoop.put(field.apiName, field.value);
                                        }
                                    }
                                }

                                Boolean recordAlreadyExist = false;
                                for(SObject objectLoop : sObjList) {
                                    if(sObjLoop.get('Id') == objectLoop.get('Id')) recordAlreadyExist = true;
                                }
                                if(!recordAlreadyExist) sObjList.add(sObjLoop);
                            }
                        }
                    }
                }

                if(!sObjList.isEmpty()) {
                    TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateFields1', String.valueOf(sObjList), 0, String.valueOf(sObjList), null);
                    
                    //START [20220701AL] - NR2330 - Suspension flow
                    List<SObject> newObjList = new List<SObject>();
                    newObjList.addAll(sObjList);

                    SObject servApp = null; 
                    
                    Boolean servAppStatusReasonFound = false;
                    for(Object tmpObj : objects) {
                        Map<String, Object> tmpMap = (Map<String, Object>) tmpObj;
                        String objectName = (String) tmpMap.get('objectName');
                    
                        if(objectName == 'ServiceAppointment') {
                            List<Object> fields = (List<Object>) tmpMap.get('fields');
                            for(Integer i = 0; i < fields.size(); i++) {
                                Map<String, Object> mapField = (Map<String, Object>) fields[i];
                                if((String) mapField.get('apiName') == 'XC_ReasonforSuspension__c') {
                                    servAppStatusReasonFound = true;
                                    break;
                                }
                            }
                        }
                    }
                    
                    if(servAppStatusReasonFound) {
                        for(Integer i = 0; i < sObjList.size(); i++) {
                            if(sObjList[i].getSObjectType().getDescribe().getName() == 'ServiceAppointment' && sObjList[i].get('XC_ReasonforSuspension__c') == 'Richiesta Preventivo') {
                                servApp = sObjList[i];
                                sObjList.remove(i);
                                break;
                            }
                        }
                    }
                    //END [20220701AL] - NR2330 - Suspension flow

                    update sObjList;

                    //START [20220701AL] - NR2330 - Suspension flow
                    if(servApp != null) update servApp; 
                    apexActionWrapper.callBackParams = afterUpdateFieldsCalls(newObjList);
                    //apexActionWrapper.callBackParams = afterUpdateFieldsCalls(objList);
                    //END [20220701AL] - NR2330 - Suspension flow
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateFields', errorMessage, 0, errorMessage, null);
            apexActionWrapper.error = errorMessage;
        }
        return apexActionWrapper;
    }

    private static List<Object> afterUpdateFieldsCalls(List<SObject> sObjList) {
        List<Object> callBackParams = new List<Object>();
        Boolean checkSerialNumber = false;
        String assetId;

        for(SObject sObj : sObjList) {
            /*if(sObj.getSObjectType() == Schema.Asset.getSObjectType() && sObj.get('SerialNumber') != null) {
                checkSerialNumber = true;
                assetId = String.valueOf(sObj.get('Id'));
            }*/
        }

        //if(checkSerialNumber) callBackParams.add(checkSerialNumber(assetId));
        return callBackParams;
    }

    private static ApexActionWrapper leadConversion(ApexActionWrapper apexActionWrapper) {
        if(apexActionWrapper != null) {
            String serializedInfoBag;
            Boolean hasChanged;
            String serializedAddress;

            List<Object> inputParams = (List<Object>) apexActionWrapper.parameters;
            Map<String, Object> parametersMap = new Map<String, Object>();

            for(Object tmpObj : inputParams) {
                Map<String, Object> tmpMap = (Map<String, Object>) tmpObj;

                if(tmpMap.containsKey('serializedInfoBag')) {
                    serializedInfoBag = (String) tmpMap.get('serializedInfoBag');
                }

                if(tmpMap.containsKey('hasChanged')) {
                    hasChanged = (Boolean) tmpMap.get('hasChanged');
                }

                if(tmpMap.containsKey('serializedAddress')) {
                    serializedAddress = (String) tmpMap.get('serializedAddress');
                }
            }

            TA_LCC220_LeadConversion.InfoBag infoBag = (TA_LCC220_LeadConversion.InfoBag) JSON.deserialize(serializedInfoBag, TA_LCC220_LeadConversion.InfoBag.class);

            try {
                if(infoBag.newAddress) {
                    Boolean savedAddress = XC_LCC_Address.saveAddressApex(serializedAddress, infoBag.lookupId);
                } else {
                    Map<String,Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(serializedAddress);
                    system.debug('@@>> serializedAddress >>> ' + serializedAddress);
                    system.debug('@@>> infoBag.relatedAddress.Id >>> ' + infoBag.relatedAddress.Id);

                    XC_Address__c addressToUpdate = new XC_Address__c ();
                    addressToUpdate.Id = infoBag.relatedAddress.Id;
                    addressToUpdate.XC_AddressCountry__c = (String) fieldMap.get('country');
                    addressToUpdate.XC_Address__c = (String) fieldMap.get('address');
                    addressToUpdate.XC_StreetNumber__c = (String) fieldMap.get('streetNumber');
                    addressToUpdate.XC_Door__c = (String) fieldMap.get('door');
                    addressToUpdate.XC_Stair__c = (String) fieldMap.get('stair');
                    addressToUpdate.XC_Floor__c = (String) fieldMap.get('floor');
                    addressToUpdate.XC_City__c = (String) fieldMap.get('city');
                    addressToUpdate.XC_AddressProvince__c = (String) fieldMap.get('province');
                    addressToUpdate.XC_Category__c = (String) fieldMap.get('category');
                    addressToUpdate.XC_Municipality__c = (String) fieldMap.get('municipality');
                    addressToUpdate.XC_StreetTypeText__c = (String) fieldMap.get('streetTypeText');
                    addressToUpdate.XC_GasCUPS__c = (String) fieldMap.get('gas');
                    addressToUpdate.XC_ElectricCUPS__c = (String) fieldMap.get('electric');
                    addressToUpdate.XC_Region__c = (String) fieldMap.get('region');
                    addressToUpdate.XC_ClarificatorType__c = (String) fieldMap.get('clarifType');
                    addressToUpdate.XC_ClarificatorValue__c = (String) fieldMap.get('clarifValue');
                    addressToUpdate.XC_Note__c = (String) fieldMap.get('note');

                    update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = true);
                    update addressToUpdate;
                    update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = false);
                }

                sObject dynamicObjectToSubmit = Schema.getGlobalDescribe().get(infoBag.lookupObjectName).newSObject();
                system.debug('@@>> dynamicObjectToSubmit >>> ' + dynamicObjectToSubmit);

                dynamicObjectToSubmit.Id = infoBag.lookupId;

                for(TA_LCC220_LeadConversion.FieldStructure fieldWrapper : infoBag.fieldStructureList) {
                    system.debug('@@>> fieldWrapper.apiName >>> ' + fieldWrapper.apiName);
                    system.debug('@@>> fieldWrapper.value >>> ' + fieldWrapper.value);
                    if(fieldWrapper.apiName == 'XC_BirthDate__c' && String.isNotBlank(fieldWrapper.value)){
                        dynamicObjectToSubmit.put(fieldWrapper.apiName, Date.valueOf(fieldWrapper.value));
                    } else {
                        dynamicObjectToSubmit.put(fieldWrapper.apiName, fieldWrapper.value);
                    }
                }

                update dynamicObjectToSubmit;

                if(infoBag.lookupObjectName == 'Lead'){
                    Map<String, String> params = new Map<String,String>{'LeadID' => infoBag.lookupId};
                    Map<String,String> header = new Map<String,String>{'ClientSystem' => 'XInstaller'};

                    XC_REST_Lead_W.WrapperLeadResponse responseWrapper = XC_REST_Lead_S.getLeadWrapper(params, header);
                    XC_UTIL_Lead.LeadRESTWrapper leadWrapperForLeadConversion = responseWrapper.Lead;

                    XC_REST_Lead_T.manageConvertLead(leadWrapperForLeadConversion, responseWrapper);
                    if(responseWrapper.Result.ErrorCode == '500')apexActionWrapper.error = responseWrapper.Result.Message;
                }

            } catch(Exception e){
                String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
                System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
                TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'leadConversion', errorMessage, 0, errorMessage, null);
                apexActionWrapper.error = errorMessage;
            }
        }
        return apexActionWrapper;
    }

    private static ApexActionWrapper customerInteraction(ApexActionWrapper apexActionWrapper) {
        try {
            String msgRequest = (String) apexActionWrapper.parameters;
            XC_REST_CustomerInteraction_W.WrapperRequest wrReq = (XC_REST_CustomerInteraction_W.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_CustomerInteraction_W.WrapperRequest.class);
            XC_REST_CustomerInteraction_W.WrapperResponse wrResp = new XC_REST_CustomerInteraction_W.WrapperResponse();

            XC_REST_CustomerInteraction_UU.manageInsert(wrReq, wrResp);
            if(wrResp.Result.ErrorCode != '0') apexActionWrapper.error = wrResp.Result.logError;

        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'customerInteraction', errorMessage, 0, errorMessage, null);
            apexActionWrapper.error = errorMessage;
        }
        return apexActionWrapper;
    }

    private static ApexActionWrapper updateWorkOrder(ApexActionWrapper apexActionWrapper) {
        try {
            System.debug('@@>> apexActionWrapper : ' + apexActionWrapper.parameters);
            String msgRequest = (String) apexActionWrapper.parameters;
            System.debug('Parameters : ' + apexActionWrapper.parameters);
            XC_REST_WorkOrder_W.Wrapper wrReq = (XC_REST_WorkOrder_W.Wrapper) JSON.deserialize(msgRequest, XC_REST_WorkOrder_W.Wrapper.class);
            XC_REST_WorkOrder_W.Wrapper wrResp = new XC_REST_WorkOrder_W.Wrapper();

            System.debug('wrReq >>> ' + wrReq);

            wrReq.WorkOrder.WorkType = XC_UTIL_WorkType.getWorkTypeByName(wrReq.WorkOrder.WorkType);
            WorkOrder woToMod = XC_REST_WorkOrder_UU.getWorkOrderForUpdate(wrReq);
            System.debug('woToMod : ' + woToMod);
            workOrder resWo = XC_REST_WorkOrder_U.createWorkOrder(wrReq.WorkOrder, woToMod);
            System.debug('resWo : ' + resWo);
            resWo.XC_UpdatedByApp__c = true;
            resWo.TA_UpdatedByApp__c = true;
            if(resWo.Status == 'Completed') resWo.TA_CompletedByApp__c = true;

            //START FIX COORDINATE 16062022 FD - ENXCRM-213 
            System.debug('@@>> msgRequest >>> ' + msgRequest);
            ParamWrapper paramWrapper = (ParamWrapper) JSON.deserialize(msgRequest, ParamWrapper.class);
            System.debug('@@>> paramWrapper >>> ' + paramWrapper);
            CoordinatesWrapper coordinatesWrapper = (CoordinatesWrapper) paramWrapper.Coordinates;
            system.debug('@@>> coordinatesWrapper >>> ' + coordinatesWrapper);
            if(coordinatesWrapper != null){
                CoordinatesField latitude = (CoordinatesField) coordinatesWrapper.Latitude;
                CoordinatesField longitude = (CoordinatesField) coordinatesWrapper.Longitude;
                CoordinatesField accuracy = (CoordinatesField) coordinatesWrapper.Accuracy;

                resWo.put(latitude.apiName, latitude.value);
                resWo.put(longitude.apiName, longitude.value);
                resWo.put(accuracy.apiName, accuracy.value);
                resWo.put('XC_CheckInMobility__c', true);
                resWo.put('XC_CheckInDate__c', Datetime.now());
            }
            //END FIX COORDINATE 16062022 FD - ENXCRM-213
              
            XC_UTIL_Sobject.WrapperResult resInsertWO = XC_UTIL_Sobject.updaterecord(resWo);
            System.debug('resInsertWO : ' + resInsertWO);

            if(!resInsertWO.success) {
                apexActionWrapper.error = 'Error on update WorkOrder: ' + resInsertWO.errorMessage;
                return apexActionWrapper;
            }

            //START FIX - [#20210317AL] - FIX NOT UPDATE SERVICEAPPOINTMENT ON WO CHILD
            if(wrReq.WorkOrder.ServiceAppointment[0].ServiceAppointmentID != null && !woToMod.ServiceAppointments.isEmpty()) {
            //END FIX - [#20210317AL] - FIX NOT UPDATE SERVICEAPPOINTMENT ON WO CHILD
                list<ServiceAppointment> resSa = XC_REST_WorkOrder_U.updateOrCreateServiceAppointment(wrReq.WorkOrder.ServiceAppointment, resWo.id, woToMod.ServiceAppointments);

                List<SObject> toIns = new List<SObject>();
                toIns.addAll(resSa);
    
                List<XC_UTIL_Sobject.WrapperResult> resInsert = XC_UTIL_Sobject.upsertListRecords(toIns);
    
                for(XC_UTIL_Sobject.WrapperResult msg : resInsert) {
                    if(!msg.success) {
                        apexActionWrapper.error = 'Error on upsert: ' + msg.errorMessage;
                        TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateWorkOrder', JSON.serialize(apexActionWrapper), 0, JSON.serialize(apexActionWrapper), null);
                        return apexActionWrapper;
                    }
                }
            //START FIX - [#20210317AL] - FIX NOT UPDATE SERVICEAPPOINTMENT ON WO CHILD
            }
            //END FIX - [#20210317AL] - FIX NOT UPDATE SERVICEAPPOINTMENT ON WO CHILD

            //START FIX - [ADC 18/05/2021] - FIX UPDATE FATHER ENTITY ON WO CHILD
            else {               
                Boolean updateFatherEntity = false;
                Boolean completeFatherEntity = true;
                List<WorkOrder> brotherWOList = [SELECT id, Status 
                                                FROM WorkOrder 
                                                WHERE ParentWorkOrderId =: resWo.ParentWorkOrderId];

                if(resWo.Status != 'Completed'){ 
                    if(brotherWOList.size() == 1) updateFatherEntity = true;                
                    for(WorkOrder brother : brotherWOList){
                        if(brother.Status == 'Assigned'){
                            updateFatherEntity = true;
                            break;
                        }                    
                    }
                    if(updateFatherEntity) {
                        List<ServiceAppointment> saList = [SELECT ID 
                                                            FROM ServiceAppointment 
                                                            WHERE ParentRecordId =: resWo.ParentWorkOrderId
                                                            AND Status != 'Canceled']; //FIX [20220216AL]
                        if(!saList.isEmpty()){
                            update new ServiceAppointment(id = saList[0].id, Status = 'In Progress');
                        }
                        update new WorkOrder(id = resWo.ParentWorkOrderId, Status = 'In Progress');                                     
                    }
                }
                else{
                    if(brotherWOList.size() > 1){
                        for(WorkOrder brother : brotherWOList){
                            if(brother.Status != 'Completed'){                           
                                completeFatherEntity = false;
                                break;
                            }                                      
                        }
                    }
                    if(completeFatherEntity) {
                        List<ServiceAppointment> saList = [SELECT ID 
                                                            FROM ServiceAppointment 
                                                            WHERE ParentRecordId =: resWo.ParentWorkOrderId
                                                            AND Status != 'Canceled']; //FIX [20220216AL]
                        if(!saList.isEmpty()){
                            update new ServiceAppointment(id = saList[0].id, Status = 'Completed', ActualEndTime = Datetime.now());
                        }
                        update new WorkOrder(id = resWo.ParentWorkOrderId, Status = 'Completed');                                     
                    }
                }
            }
            //END FIX - [ADC 18/05/2021] - FIX UPDATE FATHER ENTITY ON WO CHILD

            
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateWorkOrder', errorMessage, 0, errorMessage, null);
            apexActionWrapper.error = errorMessage;
        }
        TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateWorkOrder', JSON.serialize(apexActionWrapper), 0, JSON.serialize(apexActionWrapper), null);
        return apexActionWrapper;
    }

    private static ApexActionWrapper updateWorkOrder_GPS(ApexActionWrapper apexActionWrapper) {
        try {
            System.debug('@@>> apexActionWrapper : ' + apexActionWrapper.parameters);
            String msgRequest = (String) apexActionWrapper.parameters;
            System.debug('Parameters : ' + apexActionWrapper.parameters);
            XC_REST_WorkOrder_W.Wrapper wrReq = (XC_REST_WorkOrder_W.Wrapper) JSON.deserialize(msgRequest, XC_REST_WorkOrder_W.Wrapper.class);
            XC_REST_WorkOrder_W.Wrapper wrResp = new XC_REST_WorkOrder_W.Wrapper();

            System.debug('wrReq >>> ' + wrReq);

            wrReq.WorkOrder.WorkType = XC_UTIL_WorkType.getWorkTypeByName(wrReq.WorkOrder.WorkType);
            WorkOrder woToMod = XC_REST_WorkOrder_UU.getWorkOrderForUpdate(wrReq);
            System.debug('woToMod : ' + woToMod);
            workOrder resWo = XC_REST_WorkOrder_U.createWorkOrder(wrReq.WorkOrder, woToMod);
            System.debug('resWo : ' + resWo);
            resWo.XC_UpdatedByApp__c = true;
            resWo.TA_UpdatedByApp__c = true;
            if(resWo.Status == 'Completed') resWo.TA_CompletedByApp__c = true;

            //START FIX COORDINATE
            System.debug('@@>> msgRequest >>> ' + msgRequest);
            ParamWrapper paramWrapper = (ParamWrapper) JSON.deserialize(msgRequest, ParamWrapper.class);
            System.debug('@@>> paramWrapper >>> ' + paramWrapper);
            CoordinatesWrapper coordinatesWrapper = (CoordinatesWrapper) paramWrapper.Coordinates;
            system.debug('@@>> coordinatesWrapper >>> ' + coordinatesWrapper);
            if(coordinatesWrapper != null){
                CoordinatesField latitude = (CoordinatesField) coordinatesWrapper.Latitude;
                CoordinatesField longitude = (CoordinatesField) coordinatesWrapper.Longitude;
                CoordinatesField accuracy = (CoordinatesField) coordinatesWrapper.Accuracy;

                resWo.put(latitude.apiName, latitude.value);
                resWo.put(longitude.apiName, longitude.value);
                resWo.put(accuracy.apiName, accuracy.value);
                resWo.put('XC_CheckInMobility__c', true);
                resWo.put('XC_CheckInDate__c', Datetime.now());
            }
            //END FIX COORDINATE

              
            XC_UTIL_Sobject.WrapperResult resInsertWO = XC_UTIL_Sobject.updaterecord(resWo);
            System.debug('resInsertWO : ' + resInsertWO);

            if(String.isNotBlank(resInsertWO.errorMessage)) {
                apexActionWrapper.error = resInsertWO.errorMessage;
                TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateWorkOrder_GPS', String.valueOf(resInsertWO), 0, String.valueOf(resInsertWO), null);
            }

            //START FIX - [#20210317AL] - FIX NOT UPDATE SERVICEAPPOINTMENT ON WO CHILD
            if(wrReq.WorkOrder.ServiceAppointment[0].ServiceAppointmentID != null && !woToMod.ServiceAppointments.isEmpty()) {
                //END FIX - [#20210317AL] - FIX NOT UPDATE SERVICEAPPOINTMENT ON WO CHILD
                    list<ServiceAppointment> resSa = XC_REST_WorkOrder_U.updateOrCreateServiceAppointment(wrReq.WorkOrder.ServiceAppointment, resWo.id, woToMod.ServiceAppointments);
    
                    List<SObject> toIns = new List<SObject>();
                    toIns.addAll(resSa);

                    List<XC_UTIL_Sobject.WrapperResult> resInsert = XC_UTIL_Sobject.upsertListRecords(toIns);

                    for(XC_UTIL_Sobject.WrapperResult msg : resInsert) {
                        if(!msg.success) {
                            apexActionWrapper.error = 'Error on upsert: ' + msg.errorMessage;
                            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateWorkOrder', JSON.serialize(apexActionWrapper), 0, JSON.serialize(apexActionWrapper), null);
                            return apexActionWrapper;
                        }
                    }
                //START FIX - [#20210317AL] - FIX NOT UPDATE SERVICEAPPOINTMENT ON WO CHILD
                }
                //END FIX - [#20210317AL] - FIX NOT UPDATE SERVICEAPPOINTMENT ON WO CHILD
    
                //START FIX - [ADC 18/05/2021] - FIX UPDATE FATHER ENTITY ON WO CHILD
                else {               
                    Boolean updateFatherEntity = false;
                    Boolean completeFatherEntity = true;
                    List<WorkOrder> brotherWOList = [SELECT id, Status 
                                                    FROM WorkOrder 
                                                    WHERE ParentWorkOrderId =: resWo.ParentWorkOrderId];
    
                    if(resWo.Status != 'Completed'){ 
                        if(brotherWOList.size() == 1) updateFatherEntity = true;                
                        for(WorkOrder brother : brotherWOList){
                            if(brother.Status == 'Assigned'){
                                updateFatherEntity = true;
                                break;
                            }                    
                        }
                        if(updateFatherEntity) {
                            List<ServiceAppointment> saList = [SELECT ID 
                                                                FROM ServiceAppointment 
                                                                WHERE ParentRecordId =: resWo.ParentWorkOrderId
                                                                AND Status != 'Canceled']; //FIX [20220216AL]
                            if(!saList.isEmpty()){
                                update new ServiceAppointment(id = saList[0].id, Status = 'In Progress');
                            }
                            update new WorkOrder(id = resWo.ParentWorkOrderId, Status = 'In Progress');                                     
                        }
                    }
                    else{
                        if(brotherWOList.size() > 1){
                            for(WorkOrder brother : brotherWOList){
                                if(brother.Status != 'Completed'){                           
                                    completeFatherEntity = false;
                                    break;
                                }                                      
                            }
                        }
                        if(completeFatherEntity) {
                            List<ServiceAppointment> saList = [SELECT ID 
                                                                FROM ServiceAppointment 
                                                                WHERE ParentRecordId =: resWo.ParentWorkOrderId
                                                                AND Status != 'Canceled']; //FIX [20220216AL]
                            if(!saList.isEmpty()){
                                update new ServiceAppointment(id = saList[0].id, Status = 'Completed', ActualEndTime = Datetime.now());
                            }
                            update new WorkOrder(id = resWo.ParentWorkOrderId, Status = 'Completed');                                     
                        }
                    }
                }
                //END FIX - [ADC 18/05/2021] - FIX UPDATE FATHER ENTITY ON WO CHILD
                
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateWorkOrder_GPS', errorMessage, 0, errorMessage, null);
            apexActionWrapper.error = errorMessage;
        }
        return apexActionWrapper;
    }

    private static ApexActionWrapper manageProvisioning(ApexActionWrapper apexActionWrapper) {
        try {
            System.debug('@@ enter manageProvisioning');
            Map<String,Object> parameters = (Map<String,Object>) apexActionWrapper.parameters;
            Id recordId = (Id) parameters.get('id');
            WorkOrder wo = [select id, XC_Configuration__c, XC_Configuration__r.NE__AccountId__c, XC_Configuration__r.XC_Compliance_Approval__c, XC_Configuration__r.RecordType.Name from workorder where id =: recordId];
            XC_REST_Order_U.WrapperRes wr = new XC_REST_Order_U.WrapperRes();
            XC_REST_Order_U.WrapperPUTRequest wrReq = new XC_REST_Order_U.WrapperPUTRequest();
            wrReq.Order = new XC_UTIL_Order.OrderIFWrapper();
            wrReq.Order.OrderID = wo.XC_Configuration__c;
            wrReq.Order.StartProvisioning = true;
            //wrReq.Order.skipCompliance = true;
            Map<String, List<NE__Order_Item_Attribute__c>> mapOrdItemIdOIA = new  Map<String, List<NE__Order_Item_Attribute__c>>();
            Map<Id,NE__Order__c> ordMap = new Map<Id,NE__Order__c>([select id, XC_FinancialPracticeStatus__c,XC_FinancialPracticeNumber__c,XC_FinancialInstitution__c,(select id,XC_PaymentMethod__c from NE__Order_Items__r) from NE__Order__c where id =: wo.XC_Configuration__c]);

            Map<String, Object> mapOrder = new Map<String, Object>{ 'mapOrdItemIdOIA'=> mapOrdItemIdOIA,
                                                                    'wrReq' => wrReq,
                                                                    'ordMap' => ordMap,
                                                                    'orderID' => wo.XC_Configuration__c,
                                                                    'complianceStatus' => wo.XC_Configuration__r.XC_Compliance_Approval__c,
                                                                    'recordTypeOrder' => wo.XC_Configuration__r.RecordType.Name};
            List<NE__OrderItem__c> orderItemList = [select id from NE__OrderItem__c where NE__OrderId__c =: wo.XC_Configuration__c];
            for(NE__OrderItem__c oi : orderItemList) {
                XC_UTIL_Order.OrderItemWrapper item = new XC_UTIL_Order.OrderItemWrapper();
                item.OrderItemID = oi.Id;
                            wrReq.Order.OrderItem.add(item);
            }
            System.debug('@@ OrderItem size :' + wrReq.Order.OrderItem.size());

            XC_REST_Order_U.updateOrders(mapOrder, wr);

        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'manageProvisioning', errorMessage, 0, errorMessage, null);
            apexActionWrapper.error = errorMessage;
        }
        return apexActionWrapper;
    }

    private static ApexActionWrapper createNewOppty(ApexActionWrapper apexActionWrapper) {
        try {
            Map<String, Object> parameters = (Map<String, Object>) apexActionWrapper.parameters;
            if(parameters.containsKey('opptyWrapper')) {
                String msgRequest = (String) parameters.get('opptyWrapper');
                XC_REST_Opportunity_U.WrapperRequest wrReq = (XC_REST_Opportunity_U.WrapperRequest) JSON.deserialize(msgRequest, XC_REST_Opportunity_U.WrapperRequest.class);
                wrReq.Opportunity.OpportunityName = wrReq.Opportunity.WorkOrderID;
                wrReq.Opportunity.Status = 'Draft';
                wrReq.Opportunity.CloseDate = System.today().addDays(1);
                List<Opportunity> opportunityToInsert = new List<Opportunity> {XC_REST_Opportunity_U.createOpportunityFromWrapper(wrReq)};
                XC_UTIL_Sobject.WrapperResult result = XC_UTIL_Sobject.insertRecord(opportunityToInsert.get(0));
    
                if(result.success) {
                    apexActionWrapper.callBackParams = new List<Object>();
                    apexActionWrapper.callBackParams.add(result.recordId);

                    WorkOrder workOrder = new WorkOrder();
                    workOrder.Id = wrReq.Opportunity.WorkOrderID;
                    Map<String, String> taParameters = new Map<String, String>();
                    Map<String, Object> evtParam = (Map<String, Object>) parameters.get('taParameters');
                    for(String evtParamKey : evtParam.keySet()) {
                        if(evtParamKey == 'newOppty') {
                            evtParam.put(evtParamKey, result.recordId);
                        }
                        taParameters.put(evtParamKey, String.valueOf(evtParam.get(evtParamKey)));
                    }
                    workOrder.TA_Parameters__c = JSON.serialize(taParameters);
                    update workOrder;
                } else {
                    apexActionWrapper.error = result.errorMessage;
                    if(String.isNotEmpty(result.errorfieldName)) {
                        apexActionWrapper.error = result.errorfieldName + ': ' + apexActionWrapper.error;
                    }
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'createNewOppty', errorMessage, 0, errorMessage, null);
            apexActionWrapper.error = errorMessage;
        }
        return apexActionWrapper;
    }

    private static ApexActionWrapper updateWorkOrderTAParameters(ApexActionWrapper apexActionWrapper) {
        try {
            Map<String, Object> parameters = (Map<String, Object>) apexActionWrapper.parameters;
            Map<String, Object> workOrderMap = (Map<String, Object>) parameters.get('workOrder');
            WorkOrder workOrder = new WorkOrder();
            workOrder.Id = String.valueOf(workOrderMap.get('Id'));
            Map<String, String> taParameters = new Map<String, String>();
            Map<String, Object> evtParam = (Map<String, Object>) parameters.get('evtParam');
            for(String evtParamKey : evtParam.keySet()) {
                taParameters.put(evtParamKey, String.valueOf(evtParam.get(evtParamKey)));
            }
            workOrder.TA_Parameters__c = JSON.serialize(taParameters);
            update workOrder;
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateWorkOrderTAParameters', errorMessage, 0, errorMessage, null);
            //START FIX [ADC25-06-2021] ENXCRM-161
            //apexActionWrapper.error = errorMessage;
            apexActionWrapper.error = e.getMessage().contains('UNABLE_TO_LOCK_ROW') ? '' : errorMessage;  
            //END FIX [ADC25-06-2021] ENXCRM-161          
        }
        return apexActionWrapper;
    }
    
    private static ApexActionWrapper completeAllWoli(ApexActionWrapper apexActionWrapper, String workOrderId) {
        System.debug('[TA_LCC199_ButtonSection] completeAllWoli');
        try{
            if (String.isNotBlank(workOrderId)){
                System.debug('[TA_LCC199_ButtonSection] in if');
                List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
                WorkOrder wo = [SELECT XC_WorkTypeCategory__c, 
                                (SELECT ID FROM WorkOrderLineItems) 
                                FROM WorkOrder WHERE ID =: workOrderId];
                
                if (wo.XC_WorkTypeCategory__c == Label.XC_CL_WorkType_CommercialVisit) {                
                    for(WorkOrderLineItem woli : wo.WorkOrderLineItems){
                        woli.Status = 'Closed';
                        woliList.add(woli);                        
                    }  
                    update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = true);
                    update woliList;
                    update new User(Id = UserInfo.getUserId(), XC_EnabledToSkip__c = false);
                    
                }

            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'completeAllWoli', errorMessage, 0, errorMessage, null);
            apexActionWrapper.error = errorMessage;
        }
        return apexActionWrapper;
    }

    
    private static ApexActionWrapper fillAddressOnOrder(Id workOrderId, ApexActionWrapper apexActionWrapper) {
        if(String.isNotBlank(workOrderId) && apexActionWrapper != null) {
            List<WorkOrder> workOrderList = [SELECT Id, XC_Configuration__c, XC_Address__c FROM WorkOrder WHERE Id = :workOrderId];
            if(!workOrderList.isEmpty()){
                WorkOrder myWorkOrder = workOrderList[0];
                if(String.isNotBlank(myWorkOrder.XC_Configuration__c)){
                    NE__Order__c myOrder = new NE__Order__c(Id = myWorkOrder.XC_Configuration__c, 
                                                            XC_OrderBillingAddress__c = myWorkOrder.XC_Address__c, 
                                                            XC_InstallationAddress__c = myWorkOrder.XC_Address__c,
                                                            XC_DeliveryAddress__c = myWorkOrder.XC_Address__c);
                    update myOrder;
                }
            }
        }
        return apexActionWrapper;
    }

    @AuraEnabled
    public static String updateReasonCannotComplete(Id workOrderId, String rccValue) {
        try {
            if(String.isNotBlank(workOrderId) && String.isNotBlank(rccValue)) {
                List<WorkOrder> workOrders = [SELECT Id, ParentWorkOrderId FROM WorkOrder WHERE Id = :workOrderId];
                if(!workOrders.isEmpty()) {
                    String parentRecordId = workOrders[0].ParentWorkOrderId != null ? workOrders[0].ParentWorkOrderId : workOrders[0].Id;
                    List<ServiceAppointment> servApps = [SELECT Id FROM ServiceAppointment WHERE ParentRecordId = :parentRecordId AND Status != 'Canceled']; //FIX [20220216AL]
                    if(!servApps.isEmpty()) {
                        update new ServiceAppointment(Id = servApps[0].Id, XC_Reason_Cannot_Complete__c = rccValue, Status = 'Cannot Complete');
                        return 'complete';
                    }
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'updateReasonCannotComplete', errorMessage, 0, errorMessage, null);
            return errorMessage;
        }
        return null;
    }

    //START - [20220622AL] - NR2330
    @AuraEnabled
    public static String getTechnicalAssetDefaultValues(Id workOrderId) {
        try {
            Map<String, String> response = new Map<String, String>();
            if(String.isNotBlank(workOrderId)) {
                List<WorkOrder> workOrders = [SELECT Id, AccountId, AssetId, Asset.Name, Asset.NE__City__c, Case.XC_TechnicalAsset__c, Case.XC_TechnicalAsset__r.Name FROM WorkOrder WHERE Id = :workOrderId];
                if(!workOrders.isEmpty()) {
                    response.put('technicalAsset', workOrders[0].AssetId);
                    response.put('technicalAssetName', String.isNotBlank(workOrders[0].AssetId) ? workOrders[0].Asset.Name : null);
                    response.put('city', String.isNotBlank(workOrders[0].AssetId) ? workOrders[0].Asset.NE__City__c : null);
                    response.put('dateDeclared', String.valueOf(DateTime.now()));
                    response.put('accountId', workOrders[0].AccountId);
                    return JSON.serialize(response);
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC199_ButtonSection] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC199_ButtonSection', 'getTechnicalAssetDefaultValues', errorMessage, 0, errorMessage, null);
            return errorMessage;
        }
        return null;
    }
    //END - [20220622AL] - NR2330
}