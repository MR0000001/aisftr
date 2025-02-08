public without sharing class TA_LCC208_Modal {

    public class ActionWrapper {
        @AuraEnabled
        public String   Id              {get; set;}
        @AuraEnabled
        public String   label           {get; set;}
        @AuraEnabled
        public String   developerName   {get; set;}
        @AuraEnabled
        public String   type            {get; set;}

        public actionWrapper() {}

        public actionWrapper(String Id, String label, String developerName, String type) {
            this.Id             = Id;
            this.label          = label;
            this.developerName  = developerName;
            this.type           = type;
        }
    }

    public class MatrixWrapper {
        @AuraEnabled
        public String           Id              {get; set;}
        @AuraEnabled
        public Double           indexAction     {get; set;}
        @AuraEnabled
        public String           nextPhase       {get; set;}
        @AuraEnabled
        public actionWrapper    actionWrp       {get; set;}
        @AuraEnabled
        public Boolean          updateNextPhase {get; set;}
        @AuraEnabled
        public String           methods         {get; set;}
        @AuraEnabled
        public Boolean          updateFields    {get; set;}

        public matrixWrapper() {}

        public matrixWrapper(String Id, Decimal indexAction, String nextPhase, Boolean updateNextPhase,
                             String methods, Boolean updateFields, ActionWrapper actionWrp) {
            this.Id                 = Id;
            this.indexAction        = indexAction;
            this.nextPhase          = nextPhase;
            this.updateNextPhase    = updateNextPhase;
            this.methods            = methods;
            this.updateFields       = updateFields;
            this.actionWrp          = actionWrp;
        }
    }

    @AuraEnabled
    public static List<matrixWrapper> initialize(String phaseName, List<String> actionsName, String workTypeCategory, String country) {
        List<matrixWrapper> matrixWrappers = new List<matrixWrapper>();
        try {
            if(String.isNotBlank(phaseName) && !actionsName.isEmpty()) {
                List<TA_Layout_Matrix_Configuration__c> matrixConfigs = [SELECT Id,
                                                                            TA_IndexAction__c,
                                                                            TA_Methods__c,
                                                                            TA_NextPhase__c,
                                                                            TA_UpdateNextPhase__c,
                                                                            TA_Action__c,
                                                                            TA_Action__r.Name,
                                                                            TA_Action__r.TA_DeveloperName__c,
                                                                            TA_Action__r.TA_Type__c,
                                                                            TA_Update_Fields__c
                                                                        FROM TA_Layout_Matrix_Configuration__c
                                                                        WHERE TA_Phase__r.TA_DeveloperName__c = :phaseName
                                                                            AND TA_Action__r.TA_DeveloperName__c IN :actionsName
                                                                            AND TA_WorkTypeCategory__c = :workTypeCategory
                                                                            AND TA_ConfigurationSet__c = :country
                                                                        ORDER BY TA_IndexAction__c];

                //START FIX - [#20210226AL] - CustomMetadata Labels Management
                List<String> customLabels = new List<String>();
                for(TA_Layout_Matrix_Configuration__c layoutMatrixConfig : matrixConfigs) {
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

                if(!matrixConfigs.isEmpty()) {
                    for(TA_Layout_Matrix_Configuration__c matrixConfig : matrixConfigs) {
                        matrixWrappers.add(new MatrixWrapper(matrixConfig.Id,
                                                                matrixConfig.TA_IndexAction__c,
                                                                matrixConfig.TA_NextPhase__c,
                                                                matrixConfig.TA_UpdateNextPhase__c,
                                                                matrixConfig.TA_Methods__c,
                                                                matrixConfig.TA_Update_Fields__c,
                                                                new ActionWrapper(matrixConfig.TA_Action__c,
                                                                                    //START FIX - [#20210226AL] - CustomMetadata Labels Management  
                                                                                    masterLabelToLabelMap.get(matrixConfig.TA_Action__r.Name),
                                                                                    //END FIX - [#20210226AL] - CustomMetadata Labels Management  
                                                                                    matrixConfig.TA_Action__r.TA_DeveloperName__c,
                                                                                    matrixConfig.TA_Action__r.TA_Type__c)));
                    }
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC208_Modal] EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC208_Modal', 'initialize', errorMessage, 0, errorMessage, null);
        }
        return matrixWrappers;
    }
}