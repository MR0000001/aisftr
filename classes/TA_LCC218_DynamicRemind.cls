public without sharing class TA_LCC218_DynamicRemind {
    @AuraEnabled
    public static List<TA_CustomLabel__mdt> getCustomLabels(String language, List<String> customLabels) {
        List<TA_CustomLabel__mdt> listCustomLabel = new List<TA_CustomLabel__mdt>();
        try {
            List<TA_CustomLabel__mdt> listAllCustomLabel = [SELECT Id,
                                                                TA_Label__c,
                                                                MasterLabel,
                                                                TA_Language__c
                                                            FROM TA_CustomLabel__mdt
                                                            WHERE (TA_Language__c = :language OR TA_Language__c = 'en_US')
                                                                AND MasterLabel IN :customLabels];

            Map<String, TA_CustomLabel__mdt> mapCustomLabelFiltered = new Map<String, TA_CustomLabel__mdt>();
            for(TA_CustomLabel__mdt customLabel : listAllCustomLabel) {
                if(customLabel.TA_Language__c == language ||
                (customLabel.TA_Language__c == 'en_US' && !mapCustomLabelFiltered.containsKey(customLabel.MasterLabel))) {
                    mapCustomLabelFiltered.put(customLabel.MasterLabel, customLabel);
                }
            }
            listCustomLabel.addAll(mapCustomLabelFiltered.values());
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();
            System.debug('[TA_LCC218_DynamicRemind] getCustomLabels - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC218_DynamicRemind', 'getCustomLabels', errorMessage, 0, errorMessage, null);
        }
        return listCustomLabel;
    }
}