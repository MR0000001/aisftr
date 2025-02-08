trigger XC_TR_PPM_Projec on project_cloud__Project__c (before insert, before update, before delete, after insert, after update, after delete) {
    XC_TR_Dispatcher.init(new XC_TR_PPM_Project_Handler(), Trigger.operationType,constants.MDT_SKIP_WBE_TRACKING);

}