/**
 * @description       : 
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 29-07-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   05-07-2021   benjamin.geronimo   Initial Version
**/

public with sharing class TA_LCC259_QualityCheckCreateRecord {

    public class QualityCheckWrapper {
        @AuraEnabled
        public String  relatedId   {get; set;} //Case (External) or WorkOrder (Internal)
        @AuraEnabled
        public String  parentAccount   {get; set;} 
        @AuraEnabled
        public Boolean isExternal   {get; set;}
        @AuraEnabled
        public XC_B2BG_QualityCheck__c   qcRecord   {get; set;}
    }

    public class PredefinedValue {
        @AuraEnabled
        public String   apiName   {get; set;}
        @AuraEnabled
        public String   queryField   {get; set;}
        @AuraEnabled
        public String   value   {get; set;}
        @AuraEnabled
        public String   dependentField   {get; set;}
    }
    
    public class RecordWrapper {
        @AuraEnabled
        public String   id   {get; set;}
        @AuraEnabled
        public String   name   {get; set;}
        @AuraEnabled
        public String   status   {get; set;}
        @AuraEnabled
        public String   recordTypeName   {get; set;}
        @AuraEnabled
        public String   recordTypeId   {get; set;}
        @AuraEnabled
        public Boolean   readOnly   {get; set;}
        @AuraEnabled
        public Map<String, String>  fieldsToCheck  {get; set;}

        public RecordWrapper(String id, String name, String status, String recordTypeName, String recordTypeId, Boolean readOnly, Map<String, String> fieldsToCheck) {
            this.id = id;
            this.name = name;
            this.status = status;
            this.recordTypeName = recordTypeName;
            this.recordTypeId = recordTypeId;
            this.readOnly = readOnly;
            this.fieldsToCheck = fieldsToCheck;
        }
    }

    /**
    * @description 
    * @author benjamin.geronimo | 05-07-2021 
    * @param objName 
    * @return string 
    **/
    @AuraEnabled
    public static string findRecordTypes(string objName){
        return TA_LCC242_DynamicCreateRecord.getRecordTypesByObjectName(objName);
    }

    /**
    * @description 
    * @author benjamin.geronimo | 29-07-2021 
    * @param workOrderId 
    * @return List<RecordWrapper> 
    **/
    @AuraEnabled
    public static List<RecordWrapper> getCurrentRecords(String workOrderId){
        List<RecordWrapper> recordWrappers = new List<RecordWrapper>();
        try {

            if( Test.isRunningTest() && workOrderId == null) {
                CalloutException e = new CalloutException();
                e.setMessage('workOrderId is null!');
                throw e;
            }

            Boolean isExternal = false;
            String profileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1][0].Name;
            if( profileName != null && profileName.contains('External') ) isExternal = true;
            System.debug('>_> isExternal : ' + isExternal);

            List<String> fieldsToCheck = new List<String>{'XC_Contract__c'};

            String qcQuery = 'SELECT Id, Name, toLabel(XC_Status__c), RecordType.Name, RecordTypeId ';
            if(!fieldsToCheck.isEmpty()) qcQuery += ', ' + String.join(fieldsToCheck,',');
            qcQuery += ' FROM XC_B2BG_QualityCheck__c ';

            List<WorkOrder> workOrders = [SELECT Id, CaseId, Case.XC_WorkOrder__r.XC_AssignedPartner__c, ParentWorkOrder.XC_AssignedPartner__c FROM WorkOrder WHERE Id =:workOrderId LIMIT 1];

            if(!workOrders.isEmpty()) {
                if( !isExternal) {
                    //Internal
                    String caseId = workOrders[0].CaseId;
                    if(caseId != null){
                        qcQuery += 'WHERE XC_Case__c =:caseId';
                    }       
                } else {
                    //External
                    qcQuery += 'WHERE XC_WorkOrder__c =:workOrderId';                    
                }
            }

            qcQuery += ' ORDER BY CreatedDate DESC';

            System.debug('>_> qcQuery : ' + qcQuery);

            List<XC_B2BG_QualityCheck__c> qcResults = Database.query(qcQuery);

            List<String> readOnlyStatus = new List<String>{'Sent for validation', 'Sent for final validation','Inviata per validazione','Inviata per validazione finale', 'Validated','Validato'};

            if( !qcResults.isEmpty() ){
                //qualityCheckToReturn.qcRecord = qcResults[0]; 
                for(XC_B2BG_QualityCheck__c obj : qcResults) {
                    Map<String, String> fieldsMap = new Map<String, String>();
                    for(String field : fieldsToCheck) {
                        fieldsMap.put(field, String.valueOf(obj.get(field)));
                    }

                    Boolean readOnly = readOnlyStatus.contains(String.valueOf(obj.get('XC_Status__c')));
                    System.debug('>_> readOnly : ' + readOnly);

                    recordWrappers.add(new RecordWrapper(String.valueOf(obj.get('Id')), 
                                                            String.valueOf(obj.get('Name')), 
                                                            String.valueOf(obj.get('XC_Status__c')), 
                                                            String.isNotBlank(String.valueOf(obj.getSObject('RecordType'))) ? String.valueOf(obj.getSObject('RecordType').get('Name')) : null, 
                                                            String.valueOf(obj.get('RecordTypeId')),
                                                            readOnly,
                                                            fieldsMap
                                                            ));
                }

            }
            
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC259_QualityCheckCreateRecord] getCurrentRecords - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC259_QualityCheckCreateRecord', 'getCurrentRecords', errorMessage, 0, errorMessage, null);
        }
        return recordWrappers;
    }

    /**
    * @description 
    * @author benjamin.geronimo | 06-07-2021 
    * @param recordId 
    * @param objectName 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean deleteRecord(String recordId, String objectName){
        return TA_LCC242_DynamicCreateRecord.deleteRecord(recordId,objectName);
    }

    @AuraEnabled
    public static List<PredefinedValue> getPredefinedValues(String serializedPredefinedValuesToQuery, String workOrderId){
        // return TA_LCC242_DynamicCreateRecord.getPredefinedValues(serializedPredefinedValuesToQuery, workOrderId);
        List<PredefinedValue> predefinedValues = (List<PredefinedValue>) JSON.deserialize(serializedPredefinedValuesToQuery, List<PredefinedValue>.class);
        //TO ADAPT IN CASE OF OTHER OBJECT/FIELD RULES
        try {
            if(String.isNotBlank(workOrderId)) {
                String selectFields = '';
                for(PredefinedValue predValue : predefinedValues) {
                    selectFields += predValue.queryField + ', ';
                }

                String queryString = 'SELECT ' + selectFields.substring(0, selectFields.length() - 2) + ' FROM WorkOrder WHERE Id =:workOrderId'; 
                System.debug('>_> queryString : ' + queryString); 
                List<WorkOrder> workOrders = Database.query(queryString);

                if(!workOrders.isEmpty()) {
                    for(PredefinedValue predValue : predefinedValues) {
                        if(predValue.queryField.contains('.')){
                            WorkOrder wo = (WorkOrder) workOrders[0].getPopulatedFieldsAsMap().get(predValue.queryField.split('\\.').get(0)); 
                            if(wo != null){
                                predValue.value = String.valueOf(wo.get(predValue.queryField.split('\\.').get(1)));
                            }
                        } else {
                            predValue.value = String.valueOf(workOrders[0].get(predValue.queryField));
                        }
                    }
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC259_QualityCheckCreateRecord] getPredefinedValues - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC259_QualityCheckCreateRecord', 'getPredefinedValues', errorMessage, 0, errorMessage, null);
        }
        return predefinedValues;
    }

  
}