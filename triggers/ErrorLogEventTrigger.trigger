/**
 * Created by ABOZZANO00 on 06/08/2020.
 */

trigger ErrorLogEventTrigger on Error_Log_Event__e (after insert) {
    private FeatureEnablement__mdt skipTrigger = FeatureEnablement__mdt.getInstance('ErrorLogEventTrigger');

    if(skipTrigger == null || skipTrigger.isActive__c) {
        List<Error_Log__c> errorList = new List<Error_Log__c>();
        for (Error_Log_Event__e event : Trigger.new) {
            Error_Log__c log = new Error_Log__c();
            log.Error_Message__c = event.Error_Message__c;
            log.User__c = event.User__c;
            log.Date__c = event.Date__c;
            log.Error_Row__c = event.Error_Row__c;
            log.Stack_Trace__c = event.Stack_Trace__c;
            log.Class_Name__c = event.Class_Name__c;
            log.Method_Name__c = event.Method_Name__c;
            log.Log_Typology__c = event.Log_Typology__c;
            log.Exception_Type__c = event.Exception_Type__c;
            log.Note__c = event.Note__c;
            errorList.add(log);
        }
        insert errorList;
    }
}