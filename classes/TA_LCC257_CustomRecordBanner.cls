public without sharing class TA_LCC257_CustomRecordBanner {

    public class InfoBag {
        @AuraEnabled
        public WorkOrder workOrder {get;set;}
        @AuraEnabled
        public String general {get;set;}
        @AuraEnabled
        public String custom {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String description {get;set;}
    }

    @AuraEnabled
    public static String initialize(String recordId) {
        InfoBag infoBag = new InfoBag();
        infoBag.workOrder = new WorkOrder();
        infoBag.title = '';
        infoBag.description = '';
        try {
            String currentUserPermissionSetName;
            if(Test.isRunningTest()) {
                currentUserPermissionSetName = 'B2C_Italy_Set';
            } else {
                Id currentUserProfileId = UserInfo.getUserId();
                List<PermissionSetAssignment> currentUserPermissionSetList = [SELECT PermissionSet.Name
                                                                                FROM PermissionSetAssignment
                                                                                WHERE AssigneeId =: currentUserProfileId
                                                                                    AND PermissionSet.Description = 'TA_Configuration_Language'];

                if(!currentUserPermissionSetList.isEmpty()) {
                    currentUserPermissionSetName = currentUserPermissionSetList[0].PermissionSet.Name;
                }
            }

            //START | ENCXRM-151 HSEQ BGO
            String userProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1][0].Name;

            // List<TA_Capability_Configuration__c> cbConfigurations = [SELECT Id,
            //                                                             TA_DeveloperName__c,
            //                                                             TA_JSON_Param__c,
            //                                                             TA_Index__c,
            //                                                             TA_Value__c,
            //                                                             TA_WorkType_Category__c
            //                                                         FROM TA_Capability_Configuration__c
            //                                                         WHERE TA_Active__c = true
            //                                                             AND TA_Type__c = 'RecordBanner'
            //                                                             AND TA_DeveloperName__c  = 'TA_LCP257_CustomRecordBanner'
            //                                                             AND TA_Configuration_Set__c =: currentUserPermissionSetName];

            String cbQuery = 'SELECT Id, TA_DeveloperName__c, TA_JSON_Param__c, TA_Index__c, TA_Value__c, TA_WorkType_Category__c ' 
                            + 'FROM TA_Capability_Configuration__c ' 
                            + 'WHERE TA_Type__c = \'RecordBanner\' ' 
                            + 'AND TA_Active__c = true '
                            + 'AND TA_DeveloperName__c = \'TA_LCP257_CustomRecordBanner\' '
                            + 'AND TA_Configuration_Set__c = \'' + currentUserPermissionSetName + '\' ';

            if( TA_CNS201_DynamicLayoutContainer.CB_HSEQ_PROFILE_LIST.contains(userProfileName) ) cbQuery += ' AND TA_ProfileName__c = \'' + userProfileName + '\' ';

            cbQuery += 'ORDER BY TA_Index__c ASC';

            System.debug('>_> cbQuery : ' + cbQuery);

            List<TA_Capability_Configuration__c> cbConfigurations = Database.query(cbQuery);
            System.debug('>_> cbConfigurations : ' + cbConfigurations);
            //END | ENCXRM-151 HSEQ BGO

            Set<String> dynamicFields = new Set<String>();
            dynamicFields.add('XC_WorkTypeCategory__c');
            for(TA_Capability_Configuration__c cbConfig : cbConfigurations) {
                Map<String, Object> jsonParams = (Map<String, Object>) JSON.deserializeUntyped(cbConfig.TA_JSON_Param__c);
                infoBag.general = JSON.serialize(jsonParams.get('general'));
                infoBag.custom = JSON.serialize(jsonParams.get('custom'));
                Map<String, Object> general = (Map<String, Object>) jsonParams.get('general');
                dynamicFields.addAll(String.valueOf(general.get('defaultTitle')).split(','));
                dynamicFields.addAll(String.valueOf(general.get('description')).split(','));
            }

            String woQuery = 'SELECT Id';
            for(String dynamicField : dynamicFields) {
                woQuery += ', ' + dynamicField;
            }
            woQuery += ' FROM WorkOrder WHERE Id = \'' + recordId + '\'';

            List<WorkOrder> workOrderList = Database.query(woQuery);
            if(workOrderList.size() > 0) {
                infoBag.workOrder = workOrderList[0];
                for(TA_Capability_Configuration__c cbConfig : cbConfigurations) {
                    if(cbConfig.TA_WorkType_Category__c == infoBag.workOrder.XC_WorkTypeCategory__c) {
                        Map<String, Object> jsonParams = (Map<String, Object>) JSON.deserializeUntyped(cbConfig.TA_JSON_Param__c);
                        infoBag.general = JSON.serialize(jsonParams.get('general'));
                        infoBag.custom = JSON.serialize(jsonParams.get('custom'));
                        Map<String, Object> general = (Map<String, Object>) jsonParams.get('general');
                        for(String field : String.valueOf(general.get('defaultTitle')).split(',')) {
                            if(field.contains('toLabel(')) {
                                field = field.substring(field.indexOf(' ') + 1, field.length());
                            }
                            if(field.contains('.')) {
                                String woString = JSON.serialize(infoBag.workOrder);
                                Map<String, Object> parentMap = (Map<String, Object>) JSON.deserializeUntyped(woString);
                                for(Integer i = 0; i < field.split('\\.').size(); i++) {
                                    if(parentMap != null && parentMap.get(field.split('\\.')[i]) != null) {
                                        if(i == field.split('\\.').size()-1) {
                                            if(infoBag.title == '') {
                                                infoBag.title = String.valueOf(parentMap.get(field.split('\\.')[i]));
                                            } else {
                                                infoBag.title += ' - ' + String.valueOf(parentMap.get(field.split('\\.')[i]));
                                            }
                                        } else {
                                            parentMap = (Map<String, Object>) parentMap.get(field.split('\\.')[i]);
                                        }
                                    }
                                }
                            } else {
                                if(infoBag.workOrder.get(field) != null) {
                                    if(infoBag.title == '') {
                                        infoBag.title = String.valueOf(infoBag.workOrder.get(field));
                                    } else {
                                        infoBag.title += ' - ' + String.valueOf(infoBag.workOrder.get(field));
                                    }
                                }
                            }
                        }
                        for(String field : String.valueOf(general.get('description')).split(',')) {
                            if(field.contains('toLabel(')) {
                                field = field.substring(field.indexOf(' ') + 1, field.length());
                            }

                            if(field.contains('.')) {
                                String woString = JSON.serialize(infoBag.workOrder);
                                Map<String, Object> parentMap = (Map<String, Object>) JSON.deserializeUntyped(woString);
                                for(Integer i = 0; i < field.split('\\.').size(); i++) {
                                    if(parentMap != null && parentMap.get(field.split('\\.')[i]) != null) {
                                        if(i == field.split('\\.').size()-1) {
                                            if(infoBag.description == '') {
                                                infoBag.description = String.valueOf(parentMap.get(field.split('\\.')[i]));
                                            } else {
                                                infoBag.description += ' - ' + String.valueOf(parentMap.get(field.split('\\.')[i]));
                                            }
                                        } else {
                                            parentMap = (Map<String, Object>) parentMap.get(field.split('\\.')[i]);
                                        }
                                    }
                                }
                            } else {
                                if(infoBag.workOrder.get(field) != null) {
                                    if(infoBag.description == '') {
                                        infoBag.description = String.valueOf(infoBag.workOrder.get(field));
                                    } else {
                                        infoBag.description += ' - ' + String.valueOf(infoBag.workOrder.get(field));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC198_ProcessIndicator] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC198_ProcessIndicator', 'retrieveWO', errorMessage, 0, errorMessage, null);
        }
        return JSON.serialize(infoBag);
    }
}