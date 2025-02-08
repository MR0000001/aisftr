public without sharing class TA_LCC221_QuestionAnswer {

    public class InfoBag {
        @AuraEnabled
        public TA_CustomLabel__mdt question {get;set;}
        @AuraEnabled
        public List<AnswerWrapper> answers {get;set;}
    }

    public class AnswerWrapper {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public List<Object> value {get;set;}
    }

    @AuraEnabled
    public static String initialize(String customSerialized) {
        InfoBag infoBag = new InfoBag();
        infoBag.question = new TA_CustomLabel__mdt();
        infoBag.answers = new List<AnswerWrapper>();
        try {
            Map<String, Object> custom = (Map<String, Object>) JSON.deserializeUntyped(customSerialized);
            String question = String.valueOf(custom.get('question'));
            List<String> listAnswerMasterLabel = new List<String>();
            Map<String, Object> mapAnswersLabelValue = new Map<String, Object>();
            List<Object> answers = (List<Object>) custom.get('answers');

            for(Object answer : answers) {
                Map<String, Object> mapAnswer = (Map<String, Object>) answer;
                mapAnswersLabelValue.put(String.valueOf(mapAnswer.get('label')), mapAnswer.get('value'));
                listAnswerMasterLabel.add(String.valueOf(mapAnswer.get('label')));
            }

            List<TA_CustomLabel__mdt> listCustomLabel = [SELECT Id,
                                                            MasterLabel,
                                                            TA_Label__c,
                                                            TA_Language__c
                                                        FROM TA_CustomLabel__mdt
                                                        WHERE (TA_Language__c = :UserInfo.getLanguage() OR TA_Language__c = 'en_US')
                                                            AND (MasterLabel = :question OR MasterLabel IN :listAnswerMasterLabel)];

            Map<String, TA_CustomLabel__mdt> mapCustomLabelFiltered = new Map<String, TA_CustomLabel__mdt>();
            for(TA_CustomLabel__mdt customLabel : listCustomLabel) {
                if(customLabel.TA_Language__c == UserInfo.getLanguage() ||
                (customLabel.TA_Language__c == 'en_US' && !mapCustomLabelFiltered.containsKey(customLabel.MasterLabel))) {
                    mapCustomLabelFiltered.put(customLabel.MasterLabel, customLabel);
                }
            }

            infoBag.answers = new AnswerWrapper[answers.size()];
            for(TA_CustomLabel__mdt customLabel : mapCustomLabelFiltered.values()) {
                if(customLabel.MasterLabel == question) {
                    infoBag.question = customLabel;
                } else if(listAnswerMasterLabel.indexOf(customLabel.MasterLabel) != -1) {
                    AnswerWrapper answerWrapper = new AnswerWrapper();
                    answerWrapper.label = customLabel.TA_Label__c;
                    answerWrapper.name = customLabel.MasterLabel;
                    if(mapAnswersLabelValue.containsKey(customLabel.MasterLabel)) {
                        answerWrapper.value = (List<Object>) mapAnswersLabelValue.get(customLabel.MasterLabel);
                    }
                    infoBag.answers.set(listAnswerMasterLabel.indexOf(customLabel.MasterLabel), answerWrapper);
                }
            }
        } catch(Exception e) {
            String errorMessage = 'An exception has occured : ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString();           
            System.debug('[TA_LCC221_QuestionAnswer] initialize - EXCEPTION HANDLER: ' + errorMessage);
            TA_UTIL_LogManagement.createLog('TA_LCC221_QuestionAnswer', 'initialize', errorMessage, 0, errorMessage, null);
        }
        return JSON.serialize(infoBag);
    }
}