trigger XC_TR_PPM_ProjecTask on project_cloud__Project_Task__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_PPM_Project_Task_Handler(), Trigger.operationType,constants.MDT_SKIP_WBE_TRACKING);

}