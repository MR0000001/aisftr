public without sharing class TA_LCC264_DynamicListView {

    public class WorkOrderWrapper {
        @AuraEnabled
        public String id {get; set;}
        @AuraEnabled
        public String woNumber {get; set;}
        @AuraEnabled
        public String workTypeCategory {get; set;}
        @AuraEnabled
        public String workTypeCategoryTranslation {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String statusTranslation {get; set;}
        @AuraEnabled
        public String faultType {get; set;}
        
        public WorkOrderWrapper(String id, String woNumber, String workTypeCategory, String status, String faultType) {
            this.id = id;
            this.woNumber = woNumber;
            this.workTypeCategory = workTypeCategory;
            this.status = status;
            this.faultType = faultType;
        }
    }

    @AuraEnabled
    public static String getListViews(String objectName){
        String response = '';
        try {
            if(String.isNotBlank(objectName)) {
                response = JSON.serialize([SELECT Id, Name FROM ListView WHERE SobjectType = :objectName]);
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC264_DynamicListView] getLitViewRecords - EXCEPTION HANDLER: ' + errorMessage);
            response = errorMessage;
        }
        return response;
    }

    @AuraEnabled
    public static String getLitViewRecords(String filterId, String objectName) { 
        String response = '';
        try {
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            String endPoinURL = baseUrl+'/services/data/v50.0/sobjects/'+ objectName +'/listviews/'+ filterId +'/results?limit=1000';
    
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoinURL);
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    
            Http http = new Http();
            HttpResponse httpResponse = http.send(req);

            if(httpResponse.getStatusCode() == 301 || httpResponse.getStatusCode() == 302) {    
                req.setEndpoint(httpResponse.getHeader('Location'));
                httpResponse = new Http().send(req);
            }

            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            response = JSON.serialize(tokenResponse);

        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC264_DynamicListView] getLitViewRecords - EXCEPTION HANDLER: ' + errorMessage);
            response = errorMessage;
        }
        return response;
    }

    @AuraEnabled
    public static String getRelatedWorkOrders(Id accountId) { 
        String response = '[]';
        try {
            if(String.isNotBlank(accountId)) {
                List<WorkOrderWrapper> workOrderWrappers = new List<WorkOrderWrapper>();
                List<WorkOrder> workOrders = [SELECT Id, WorkOrderNumber, XC_WorkTypeCategory__c, Status, CaseId, Case.XC_FaultType__c FROM WorkOrder WHERE AccountId = :accountId];
                if(!workOrders.isEmpty()) {
                    for(WorkOrder wo : workOrders) {
                        workOrderWrappers.add(
                            new WorkOrderWrapper(
                                wo.Id, 
                                wo.WorkOrderNumber, 
                                wo.XC_WorkTypeCategory__c, 
                                wo.Status,
                                String.isNotBlank(wo.CaseId) ? wo.Case.XC_FaultType__c : ''
                        ));
                    }
                    
                    Schema.SObjectType s = Schema.getGlobalDescribe().get('WorkOrder') ;
                    Schema.DescribeSObjectResult r = s.getDescribe() ;
                    Map<String,Schema.SObjectField> fields = r.fields.getMap() ;

                    Schema.DescribeFieldResult fiedlWoTypeResult = fields.get('XC_WorkTypeCategory__c').getDescribe();
                    List<Schema.PicklistEntry> pleWoType = fiedlWoTypeResult.getPicklistValues();
                    for( Schema.PicklistEntry pickValWoType : pleWoType){
                        for(WorkOrderWrapper woWrap : workOrderWrappers) {
                            if(woWrap.workTypeCategory == pickValWoType.getValue()) woWrap.workTypeCategoryTranslation = pickValWoType.getLabel();
                        }
                    }   

                    Schema.DescribeFieldResult fiedlStatusResult = fields.get('Status').getDescribe();
                    List<Schema.PicklistEntry> pleStatus = fiedlStatusResult.getPicklistValues();
                    for( Schema.PicklistEntry pickValStatus : pleStatus){
                        for(WorkOrderWrapper woWrap : workOrderWrappers) {
                            if(woWrap.status == pickValStatus.getValue()) woWrap.statusTranslation = pickValStatus.getLabel();
                        }
                    }


                    response = JSON.serialize(workOrderWrappers);
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC264_DynamicListView] getLitViewRecords - EXCEPTION HANDLER: ' + errorMessage);
            response = errorMessage;
        }
        return response;
    }

    @AuraEnabled
    public static String searchAccount(String accountNameLike) {
        String response = '';
        if(String.isNotBlank(accountNameLike)) response = JSON.serialize([SELECT Id, Name FROM Account WHERE Name LIKE :accountNameLike + '%']);
        else response = 'No records found';
        return response;
    }

    @AuraEnabled
    public static String getPicklistValues(){
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, String>> statusPickValues = new List<Map<String, String>>();
        List<Map<String, String>> woTypePickValues = new List<Map<String, String>>();
        List<Map<String, String>> faultTypePickValues = new List<Map<String, String>>();

        Schema.SObjectType s = Schema.getGlobalDescribe().get('WorkOrder') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        
        Schema.DescribeFieldResult fiedlStatusResult = fields.get('Status').getDescribe();
        List<Schema.PicklistEntry> pleStatus = fiedlStatusResult.getPicklistValues();
        for( Schema.PicklistEntry pickValStatus : pleStatus){
            statusPickValues.add(new Map<String, String> {'label' => pickValStatus.getLabel(), 'value' => pickValStatus.getValue()});
        }    

        Schema.DescribeFieldResult fiedlWoTypeResult = fields.get('XC_WorkTypeCategory__c').getDescribe();
        List<Schema.PicklistEntry> pleWoType = fiedlWoTypeResult.getPicklistValues();
        for( Schema.PicklistEntry pickValWoType : pleWoType){
            woTypePickValues.add(new Map<String, String> {'label' => pickValWoType.getLabel(), 'value' => pickValWoType.getValue()});
        }  

        Schema.SObjectType sCase = Schema.getGlobalDescribe().get('Case') ;
        Schema.DescribeSObjectResult rCase = sCase.getDescribe() ;
        Map<String,Schema.SObjectField> fieldsCase = rCase.fields.getMap() ;

        Schema.DescribeFieldResult fiedlFaultTypeResult = fieldsCase.get('XC_FaultType__c').getDescribe();
        List<Schema.PicklistEntry> pleFaultType = fiedlFaultTypeResult.getPicklistValues();
        for( Schema.PicklistEntry pickValFaultType : pleFaultType){
            faultTypePickValues.add(new Map<String, String> {'label' => pickValFaultType.getLabel(), 'value' => pickValFaultType.getValue()});
        }  

        result.put('statusPickValues', statusPickValues);
        result.put('woTypePickValues', woTypePickValues);
        result.put('faultTypePickValues', faultTypePickValues);
        return JSON.serialize(result);
    }
}