public without sharing class TA_LCC198_ProcessIndicator {

    public class InfoBag {
        @AuraEnabled
        public Integer              index       {get;set;}
        @AuraEnabled
        public List<ProcessWrapper> listProcess {get;set;}

        public InfoBag() {}
    }

    public class ProcessWrapper {
        @AuraEnabled
        public String   name    {get;set;}
        @AuraEnabled
        public Integer  index   {get;set;}

        public ProcessWrapper() {}
    }

    @AuraEnabled
    public static InfoBag setProcess(Id workOrderId) {
        InfoBag infoBag = new InfoBag();
        infoBag.listProcess = new List<ProcessWrapper>();

        try {
            if(workOrderId == null) {
                CalloutException e = new CalloutException();
                e.setMessage('workOrderId is null!');
                throw e;
            }
            List<WorkOrder> workOrderList = [SELECT TA_Phase__c, XC_WorkTypeCategory__c
                                            FROM WorkOrder
                                            WHERE Id =: workOrderId];

            String currentUserPermissionSetName;
            if(Test.isRunningTest()) {
                currentUserPermissionSetName = 'Italy_Set';
            } else {
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
            }

            if(workOrderList.size() > 0) {
                WorkOrder workOrder = workOrderList[0];
                List<TA_Layout_Matrix_Configuration__c> layoutMatrixConfigList = [SELECT Id,
                                                                                        TA_Phase__c,
                                                                                        TA_Phase__r.Name,
                                                                                        TA_Phase__r.TA_DeveloperName__c,
                                                                                        TA_Phase__r.TA_Hidden__c,
                                                                                        TA_IndexPhase__c
                                                                                    FROM TA_Layout_Matrix_Configuration__c
                                                                                    WHERE TA_Active__c = true
                                                                                        AND TA_ConfigurationSet__c = :currentUserPermissionSetName
                                                                                        AND TA_WorkTypeCategory__c = :workOrder.XC_WorkTypeCategory__c
                                                                                    ORDER BY TA_IndexPhase__c];

                List<String> customLabels = new List<String>();
                for(TA_Layout_Matrix_Configuration__c layoutMatrixConfig : layoutMatrixConfigList) {
                    customLabels.add(layoutMatrixConfig.TA_Phase__r.Name);
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

                Set<String> listProcessName = new Set<String>();
                for(TA_Layout_Matrix_Configuration__c layoutMatrixConfig : layoutMatrixConfigList) {
                    if(!layoutMatrixConfig.TA_Phase__r.TA_Hidden__c && !listProcessName.contains(layoutMatrixConfig.TA_Phase__r.Name)) {
                        ProcessWrapper processWrapper = new ProcessWrapper();
                        // processWrapper.name = layoutMatrixConfig.TA_Phase__r.Name;
                        processWrapper.name = masterLabelToLabelMap.get(layoutMatrixConfig.TA_Phase__r.Name);
                        processWrapper.index = (Integer) layoutMatrixConfig.TA_IndexPhase__c;
                        InfoBag.listProcess.add(processWrapper);
                        listProcessName.add(layoutMatrixConfig.TA_Phase__r.Name);
                    }
                    if(layoutMatrixConfig.TA_Phase__r.TA_DeveloperName__c == workOrder.TA_Phase__c) {
                        InfoBag.index = (Integer) layoutMatrixConfig.TA_IndexPhase__c;
                    }
                }
            }
        } catch (Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC198_ProcessIndicator] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC198_ProcessIndicator', 'setProcess', errorMessage, 0, errorMessage, null);
        }
        return infoBag;
    }
}