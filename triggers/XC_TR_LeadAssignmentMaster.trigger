trigger XC_TR_LeadAssignmentMaster on XC_LeadAssignmentMaster__c (before insert, before update, before delete, after insert, after update, after delete) {
  XC_TR_Dispatcher.init(new XC_TR_LeadAssignmentMaster_Handler(), Trigger.operationType);
}