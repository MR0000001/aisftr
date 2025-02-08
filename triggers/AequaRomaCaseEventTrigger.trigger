trigger AequaRomaCaseEventTrigger on AequaRoma_Case__e (after insert) {
    List<PlatFormEvents_Log__c> logList = new List<PlatFormEvents_Log__c>();
    for (AequaRoma_Case__e event : Trigger.new) {
        PlatFormEvents_Log__c log = new PlatFormEvents_Log__c();
        log.Service__c = 'AEQUAROMA CRM';
        log.Method_Name__c = 'Integrazione Case';
        log.Note__c = 'CaseId: '+event.CaseId__c;
        log.isError__c = false;
        logList.add(log);
    }
    insert logList;
}