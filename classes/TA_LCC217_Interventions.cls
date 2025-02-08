public without sharing class TA_LCC217_Interventions {
    public static Boolean isInitialize = false;
    public static Integer retry = 0;

    public class InfoBag {
        @AuraEnabled
        public List<MacroBlock> macroBlockList {get;set;}
        @AuraEnabled
        public String baseUrl {get;set;}
        @AuraEnabled
        public Integer numberOfWoli {get;set;}
        @AuraEnabled
        public Boolean isDevHub {get;set;}
        @AuraEnabled
        public String actionResponse {get;set;}
    }

    public class RelatedListBlock {
        @AuraEnabled
        public List<String> fieldList {get;set;}
        @AuraEnabled
        public Map<String, String> fieldApiNameToLabel {get;set;}
        @AuraEnabled
        public String relationShipName {get;set;}
    }

    public class MacroBlock {
        @AuraEnabled
        public String blockName {get;set;}
        @AuraEnabled
        public Decimal blockNumber {get;set;}
        @AuraEnabled
        public Boolean showExpandButton = true; //ENXCRM-138 - BGO - 07062021
        @AuraEnabled
        public String blockColor = '';
        @AuraEnabled
        public List<WorkOrderLineItemWrapper> woliListWrapper {get;set;}
    }

    public class ChildBlock {
        @AuraEnabled
        public Boolean showAccordion {get;set;}
        @AuraEnabled
        public Boolean showRecord {get;set;}
        @AuraEnabled
        public Boolean newRecord {get;set;}
        @AuraEnabled
        public List<ChildRecordWrapper> recordList {get;set;}
    }

    public class ChildRecordWrapper {
        @AuraEnabled
        public SObject record {get;set;}
        @AuraEnabled
        public List<FieldWrapper> fieldToShow {get;set;}
    }

    public class FieldWrapper {
        @AuraEnabled
        public String apiName {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }

    public class ButtonWrapper{
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public String label {get;set;}
    }

    public class WorkOrderLineItemWrapper {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String lineItemNumber {get;set;}
        @AuraEnabled
        public String macroBlocName {get;set;}
        @AuraEnabled
        public Decimal macroBlocNumber {get;set;}
        @AuraEnabled
        public String rtDeveloperName {get;set;}
        @AuraEnabled
        public String rtId {get;set;}
        @AuraEnabled
        public String activityName {get;set;}
        @AuraEnabled
        public String WOLIType {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String statusLabel {get;set;}
        @AuraEnabled
        public Decimal measurementValueOne {get;set;}
        @AuraEnabled
        public String measurementUnitOne {get;set;}
        @AuraEnabled
        public String technicianResponse {get;set;}
        @AuraEnabled
        public String technicianResponseButtonLeft {get;set;}
        @AuraEnabled
        public String technicianResponseButtonRight {get;set;}
        @AuraEnabled
        public List<String> buttonList {get;set;}
        @AuraEnabled
        public List<ButtonWrapper> buttonWrapperList {get;set;}
        @AuraEnabled
        public Decimal minRange {get;set;}
        @AuraEnabled
        public Decimal maxRange {get;set;}
        @AuraEnabled
        public Boolean showWarning {get;set;}
        @AuraEnabled
        public Boolean showDescription = false;
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public List<ContentVersion> contentVersionList {get;set;}
        @AuraEnabled
        public String doxeeURL {get;set;}
        @AuraEnabled
        public Boolean required {get;set;}
        @AuraEnabled
        public List<TA_Doxee_Url_Management__c> doxeeUrlManList {get;set;}
        @AuraEnabled
        public ChildBlock productConsumedBl {get;set;}
        @AuraEnabled
        public ChildBlock positionRequiredBl {get;set;}
        @AuraEnabled
        public ChildBlock productRequiredBl {get;set;}
        @AuraEnabled
        public Map<String, Object> actions {get;set;}
    }

    @AuraEnabled
    public static String init(String objectId, String actionResponse, String jsonCustomConfigSerialized) {
        InfoBag infobag = new InfoBag();
        try {
            isInitialize = true;
            infobag.actionResponse = actionResponse;
            Map<String, Decimal> nameNumberMap = new Map<String, Decimal>();
            List<String> woliIdList = new List<String>();

            Map<String, Object> jsonCustomConfig = (Map<String, Object>) JSON.deserializeUntyped(jsonCustomConfigSerialized);
            Map<String, Object> woliTypeConfig = new Map<String, Object>();
            if(jsonCustomConfig.containsKey('woliTypeConfig')) {
                woliTypeConfig = (Map<String, Object>) jsonCustomConfig.get('woliTypeConfig');
            }

            Schema.DescribeSObjectResult R = XC_ProductConsumed__c.SObjectType.getDescribe();
            List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
            String recordtypeField = RT.size() > 1 ? ',RecordTypeId,' : ',';
            List<RelatedListBlock> relatedListBL = new List<RelatedListBlock>();

            RelatedListBlock blockPC = new RelatedListBlock();
            blockPC.relationShipName = 'Products_Consumed__r';
            String fieldPC = 'Id' + recordtypeField + 'XC_Product2Id__r.ProductCode,XC_Product2Id__r.Name,XC_QuantityConsumed__c,Name,TAM_Asset__c,TAM_Asset__r.RecordTypeId,TAM_Asset__r.TAM_AssetType__c,TAM_Asset__r.Name,TAM_Status__c';
            blockPC.fieldList = fieldPC.split(',');
            blockPC.fieldApiNameToLabel = createMapApiNameLabel('XC_ProductConsumed__c', blockPC.fieldList);

            RelatedListBlock blockRP = new RelatedListBlock();
            blockRP.relationShipName = 'Required_Positions__r';
            String fieldRP = 'Id,XC_ProductName__c,XC_PositionCode__c,XC_Quantity__c';
            blockRP.fieldList = fieldRP.split(',');
            blockRP.fieldApiNameToLabel = createMapApiNameLabel('XC_RequiredPosition__c', blockRP.fieldList);

            RelatedListBlock blockPR = new RelatedListBlock();
            blockPR.relationShipName = 'Products_Required__r';
            String fieldPR = 'Id,ProductName,QuantityRequired,XC_WBSElement__c';
            blockPR.fieldList = fieldPR.split(',');
            blockPR.fieldApiNameToLabel = createMapApiNameLabel('ProductRequired', blockPR.fieldList);

            relatedListBL.add(blockPC);
            relatedListBL.add(blockRP);
            relatedListBL.add(blockPR);

            String queryRelatedList = '';
            for(RelatedListBlock bl : relatedListBL) {
                queryRelatedList += '(SELECT ' + String.join(bl.fieldList,',') + ' FROM ' + bl.relationShipName + ' ORDER BY CreatedDate),';
            }
            System.debug(queryRelatedList);

            String queryWOLI = 'SELECT Id, toLabel(Status) statusLabel,' + queryRelatedList + 'XC_Segment__c, LineItemNumber,XC_WOLIType__c, XC_MacroBlocName__c, XC_MacroBlocNumber__c, XC_ActivityName__c, RecordType.DeveloperName, RecordTypeId, XC_ActivityNumber__c, Status, XC_MeasurementValueOne__c, XC_MeasurementUnitOne__c, XC_TechnicianResponse__c, XC_TechnicianResponseForConfiguration__c, XC_Range__c, Description, XC_Required__c '+
                                'FROM WorkOrderLineItem '+
                                'WHERE WorkOrderId =: objectId '+
                                'ORDER BY XC_MacroBlocNumber__c, XC_ActivityNumber__c, LineItemNumber';
            List<WorkOrderLineItem> woliList= Database.query(queryWOLI);
            Map<Id, WorkOrderLineItem> woliMap = new Map<Id, WorkOrderLineItem>(woliList);

            Map<String, Object> actions = new Map<String, Object>();
            String response = '';
            retry = 0;
            if(!Test.isRunningTest()) {
                String segment = woliList[0].XC_Segment__c;
                if(segment != 'B2C') {
                    response = infobag.actionResponse == null ? getAction(String.join((List<String>) new List<Id>(woliMap.keySet()), ',')) : infobag.actionResponse;
                    infobag.actionResponse = response;
                    if(infobag.actionResponse != 'KO') {
                        Map<String, Object> responseAction = (Map<String, Object>) JSON.deserializeUntyped(response);
                        actions = (Map<String, Object>) responseAction.get('actions');
                    } else {
                        return JSON.serialize(infoBag);
                    }
                }
            }

            List<WorkOrderLineItemWrapper> woliWrapperList = new List<WorkOrderLineItemWrapper>();
            infobag.macroBlockList = new List<MacroBlock>();
            infobag.numberOfWoli = woliList.size();
            infobag.isDevHub = TA_Org_Info__c.getInstance().TA_isDevHub__c;
            for(WorkOrderLineItem woli : woliMap.values()) {
                WorkOrderLineItemWrapper woliWrapper = new WorkOrderLineItemWrapper();
                woliWrapper.contentVersionList = new List<ContentVersion>();
                woliWrapper.doxeeUrlManList = new List<TA_Doxee_Url_Management__c>();
                DescribeSObjectResult describe = SObjectType.WorkOrderLineItem;
                String macroblockName = woli.XC_MacroBlocNumber__c == null ? describe.getLabel() : woli.XC_MacroBlocName__c;
                nameNumberMap.put(macroblockName, woli.XC_MacroBlocNumber__c);
                woliWrapper.id = woli.id;
                woliWrapper.rtDeveloperName = woli.RecordType.DeveloperName;
                woliWrapper.rtId = woli.RecordTypeId;
                woliWrapper.macroBlocName = macroblockName;
                woliWrapper.macroBlocNumber = woli.XC_MacroBlocNumber__c;
                woliWrapper.activityName = woli.XC_ActivityName__c;
                woliWrapper.WOLIType = woli.XC_WOLIType__c;
                woliWrapper.status = woli.Status;
                woliWrapper.statusLabel = String.valueOf(woli.get('statusLabel'));
                woliWrapper.measurementValueOne = woli.XC_MeasurementValueOne__c;
                woliWrapper.measurementUnitOne = woli.XC_MeasurementUnitOne__c;
                woliWrapper.lineItemNumber = woli.LineItemNumber;
                woliWrapper.technicianResponse = woli.XC_TechnicianResponse__c;
                woliWrapper.description = woli.Description;
                woliWrapper.required = woli.XC_Required__c;
                if(actions.containsKey(woli.id)) {
                    woliWrapper.actions = (Map<String, Object>) actions.get(woli.Id);
                }

                Map<String, Object> childObjConfig = new Map<String, Object>();
                if(woliTypeConfig.containsKey(woliWrapper.WOLIType)) {
                    childObjConfig = (Map<String, Object>) woliTypeConfig.get(woliWrapper.WOLIType);
                } else {
                    childObjConfig = (Map<String, Object>) woliTypeConfig.get('Default');
                }

                if(childObjConfig != null) {
                    if(childObjConfig.containsKey('Products_Consumed__r')) {
                        Map<String, String> fieldApiNameToLabel = new Map<String, String>();
                        for(RelatedListBlock relatedBL : relatedListBL) {
                            if(relatedBL.relationShipName == 'Products_Consumed__r') {
                                fieldApiNameToLabel = relatedBL.fieldApiNameToLabel;
                            }
                        }
    
                        woliWrapper.productConsumedBl = new ChildBlock();
                        Map<String, Object> productConsumedConfig = (Map<String, Object>) childObjConfig.get('Products_Consumed__r');
                        woliWrapper.productConsumedBl.showAccordion = (Boolean) productConsumedConfig.get('showAccordion');
                        woliWrapper.productConsumedBl.showRecord = (Boolean) productConsumedConfig.get('showRecord');
                        woliWrapper.productConsumedBl.newRecord = (Boolean) productConsumedConfig.get('newRecord');
                        woliWrapper.productConsumedBl.recordList = new List<ChildRecordWrapper>();
    
                        if(woli.getSObjects('Products_Consumed__r') != null) {
                            List<SObject> productConsumedList = woli.getSObjects('Products_Consumed__r');
                            for(SObject productConsumed : productConsumedList) {
                                ChildRecordWrapper childRecordWrapper = new ChildRecordWrapper();
                                childRecordWrapper.record = productConsumed;
                                childRecordWrapper.fieldToShow = new List<FieldWrapper>();
    
                                for(Object fieldName : (List<Object>) productConsumedConfig.get('fieldRecordList')) {
                                    String fieldNameSerialized = String.valueOf(fieldName);
                                    List<String> fieldNameDividedByDotList = fieldNameSerialized.split('\\.');
                                    if(fieldNameDividedByDotList != null) {
                                        if(fieldNameDividedByDotList.size() == 1) {
                                            String fieldNameDividedByDot = fieldNameDividedByDotList[0];
                                            if(productConsumed.get(fieldNameDividedByDot) != null) {
                                                FieldWrapper fieldWrapper = new FieldWrapper();
                                                fieldWrapper.apiName = fieldNameSerialized;
                                                if(fieldApiNameToLabel.containsKey(fieldNameSerialized)) {
                                                    fieldWrapper.label = fieldApiNameToLabel.get(fieldNameSerialized);
                                                }
                                                fieldWrapper.value = String.valueOf(productConsumed.get(fieldNameDividedByDot));
                                                childRecordWrapper.fieldToShow.add(fieldWrapper);
                                            }
                                        } else if(fieldNameDividedByDotList.size() > 1) {
                                            SObject tempObj = productConsumed;
                                            for(Integer i = 0; i < fieldNameDividedByDotList.size(); i++) {
                                                if(tempObj != null) {
                                                    String fieldNameDividedByDot = fieldNameDividedByDotList[i];
                                                    if(i == fieldNameDividedByDotList.size() - 1) {
                                                        FieldWrapper fieldWrapper = new FieldWrapper();
                                                        fieldWrapper.apiName = fieldNameSerialized;
                                                        if(fieldApiNameToLabel.containsKey(fieldNameSerialized)) {
                                                            fieldWrapper.label = fieldApiNameToLabel.get(fieldNameSerialized);
                                                        }
                                                        fieldWrapper.value = String.valueOf(tempObj.get(fieldNameDividedByDot));
                                                        childRecordWrapper.fieldToShow.add(fieldWrapper);
                                                    } else {
                                                        tempObj = (SObject) tempObj.getSobject(fieldNameDividedByDot);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                woliWrapper.productConsumedBl.recordList.add(childRecordWrapper);
                            }
                        }
                    }
    
                    if(childObjConfig.containsKey('Required_Positions__r')) {
                        Map<String, String> fieldApiNameToLabel = new Map<String, String>();
                        for(RelatedListBlock relatedBL : relatedListBL) {
                            if(relatedBL.relationShipName == 'Required_Positions__r') {
                                fieldApiNameToLabel = relatedBL.fieldApiNameToLabel;
                            }
                        }
    
                        woliWrapper.positionRequiredBl = new ChildBlock();
                        Map<String, Object> requiredPositionConfig = (Map<String, Object>) childObjConfig.get('Required_Positions__r');
                        woliWrapper.positionRequiredBl.showAccordion = (Boolean) requiredPositionConfig.get('showAccordion');
                        woliWrapper.positionRequiredBl.showRecord = (Boolean) requiredPositionConfig.get('showRecord');
                        woliWrapper.positionRequiredBl.newRecord = (Boolean) requiredPositionConfig.get('newRecord');
                        woliWrapper.positionRequiredBl.recordList = new List<ChildRecordWrapper>();
    
                        if(woli.getSObjects('Required_Positions__r') != null) {
                            List<SObject> requiredPositionList = woli.getSObjects('Required_Positions__r');
                            for(SObject requiredPosition : requiredPositionList) {
                                ChildRecordWrapper childRecordWrapper = new ChildRecordWrapper();
                                childRecordWrapper.record = requiredPosition;
                                childRecordWrapper.fieldToShow = new List<FieldWrapper>();
    
                                for(Object fieldName : (List<Object>) requiredPositionConfig.get('fieldRecordList')) {
                                    String fieldNameSerialized = String.valueOf(fieldName);
                                    List<String> fieldNameDividedByDotList = fieldNameSerialized.split('\\.');
                                    if(fieldNameDividedByDotList != null) {
                                        if(fieldNameDividedByDotList.size() == 1) {
                                            String fieldNameDividedByDot = fieldNameDividedByDotList[0];
                                            if(requiredPosition.get(fieldNameDividedByDot) != null) {
                                                FieldWrapper fieldWrapper = new FieldWrapper();
                                                fieldWrapper.apiName = fieldNameSerialized;
                                                if(fieldApiNameToLabel.containsKey(fieldNameSerialized)) {
                                                    fieldWrapper.label = fieldApiNameToLabel.get(fieldNameSerialized);
                                                }
                                                fieldWrapper.value = String.valueOf(requiredPosition.get(fieldNameDividedByDot));
                                                childRecordWrapper.fieldToShow.add(fieldWrapper);
                                            }
                                        } else if(fieldNameDividedByDotList.size() > 1) {
                                            SObject tempObj = requiredPosition;
                                            for(Integer i = 0; i < fieldNameDividedByDotList.size(); i++) {
                                                if(tempObj != null) {
                                                    String fieldNameDividedByDot = fieldNameDividedByDotList[i];
                                                    if(i == fieldNameDividedByDotList.size() - 1) {
                                                        FieldWrapper fieldWrapper = new FieldWrapper();
                                                        fieldWrapper.apiName = fieldNameSerialized;
                                                        if(fieldApiNameToLabel.containsKey(fieldNameSerialized)) {
                                                            fieldWrapper.label = fieldApiNameToLabel.get(fieldNameSerialized);
                                                        }
                                                        fieldWrapper.value = String.valueOf(tempObj.get(fieldNameDividedByDot));
                                                        childRecordWrapper.fieldToShow.add(fieldWrapper);
                                                    } else {
                                                        tempObj = (SObject) tempObj.getSobject(fieldNameDividedByDot);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                woliWrapper.positionRequiredBl.recordList.add(childRecordWrapper);
                            }
                        }
                    }
    
                    if(childObjConfig.containsKey('Products_Required__r')) {
                        Map<String, String> fieldApiNameToLabel = new Map<String, String>();
                        for(RelatedListBlock relatedBL : relatedListBL) {
                            if(relatedBL.relationShipName == 'Products_Required__r') {
                                fieldApiNameToLabel = relatedBL.fieldApiNameToLabel;
                            }
                        }
    
                        woliWrapper.productRequiredBl = new ChildBlock();
                        Map<String, Object> productRequiredConfig = (Map<String, Object>) childObjConfig.get('Products_Required__r');
                        woliWrapper.productRequiredBl.showAccordion = (Boolean) productRequiredConfig.get('showAccordion');
                        woliWrapper.productRequiredBl.showRecord = (Boolean) productRequiredConfig.get('showRecord');
                        woliWrapper.productRequiredBl.newRecord = (Boolean) productRequiredConfig.get('newRecord');
                        woliWrapper.productRequiredBl.recordList = new List<ChildRecordWrapper>();
    
                        if(woli.getSObjects('Products_Required__r') != null) {
                            List<SObject> productRequiredList = woli.getSObjects('Products_Required__r');
                            for(SObject productRequired : productRequiredList) {
                                ChildRecordWrapper childRecordWrapper = new ChildRecordWrapper();
                                childRecordWrapper.record = productRequired;
                                childRecordWrapper.fieldToShow = new List<FieldWrapper>();
    
                                for(Object fieldName : (List<Object>) productRequiredConfig.get('fieldRecordList')) {
                                    String fieldNameSerialized = String.valueOf(fieldName);
                                    List<String> fieldNameDividedByDotList = fieldNameSerialized.split('\\.');
                                    if(fieldNameDividedByDotList != null) {
                                        if(fieldNameDividedByDotList.size() == 1) {
                                            String fieldNameDividedByDot = fieldNameDividedByDotList[0];
                                            if(productRequired.get(fieldNameDividedByDot) != null) {
                                                FieldWrapper fieldWrapper = new FieldWrapper();
                                                fieldWrapper.apiName = fieldNameSerialized;
                                                if(fieldApiNameToLabel.containsKey(fieldNameSerialized)) {
                                                    fieldWrapper.label = fieldApiNameToLabel.get(fieldNameSerialized);
                                                }
                                                fieldWrapper.value = String.valueOf(productRequired.get(fieldNameDividedByDot));
                                                childRecordWrapper.fieldToShow.add(fieldWrapper);
                                            }
                                        } else if(fieldNameDividedByDotList.size() > 1) {
                                            SObject tempObj = productRequired;
                                            for(Integer i = 0; i < fieldNameDividedByDotList.size(); i++) {
                                                if(tempObj != null) {
                                                    String fieldNameDividedByDot = fieldNameDividedByDotList[i];
                                                    if(i == fieldNameDividedByDotList.size() - 1) {
                                                        FieldWrapper fieldWrapper = new FieldWrapper();
                                                        fieldWrapper.apiName = fieldNameSerialized;
                                                        if(fieldApiNameToLabel.containsKey(fieldNameSerialized)) {
                                                            fieldWrapper.label = fieldApiNameToLabel.get(fieldNameSerialized);
                                                        }
                                                        fieldWrapper.value = String.valueOf(tempObj.get(fieldNameDividedByDot));
                                                        childRecordWrapper.fieldToShow.add(fieldWrapper);
                                                    } else {
                                                        tempObj = (SObject) tempObj.getSobject(fieldNameDividedByDot);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                woliWrapper.productRequiredBl.recordList.add(childRecordWrapper);
                            }
                        }
                    }
                }

                List<String> rangeList = new List<String>();
                if(String.isNotBlank(woli.XC_Range__c)) {
                    rangeList = (woli.XC_Range__c.split('##'));
                    woliWrapper.minRange = Decimal.valueOf(rangeList[0]);
                    woliWrapper.maxRange = Decimal.valueOf(rangeList[1]);
                    if(woliWrapper.measurementValueOne < woliWrapper.minRange || woliWrapper.measurementValueOne > woliWrapper.maxRange) {
                        woliWrapper.showWarning = true;
                    } else {
                        woliWrapper.showWarning = false;
                    }
                }

                if(String.isNotBlank(woli.XC_TechnicianResponseForConfiguration__c)) {
                    /*buttonList = (woli.XC_TechnicianResponseForConfiguration__c.split('/'));
                    woliWrapper.technicianResponseButtonLeft = buttonList[0];
                    woliWrapper.technicianResponseButtonRight = buttonList[1];*/
                    //woliWrapper.buttonList = new List<String>();
                    woliWrapper.buttonWrapperList = new List<ButtonWrapper>();
                    /*List<String> listToTrim = (woli.XC_TechnicianResponseForConfiguration__c.split('/'));
                    for(String toTrim : listToTrim) {
                        String trimmed = toTrim.trim();
                        woliWrapper.buttonList.add(trimmed);
                    }*/

                    List<Schema.PicklistEntry> picklistEntries = Schema.SObjectType.WorkOrderLineItem.fields.XC_TechnicianResponseForConfiguration__c.getPicklistValues();
                    String labelToTrim;
                    String valueToTrim;
                    for(Schema.PicklistEntry ple :picklistEntries){
                        if(ple.getValue() == woli.XC_TechnicianResponseForConfiguration__c){
                            labelToTrim = ple.getLabel();
                            valueToTrim = ple.getValue();
                        }
                    }

                    if(String.isNotBlank(labelToTrim)){
                        List<String> listLabelToTrim = (labelToTrim.split('/'));
                        List<String> listValueToTrim = (valueToTrim.split('/'));

                        for(integer i = 0; i < listLabelToTrim.size(); i++){
                            ButtonWrapper button = new ButtonWrapper();
                            button.label = listLabelToTrim[i];
                            button.value = listValueToTrim[i];
                            woliWrapper.buttonWrapperList.add(button);
                        }
                        
                        /*for(String toTrim : listToTrim) {
                            String trimmed = toTrim.trim();
                            woliWrapper.buttonList.add(trimmed);
                        }*/
                    }
                }

                woliWrapperList.add(woliWrapper);
                woliIdList.add(woli.Id);
            }

            for(String mapName : nameNumberMap.keySet()) {
                MacroBlock macroBlocK = new MacroBlocK();
                macroBlocK.woliListWrapper = new List<WorkOrderLineItemWrapper>();
                macroBlocK.blockName = mapName;
                macroBlocK.blockNumber = nameNumberMap.get(mapName);
                for(WorkOrderLineItemWrapper woliwr : woliWrapperList) {
                    if(woliwr.macroBlocName == macroBlocK.blockName) {
                        macroblock.woliListWrapper.add(woliwr);
                    }
                }
                infobag.macroBlockList.add(macroBlock);
            }

            infobag.baseUrl = Site.getBaseUrl() + '/sfc/servlet.shepherd/version/download/';

            if(infobag.isDevHub) {
                List<ContentVersion> contentVersionFromAllWoli = searchDocument(woliIdList);
                for(ContentVersion cv : contentVersionFromAllWoli) {
                    for(WorkOrderLineItemWrapper woli : woliWrapperList) {
                        if(cv.FirstPublishLocationId == woli.Id) {
                            woli.contentVersionList.add(cv);
                        }
                    }
                }
            }

            List<TA_Doxee_Url_Management__c> dumList = [SELECT TA_WorkOrderLineItem__c, TA_DoxeeURL__c,TA_isPdf__c,TA_FileName__c, TA_isDoc__c 
                                                        FROM TA_Doxee_Url_Management__c
                                                        WHERE TA_WorkOrderLineItem__c IN: woliIdList];

            for(TA_Doxee_Url_Management__c dum : dumList) {
                for(WorkOrderLineItemWrapper woli : woliWrapperList) {
                    if(dum.TA_WorkOrderLineItem__c == woli.Id) {
                        woli.doxeeURL = dum.TA_DoxeeURL__c;
                        woli.doxeeUrlManList.add(dum);
                    }
                }
            }

            System.debug('TA_LCC217_Interventions infobag: ' + infobag);
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC217_Interventions] init - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC217_Interventions', 'init', errorMessage, 0, errorMessage, null);
        }
        return JSON.serialize(infoBag);
    }

    @AuraEnabled
    public static List<ContentVersion> searchDocument(List<String> recId) {
        System.debug('TA_LCC217_Interventions: searchDocument');
        System.debug('TA_LCC217_Interventions isInitialize: ' + isInitialize);
        List<ContentDocumentLink> docLink = [ SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recId];
        List<String> contentDocumentIdList = new List<String>();
        for(ContentDocumentLink cdl : docLink) {
            contentDocumentIdList.add(cdl.ContentDocumentId);
        }
        List<ContentVersion> contentVersionList = [SELECT Id, FirstPublishLocationId, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdList];
        if(contentVersionList.size() == 0) {
            System.debug('TA_LCC217_Interventions: woli status return to NEW');
            //List<WorkOrderLineItem> wolilist = closeWoli('Not Completed', recId[0], null);
            if (!isInitialize) update new WorkOrderLineItem(ID = recId[0], Status = 'New');
        } else {
            List<XC_DocumentType__c> dtToCheck = [SELECT id FROM XC_DocumentType__c WHERE XC_WorkOrderLineItem__c =: recId[0]];
            if(dtToCheck.isEmpty()) {
                XC_DocumentType__c dt = new XC_DocumentType__c();
                dt.XC_WorkOrderLineItem__c = recId[0];
                dt.Category__c = 'SIGNED';
                insert dt;
            }
            update new WorkOrderLineItem(ID = recId[0], Status = 'Closed');
        }
        //inserire la logica anche per portare il woli in closed che adesso non è possibile inserire per via del checkDocumentType

        return contentVersionList;
    }
    @AuraEnabled
    public static String callDoxee(String requestWrapper, String inputWrapper, String workOrderId, Boolean isPdf, Boolean isDoc) {
        System.debug('TA_LCC217_Interventions: callDoxee');

        try{
            XC_REST_DoxeeFileSend_U.RequestWrapper rw = new XC_REST_DoxeeFileSend_U.RequestWrapper();
            rw.File = (XC_REST_DoxeeFileSend_U.FileWrapper) JSON.deserialize(requestWrapper, XC_REST_DoxeeFileSend_U.FileWrapper.class);
            //XC_UTIL_ResultWrapper fetchUser = XC_LCC066_Doxee.fetchUser(rw.File.ObjectId);
            XC_UTIL_ResultWrapper fetchUser = XC_LCC066_Doxee.fetchUser(workOrderId);
            System.debug('###### fetchUser :' + fetchUser );

            DateTime myDateTime = DateTime.now();
            String myDate = myDateTime.format('yyyyMMdd');
            rw.File.FileCreationDate = myDate + 'T' + myDateTime.format('HH:mm:ss');

            XC_LCC066_Doxee.WrapperUser wrapperUser = (XC_LCC066_Doxee.WrapperUser) JSON.deserialize(fetchUser.objectInfo, XC_LCC066_Doxee.WrapperUser.class);
            System.debug('###### wrapperUser :' + wrapperUser );

            rw.File.Company	= wrapperUser.company;
            rw.File.Country	= wrapperUser.country;
            //START FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf
            //Boolean isPdf = rw.File.FileName.endsWithIgnoreCase('.pdf')? true: false;
            //END FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf
            System.debug('###### rw :' + rw );
            XC_REST_DoxeeFileSend_U.ResponseWrapper resp = XC_REST_DoxeeFileSend.createFile(rw);
            System.debug('@@@@@@@@@@ response: ' + resp);
            if(resp.Result.ErrorCode == '0' && resp.File != null) {
                System.debug('@@@@@@@@@@ resp.File: ' + resp.File);
                List<TA_Doxee_Url_Management__c> dumList = [SELECT ID, TA_DoxeeURL__c,TA_isPdf__c,TA_isDoc__c,TA_FileName__c FROM TA_Doxee_Url_Management__c WHERE TA_WorkOrderLineItem__c =: rw.File.ObjectId];
                List<TA_Doxee_Url_Management__c> dumToInsert = new List<TA_Doxee_Url_Management__c>();
                //START FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf
                //dumToInsert.add(new TA_Doxee_Url_Management__c(TA_WorkOrderLineItem__c = rw.File.ObjectId, TA_DoxeeURL__c,TA_DoxeeURL__c = resp.File.Purl));
                dumToInsert.add(new TA_Doxee_Url_Management__c(TA_WorkOrderLineItem__c = rw.File.ObjectId, TA_DoxeeURL__c = resp.File.Purl,TA_isPdf__c = isPdf,TA_isDoc__c = isDoc,TA_FileName__c = rw.File.FileName));
                //END FIX [ADC27/05/2021] ENXCRM-118 aggiunta estensione per i pdf   
                insert dumToInsert;
                dumList.addAll(dumToInsert);

                if (dumList.size() == 1) closeWoli(inputWrapper, workOrderId);
                return JSON.serialize(dumList);
            }
            return JSON.serialize(resp);
        }catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC217_Interventions] callDoxee - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC217_Interventions', 'callDoxee', errorMessage, 0, errorMessage, null);
            return null;
        }
    }
    /*
    @AuraEnabled
    public static List<TA_Doxee_Url_Management__c> callDoxee(String requestWrapper, String inputWrapper, String workOrderId) {
        System.debug('TA_LCC217_Interventions: callDoxee');

        XC_REST_DoxeeFileSend_U.RequestWrapper rw = new XC_REST_DoxeeFileSend_U.RequestWrapper();
        rw.File = (XC_REST_DoxeeFileSend_U.FileWrapper) JSON.deserialize(requestWrapper, XC_REST_DoxeeFileSend_U.FileWrapper.class);
        //XC_UTIL_ResultWrapper fetchUser = XC_LCC066_Doxee.fetchUser(rw.File.ObjectId);
        XC_UTIL_ResultWrapper fetchUser = XC_LCC066_Doxee.fetchUser(workOrderId);
        System.debug('###### fetchUser :' + fetchUser );

        DateTime myDateTime = DateTime.now();
        String myDate = myDateTime.format('yyyyMMdd');
        rw.File.FileCreationDate = myDate + 'T' + myDateTime.format('HH:mm:ss');

        XC_LCC066_Doxee.WrapperUser wrapperUser = (XC_LCC066_Doxee.WrapperUser) JSON.deserialize(fetchUser.objectInfo, XC_LCC066_Doxee.WrapperUser.class);
        System.debug('###### wrapperUser :' + wrapperUser );

        rw.File.Company	= wrapperUser.company;
        rw.File.Country	= wrapperUser.country;
        System.debug('###### rw :' + rw );
        XC_REST_DoxeeFileSend_U.ResponseWrapper resp = XC_REST_DoxeeFileSend.createFile(rw);
        System.debug('@@@@@@@@@@ response: ' + resp);
        if(resp.Result.ErrorCode == '0' && resp.File != null) {
            System.debug('@@@@@@@@@@ resp.File: ' + resp.File);
            List<TA_Doxee_Url_Management__c> dumList = [SELECT ID, TA_DoxeeURL__c FROM TA_Doxee_Url_Management__c WHERE TA_WorkOrderLineItem__c =: rw.File.ObjectId];
            List<TA_Doxee_Url_Management__c> dumToInsert = new List<TA_Doxee_Url_Management__c>();
            dumToInsert.add(new TA_Doxee_Url_Management__c(TA_WorkOrderLineItem__c = rw.File.ObjectId, TA_DoxeeURL__c = resp.File.Purl));
            insert dumToInsert;
            dumList.addAll(dumToInsert);

            if (dumList.size() == 1) closeWoli(inputWrapper, workOrderId);
            return dumList;
        }
        return null;
    }*/

    @AuraEnabled
    public static String searchPhoto(String recordId) {
        System.debug('TA_LCC217_Interventions: searchPhoto');
        List<TA_Doxee_Url_Management__c> dumList = [SELECT TA_DoxeeURL__c FROM TA_Doxee_Url_Management__c WHERE TA_WorkOrderLineItem__c =: recordId];
        if(dumList.size() > 0) {
            return dumList[0].TA_DoxeeURL__c;
        }
        return null;
    }

    @AuraEnabled
    public static WorkOrderLineItem closeWoli(String inputWrapper, String woId) {
        System.debug('TA_LCC217_Interventions: closeWoli');
        /*List<WorkOrderLineItem> woliToUpdateList = new List<WorkOrderLineItem>();
        String status = '';
        if (buttonName == 'Completed') {
            status = 'Closed';
        } else if (buttonName == 'Not Completed') {
            status = 'New';
        }
        if(String.isNotBlank(status)) {
            WorkOrderLineItem woli = new WorkOrderLineItem(Id = buttonId, Status = status);
            woliToUpdateList.add(woli);
            System.debug('woliToUpdateList: ' + woliToUpdateList);
            update woliToUpdateList;
        }
        return woliToUpdateList;*/

        // test update rest class
        List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper> itemsWrapperWoli = new List<XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper>();
        XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper wrapper = (XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper) JSON.deserialize(inputWrapper, XC_UTIL_WorkOrderLineItem.WorkOrderLineItemWrapper.class);
        //wrapper.WorkOrderLineItemNumber = lineItemNumber;
        //wrapper.Status = 'Closed';
        //wrapper.TechnicianResponse = buttonName;
        itemsWrapperWoli.add(wrapper);
        List<WorkOrderLineItem> itemsWoliList = new List<WorkOrderLineItem>();
        WorkOrderLineItem itemWoli = [SELECT id, LineItemNumber, Status, XC_TechnicianResponse__c FROM WorkOrderLineItem WHERE LineItemNumber =: wrapper.WorkOrderLineItemNumber and WorkOrderId =: woId];
        itemsWoliList.add(itemWoli);
        List<WorkOrderLineItem> resWl = XC_REST_WorkOrder_U.updateOrCreateWorkOrderLine(itemsWrapperWoli, woId, itemsWoliList);

        List<SObject> toIns = new List<SObject>();
        toIns.addAll(resWl);
        List<XC_UTIL_Sobject.WrapperResult> resInsert = XC_UTIL_Sobject.upsertListRecords(toIns);

        if(resWl.size() > 0) {
            return resWl[0];
        }
        return null;
    }

    @AuraEnabled
    public static List<ContentVersion> removePhoto(List<String> contentDocumentIdList, List<String> woliIdList) {
        System.debug('TA_LCC217_Interventions: removePhoto');
        System.debug('contentDocumentIdList: ' + contentDocumentIdList);
        System.debug('woliIdList: ' + woliIdList);

        List<ContentDocument> cdToDeleteList = new List<ContentDocument>();
        for(String cdId : contentDocumentIdList) {
            cdToDeleteList.add(new ContentDocument(id = cdId));
        }
        List<ContentVersion> contentVersionListToReturn = new List<ContentVersion>();

        System.debug('woliIdList: ' + cdToDeleteList);
        System.debug('cdToDeleteList: ' + cdToDeleteList);
        delete cdToDeleteList;
        contentVersionListToReturn = searchDocument(woliIdList);
        return contentVersionListToReturn;
    }

    @AuraEnabled
    public static List<TA_Doxee_Url_Management__c> deletePhoto(String woliId, String inputWrapper, String workOrderId, String dumUrl) {
        System.debug('TA_LCC217_Interventions: deletePhoto');
        //TA_Doxee_Url_Management__c recordToDelete = [SELECT ID FROM TA_Doxee_Url_Management__c WHERE TA_WorkOrderLineItem__c =: woliId];
        List<TA_Doxee_Url_Management__c> dumList = [SELECT ID,TA_DoxeeURL__c FROM TA_Doxee_Url_Management__c
        WHERE TA_WorkOrderLineItem__c =: woliId];
        List<TA_Doxee_Url_Management__c> recordToDelete = new List<TA_Doxee_Url_Management__c>();
        Integer index;
        for(TA_Doxee_Url_Management__c dum : dumList){
            if (dum.TA_DoxeeURL__c == dumUrl){
                recordToDelete.add(dum);
                index = dumList.indexOf(dum);

            }
        }

        delete recordToDelete;
        if(dumList.size() == 1 && recordToDelete.size() == 1) {
            closeWoli(inputWrapper, workOrderId);
        }
        dumList.remove(index);
        return dumList;

    }

    @AuraEnabled
    public static WorkOrderLineItem insertMeasure(Decimal measureValue, String woliId) {
        System.debug('TA_LCC217_Interventions: insertMeasure');
        List<WorkOrderLineItem> woliToUpdateList = new List<WorkOrderLineItem>();
        WorkOrderLineItem woli = new WorkOrderLineItem(Id = woliId, XC_MeasurementValueOne__c = measureValue);
        woli.Status = measureValue != null ? 'Closed': 'New';
        woliToUpdateList.add(woli);
        if(woliToUpdateList.size() > 0) {
            update woliToUpdateList;
            return woliToUpdateList[0];
        }
        return null;
    }
    @AuraEnabled
    public static String sendApprovalRequest(String recordId,String comment){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments(comment);
        req.setObjectId(recordId);
        // Submit the approval request for the Opportunity
        Approval.ProcessResult result = Approval.process(req);
        return JSON.serialize(result);
    }

    public static String getAction(String ids) {
        //Make sure your Salesforce instance URL is added in remote site settings


        System.debug('TA_LCC217_Interventions: getAction');

        List<Network> communities = [SELECT Id, UrlPathPrefix, Name FROM Network WHERE Name = 'Enel x'];



        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String restAPIURL = sfdcURL+'/'+communities[0].UrlPathPrefix + '/services/data/v51.0/ui-api/actions/record/'+ids;
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setTimeout(15000);
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        httpRequest.setEndpoint(restAPIURL);
        String response = '';
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if(httpResponse.getStatusCode() == 200) {
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
            } else {
                throw new CalloutException(httpResponse.getBody());
            }
        } catch(System.Exception e) {
            if(retry < 3) {
                retry++;
                return getAction(ids);
            }
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC217_Interventions] getCustomLabels - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC217_Interventions', 'getAction', errorMessage, 0, errorMessage, null);
            return 'KO';         
        }
        System.debug(' ** response ** : ' + response );
        return response;
    }

    @AuraEnabled
    public static Map<String, String> createMapApiNameLabel(String objectName, List<String> fieldNameList) {
        Map<String, String> fieldApiNameToLabel = new Map<String, String>();
        try {
            SObjectType sObjectType;
            Map<String, Schema.SObjectField> fieldsMap;
            Schema.SObjectField sObjectField;

            for(String fieldProductConsumed : fieldNameList) {
                sObjectType = Schema.getGlobalDescribe().get(objectName);
                List<String> fieldNameDividedByDotList = fieldProductConsumed.split('\\.');
                if(fieldNameDividedByDotList != null) {
                    if(fieldNameDividedByDotList.size() == 1) {
                        String fieldNameDividedByDot = fieldNameDividedByDotList[0];
                        fieldsMap = sObjectType.getDescribe().fields.getMap();
                        sObjectField = fieldsMap.get(fieldNameDividedByDot);
                        fieldApiNameToLabel.put(fieldProductConsumed, String.valueOf(sObjectField.getDescribe().getLabel()));
                    } else if(fieldNameDividedByDotList.size() > 1) {
                        for(Integer i = 0; i < fieldNameDividedByDotList.size(); i++) {
                            String fieldNameDividedByDot = fieldNameDividedByDotList[i];
                            if(i == fieldNameDividedByDotList.size() - 1) {
                                fieldsMap = sObjectType.getDescribe().fields.getMap();
                                sObjectField = fieldsMap.get(fieldNameDividedByDot);
                                fieldApiNameToLabel.put(fieldProductConsumed, String.valueOf(sObjectField.getDescribe().getLabel()));
                            } else {
                                sObjectType = Schema.getGlobalDescribe()
                                    .get(String.valueOf(sObjectType))
                                    .getDescribe()
                                    .fields
                                    .getMap()
                                    .get(fieldNameDividedByDot.split('\\.').get(0).replace('__r','__c'))
                                    .getDescribe()
                                    .getReferenceTo()
                                    .get(0);
                            }
                        }
                    }
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC217_Interventions] createMapApiNameLabel - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC217_Interventions', 'createMapApiNameLabel', errorMessage, 0, errorMessage, null);
        }
        return fieldApiNameToLabel;
    }
}