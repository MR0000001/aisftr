/**
 * @description       : Apex Controller for TA_LCP258_HSEQManagement
 * @author            : benjamin.geronimo
 * @group             : WebResults
 * @last modified on  : 29-07-2021
 * @last modified by  : benjamin.geronimo
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   15-06-2021   benjamin.geronimo   Initial Version
**/

public with sharing class TA_LCC258_HSEQManagement {

    public class HSEQWrapper{
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String parentWorkOrderId {get; set;}
        @AuraEnabled
        public String woPhase {get; set;}
        @AuraEnabled
        public Boolean toReview {get; set;}
        @AuraEnabled
        public Boolean isCompleted {get; set;}
        @AuraEnabled
        public List<FieldWrapper> fields {get; set;}
        
        public HSEQWrapper(){}
    }

    public class FieldWrapper {

        @AuraEnabled
        public String name {get; set;}

        @AuraEnabled
        public String label {get; set;}

        @AuraEnabled
        public String value {get; set;}

        @AuraEnabled
        public Boolean hidden {get; set;}

        public FieldWrapper() {}

    }

    public class CreateWorkOrderResult{
        @AuraEnabled
        public Boolean success {get; set;}
        @AuraEnabled
        public string errorMessage {get; set;}
        @AuraEnabled
        public string workOrderId {get; set;}

        public CreateWorkOrderResult() {}
    }

    /**
    * @description 
    * @author benjamin.geronimo | 29-07-2021 
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean checkProfileUser( ) {
        
        Boolean isExternal = false;
        String profileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1][0].Name;
        if( profileName != null && profileName.contains('External') ) isExternal = true;
        System.debug('>_> isExternal : ' + isExternal);
        return isExternal;
    }

    /**
    * @description 
    * @author benjamin.geronimo | 18-06-2021 
    * @param condition 
    * @return List<HSEQWrapper> 
    **/
    @AuraEnabled
    public static List<HSEQWrapper> getHSEQList(String condition, Boolean isExternal) {
        List<HSEQWrapper> hseqListToReturn = new List<HSEQWrapper>();
        System.debug('>_> condition : ' + condition);
        try {
            
        
            String profileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1][0].Name;
            // profileName = 'XC_ITA_InspectorInternal';
        
            System.debug('>_> isExternal : ' + isExternal);

            Map<String, String> mapFieldObject = new Map<String, String>();
            List<Object> deserializedJsonList = (List<Object>) JSON.deserializeUntyped(condition);

            List<Map<String, Object>> deserializedJsonMap = new List<Map<String, Object>>();
            for(Object deserializedJson : deserializedJsonList) {
                deserializedJsonMap.add((Map<String, Object>) deserializedJson);
            }

            String sObjectName;
            List<Object> whereCondition = new List<Object>();
            
            if(deserializedJsonMap.size() > 0) {
                for(Map<String, Object> deserializedJsonSingleMap : deserializedJsonMap) {
                    if(String.valueOf(deserializedJsonSingleMap.get('profile')).equals(profileName)){
                        sObjectName = String.valueOf(deserializedJsonSingleMap.get('object'));
                        whereCondition = (List<Object>) deserializedJsonSingleMap.get('whereCond');
                        break;
                    }
                }
            }

            System.debug('>_> sObjectName : ' + sObjectName);
            System.debug('>_> whereCondition : ' + whereCondition);

            if( sObjectName != null && whereCondition != null ){
                String queryString = 'SELECT';


                if(!isExternal){
                    //Internal inspector
                    queryString += ' Id, CaseNumber, XC_WorkOrder__c';
                    queryString += ' From Case WHERE ' + String.join(whereCondition,' AND ');
               
                } else {
                    //External
                    queryString += ' Id, WorkOrderNumber, ParentWorkOrderId';
                    queryString += ' From WorkOrder WHERE ' + String.join(whereCondition,' AND ');
                    //queryString += ' AND XC_AssignedResource__r.RelatedRecordId = \'' + userinfo.getUserId() + '\''; //INC000091321722 
                }

                queryString += ' ORDER BY CreatedDate Desc';

                List<SObject> queryResults = Database.query(queryString);

                Map<Id, HSEQWrapper> hseqMap = new Map<Id, HSEQWrapper>();

                for(SObject sObj : queryResults){
                    System.debug('>_> sObj : ' + sObj);

                    HSEQWrapper hseqWrap = new HSEQWrapper();
                    hseqWrap.recordId = sObj.Id;
                    hseqWrap.name = String.valueOf( isExternal ? sObj.get('WorkOrderNumber') : sObj.get('CaseNumber') );
                    hseqWrap.parentWorkOrderId = String.valueOf( isExternal ? sObj.get('ParentWorkOrderId') : sObj.get('XC_WorkOrder__c') );
                    hseqWrap.fields = new List<FieldWrapper>();
                    hseqWrap.toReview = false;

                    if( hseqWrap.parentWorkOrderId != null) hseqMap.put(hseqWrap.parentWorkOrderId, hseqWrap);
                }

                System.debug('>_> hseqMap : ' + hseqMap);
                if( !hseqMap.isEmpty() ) hseqListToReturn = buildFieldsList(hseqMap);

                hseqListToReturn = getQualityChecks(hseqListToReturn, isExternal);

                 //Retrieve workorder phase
                 List<String> relatedIdList = new List<String>();
                for(HSEQWrapper hseq : hseqListToReturn){
                    relatedIdList.add(hseq.recordId);
                }

                Map<ID, String> woPhaseMap = new Map<ID, String>();
                if(!isExternal) {
                    for(WorkOrder woCase : [SELECT TA_Phase__c, CaseId FROM WorkOrder WHERE CaseId IN :relatedIdList AND XC_WorkTypeCategory__c = 'Quality Check Inspection']) {
                        woPhaseMap.put(woCase.CaseId, woCase.TA_Phase__c);
                    }
                } else {
                    for (WorkOrder wo : [SELECT Id, TA_Phase__c FROM WorkOrder WHERE Id IN :relatedIdList]) {
                        woPhaseMap.put(wo.Id, wo.TA_Phase__c);
                    }
                }
                //  for (WorkOrder wo : [SELECT Id, CaseId, TA_Phase__c FROM WorkOrder WHERE Id IN :relatedIdList OR CaseId IN :relatedIdList]){
                //      if(!isExternal){
                //          woPhaseMap.put(wo.CaseId, wo.TA_Phase__c);
                //      } else {
                //          woPhaseMap.put(wo.Id, wo.TA_Phase__c);
                //      }
                //  }
 
                 List<HSEQWrapper> hseqListToReview = new List<HSEQWrapper>();
 
                 if(!woPhaseMap.isEmpty()){
                     for (HSEQWrapper wrapper : hseqListToReturn){
                         if( woPhaseMap.get(wrapper.recordId) != null ) {
                             wrapper.woPhase = woPhaseMap.get(wrapper.recordId);
                         }
                     }
                 }
            }

            System.debug('>_> hseqListToReturn : ' + hseqListToReturn);

        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC258_HSEQManagement] getHSEQList - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC258_HSEQManagement', 'getHSEQList', errorMessage, 0, errorMessage, null);
        }
        return hseqListToReturn;
    }

    /**
    * @description 
    * @author benjamin.geronimo | 29-07-2021 
    * @param hseqMap 
    * @return List<HSEQWrapper> 
    **/
    private static List<HSEQWrapper> buildFieldsList( Map<Id, HSEQWrapper> hseqMap ) {
        try {

            List<WorkOrder> workOrderList = [SELECT Id,
                                                    WorkOrderNumber,
                                                    XC_AssignedPartner__c,
                                                    XC_AssignedPartner__r.Name,
                                                    XC_Address__c,
                                                    XC_Address__r.Name,
                                                    XC_Address__r.XC_City__c,
                                                    XC_Country__c,
                                                    XC_ScheduledStart__c

                                                FROM WorkOrder
                                                WHERE Id IN :hseqMap.keySet() ];

            if( !workOrderList.isEmpty( ) ){
                SObjectType sObjectTypeWO = Schema.getGlobalDescribe().get('WorkOrder');
                Map<String, Schema.SObjectField> fieldsMapWO = sObjectTypeWO.getDescribe().fields.getMap();

                for (WorkOrder wo : workOrderList) {
                    HSEQWrapper hseq = hseqMap.get(wo.Id);

                    FieldWrapper fieldWrapWoNo = new FieldWrapper();
                    fieldWrapWoNo.name = 'workordernumber';
                    fieldWrapWoNo.label = String.valueOf(fieldsMapWO.get('WorkOrderNumber').getDescribe().getLabel());
                    fieldWrapWoNo.value = wo.WorkOrderNumber;
                    fieldWrapWoNo.hidden = false;
                    hseq.fields.add(fieldWrapWoNo);

                    FieldWrapper fieldWrapPartner = new FieldWrapper();
                    fieldWrapPartner.name = 'partner';
                    fieldWrapPartner.label = String.valueOf(fieldsMapWO.get('XC_AssignedPartner__c').getDescribe().getLabel());
                    fieldWrapPartner.value = wo.XC_AssignedPartner__r.Name;
                    fieldWrapPartner.hidden = false;
                    hseq.fields.add(fieldWrapPartner);

                    FieldWrapper fieldWrapAddress = new FieldWrapper();
                    fieldWrapAddress.name = 'address';
                    fieldWrapAddress.label = String.valueOf(fieldsMapWO.get('XC_Address__c').getDescribe().getLabel());
                    fieldWrapAddress.value = wo.XC_Address__r.Name;
                    fieldWrapAddress.hidden = false;
                    hseq.fields.add(fieldWrapAddress);

                    FieldWrapper fieldWrapScheduledDate = new FieldWrapper();
                    fieldWrapScheduledDate.name = 'date';
                    fieldWrapScheduledDate.label = String.valueOf(fieldsMapWO.get('XC_ScheduledStart__c').getDescribe().getLabel());
                    // fieldWrapScheduledDate.value = String.valueOf(wo.XC_ScheduledStart__c);
                    fieldWrapScheduledDate.value = wo.XC_ScheduledStart__c != null ? String.valueOf(Date.newInstance(wo.XC_ScheduledStart__c.year(), wo.XC_ScheduledStart__c.month(), wo.XC_ScheduledStart__c.day())) : null;
                    fieldWrapScheduledDate.hidden = false;
                    hseq.fields.add(fieldWrapScheduledDate);

                    FieldWrapper fieldWrapCity = new FieldWrapper();
                    fieldWrapCity.name = 'city';
                    fieldWrapCity.label = 'City';
                    fieldWrapCity.value = wo.XC_Address__r.XC_City__c;
                    fieldWrapCity.hidden = true;
                    hseq.fields.add(fieldWrapCity);


                    //federico.demichelis@eng.it 23/05/22 - START
                    FieldWrapper fieldWrapCountry = new FieldWrapper();
                    fieldWrapCountry.name = 'country';
                    // fieldWrapCountry.label = System.label.TA_Country;
                    fieldWrapCountry.label = String.valueOf(fieldsMapWO.get('XC_Country__c').getDescribe().getLabel());
                    fieldWrapCountry.value = wo.XC_Country__c;
                    fieldWrapCountry.hidden = false;
                    hseq.fields.add(fieldWrapCountry);
                    //federico.demichelis@eng.it 23/05/22 - END
                }

            }


        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC258_HSEQManagement] buildFieldsList - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC258_HSEQManagement', 'buildFieldsList', errorMessage, 0, errorMessage, null);
        }
        return hseqMap.values();
    }

    /**
    * @description 
    * @author benjamin.geronimo | 29-07-2021 
    * @param hseqList 
    * @param isExternal 
    * @return List<HSEQWrapper> 
    **/
    private static List<HSEQWrapper> getQualityChecks( List<HSEQWrapper> hseqList, Boolean isExternal) {
        List<HSEQWrapper> hseqListToReview = new List<HSEQWrapper>();
        Map<String, List<XC_B2BG_QualityCheck__c>> recIdToQcMap = new Map<String, List<XC_B2BG_QualityCheck__c>>();
        
        try {

            List<String> relatedIdList = new List<String>();
            for(HSEQWrapper hseq : hseqList) relatedIdList.add(hseq.recordId);

            //String qcQuery = 'SELECT Id, Name, XC_Status__c, XC_Case__c, XC_WorkOrder__c FROM XC_B2BG_QualityCheck__c WHERE XC_Status__c = \'In modification (controller)\'';
            String qcQuery = 'SELECT Id, Name, XC_Status__c, XC_Case__c, XC_WorkOrder__c FROM XC_B2BG_QualityCheck__c WHERE';
            
            if(!isExternal) qcQuery += ' XC_Case__c IN :relatedIdList';
            else qcQuery += ' XC_WorkOrder__c IN :relatedIdList';

            List<String> qcIdToReview = new List<String>();
            for( XC_B2BG_QualityCheck__c qc : Database.query(qcQuery)) {
                if(!isExternal) {
                    if(qcIdToReview.contains(qc.XC_Case__c)) recIdToQcMap.get(qc.XC_Case__c).add(qc);
                    else recIdToQcMap.put(qc.XC_Case__c, new List<XC_B2BG_QualityCheck__c>{ qc });
                    qcIdToReview.add(qc.XC_Case__c);

                } else {
                    if(qcIdToReview.contains(qc.XC_WorkOrder__c)) recIdToQcMap.get(qc.XC_WorkOrder__c).add(qc);
                    else recIdToQcMap.put(qc.XC_WorkOrder__c, new List<XC_B2BG_QualityCheck__c>{ qc });
                    qcIdToReview.add(qc.XC_WorkOrder__c);
                }
            }

            for (HSEQWrapper wrapper : hseqList){
                Boolean toReview = false;
                Boolean isCompleted = true;

                if(!recIdToQcMap.isEmpty() && !qcIdToReview.isEmpty() && qcIdToReview.contains(wrapper.recordId)) {
                    //wrapper.toReview = true;
                    for(XC_B2BG_QualityCheck__c qc : recIdToQcMap.get(wrapper.recordId)) {
                        if(qc.XC_Status__c == 'In modification (controller)' || qc.XC_Status__c == 'Draft') {
                            if(qc.XC_Status__c == 'In modification (controller)') toReview = true;
                            isCompleted = false;
                        }
                    }
                } else isCompleted = false;

                wrapper.toReview = toReview;
                wrapper.isCompleted = isCompleted;
                hseqListToReview.add(wrapper);
            }
            

        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC258_HSEQManagement] getQualityCheckList - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC258_HSEQManagement', 'getQualityCheckList', errorMessage, 0, errorMessage, null);
        }
        return hseqListToReview;
    }

    /**
    * @description 
    * @author benjamin.geronimo | 21-06-2021 
    * @param caseId 
    * @return CreateWorkOrderResult 
    **/
    @AuraEnabled
    public static CreateWorkOrderResult createDummyWorkOrderFromCase(String caseId) {
        
        Savepoint savePoint = Database.setSavepoint();
        CreateWorkOrderResult result = new CreateWorkOrderResult();

        try {
            if( Test.isRunningTest() && caseId == null) {
                CalloutException e = new CalloutException();
                e.setMessage('caseId is null!');
                throw e;
            }

            //Check if wo exist
            List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder
                                            WHERE XC_WorkTypeCategory__c = 'Quality Check Inspection'
                                            AND CaseId =: caseId];

            if(!workOrderList.isEmpty()) {
                result.success = true;
                result.workOrderId =  workOrderList[0].Id;
            } else {

                List<Case> caseRecord = [SELECT Id, XC_WorkOrder__r.XC_AssignedPartner__c, XC_WorkOrder__c, XC_WorkOrder__r.XC_Address__c  FROM Case WHERE Id =: caseId LIMIT 1];
                
                if (!caseRecord.isEmpty()) {
                
                    //CREO IL WORKORDER
                    WorkOrder dummyWorkOrderToInsert = new WorkOrder();

                    dummyWorkOrderToInsert.OwnerId = UserInfo.getUserId();
                    dummyWorkOrderToInsert.StartDate = DateTime.now();
                    dummyWorkOrderToInsert.XC_AssignedPartner__c = caseRecord[0].XC_WorkOrder__r.XC_AssignedPartner__c;
                    dummyWorkOrderToInsert.TA_Phase__c = 'Preservice';
                    dummyWorkOrderToInsert.XC_WorkTypeLabel__c = 'Quality Check Inspection';
                    dummyWorkOrderToInsert.XC_WorkTypeCategory__c = 'Quality Check Inspection';
                    dummyWorkOrderToInsert.CaseId  = caseRecord[0].Id;
                    dummyWorkOrderToInsert.Status  = 'In Progress';
                    dummyWorkOrderToInsert.XC_LegalEntity__c  = 'EnelXItalia';
                    dummyWorkOrderToInsert.XC_Segment__c = 'B2C';
                    dummyWorkOrderToInsert.XC_Address__c = caseRecord[0].XC_WorkOrder__r.XC_Address__c;
                    dummyWorkOrderToInsert.ParentWorkOrderId = caseRecord[0].XC_WorkOrder__c;
                    dummyWorkOrderToInsert.XC_CreatedAutomaticallyBySystem__c = true;
                    dummyWorkOrderToInsert.RecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('XC_ITA_WorkOrder').getRecordTypeId();
                    
                    XC_UTIL_Sobject.WrapperResult resultInsertWorkOrder = XC_UTIL_Sobject.insertRecord(dummyWorkOrderToInsert);
                    System.debug('@@>> WorkOrder inserito >>> ' + resultInsertWorkOrder);
            
                    if(!resultInsertWorkOrder.success){
                        Database.rollback(savePoint);
                        result.success = false;
                        result.errorMessage = resultInsertWorkOrder.errorMessage;
                    } else {
                        result.success = true;
                        result.workOrderId = resultInsertWorkOrder.recordId;
                    }
                }
            }

        } catch (Exception e) {
            Database.rollback(savePoint);
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC258_HSEQManagement] createDummyWorkOrderFromCase - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC258_HSEQManagement', 'createDummyWorkOrderFromCase', errorMessage, 0, errorMessage, null);
            
            result.success = false;
            result.errorMessage = errorMessage;
            
        }
        return result;
        
    }


}